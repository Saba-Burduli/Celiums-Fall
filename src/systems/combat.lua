local Utils = require("src.core.utils")
local Projectile = require("src.entities.projectile")
local Camera = require("src.core.camera")
local Combat = {}

local function particles(game, x, y, color, amount)
  for _ = 1, amount or 6 do
    local angle, speed = love.math.random() * math.pi * 2, love.math.random(35, 105)
    table.insert(game.particles, { x = x, y = y, dx = math.cos(angle) * speed, dy = math.sin(angle) * speed,
      life = .35, color = color })
  end
end

function Combat.melee(game)
  local p = game.player
  if p.meleeTimer > 0 then return end
  p.meleeTimer, game.meleeFlash = .42, .12
  if game.audio then game.audio.play("melee") end
  local targetX, targetY = p.x + p.aimX * 31, p.y + p.aimY * 31
  local hitPoint = { x = targetX, y = targetY, radius = 28 }
  for _, e in ipairs(game.enemies) do
    if not e.dead and Utils.circleHit(hitPoint, e) then Combat.damageEnemy(game, e, p.meleeDamage) end
  end
  if game.boss and not game.boss.dead and Utils.circleHit(hitPoint, game.boss) then Combat.damageEnemy(game, game.boss, p.meleeDamage) end
end

function Combat.magic(game)
  local p = game.player
  if p.magicTimer > 0 or p.mana < 18 then return end
  p.magicTimer, p.mana = .32, p.mana - 18
  if game.audio then game.audio.play("magic") end
  table.insert(game.projectiles, Projectile.new(p.x, p.y, p.aimX, p.aimY, "player", p.magicDamage, 430, { .55, .32, .92 }, 7))
end

function Combat.damageEnemy(game, e, amount)
  if e.guard then amount = math.max(1, math.floor(amount * .25)) end
  e.hp, e.flash = e.hp - amount, .1
  if game.audio then game.audio.play("hit") end
  particles(game, e.x, e.y, e.color, 7); Camera.hit(3)
  if e.hp <= 0 then e.dead = true; particles(game, e.x, e.y, { .75, .1, .3 }, 13) end
end

function Combat.chainLightning(game)
  local p = game.player
  if not p.chainUnlocked or p.chainTimer > 0 or p.mana < 32 then return false end
  local candidates = {}
  for _, enemy in ipairs(game.enemies) do if not enemy.dead then table.insert(candidates, enemy) end end
  if game.boss and not game.boss.dead then table.insert(candidates, game.boss) end
  local aim = { x = p.x + p.aimX * 190, y = p.y + p.aimY * 190 }
  table.sort(candidates, function(a, b) return Utils.distance(a, aim) < Utils.distance(b, aim) end)
  if not candidates[1] or Utils.distance(candidates[1], aim) > 220 then return false end
  p.mana, p.chainTimer = p.mana - 32, 1.25
  game.lightning = game.lightning or {}
  local from, hit = p, {}
  for _ = 1, 3 do
    local best, bestDistance
    for _, target in ipairs(candidates) do
      if not hit[target] then
        local distance = Utils.distance(from, target)
        if distance <= 230 and (not bestDistance or distance < bestDistance) then best, bestDistance = target, distance end
      end
    end
    if not best then break end
    table.insert(game.lightning, { x1 = from.x, y1 = from.y, x2 = best.x, y2 = best.y, life = .16 })
    Combat.damageEnemy(game, best, p.magicDamage * .8)
    hit[best], from = true, best
  end
  if game.audio then game.audio.play("magic") end
  return true
end

function Combat.damagePlayer(game, amount)
  local p = game.player
  if p.invulnerable > 0 then return end
  p.hp, p.invulnerable, p.flash = p.hp - amount, .65, .14
  if game.audio then game.audio.play("hit") end
  particles(game, p.x, p.y, { .55, .2, .3 }, 9); Camera.hit(6)
end

function Combat.update(game, dt)
  local p = game.player
  for _, hazard in ipairs(game.level.hazards or {}) do
    if Utils.circleHit(p, hazard) then Combat.damagePlayer(game, hazard.damage) end
  end
  for _, e in ipairs(game.enemies) do
    local contactAttacker = e.behavior == "melee" or e.behavior == "shield" or e.behavior == "flying"
    if not e.dead and contactAttacker and Utils.circleHit(p, e) and e.attackTimer <= 0 then
      Combat.damagePlayer(game, e.damage); e.attackTimer = .9
    end
  end
  if game.boss and not game.boss.dead and Utils.circleHit(p, game.boss) and game.boss.contactTimer == nil then
    Combat.damagePlayer(game, game.boss.damage); game.boss.contactTimer = .8
  end
  if game.boss and game.boss.contactTimer then
    game.boss.contactTimer = game.boss.contactTimer - dt
    if game.boss.contactTimer <= 0 then game.boss.contactTimer = nil end
  end
  for i = #game.projectiles, 1, -1 do
    local shot = game.projectiles[i]
    Projectile.update(shot, dt)
    local remove = shot.life <= 0 or shot.x < 0 or shot.x > 1280 or shot.y < 40 or shot.y > 720
    if not remove and shot.owner == "enemy" and Utils.circleHit(shot, p) then Combat.damagePlayer(game, shot.damage); remove = true end
    if not remove and (shot.owner == "player" or shot.owner == "ally") then
      for _, e in ipairs(game.enemies) do
        if not e.dead and Utils.circleHit(shot, e) then Combat.damageEnemy(game, e, shot.damage); remove = true; break end
      end
      if not remove and game.boss and not game.boss.dead and Utils.circleHit(shot, game.boss) then Combat.damageEnemy(game, game.boss, shot.damage); remove = true end
    end
    if remove then table.remove(game.projectiles, i) end
  end
  for i = #(game.lightning or {}), 1, -1 do
    game.lightning[i].life = game.lightning[i].life - dt
    if game.lightning[i].life <= 0 then table.remove(game.lightning, i) end
  end
  for i = #game.particles, 1, -1 do
    local q = game.particles[i]; q.x, q.y, q.life = q.x + q.dx * dt, q.y + q.dy * dt, q.life - dt
    if q.life <= 0 then table.remove(game.particles, i) end
  end
end

return Combat
