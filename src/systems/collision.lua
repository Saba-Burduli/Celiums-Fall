local Utils = require("src.core.utils")
local Collision = {}

function Collision.near(a, b, range) return Utils.distance(a, b) <= range end
function Collision.overlap(a, b) return Utils.circleHit(a, b) end
function Collision.inBounds(e) return e.x > -40 and e.x < 1320 and e.y > 20 and e.y < 760 end

function Collision.moveHorizontal(entity, amount, walls)
  local halfWidth = entity.halfWidth or entity.radius or 12
  local halfHeight = entity.halfHeight or entity.radius or 16
  local nextX = entity.x + amount
  for _, wall in ipairs(walls or {}) do
    local overlapsY = entity.y + halfHeight > wall.y and entity.y - halfHeight < wall.y + wall.h
    if overlapsY then
      if amount > 0 and entity.x + halfWidth <= wall.x and nextX + halfWidth > wall.x then
        nextX, entity.vx = wall.x - halfWidth, 0
      elseif amount < 0 and entity.x - halfWidth >= wall.x + wall.w and nextX - halfWidth < wall.x + wall.w then
        nextX, entity.vx = wall.x + wall.w + halfWidth, 0
      end
    end
  end
  entity.x = Utils.clamp(nextX, halfWidth + 5, 1275 - halfWidth)
end

function Collision.applyPlatformPhysics(entity, platforms, dt, gravity)
  local halfWidth = entity.halfWidth or entity.radius or 12
  local halfHeight = entity.halfHeight or entity.radius or 16
  local previousBottom = entity.y + halfHeight
  entity.vy = (entity.vy or 0) + (gravity or 1450) * dt
  local nextY = entity.y + entity.vy * dt
  local nextBottom = nextY + halfHeight
  entity.onGround = false
  entity.supportingPlatform, entity.supportingPlatformId = nil, nil
  entity.ignorePlatformTimer = math.max(0, (entity.ignorePlatformTimer or 0) - dt)
  if entity.ignorePlatformTimer == 0 then entity.ignorePlatformId = nil end
  if entity.vy >= 0 then
    local landing
    for _, platform in ipairs(platforms or {}) do
      local overlapsX = entity.x + halfWidth > platform.x and entity.x - halfWidth < platform.x + platform.w
      local ignored = entity.ignorePlatformId == platform.id and platform.oneWay ~= false
      if not ignored and overlapsX and previousBottom <= platform.y + 2 and nextBottom >= platform.y then
        if not landing or platform.y < landing.y then landing = platform end
      end
    end
    if landing then
      nextY, entity.vy, entity.onGround = landing.y - halfHeight, 0, true
      entity.supportingPlatform, entity.supportingPlatformId = landing, landing.id
    end
  end
  entity.y = nextY
end


function Collision.dropThrough(entity)
  local platform = entity.supportingPlatform
  if not entity.onGround or not platform or platform.oneWay == false then return false end
  entity.ignorePlatformId, entity.ignorePlatformTimer = platform.id, .24
  entity.supportingPlatform, entity.supportingPlatformId = nil, nil
  entity.onGround, entity.coyote, entity.vy = false, 0, math.max(entity.vy or 0, 90)
  return true
end

return Collision
