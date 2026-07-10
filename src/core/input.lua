local Utils = require("src.core.utils")
local M = {}

function M.move()
  local x = (love.keyboard.isDown("d") and 1 or 0) - (love.keyboard.isDown("a") and 1 or 0)
  local y = (love.keyboard.isDown("s") and 1 or 0) - (love.keyboard.isDown("w") and 1 or 0)
  local joystick = love.joystick.getJoysticks()[1]
  if joystick then
    local jx, jy = joystick:getGamepadAxis("leftx"), joystick:getGamepadAxis("lefty")
    if Utils.length(jx, jy) > .2 then x, y = jx, jy end
  end
  return Utils.normalize(x, y)
end

function M.horizontal()
  local x = (love.keyboard.isDown("d") and 1 or 0) - (love.keyboard.isDown("a") and 1 or 0)
  local joystick = love.joystick.getJoysticks()[1]
  if joystick then
    local axis = joystick:getGamepadAxis("leftx")
    if math.abs(axis) > .2 then x = axis end
  end
  return x
end

function M.aim(player)
  local x = (love.keyboard.isDown("right") and 1 or 0) - (love.keyboard.isDown("left") and 1 or 0)
  local y = (love.keyboard.isDown("down") and 1 or 0) - (love.keyboard.isDown("up") and 1 or 0)
  if x ~= 0 or y ~= 0 then return Utils.normalize(x, y) end
  local joystick = love.joystick.getJoysticks()[1]
  if joystick then
    local jx, jy = joystick:getGamepadAxis("rightx"), joystick:getGamepadAxis("righty")
    if Utils.length(jx, jy) > .25 then return Utils.normalize(jx, jy) end
  end
  local mx, my = love.mouse.getPosition()
  local sx, sy = love.graphics.getWidth() / 1280, love.graphics.getHeight() / 720
  return Utils.normalize(mx / sx - player.x, my / sy - player.y)
end

return M
