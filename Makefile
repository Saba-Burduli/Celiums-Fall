.PHONY: run check test build smoke

run:
	love .

check:
	./scripts/check.sh

test:
	lua tests/run.lua

build:
	./scripts/build.sh

smoke:
	love . --smoke
