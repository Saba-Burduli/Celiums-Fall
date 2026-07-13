# Architecture

The project uses dependency-free Lua modules with narrow ownership. `main.lua` forwards LÖVE callbacks to `core/state` and runs the standalone smoke test when requested.

- `src/core`: app state, session construction, normalized actions, configuration, persistence, camera, audio, assets, and shared helpers
- `src/entities`: actor construction and entity-local behavior
- `src/systems`: combat, navigation execution, world progression, collision, platforms, and other cross-entity rules
- `src/world`: level definitions, runtime encounter construction, and validation
- `src/ui`: world and interface rendering
- `src/data`: declarative encounters, lore, quests, and tuning tables
- `tests`: dependency-free unit harness and the LÖVE integration smoke test

`core/state` owns application modes and callback dispatch. `core/actions` converts keyboard, controller, and mouse input into device-independent actions. `core/game_session` creates or restores a run and enters rooms. `systems/world_flow` owns objectives, interactions, transitions, and win/death outcomes. `ui/world_renderer` owns gameplay draw order.

`core/config` is the source of truth for world, render, physics, and navigation constants. `core/storage` provides deterministic key-value encoding and filesystem access; `core/save` and `core/settings` define their own compatible schemas on top of it. Checkpoint version 1 and legacy settings remain readable.

`data/encounters` declares room content, while `world/spawner` turns those declarations into runtime entities. `world/validator` checks level and encounter references without owning construction.

`systems/platforms` gives platforms stable IDs and movement envelopes. `systems/collision` owns gravity, support tracking, selective one-way ignores, and solid-wall blocking. `systems/navigation_graph` builds walkable spans and validated edges and runs A*. `systems/navigation` only plans and executes actor routes. Bosses and flying or teleporting archetypes bypass grounded navigation.

`core/assets` exposes semantic drawing operations over the GothicVania and fallback art. `core/camera` renders at 640×360 before nearest-neighbor scaling. `ui/fonts` caches the shared pixel font. `data/lore` owns story copy, while `ui/cinematic` owns its presentation and page state.

Run `make check` for syntax and unit coverage, `make smoke` for integration coverage, and `make build` followed by `unzip -t dist/celiums-fall.love` for package integrity. CI runs all four checks headlessly.
