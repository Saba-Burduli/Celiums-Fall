local Defs = require("src.data.enemies")
local Utils = require("src.core.utils")
local Projectile = require("src.entities.projectile")
local Enemy = {}

function Enemy.new(kind, x, y)
  local d = Defs[kind]
  return { kind = kind, name = d.name, x = x, y = y, hp = d.hp, maxHp = d.hp, speed = d.speed,
    damage = d.damage, radius = d.radius, color = d.color, behavior = d.kind, attackTimer = love.math.random() * 1.2, flash = 0, dead = false }
end

function Enemy.update(e, player, projectiles, dt)
  e.attackTimer, e.flash = math.max(0, e.attackTimer - dt), math.max(0, e.flash - dt)
  local dx, dy = player.x - e.x, player.y - e.y
  local nx, ny = Utils.normalize(dx, dy)
  local dist = Utils.length(dx, dy)
  if e.behavior == "ranged" then
    if dist > 230 then e.x, e.y = e.x + nx * e.speed * dt, e.y + ny * e.speed * dt end
    if dist < 150 then e.x, e.y = e.x - nx * e.speed * dt, e.y - ny * e.speed * dt end
    if e.attackTimer == 0 and dist < 440 then
      table.insert(projectiles, Projectile.new(e.x, e.y, nx, ny, "enemy", e.damage, 230, { .55, .48, .35 }, 5))
      e.attackTimer = 1.7
    end
  else
    e.x, e.y = e.x + nx * e.speed * dt, e.y + ny * e.speed * dt
  end
end

function Enemy.draw(e)
  love.graphics.setColor(e.flash > 0 and 1 or e.color[1], e.color[2], e.color[3])
  if e.kind == "cursed_hound" then
    love.graphics.polygon("fill", e.x - 16, e.y + 9, e.x + 18, e.y, e.x - 10, e.y - 10)
  elseif e.kind == "ash_cultist" then
    love.graphics.rectangle("fill", e.x - 12, e.y - 14, 24, 28)
    love.graphics.setColor(.12, .1, .1); love.graphics.circle("fill", e.x, e.y - 10, 6)
  else
    love.graphics.circle("fill", e.x, e.y, e.radius)
  end
end

return Enemy

