local Boss = require("src.entities.boss")
local Helper = require("tests.test_helper")
local Platforms = require("src.systems.platforms")

local function level()
  return Platforms.create({ platforms = { { x = 0, y = 632, w = 1280, h = 88 } } })
end

Helper.test("boss updates return summon requests without constructing enemies", function()
  local boss = Boss.new("lord_celium", 980, 585)
  boss.attackTimer, boss.summonTimer, boss.chargeTimer = 10, 0, 10
  local summons = Boss.update(boss, { x = 200, y = 600 }, {}, level(), .016)
  Helper.equal(#summons, 1)
  Helper.equal(summons[1].kind, "shadow_thrall")

  boss.phase, boss.summonTimer = 2, 0
  summons = Boss.update(boss, { x = 200, y = 600 }, {}, level(), .016)
  Helper.equal(#summons, 2)
  Helper.equal(summons[2].kind, "cursed_hound")
end)
