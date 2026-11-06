$ErrorActionPreference = 'Stop'
$root = 'C:\Users\pkepe\OneDrive\Desktop\My computer\vibecode\Animal Atlas'
$d3Path = Join-Path $root 'full-animal-tree.html'
$manualPath = Join-Path $root 'animal-evolution-tree.html'
$posPath = Join-Path $root 'positions.json'
$utf8 = New-Object System.Text.UTF8Encoding($false)

# ---------- D3 data ----------
$d3 = [System.IO.File]::ReadAllText($d3Path, [System.Text.Encoding]::UTF8)
$s = $d3.IndexOf('const S=`') + 9
$e = $d3.IndexOf('.split', $s)
$rows = $d3.Substring($s, $e - $s).TrimEnd('`') -split ';'
$nodes = @()
foreach ($row in $rows) {
  $p = $row -split '\|'
  $parent = $null
  if ($p[1] -ne '') { $parent = $p[1] }
  $accent = ""; if ($p.Count -gt 5) { $accent = $p[5] }
$nodes += [pscustomobject]@{ id = $p[0]; parentId = $parent; title = $p[2]; subtitle = $p[3]; kind = $p[4]; accent = $accent }
}
$count = $nodes.Count

# ---------- D3 layout positions ----------
$positions = Get-Content -Raw $posPath | ConvertFrom-Json
$posById = @{}
foreach ($p in $positions) { $posById[$p.id] = $p }
if ($positions.Count -ne $count) { throw "Position count $($positions.Count) != node count $count" }
foreach ($n in $nodes) { if (-not $posById.ContainsKey($n.id)) { throw "No position for $($n.id)" } }

# ---------- context nodes first, then the rest ----------
$contextOrder = @('life','bacteria','archaea','euk','plantae','fungi','other-euk','animalia')
$byId = @{}
foreach ($n in $nodes) { $byId[$n.id] = $n }
$ordered = @()
$seen = @{}
foreach ($id in $contextOrder) {
  if (-not $byId.ContainsKey($id)) { throw "Missing context node $id" }
  $ordered += $byId[$id]
  $seen[$id] = $true
}
foreach ($n in $nodes) {
  if (-not $seen.ContainsKey($n.id)) { $ordered += $n; $seen[$n.id] = $true }
}

# ---------- display metadata ----------
$kindMap = @{ 'root'='animal'; 'clade'='clade'; 'vertebrate'='vert'; 'arthropod'='arth'; 'family'='family'; 'fossil'='fossil'; 'domain'='domain'; 'kingdom'='kingdom'; 'phylum'='phylum'; 'class'='class'; 'order'='order'; 'genus'='genus'; 'tribe'='tribe'; 'subtribe'='subtribe'; 'subfamily'='subfamily'; 'subphylum'='subphylum'; 'subclass'='subclass'; 'suborder'='suborder'; 'superorder'='superorder'; 'infraclass'='infraclass'; ''='' }
$overrides = @{
  life = @{ title='LUCA'; subtitle='last universal common ancestor'; kind='outside' }
  bacteria = @{ title='Bacteria'; subtitle='domain'; kind='domain' }
  archaea = @{ title='Archaea'; subtitle='domain'; kind='domain' }
  euk = @{ title='Eukaryota'; subtitle='domain, arising from Archaea'; kind='domain' }
  plantae = @{ title='Plantae'; subtitle='plants'; kind='kingdom' }
  fungi = @{ title='Fungi'; subtitle='fungi'; kind='kingdom' }
  'other-euk' = @{ title='Other eukaryotes'; subtitle='protist lineages'; kind='outside' }
  animalia = @{ title='Animalia / Metazoa'; subtitle='kingdom - multicellular animals'; kind='animal' }
}
foreach ($n in $ordered) {
  if ($overrides.ContainsKey($n.id)) {
    $n.title = $overrides[$n.id].title
    $n.subtitle = $overrides[$n.id].subtitle
    $n.kind = $overrides[$n.id].kind
  } else {
    $n.kind = $kindMap[$n.kind]
  }
}

# ---------- positions shifted into the world ----------
$minX = ($positions | ForEach-Object { $_.x } | Measure-Object -Minimum).Minimum
$minY = ($positions | ForEach-Object { $_.y } | Measure-Object -Minimum).Minimum
$margin = 150
$xy = @{}
foreach ($n in $ordered) {
  $p = $posById[$n.id]
  $xy[$n.id] = @{
    x = [int][math]::Round($margin + ($p.x - $minX))
    y = [int][math]::Round($margin + ($p.y - $minY))
  }
}
$maxX = ($xy.Values | ForEach-Object { $_.x } | Measure-Object -Maximum).Maximum
$maxY = ($xy.Values | ForEach-Object { $_.y } | Measure-Object -Maximum).Maximum
$WW = [int][math]::Ceiling($maxX + 200)
$WH = [int][math]::Ceiling($maxY + 200)

# ---------- D array ----------
$index = @{}
for ($i = 0; $i -lt $ordered.Count; $i++) { $index[$ordered[$i].id] = $i }
$entries = @()
foreach ($n in $ordered) {
  $parent = 'null'
  if ($n.parentId) { $parent = [string]$index[$n.parentId] }
  $title = $n.title -replace "'", "\'"
  $sub = $n.subtitle -replace "'", "\'"
  $p = $xy[$n.id]
  if ($n.accent) { $entries += "['$title','$sub','$($n.kind)',$($p.x),$($p.y),$parent,'$($n.accent)']" } else { $entries += "['$title','$sub','$($n.kind)',$($p.x),$($p.y),$parent]" }
}
$newD = "const D=[`n" + ($entries -join ",`n") + "`n]"

$mraw = [System.IO.File]::ReadAllText($manualPath, [System.Text.Encoding]::UTF8)
$dStart = $mraw.IndexOf('const D=[')
$dEnd = $mraw.IndexOf('];const world', $dStart) + 1
$new = $mraw.Substring(0, $dStart) + $newD + $mraw.Substring($dEnd)

# dimensions
$new = [regex]::Replace($new, '\.world\{position:absolute;width:\d+px;height:\d+px;', ".world{position:absolute;width:${WW}px;height:${WH}px;")
$new = [regex]::Replace($new, '\.lines\{position:absolute;width:\d+px;height:\d+px;', ".lines{position:absolute;width:${WW}px;height:${WH}px;")
$new = [regex]::Replace($new, 'viewBox="0 0 \d+ \d+"', "viewBox=`"0 0 $WW $WH`"")
$new = [regex]::Replace(
  $new,
  "world\.style\.width='\d+px';world\.style\.height='\d+px';svg\.setAttribute\('width','\d+'\);svg\.setAttribute\('height','\d+'\);svg\.setAttribute\('viewBox','0 0 \d+ \d+'\);",
  "world.style.width='${WW}px';world.style.height='${WH}px';svg.setAttribute('width','${WW}');svg.setAttribute('height','${WH}');svg.setAttribute('viewBox','0 0 ${WW} ${WH}');"
)

# fit bounds
$bx0 = $margin - 70
$by0 = $margin - 40
$bx1 = $maxX + 70
$by1 = $maxY + 40
$fit = "function fitView(){let vw=view.clientWidth,vh=view.clientHeight,bw=$bx1-$bx0,bh=$by1-$by0;s=Math.max(.02,Math.min((vw-70)/bw,(vh-70)/bh,.8));x=(vw-bw*s)/2-($bx0)*s;y=(vh-bh*s)/2-($by0)*s;draw()}function resetView"
$new = [regex]::Replace($new, 'function fitView\(\)\{[^}]*\}function resetView', $fit)

# header
$new = [regex]::Replace($new, '<div class="sub">.*?</div>', '<div class="sub">Evolutionary tree of animal life</div>', 1)

[System.IO.File]::WriteAllText($manualPath, $new, $utf8)

# ---------- validation ----------
$check = [System.IO.File]::ReadAllText($manualPath, [System.Text.Encoding]::UTF8)
$cs = $check.IndexOf('const D=[') + 9
$ce = $check.IndexOf('];const world', $cs)
$cbody = $check.Substring($cs, $ce - $cs + 1)
$rx = [regex]"\[(?:'((?:[^']|\\')*)'),(?:'((?:[^']|\\')*)'),(?:'((?:[^']|\\')*)'),(-?\d+),(-?\d+),(null|\d+)(?:,'([a-z-]+)')?\]"
$cm = $rx.Matches($cbody)
$badParents = 0
for ($i = 0; $i -lt $cm.Count; $i++) {
  $pi = $cm[$i].Groups[6].Value
  if ($pi -ne 'null' -and ([int]$pi -lt 0 -or [int]$pi -ge $cm.Count)) { $badParents++ }
}
$overlaps = 0
$samples = @()
for ($i = 0; $i -lt $cm.Count; $i++) {
  $xi = [int]$cm[$i].Groups[4].Value; $yi = [int]$cm[$i].Groups[5].Value
  $wi = if ($cm[$i].Groups[3].Value -eq 'family') { 52 } else { 62 }
  for ($j = $i + 1; $j -lt $cm.Count; $j++) {
    $xj = [int]$cm[$j].Groups[4].Value; $yj = [int]$cm[$j].Groups[5].Value
    $wj = if ($cm[$j].Groups[3].Value -eq 'family') { 52 } else { 62 }
    if ([math]::Abs($xi - $xj) -lt ($wi + $wj) -and [math]::Abs($yi - $yj) -lt 60) {
      $overlaps++
      if ($samples.Count -lt 8) { $samples += "$($cm[$i].Groups[1].Value) <-> $($cm[$j].Groups[1].Value)" }
    }
  }
}
$mNames = @()
foreach ($x in $cm) { $mNames += $x.Groups[1].Value }
$dNames = @($nodes | ForEach-Object { $t = $_.title; if ($t -eq 'Animalia') { $t = 'Animalia / Metazoa' }; $t })
$onlyM = @(Compare-Object $mNames $dNames | Where-Object SideIndicator -eq '<=')
$onlyD = @(Compare-Object $mNames $dNames | Where-Object SideIndicator -eq '=>')
"Manual nodes: $($cm.Count)"
"Bad parent indices: $badParents"
"Overlapping card pairs: $overlaps"
if ($samples.Count) { "Samples: $($samples -join ', ')" }
"Only in manual: $($onlyM.Count)"
"Only in D3: $($onlyD.Count)"
"World: ${WW} x ${WH}"
"Root: $($cm[0].Groups[1].Value) parent=$($cm[0].Groups[6].Value)"
if ($badParents -or $overlaps -or $onlyM.Count -or $onlyD.Count) { throw 'Manual validation failed' }
