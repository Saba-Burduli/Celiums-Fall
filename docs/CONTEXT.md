# Compressed Context

Celium's Fall is a compact top-down LÖVE action game targeting a 15-minute run. Aren crosses six rooms from the Cursed Forest to Celium's Summit, helps an Old Villager, recruits the sarcastic former faction occultist Sillius, kills the Mire Priest, and defeats Lord Celium. Original and curated CC0 16-bit sprite sets are hot-swappable.

## Current loop

Title → forest/moonstone quest → Forest Depths/Sillius patrol quest → unlock Chain Lightning and recruit Sillius → shrine/Mire Priest → crypt → mountain path → Lord Celium → victory. Checkpoints preserve area and progression.

## Module map

`core/state` owns lifecycle and transitions; `core/assets` owns the two sprite sets. Entities include player, six regular enemies, bosses, and Sillius. Systems own combat, AI, collisions, quests, and progression. World modules define six rooms/spawns. UI modules draw HUD/dialogue/screens. Data modules contain tuning definitions.

## Controls

WASD/left stick move; mouse/arrows/right stick aim; Space/B dash; J/left mouse/A melee; K/right mouse/X magic; L/right shoulder Chain Lightning after unlock; E/Y interact; Enter/Start begin; Esc/Start pause; C continues; V/M controls volume; F2 switches art sets.

## Known limitations

Rooms remain single-screen arenas with simple circle collision, fixed encounters, basic enemy separation, procedural-only audio, checkpoint rather than full world persistence, and short dialogue-only narrative scenes.

## Next recommended tasks

1. Playtest the complete 15-minute route and tune encounters.
2. Add enemy attack telegraphs and obstacle collision.
3. Expand boss introductions and the ending.
4. Produce platform-specific fused releases.

## Read these files for X

- Player/combat: `src/entities/player.lua`, `src/systems/combat.lua`
- Enemy behavior: `src/entities/enemy.lua`, `src/entities/boss.lua`, `src/systems/ai.lua`
- Sillius/chain spell: `src/entities/companion.lua`, `src/systems/combat.lua`
- Map/collision: `src/world/levels.lua`, `src/systems/collision.lua`
- Encounters: `src/world/spawner.lua`, `src/data/enemies.lua`, `src/data/bosses.lua`
- UI/dialogue: `src/ui/hud.lua`, `src/ui/dialogue.lua`, `src/ui/menu.lua`
- Asset switching: `src/core/assets.lua`, `CREDITS.md`
- State/transitions: `src/core/state.lua`
- Quest/upgrades: `src/systems/quests.lua`, `src/systems/progression.lua`, `src/data/quests.lua`, `src/data/items.lua`
