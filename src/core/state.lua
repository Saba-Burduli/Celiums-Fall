local Camera = require("src.core.camera")
local Actions = require("src.core.actions")
local GameSession = require("src.core.game_session")
local Input = require("src.core.input")
local Player = require("src.entities.player")
local Item = require("src.entities.item")
local AI = require("src.systems.ai")
local Combat = require("src.systems.combat")
local WorldFlow = require("src.systems.world_flow")
local Hud = require("src.ui.hud")
local WorldRenderer = require("src.ui.world_renderer")
local Dialogue = require("src.ui.dialogue")
local Cinematic = require("src.ui.cinematic")
local Menu = require("src.ui.menu")
local Audio = require("src.core.audio")
local Save = require("src.core.save")
local Settings = require("src.core.settings")
local Assets = require("src.core.assets")
local Companion = require("src.entities.companion")
local Platforms = require("src.systems.platforms")

local State = { mode = "title", pauseSelection = 1 }

function State.load()
  Settings.load(); Audio.load(); Assets.load()
  State.mode, State.hasSave = "title", Save.exists()
end

function State.update(dt)
  if State.mode ~= "playing" then return end
  local game, p = State.game, State.game.player
  if game.cinematic then Cinematic.update(game, dt); return end
  local riders = { p }
  for _, enemy in ipairs(game.enemies) do if not enemy.dead then table.insert(riders, enemy) end end
  if game.boss and not game.boss.dead then table.insert(riders, game.boss) end
  Platforms.update(game.physics, dt, riders)
  Player.update(p, game.physics, dt); Camera.update(dt)
  game.meleeFlash = math.max(0, game.meleeFlash - dt)
  game.messageTimer = math.max(0, game.messageTimer - dt)
  if game.messageTimer == 0 then game.message = nil end
  for _, item in ipairs(game.items) do Item.update(item, dt) end
  AI.update(game.enemies, game.boss, p, game.projectiles, game.physics, dt)
  Companion.update(game.companion, game, dt)
  Combat.update(game, dt)
  local outcome = WorldFlow.update(game)
  if outcome then
    State.mode = outcome
    if outcome == "victory" then State.hasSave = false end
  end
end

function State.draw()
  Camera.beginDraw()
  if State.mode == "title" or State.mode == "dead" or State.mode == "victory" then
    Menu.draw(State.mode); Camera.endDraw(); return
  end
  WorldRenderer.draw(State.game)
  Hud.draw(State.game)
  Dialogue.draw(State.game.message)
  Cinematic.draw(State.game)
  if State.mode == "paused" then Menu.pause(Settings, State.pauseSelection) end
  Camera.endDraw()
end

local function startGame(saved)
  if not saved then Save.clear() end
  State.game = GameSession.new(saved, Audio)
  State.hasSave = false
  State.mode = "playing"
end

local function changePauseSelection(amount)
  State.pauseSelection = ((State.pauseSelection - 1 + amount) % 4) + 1
end

local function adjustPauseSetting(amount)
  if State.pauseSelection == 2 then Settings.adjustMaster(amount) end
  if State.pauseSelection == 3 then Settings.adjustSfx(amount) end
end

local function dispatch(action)
  if not action then return end
  if action == "new_game" then startGame(nil); return end
  if action == "continue" then
    if Save.exists() then startGame(Save.read()) end
    return
  end
  if action == "cinematic_advance" then Cinematic.advance(State.game); return end
  if action == "pause_toggle" then
    State.mode = State.mode == "playing" and "paused" or "playing"
    if State.mode == "paused" then State.pauseSelection = 1 end
    return
  end
  if action == "pause_resume" then State.mode = "playing"; return end
  if action == "menu_up" then changePauseSelection(-1); return end
  if action == "menu_down" then changePauseSelection(1); return end
  if action == "menu_decrease" then adjustPauseSetting(-.1); return end
  if action == "menu_increase" then adjustPauseSetting(.1); return end
  if action == "menu_confirm" then
    if State.pauseSelection == 1 then State.mode = "playing" end
    if State.pauseSelection == 4 then Settings.toggleMute() end
    return
  end
  if action == "volume_cycle" then Settings.cycleVolume(); return end
  if action == "mute_toggle" then Settings.toggleMute(); return end

  local game = State.game
  if action == "jump" then
    if Input.down() then Player.dropThrough(game.player) else Player.jump(game.player) end
  elseif action == "dash" then
    if Player.dash(game.player) then game.audio.play("dash") end
  elseif action == "melee" then
    Combat.melee(game)
  elseif action == "magic" then
    Combat.magic(game)
  elseif action == "chain_lightning" then
    Combat.chainLightning(game)
  elseif action == "interact" then
    WorldFlow.interact(game)
  end
end

function State.keypressed(key)
  dispatch(Actions.key(key, State.mode, State.game and State.game.cinematic))
end

function State.gamepadpressed(_, button)
  dispatch(Actions.gamepad(button, State.mode, State.game and State.game.cinematic))
end

function State.mousepressed(_, _, button)
  dispatch(Actions.mouse(button, State.mode))
end

return State
