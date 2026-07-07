local Dialogue = {}

function Dialogue.draw(text)
  if not text or text == "" then return end
  love.graphics.setColor(.025, .02, .04, .94)
  love.graphics.rectangle("fill", 190, 565, 900, 100, 8, 8)
  love.graphics.setColor(.55, .38, .68)
  love.graphics.rectangle("line", 190, 565, 900, 100, 8, 8)
  love.graphics.setColor(.9, .86, .94)
  love.graphics.printf(text, 220, 592, 840, "center")
end

return Dialogue

