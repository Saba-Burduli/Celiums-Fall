# Celium's Fall

A small top-down dark fantasy action-adventure built with LÖVE. Aren, a former occult servant, turns corrupted magic against Lord Celium and the faction hunting him. This repository contains an asset-free playable vertical slice built from primitive graphics.

## Install and run

Install LÖVE 11.4+ from [love2d.org](https://love2d.org/) or with your system package manager. Then run:

```sh
make run
# Fallback: ./scripts/run.sh
# Direct: love .
```

No external assets or Lua packages are required. To publish later, add a remote with `git remote add origin <url>` and push the `main` branch.

## Controls

- WASD: move
- Mouse or arrow keys: aim
- J / left mouse: melee
- K / right mouse: magic projectile
- L / right shoulder: chain lightning after Sillius unlocks it
- Space: dash
- E: interact / collect
- Enter: start / confirm / restart
- Esc: pause
- C on title: continue saved checkpoint
- V / M while paused: cycle volume / mute
- F2: switch instantly between original and curated 16-bit pixel-art sets
- Gamepad: left stick move, right stick aim, A melee, X magic, B dash, Y interact, Start pause

## MVP features

- Title, play, pause, death, restart, and victory states
- Three connected areas: Cursed Forest, Ruined Shrine, Black Mountain
- Six rooms across the forest, shrine, and mountain route
- Aren movement, dash, melee, magic, health, and mana
- Three regular enemies and two bosses with distinct behaviors
- Shielded Knight, Rift Witch, and Winged Curse enemy archetypes
- Four permanent stone upgrades and a moonstone side quest
- HUD, dialogue prompts, boss health bar, particles, hit flashes, and camera shake
- Generated primitive art; no missing asset dependency
- Procedural sound effects, persisted settings/checkpoints, and gamepad controls
- Sillius ally quest, temporary companion combat, and chain-lightning unlock
- Two hot-swappable 16-bit pixel-art sets: original Celium sprites and Kenney Tiny Dungeon CC0 assets

## Build

Create a portable LÖVE archive with `make build`. The result is `dist/celiums-fall.love` and can be opened by LÖVE on macOS, Windows, or Linux.

## Roadmap

Next priorities are audio, map readability, combat tuning, save data, richer dialogue, accessibility options, gamepad support, and packaged builds. See [`docs/ROADMAP.md`](docs/ROADMAP.md).

## Validation

Run `make check` or `./scripts/check.sh`. The check uses `luac` or `lua` when available and otherwise verifies required files.
Run `make smoke` with LÖVE installed to load both asset sets and exercise every room plus the new progression systems.
