local Camera = { shake = 0, width = 640, height = 360, canvas = nil }

function Camera.hit(amount) Camera.shake = math.max(Camera.shake, amount or 4) end
function Camera.update(dt) Camera.shake = math.max(0, Camera.shake - dt * 18) end
function Camera.beginDraw()
  Camera.canvas = Camera.canvas or love.graphics.newCanvas(Camera.width, Camera.height)
  Camera.canvas:setFilter("nearest", "nearest")
  love.graphics.setCanvas(Camera.canvas)
  love.graphics.clear(0, 0, 0, 1)
  love.graphics.push()
  love.graphics.scale(.5, .5)
  if Camera.shake > 0 then
    love.graphics.translate((love.math.random() * 2 - 1) * Camera.shake, (love.math.random() * 2 - 1) * Camera.shake)
  end
end
function Camera.endDraw()
  love.graphics.pop()
  love.graphics.setCanvas()
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(Camera.canvas, 0, 0, 0, love.graphics.getWidth() / Camera.width, love.graphics.getHeight() / Camera.height)
end

return Camera
