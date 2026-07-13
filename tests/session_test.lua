local GameSession = require("src.core.game_session")
local Helper = require("tests.test_helper")

Helper.test("session restoration preserves version-one player progress", function()
  local game = {
    player = { hp = 1, maxHp = 1, mana = 1, maxMana = 1, speed = 1, magicDamage = 1,
      dashCooldown = 1, stones = {} },
    quest = { status = "start" },
    companion = { status = "unmet" },
    mireDead = false,
  }
  GameSession.restore(game, {
    hp = "90", maxHp = "150", mana = "70", maxMana = "130", speed = "215",
    magicDamage = "37", dashCooldown = ".9", questReward = "true", chainUnlocked = "true",
    mireDead = "true", quest = "done", sillius = "allied", stones = "ash,moon",
  })
  Helper.equal(game.player.hp, 90)
  Helper.equal(game.player.maxHp, 150)
  Helper.equal(game.player.chainUnlocked, true)
  Helper.equal(game.player.stones.ash, true)
  Helper.equal(game.player.stones.moon, true)
  Helper.equal(game.quest.status, "done")
  Helper.equal(game.companion.status, "allied")
  Helper.equal(game.mireDead, true)
end)

Helper.test("session creation safely falls back from an unknown saved area", function()
  local previousLove = love
  love = {
    graphics = { newFont = function() return {} end },
    math = { random = math.random },
  }
  local game = GameSession.new({ area = "removed_room" })
  Helper.equal(game.area, "forest")
  Helper.equal(game.level.name, "Cursed Forest")
  love = previousLove
end)
