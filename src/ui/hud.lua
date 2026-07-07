local Progression = require("src.systems.progression")
local Hud = {}

local function bar(x, y, w, h, value, maxValue, color)
  love.graphics.setColor(.04, .03, .06, .9); love.graphics.rectangle("fill", x, y, w, h, 3, 3)
  love.graphics.setColor(color); love.graphics.rectangle("fill", x + 2, y + 2, (w - 4) * math.max(0, value / maxValue), h - 4, 2, 2)
end

function Hud.draw(game)
  local p = game.player
  love.graphics.setFont(game.fonts.small)
  love.graphics.setColor(.9, .86, .93); love.graphics.print("AREN", 24, 18)
  bar(24, 42, 250, 18, p.hp, p.maxHp, { .58, .09, .16 })
  bar(24, 66, 250, 14, p.mana, p.maxMana, { .34, .26, .68 })
  love.graphics.setColor(.86, .82, .9)
  love.graphics.print(math.ceil(p.hp) .. "/" .. p.maxHp, 285, 42)
  love.graphics.print("Stones " .. Progression.count(p) .. "/4", 24, 90)
  love.graphics.printf(game.level.name, 900, 20, 350, "right")
  love.graphics.setColor(.65, .61, .7); love.graphics.printf(game.questObjective, 720, 48, 530, "right")
  if game.boss and not game.boss.dead then
    love.graphics.setColor(.92, .82, .9); love.graphics.printf(game.boss.name .. (game.boss.phase == 2 and " — ASCENDANT" or ""), 390, 620, 500, "center")
    bar(390, 646, 500, 18, game.boss.hp, game.boss.maxHp, { .48, .08, .24 })
  end
  if game.prompt then
    love.graphics.setColor(.9, .85, .65); love.graphics.printf("[E] " .. game.prompt, 390, 530, 500, "center")
  end
end

return Hud

