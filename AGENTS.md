# Animal Atlas project instructions

Read CLAUDE.md and HANDOFF.md before changing the chart. They define the data source, rebuild pipeline, rank colors, version rules, and verification requirements.

## Publishing requested changes

The user gave standing authorization on 2026-11-12: when adding or changing the site, publish the verified result to https://github.com/peysos/animal-atlas and its GitHub Pages site at https://peysos.github.io/animal-atlas/.

- Keep both chart views, search aliases, and changelogs in sync. Rebuild the card chart from the D3 source after data changes.
- Keep the current version unless the user requests a new one.
- Before publishing, inspect the current remote main head and preserve concurrent work. Verify the requested change, then commit and publish the intended files to main. Never force-push main.
- Follow the version-tag rules in CLAUDE.md. If an existing published version tag must move, update only that tag with a lease against its observed remote SHA.
- Check the GitHub Pages deployment for the published commit and report success or the actual failure. Do not claim the live site updated merely because a push succeeded.
- This is permission to publish future requested, verified project changes; do not ask for the same publication permission again. Report actual access failures or deployment blockers.
- Preserve the repository's private noreply Git author email. Never publish credentials or temporary layout exports.
