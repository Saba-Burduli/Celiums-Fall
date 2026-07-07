local Camera = require("src.core.camera")
local Player = require("src.entities.player")
local Projectile = require("src.entities.projectile")
local Item = require("src.entities.item")
local Levels = require("src.world.levels")
local Spawner = require("src.world.spawner")
local AI = require("src.systems.ai")
local Combat = require("src.systems.combat")
local Collision = require("src.systems.collision")
local Quests = require("src.systems.quests")
local Progression = require("src.systems.progression")
local Hud = require("src.ui.hud")
local Dialogue = require("src.ui.dialogue")
local Menu = require("src.ui.menu")

local State = { mode = "title" }

local function notify(game, text)
  game.message, game.messageTimer = text, 3.2
end

local function enterArea(game, name)
  game.area, game.level = name, Levels[name]
  local flags = {
    blood = game.player.stones.blood, moon = game.player.stones.moon, ash = game.player.stones.ash, wind = game.player.stones.wind,
    questMoon = game.quest.status == "return" or game.quest.status == "done", mireDead = game.mireDead,
  }
  game.enemies, game.boss, game.items = Spawner.forArea(name, flags)
  game.projectiles = {}
  game.player.x, game.player.y = game.level.entry[1], game.level.entry[2]
  notify(game, game.level.name)
end

local function newGame()
  local game = {
    player = Player.new(95, 360), projectiles = {}, particles = {}, quest = Quests.new(), mireDead = false,
    message = nil, messageTimer = 0, meleeFlash = 0, prompt = nil,
    questObjective = "",
    fonts = { small = love.graphics.newFont(15), normal = love.graphics.newFont(18) },
  }
  game.questObjective = Quests.objective(game.quest)
  enterArea(game, "forest")
  return game
end

function State.load() State.mode = "title" end

local function interact(game)
  local p = game.player
  if game.area == "forest" and Collision.near(p, { x = 175, y = 360 }, 65) then
    notify(game, Quests.interact(game.quest, p)); return
  end
  for _, item in ipairs(game.items) do
    if not item.collected and Collision.near(p, item, 45) then
      if item.questItem then
        if Quests.takeMoonstone(game.quest) then item.collected = true; notify(game, "Lost Moonstone recovered.")
        else notify(game, "A pale stone. Someone may be searching for it.") end
      else
        local text = Progression.collect(p, item)
        if text then notify(game, text) end
      end
      return
    end
  end
end

local function updatePrompt(game)
  game.prompt = nil
  if game.area == "forest" and Collision.near(game.player, { x = 175, y = 360 }, 65) then game.prompt = "Speak with Old Villager" end
  for _, item in ipairs(game.items) do
    if not item.collected and Collision.near(game.player, item, 45) then game.prompt = item.questItem and "Take lost moonstone" or "Absorb stone" end
  end
end

local function transition(game)
  local exit = game.level.exit
  if not exit or not Collision.near(game.player, exit, 45) then return end
  if game.area == "forest" then enterArea(game, "shrine")
  elseif game.area == "shrine" then
    if game.mireDead then enterArea(game, "mountain") else game.player.x = 1170; notify(game, "The Mire Priest's ward seals the mountain path.") end
  end
end

function State.update(dt)
  if State.mode ~= "playing" then return end
  local game, p = State.game, State.game.player
  Player.update(p, dt); Camera.update(dt)
  game.meleeFlash = math.max(0, game.meleeFlash - dt)
  game.messageTimer = math.max(0, game.messageTimer - dt)
  if game.messageTimer == 0 then game.message = nil end
  for _, item in ipairs(game.items) do Item.update(item, dt) end
  AI.update(game.enemies, game.boss, p, game.projectiles, dt)
  Combat.update(game, dt)
  if game.boss and game.boss.dead then
    if game.boss.kind == "mire_priest" and not game.mireDead then game.mireDead = true; notify(game, "Mire Priest slain — the mountain ward is broken.") end
    if game.boss.kind == "lord_celium" then State.mode = "victory"; return end
  end
  if p.hp <= 0 then State.mode = "dead"; return end
  updatePrompt(game); transition(game)
  game.questObjective = Quests.objective(game.quest)
end

local function drawWorld(game)
  love.graphics.clear(game.level.background)
  love.graphics.setColor(game.level.accent)
  for _, tree in ipairs(game.level.trees) do
    love.graphics.circle("fill", tree[1], tree[2], tree[3]); love.graphics.setColor(game.level.accent[1] * .6, game.level.accent[2] * .6, game.level.accent[3] * .6)
    love.graphics.rectangle("fill", tree[1] - 6, tree[2], 12, tree[3] + 18); love.graphics.setColor(game.level.accent)
  end
  love.graphics.setColor(.22, .2, .25, .5); love.graphics.rectangle("line", 24, 50, 1232, 646)
  if game.level.exit then
    local open = game.area ~= "shrine" or game.mireDead
    love.graphics.setColor(open and { .35, .42, .58, .7 } or { .45, .08, .16, .8 })
    love.graphics.rectangle("fill", 1215, 305, 35, 110)
    love.graphics.push(); love.graphics.translate(1202, 425); love.graphics.rotate(-math.pi / 2)
    love.graphics.setColor(.7, .68, .76); love.graphics.print(game.level.exit.label, 0, 0); love.graphics.pop()
  end
  if game.area == "forest" then
    love.graphics.setColor(.48, .4, .32); love.graphics.circle("fill", 175, 360, 17)
    love.graphics.setColor(.7, .65, .6); love.graphics.print("Old Villager", 128, 388)
  end
  for _, item in ipairs(game.items) do Item.draw(item) end
  for _, shot in ipairs(game.projectiles) do Projectile.draw(shot) end
  for _, enemy in ipairs(game.enemies) do if not enemy.dead then require("src.entities.enemy").draw(enemy) end end
  if game.boss and not game.boss.dead then require("src.entities.boss").draw(game.boss) end
  Player.draw(game.player)
  if game.meleeFlash > 0 then
    local p = game.player; love.graphics.setColor(.8, .65, .95, .5)
    love.graphics.arc("line", "open", p.x, p.y, 45, math.atan2(p.aimY, p.aimX) - .8, math.atan2(p.aimY, p.aimX) + .8)
  end
  for _, q in ipairs(game.particles) do love.graphics.setColor(q.color[1], q.color[2], q.color[3], q.life / .35); love.graphics.circle("fill", q.x, q.y, 3) end
  love.graphics.setColor(.12, .1, .16, .13)
  for i = 1, 16 do love.graphics.circle("fill", (i * 97 + love.timer.getTime() * 7) % 1280, (i * 173) % 720, 45 + i % 3 * 20) end
end

function State.draw()
  if State.mode == "title" or State.mode == "dead" or State.mode == "victory" then Menu.draw(State.mode); return end
  Camera.beginDraw()
  drawWorld(State.game)
  Hud.draw(State.game)
  Dialogue.draw(State.game.message)
  if State.mode == "paused" then Menu.pause() end
  Camera.endDraw()
end

function State.keypressed(key)
  if key == "return" and (State.mode == "title" or State.mode == "dead" or State.mode == "victory") then State.game = newGame(); State.mode = "playing"; return end
  if key == "escape" and (State.mode == "playing" or State.mode == "paused") then State.mode = State.mode == "playing" and "paused" or "playing"; return end
  if State.mode ~= "playing" then return end
  if key == "space" then Player.dash(State.game.player) end
  if key == "j" then Combat.melee(State.game) end
  if key == "k" then Combat.magic(State.game) end
  if key == "e" then interact(State.game) end
end

function State.mousepressed(_, _, button)
  if State.mode ~= "playing" then return end
  if button == 1 then Combat.melee(State.game) end
  if button == 2 then Combat.magic(State.game) end
end

return State
