.PHONY: run check build

run:
	love .

check:
	./scripts/check.sh

build:
	./scripts/build.sh
