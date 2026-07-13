local Defs = require("src.data.bosses")
local Config = require("src.core.config")
local Utils = require("src.core.utils")
local Projectile = require("src.entities.projectile")
local Collision = require("src.systems.collision")
local Boss = {}

function Boss.new(kind, x, y)
  local d = Defs[kind]
  return { kind = kind, name = d.name, x = x, y = y, hp = d.hp, maxHp = d.hp, speed = d.speed,
    damage = d.damage, radius = d.radius, color = d.color, attackTimer = 1, baseCooldown = d.cooldown,
    summonTimer = 5, chargeTimer = 4, chargeWindup = 0, chargeX = 0, chargeY = 0,
    halfWidth = d.radius * .75, halfHeight = d.radius, vy = 0, onGround = false,
    flash = 0, dead = false, isBoss = true, phase = 1, animTime = 0, facing = -1 }
end

local function radial(b, projectiles, count, speed)
  for i = 1, count do
    local angle = i / count * math.pi * 2
    table.insert(projectiles, Projectile.new(b.x, b.y, math.cos(angle), math.sin(angle), "enemy", b.damage, speed, b.color, 7))
  end
end

function Boss.update(b, player, projectiles, level, dt)
  local summons = {}
  local oldX = b.x
  b.animTime = b.animTime + dt
  b.attackTimer, b.summonTimer = b.attackTimer - dt, b.summonTimer - dt
  b.flash = math.max(0, b.flash - dt)
  if b.kind == "lord_celium" and b.hp < b.maxHp * .5 and b.phase == 1 then
    b.phase, b.phaseChanged = 2, true
  end
  local nx, ny = Utils.normalize(player.x - b.x, player.y - b.y)
  b.facing = player.x >= b.x and 1 or -1
  local pace = b.phase == 2 and 1.35 or 1
  if b.chargeWindup > 0 then
    b.chargeWindup = b.chargeWindup - dt
    if b.chargeWindup <= 0 then
      b.x = Utils.clamp(b.x + b.chargeX * 175, 70, 1210)
      b.y = Utils.clamp(b.y + b.chargeY * 70, 100, 650)
    end
  else
    b.x = b.x + (player.x >= b.x and 1 or -1) * b.speed * pace * dt
  end
  if b.attackTimer <= 0 then
    radial(b, projectiles, b.kind == "mire_priest" and 10 or (b.phase == 2 and 16 or 12), b.phase == 2 and 255 or 205)
    b.attackTimer = b.baseCooldown / pace
  end
  if b.summonTimer <= 0 then
    local kind = b.kind == "mire_priest" and "cursed_hound" or "shadow_thrall"
    summons[#summons + 1] = { kind = kind, x = b.x + 55, y = b.y + 20 }
    if b.phase == 2 then summons[#summons + 1] = { kind = "cursed_hound", x = b.x - 55, y = b.y - 20 } end
    b.summonTimer = b.kind == "mire_priest" and 6 or 5
  end
  if b.kind == "lord_celium" and b.chargeWindup <= 0 then
    b.chargeTimer = b.chargeTimer - dt
  end
  if b.kind == "lord_celium" and b.chargeTimer <= 0 and b.chargeWindup <= 0 then
    b.chargeX, b.chargeY, b.chargeWindup = nx, ny, .65
    b.chargeTimer = b.phase == 2 and 3 or 4.5
  end
  local movement = b.x - oldX
  b.x = oldX
  Collision.moveHorizontal(b, movement, level.walls)
  Collision.applyPlatformPhysics(b, level.platforms, dt, Config.physics.actorGravity)
  return summons
end

function Boss.draw(b, assets)
  if assets then assets.drawBoss(b) end
  if not assets then
  love.graphics.setColor(b.flash > 0 and 1 or b.color[1], b.color[2], b.color[3])
  love.graphics.circle("fill", b.x, b.y, b.radius)
  love.graphics.setColor(.08, .04, .1)
  love.graphics.polygon("fill", b.x - b.radius, b.y, b.x, b.y - b.radius * 1.5, b.x + b.radius, b.y)
  end
  love.graphics.setColor(b.color)
  love.graphics.circle("line", b.x, b.y, b.radius + 10 + math.sin(love.timer.getTime() * 3) * 3)
  if b.chargeWindup > 0 then
    local alpha = .35 + math.sin(love.timer.getTime() * 18) * .2
    love.graphics.setColor(.9, .12, .28, alpha)
    love.graphics.setLineWidth(7)
    love.graphics.line(b.x, b.y, b.x + b.chargeX * 210, b.y + b.chargeY * 210)
    love.graphics.setLineWidth(1)
  end
end

return Boss
