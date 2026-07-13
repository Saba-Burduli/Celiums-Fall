local Helper = require("tests.test_helper")
local Storage = require("src.core.storage")

Helper.test("storage parses key-value lines and preserves equals signs", function()
  local values = Storage.parse("version=1\nname=Celium=Fall\nempty=\n")
  Helper.equal(values.version, "1")
  Helper.equal(values.name, "Celium=Fall")
  Helper.equal(values.empty, "")
end)

Helper.test("storage encoding follows its explicit field order", function()
  local encoded = Storage.encode({ muted = false, volume = ".7" }, { "volume", "muted" })
  Helper.equal(encoded, "volume=.7\nmuted=false\n")
end)

Helper.test("version-one checkpoints retain their wire format", function()
  local files = { ["checkpoint.txt"] = "version=1\narea=forest\nhp=120\nstones=moon,blood\n" }
  local previousLove = love
  love = { filesystem = {
    getInfo = function(path) return files[path] and {} or nil end,
    read = function(path) return files[path] end,
    write = function(path, value) files[path] = value; return true end,
    remove = function(path) files[path] = nil; return true end,
  } }
  package.loaded["src.core.save"] = nil
  local Save = require("src.core.save")
  local values = Save.read()
  Helper.equal(values.version, "1")
  Helper.equal(values.area, "forest")
  Helper.equal(values.stones, "moon,blood")
  love = previousLove
end)

Helper.test("legacy settings load without an sfx field", function()
  local files = { ["settings.txt"] = "volume=0.5\nmuted=true\n" }
  local applied
  local previousLove = love
  love = {
    filesystem = {
      getInfo = function(path) return files[path] and {} or nil end,
      read = function(path) return files[path] end,
      write = function(path, value) files[path] = value; return true end,
    },
    audio = { setVolume = function(value) applied = value end },
  }
  package.loaded["src.core.settings"] = nil
  local Settings = require("src.core.settings")
  Settings.load()
  Helper.equal(Settings.volume, .5)
  Helper.equal(Settings.sfxVolume, .8)
  Helper.equal(Settings.muted, true)
  Helper.equal(applied, 0)
  love = previousLove
end)
