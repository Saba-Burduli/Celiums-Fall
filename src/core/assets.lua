local Assets = { current = "original", sets = {} }

local names = { "player", "shadow_thrall", "cursed_hound", "ash_cultist", "shielded_knight",
  "rift_witch", "winged_curse", "sillius", "mire_priest", "lord_celium", "stone", "villager" }

local curatedTiles = {
  player = { 0, 6 }, shadow_thrall = { 0, 7 }, cursed_hound = { 0, 10 }, ash_cultist = { 3, 6 },
  shielded_knight = { 1, 7 }, rift_witch = { 0, 8 }, winged_curse = { 1, 10 }, sillius = { 2, 6 },
  mire_priest = { 0, 9 }, lord_celium = { 2, 8 }, stone = { 4, 7 }, villager = { 1, 8 },
}

local function buildSet(path, coordinates)
  local image = love.graphics.newImage(path)
  image:setFilter("nearest", "nearest")
  local set = { image = image, quads = {} }
  for index, name in ipairs(names) do
    local col, row
    if coordinates then col, row = coordinates[name][1], coordinates[name][2]
    else col, row = index - 1, 0 end
    set.quads[name] = love.graphics.newQuad(col * 16, row * 16, 16, 16, image:getDimensions())
  end
  return set
end

function Assets.load()
  Assets.sets.original = buildSet("assets/original/celium-sprites.png")
  Assets.sets.curated = buildSet("assets/curated/tiny-dungeon.png", curatedTiles)
end

function Assets.toggle()
  Assets.current = Assets.current == "original" and "curated" or "original"
  return Assets.current
end

function Assets.draw(name, x, y, scale, flash)
  local set = Assets.sets[Assets.current]
  if not set or not set.quads[name] then return false end
  scale = scale or 2
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(set.image, set.quads[name], math.floor(x), math.floor(y), 0, scale, scale, 8, 8)
  if flash and flash > 0 then
    love.graphics.setColor(1, 1, 1, math.min(1, flash * 7))
    love.graphics.rectangle("line", math.floor(x - 8 * scale), math.floor(y - 8 * scale), 16 * scale, 16 * scale)
  end
  return true
end

return Assets

