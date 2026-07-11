local Input = require("src.core.input")
local Collision = require("src.systems.collision")
local Player = {}

function Player.new(x, y)
  return { name = "Aren", x = x, y = y, radius = 16, halfWidth = 13, halfHeight = 25, vx = 0, vy = 0,
    onGround = false, coyote = 0, facing = 1, animTime = 0, dashTime = 0, hp = 120, maxHp = 120, mana = 100, maxMana = 100,
    speed = 190, meleeDamage = 30, magicDamage = 27, aimX = 1, aimY = 0, meleeTimer = 0, magicTimer = 0,
    chainTimer = 0, chainUnlocked = false, dashTimer = 0, dashCooldown = 1.1, invulnerable = 0, flash = 0,
    stones = {}, questReward = false }
end

function Player.update(p, level, dt)
  p.meleeTimer, p.magicTimer = math.max(0, p.meleeTimer - dt), math.max(0, p.magicTimer - dt)
  p.chainTimer = math.max(0, p.chainTimer - dt)
  p.dashTimer, p.invulnerable, p.flash = math.max(0, p.dashTimer - dt), math.max(0, p.invulnerable - dt), math.max(0, p.flash - dt)
  p.dashTime = math.max(0, p.dashTime - dt)
  p.mana = math.min(p.maxMana, p.mana + 13 * dt)
  p.animTime = p.animTime + dt
  local move = Input.horizontal()
  if move ~= 0 then p.facing = move > 0 and 1 or -1 end
  if p.dashTime > 0 then p.vx = p.facing * p.speed * 2.7 else p.vx = move * p.speed end
  Collision.moveHorizontal(p, p.vx * dt, level.walls)
  Collision.applyPlatformPhysics(p, level.platforms, dt, 1500)
  p.coyote = p.onGround and .11 or math.max(0, p.coyote - dt)
  if p.y > 760 then p.hp = 0 end
  local ax, ay = Input.aim(p)
  if ax ~= 0 or ay ~= 0 then p.aimX, p.aimY = ax, ay
  else p.aimX, p.aimY = p.facing, 0 end
end

function Player.jump(p)
  if p.coyote <= 0 then return false end
  p.vy, p.onGround, p.coyote = -570, false, 0
  return true
end

function Player.dropThrough(p)
  return Collision.dropThrough(p)
end

function Player.dash(p)
  if p.dashTimer > 0 then return false end
  p.dashTimer, p.invulnerable, p.dashTime = p.dashCooldown, 0.25, .18
  p.vx = p.facing * p.speed * 2.25
  return true
end

function Player.draw(p, assets)
  if assets and assets.drawPlayer(p) then return end
  local flash = p.flash > 0 and 1 or 0
  love.graphics.setColor(0.28 + flash * .5, 0.67, 0.86)
  love.graphics.circle("fill", p.x, p.y, p.radius)
  love.graphics.setColor(0.08, 0.05, 0.12)
  love.graphics.polygon("fill", p.x - 13, p.y + 13, p.x + 13, p.y + 13, p.x, p.y - 20)
  love.graphics.setColor(0.75, 0.5, 0.92)
  love.graphics.line(p.x, p.y, p.x + p.aimX * 24, p.y + p.aimY * 24)
end

return Player
