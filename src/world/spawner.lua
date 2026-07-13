local Enemy = require("src.entities.enemy")
local Boss = require("src.entities.boss")
local Item = require("src.entities.item")
local Spawner = {}

function Spawner.forArea(area, flags)
  local enemies, boss, items = {}, nil, {}
  if area == "forest" then
    enemies = { Enemy.new("shadow_thrall", 420, 595), Enemy.new("cursed_hound", 610, 430), Enemy.new("ash_cultist", 890, 500), Enemy.new("shadow_thrall", 1080, 595) }
    if not flags.blood then table.insert(items, Item.new("blood", 560, 410)) end
    if not flags.questMoon then table.insert(items, Item.new("moon", 930, 480, true)) end
  elseif area == "forest_depths" then
    enemies = { Enemy.new("shielded_knight", 520, 385), Enemy.new("rift_witch", 820, 460), Enemy.new("winged_curse", 1030, 300) }
  elseif area == "forest_ruins" then
    enemies = { Enemy.new("cursed_hound", 270, 470), Enemy.new("ash_cultist", 500, 380), Enemy.new("shadow_thrall", 820, 450), Enemy.new("winged_curse", 1080, 315) }
  elseif area == "shrine" then
    enemies = { Enemy.new("shadow_thrall", 350, 595), Enemy.new("ash_cultist", 540, 400) }
    if not flags.mireDead then boss = Boss.new("mire_priest", 870, 590) end
    if not flags.moon then table.insert(items, Item.new("moon", 540, 390)) end
    if not flags.ash then table.insert(items, Item.new("ash", 810, 475)) end
  elseif area == "shrine_crypt" then
    enemies = { Enemy.new("shielded_knight", 250, 450), Enemy.new("rift_witch", 760, 390), Enemy.new("ash_cultist", 1040, 470) }
  elseif area == "ossuary" then
    enemies = { Enemy.new("shadow_thrall", 260, 465), Enemy.new("rift_witch", 500, 370), Enemy.new("cursed_hound", 800, 455), Enemy.new("ash_cultist", 1080, 370) }
  elseif area == "mountain_path" then
    enemies = { Enemy.new("winged_curse", 380, 280), Enemy.new("winged_curse", 690, 250), Enemy.new("shielded_knight", 960, 430), Enemy.new("rift_witch", 1090, 300) }
  elseif area == "black_keep" then
    enemies = { Enemy.new("shielded_knight", 245, 480), Enemy.new("ash_cultist", 485, 390), Enemy.new("winged_curse", 760, 270), Enemy.new("rift_witch", 1060, 400) }
  elseif area == "mountain" then
    enemies = { Enemy.new("cursed_hound", 360, 590), Enemy.new("ash_cultist", 540, 385) }
    boss = Boss.new("lord_celium", 980, 585)
    if not flags.wind then table.insert(items, Item.new("wind", 540, 375)) end
  end
  return enemies, boss, items
end

return Spawner
