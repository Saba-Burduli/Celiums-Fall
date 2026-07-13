local Storage = require("src.core.storage")
local Save = {}
local path = "checkpoint.txt"
local order = { "version", "area", "hp", "maxHp", "mana", "maxMana", "speed", "magicDamage",
  "dashCooldown", "stones", "quest", "questReward", "mireDead", "sillius", "chainUnlocked" }

function Save.exists() return love.filesystem.getInfo(path) ~= nil end

function Save.write(game)
  local p, stones = game.player, {}
  for kind in pairs(p.stones) do table.insert(stones, kind) end
  table.sort(stones)
  Storage.write(path, {
    version = 1,
    area = game.area,
    hp = math.max(1, math.floor(p.hp)),
    maxHp = p.maxHp,
    mana = math.floor(p.mana),
    maxMana = p.maxMana,
    speed = p.speed,
    magicDamage = p.magicDamage,
    dashCooldown = p.dashCooldown,
    stones = table.concat(stones, ","),
    quest = game.quest.status,
    questReward = p.questReward,
    mireDead = game.mireDead,
    sillius = game.companion.status,
    chainUnlocked = p.chainUnlocked,
  }, order)
end

function Save.read()
  local values = Storage.read(path)
  if not values then return nil end
  if values.version ~= "1" or not values.area then return nil end
  return values
end

function Save.clear() if Save.exists() then love.filesystem.remove(path) end end

return Save
