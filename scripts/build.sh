#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
mkdir -p dist
rm -f dist/celiums-fall.love
zip -q -r dist/celiums-fall.love main.lua conf.lua src assets README.md CREDITS.md -x '*.DS_Store'
echo "Built dist/celiums-fall.love"
