#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
if command -v luac >/dev/null 2>&1; then
  find . -path './.git' -prune -o -name '*.lua' -type f -print | sort | while IFS= read -r file; do
    luac -p "$file"
  done
  echo "Lua syntax check passed."
elif command -v lua >/dev/null 2>&1; then
  lua scripts/check.lua
else
  echo "No Lua interpreter found; checked required files only."
  for file in main.lua conf.lua docs/CONTEXT.md docs/TASKS.md; do test -f "$file"; done
fi

