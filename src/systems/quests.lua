local Data = require("src.data.quests").moonstone
local Quests = {}

function Quests.new() return { status = "available", hasMoonstone = false } end
function Quests.objective(q)
  if q.status == "available" then return "Speak to the Old Villager [E]." end
  if q.status == "active" then return Data.active end
  if q.status == "return" then return Data.return_text end
  return Data.done
end
function Quests.interact(q, player)
  if q.status == "available" then q.status = "active"; return Data.offered end
  if q.status == "return" then
    q.status, q.hasMoonstone = "done", false
    if not player.questReward then player.questReward = true; player.maxHp, player.hp = player.maxHp + 25, player.hp + 25 end
    return Data.done
  end
  return Quests.objective(q)
end
function Quests.takeMoonstone(q)
  if q.status ~= "active" then return false end
  q.status, q.hasMoonstone = "return", true
  return true
end

return Quests

