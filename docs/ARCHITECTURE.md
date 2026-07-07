# Architecture

The project uses small table-returning modules and one controlled state object. `main.lua` only forwards LÖVE callbacks to `src/core/state.lua`.

- `src/core`: lifecycle, input, camera, shared math helpers
- `src/entities`: constructors and entity-local update/draw behavior
- `src/systems`: rules spanning multiple entities
- `src/world`: static level definitions and encounter construction
- `src/ui`: presentation with no gameplay ownership
- `src/data`: declarative tuning tables

Dependencies flow from state → world/entities/systems/UI → data/core helpers. Data never imports gameplay modules. Systems should not own rendering. No ECS or external library is planned for the MVP.

