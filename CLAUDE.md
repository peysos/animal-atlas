# Animal Atlas

Two synced single-file websites showing an evolutionary tree of animal life. No build step.

**Read [HANDOFF.md](HANDOFF.md) before changing anything.** It has the data format, rebuild pipeline, color system, verification snippets and known pitfalls.

The user is new to Claude Code, so explain things in plain language.

## Files
- `full-animal-tree.html`: D3 site at `http://localhost:8080/full`. **Source of truth for all data.**
- `animal-evolution-tree.html`: card site at `http://localhost:8080/`. Its `D` array is generated, so never hand-edit it.
- `tools\`: build and server scripts. `tools\serve-animal-atlas.ps1` runs the 8080 server.

## Rules
1. **Never remove taxa** without explicit consent. Every node keeps a parent, and LUCA is the only root.
2. **Change data only in `S` in `full-animal-tree.html`**, then run the rebuild pipeline (HANDOFF §4).
3. **Never bump the version badge unless the user says so** (user rule since 2026-11-08). New animals, taxonomic changes, styling and everything else keep the current version until the user asks for a new one.
4. **Log every change in the changelog in both files:** a note in the current version's section, or a new section when the user asks for a new version.
5. **Keep both sites in full parity:** same taxa, titles, subtitles and ranks (the rebuild `$overrides` are intentional). Keep `alias{}` in sync too.
6. **After every change, verify both live pages** (HANDOFF §8): no console errors, 812 cards / 811 links, 0 overlaps, 0 lines crossing unrelated cards, one root, full title parity. The taxa count changes only if the user adds taxa.
7. **Ask before adding taxa,** because the user may want to specify placement.
8. **Avoid repetitive single-child chains** such as class > family > genus where each level has only one child (user preference since v4.1): connect the class straight to the genus instead.

## Git
This is a local repository with no remote. Never push or add a remote unless asked.
- When the user asks for a new version and it passes verification, commit it as `vX.Y: short summary` and tag it `vX.Y`.
- Every other change keeps the current version: make a normal commit and move the tag with `git tag -f vX.Y`.
- Don't restore old versions or discard changes without asking.

## Keep the docs current
When versions, counts, rules or pipeline steps change, update `HANDOFF.md`.
