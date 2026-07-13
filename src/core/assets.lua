local Config = require("src.core.config")

local Assets = { current = "gothic", sets = {}, gothic = {} }

local names = { "player", "shadow_thrall", "cursed_hound", "ash_cultist", "shielded_knight",
  "rift_witch", "winged_curse", "sillius", "mire_priest", "lord_celium", "stone", "villager" }

local curatedTiles = {
  player = { 0, 6 }, shadow_thrall = { 0, 7 }, cursed_hound = { 0, 10 }, ash_cultist = { 3, 6 },
  shielded_knight = { 1, 7 }, rift_witch = { 0, 8 }, winged_curse = { 1, 10 }, sillius = { 2, 6 },
  mire_priest = { 0, 9 }, lord_celium = { 2, 8 }, stone = { 4, 7 }, villager = { 1, 8 },
}

local function image(path)
  local result = love.graphics.newImage(path)
  result:setFilter("nearest", "nearest")
  return result
end

local function buildSet(path, coordinates)
  local sheet = image(path)
  local set = { image = sheet, quads = {} }
  for index, name in ipairs(names) do
    local col, row
    if coordinates then col, row = coordinates[name][1], coordinates[name][2] else col, row = index - 1, 0 end
    set.quads[name] = love.graphics.newQuad(col * 16, row * 16, 16, 16, sheet:getDimensions())
  end
  return set
end

local function sequence(path)
  local frames, files = {}, love.filesystem.getDirectoryItems(path)
  table.sort(files)
  for _, file in ipairs(files) do if file:match("%.png$") then table.insert(frames, image(path .. "/" .. file)) end end
  return frames
end

function Assets.load()
  Assets.sets.original = buildSet("assets/original/celium-sprites.png")
  Assets.sets.curated = buildSet("assets/curated/tiny-dungeon.png", curatedTiles)
  local g = Assets.gothic
  g.tiles, g.props, g.column = image("assets/gothic/environment/tileset.png"), image("assets/gothic/environment/props.png"), image("assets/gothic/environment/column.png")
  g.player = {
    idle = sequence("assets/gothic/player/idle"), run = sequence("assets/gothic/player/run"),
    jump = sequence("assets/gothic/player/jump"), attack = sequence("assets/gothic/player/attack"),
  }
  g.bosses = {
    mire_priest = { idle = sequence("assets/gothic/bosses/mire/idle") },
    lord_celium = {
      idle = sequence("assets/gothic/bosses/celium/idle"),
      attack = sequence("assets/gothic/bosses/celium/attack"),
    },
  }
  g.ghoul = image("assets/gothic/enemies/ghoul.png")
  g.wizard = image("assets/gothic/enemies/wizard.png")
  g.angel = image("assets/gothic/enemies/angel.png")
  g.darkBolt = image("assets/gothic/magic/dark-bolt.png")
  g.darkBoltQuads = {}
  for i = 0, 7 do g.darkBoltQuads[i + 1] = love.graphics.newQuad(i * 88, 0, 88, 88, g.darkBolt:getDimensions()) end
  g.platformQuad = love.graphics.newQuad(16, 160, 48, 32, g.tiles:getDimensions())
  g.propsQuads = {
    window = love.graphics.newQuad(0, 0, 176, 192, g.props:getDimensions()),
    column = love.graphics.newQuad(176, 0, 128, 192, g.props:getDimensions()),
    altar = love.graphics.newQuad(304, 0, 176, 192, g.props:getDimensions()),
  }
  Assets.current = "gothic"
end

function Assets.toggle()
  Assets.current = Assets.current == "gothic" and "original" or "gothic"
  return Assets.current
end

local function drawFallback(name, x, y, scale, flash)
  local set = Assets.sets[Assets.current] or Assets.sets.original
  if not set or not set.quads[name] then return false end
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(set.image, set.quads[name], math.floor(x), math.floor(y), 0, scale or 2, scale or 2, 8, 8)
  if flash and flash > 0 then love.graphics.setColor(1, .5, .5, .7); love.graphics.circle("line", x, y, 20) end
  return true
end

function Assets.drawPlayer(player)
  if Assets.current ~= "gothic" then return drawFallback("player", player.x, player.y, 2.2, player.flash) end
  local state = "idle"
  if player.meleeTimer > .08 then state = "attack"
  elseif not player.onGround then state = "jump"
  elseif math.abs(player.vx or 0) > 10 then state = "run" end
  local frames = Assets.gothic.player[state]
  local rate = state == "attack" and 14 or 9
  local frame = frames[(math.floor(player.animTime * rate) % #frames) + 1]
  local w, h = frame:getDimensions()
  love.graphics.setColor(player.flash > 0 and 1 or .82, player.flash > 0 and .55 or .82, player.flash > 0 and .55 or .9)
  love.graphics.draw(frame, math.floor(player.x), math.floor(player.y + player.halfHeight), 0, 1.35 * player.facing, 1.35, w / 2, h - 5)
  return true
end

function Assets.drawCompanion(companion)
  if Assets.current ~= "gothic" then return drawFallback("sillius", companion.x, companion.y, 2.2) end
  local state = math.abs(companion.vx or 0) > 10 and "run" or "idle"
  local frames = Assets.gothic.player[state]
  local frame = frames[(math.floor(companion.animTime * 9) % #frames) + 1]
  local w, h = frame:getDimensions()
  love.graphics.setColor(.42, .78, 1)
  love.graphics.draw(frame, math.floor(companion.x), math.floor(companion.y + 25), 0, 1.35 * companion.facing, 1.35, w / 2, h - 5)
  return true
end

function Assets.drawBoss(boss)
  if Assets.current ~= "gothic" then
    return drawFallback(boss.kind, boss.x, boss.y, boss.kind == "lord_celium" and 2.7 or 2.3, boss.flash)
  end
  local animation = "idle"
  if boss.kind == "lord_celium" and (boss.chargeWindup > 0 or boss.attackTimer > boss.baseCooldown - .3) then animation = "attack" end
  local frames = Assets.gothic.bosses[boss.kind][animation]
  local frame = frames[(math.floor(boss.animTime * (animation == "attack" and 11 or 7)) % #frames) + 1]
  local w, h = frame:getDimensions()
  if boss.flash > 0 then love.graphics.setColor(1, .55, .55)
  elseif boss.kind == "lord_celium" then love.graphics.setColor(1, .3, .4)
  else love.graphics.setColor(.5, .9, .55) end
  local scale = boss.kind == "lord_celium" and 1.55 or 1.35
  love.graphics.draw(frame, math.floor(boss.x), math.floor(boss.y + boss.halfHeight), 0, scale * boss.facing, scale, w / 2, h - 5)
  return true
end

function Assets.draw(name, x, y, scale, flash, facing)
  if Assets.current ~= "gothic" then return drawFallback(name, x, y, scale, flash) end
  local actor
  if name == "shadow_thrall" or name == "cursed_hound" or name == "shielded_knight" then actor = Assets.gothic.ghoul
  elseif name == "ash_cultist" or name == "rift_witch" then actor = Assets.gothic.wizard
  elseif name == "winged_curse" then actor = Assets.gothic.angel
  elseif name == "villager" then actor = Assets.gothic.player.idle[1] end
  if actor then
    local w, h = actor:getDimensions()
    local r, g, b = 1, 1, 1
    if name == "lord_celium" then r, g, b = 1, .28, .38
    elseif name == "mire_priest" then r, g, b = .48, .9, .5
    elseif name == "sillius" then r, g, b = .45, .8, 1
    elseif name == "villager" then r, g, b = .72, .58, .5 end
    if flash and flash > 0 then r, g, b = 1, .5, .5 end
    love.graphics.setColor(r, g, b)
    love.graphics.draw(actor, math.floor(x), math.floor(y + 16), 0, (scale or 1.2) * (facing or -1), scale or 1.2, w / 2, h - 5)
    return true
  end
  return drawFallback(name, x, y, scale, flash)
end

function Assets.drawProjectile(projectile)
  if Assets.current ~= "gothic" or projectile.owner == "ally" then return false end
  local index = (math.floor((4 - projectile.life) * 14) % #Assets.gothic.darkBoltQuads) + 1
  local angle = math.atan2(projectile.dy, projectile.dx)
  love.graphics.setColor(projectile.owner == "player" and .65 or 1, .55, 1)
  love.graphics.draw(Assets.gothic.darkBolt, Assets.gothic.darkBoltQuads[index], projectile.x, projectile.y, angle, .55, .55, 44, 44)
  return true
end

function Assets.drawBackdrop(level)
  local theme = level.theme or "church"
  local moon = theme == "mountain" or theme == "summit"
  local width, height = Config.world.width, Config.world.height
  love.graphics.setColor(level.background)
  love.graphics.rectangle("fill", 0, 0, width, height)
  love.graphics.setColor(moon and { .58, .12, .18, .32 } or { .38, .42, .62, .22 })
  love.graphics.circle("fill", 1030, 145, moon and 82 or 58)
  love.graphics.setColor(.045, .035, .07, .88)
  love.graphics.polygon("fill", 0, 420, 170, 250, 300, 420, 470, 210, 660, 420,
    850, 270, 1040, 420, 1180, 230, width, 380, width, 640, 0, 640)
  love.graphics.setColor(.08, .06, .11, .8)
  for x = 40, 1240, 130 do love.graphics.rectangle("fill", x, 315 + (x % 3) * 18, 18, 325); love.graphics.polygon("fill", x - 20, 340, x + 9, 270, x + 38, 340) end
  love.graphics.setColor(.25, .22, .35, .08)
  for y = 390, 590, 55 do love.graphics.rectangle("fill", 0, y, width, 18) end
end

function Assets.drawPlatforms(level)
  for _, platform in ipairs(level.platforms or {}) do
    love.graphics.setColor(platform.moving and .25 or .17, .1, platform.moving and .3 or .22)
    love.graphics.rectangle("fill", platform.x, platform.y, platform.w, platform.h)
    local x = platform.x
    while x < platform.x + platform.w do
      love.graphics.setColor(1, 1, 1)
      love.graphics.draw(Assets.gothic.tiles, Assets.gothic.platformQuad, x, platform.y - 6, 0, 1, 1)
      x = x + 48
    end
    if platform.moving then
      love.graphics.setColor(.55, .45, .68, .65)
      love.graphics.line(platform.x + 12, platform.y + platform.h, platform.x + 12, platform.y + platform.h + 22)
      love.graphics.line(platform.x + platform.w - 12, platform.y + platform.h, platform.x + platform.w - 12, platform.y + platform.h + 22)
    end
  end
  for _, wall in ipairs(level.walls or {}) do
    love.graphics.setColor(.12, .075, .16)
    love.graphics.rectangle("fill", wall.x, wall.y, wall.w, wall.h)
    love.graphics.setColor(.5, .42, .6, .5)
    love.graphics.rectangle("line", wall.x + 2, wall.y, wall.w - 4, wall.h)
  end
  for _, prop in ipairs(level.props or {}) do
    local quad = Assets.gothic.propsQuads[prop[1]]
    if quad then
      local _, _, w, h = quad:getViewport()
      love.graphics.setColor(1, 1, 1, .88)
      love.graphics.draw(Assets.gothic.props, quad, prop[2], prop[3], 0, .8, .8, w / 2, h)
    end
  end
end

return Assets
