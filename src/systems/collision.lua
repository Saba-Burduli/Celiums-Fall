local Utils = require("src.core.utils")
local Collision = {}

function Collision.near(a, b, range) return Utils.distance(a, b) <= range end
function Collision.overlap(a, b) return Utils.circleHit(a, b) end
function Collision.inBounds(e) return e.x > -40 and e.x < 1320 and e.y > 20 and e.y < 760 end

function Collision.applyPlatformPhysics(entity, platforms, dt, gravity)
  local halfWidth = entity.halfWidth or entity.radius or 12
  local halfHeight = entity.halfHeight or entity.radius or 16
  local previousBottom = entity.y + halfHeight
  entity.vy = (entity.vy or 0) + (gravity or 1450) * dt
  local nextY = entity.y + entity.vy * dt
  local nextBottom = nextY + halfHeight
  entity.onGround = false
  if entity.vy >= 0 then
    local landing
    for _, platform in ipairs(platforms or {}) do
      local overlapsX = entity.x + halfWidth > platform.x and entity.x - halfWidth < platform.x + platform.w
      if overlapsX and previousBottom <= platform.y + 2 and nextBottom >= platform.y then
        if not landing or platform.y < landing.y then landing = platform end
      end
    end
    if landing then
      nextY, entity.vy, entity.onGround = landing.y - halfHeight, 0, true
    end
  end
  entity.y = nextY
end

return Collision
