local Config = require("src.core.config")
local Graph = require("src.systems.navigation_graph")
local Platforms = {}

local function clone(source)
  local copy = {}
  for key, value in pairs(source) do copy[key] = value end
  return copy
end

function Platforms.create(level)
  local runtime = { platforms = {}, walls = level.walls or {}, props = level.props or {} }
  for index, platform in ipairs(level.platforms or {}) do
    local static = clone(platform)
    static.id = "static:" .. index
    static.oneWay = static.oneWay ~= false and not
      (static.y >= Config.world.groundY - 12 and static.h >= Config.world.groundHeight - 28)
    static.minX, static.maxX, static.minY, static.maxY = static.x, static.x, static.y, static.y
    table.insert(runtime.platforms, static)
  end
  for index, platform in ipairs(level.movingPlatforms or {}) do
    local moving = clone(platform)
    moving.id, moving.oneWay = "moving:" .. index, true
    moving.baseX, moving.baseY = moving.x, moving.y
    moving.time, moving.moving = moving.phase or 0, true
    local offset = math.sin(moving.time) * (moving.range or 60)
    if moving.axis == "y" then moving.y = moving.baseY + offset else moving.x = moving.baseX + offset end
    moving.minX, moving.maxX = moving.baseX, moving.baseX
    moving.minY, moving.maxY = moving.baseY, moving.baseY
    if moving.axis == "y" then moving.minY, moving.maxY = moving.baseY - (moving.range or 60), moving.baseY + (moving.range or 60)
    else moving.minX, moving.maxX = moving.baseX - (moving.range or 60), moving.baseX + (moving.range or 60) end
    table.insert(runtime.platforms, moving)
  end
  runtime.navigation = Graph.build(runtime)
  return runtime
end

function Platforms.update(runtime, dt, riders)
  for _, platform in ipairs(runtime.platforms) do
    if platform.moving then
      local oldX, oldY = platform.x, platform.y
      platform.time = platform.time + dt * (platform.speed or 1)
      local offset = math.sin(platform.time) * (platform.range or 60)
      if platform.axis == "y" then platform.y = platform.baseY + offset else platform.x = platform.baseX + offset end
      local dx, dy = platform.x - oldX, platform.y - oldY
      for _, rider in ipairs(riders or {}) do
        local halfWidth = rider.halfWidth or rider.radius or 12
        local halfHeight = rider.halfHeight or rider.radius or 16
        local onTop = math.abs((rider.y + halfHeight) - oldY) <= 3
        local overlaps = rider.x + halfWidth > oldX and rider.x - halfWidth < oldX + platform.w
        if (rider.supportingPlatformId == platform.id or (onTop and overlaps)) and (rider.vy or 0) >= 0 then
          rider.x, rider.y = rider.x + dx, rider.y + dy
          rider.supportingPlatform, rider.supportingPlatformId = platform, platform.id
        end
      end
    end
  end
end

return Platforms
