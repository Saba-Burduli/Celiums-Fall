local Enemy = require("src.entities.enemy")
local Boss = require("src.entities.boss")
local Item = require("src.entities.item")
local Encounters = require("src.data.encounters")
local Spawner = {}

local function enabled(specification, flags)
  return not specification.unlessFlag or not flags[specification.unlessFlag]
end

function Spawner.forArea(area, flags)
  local definition = assert(Encounters[area], "missing encounter definition: " .. tostring(area))
  local enemies, boss, items = {}, nil, {}
  for _, specification in ipairs(definition.enemies or {}) do
    enemies[#enemies + 1] = Enemy.new(specification.kind, specification.x, specification.y)
  end
  if definition.boss and enabled(definition.boss, flags) then
    boss = Boss.new(definition.boss.kind, definition.boss.x, definition.boss.y)
  end
  for _, specification in ipairs(definition.items or {}) do
    if enabled(specification, flags) then
      items[#items + 1] = Item.new(specification.kind, specification.x, specification.y, specification.questItem)
    end
  end
  return enemies, boss, items
end

return Spawner
