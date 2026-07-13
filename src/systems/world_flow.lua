local Collision = require("src.systems.collision")
local Companion = require("src.entities.companion")
local GameSession = require("src.core.game_session")
local Progression = require("src.systems.progression")
local Quests = require("src.systems.quests")
local Save = require("src.core.save")
local WorldFlow = {}

function WorldFlow.currentObjective(game)
  if game.companion.status == "active" then return "Sillius: eliminate the faction patrol." end
  if game.companion.status == "ready" then return "Return to Sillius in the Forest Depths." end
  if game.companion.status == "unmet" and game.area == "forest_depths" then
    return "Speak with the stranded faction occultist."
  end
  return Quests.objective(game.quest)
end

function WorldFlow.interact(game)
  local player = game.player
  if Companion.present(game.companion, game.area) and Collision.near(player, game.companion, 65) then
    local companion = game.companion
    if companion.status == "unmet" then
      companion.status = "active"
      GameSession.notify(game,
        "Sillius: Still saving strangers, Aren? Kill this patrol and I'll make myself useful.")
    elseif companion.status == "active" and GameSession.livingEnemyCount(game) > 0 then
      GameSession.notify(game, "Sillius: The sarcastic reunion can continue after the screaming stops.")
    elseif companion.status == "active" or companion.status == "ready" then
      companion.status = "allied"
      player.chainUnlocked = true
      GameSession.notify(game, "Sillius joins you. Chain Lightning unlocked [L]. Try not to look impressed.")
      game.audio.play("stone")
    else
      GameSession.notify(game, "Sillius: Lead on. I promise to criticize your technique quietly.")
    end
    Save.write(game)
    return
  end

  if game.area == "forest" and Collision.near(player, { x = 175, y = 600 }, 65) then
    GameSession.notify(game, Quests.interact(game.quest, player))
    Save.write(game)
    return
  end

  for _, item in ipairs(game.items) do
    if not item.collected and Collision.near(player, item, 45) then
      if item.questItem then
        if Quests.takeMoonstone(game.quest) then
          item.collected = true
          GameSession.notify(game, "Lost Moonstone recovered.")
          game.audio.play("stone")
        else
          GameSession.notify(game, "A pale stone. Someone may be searching for it.")
        end
      else
        local text = Progression.collect(player, item)
        if text then
          GameSession.notify(game, text)
          game.audio.play("stone")
        end
      end
      Save.write(game)
      return
    end
  end
end

function WorldFlow.updatePrompt(game)
  game.prompt = nil
  if Companion.present(game.companion, game.area)
      and Collision.near(game.player, game.companion, 65) then
    game.prompt = game.companion.status == "allied"
      and "Speak with Sillius" or "Ask Sillius about the patrol"
  end
  if game.area == "forest" and Collision.near(game.player, { x = 175, y = 600 }, 65) then
    game.prompt = "Speak with Old Villager"
  end
  for _, item in ipairs(game.items) do
    if not item.collected and Collision.near(game.player, item, 45) then
      game.prompt = item.questItem and "Take lost moonstone" or "Absorb stone"
    end
  end
end

local function transition(game)
  local exit = game.level.exit
  if not exit or not Collision.near(game.player, exit, 45) then return end
  if game.area == "forest_depths" and game.companion.status == "active"
      and GameSession.livingEnemyCount(game) == 0 then
    game.companion.status = "ready"
  end
  if game.area == "forest_depths" and game.companion.status ~= "allied" then
    game.player.x = 1170
    GameSession.notify(game, "Sillius: Leaving already? The patrol still owns this road.")
    return
  end
  if game.area == "shrine" and not game.mireDead then
    game.player.x = 1170
    GameSession.notify(game, "The Mire Priest's ward seals the crypt.")
    return
  end
  if game.level.next then
    GameSession.enterArea(game, game.level.next)
    Save.write(game)
  end
end

local function resolveBoss(game)
  if not game.boss then return end
  if game.boss.dead then
    if game.boss.kind == "mire_priest" and not game.mireDead then
      game.mireDead = true
      GameSession.notify(game, "Mire Priest slain — the mountain ward is broken.")
      game.audio.play("boss")
      Save.write(game)
    elseif game.boss.kind == "lord_celium" then
      Save.clear()
      game.audio.play("victory")
      return "victory"
    end
  end
  if game.boss.phaseChanged then
    game.boss.phaseChanged = false
    GameSession.notify(game, "Lord Celium tears open the veil — his final phase begins.")
    game.audio.play("boss")
  end
end

function WorldFlow.update(game)
  if game.companion.status == "active" and game.area == "forest_depths"
      and GameSession.livingEnemyCount(game) == 0 then
    game.companion.status = "ready"
  end
  local outcome = resolveBoss(game)
  if outcome then return outcome end
  if game.player.hp <= 0 then return "dead" end
  WorldFlow.updatePrompt(game)
  transition(game)
  game.questObjective = WorldFlow.currentObjective(game)
end

return WorldFlow
