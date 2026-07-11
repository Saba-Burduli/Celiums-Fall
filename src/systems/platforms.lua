local Platforms = {}

local function clone(source)
  local copy = {}
  for key, value in pairs(source) do copy[key] = value end
  return copy
end

function Platforms.create(level)
  local runtime = { platforms = {}, walls = level.walls or {}, props = level.props or {} }
  for _, platform in ipairs(level.platforms or {}) do table.insert(runtime.platforms, clone(platform)) end
  for _, platform in ipairs(level.movingPlatforms or {}) do
    local moving = clone(platform)
    moving.baseX, moving.baseY = moving.x, moving.y
    moving.time, moving.moving = moving.phase or 0, true
    local offset = math.sin(moving.time) * (moving.range or 60)
    if moving.axis == "y" then moving.y = moving.baseY + offset else moving.x = moving.baseX + offset end
    table.insert(runtime.platforms, moving)
  end
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
        if onTop and overlaps and (rider.vy or 0) >= 0 then rider.x, rider.y = rider.x + dx, rider.y + dy end
      end
    end
  end
end

function Platforms.validate(level)
  for _, platform in ipairs(level.platforms or {}) do
    if platform.w < 120 or platform.y < 330 or platform.y > 632 then return false end
  end
  for _, platform in ipairs(level.movingPlatforms or {}) do
    if platform.w < 100 or (platform.range or 0) > 110 then return false end
  end
  return true
end

return Platforms
