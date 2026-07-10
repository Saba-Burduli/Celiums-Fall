.PHONY: run check build smoke

run:
	love .

check:
	./scripts/check.sh

build:
	./scripts/build.sh

smoke:
	love . --smoke
