local Defs = require("src.data.enemies")
local Config = require("src.core.config")
local Utils = require("src.core.utils")
local Projectile = require("src.entities.projectile")
local Collision = require("src.systems.collision")
local Navigation = require("src.systems.navigation")
local Enemy = {}

function Enemy.new(kind, x, y)
  local d = Defs[kind]
  return {
    kind = kind,
    name = d.name,
    x = x,
    y = y,
    hp = d.hp,
    maxHp = d.hp,
    speed = d.speed,
    damage = d.damage,
    radius = d.radius,
    color = d.color,
    behavior = d.kind,
    attackTimer = love.math.random() * 1.2,
    specialTimer = 1.8 + love.math.random(),
    hover = love.math.random() * 6,
    guard = d.kind == "shield",
    halfWidth = d.radius * .7,
    halfHeight = d.radius,
    vy = 0,
    onGround = false,
    facing = -1,
    flash = 0,
    dead = false,
  }
end

local function addProjectile(e, projectiles, dx, dy, speed, color, radius)
  projectiles[#projectiles + 1] = Projectile.new(
    e.x, e.y, dx, dy, "enemy", e.damage, speed, color or e.color, radius
  )
end

local function shootSpread(e, nx, ny, projectiles)
  local base = math.atan2(ny, nx)
  for _, offset in ipairs({ -.18, 0, .18 }) do
    addProjectile(e, projectiles, math.cos(base + offset), math.sin(base + offset), 250, e.color, 6)
  end
end

local function updateShield(e, player, level, dt)
  local baseSpeed = e.speed
  if e.specialTimer <= 0 then
    e.guard = false
    e.speed = e.speed * 2.8
    if e.specialTimer <= -.55 then
      e.specialTimer, e.guard = 2.5, true
    end
  end
  Navigation.update(e, player, level, dt)
  e.speed = baseSpeed
end

local function updateTeleport(e, player, projectiles)
  if e.specialTimer > 0 then return end
  local angle = love.math.random() * math.pi * 2
  e.x = Utils.clamp(player.x + math.cos(angle) * 210, 70, Config.world.width - 70)
  e.y = player.y - 70
  local nx, ny = Utils.normalize(player.x - e.x, player.y - e.y)
  shootSpread(e, nx, ny, projectiles)
  e.specialTimer = 3.1
end

local function updateFlying(e, nx, ny, dt)
  local sway = math.sin(e.hover * 3) * 75
  e.x = e.x + (nx * e.speed - ny * sway) * dt
  e.y = e.y + (ny * e.speed + nx * sway) * dt
end

local function updateRanged(e, player, projectiles, level, distance, nx, ny, dt)
  Navigation.update(e, player, level, dt, 190)
  if e.attackTimer == 0 and distance < 440 then
    addProjectile(e, projectiles, nx, ny, 230, { .55, .48, .35 }, 5)
    e.attackTimer = 1.7
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
    updateShield(e, player, level, dt)
  elseif e.behavior == "teleport" then
    updateTeleport(e, player, projectiles)
  elseif e.behavior == "flying" then
    updateFlying(e, nx, ny, dt)
  elseif e.behavior == "ranged" then
    updateRanged(e, player, projectiles, level, dist, nx, ny, dt)
  else
    Navigation.update(e, player, level, dt)
  end
  if e.behavior == "teleport" then
    e.x = Utils.clamp(e.x, 18, Config.world.width - 18)
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
  local scale = e.kind == "winged_curse" and .75 or 1.15
  if assets and assets.draw(e.kind, e.x, e.y, scale, e.flash, e.facing) then return end
  love.graphics.setColor(e.flash > 0 and 1 or e.color[1], e.color[2], e.color[3])
  if e.kind == "cursed_hound" then
    love.graphics.polygon("fill", e.x - 16, e.y + 9, e.x + 18, e.y, e.x - 10, e.y - 10)
  elseif e.kind == "ash_cultist" then
    love.graphics.rectangle("fill", e.x - 12, e.y - 14, 24, 28)
    love.graphics.setColor(.12, .1, .1)
    love.graphics.circle("fill", e.x, e.y - 10, 6)
  else
    love.graphics.circle("fill", e.x, e.y, e.radius)
  end
end

return Enemy
