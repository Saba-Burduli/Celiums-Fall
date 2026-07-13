local Storage = require("src.core.storage")
local Utils = require("src.core.utils")
local Settings = { volume = 0.7, sfxVolume = 0.8, muted = false }
local path = "settings.txt"
local order = { "volume", "sfx", "muted" }

function Settings.load()
  local values = Storage.read(path)
  if not values then return Settings end
  Settings.volume = Utils.clamp(tonumber(values.volume) or Settings.volume, 0, 1)
  Settings.sfxVolume = Utils.clamp(tonumber(values.sfx) or Settings.sfxVolume, 0, 1)
  Settings.muted = values.muted == "true"
  Settings.apply()
  return Settings
end

function Settings.save()
  Storage.write(path, {
    volume = ("%.1f"):format(Settings.volume),
    sfx = ("%.1f"):format(Settings.sfxVolume),
    muted = Settings.muted,
  }, order)
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
