local Settings = { volume = 0.7, muted = false }
local path = "settings.txt"

function Settings.load()
  if not love.filesystem.getInfo(path) then return Settings end
  local raw = love.filesystem.read(path) or ""
  Settings.volume = tonumber(raw:match("volume=([%d.]+)")) or Settings.volume
  Settings.muted = raw:match("muted=true") ~= nil
  Settings.apply()
  return Settings
end

function Settings.save()
  love.filesystem.write(path, ("volume=%.1f\nmuted=%s\n"):format(Settings.volume, tostring(Settings.muted)))
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

return Settings

