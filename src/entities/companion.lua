local Utils = require("src.core.utils")
local Projectile = require("src.entities.projectile")
local Companion = {}

function Companion.new()
  return { name = "Sillius", status = "unmet", x = 250, y = 470, radius = 14, shotTimer = 0,
    vx = 0, facing = 1, animTime = 0 }
end

function Companion.present(c, area)
  if area == "forest_depths" then return true end
  return c.status == "allied" and (area == "shrine" or area == "shrine_crypt" or area == "mountain_path")
end

function Companion.update(c, game, dt)
  if not Companion.present(c, game.area) then return end
  c.animTime = c.animTime + dt
  c.vx = 0
  if c.status ~= "allied" then return end
  local oldX = c.x
  c.shotTimer = math.max(0, c.shotTimer - dt)
  local p = game.player
  local dx, dy = p.x - c.x, p.y - c.y
  local nx, ny = Utils.normalize(dx, dy)
  if Utils.length(dx, dy) > 75 then c.x, c.y = c.x + nx * 150 * dt, c.y + ny * 150 * dt end
  c.vx = (c.x - oldX) / dt
  if math.abs(c.vx) > 1 then c.facing = c.vx > 0 and 1 or -1 end
  if c.shotTimer > 0 then return end
  local target, distance
  for _, enemy in ipairs(game.enemies) do
    if not enemy.dead then
      local d = Utils.distance(c, enemy)
      if d < 360 and (not distance or d < distance) then target, distance = enemy, d end
    end
  end
  if game.boss and not game.boss.dead then
    local d = Utils.distance(c, game.boss)
    if d < 360 and (not distance or d < distance) then target, distance = game.boss, d end
  end
  if target then
    nx, ny = Utils.normalize(target.x - c.x, target.y - c.y)
    table.insert(game.projectiles, Projectile.new(c.x, c.y, nx, ny, "ally", 9, 360, { .3, .8, .9 }, 5))
    c.shotTimer = .9
  end
end

function Companion.draw(c, assets)
  if not assets.drawCompanion(c) then
    love.graphics.setColor(.45, .7, .8); love.graphics.circle("fill", c.x, c.y, c.radius)
  end
end

return Companion
