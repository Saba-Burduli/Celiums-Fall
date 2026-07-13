local AI = require("src.systems.ai")
local Assets = require("src.core.assets")
local Audio = require("src.core.audio")
local Cinematic = require("src.ui.cinematic")
local Collision = require("src.systems.collision")
local Combat = require("src.systems.combat")
local Companion = require("src.entities.companion")
local Config = require("src.core.config")
local Enemy = require("src.entities.enemy")
local GameSession = require("src.core.game_session")
local Levels = require("src.world.levels")
local Menu = require("src.ui.menu")
local Navigation = require("src.systems.navigation")
local NavigationGraph = require("src.systems.navigation_graph")
local Platforms = require("src.systems.platforms")
local Player = require("src.entities.player")
local Settings = require("src.core.settings")
local Validator = require("src.world.validator")
local WorldRenderer = require("src.ui.world_renderer")

local Smoke = {}

function Smoke.run()
  local game = GameSession.new(nil, Audio)
  assert(game.cinematic and game.cinematic.area == "forest", "opening lore cinematic did not start")
  while game.cinematic do Cinematic.advance(game) end
  local rooms = { "forest", "forest_depths", "forest_ruins", "shrine", "shrine_crypt", "ossuary",
    "mountain_path", "black_keep", "mountain" }
  for _, room in ipairs(rooms) do
    GameSession.enterArea(game, room)
    assert(game.level and game.level.name, "missing room: " .. room)
    assert(game.enemies and game.items, "missing encounter data: " .. room)
    local valid, validationError = Validator.area(room, Levels)
    assert(valid, validationError)
    local jumper = Player.new(game.level.entry[1], 607)
    jumper.onGround, jumper.coyote = true, .11
    assert(Player.jump(jumper), "jump setup failed: " .. room)
    for _ = 1, 150 do
      Collision.moveHorizontal(jumper, jumper.speed * .016, game.physics.walls)
      Collision.applyPlatformPhysics(jumper, game.physics.platforms, .016, 1500)
      if jumper.supportingPlatformId == "static:2" then break end
    end
    assert(jumper.supportingPlatformId == "static:2", "first elevated platform is unreachable: " .. room)
    game.cinematic = nil
  end
  local original = Assets.current
  Assets.toggle(); Assets.toggle()
  assert(Assets.current == original, "asset set toggle did not round-trip")
  game.companion.status, game.player.chainUnlocked = "allied", true
  GameSession.enterArea(game, "forest_depths")
  assert(Companion.present(game.companion, game.area), "Sillius should be present")
  local moving
  for _, platform in ipairs(game.physics.platforms) do if platform.moving then moving = platform; break end end
  assert(moving, "Forest Depths should contain a moving platform")
  local rider = { x = moving.x + moving.w / 2, y = moving.y - 16, halfWidth = 10, halfHeight = 16, vy = 0 }
  local riderX, riderY = rider.x, rider.y
  Platforms.update(game.physics, .1, { rider })
  assert(rider.x ~= riderX or rider.y ~= riderY, "moving platform did not carry its rider")
  local wall = game.physics.walls[1]
  local collider = { x = wall.x - 14, y = wall.y + 20, halfWidth = 13, halfHeight = 20, vx = 100 }
  Collision.moveHorizontal(collider, 30, game.physics.walls)
  assert(collider.x + collider.halfWidth <= wall.x, "wall collision did not block movement")
  for _ = 1, 90 do Player.update(game.player, game.physics, .016) end
  assert(game.player.onGround, "player did not land on platform geometry")
  assert(Player.jump(game.player), "player could not jump from platform")
  Player.update(game.player, game.physics, .016)
  assert(game.player.vy < 0, "jump impulse was not applied")

  local traversal = Platforms.create({
    platforms = { { x = 0, y = Config.world.groundY, w = Config.world.width, h = Config.world.groundHeight }, { x = 240, y = 500, w = 180, h = 24 },
      { x = 500, y = 400, w = 180, h = 24 } },
    walls = { { x = 400, y = 532, w = 36, h = 100 } },
  })
  local elevated = traversal.platforms[2]
  local dropper = Player.new(300, elevated.y - 25)
  dropper.onGround, dropper.supportingPlatform, dropper.supportingPlatformId = true, elevated, elevated.id
  assert(Player.dropThrough(dropper), "player could not drop through a one-way ledge")
  for _ = 1, 90 do Collision.applyPlatformPhysics(dropper, traversal.platforms, .016, 1500) end
  assert(dropper.supportingPlatformId == "static:1", "player did not land below a dropped-through ledge")
  assert(not Player.dropThrough(dropper), "player dropped through solid ground")

  local groundNodes = 0
  for _, node in ipairs(traversal.navigation.nodes) do if node.platform.id == "static:1" then groundNodes = groundNodes + 1 end end
  assert(groundNodes == 2, "wall did not split the ground navigation span")
  local routeEnemy = { x = 100, y = 616, halfWidth = 10, halfHeight = 16, speed = 90, vy = 0,
    onGround = true, supportingPlatform = traversal.platforms[1], supportingPlatformId = "static:1" }
  local routePlayer = { x = 570, y = 375, halfWidth = 13, halfHeight = 25, onGround = true,
    supportingPlatform = traversal.platforms[3], supportingPlatformId = "static:3" }
  local startNode = NavigationGraph.nodeFor(traversal, routeEnemy)
  local goalNode = NavigationGraph.nodeFor(traversal, routePlayer)
  local route = NavigationGraph.route(traversal, startNode.id, goalNode.id)
  assert(route and #route > 1, "grounded enemy did not find a multi-platform route")
  Navigation.update(routeEnemy, routePlayer, traversal, .016)
  assert(routeEnemy.nav and routeEnemy.nav.route, "grounded enemy route state was not retained")
  local climber = Enemy.new("shadow_thrall", 100, 616)
  climber.onGround, climber.supportingPlatform, climber.supportingPlatformId = true, traversal.platforms[1], "static:1"
  for _ = 1, 720 do Enemy.update(climber, routePlayer, {}, traversal, .016) end
  assert(climber.supportingPlatformId == "static:3", "grounded enemy did not complete upward jumps")
  routePlayer.x, routePlayer.y = 520, 607
  routePlayer.supportingPlatform, routePlayer.supportingPlatformId = traversal.platforms[1], "static:1"
  for _ = 1, 360 do Enemy.update(climber, routePlayer, {}, traversal, .016) end
  assert(climber.supportingPlatformId == "static:1", "grounded enemy did not descend safely")
  local ledgeGuardX = climber.x
  routePlayer.supportingPlatform, routePlayer.supportingPlatformId = nil, nil
  for _ = 1, 60 do Enemy.update(climber, routePlayer, {}, traversal, .016) end
  assert(math.abs(climber.x - ledgeGuardX) < 1, "grounded enemy walked without a supported route")

  local shuttle = Platforms.create({
    platforms = { { x = 0, y = 632, w = 620, h = 88 } },
    movingPlatforms = { { x = 1000, y = 500, w = 120, h = 20, axis = "x", range = 350, speed = 1 } },
  })
  local mover = shuttle.platforms[2]
  local waiter = { x = 600, y = 616, halfWidth = 10, halfHeight = 16, speed = 80, vy = 0,
    onGround = true, supportingPlatform = shuttle.platforms[1], supportingPlatformId = "static:1" }
  local riderTarget = { x = mover.x + 60, y = mover.y - 25, halfWidth = 13, halfHeight = 25, onGround = true,
    supportingPlatform = mover, supportingPlatformId = mover.id }
  Navigation.update(waiter, riderTarget, shuttle, .016)
  assert(waiter.nav.waitState == "waiting_for_platform", "moving-platform route did not wait when unreachable")
  mover.x, riderTarget.x = 650, 710
  Navigation.update(waiter, riderTarget, shuttle, .016)
  assert(waiter.nav.waitState ~= "waiting_for_platform" and waiter.vy < 0, "enemy did not board a reachable moving platform")
  game.player.x, game.player.y, game.player.aimX, game.player.aimY = 400, 250, 1, 0
  assert(Combat.chainLightning(game), "chain lightning did not acquire patrol target")
  AI.update(game.enemies, game.boss, game.player, game.projectiles, game.physics, .016)
  for _, enemy in ipairs(game.enemies) do
    if enemy.behavior == "flying" or enemy.behavior == "teleport" then
      assert(not enemy.nav, "airborne or teleporting enemy entered grounded navigation")
    end
  end
  Combat.update(game, .016)
  local canvas = love.graphics.newCanvas(Config.world.width, Config.world.height)
  love.graphics.setCanvas(canvas)
  WorldRenderer.draw(game)
  Menu.pause(Settings, 2)
  game.seenCinematics.black_keep = nil
  assert(Cinematic.start(game, "black_keep"), "Black Keep lore cinematic did not start")
  assert(game.cinematic and game.cinematic.scene.pages[1], "Black Keep lore cinematic missing")
  Cinematic.draw(game)
  game.cinematic = nil
  assert(#Assets.gothic.bosses.mire_priest.idle == 5, "Mire Priest animation frames missing")
  assert(#Assets.gothic.bosses.lord_celium.idle == 8 and #Assets.gothic.bosses.lord_celium.attack == 3, "Lord Celium animation frames missing")
  GameSession.enterArea(game, "mountain")
  local bossTimer = game.boss.attackTimer
  AI.update(game.enemies, game.boss, game.player, game.projectiles, game.physics, .016)
  assert(game.boss.attackTimer < bossTimer and not game.boss.nav, "boss authored update regressed")
  WorldRenderer.draw(game)
  love.graphics.setCanvas()
  print("Celium's Fall smoke test passed: drop-through, platform A*, moving-platform waits, 9 panels, bosses/Sillius")
end

return Smoke
