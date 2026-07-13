local Encounters = require("src.data.encounters")
local Helper = require("tests.test_helper")
local Levels = require("src.world.levels")
local Validator = require("src.world.validator")

Helper.test("every level and encounter definition is valid", function()
  local valid, err = Validator.all(Levels)
  assert(valid, err)
end)

Helper.test("the world contains nine paired level and encounter definitions", function()
  local levelCount, encounterCount = 0, 0
  for _ in pairs(Levels) do levelCount = levelCount + 1 end
  for _ in pairs(Encounters) do encounterCount = encounterCount + 1 end
  Helper.equal(levelCount, 9)
  Helper.equal(encounterCount, levelCount)
end)

Helper.test("room validation rejects a broken progression link", function()
  local broken = {}
  for key, value in pairs(Levels) do broken[key] = value end
  broken.forest = {}
  for key, value in pairs(Levels.forest) do broken.forest[key] = value end
  broken.forest.next = "missing_area"
  local valid, err = Validator.area("forest", broken)
  Helper.equal(valid, false)
  assert(err:find("next area does not exist", 1, true), err)
end)

Helper.test("declarative encounter flags preserve conditional spawns", function()
  local previousLove = love
  love = { math = { random = math.random } }
  package.loaded["src.world.spawner"] = nil
  local Spawner = require("src.world.spawner")
  local _, forestBoss, forestItems = Spawner.forArea("forest", { blood = true, questMoon = true })
  Helper.equal(forestBoss, nil)
  Helper.equal(#forestItems, 0)
  local _, shrineBoss = Spawner.forArea("shrine", { mireDead = true })
  Helper.equal(shrineBoss, nil)
  local _, mountainBoss, mountainItems = Spawner.forArea("mountain", { wind = true })
  Helper.equal(mountainBoss.kind, "lord_celium")
  Helper.equal(#mountainItems, 0)
  love = previousLove
end)
