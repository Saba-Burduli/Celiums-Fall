local AI = {}

function AI.update(enemies, boss, player, projectiles, dt)
  local Enemy = require("src.entities.enemy")
  for _, enemy in ipairs(enemies) do if not enemy.dead then Enemy.update(enemy, player, projectiles, dt) end end
  if boss and not boss.dead then require("src.entities.boss").update(boss, player, projectiles, enemies, dt) end
end

return AI

