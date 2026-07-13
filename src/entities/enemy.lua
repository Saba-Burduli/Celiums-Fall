local Defs = require("src.data.enemies")
local Config = require("src.core.config")
local Utils = require("src.core.utils")
local Projectile = require("src.entities.projectile")
local Collision = require("src.systems.collision")
local Navigation = require("src.systems.navigation")
local Enemy = {}

function Enemy.new(kind, x, y)
  local d = Defs[kind]
  return { kind = kind, name = d.name, x = x, y = y, hp = d.hp, maxHp = d.hp, speed = d.speed,
    damage = d.damage, radius = d.radius, color = d.color, behavior = d.kind, attackTimer = love.math.random() * 1.2,
    specialTimer = 1.8 + love.math.random(), hover = love.math.random() * 6, guard = d.kind == "shield",
    halfWidth = d.radius * .7, halfHeight = d.radius, vy = 0, onGround = false, facing = -1, flash = 0, dead = false }
end

local function shootSpread(e, nx, ny, projectiles)
  local base = math.atan2(ny, nx)
  for _, offset in ipairs({ -.18, 0, .18 }) do
    table.insert(projectiles, Projectile.new(e.x, e.y, math.cos(base + offset), math.sin(base + offset), "enemy", e.damage, 250, e.color, 6))
  end
end

function Enemy.update(e, player, projectiles, level, dt)
  local oldX = e.x
  e.attackTimer, e.flash = math.max(0, e.attackTimer - dt), math.max(0, e.flash - dt)
  local dx, dy = player.x - e.x, player.y - e.y
  local nx, ny = Utils.normalize(dx, dy)
  local dist = Utils.length(dx, dy)
  e.facing = dx >= 0 and 1 or -1
  e.specialTimer, e.hover = e.specialTimer - dt, e.hover + dt
  if e.behavior == "shield" then
    local baseSpeed = e.speed
    if e.specialTimer <= 0 then
      e.guard = false
      e.speed = e.speed * 2.8
      if e.specialTimer <= -.55 then e.specialTimer, e.guard = 2.5, true end
    end
    Navigation.update(e, player, level, dt)
    e.speed = baseSpeed
  elseif e.behavior == "teleport" then
    if e.specialTimer <= 0 then
      local angle = love.math.random() * math.pi * 2
      e.x, e.y = player.x + math.cos(angle) * 210, player.y - 70
      e.x = Utils.clamp(e.x, 70, 1210)
      nx, ny = Utils.normalize(player.x - e.x, player.y - e.y)
      shootSpread(e, nx, ny, projectiles)
      e.specialTimer = 3.1
    end
  elseif e.behavior == "flying" then
    local sway = math.sin(e.hover * 3) * 75
    e.x, e.y = e.x + (nx * e.speed - ny * sway) * dt, e.y + (ny * e.speed + nx * sway) * dt
  elseif e.behavior == "ranged" then
    Navigation.update(e, player, level, dt, 190)
    if e.attackTimer == 0 and dist < 440 then
      table.insert(projectiles, Projectile.new(e.x, e.y, nx, ny, "enemy", e.damage, 230, { .55, .48, .35 }, 5))
      e.attackTimer = 1.7
    end
  else
    Navigation.update(e, player, level, dt)
  end
  if e.behavior == "teleport" then
    e.x = Utils.clamp(e.x, 18, 1262)
  else
    local movement = e.x - oldX
    e.x = oldX
    Collision.moveHorizontal(e, movement, level.walls)
  end
  if e.behavior ~= "flying" and e.behavior ~= "teleport" then
    Collision.applyPlatformPhysics(e, level.platforms, dt, Config.physics.actorGravity)
  end
end

function Enemy.draw(e, assets)
  if assets and assets.draw(e.kind, e.x, e.y, e.kind == "winged_curse" and .75 or 1.15, e.flash, e.facing) then return end
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
