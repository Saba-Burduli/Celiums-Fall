# Compressed Context

Celium's Fall is an asset-free top-down LÖVE action game. Aren, a former witch and occult servant, crosses a cursed forest, kills the Mire Priest, enters Black Mountain, and defeats Lord Celium while helping an Old Villager recover a moonstone.

## Current loop

Title → explore forest and fight → collect upgrades / complete moonstone quest → enter shrine → defeat Mire Priest → enter mountain → defeat Lord Celium → victory. Death restarts the run.

## Module map

`core/state` owns the controlled game state and callbacks; `core/input` and `camera` provide direction/view helpers. Entities own local data and updates. Systems own combat, AI, collisions, quests, and progression. World modules define areas/spawns. UI modules draw HUD/dialogue/screens. Data modules contain definitions only.

## Controls

WASD/left stick move; mouse/arrows/right stick aim; Space/B dash; J/left mouse/A melee; K/right mouse/X magic; E/Y interact; Enter/Start begin; Esc/Start pause; C continues a checkpoint; V/M controls volume while paused.

## Known limitations

One handcrafted room per area, simple circle collision, fixed encounters, basic enemy separation, procedural-only audio, checkpoint rather than full world persistence, and minimal narrative text.

## Next recommended tasks

1. Playtest full boss encounters and tune damage/cooldowns.
2. Add another room or environmental hazard per area.
3. Expand villager and boss narrative beats.
4. Produce platform-specific fused releases.

## Read these files for X

- Player/combat: `src/entities/player.lua`, `src/systems/combat.lua`
- Enemy behavior: `src/entities/enemy.lua`, `src/entities/boss.lua`, `src/systems/ai.lua`
- Map/collision: `src/world/levels.lua`, `src/systems/collision.lua`
- Encounters: `src/world/spawner.lua`, `src/data/enemies.lua`, `src/data/bosses.lua`
- UI/dialogue: `src/ui/hud.lua`, `src/ui/dialogue.lua`, `src/ui/menu.lua`
- State/transitions: `src/core/state.lua`
- Quest/upgrades: `src/systems/quests.lua`, `src/systems/progression.lua`, `src/data/quests.lua`, `src/data/items.lua`
