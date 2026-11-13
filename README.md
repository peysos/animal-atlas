# Animal Atlas

An interactive evolutionary tree of animal life: over 900 living and extinct animals and groups, from sponges and trilobites to whales, dinosaurs and birds, showing how they are all related.

**Live site:** https://peysos.github.io/animal-atlas/

- **Card view** ([animal-evolution-tree.html](animal-evolution-tree.html)): rank-colored cards you can pan, zoom and search.
- **Full tree** ([full-animal-tree.html](full-animal-tree.html), also at `/full/`): the same tree drawn with D3.

Features include search by scientific or common name, a scrolling bar of every order and family, highlight filters (by rank, extinct only, living only, key evolutionary steps), several themes including Fossil and T. rex, double-tap to copy a name, and full phone support (pinch to zoom).

Both pages are plain HTML files with shared entry-editor assets and no build step. `full-animal-tree.html` holds the data; `HANDOFF.md` explains the data format and the rebuild pipeline in `tools/`.

## Write your own entry information

Double-click or double-tap an entry to open the test editor, write text, add images and captions, then Save. Work is stored only in your current browser; it is not automatically published. Download a backup regularly so it can be restored or used to publish the finished content. [Editor guide](docs/entry-editor.md).
