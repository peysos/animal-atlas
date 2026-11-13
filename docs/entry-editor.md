# Entry editor test

Click or tap an entry box to select it (white glow), then click or tap that selected box again to open its information window. There is no time limit between the clicks. Write your text, choose **Add images**, optionally enter a caption or image credit, and press **Save**. The editor accepts JPG, PNG, WebP and AVIF files, up to 12 images per entry and 15 MB per source image. Images are resized to a maximum of 1600 pixels and stored as WebP.

Save keeps your work in **this browser profile, on this device, for this site address**. It does not send your writing or images to GitHub. The card and D3 views share saved entries when opened from the same site. Localhost, local files, the live GitHub Pages site, different browsers and different devices have separate storage. Clearing browser site data or using a temporary/private session can remove saved work.

Use **Download backup** regularly. The JSON download includes all entries saved in that browser plus the current entry's draft and its images. Keep the file somewhere you can find it. **Restore backup** imports that file into another browser or restores lost work; matching saved entries are replaced only after confirmation. Backups currently support files up to 150 MB; images are optimized before saving. If browser storage is unavailable, the editor can still download the current draft, and it explicitly reports that this is a single-entry backup.

**Copy name** is in the information window. A click/tap selects an entry; clicking/tapping that selected entry opens its window. Selecting a different entry starts with selection again. It replaces the old double-tap copying gesture. Navigation arrows continue to navigate without opening the editor. Enter or Space opens a focused entry, Escape closes it, and Ctrl/Cmd+S saves while the editor is open. Closing with unsaved changes asks before discarding them.

Click or tap an image to open a larger, screen-fitting view with its caption. Close that view with the Close button, Escape, or a click outside it. The entry remains open and unsaved writing is preserved. This works in both editing and read-only modes.

## When the content is ready

Download a fresh backup and provide it for publication. The text and images must first be preserved in the site's published content. After verifying that published content, set `editingEnabled: false` in `entry-content.js`. Both chart views then open a read-only information window with the published text, images and captions; Save, upload, backup and restore controls are hidden. Editing remains enabled for the current test.

Never turn off editing before obtaining and preserving the user's latest backup. Never replace user content with test fixtures. The test suite uses isolated browser contexts and publishes no sample notes or images.

## Implementation notes

- `entry-editor.js` is shared by both views. Native `dialog`, scoped CSS and theme variables keep the existing chart layout intact. The chart's click handler calls `AnimalAtlasEntries.activate(scientificName, subtitle, wasSelected)` with selection state captured before updating the highlight. An already-selected entry opens without any timing requirement. Keyboard activation and the programmatic `open` method open immediately.
- `entry-content.js` is the future published content store/configuration, currently with an empty `entries` object. Published records use the same format as backup records.
- IndexedDB database `animal-atlas-entries`, object store `entries`, holds records `{name, text, images: [{data, caption}], updatedAt}`. Images are data URLs. Canonical scientific names are keys; `Animalia / Metazoa` maps to `Animalia` so both chart views share that entry. Renaming a taxon in future requires retaining or migrating its saved key.
- Editing mode displays the browser's local record, falling back to published content. Read-only mode uses published content and ignores private local drafts.
- A save compares the loaded record's timestamp with the currently stored one inside the same write transaction. Conflicting tabs produce an error instead of silently overwriting saved work. Failed saves retain the draft and keep backup download available.
- Backups are versioned (`format: animal-atlas-entry-backup`, `schemaVersion: 1`) and validated before one atomic import transaction. User text/captions are rendered as text, never HTML; imported image data must be a JPEG, PNG or WebP data URL.
- The rebuild pipeline preserves the editor includes and handlers. No taxonomy data or coordinates were changed for this feature. The version remains v5.7 and the single-entry addition counter remains 0/5.

## Verification

`tools/verify-entry-editor.cjs` requires Playwright. Run it with Node and set `ATLAS_CHROME_PATH` if using an installed Chrome executable. Set `ATLAS_D3_PATH` to a local D3 bundle for offline verification, or allow the page's existing CDN dependency. The test routes site files from this repository to an isolated test origin and does not modify repository files or user browser data.

Checks cover single-click highlighting, clicking selected entries after a delay, changing selection, enlarged images on desktop/phone/read-only views, actual chart activation in both views, text and image saving, captions, reloads, shared records, conflicting tabs, unsaved-close protection, backup download/restoration in a fresh browser, narrow phone layout, image removal, independent entries, invalid imports, read-only publication, safe plain-text rendering and backup recovery when browser storage fails.
