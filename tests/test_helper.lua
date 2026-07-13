local Helper = { count = 0 }

function Helper.test(name, callback)
  local ok, err = xpcall(callback, debug.traceback)
  if not ok then error(("Test failed: %s\n%s"):format(name, err), 0) end
  Helper.count = Helper.count + 1
end

function Helper.equal(actual, expected, message)
  if actual ~= expected then
    error((message or "values differ") .. (": expected %s, got %s"):format(tostring(expected), tostring(actual)), 2)
  end
end

function Helper.near(actual, expected, tolerance, message)
  if math.abs(actual - expected) > tolerance then
    error((message or "values are not near") .. (": expected %s +/- %s, got %s"):format(
      tostring(expected), tostring(tolerance), tostring(actual)), 2)
  end
end

return Helper
