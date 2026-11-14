# v6.0 taxonomy additions

Date: 2026-11-14. User authorized all 20 recommended genera plus Anurognathus as one batch. This adds 21 genera (10 living, 11 extinct) and 23 supporting family/order nodes: 44 new nodes, 1044 taxa / 1043 links. Exactly one version bump, v5.9 → v6.0; pending separate-entry counter resets to 0/5 toward v6.1.

## Living genera

| Genus | Common name | Placement | Classification source |
|---|---|---|---|
| Dinomys | Pacarana | Rodentia → existing Dinomyidae | [ASM Mammal Diversity Database](https://www.mammaldiversity.org/taxon/1001237/) |
| Daubentonia | Aye-aye | Primates → new Daubentoniidae | [Naturalis](https://lemurs.linnaeus.naturalis.nl/linnaeus_ng/app/views/species/nsr_taxon.php?epi=148&id=112586), [USFWS](https://www.fws.gov/species/daubentonia-daubentonia) |
| Cryptoprocta | Fossa | Carnivora → new Eupleridae | [Taxonomic treatment via GBIF](https://www.gbif.org/dataset/42812098-88b0-4d43-bdb1-9dccf92aaa47/taxon/D51587EFFFEA9A30F0C41DFDFCB9F762.taxon) |
| Heterocephalus | Naked mole-rats | Rodentia → new Heterocephalidae | [ASM Mammal Diversity Database](https://www.mammaldiversity.org/family/heterocephalidae/), [family revision](https://doi.org/10.1111/zoj.12201) |
| Balaeniceps | Shoebill | Pelecaniformes → new Balaenicipitidae | [UCI bird collection](https://avise-birds.bio.uci.edu/pelecaniformes/balaenicipitidae/balaeniceps_rex/index.html) |
| Sagittarius | Secretary bird | Accipitriformes → new Sagittariidae | [USFWS taxonomy](https://www.fws.gov/taxonomic-tree/1678756) |
| Mitsukurina | Goblin sharks | Lamniformes → new Mitsukurinidae | [NPFC shark classification](https://www.npfc.int/system/files/2024-11/NPFC-2024-SC09-OP05%20Taxonomic%20list%20of%20deep-water%20sharks%20NPFC.pdf) |
| Chlamydoselachus | Frilled sharks | Selachii → new Hexanchiformes → new Chlamydoselachidae | [NPFC shark classification](https://www.npfc.int/system/files/2024-11/NPFC-2024-SC09-OP05%20Taxonomic%20list%20of%20deep-water%20sharks%20NPFC.pdf) |
| Architeuthis | Giant squid | Cephalopoda → new Oegopsida → new Architeuthidae | [NHM hierarchy](https://www.nhm.ac.uk/our-science/data/uk-species/hierarchy?orgKey=NBNORG0000114369), [systematic revision](https://doi.org/10.1093/zoolinnean/zlab069) |
| Odontodactylus | Peacock mantis shrimp and relatives | Malacostraca → new Stomatopoda → new Odontodactylidae | [JAMSTEC](https://www.godac.jamstec.go.jp/bismal/e/view/0003863), [WoRMS](https://www.marinespecies.org/aphia.php?id=196129&p=taxdetails) |

## Extinct genera

| Genus | Description | Placement | Classification source |
|---|---|---|---|
| Raphus | Dodo | Existing Columbidae | [MNHN taxonomy](https://science.mnhn.fr/taxon/genus/raphus) |
| Hesperornis | Flightless toothed diving bird | Maniraptora → new Hesperornithiformes → new Hesperornithidae | [Smithsonian specimen](https://www.si.edu/object/nmnhpaleobiology_3368539), [stem-bird research](https://pmc.ncbi.nlm.nih.gov/articles/PMC7281208/) |
| Allosaurus | Jurassic predatory theropod | Theropoda → new Allosauridae | [Museum specimen classification](https://paleo.iri.isu.edu/ViewSpecimen.aspx?id=268), [Utah Geological Survey monograph](https://ugspub.nr.utah.gov/publications/bulletins/B-109.pdf) |
| Carnotaurus | Horned abelisaurid theropod | Theropoda → new Abelisauridae | [Abelisaurid research](https://pmc.ncbi.nlm.nih.gov/articles/PMC3197156/) |
| Diplodocus | Long-necked sauropod | Sauropoda → new Diplodocidae | [Smithsonian specimen](https://www.si.edu/object/nmnhpaleobiology_3449067) |
| Psittacosaurus | Early parrot-beaked ceratopsian | Ornithischia → new Psittacosauridae | [Smithsonian specimen](https://postalmuseum.si.edu/object/nmnhpaleobiology_3383532) |
| Rhamphorhynchus | Long-tailed pterosaur | Pterosauria → new Rhamphorhynchidae | [Pterosaur dietary review](https://pmc.ncbi.nlm.nih.gov/articles/PMC6849529/) |
| Inostrancevia | Large sabre-toothed synapsid | Existing Gorgonopsidae (broad traditional usage) | [Gorgonopsian systematic review](https://pmc.ncbi.nlm.nih.gov/articles/PMC5995105/), [comparative anatomy](https://pmc.ncbi.nlm.nih.gov/articles/PMC4730894/) |
| Basilosaurus | Long-bodied early whale | Cetacea → new Basilosauridae | [Smithsonian specimen](https://www.si.edu/object/nmnhpaleobiology_3342381) |
| Olenoides | Spiny Cambrian trilobite | Trilobita → new Corynexochida → new Dorypygidae | [Treatise on Invertebrate Paleontology](https://trilobite.treatise.geolex.org/displayInfo.php?genera=Olenoides) |
| Anurognathus | Small insect-eating pterosaur | Pterosauria → new Anurognathidae | [Anurognathid study](https://pmc.ncbi.nlm.nih.gov/articles/PMC10093155/), [dietary review](https://pmc.ncbi.nlm.nih.gov/articles/PMC6849529/) |

## Placement decisions

- Follow the existing chart's family-level layout; add missing families/orders for these requested animals without adding every intermediate clade.
- Hesperornis is outside the chart's crown-bird Aves node, matching Ichthyornis under Maniraptora. Hesperornithiformes is an extinct order, not a modern bird order inside crown Aves.
- Anurognathidae and Rhamphorhynchidae sit directly under Pterosauria. No disputed intermediate pterosaur clades are imposed.
- Inostrancevia uses the chart's existing broad traditional Gorgonopsidae grouping. Published narrower family delimitations and Russian/African subclades vary; this addition does not assert a resolved relationship within that group or restructure existing entries.
- Basilosauridae is used in its traditional extinct early-whale sense. Existing Perucetus stays in its previous position directly under Cetacea; the user did not request reclassification of existing entries. The user-directed Pakicetus → Ambulocetus → Cetacea stem remains unchanged.
- Balaeniceps follows the modern Pelecaniformes placement; some older museum catalogues retain Ciconiiformes.
- Heterocephalus follows the current Mammal Diversity Database's Heterocephalidae rather than older Bathyergidae treatments.
- Oegopsida is an order under Cephalopoda. Existing Loligo remains in its current Loliginidae branch; this update does not broaden into restructuring other cephalopods.
- Extant genera that also include extinct species, such as Cryptoprocta, retain normal genus borders. All 11 wholly extinct added genera and their wholly extinct support nodes have red borders and daggers, with their true rank fills preserved.

## Verification

Both charts: 1044 nodes / 1043 links, one LUCA root, no runtime errors, matching parents/titles/subtitles/ranks/accents apart from documented context overrides. No existing ID, scientific title or parent changed. Card world 58317 × 4400, zero card overlaps, zero unrelated-card connector crossings, all titles fit. D3 has zero node overlaps; existing curved-link crossings elsewhere are not reclassified as a regression. All 21 new genus searches plus common-name variants checked in both views (66 search checks), and both v6.0 release notes list every added genus. Editor regression suite passes, including phone layout, save/reload, backups and image navigation. Shared editor/config bytes unchanged; no saved-content keys or user storage changed. Temporary positions export removed before publication.
