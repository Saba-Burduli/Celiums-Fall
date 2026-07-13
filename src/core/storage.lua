local Storage = {}

function Storage.parse(raw)
  local values = {}
  for line in (raw or ""):gmatch("[^\r\n]+") do
    local key, value = line:match("^([^=]+)=(.*)$")
    if key then values[key] = value end
  end
  return values
end

function Storage.encode(values, order)
  local lines = {}
  for _, key in ipairs(order) do
    local value = values[key]
    if value ~= nil then lines[#lines + 1] = key .. "=" .. tostring(value) end
  end
  return table.concat(lines, "\n") .. "\n"
end

function Storage.read(path)
  if not love.filesystem.getInfo(path) then return nil end
  return Storage.parse(love.filesystem.read(path) or "")
end

function Storage.write(path, values, order)
  return love.filesystem.write(path, Storage.encode(values, order))
end

return Storage
