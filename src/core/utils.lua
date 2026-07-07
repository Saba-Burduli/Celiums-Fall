local M = {}

function M.clamp(v, lo, hi) return math.max(lo, math.min(hi, v)) end
function M.length(x, y) return math.sqrt(x * x + y * y) end
function M.normalize(x, y)
  local l = M.length(x, y)
  if l == 0 then return 0, 0 end
  return x / l, y / l
end
function M.distance(a, b) return M.length(a.x - b.x, a.y - b.y) end
function M.circleHit(a, b) return M.distance(a, b) < (a.radius + b.radius) end
function M.approach(value, target, amount)
  if value < target then return math.min(value + amount, target) end
  return math.max(value - amount, target)
end

return M

