local Assets = require("src.core.assets")
local Boss = require("src.entities.boss")
local Companion = require("src.entities.companion")
local Config = require("src.core.config")
local Enemy = require("src.entities.enemy")
local Item = require("src.entities.item")
local Player = require("src.entities.player")
local Projectile = require("src.entities.projectile")
local WorldRenderer = {}

local function drawHazards(game)
  for _, hazard in ipairs(game.level.hazards or {}) do
    love.graphics.setColor(.65, .04, .18, .25 + math.sin(love.timer.getTime() * 4) * .08)
    love.graphics.circle("fill", hazard.x, hazard.y, hazard.radius)
    love.graphics.setColor(.95, .18, .28, .8)
    love.graphics.circle("line", hazard.x, hazard.y, hazard.radius)
  end
end

local function drawExit(game)
  if not game.level.exit then return end
  local open = game.area ~= "shrine" or game.mireDead
  love.graphics.setColor(open and { .35, .42, .58, .7 } or { .45, .08, .16, .8 })
  love.graphics.rectangle("fill", 1215, 510, 35, 122)
  love.graphics.push()
  love.graphics.translate(1202, 615)
  love.graphics.rotate(-math.pi / 2)
  love.graphics.setColor(.7, .68, .76)
  love.graphics.print(game.level.exit.label, 0, 0)
  love.graphics.pop()
end

local function drawVillager(game)
  if game.area ~= "forest" then return end
  if not Assets.draw("villager", 175, 600, 1.1) then
    love.graphics.setColor(.48, .4, .32)
    love.graphics.circle("fill", 175, 600, 17)
  end
  love.graphics.setColor(.7, .65, .6)
  love.graphics.print("Old Villager", 128, 565)
end

local function drawEffects(game)
  if game.meleeFlash > 0 then
    local player = game.player
    love.graphics.setColor(.8, .65, .95, .5)
    love.graphics.arc("line", "open", player.x, player.y, 45,
      math.atan2(player.aimY, player.aimX) - .8, math.atan2(player.aimY, player.aimX) + .8)
  end
  for _, particle in ipairs(game.particles) do
    love.graphics.setColor(particle.color[1], particle.color[2], particle.color[3], particle.life / .35)
    love.graphics.circle("fill", particle.x, particle.y, 3)
  end
  for _, bolt in ipairs(game.lightning) do
    love.graphics.setColor(.5, .9, 1, math.min(1, bolt.life * 8))
    love.graphics.setLineWidth(4)
    love.graphics.line(bolt.x1, bolt.y1,
      (bolt.x1 + bolt.x2) / 2 + love.math.random(-8, 8),
      (bolt.y1 + bolt.y2) / 2 + love.math.random(-8, 8), bolt.x2, bolt.y2)
    love.graphics.setLineWidth(1)
  end
end

function WorldRenderer.draw(game)
  Assets.drawBackdrop(game.level)
  Assets.drawPlatforms(game.physics)
  drawHazards(game)
  drawExit(game)
  drawVillager(game)
  if Companion.present(game.companion, game.area) then Companion.draw(game.companion, Assets) end
  for _, item in ipairs(game.items) do Item.draw(item, Assets) end
  for _, projectile in ipairs(game.projectiles) do Projectile.draw(projectile, Assets) end
  for _, enemy in ipairs(game.enemies) do if not enemy.dead then Enemy.draw(enemy, Assets) end end
  if game.boss and not game.boss.dead then Boss.draw(game.boss, Assets) end
  Player.draw(game.player, Assets)
  drawEffects(game)
  love.graphics.setColor(.12, .1, .16, .13)
  for index = 1, 16 do
    love.graphics.circle("fill", (index * 97 + love.timer.getTime() * 7) % Config.world.width,
      (index * 173) % Config.world.height, 45 + index % 3 * 20)
  end
end

return WorldRenderer
