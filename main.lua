local State = require("src.core.state")

function love.load()
  love.graphics.setDefaultFilter("nearest", "nearest")
  State.load()
end

function love.update(dt) State.update(math.min(dt, 1 / 30)) end
function love.draw() State.draw() end
function love.keypressed(key) State.keypressed(key) end
function love.mousepressed(x, y, button) State.mousepressed(x, y, button) end
function love.gamepadpressed(joystick, button) State.gamepadpressed(joystick, button) end
