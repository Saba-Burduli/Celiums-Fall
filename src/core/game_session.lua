local Cinematic = require("src.ui.cinematic")
local Companion = require("src.entities.companion")
local Fonts = require("src.ui.fonts")
local Levels = require("src.world.levels")
local Platforms = require("src.systems.platforms")
local Player = require("src.entities.player")
local Quests = require("src.systems.quests")
local Spawner = require("src.world.spawner")
local Validator = require("src.world.validator")
local GameSession = {}

function GameSession.notify(game, text)
  game.message = text
  game.messageTimer = 3.2
end

function GameSession.livingEnemyCount(game)
  local count = 0
  for _, enemy in ipairs(game.enemies) do
    if not enemy.dead then count = count + 1 end
  end
  return count
end

local function encounterFlags(game)
  local player = game.player
  return {
    blood = player.stones.blood,
    moon = player.stones.moon,
    ash = player.stones.ash,
    wind = player.stones.wind,
    questMoon = game.quest.status == "return" or game.quest.status == "done",
    mireDead = game.mireDead,
  }
end

function GameSession.enterArea(game, name)
  local valid, validationError = Validator.area(name, Levels)
  assert(valid, validationError)
  game.area = name
  game.level = Levels[name]
  game.physics = Platforms.create(game.level)
  game.enemies, game.boss, game.items = Spawner.forArea(name, encounterFlags(game))
  game.projectiles = {}
  game.player.x = game.level.entry[1]
  game.player.y = game.level.entry[2]
  if game.companion.status == "allied" then
    game.companion.x = game.player.x - 35
    game.companion.y = game.player.y
  end
  GameSession.notify(game, game.level.name)
  Cinematic.start(game, name)
end

function GameSession.restore(game, saved)
  if not saved then return end
  local player = game.player
  player.hp = tonumber(saved.hp) or player.hp
  player.maxHp = tonumber(saved.maxHp) or player.maxHp
  player.mana = tonumber(saved.mana) or player.mana
  player.maxMana = tonumber(saved.maxMana) or player.maxMana
  player.speed = tonumber(saved.speed) or player.speed
  player.magicDamage = tonumber(saved.magicDamage) or player.magicDamage
  player.dashCooldown = tonumber(saved.dashCooldown) or player.dashCooldown
  player.questReward = saved.questReward == "true"
  player.chainUnlocked = saved.chainUnlocked == "true"
  game.mireDead = saved.mireDead == "true"
  game.quest.status = saved.quest or game.quest.status
  game.companion.status = saved.sillius or game.companion.status
  for kind in (saved.stones or ""):gmatch("[^,]+") do player.stones[kind] = true end
end

function GameSession.new(saved, audio)
  local game = {
    player = Player.new(95, 360),
    projectiles = {},
    particles = {},
    lightning = {},
    quest = Quests.new(),
    companion = Companion.new(),
    mireDead = false,
    message = nil,
    messageTimer = 0,
    meleeFlash = 0,
    prompt = nil,
    questObjective = "",
    fonts = {
      small = Fonts.get(16),
      normal = Fonts.get(20),
    },
    audio = audio,
  }
  GameSession.restore(game, saved)
  game.questObjective = Quests.objective(game.quest)
  local area = saved and saved.area or "forest"
  if not Levels[area] then area = "forest" end
  GameSession.enterArea(game, area)
  return game
end

return GameSession
