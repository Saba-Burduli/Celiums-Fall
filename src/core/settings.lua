local Settings = { volume = 0.7, sfxVolume = 0.8, muted = false }
local path = "settings.txt"

function Settings.load()
  if not love.filesystem.getInfo(path) then return Settings end
  local raw = love.filesystem.read(path) or ""
  Settings.volume = tonumber(raw:match("volume=([%d.]+)")) or Settings.volume
  Settings.sfxVolume = tonumber(raw:match("sfx=([%d.]+)")) or Settings.sfxVolume
  Settings.muted = raw:match("muted=true") ~= nil
  Settings.apply()
  return Settings
end

function Settings.save()
  love.filesystem.write(path, ("volume=%.1f\nsfx=%.1f\nmuted=%s\n"):format(
    Settings.volume, Settings.sfxVolume, tostring(Settings.muted)))
end

function Settings.apply() love.audio.setVolume(Settings.muted and 0 or Settings.volume) end
function Settings.cycleVolume()
  Settings.volume = Settings.volume >= 1 and 0.2 or math.min(1, Settings.volume + 0.2)
  Settings.muted = false
  Settings.apply(); Settings.save()
end
function Settings.toggleMute()
  Settings.muted = not Settings.muted
  Settings.apply(); Settings.save()
end

local function adjust(value, amount) return math.max(0, math.min(1, value + amount)) end

function Settings.adjustMaster(amount)
  Settings.volume, Settings.muted = adjust(Settings.volume, amount), false
  Settings.apply(); Settings.save()
end

function Settings.adjustSfx(amount)
  Settings.sfxVolume = adjust(Settings.sfxVolume, amount)
  Settings.save()
end

return Settings
