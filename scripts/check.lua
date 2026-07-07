local pipe = assert(io.popen("find . -path './.git' -prune -o -name '*.lua' -type f -print"))
for file in pipe:lines() do
  local chunk, err = loadfile(file)
  assert(chunk, err)
end
assert(pipe:close())
print("Lua syntax check passed.")

