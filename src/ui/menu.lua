local Menu = {}
local fonts = {}

local function center(text, y, size)
  fonts[size] = fonts[size] or love.graphics.newFont(size)
  love.graphics.setFont(fonts[size])
  love.graphics.printf(text, 0, y, 1280, "center")
end

function Menu.draw(mode)
  love.graphics.clear(.025, .018, .04)
  for i = 1, 45 do
    local x, y = (i * 137) % 1280, (i * 83) % 720
    love.graphics.setColor(.22, .12, .3, .18)
    love.graphics.circle("fill", x, y, 2 + i % 4)
  end
  love.graphics.setColor(.72, .64, .84)
  if mode == "title" then
    center("CELIUM'S FALL", 205, 54)
    love.graphics.setColor(.58, .52, .64); center("A dark fantasy action-adventure", 285, 20)
    love.graphics.setColor(.84, .8, .88); center("Press Enter to begin", 410, 22)
    love.graphics.setColor(.45, .4, .5); center("WASD move  •  J melee  •  K magic  •  Space dash", 475, 15)
  elseif mode == "dead" then
    love.graphics.setColor(.65, .12, .2); center("AREN HAS FALLEN", 250, 45)
    love.graphics.setColor(.82, .78, .84); center("Press Enter to defy the curse again", 370, 21)
  elseif mode == "victory" then
    love.graphics.setColor(.65, .78, .9); center("CELIUM IS FREE", 220, 48)
    love.graphics.setColor(.85, .8, .9); center("Lord Celium is dead. The old shadows loosen their hold.", 315, 21)
    love.graphics.setColor(.65, .58, .7); center("Aren walks down the mountain toward the people he chose.", 355, 18)
    love.graphics.setColor(.85, .8, .9); center("Press Enter to play again", 450, 20)
  end
end

function Menu.pause()
  love.graphics.setColor(0, 0, 0, .72); love.graphics.rectangle("fill", 0, 0, 1280, 720)
  love.graphics.setColor(.9, .85, .95); center("PAUSED", 285, 42)
  love.graphics.setColor(.65, .6, .7); center("Esc to return", 355, 18)
end

return Menu
