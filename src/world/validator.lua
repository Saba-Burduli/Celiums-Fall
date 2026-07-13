local Bosses = require("src.data.bosses")
local Config = require("src.core.config")
local Encounters = require("src.data.encounters")
local Enemies = require("src.data.enemies")
local Items = require("src.data.items")
local Validator = {}

local function invalid(area, message)
  return false, ("invalid area '%s': %s"):format(tostring(area), message)
end

function Validator.area(area, levels)
  local level = levels[area]
  if not level then return invalid(area, "level definition is missing") end
  local encounter = Encounters[area]
  if not encounter then return invalid(area, "encounter definition is missing") end
  if not level.name or not level.entry or not level.platforms then return invalid(area, "required fields are missing") end
  if level.next and not levels[level.next] then return invalid(area, "next area does not exist: " .. level.next) end

  for _, platform in ipairs(level.platforms) do
    if not platform.x or not platform.y or not platform.w or not platform.h then
      return invalid(area, "platform geometry is incomplete")
    end
    if platform.w < 120 or platform.y < 330 or platform.y > Config.world.groundY then
      return invalid(area, "static platform is outside supported dimensions")
    end
  end
  for _, platform in ipairs(level.movingPlatforms or {}) do
    if not platform.x or not platform.y or not platform.w or not platform.h or not platform.axis then
      return invalid(area, "moving platform geometry is incomplete")
    end
    if platform.w < 100 or (platform.range or 0) > 110 then
      return invalid(area, "moving platform is outside supported dimensions")
    end
  end
  for _, enemy in ipairs(encounter.enemies or {}) do
    if not Enemies[enemy.kind] then return invalid(area, "unknown enemy: " .. tostring(enemy.kind)) end
  end
  if encounter.boss and not Bosses[encounter.boss.kind] then
    return invalid(area, "unknown boss: " .. tostring(encounter.boss.kind))
  end
  for _, item in ipairs(encounter.items or {}) do
    if not Items[item.kind] then return invalid(area, "unknown item: " .. tostring(item.kind)) end
  end
  return true
end

function Validator.all(levels)
  for area in pairs(levels) do
    local ok, err = Validator.area(area, levels)
    if not ok then return false, err end
  end
  for area in pairs(Encounters) do
    if not levels[area] then return invalid(area, "encounter has no level") end
  end
  return true
end

return Validator
