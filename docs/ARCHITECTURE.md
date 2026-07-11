# Architecture

The project uses small table-returning modules and one controlled state object. `main.lua` only forwards LÖVE callbacks to `src/core/state.lua`.

- `src/core`: lifecycle, input, camera, shared math helpers
- `src/entities`: constructors and entity-local update/draw behavior
- `src/systems`: rules spanning multiple entities
- `src/world`: static level definitions and encounter construction
- `src/ui`: presentation with no gameplay ownership
- `src/data`: declarative tuning tables

Dependencies flow from state → world/entities/systems/UI → data/core helpers. Data never imports gameplay modules. Systems should not own rendering. No ECS or external library is planned for the MVP.

`core/save` persists a small versioned checkpoint through `love.filesystem`; `core/settings` owns persisted audio preferences; `core/audio` generates short sound effects in memory. None requires bundled assets.

`core/assets` loads GothicVania environment pieces, frame sequences, enemies, spell effects, and fallback sheets behind semantic draw calls. `core/camera` renders the full game to a 640×360 canvas before nearest-neighbor scaling. `systems/platforms` gives runtime platforms stable IDs and movement envelopes, animates them, and carries supported actors. `systems/collision` applies gravity, support tracking, selective one-way ignores, and axis-aligned wall blocking. `systems/navigation` splits walkable spans around walls, connects validated jump/drop/boarding transitions, runs A*, and executes routes for grounded regular enemies; bosses and flying/teleporting archetypes bypass it.
