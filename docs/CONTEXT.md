# Compressed Context

Celium's Fall is an asset-free top-down LÖVE action game. Aren, a former witch and occult servant, crosses a cursed forest, kills the Mire Priest, enters Black Mountain, and defeats Lord Celium while helping an Old Villager recover a moonstone.

## Current loop

Title → explore forest and fight → collect upgrades / complete moonstone quest → enter shrine → defeat Mire Priest → enter mountain → defeat Lord Celium → victory. Death restarts the run.

## Module map

`core/state` owns the controlled game state and callbacks; `core/input` and `camera` provide direction/view helpers. Entities own local data and updates. Systems own combat, AI, collisions, quests, and progression. World modules define areas/spawns. UI modules draw HUD/dialogue/screens. Data modules contain definitions only.

## Controls

WASD move; mouse/arrows aim; Space dash; J/left mouse melee; K/right mouse magic; E interact; Enter start/restart; Esc pause.

## Known limitations

One handcrafted room per area, no saves/audio/gamepad, simple circle collision, fixed encounters, basic enemy separation, and minimal narrative text.

## Next recommended tasks

1. Playtest and tune boss damage/cooldowns.
2. Add generated audio and volume controls.
3. Add save/checkpoint support.
4. Add gamepad bindings and accessibility options.

## Read these files for X

- Player/combat: `src/entities/player.lua`, `src/systems/combat.lua`
- Enemy behavior: `src/entities/enemy.lua`, `src/entities/boss.lua`, `src/systems/ai.lua`
- Map/collision: `src/world/levels.lua`, `src/systems/collision.lua`
- Encounters: `src/world/spawner.lua`, `src/data/enemies.lua`, `src/data/bosses.lua`
- UI/dialogue: `src/ui/hud.lua`, `src/ui/dialogue.lua`, `src/ui/menu.lua`
- State/transitions: `src/core/state.lua`
- Quest/upgrades: `src/systems/quests.lua`, `src/systems/progression.lua`, `src/data/quests.lua`, `src/data/items.lua`

