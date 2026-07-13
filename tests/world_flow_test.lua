local Helper = require("tests.test_helper")
local WorldFlow = require("src.systems.world_flow")

Helper.test("world objectives reflect companion progression", function()
  local game = { area = "forest_depths", companion = { status = "unmet" }, quest = { status = "start" } }
  Helper.equal(WorldFlow.currentObjective(game), "Speak with the stranded faction occultist.")
  game.companion.status = "active"
  Helper.equal(WorldFlow.currentObjective(game), "Sillius: eliminate the faction patrol.")
  game.companion.status = "ready"
  Helper.equal(WorldFlow.currentObjective(game), "Return to Sillius in the Forest Depths.")
end)

Helper.test("world flow reports player death without owning application state", function()
  local game = {
    area = "forest",
    player = { hp = 0 },
    companion = { status = "unmet" },
    enemies = {},
    boss = nil,
  }
  Helper.equal(WorldFlow.update(game), "dead")
end)

Helper.test("world flow marks a cleared Sillius patrol ready", function()
  local game = {
    area = "forest_depths",
    player = { hp = 120, x = 100, y = 100 },
    companion = { status = "active", x = 400, y = 400 },
    enemies = {},
    items = {},
    boss = nil,
    level = {},
    quest = { status = "start" },
  }
  WorldFlow.update(game)
  Helper.equal(game.companion.status, "ready")
end)
