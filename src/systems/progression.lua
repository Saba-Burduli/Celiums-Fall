local Items = require("src.data.items")
local Progression = {}

function Progression.collect(player, item)
  if item.collected or player.stones[item.kind] then return nil end
  item.collected, player.stones[item.kind] = true, true
  if item.kind == "blood" then player.maxHp, player.hp = player.maxHp + 30, player.hp + 30 end
  if item.kind == "moon" then player.maxMana, player.mana = player.maxMana + 30, player.mana + 30 end
  if item.kind == "ash" then player.magicDamage = player.magicDamage + 10 end
  if item.kind == "wind" then player.speed, player.dashCooldown = player.speed + 25, math.max(.6, player.dashCooldown - .25) end
  return Items[item.kind].name .. " absorbed: " .. Items[item.kind].description
end

function Progression.count(player)
  local n = 0
  for _ in pairs(player.stones) do n = n + 1 end
  return n
end

return Progression

