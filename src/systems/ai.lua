local Boss = require("src.entities.boss")
local Enemy = require("src.entities.enemy")
local AI = {}

function AI.update(enemies, boss, player, projectiles, level, dt)
  for _, enemy in ipairs(enemies) do if not enemy.dead then Enemy.update(enemy, player, projectiles, level, dt) end end
  if not boss or boss.dead then return end
  local alive = 0
  for _, enemy in ipairs(enemies) do if not enemy.dead then alive = alive + 1 end end
  local summons = Boss.update(boss, player, projectiles, level, dt)
  for _, summon in ipairs(summons) do
    if alive >= 6 then break end
    enemies[#enemies + 1] = Enemy.new(summon.kind, summon.x, summon.y)
    alive = alive + 1
  end
end

return AI
