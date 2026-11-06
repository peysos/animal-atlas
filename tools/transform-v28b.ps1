$ErrorActionPreference = 'Stop'
$utf8 = New-Object System.Text.UTF8Encoding($false)
$D3 = 'C:\Users\pkepe\OneDrive\Desktop\My computer\vibecode\Animal Atlas\full-animal-tree.html'
$CARD = 'C:\Users\pkepe\OneDrive\Desktop\My computer\vibecode\Animal Atlas\animal-evolution-tree.html'
$RB = 'C:\Users\pkepe\AppData\Local\Temp\opencode\rebuild-manual-full.ps1'
$bt = [char]96  # backtick (first row of S template)

# ============ rank assignment tables ============
# arthropod lineage rows -> true rank, accent a-arth (yellow border)
$A = @{ arachnida='class'; pycnogonida='class'; xiphosura='class'; chilopoda='class'; diplopoda='class'
  crustacea='subphylum'; acari='subclass'; araneae='order'; scorpiones='order'; cirripedia='subclass'
  decapoda='order'; isopoda='order'; insecta='class'; collembola='class'; diplura='class'; protura='class'
  coleoptera='order'; diptera='order'; hemiptera='order'; hymenoptera='order'; lepidoptera='order'
  odonata='order'; orthoptera='order' }
# extinct rows -> true rank, accent a-ext (red border)
$F = @{ pikaia='genus'; placodermi='class'; trilobita='class'; dunkleosteus='genus'; tiktaalik='genus'
  acanthostega='genus'; ichthyostega='genus'; hylonomus='genus'; temnospondyli='order'
  edaphosauridae='family'; ophiacodontidae='family'; sphenacodontia='clade'; therapsida='order'
  eryops='genus'; sauropterygia='clade'; edaphosaurus='genus'; sphenacodontidae='family'
  cynodontia='clade'; gorgonopsidae='family'; pterosauria='order'; plesiosauria='order'
  mosasauridae='family'; dimetrodon='genus'; ornithischia='order'; sauropoda='clade'
  azhdarchidae='family'; pteronodontidae='family'; pterodactylus='genus'; elasmosauridae='family'
  plesiosauridae='family'; pliosauridae='family'; mosasaurus='genus'; tylosaurus='genus'
  megazostrodon='genus'; deinosuchus='genus'; stegosaurus='genus'; triceratops='genus'
  brachiosaurus='genus'; spinosauridae='family'; tyrannosaurus='genus'; quetzalcoatlus='genus'
  pteranodon='genus'; elasmosaurus='genus'; plesiosaurus='genus'; liopleurodon='genus'
  titanoboa='genus'; archaeopteryx='genus'; dromaeosauridae='family'; spinosaurus='genus'
  velociraptor='genus'; pakicetus='genus'; mammuthus='genus' }

# ============ 1. D3 data rows (skipped if already applied) ============
$c = [IO.File]::ReadAllText($D3, $utf8)
if (-not $c.Contains('|a-ext')) {
$fail = 0
foreach ($t in @(@('arthropod', $A, 'a-arth'), @('fossil', $F, 'a-ext'))) {
  $oldkind = $t[0]; $table = $t[1]; $acc = $t[2]
  foreach ($id in $table.Keys) {
    $rank = $table[$id]
    # lookbehind ; or backtick = row boundary; capture first five fields, replace kind + append accent
    $pat = "(?<=[;$bt])(" + [regex]::Escape($id) + "\|[a-z-]+\|[^;|]+\|[^;|]+)\|$oldkind"
    $ms = [regex]::Matches($c, $pat)
    if ($ms.Count -ne 1) { Write-Output "MISS x$($ms.Count): $id -> $rank"; $fail++; continue }
    $repl = '$1|' + $rank + '|' + $acc
    $c = [regex]::Replace($c, $pat, $repl)
  }
}
if ($fail) { throw "$fail row pattern(s) failed" }
[IO.File]::WriteAllText($D3, $c, $utf8)
Write-Output "D3 data: $($A.Count + $F.Count) rows re-ranked with accents"
} else { Write-Output 'D3 data: already re-ranked (skipped)' }

# ============ 2. D3 code + CSS ============
$dg = [string][char]8224   # dagger char used in the label prefix
$c = [IO.File]::ReadAllText($D3, $utf8)

# parse accent field
$old = "{let[id,parentId,title,subtitle,kind]=x.split('|');return{id,parentId:parentId||null,title,subtitle,kind}}"
$new = "{let[id,parentId,title,subtitle,kind,accent]=x.split('|');return{id,parentId:parentId||null,title,subtitle,kind,accent:accent||''}}"
if ($c.Contains($old)) { $c = $c.Replace($old, $new) } else { throw 'D3 parse code not found' }

# width calc: extinct prefix by accent
$old = "(d.kind==='fossil'?'$dg ':'')"
if ($c.Contains($old)) { $c = $c.Replace($old, "(d.accent==='a-ext'?'$dg ':'')") } else { throw 'D3 width calc not found' }

# label prefix by accent
$old = "(d.data.kind==='fossil'?'$dg ':'')"
if ($c.Contains($old)) { $c = $c.Replace($old, "(d.data.accent==='a-ext'?'$dg ':'')") } else { throw 'D3 label code not found' }

# node class: append accent
$old = "attr('class',d=>'n '+d.data.kind)"
if ($c.Contains($old)) { $c = $c.Replace($old, "attr('class',d=>'n '+d.data.kind+(d.data.accent?' '+d.data.accent:''))") } else { throw 'D3 node class not found' }

# kindName: add subphylum/subclass
$old = ",subtribe:'subtribe',subfamily:'subfamily'}"
if ($c.Contains($old)) { $c = $c.Replace($old, ",subtribe:'subtribe',subfamily:'subfamily',subphylum:'subphylum',subclass:'subclass'}") } else { throw 'D3 kindName not found' }

# CSS: sub-ranks + accent borders (accent rules last so they win)
$old = '.n.genus rect,.n.tribe rect,.n.subtribe rect,.n.subfamily rect{fill:#3e4a47;stroke:#cfd6d3}'
$new = $old + '.n.subphylum rect{fill:#16425c;stroke:#7fd4ff}.n.subclass rect{fill:#1d4a25;stroke:#9be89b}.n.a-arth rect{stroke:#ffd54f;stroke-width:2.5}.n.a-ext rect{stroke:#ff5252;stroke-width:2.5}'
if ($c.Contains($old)) { $c = $c.Replace($old, $new) } else { throw 'D3 node CSS not found' }

# changelog: extend the v2.8 entry
$old = '<li>Every rank now has its own color: <strong>kingdom yellow</strong>, <strong>phylum light blue</strong>, <strong>class light green</strong> (vertebrate lineages too), <strong>order light orange</strong>, <strong>family pink</strong>, <strong>genus/tribe/subtribe light grey</strong>, <strong>clade light brown</strong>; extinct entries carry a bright red border. Card text stays light-on-dark for readability.</li></ul>'
$new = '<li>Every rank now has its own color: <strong>kingdom yellow</strong>, <strong>phylum light blue</strong>, <strong>class light green</strong> (vertebrate lineages too), <strong>order light orange</strong>, <strong>family pink</strong>, <strong>genus/tribe/subtribe light grey</strong>, <strong>clade light brown</strong>, <strong>subphyla/subclasses inherit their parent rank color</strong>. Card text stays light-on-dark for readability.</li><li>Arthropod lineages (Hexapoda, Arachnida, Insecta, Decapoda&hellip;) now carry their true rank color plus a <strong>yellow border</strong> &mdash; e.g. Hexapoda is light blue as a subphylum</li><li>Extinct entries keep their rank color (Tyrannosaurus = grey genus, Mosasauridae = pink family&hellip;) with a bold <strong>red border</strong></li></ul>'
if ($c.Contains($old)) { $c = $c.Replace($old, $new) } else { throw 'D3 changelog v2.8 not found' }

[IO.File]::WriteAllText($D3, $c, $utf8)
Write-Output 'D3 code+CSS OK'

# ============ 3. Card file code + CSS ============
$c = [IO.File]::ReadAllText($CARD, $utf8)

# card class: append accent (7th element optional)
$old = "c.className='card '+n[2];"
if ($c.Contains($old)) { $c = $c.Replace($old, "c.className='card '+(n[6]?n[2]+' '+n[6]:n[2]);") } else { throw 'card class code not found' }

# dagger prefix: by accent (dagger char + nbsp in the template)
$old = '${n[2]===' + "'fossil'" + "?'" + [string][char]8224 + "&nbsp;:''}"
$new = '${n[6]===' + "'a-ext'" + "?'" + [string][char]8224 + "&nbsp;:''}"
if ($c.Contains($old)) { $c = $c.Replace($old, $new) } else { throw 'card dagger code not found' }

# kindName
$old = ",subtribe:'subtribe',subfamily:'subfamily'}"
if ($c.Contains($old)) { $c = $c.Replace($old, ",subtribe:'subtribe',subfamily:'subfamily',subphylum:'subphylum',subclass:'subclass'}") } else { throw 'card kindName not found' }

# CSS
$old = '.genus,.tribe,.subtribe,.subfamily{border-color:#cfd6d3;background:#3e4a47}'
$new = $old + '.subphylum{border-color:#7fd4ff;background:#16425c}.subclass{border-color:#9be89b;background:#1d4a25}.a-arth{border-color:#ffd54f}.a-ext{border-color:#ff5252;border-width:2px}'
if ($c.Contains($old)) { $c = $c.Replace($old, $new) } else { throw 'card CSS not found' }

# changelog
$old = '<li>Every rank now has its own color: <strong>kingdom yellow</strong>, <strong>phylum light blue</strong>, <strong>class light green</strong> (vertebrate lineages too), <strong>order light orange</strong>, <strong>family pink</strong>, <strong>genus/tribe/subtribe light grey</strong>, <strong>clade light brown</strong>; extinct entries carry a bright red border. Card text stays light-on-dark for readability.</li></ul>'
$new = '<li>Every rank now has its own color: <strong>kingdom yellow</strong>, <strong>phylum light blue</strong>, <strong>class light green</strong> (vertebrate lineages too), <strong>order light orange</strong>, <strong>family pink</strong>, <strong>genus/tribe/subtribe light grey</strong>, <strong>clade light brown</strong>, <strong>subphyla/subclasses inherit their parent rank color</strong>. Card text stays light-on-dark for readability.</li><li>Arthropod lineages (Hexapoda, Arachnida, Insecta, Decapoda&hellip;) now carry their true rank color plus a <strong>yellow border</strong> &mdash; e.g. Hexapoda is light blue as a subphylum</li><li>Extinct entries keep their rank color (Tyrannosaurus = grey genus, Mosasauridae = pink family&hellip;) with a bold <strong>red border</strong></li></ul>'
if ($c.Contains($old)) { $c = $c.Replace($old, $new) } else { throw 'card changelog v2.8 not found' }

[IO.File]::WriteAllText($CARD, $c, $utf8)
Write-Output 'card code+CSS OK'

# ============ 4. Rebuild script: accent passthrough ============
$c = [IO.File]::ReadAllText($RB)

$old = "'subtribe'='subtribe'; 'subfamily'='subfamily'; ''=''"
if ($c.Contains($old)) { $c = $c.Replace($old, "'subtribe'='subtribe'; 'subfamily'='subfamily'; 'subphylum'='subphylum'; 'subclass'='subclass'; ''=''") } else { throw 'kindMap pattern not found' }

$oldNode = @'
$nodes += [pscustomobject]@{ id = $p[0]; parentId = $parent; title = $p[2]; subtitle = $p[3]; kind = $p[4] }
'@
$newNode = @'
$accent = ""; if ($p.Count -gt 5) { $accent = $p[5] }
$nodes += [pscustomobject]@{ id = $p[0]; parentId = $parent; title = $p[2]; subtitle = $p[3]; kind = $p[4]; accent = $accent }
'@
if ($c.Contains($oldNode)) { $c = $c.Replace($oldNode, $newNode) } else { throw 'rebuild node parse not found' }

$oldEntries = @'
$entries += "['$title','$sub','$($n.kind)',$($p.x),$($p.y),$parent]"
'@
$newEntries = @'
if ($n.accent) { $entries += "['$title','$sub','$($n.kind)',$($p.x),$($p.y),$parent,'$($n.accent)']" } else { $entries += "['$title','$sub','$($n.kind)',$($p.x),$($p.y),$parent]" }
'@
if ($c.Contains($oldEntries)) { $c = $c.Replace($oldEntries, $newEntries) } else { throw 'rebuild entries pattern not found' }

[IO.File]::WriteAllText($RB, $c, $utf8)
Write-Output 'rebuild script OK'
Write-Output 'ALL PATCHES OK'
