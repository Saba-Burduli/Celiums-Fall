local Actions = {}

local function menuKey(key)
  local mapping = {
    up = "menu_up", w = "menu_up",
    down = "menu_down", s = "menu_down",
    left = "menu_decrease", a = "menu_decrease",
    right = "menu_increase", d = "menu_increase",
    ["return"] = "menu_confirm", space = "menu_confirm",
    v = "volume_cycle", m = "mute_toggle",
  }
  return mapping[key]
end

function Actions.key(key, mode, cinematic)
  if key == "return" and (mode == "title" or mode == "dead" or mode == "victory") then
    return "new_game"
  end
  if key == "c" and (mode == "title" or mode == "dead") then return "continue" end
  if mode == "playing" and cinematic then
    if key == "return" or key == "space" or key == "e" then return "cinematic_advance" end
    return nil
  end
  if key == "escape" and (mode == "playing" or mode == "paused") then return "pause_toggle" end
  if mode == "paused" then return menuKey(key) end
  if mode ~= "playing" then return nil end

  if key == "space" or key == "w" or key == "up" then return "jump" end
  if key == "lshift" or key == "rshift" then return "dash" end
  if key == "j" then return "melee" end
  if key == "k" then return "magic" end
  if key == "l" then return "chain_lightning" end
  if key == "e" then return "interact" end
end

function Actions.gamepad(button, mode, cinematic)
  if mode == "playing" and cinematic then
    if button == "a" or button == "start" then return "cinematic_advance" end
    return nil
  end
  if button == "start" then
    if mode == "title" or mode == "dead" or mode == "victory" then return "new_game" end
    if mode == "playing" or mode == "paused" then return "pause_toggle" end
  end
  if mode == "paused" then
    local mapping = {
      dpup = "menu_up", dpdown = "menu_down", dpleft = "menu_decrease",
      dpright = "menu_increase", a = "menu_confirm", b = "pause_resume",
    }
    return mapping[button]
  end
  if mode ~= "playing" then return nil end

  local mapping = {
    a = "jump", x = "melee", y = "magic", rightshoulder = "chain_lightning",
    b = "dash", leftshoulder = "interact",
  }
  return mapping[button]
end

function Actions.mouse(button, mode)
  if mode ~= "playing" then return nil end
  if button == 1 then return "melee" end
  if button == 2 then return "magic" end
end

return Actions
