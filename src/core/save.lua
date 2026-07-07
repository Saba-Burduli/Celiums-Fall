local Save = {}
local path = "checkpoint.txt"

function Save.exists() return love.filesystem.getInfo(path) ~= nil end

function Save.write(game)
  local p, stones = game.player, {}
  for kind in pairs(p.stones) do table.insert(stones, kind) end
  table.sort(stones)
  local fields = {
    "version=1", "area=" .. game.area, "hp=" .. math.max(1, math.floor(p.hp)), "maxHp=" .. p.maxHp,
    "mana=" .. math.floor(p.mana), "maxMana=" .. p.maxMana, "speed=" .. p.speed,
    "magicDamage=" .. p.magicDamage, "dashCooldown=" .. p.dashCooldown, "stones=" .. table.concat(stones, ","),
    "quest=" .. game.quest.status, "questReward=" .. tostring(p.questReward), "mireDead=" .. tostring(game.mireDead),
  }
  love.filesystem.write(path, table.concat(fields, "\n") .. "\n")
end

function Save.read()
  if not Save.exists() then return nil end
  local values = {}
  for line in (love.filesystem.read(path) or ""):gmatch("[^\r\n]+") do
    local key, value = line:match("^([^=]+)=(.*)$")
    if key then values[key] = value end
  end
  if values.version ~= "1" or not values.area then return nil end
  return values
end

function Save.clear() if Save.exists() then love.filesystem.remove(path) end end

return Save

