local Utils = require("src.core.utils")
local M = {}

function M.move()
  local x = (love.keyboard.isDown("d") and 1 or 0) - (love.keyboard.isDown("a") and 1 or 0)
  local y = (love.keyboard.isDown("s") and 1 or 0) - (love.keyboard.isDown("w") and 1 or 0)
  return Utils.normalize(x, y)
end

function M.aim(player)
  local x = (love.keyboard.isDown("right") and 1 or 0) - (love.keyboard.isDown("left") and 1 or 0)
  local y = (love.keyboard.isDown("down") and 1 or 0) - (love.keyboard.isDown("up") and 1 or 0)
  if x ~= 0 or y ~= 0 then return Utils.normalize(x, y) end
  local mx, my = love.mouse.getPosition()
  local sx, sy = love.graphics.getWidth() / 1280, love.graphics.getHeight() / 720
  return Utils.normalize(mx / sx - player.x, my / sy - player.y)
end

return M

