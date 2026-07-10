local Items = require("src.data.items")
local Item = {}

function Item.new(kind, x, y, questItem)
  return { kind = kind, x = x, y = y, radius = 12, collected = false, questItem = questItem, pulse = 0 }
end

function Item.update(item, dt) item.pulse = item.pulse + dt end
function Item.draw(item, assets)
  if item.collected then return end
  local def = Items[item.kind]
  local r = item.radius + math.sin(item.pulse * 3) * 2
  love.graphics.setColor(def.color[1], def.color[2], def.color[3], 0.18)
  love.graphics.circle("fill", item.x, item.y, r * 2)
  love.graphics.setColor(def.color)
  if not assets or not assets.draw("stone", item.x, item.y, 1.7) then
    love.graphics.polygon("fill", item.x, item.y - r, item.x + r * .75, item.y, item.x, item.y + r, item.x - r * .75, item.y)
  end
end

return Item
