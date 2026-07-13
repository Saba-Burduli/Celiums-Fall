local Menu = {}
local fonts = {}
local Assets = require("src.core.assets")

local function center(text, y, size)
  fonts[size] = fonts[size] or love.graphics.newFont("assets/fonts/kenpixel-square.ttf", size)
  love.graphics.setFont(fonts[size])
  love.graphics.printf(text, 0, y, 1280, "center")
end

function Menu.draw(mode)
  if Assets.gothic and Assets.gothic.tiles then Assets.drawBackdrop({ background = { .018, .01, .03 }, theme = "church" })
  else love.graphics.clear(.025, .018, .04) end
  for i = 1, 45 do
    local x, y = (i * 137) % 1280, (i * 83) % 720
    love.graphics.setColor(.22, .12, .3, .18)
    love.graphics.circle("fill", x, y, 2 + i % 4)
  end
  love.graphics.setColor(.72, .64, .84)
  if mode == "title" then
    center("CELIUM'S FALL", 205, 54)
    love.graphics.setColor(.58, .52, .64); center("A dark fantasy action-adventure", 285, 20)
    love.graphics.setColor(.84, .8, .88); center("Enter: new journey    C: continue checkpoint", 410, 22)
    love.graphics.setColor(.55, .5, .62); center("A/D move  •  Space jump  •  Shift dash  •  J melee  •  K magic", 475, 15)
  elseif mode == "dead" then
    love.graphics.setColor(.65, .12, .2); center("AREN HAS FALLEN", 250, 45)
    love.graphics.setColor(.82, .78, .84); center("Enter: new journey    C: return to checkpoint", 370, 21)
  elseif mode == "victory" then
    love.graphics.setColor(.65, .78, .9); center("CELIUM IS FREE", 220, 48)
    love.graphics.setColor(.85, .8, .9); center("Lord Celium is dead. The old shadows loosen their hold.", 315, 21)
    love.graphics.setColor(.65, .58, .7); center("Aren walks down the mountain toward the people he chose.", 355, 18)
    love.graphics.setColor(.85, .8, .9); center("Press Enter to play again", 450, 20)
  end
end

function Menu.pause(settings, selection)
  love.graphics.setColor(0, 0, 0, .72); love.graphics.rectangle("fill", 0, 0, 1280, 720)
  love.graphics.setColor(.9, .85, .95); center("PAUSED", 155, 42)
  local options = {
    "Resume",
    ("Master Volume    %d%%"):format(math.floor(settings.volume * 100 + .5)),
    ("SFX Volume       %d%%"):format(math.floor(settings.sfxVolume * 100 + .5)),
    "Mute             " .. (settings.muted and "ON" or "OFF"),
  }
  for index, label in ipairs(options) do
    love.graphics.setColor(index == selection and { .9, .72, .35 } or { .72, .68, .78 })
    center((index == selection and ">  " or "   ") .. label, 255 + index * 52, 21)
  end
  love.graphics.setColor(.52, .48, .58)
  center("Up/Down select  •  Left/Right adjust  •  Enter/A confirm  •  Esc/B resume", 535, 16)
end

return Menu
