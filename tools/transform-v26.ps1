$ErrorActionPreference = 'Stop'
$utf8 = New-Object System.Text.UTF8Encoding($false)
$D3 = 'C:\Users\pkepe\OneDrive\Desktop\My computer\vibecode\Animal Atlas\full-animal-tree.html'
$CARD = 'C:\Users\pkepe\OneDrive\Desktop\My computer\vibecode\Animal Atlas\animal-evolution-tree.html'
$RB = 'C:\Users\pkepe\AppData\Local\Temp\opencode\rebuild-manual-full.ps1'

# ---------- D3 data rows: [old full row] -> [new] ----------
$pairs = @(
  @('elasmosaurus|plesiosauridae|Elasmosaurus|extinct super-long-necked plesiosaur|fossil',
    'elasmosauridae|plesiosauria|Elasmosauridae|extinct giant long-necked plesiosaurs|fossil;elasmosaurus|elasmosauridae|Elasmosaurus|extinct super-long-necked plesiosaur|fossil'),
  # de-extinct the dinosaur line (birds are inside these clades)
  @('dinosauria|archosauria|Dinosauria|extinct dinosaurs|fossil','dinosauria|archosauria|Dinosauria|dinosaurs - birds included|vertebrate'),
  @('theropoda|dinosauria|Theropoda|extinct bipedal dinosaurs|fossil','theropoda|dinosauria|Theropoda|theropods - birds included|vertebrate'),
  @('maniraptora|theropoda|Maniraptora|dinosaurs close to birds|fossil','maniraptora|theropoda|Maniraptora|maniraptorans - birds included|vertebrate'),
  # ranks: domains & kingdoms
  @('bacteria|life|Bacteria|domain|','bacteria|life|Bacteria|domain|domain'),
  @('archaea|life|Archaea|domain|','archaea|life|Archaea|domain|domain'),
  @('euk|archaea|Eukaryota|domain, arising from Archaea|','euk|archaea|Eukaryota|domain, arising from Archaea|domain'),
  @('plantae|euk|Plantae|plants|','plantae|euk|Plantae|plants|kingdom'),
  @('fungi|opisthokonta|Fungi|fungi|','fungi|opisthokonta|Fungi|fungi|kingdom'),
  # ranks: phyla
  @('ctenophora|animalia|Ctenophora|comb jellies|','ctenophora|animalia|Ctenophora|comb jellies|phylum'),
  @('cnidaria|eum|Cnidaria|jellies & corals|','cnidaria|eum|Cnidaria|jellies & corals|phylum'),
  @('placozoa|parazoa|Placozoa|placozoans|','placozoa|parazoa|Placozoa|placozoans|phylum'),
  @('porifera|parazoa|Porifera|sponges|','porifera|parazoa|Porifera|sponges|phylum'),
  @('echinodermata|deut|Echinodermata|stars & urchins|','echinodermata|deut|Echinodermata|stars & urchins|phylum'),
  @('hemichordata|deut|Hemichordata|acorn worms|','hemichordata|deut|Hemichordata|acorn worms|phylum'),
  @('nematoda|ecdy|Nematoda|roundworms|','nematoda|ecdy|Nematoda|roundworms|phylum'),
  @('annelida|loph|Annelida|segmented worms|','annelida|loph|Annelida|segmented worms|phylum'),
  @('mollusca|loph|Mollusca|snails, clams & squid|','mollusca|loph|Mollusca|snails, clams & squid|phylum'),
  @('platy|loph|Platyhelminthes|flatworms|','platy|loph|Platyhelminthes|flatworms|phylum'),
  # ranks: classes
  @('scyphozoa|cnidaria|Scyphozoa|true jellyfish|','scyphozoa|cnidaria|Scyphozoa|true jellyfish|class'),
  @('hydrozoa|cnidaria|Hydrozoa|hydras & siphonophores|','hydrozoa|cnidaria|Hydrozoa|hydras & siphonophores|class'),
  @('cubozoa|cnidaria|Cubozoa|box jellyfish|','cubozoa|cnidaria|Cubozoa|box jellyfish|class'),
  @('anthozoa|cnidaria|Anthozoa|corals & anemones|clade','anthozoa|cnidaria|Anthozoa|corals & anemones|class'),
  @('gastropoda|mollusca|Gastropoda|snails & slugs|clade','gastropoda|mollusca|Gastropoda|snails & slugs|class'),
  @('cephalopoda|mollusca|Cephalopoda|octopuses, squid & nautilus|clade','cephalopoda|mollusca|Cephalopoda|octopuses, squid & nautilus|class'),
  @('bivalvia|mollusca|Bivalvia|clams, mussels & scallops|clade','bivalvia|mollusca|Bivalvia|clams, mussels & scallops|class'),
  @('chondrichthyes|gnatho|Chondrichthyes|sharks & rays|','chondrichthyes|gnatho|Chondrichthyes|sharks & rays|class'),
  @('actino|osteichthyes|Actinopterygii|ray-finned fishes|','actino|osteichthyes|Actinopterygii|ray-finned fishes|class'),
  @('amphibia|tetrapoda|Amphibia|frogs & salamanders|','amphibia|tetrapoda|Amphibia|frogs & salamanders|class'),
  @('crinoidea|echinodermata|Crinoidea|sea lilies & feather stars|','crinoidea|echinodermata|Crinoidea|sea lilies & feather stars|class'),
  @('echinoidea|echinodermata|Echinoidea|sea urchins & sand dollars|','echinoidea|echinodermata|Echinoidea|sea urchins & sand dollars|class'),
  @('holothuroidea|echinodermata|Holothuroidea|sea cucumbers|','holothuroidea|echinodermata|Holothuroidea|sea cucumbers|class'),
  @('ophiuroidea|echinodermata|Ophiuroidea|brittle stars|','ophiuroidea|echinodermata|Ophiuroidea|brittle stars|class'),
  # remaining blank kinds
  @('eusuchia|crocodylomorpha|Eusuchia|advanced crocodyliforms|','eusuchia|crocodylomorpha|Eusuchia|advanced crocodyliforms|clade'),
  @('other-euk|euk|Other eukaryotes|protist lineages|','other-euk|euk|Other eukaryotes|protist lineages|clade'),
  # misranked primate/hominid rows + orca genus
  @('homo|hominidae|Homo|humans|family','homo|hominidae|Homo|humans|genus'),
  @('gorillinae|hominidae|Gorillinae|gorillas|family','gorillinae|hominidae|Gorillinae|gorillas|tribe'),
  @('panina|hominidae|Panina|chimpanzees & bonobos|family','panina|hominidae|Panina|chimpanzees & bonobos|subtribe'),
  @('ponginae|hominidae|Ponginae|orangutans|family','ponginae|hominidae|Ponginae|orangutans|subfamily'),
  @("orcinus|delphinidae|Orcinus|killer whales|",  "orcinus|delphinidae|Orcinus|killer whales|genus"),
  # extinct wording for fossil rows
  @('therapsida|synapsida|Therapsida|mammal-line ancestors|fossil','therapsida|synapsida|Therapsida|extinct mammal-line ancestors|fossil'),
  @('sphenacodontia|synapsida|Sphenacodontia|predatory synapsids|fossil','sphenacodontia|synapsida|Sphenacodontia|extinct predatory synapsids|fossil'),
  @('mammuthus|elephantidae|Mammuthus|mammoths|fossil','mammuthus|elephantidae|Mammuthus|extinct mammoths|fossil'),
  # Parazoa = informal grade note
  @('parazoa|animalia|Parazoa|early animals|clade','parazoa|animalia|Parazoa|sponge-grade animals - informal grouping|clade'),
  # duplicate subtitle fixes
  @('myxinidae|myxini|Myxinidae|hagfishes|family','myxinidae|myxini|Myxinidae|hagfish family|family'),
  @('petromyzontidae|hyperoartia|Petromyzontidae|lampreys|family','petromyzontidae|hyperoartia|Petromyzontidae|lamprey family|family'),
  @('branchiostomidae|cephalochordata|Branchiostomidae|lancelets|family','branchiostomidae|cephalochordata|Branchiostomidae|lancelet family|family'),
  @('asteriidae|asteroidea|Asteriidae|sea stars|family','asteriidae|asteroidea|Asteriidae|sea star family|family'),
  @('ophiuridae|ophiuroidea|Ophiuridae|brittle stars|family','ophiuridae|ophiuroidea|Ophiuridae|brittle star family|family'),
  @('holothuriidae|holothuroidea|Holothuriidae|sea cucumbers|family','holothuriidae|holothuroidea|Holothuriidae|sea cucumber family|family'),
  @('stichopodidae|holothuroidea|Stichopodidae|sea cucumbers|family','stichopodidae|holothuroidea|Stichopodidae|warty sea cucumbers|family'),
  @('columbidae|columbiformes|Columbidae|pigeons & doves|family','columbidae|columbiformes|Columbidae|pigeon & dove family|family'),
  @('spheniscidae|sphenisciformes|Spheniscidae|penguins|family','spheniscidae|sphenisciformes|Spheniscidae|penguin family|family'),
  @('didelphidae|didelphimorphia|Didelphidae|opossums|family','didelphidae|didelphimorphia|Didelphidae|opossum family|family'),
  @('peramelidae|peramelemorphia|Peramelidae|bandicoots|family','peramelidae|peramelemorphia|Peramelidae|bandicoot family|family'),
  @('sphenodontidae|rhynchocephalia|Sphenodontidae|tuatara|family','sphenodontidae|rhynchocephalia|Sphenodontidae|tuatara family|family'),
  @('limulidae|xiphosura|Limulidae|horseshoe crabs|family','limulidae|xiphosura|Limulidae|horseshoe crab family|family'),
  @('pycnogonidae|pycnogonida|Pycnogonidae|sea spiders|family','pycnogonidae|pycnogonida|Pycnogonidae|sea spider family|family'),
  @('scorpionidae|scorpiones|Scorpionidae|scorpions|family','scorpionidae|scorpiones|Scorpionidae|scorpion family|family'),
  @('scolopendridae|chilopoda|Scolopendridae|centipedes|family','scolopendridae|chilopoda|Scolopendridae|giant centipedes|family'),
  @('julidae|diplopoda|Julidae|millipedes|family','julidae|diplopoda|Julidae|millipede family|family'),
  @('leporidae|lagomorpha|Leporidae|rabbits & hares|family','leporidae|lagomorpha|Leporidae|rabbit & hare family|family'),
  @('elephantidae|proboscidea|Elephantidae|elephants|family','elephantidae|proboscidea|Elephantidae|elephant family|family'),
  @('peripatidae|onychophora|Peripatidae|velvet worms|family','peripatidae|onychophora|Peripatidae|velvet worm family|family'),
  @('sauropterygia|reptilia|Sauropterygia|extinct marine reptiles|fossil','sauropterygia|reptilia|Sauropterygia|extinct paddle-limbed sea reptiles|fossil'),
  @('acanthostega|tetrapoda|Acanthostega|extinct early tetrapod|fossil','acanthostega|tetrapoda|Acanthostega|extinct eight-fingered tetrapod|fossil'),
  @('ichthyostega|tetrapoda|Ichthyostega|extinct early tetrapod|fossil','ichthyostega|tetrapoda|Ichthyostega|extinct seven-fingered tetrapod|fossil'),
  @('tylosaurus|mosasauridae|Tylosaurus|extinct giant sea reptile|fossil','tylosaurus|mosasauridae|Tylosaurus|extinct giant mosasaur|fossil')
)
$c = [IO.File]::ReadAllText($D3, $utf8)
$fail = 0
foreach ($p in $pairs) {
  $n = [regex]::Matches($c, [regex]::Escape($p[0])).Count
  if ($n -ne 1) { Write-Output "MISS x$n :: $($p[0])"; $fail++ }
  else { $c = $c.Replace($p[0], $p[1]) }
}
if ($fail) { throw "$fail replacement(s) failed" }
[IO.File]::WriteAllText($D3, $c, $utf8)
Write-Output "D3 data: $($pairs.Count) row changes applied"

# kindName additions (D3): root kingdom stays
$c = [IO.File]::ReadAllText($D3, $utf8)
$old = "kindName={root:'kingdom',clade:'clade',vertebrate:'vertebrate',arthropod:'arthropod',family:'family',fossil:'extinct'}"
$new = "kindName={root:'kingdom',clade:'clade',vertebrate:'vertebrate',arthropod:'arthropod',family:'family',fossil:'extinct',domain:'domain',kingdom:'kingdom',phylum:'phylum',class:'class',order:'order',genus:'genus',tribe:'tribe',subtribe:'subtribe',subfamily:'subfamily'}"
if ($c.Contains($old)) { $c = $c.Replace($old, $new); [IO.File]::WriteAllText($D3, $c, $utf8); Write-Output 'D3 kindName extended' } else { throw 'D3 kindName not found' }

# rebuild script: pass new kinds through to cards
$c = [IO.File]::ReadAllText($RB)
$old = "`$kindMap = @{ 'root'='animal'; 'clade'='clade'; 'vertebrate'='vert'; 'arthropod'='arth'; 'family'='family'; 'fossil'='fossil'; ''='' }"
$new = "`$kindMap = @{ 'root'='animal'; 'clade'='clade'; 'vertebrate'='vert'; 'arthropod'='arth'; 'family'='family'; 'fossil'='fossil'; 'domain'='domain'; 'kingdom'='kingdom'; 'phylum'='phylum'; 'class'='class'; 'order'='order'; 'genus'='genus'; 'tribe'='tribe'; 'subtribe'='subtribe'; 'subfamily'='subfamily'; ''='' }"
if ($c.Contains($old)) { $c = $c.Replace($old, $new); [IO.File]::WriteAllText($RB, $c, $utf8); Write-Output 'rebuild kindMap extended' } else { throw 'rebuild kindMap not found' }

# card file: extend kindName for new card kinds
$c = [IO.File]::ReadAllText($CARD, $utf8)
$old = "kindName={family:'family',clade:'clade',vert:'vertebrate',arth:'arthropod',animal:'kingdom',outside:'context',fossil:'extinct'}"
$new = "kindName={family:'family',clade:'clade',vert:'vertebrate',arth:'arthropod',animal:'kingdom',outside:'context',fossil:'extinct',domain:'domain',kingdom:'kingdom',phylum:'phylum',class:'class',order:'order',genus:'genus',tribe:'tribe',subtribe:'subtribe',subfamily:'subfamily'}"
if ($c.Contains($old)) { $c = $c.Replace($old, $new); Write-Output 'card kindName extended' } else { throw 'card kindName not found' }

# card file: replace straight lines with elbow connectors routed through gaps
$old = @'
D.forEach(n=>{if(n[5]!==null){let p=D[n[5]],l=document.createElementNS('http://www.w3.org/2000/svg','line');l.setAttribute('x1',p[3]);l.setAttribute('y1',p[4]);l.setAttribute('x2',n[3]);l.setAttribute('y2',n[4]);if(n[5]<7)l.setAttribute('class','outside');svg.append(l)}});
'@
$new = @'
D.forEach(n=>{if(n[5]!==null){let p=D[n[5]],m=(p[4]+n[4])/2,l=document.createElementNS('http://www.w3.org/2000/svg','path');l.setAttribute('d',`M${p[3]},${p[4]} L${p[3]},${m} L${n[3]},${m} L${n[3]},${n[4]}`);if(n[5]<7)l.setAttribute('class','outside');svg.append(l)}});
'@
if ($c.Contains($old)) { $c = $c.Replace($old, $new); Write-Output 'card lines -> elbow paths' } else { throw 'card line code not found' }
$c = $c.Replace('.lines line{stroke:var(--line);stroke-width:3}', '.lines path{stroke:var(--line);stroke-width:3;fill:none}')

# card file: badge v2.5 -> v2.6 and changelog v2.6 block
$c = $c.Replace('<button class="ver" id="ver" type="button">v2.5</button>', '<button class="ver" id="ver" type="button">v2.6</button>')
$old = 'What&rsquo;s new</h2><h3>v2.5 &mdash; Early mammal added</h3>'
$new = @'
What&rsquo;s new</h2><h3>v2.6 &mdash; Accuracy &amp; readability pass</h3><ul><li>Ranks are now labeled in search: domains, kingdoms, phyla (Mollusca, Annelida, Nematoda, Chordata&hellip;), classes (Chondrichthyes, Actinopterygii, Amphibia, Scyphozoa&hellip;), and hominid ranks fixed &mdash; Gorillinae is a tribe, Panina a subtribe, Ponginae a subfamily, Homo and Orcinus genera</li><li>Elasmosaurus moved into its own family Elasmosauridae (long-necked plesiosaurs); Plesiosaurus stays under Plesiosauridae</li><li>Dinosauria, Theropoda and Maniraptora are no longer marked extinct &mdash; birds are dinosaurs, so these clades now say &ldquo;birds included&rdquo; with no dagger</li><li>Missing &ldquo;extinct&rdquo; added: Therapsida, Sphenacodontia, Mammuthus</li><li>~20 duplicate labels differentiated (e.g. hagfishes/lampreys/sea stars families now end in &ldquo;family&rdquo;); Parazoa marked as an informal sponge-grade grouping</li><li>Tree connectors redrawn as routed elbows so lines never cross over cards</li></ul><h3>v2.5 &mdash; Early mammal added</h3>
'@
if ($c.Contains($old)) { $c = $c.Replace($old, $new) } else { throw 'card changelog anchor not found' }
[IO.File]::WriteAllText($CARD, $c, $utf8)
Write-Output 'card file updated'

# D3: badge + changelog + alias
$c = [IO.File]::ReadAllText($D3, $utf8)
$c = $c.Replace('<button class="ver" id="ver" type="button">v2.5</button>', '<button class="ver" id="ver" type="button">v2.6</button>')
$old = 'What&rsquo;s new</h2><h3>v2.5 &mdash; Early mammal added</h3>'
$new = @'
What&rsquo;s new</h2><h3>v2.6 &mdash; Accuracy &amp; readability pass</h3><ul><li>Ranks are now labeled in search: domains, kingdoms, phyla (Mollusca, Annelida, Nematoda, Chordata&hellip;), classes (Chondrichthyes, Actinopterygii, Amphibia, Scyphozoa&hellip;), and hominid ranks fixed &mdash; Gorillinae is a tribe, Panina a subtribe, Ponginae a subfamily, Homo and Orcinus genera</li><li>Elasmosaurus moved into its own family Elasmosauridae (long-necked plesiosaurs); Plesiosaurus stays under Plesiosauridae</li><li>Dinosauria, Theropoda and Maniraptora are no longer marked extinct &mdash; birds are dinosaurs, so these clades now say &ldquo;birds included&rdquo; with no dagger</li><li>Missing &ldquo;extinct&rdquo; added: Therapsida, Sphenacodontia, Mammuthus</li><li>~20 duplicate labels differentiated (e.g. hagfishes/lampreys/sea stars families now end in &ldquo;family&rdquo;); Parazoa marked as an informal sponge-grade grouping</li><li>New alias: Elasmosauridae searchable via &ldquo;elasmosaur&rdquo;</li></ul><h3>v2.5 &mdash; Early mammal added</h3>
'@
if ($c.Contains($old)) { $c = $c.Replace($old, $new) } else { throw 'D3 changelog anchor not found' }
$oldA = "'Mammuthus':'mammoth mammoths woolly mammoth woolly mammoths',"
$newA = "'Mammuthus':'mammoth mammoths woolly mammoth woolly mammoths',`n'Elasmosauridae':'elasmosaur long-necked plesiosaur family',"
if ($c.Contains($oldA)) { $c = $c.Replace($oldA, $newA) } else { throw 'D3 alias anchor missing' }
[IO.File]::WriteAllText($D3, $c, $utf8)
Write-Output 'D3 file updated (badge + changelog + alias)'

# card file alias too
$c = [IO.File]::ReadAllText($CARD, $utf8)
$oldA = "'Mammuthus':'mammoth mammoths woolly mammoth woolly mammoths',"
$newA = "'Mammuthus':'mammoth mammoths woolly mammoth woolly mammoths',`n'Elasmosauridae':'elasmosaur long-necked plesiosaur family',"
if ($c.Contains($oldA)) { $c = $c.Replace($oldA, $newA); [IO.File]::WriteAllText($CARD, $c, $utf8); Write-Output 'card alias added' } else { throw 'card alias anchor missing' }
Write-Output 'ALL PATCHES OK'
