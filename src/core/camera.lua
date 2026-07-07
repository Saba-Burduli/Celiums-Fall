local Camera = { shake = 0 }

function Camera.hit(amount) Camera.shake = math.max(Camera.shake, amount or 4) end
function Camera.update(dt) Camera.shake = math.max(0, Camera.shake - dt * 18) end
function Camera.beginDraw()
  local sx, sy = love.graphics.getWidth() / 1280, love.graphics.getHeight() / 720
  love.graphics.push()
  love.graphics.scale(sx, sy)
  if Camera.shake > 0 then
    love.graphics.translate((love.math.random() * 2 - 1) * Camera.shake, (love.math.random() * 2 - 1) * Camera.shake)
  end
end
function Camera.endDraw() love.graphics.pop() end

return Camera
