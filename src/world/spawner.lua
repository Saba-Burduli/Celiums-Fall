local Enemy = require("src.entities.enemy")
local Boss = require("src.entities.boss")
local Item = require("src.entities.item")
local Spawner = {}

function Spawner.forArea(area, flags)
  local enemies, boss, items = {}, nil, {}
  if area == "forest" then
    enemies = { Enemy.new("shadow_thrall", 420, 220), Enemy.new("cursed_hound", 650, 500), Enemy.new("ash_cultist", 900, 260), Enemy.new("shadow_thrall", 1040, 540) }
    if not flags.blood then table.insert(items, Item.new("blood", 560, 350)) end
    if not flags.questMoon then table.insert(items, Item.new("moon", 980, 150, true)) end
  elseif area == "forest_depths" then
    enemies = { Enemy.new("shielded_knight", 520, 250), Enemy.new("rift_witch", 790, 470), Enemy.new("winged_curse", 1020, 210) }
  elseif area == "shrine" then
    enemies = { Enemy.new("shadow_thrall", 350, 190), Enemy.new("ash_cultist", 400, 540) }
    if not flags.mireDead then boss = Boss.new("mire_priest", 870, 360) end
    if not flags.moon then table.insert(items, Item.new("moon", 540, 145)) end
    if not flags.ash then table.insert(items, Item.new("ash", 690, 590)) end
  elseif area == "shrine_crypt" then
    enemies = { Enemy.new("shielded_knight", 430, 200), Enemy.new("rift_witch", 700, 500), Enemy.new("ash_cultist", 980, 250) }
  elseif area == "mountain_path" then
    enemies = { Enemy.new("winged_curse", 380, 190), Enemy.new("winged_curse", 620, 540), Enemy.new("shielded_knight", 850, 350), Enemy.new("rift_witch", 1070, 180) }
  elseif area == "mountain" then
    enemies = { Enemy.new("cursed_hound", 360, 180), Enemy.new("ash_cultist", 450, 560) }
    boss = Boss.new("lord_celium", 980, 360)
    if not flags.wind then table.insert(items, Item.new("wind", 610, 170)) end
  end
  return enemies, boss, items
end

return Spawner
