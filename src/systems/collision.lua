local Utils = require("src.core.utils")
local Collision = {}

function Collision.near(a, b, range) return Utils.distance(a, b) <= range end
function Collision.overlap(a, b) return Utils.circleHit(a, b) end
function Collision.inBounds(e) return e.x > -40 and e.x < 1320 and e.y > 20 and e.y < 760 end

return Collision

