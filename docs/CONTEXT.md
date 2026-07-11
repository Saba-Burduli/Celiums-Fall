# Compressed Context

Celium's Fall is a compact side-view dark fantasy action-platformer targeting a 15-minute run. Aren crosses six platform panels from the Cursed Forest to Celium's Summit, helps an Old Villager, recruits Sillius, kills the Mire Priest, and defeats Lord Celium. The whole frame renders at 640×360 with GothicVania CC0 pixel art and nearest-neighbor scaling.

## Current loop

Title → forest/moonstone quest → Forest Depths/Sillius patrol quest → unlock Chain Lightning and recruit Sillius → shrine/Mire Priest → crypt → mountain path → Lord Celium → victory. Checkpoints preserve area and progression.

## Module map

`core/state` owns lifecycle and panel transitions; `core/camera` owns the low-resolution canvas; `core/assets` owns Gothic animation/environment assets and fallbacks. `systems/platforms` creates stable runtime platforms and movement envelopes; `systems/collision` handles support tracking, one-way landings/drop-through, and solid walls; `systems/navigation` builds room-local platform graphs and A* routes for grounded enemies. Entities include player, six regular enemies, animated bosses, and animated Sillius. World modules define six platform layouts and spawns.

## Controls

A/D or left stick move; W/Up/Space or gamepad A jump; S/Down + jump or left stick down + A drops through one-way ledges; Shift/B dash; mouse/arrows/right stick aim; J/left mouse/X melee; K/right mouse/Y magic; L/right shoulder Chain Lightning; E/left shoulder interact; Enter/Start begin; Esc/Start pause; C continues; V/M controls volume.

## Known limitations

Platforms do not support slopes. Moving platforms use fixed sine paths, encounters remain fixed, navigation uses compact per-room graphs rather than a navmesh, audio is procedural, and persistence is checkpoint-based.

## Next recommended tasks

1. Manually playtest moving-platform timing, wall placement, and airborne encounters across the full route.
2. Tune grounded-enemy launch points and moving-platform waits from manual playtests.
3. Add authored ambient music and platform-specific releases.

## Read these files for X

- Player/combat: `src/entities/player.lua`, `src/systems/combat.lua`
- Enemy behavior: `src/entities/enemy.lua`, `src/entities/boss.lua`, `src/systems/ai.lua`
- Sillius/chain spell: `src/entities/companion.lua`, `src/systems/combat.lua`
- Map/collision: `src/world/levels.lua`, `src/systems/platforms.lua`, `src/systems/collision.lua`
- Encounters: `src/world/spawner.lua`, `src/data/enemies.lua`, `src/data/bosses.lua`
- UI/dialogue: `src/ui/hud.lua`, `src/ui/dialogue.lua`, `src/ui/menu.lua`
- Asset switching: `src/core/assets.lua`, `CREDITS.md`
- State/transitions: `src/core/state.lua`
- Quest/upgrades: `src/systems/quests.lua`, `src/systems/progression.lua`, `src/data/quests.lua`, `src/data/items.lua`
