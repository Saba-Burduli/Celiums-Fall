local Audio = { sounds = {} }

local function tone(frequency, duration, volume, wave)
  local rate, samples = 22050, math.floor(22050 * duration)
  local data = love.sound.newSoundData(samples, rate, 16, 1)
  for i = 0, samples - 1 do
    local t, fade = i / rate, 1 - i / samples
    local phase = t * frequency * math.pi * 2
    local value = wave == "square" and (math.sin(phase) >= 0 and 1 or -1) or math.sin(phase)
    data:setSample(i, value * fade * volume)
  end
  return love.audio.newSource(data, "static")
end

function Audio.load()
  Audio.sounds = {
    melee = tone(105, .09, .16, "square"), magic = tone(380, .16, .12), hit = tone(72, .1, .2, "square"),
    stone = tone(660, .3, .1), dash = tone(220, .08, .08), boss = tone(48, .45, .12, "square"), victory = tone(520, .7, .1),
  }
  return Audio
end

function Audio.play(name)
  local source = Audio.sounds[name]
  if source then source:stop(); source:play() end
end

return Audio

