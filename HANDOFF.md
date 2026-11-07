# HANDOFF — Animal Atlas Evolution Tree

**Date of handoff:** 2026-11-06 · **Current version: v4.1**

## 1. Where the project is

```
C:\Users\pkepe\OneDrive\Desktop\My computer\vibecode\Animal Atlas\
```

| File | What it is |
|---|---|
| `animal-evolution-tree.html` | **Card site** ("Animal Atlas") — flat card tree served at `http://localhost:8080/` |
| `full-animal-tree.html` | **D3 site** — zoomable d3 tree served at `http://localhost:8080/full` · **SOURCE OF TRUTH for all data** |
| `favicon.svg` | site icon |
| `tools\` | All build/verify PowerShell scripts (copied out of temp — treat these as the canonical copies) |
| `backups\` | `*-v2.7.html` snapshot of both sites taken 2026-11-06 **before** the v2.8 color work |
| `HANDOFF.md` | This file |

The files are plain single-file HTML (no build step, no dependencies except d3 from a CDN on the full page). Everything lives in one `<script>` inside each file.

## 2. What the project is

Two synced interactive evolutionary-tree sites of animal life (plus context nodes for LUCA/Bacteria/Archaea/Eukaryota/Plantae/Fungi):

- **Card site**: absolutely-positioned HTML cards + SVG elbow-path connectors (down → across the row gap → down, routed at `m=(p[4]+n[4])/2`). Search box with autocomplete (scientific names + rank word; common names via an alias map).
- **D3 site**: `d3.stratify` + bezier links, `.n` nodes as `rect`s, same data, same search.

**662 taxa / 661 links. Every entry must stay: never remove taxa, every node keeps a parent, exactly one root (LUCA).**

## 3. Data model

### full-animal-tree.html (source of truth)
```js
const S=`id|parentId|Title|subtitle|kind|accent;...`
  .split(';').map(x=>{let[id,parentId,title,subtitle,kind,accent]=x.split('|');
  return{id,parentId:parentId||null,title,subtitle,kind,accent:accent||''}})
```
- Rows are `;`-separated, `|`-separated fields. **`accent` is optional** (empty for most rows).
- **Careful:** the row text contains a literal **`†` (U+2020)** in the label-prefix code (`?'+ '...` renders as `?'†'`), and the template literal's **last row has NO trailing `;`** — its closing backtick abuts the last row. Don't append/replace blindly at the end; the Erinaceidae incident came from gluing the backtick onto its kind (`familyfamily`).

### animal-evolution-tree.html (generated)
```js
const D=[['Title','subtitle','kind',x,y,parentIndex],   // normal row
         ['Title','subtitle','kind',x,y,parentIndex,'a-ext']] // accent row (optional 7th el)
```
- `x,y` = card centers (world px), `parentIndex` = index into D or `null`.
- The whole `D` array (and world size, and the `kindName`/CSS if ranks changed) is **regenerated** from the D3 file by `tools\rebuild-manual-full.ps1`. NEVER hand-edit `D` — edit `S` in full-animal-tree.html, then run the pipeline (§4).
- The card file's hand-maintained parts: header/badge, CSS (colors), `alias{}` map, changelog `<div id="chg">`, and the small JS tweaks noted below.

## 4. The rebuild pipeline (after ANY data change in full-animal-tree.html)

```powershell
# 1. start the positions export server (from the project dir, background)
powershell -NoProfile -ExecutionPolicy Bypass -File tools\serve-positions.ps1
# 2. browser: open http://localhost:8766/full-animal-tree.html, then evaluate:
#    (function exports layout + writes positions.json)
// fetch('/positions', {method:'POST', headers:{'Content-Type':'application/json'},
//   body: JSON.stringify(r.descendants().map(d=>({id:d.data.id,title:d.data.title,x:d.x,y:-d.y})))})
# 3. generate the card file
powershell -NoProfile -ExecutionPolicy Bypass -File tools\rebuild-manual-full.ps1
#    → must print: Manual nodes: 662 · Bad parent indices: 0 · Overlapping card pairs: 0
#      Only in manual: 0 · Only in D3: 0 · World: 32779 x 4100 · Root: LUCA parent=null
# 4. cleanup (kills servers, DELETES positions.json)
powershell -NoProfile -ExecutionPolicy Bypass -File tools\stop-animaltree-servers.ps1
```
Notes:
- The D3 layout x/y doesn't depend on kind/accent, so if you only changed `kind`/`subtitle`/`accent` you may reuse a freshly exported positions.json from the same session; otherwise export fresh.
- `serve-animal-atlas.ps1` is the 8080 static server for day-to-day viewing.

## 5. User rules (non-negotiable)

1. **Never remove taxa.** Every entry stays connected; no orphans; one root.
2. **Version badge** (`#ver` button in the header) bumps **+0.1 only for major changes: new animal entries or taxonomic changes** (user rule since v3.2) → currently **v4.1**; next bump = **v4.2**. Anything else (colors, styling, interface tweaks) keeps the current version — extend the current changelog section instead. Versions before this rule bumped on every change, so history includes styling-only versions.
3. **Changelog**: clicking the badge opens a modal (closes via Close button, backdrop, or Escape). Every version gets a `What&rsquo;s new</h2><h3>vX.Y</h3>` section in **both** files. Insert newest before the current top section (`<h3>v4.1 &mdash;`).
4. **Both files stay in full parity** (same taxa, titles, subtitles, ranks). The D3 file is the data source; the card file's `D` is generated.
5. **After every change, verify on both live pages**: no console errors, 662 cards / 661 links, 0 card-card overlaps, 0 line-through-card hits, one root, full title parity. See §8 snippets.
6. Badge wording of ranks: see `kindName` in both files (must list identical words).

## 6. Rank & color system (v3.4)

**Color rule (v4.0, user request):** no two ranks may look alike. Every pair of rank border colors differs by at least 20 in CIELAB distance (closest now: phylum/tribe 23.9). Check any new color against all others before using it, and keep light text readable (all boxes are 7.7:1 or better against #eef6ef).

**Colors button:** `#legBtn` in the header opens the `#leg` popup, which lists every color. Its rows are a `rows` array after `insertAdjacentHTML('beforeend',CHG)` in each file. **If a rank color changes, update that array in both files too.** The second row differs per site (No rank on D3, Context on cards).

Kind = `S` field 5 (or card `D[2]`) → CSS class + search-display word:

| kind | display word | card border | card bg | D3 stroke | Notes |
|---|---|---|---|---|---|
| root | kingdom | #ffd54f yellow | #4a3d12 | #ffd54f | Animalia only |
| domain | domain | #f2f6fa ice white | #2b3a52 | #f2f6fa | Bacteria/Archaea/Eukaryota, same on both sites |
| kingdom | kingdom | #ffd54f | #4a3d12 | #ffd54f | Plantae, Fungi |
| phylum | phylum | #4fc3f7 sky blue | #0f3d57 | #4fc3f7 | |
| subphylum | subphylum | #9fa8ff periwinkle | #262c66 | #9fa8ff | |
| class | class | #7ee07e green | #1d4a25 | #7ee07e | |
| subclass | subclass | #1de9b6 aqua | #0d4a3c | #1de9b6 | |
| infraclass | infraclass | #c6ff00 neon lime | #3d4d00 | #c6ff00 | Marsupialia, Placentalia; also in the rebuild `$kindMap` |
| superorder | superorder | #ffd9a3 pale peach | #5c4520 | #ffd9a3 | Selachii, Batoidea; also in the rebuild `$kindMap` |
| order | order | #ff8c00 bright orange | #6b3300 | #ff8c00 | |
| suborder | suborder | #ffa95e light orange | #4a2508 | #ffa95e | Serpentes, Lacertilia, Mysticeti, Odontoceti, Sauropoda; also in the rebuild `$kindMap` |
| family | family | #ff3399 hot pink | #6b0f3e | #ff3399 | cards 104px wide, 1px border |
| subfamily | subfamily | #b388ff violet | #36205e | #b388ff | |
| tribe | tribe | #80deea pale cyan | #1f4d53 | #80deea | |
| subtribe | subtribe | #c5e1a5 sage | #3d4a30 | #c5e1a5 | |
| genus | genus | #a1887f warm taupe | #3e322c | #a1887f | |
| clade | clade | #e040fb magenta | #4a1552 | #e040fb | not red: a red "extinct" border would vanish on a red box |
| vertebrate | vertebrate | #9be89b lt green | #1e4d33 | #9be89b | legacy; 0 rows remain (converted to true ranks in v3.3). Don't use: it hides the real rank |
| arthropod | arthropod | #d69bd4 purple | #59365a | #d69bd4 | legacy; 0 rows remain (converted to ranks in v2.8) |
| outside | context | var(--life) = #7b93ad blue-grey | #41504b | — | Card site only: LUCA and Other eukaryotes, forced by rebuild `$overrides`. Was grey #9ba7a0 until the v4.0 color rework, changed because it looked like the taupe genus color |
| blank | taxon | default teal | #1b4842 | #78998e | only LUCA's raw row is blank |

**Accent field** (`S` field 6, card `D[6]`, appended to class name):
- `a-arth` → **removed in v3.2 at the user's request** (0 rows, CSS deleted). Arthropods have no special border and show their normal rank colors. Don't re-add it unless asked.
- `a-ext` → **pure red border** (#ff0000, 2.5px in D3; 2px on cards). 115 rows: every extinct entry carries its TRUE rank kind + the red border (e.g. Tyrannosaurus = `genus+a-ext`, Trilobita = `class+a-ext`, Mosasauridae = `family+a-ext`, Sauropterygia = `clade+a-ext`). † prefix and "extinct …" wording kept for recognition. **A group with living descendants must not be marked extinct** (Dinosauria, Therapsida, Cynodontia and Sphenacodontia are "... included" clades instead). Check on the D3 page: `r.descendants().filter(d=>d.data.accent==='a-ext'&&d.descendants().some(x=>x.data.accent!=='a-ext'))` must be empty.

**Click behavior (v3.0, both sites) — user rule:** a border keeps its color whether clicked or not. Extinct entries always stay red; never turn a border white on click (v2.9 did this by misreading the request, and the user rejected it). Clicking adds `.active`, which shows a soft white glow outside the border until another entry is clicked; there is no toggle-off or click-background-to-clear. Hover must not change a border's color. Card site: `.card.active` sets the glow via `box-shadow` and a 2px border. D3 site: `G.on('click',…)` plus `.n.active rect`, which sets the glow via `filter:drop-shadow`.

Current kind+accent census in `S` (662): family 162·family+a-ext 30·genus 230·genus+a-ext 72·clade 33·clade+a-ext 3·class 29·class+a-ext 2·order 51·order+a-ext 7·phylum 14·subphylum 7·subclass 2·infraclass 2·superorder 3·suborder 4·suborder+a-ext 1·kingdom 2·domain 3·root 1·subfamily 1·tribe 1·subtribe 1·blank 1 (LUCA).

**Layout (v4.1):** the D3 tree spaces neighbours by their own box width, `d3.tree().nodeSize([1,150]).separation((a,b)=>(Math.max(a.data.w,140)+Math.max(b.data.w,140))/2+(a.parent===b.parent?24:56))`, not by the widest box. The 140 minimum keeps the card site's 124px cards from overlapping. Children stay in alphabetical order; sorting by subtree size shortened the longest lines slightly but made the tree about 40% wider.

**Open rank questions:** Gorillini, Panina and Homo sit directly under Hominidae because the tree has no subfamily Homininae; fixing that means adding a taxon, so ask first. Cetacea stays a clade because it sits inside the order Cetartiodactyla, and it means crown whales only (Mysticeti + Odontoceti): Pakicetus stays outside it as a stem whale under Cetartiodactyla, at the user's direction. Crustacea stays a subphylum beside Hexapoda even though it is paraphyletic, and its subtitle says so. Placozoa stays under Parazoa, and its subtitle notes the debate. Animalia's internal kind `root`/`animal` is deliberate: it shows the word "kingdom" and kingdom colors.

**Fit to view:** both sites fit the whole tree on load, on resize, and on `pageshow`. The card site's minimum zoom is `.005` in `zoomAt` and in the rebuild's `$fit` line (it was `.02`, which cut off windows under about 700px wide). `resetView` also clears the old zoom target. The logo is `.logo` inside `.brand`; keep it no taller than 44px so the header heights (78px cards, 76px D3) don't change, because D3's `fit()` hard-codes 76.

## 7. Text/alias conventions

- Extinct entries: subtitle starts with "extinct …"; title gets the † prefix **at render time only** (D3 label code + card template must use the accent test `a-ext`, NOT `kind==='fossil'` — that kind no longer exists in data).
- Search: dropdown shows scientific title + rank word from `kindName{...}`; both files must have identical kindName sets (rank words are self-named: `subphylum:'subphylum'` etc.).
- `alias{}` maps common names → taxa ("hedgehog"→Erinaceidae, "mollusk"→Mollusca, "orca"→Orcinus, "elasmosaur"→Elasmosauridae …). Keep in sync across both files.

## 8. Verification snippets (run in browser console via automation)

**Card page (`http://localhost:8080/`) — reload first; globals: `D`, `ver`:**
```js
// overlaps
const c=[...document.querySelectorAll('.card')].map(x=>({l:parseFloat(x.style.left),t:parseFloat(x.style.top),w:x.offsetWidth,h:x.offsetHeight})); // parseFloat: style.left is "28965px", and +"28965px" is NaN, which makes both counts always 0
let ov=0;for(let i=0;i<c.length;i++)for(let j=i+1;j<c.length;j++){const a=c[i],b=c[j];
 if(Math.abs(a.l-b.l)-(a.w+b.w)/2<0&&Math.abs(a.t-b.t)-(a.h+b.h)/2<0)ov++}
// connector-vs-card: lines start and end at card centers, so a line's own 2 end cards are skipped (own)
const ps=[...document.querySelectorAll('#lines path')];let hits=0;const D2=c;
ps.forEach(p=>{const P=(p.getAttribute('d').match(/-?[\d.]+,-?[\d.]+/g)||[]).map(s=>s.split(',').map(Number));
 const own=k=>[P[0],P[P.length-1]].some(q=>Math.abs(q[0]-k.l)<=k.w/2+1&&Math.abs(q[1]-k.t)<=k.h/2+1);
 for(let i=0;i+1<P.length;i++){const[x1,y1]=P[i],[x2,y2]=P[i+1];
  if(x1===x2)D2.forEach(k=>{const k1=k.l-k.w/2,k2=k.l+k.w/2,j1=k.t-k.h/2,j2=k.t+k.h/2;
   if(!own(k)&&x1<k2-.5&&x1>k1+.5&&Math.min(y1,y2)<j2-.5&&Math.max(y1,y2)>j1+.5)hits++});
  else D2.forEach(k=>{const k1=k.l-k.w/2,k2=k.l+k.w/2,j1=k.t-k.h/2,j2=k.t+k.h/2;
   if(!own(k)&&y1>j1+.5&&y1<j2-.5&&Math.min(x1,x2)<k2-.5&&Math.max(x1,x2)>k1+.5)hits++})}});
({cards:c.length,paths:ps.length,ov,hits,badge:document.getElementById('ver').textContent})
```
**D3 page — reload first; globals: `r`, `ver`:** (at fit-to-view zoom, boxes sit under 1px apart, so the on-screen overlap count can report a false 1 from rounding. Confirm any hit at 100% zoom with `V.call(zoom.transform,d3.zoomIdentity.scale(1))`, or check gaps per depth in layout coordinates; the smallest real gap should be 24.)
```js
const B=[...document.querySelectorAll('.n')].map(g=>g.getBoundingClientRect());
let ov=0;for(let i=0;i<B.length;i++)for(let j=i+1;j<B.length;j++){const a=B[i],b=B[j];
 if(Math.min(a.right,b.right)-Math.max(a.left,b.left)>.5&&Math.min(a.bottom,b.bottom)-Math.max(a.top,b.top)>.5)ov++}
({nodes:document.querySelectorAll('.n').length,links:document.querySelectorAll('path.link').length,ov,badge:document.getElementById('ver').textContent})
```
Parity check: `r.descendants().map(d=>d.data.title).sort()` (D3) vs `[...new Set(D.map(n=>n[0]))].sort()` (cards) must be identical (fat-arrow titles only; `Animalia` vs `Animalia / Metazoa` is a rebuild `$overrides` rename, not a mismatch).

**Harness quirks:** in the automation sandbox `setTimeout` is unavailable (use a page-side `sleep` promise inside `evaluate`); `requestAnimationFrame` never fires on the card page; always target the tab ID explicitly and reload after file edits (tabs cache aggressively).

## 9. Known pitfalls (learned the hard way)

1. **`†` is U+2020**, not '+': raw string replaces with `'+'` silently miss the label-prefix conditions. Match with the real char.
2. **`familyfamily`, `familyfamilyfamily`**: PowerShell `.Replace()`-based appends can double-hit across repeated runs. Always verify replacement count == 1, and re-verify the file after writing.
3. **Last S row / template backtick:** Erinaceidae (last row) once had the closing backtick glued to its kind → cards showed "taxon". The rebuild does `.TrimEnd('`')` — keep that.
4. **Editing `S` rows:** rows are unique by `id|parent|title` — build replaces from the FULL old row text, or use the `(?<=[;\`])` row-boundary lookbehind (`insecta` appears as both id and parent).
5. **Rebuild validation regex** reads generated rows as `\['..','..','kind',x,y,parent(,'accent')?\]` — if you add more D fields, patch that regex too (`$rx` in rebuild-manual-full.ps1).
6. **`$overrides`** in the rebuild force card-page data for LUCA/Bacteria/Archaea/Eukaryota/Plantae/Fungi/Animalia/other-euk (since v3.4 only LUCA and other-euk use the grey `outside` tone; "Animalia / Metazoa" naming). Subtitle/kind edits to those 8 rows belong in the overrides, not just S.
7. D3 node widths come from `measureText` + a †-prefix condition — if you conditionally render prefixes, keep the width calc in sync or world size changes.
8. The card file's `c.title` tooltip uses `n[0]+': '+n[1]` and clicking sets `.active` on one card at a time; keep working.
9. **PowerShell functions return everything they print.** A helper that prints a status string and then returns text hands back both, and writing that result puts the status text at the top of the file. Use `Write-Host` for messages inside such helpers, and check that the file still starts with `<!doctype html>` before moving on.

## 10. Version history

- **v4.1 (2026-11-07)** — 662 taxa. Added 67 reptile/bird entries (Archosauromorpha with Prolacertiformes, Sharovipteryx and Longisquama; Kaprosuchus, Metriorhynchus; Sauropodomorpha with Plateosauridae; Hadrosauridae, Ankylosauridae, Ceratopsidae (+Torosaurus), Stegosauridae; Struthioniformes in the broad ratite sense with ostriches, rheas, cassowaries/emus, kiwis, elephant birds and moas; Cariamiformes with seriemas and terror birds; 9 lizard families/genera incl. Sauromalus, Phelsuma, Eublepharis, Correlophus; Henodontidae, Protostegidae with Archelon, Mesosauria) and 76 mammal entries (Xenarthra with armadillos, Glyptodontidae, sloths, anteaters, Megatheriidae; Pholidota, Sirenia, Tubulidentata, Hyracoidea, Litopterna, Notoungulata; seals, sea lions, hyenas, raccoons, giraffes, lemurs, capuchins, cavies, fruit and vampire bats; extinct megafauna such as Mammut, Coelodonta, Megaloceros, Paraceratherium, Diprotodon, Thylacoleo, Thylacinus, Arctodus, Aenocyon). Removed Cynodontia and 21 repetitive single-child families (user request; Vespertilionidae was removed then restored once other bat families joined it). Families now hot pink. Width-based layout spacing roughly halves tree width. Card world 32779 x 4100. Search box placeholder now reads "Search all N taxa." with N counted live from the data (`S.length` on D3, `D.length` on cards), so it never needs a manual update.
- **v4.0 (2026-11-06)** — 193 genera added under families (user asked for 0–2 per family, about 1 on average, more where worthwhile), now 542 taxa and 224 genera. All 8 families with no genus were left that way on purpose: Entomobryidae, Acerentomidae, Campodeidae, Ophiuridae, Stichopodidae, Pycnogonidae, Julidae, Didemnidae. **The user wants every added genus listed in the update log.** Each pick was checked against GBIF; 189 of 193 matched as accepted in the expected family, and the other 4 were reviewed (Mobula and Cacatua are GBIF family quirks, Gorgonops is a spelling variant, Branchiostoma led to the rename below). Branchiostomidae renamed Branchiostomatidae (GBIF synonym; `S` id unchanged, old name kept as a search alias). Xiphosura changed from class to order. Gorgonopsidae kept although GBIF prefers Gorgonopidae, because the literature mostly uses Gorgonopsidae. Card world now 46844 x 4250.
- **v3.9 (2026-11-06)** — second audit, including a name and placement comparison of all animal entries against the GBIF API (`api.gbif.org/v1/species/match?kingdom=Animalia&name=…`). Aureliidae renamed Ulmaridae (GBIF lists it as a synonym; `S` id stays `aureliidae`, old name kept as a search alias). Monotremata changed from infraclass to order. Stale `Apterygidae` alias removed. GBIF results need human review: it returns false hits from name clashes (Crustacea matched a bee genus), and it lists Pakicetus under Cetacea and Cathartidae under Accipitriformes, which this tree deliberately doesn't follow.
- **v3.8 (2026-11-06)** — full placement audit of all 349 entries. Pakicetus moved out of Cetacea to Cetartiodactyla. Therapsida, Cynodontia and Sphenacodontia no longer extinct (they include mammals); Therapsida moved under Sphenacodontia and changed from order to clade. Hylonomus moved from Amniota to Sauropsida. 49 extinct rows. Card world now 31444 x 4250.
- **v3.7 (2026-11-06)** — Cetacea moved under Cetartiodactyla and Pakicetus under Cetacea (reverses the v2.5 link where Cetacea sat under Pakicetus). Osteichthyes and Sarcopterygii to clade. Subtitle notes on Placozoa and Crustacea. Paw logo in the header. Card site fit-to-view fixed for narrow windows. Card world now 31567 x 4100.
- **v3.6 (2026-11-06)** — 2 new taxa, now 349: classes Malacostraca and Thecostraca under Crustacea. Decapoda and Isopoda moved under Malacostraca, Cirripedia under Thecostraca. Layout changed, so the card world is now 31567 x 4250.
- **v3.5 (2026-11-06)** — Gorillinae renamed Gorillini (still a tribe; its internal `S` id stays `gorillinae`, and "gorillinae" remains a search alias).
- **v3.4 (2026-11-06)** — 16 rank corrections: Reptilia and Cyclostomata to clade; Onychophora and Tardigrada to phylum; Tunicata and Cephalochordata to subphylum; Asteroidea to class; Nudibranchia to order; Mysticeti, Odontoceti and Sauropoda to suborder; new ranks superorder (Selachii, Batoidea) and infraclass (Monotremata, Marsupialia, Placentalia). Card site now shows Bacteria/Archaea/Eukaryota as domain and Plantae/Fungi as kingdom, with a new domain color on both sites.
- **v3.3 (2026-11-06)** — all 50 `vertebrate` rows moved to true ranks: 1 phylum (Chordata), 1 subphylum (Vertebrata), 8 classes, 29 orders, 2 suborders (new rank: Lacertilia, Serpentes), 9 clades (including Cetacea, Dinosauria, Theropoda, Maniraptora). Subphylum, subclass, suborder, subfamily, tribe and subtribe got their own colors. New Colors button and popup on both sites.
- **v3.2 (2026-11-06)** — yellow `a-arth` border removed entirely, data and CSS; the 4 subphyla and 2 subclasses that still had it now show their normal rank colors. Extinct border changed from #ff5252 to pure red #ff0000 (no bump, under the new version rule).
- **v3.1 (2026-11-06)** — yellow `a-arth` border limited to arthropod sub-ranks (4 subphyla, 2 subclasses); the 9 classes and 11 orders that had it now show their normal rank colors.
- **v3.0 (2026-11-06)** — borders keep their color when clicked (extinct stay red, arthropod lineages stay yellow, all others keep their rank color); the selected entry gets a soft white glow. Replaces the v2.9 white-on-click behavior.
- **v2.9 (2026-11-06)** — clicking any entry turns its border white on both sites (the D3 site previously had no click handling). Hover no longer changes border color on the card site; family cards get a 2px border while selected.
- **v2.8 (2026-11-06)** — color-coded ranks (borders + dark tinted backgrounds, light text kept). All 52 extinct rows re-ranked to true ranks + `a-ext` red border; all 26 arthropod lineages re-ranked + `a-arth` yellow border; new rank kinds subphylum/subclass; changelog entries extended in both files (fold-in, no bump per user).
- **v2.7 (2026-11-06)** — Arthropoda re-ranked from lineage `arthropod` → `phylum` (user caught it). Snapshot backed up to `backups\` right after this (that backup therefore contains v2.7 badge but pre-v2.8 styling).
- **v2.6 (2026-11-05)** — accuracy pass: dinosaurs de-fossilized (birds inside; "birds included"), Elasmosaurus → own family Elasmosauridae, rank sweep (domain/kingdom/phylum/class + hominid tribe/subtribe/subfamily/genus fixes), "extinct" wording added to Therapsida/Sphenacodontia/Mammuthus, ~24 duplicate subtitles differentiated, Parazoa "sponge-grade", elbow-path connectors (kills line-through-card), search rank words, alias Mollusca/Elasmosauridae. Record of all 68 row edits: `tools\transform-v26.ps1`.
- **v2.5** — early mammal Megazostrodon, Pikaia, Archaeopteryx; Pakicetus → stem position (cetacea child); Orcinus kept separate.
- **v2.2–v2.4** — earlier accuracy/layout passes (see changelog modal).
- **v2.1** — initial changelog-era baseline.

## 11. Rollback procedure

**Preferred (v2.8 onward):** the project is a local git repository with one tag per version. `git tag` lists versions; `git restore --source=v2.8 -- animal-evolution-tree.html full-animal-tree.html` restores both sites. Confirm with the user first, because this overwrites the current files.

**Older snapshot:** restore = copy `backups\*-v2.7.html` over the live files. **But** the backup predates the whole v2.8 rank/accent data change — if the user wants to keep v2.8 data but only revert some styling, edit the CSS classes listed in §6 instead. Always verify (§8) after any rollback.

## 12. Suggested next steps for Claude

- Serve with `tools\serve-animal-atlas.ps1` if no server is running (user may still have theirs up on 8080).
- Confirm current live state matches §6 census before making changes.
- Ask the user before: adding taxa (they may specify placement), removing anything (never without explicit consent), or bumping vs folding (§5.2).
