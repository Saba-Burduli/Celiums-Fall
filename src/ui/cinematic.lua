local Config = require("src.core.config")
local Lore = require("src.data.lore")
local Fonts = require("src.ui.fonts")
local Cinematic = {}

function Cinematic.start(game, area)
  local scene = Lore[area]
  game.seenCinematics = game.seenCinematics or {}
  if not scene or game.seenCinematics[area] then return false end
  game.seenCinematics[area] = true
  game.cinematic = { area = area, scene = scene, page = 1, time = 0 }
  return true
end

function Cinematic.update(game, dt)
  if game.cinematic then game.cinematic.time = game.cinematic.time + dt end
end

function Cinematic.advance(game)
  local current = game.cinematic
  if not current then return false end
  if current.page < #current.scene.pages then
    current.page, current.time = current.page + 1, 0
  else game.cinematic = nil end
  return true
end

local function silhouette(y, color, speed, time)
  love.graphics.setColor(color)
  local shift = math.sin(time * speed) * 12
  local width, height = Config.world.width, Config.world.height
  love.graphics.polygon("fill", 0, height, 0, y, 180 + shift, y - 95, 340 + shift, y,
    520 + shift, y - 135, 710 + shift, y, 900 + shift, y - 105, 1080 + shift, y,
    width, y - 80, width, height)
end

function Cinematic.draw(game)
  local current = game.cinematic
  if not current then return end
  love.graphics.setColor(.008, .006, .018, .96)
  love.graphics.rectangle("fill", 0, 0, Config.world.width, Config.world.height)
  love.graphics.setColor(.28, .12, .36, .34); love.graphics.circle("fill", 990, 165, 105)
  silhouette(470, { .12, .06, .18, .9 }, .35, current.time)
  silhouette(550, { .055, .035, .085, 1 }, .6, current.time)
  love.graphics.setColor(.65, .18, .32, .5)
  love.graphics.rectangle("fill", 620, 235, 45, 290)
  love.graphics.polygon("fill", 580, 235, 642, 145, 705, 235)
  love.graphics.setFont(Fonts.get(18))
  love.graphics.setColor(.88, .78, .92); love.graphics.printf(current.scene.title, 110, 78, 1060, "center")
  love.graphics.setColor(.92, .88, .94)
  love.graphics.printf(current.scene.pages[current.page], 180, 535, 920, "center")
  love.graphics.setColor(.55, .5, .62)
  love.graphics.printf(("Continue [Enter / Space / A]    %d / %d"):format(current.page, #current.scene.pages),
    180, 660, 920, "center")
end

return Cinematic
