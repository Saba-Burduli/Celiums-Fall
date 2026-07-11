local State = require("src.core.state")

function love.load(args)
  love.graphics.setDefaultFilter("nearest", "nearest")
  State.load()
  for _, value in ipairs(args or {}) do
    if value == "--smoke" then
      local ok, err = xpcall(State.smokeTest, debug.traceback)
      love.graphics.setCanvas()
      if not ok then print(err) end
      love.event.quit(ok and 0 or 1)
      return
    end
  end
end

function love.update(dt) State.update(math.min(dt, 1 / 30)) end
function love.draw() State.draw() end
function love.keypressed(key) State.keypressed(key) end
function love.mousepressed(x, y, button) State.mousepressed(x, y, button) end
function love.gamepadpressed(joystick, button) State.gamepadpressed(joystick, button) end
