local Projectile = {}

function Projectile.new(x, y, dx, dy, owner, damage, speed, color, radius)
  return { x = x, y = y, dx = dx, dy = dy, owner = owner, damage = damage, speed = speed or 340,
    color = color or { 0.6, 0.3, 0.9 }, radius = radius or 6, life = 4 }
end

function Projectile.update(p, dt)
  p.x, p.y = p.x + p.dx * p.speed * dt, p.y + p.dy * p.speed * dt
  p.life = p.life - dt
end

function Projectile.draw(p)
  love.graphics.setColor(p.color)
  love.graphics.circle("fill", p.x, p.y, p.radius)
  love.graphics.setColor(p.color[1], p.color[2], p.color[3], 0.25)
  love.graphics.circle("fill", p.x, p.y, p.radius * 2.2)
end

return Projectile

