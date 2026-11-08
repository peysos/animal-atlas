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
3. **Bump the version badge by 0.1 only for major changes: new animal entries or taxonomic changes** (such as ranks or placement in the tree). Anything else, like colors, styling or interface tweaks, keeps the current version. Ask if it is unclear.
4. **Log every change in the changelog in both files:** a new section for a new version, otherwise a note in the current version's section.
5. **Keep both sites in full parity:** same taxa, titles, subtitles and ranks (the rebuild `$overrides` are intentional). Keep `alias{}` in sync too.
6. **After every change, verify both live pages** (HANDOFF §8): no console errors, 763 cards / 762 links, 0 overlaps, 0 lines crossing unrelated cards, one root, full title parity. The taxa count changes only if the user adds taxa.
7. **Ask before adding taxa,** because the user may want to specify placement.
8. **Avoid repetitive single-child chains** such as class > family > genus where each level has only one child (user preference since v4.1): connect the class straight to the genus instead.

## Git
This is a local repository with no remote. Never push or add a remote unless asked.
- After a new version passes verification, commit it as `vX.Y: short summary` and tag it `vX.Y`.
- For a change that keeps the current version, make a normal commit and move the tag with `git tag -f vX.Y`.
- Don't restore old versions or discard changes without asking.

## Keep the docs current
When versions, counts, rules or pipeline steps change, update `HANDOFF.md`.
