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
3. **Follow [VERSIONING.md](VERSIONING.md)** (new user rule, 2026-11-12): bump +0.1 after five separate single-entry addition requests, or exactly once for a batch request. Supporting family/order nodes are not extra requested animals. Already-present entries and non-addition edits do not count. Explicit version requests take precedence. Update the persistent counter after every completed addition.
4. **Log every change in the changelog in both files:** a note in the current version's section, or a new section when the user asks for a new version.
5. **Keep both sites in full parity:** same taxa, titles, subtitles and ranks (the rebuild `$overrides` are intentional). Keep `alias{}` in sync too.
6. **After every change, verify both live pages** (HANDOFF §8): no console errors, 975 cards / 974 links, 0 overlaps, 0 lines crossing unrelated cards, one root, full title parity. The taxa count changes only if the user adds taxa.
7. **Ask before adding taxa,** because the user may want to specify placement.
8. **Avoid repetitive single-child chains** such as class > family > genus where each level has only one child (user preference since v4.1): connect the class straight to the genus instead. Exception: on 2026-11-12 the user requested missing families and orders; include verified ranks for that task even when a step has only one child.

## Git
The repository is on GitHub as `peysos/animal-atlas` (remote `origin`, branch `main`), published with GitHub Pages at https://peysos.github.io/animal-atlas/ (user request, 2026-11-11). The user gave standing authorization on 2026-11-12 to publish future verified project changes to GitHub and the live site. After making a requested change, verify both charts, commit the intended files, publish to origin/main, and check the GitHub Pages deployment. Do not ask for publication permission again for these requested changes; report any actual access or deployment failure. Check the remote head first and integrate concurrent changes without overwriting them; never force-push main. Commits use the private GitHub address `324647968+peysos@users.noreply.github.com` (set in this repo's git config) so the user's real email stays private; keep it that way.
- When VERSIONING.md calls for a new version, or the user explicitly requests one, and verification passes, commit it as `vX.Y: short summary` and tag it `vX.Y`.
- Every other change keeps the current version: make a normal commit and move the tag with `git tag -f vX.Y`.
- Don't restore old versions or discard changes without asking.

## Keep the docs current
When versions, counts, rules or pipeline steps change, update `HANDOFF.md`.
