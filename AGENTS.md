# AGENTS.md

This repository is optimized for low-token, agent-driven development.

Before editing, read only:

1. `docs/CONTEXT.md`
2. `docs/TASKS.md`
3. The specific source files related to the requested task

Rules:

- Do not scan the whole repository unless absolutely necessary.
- Keep files small and focused; prefer changing one system at a time.
- Update `docs/CHANGELOG.md` after meaningful changes.
- Update `docs/TASKS.md` when completing or adding tasks.
- Add short comments only where logic is non-obvious.
- Do not duplicate lore or architecture explanations across files.
- Use `docs/CONTEXT.md` as the compressed source of truth.
- Use `docs/ARCHITECTURE.md` for module boundaries.
- Use `docs/GAME_DESIGN.md` for gameplay and lore rules.
- For a new feature, identify the smallest relevant module first.
- Avoid broad rewrites and dependencies unless clearly justified.
- Preserve the MVP loop unless the task explicitly changes it.
- Run `make check` after Lua edits. Run the game when LÖVE is available.

