local Fonts = {}
local cache = {}

local FONT_PATH = "assets/fonts/kenpixel-square.ttf"

function Fonts.get(size)
  if not cache[size] then
    cache[size] = love.graphics.newFont(FONT_PATH, size)
  end
  return cache[size]
end

return Fonts
