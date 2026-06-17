# Document de faisabilité — Clavier FR familier / QC

> Statut : v1 (cadrage initial). À réviser après les POC de la Phase 0.
> Dernière mise à jour : 2026-06-17

## 1. Cadre du problème

On veut un **clavier iOS** (Keyboard Extension) qui corrige l'orthographe et
une partie de la grammaire du français **familier / québécois**, sans écraser
le registre familier voulu par l'utilisateur.

La difficulté n'est pas linguistique en premier lieu : elle est **systémique**.
Une Keyboard Extension iOS est un environnement très contraint. La majorité des
échecs de ce type de produit viennent de là, pas de l'algorithme de correction.

## 2. Verrous critiques (les vrais risques)

| # | Verrou | Pourquoi c'est critique |
|---|--------|--------------------------|
| V1 | **Budget mémoire de l'extension** | Les keyboard extensions sont tuées (« jetsam ») au-delà d'un seuil bas (historiquement ~48 Mo, variable selon iOS/device). Dépassement = crash silencieux du clavier. C'est LE verrou n°1. |
| V2 | **App Group / Full Access** | L'accès fiable au conteneur partagé (App Group) et au réseau nécessite que l'utilisateur active « Allow Full Access ». Sans ça, l'extension doit fonctionner en autonomie. |
| V3 | **Contexte texte limité** | `UITextDocumentProxy` ne donne que `documentContextBeforeInput` / `AfterInput`, souvent tronqué, parfois vide (champs sécurisés). Pas de lecture fiable du document complet. |
| V4 | **Latence par frappe** | La correction doit rester sous le seuil de perception (~30-50 ms) sinon le clavier « rame » et devient inutilisable. |
| V5 | **Pas d'autocorrection native** | iOS ne prête pas son moteur d'autocorrection aux claviers tiers. Tout (suggestion bar incluse) est à reconstruire. |
| V6 | **Revue App Store** | Un clavier Full Access qui « voit » les frappes subit une revue de confidentialité renforcée. Justification et politique de données obligatoires. |

## 3. Matrice faisable / risqué / infaisable

### ✅ Faisable (confiance élevée, sans POC bloquant)

- Clavier QWERTY/AZERTY de base + suggestion bar maison.
- Corrections **déterministes** par table :
  - apostrophes (`lami` → `l'ami`, `jai` → `j'ai`),
  - accents fréquents (`ecole` → `école`, `etre` → `être`) par dictionnaire,
  - contractions familières configurables (`je suis` ↔ `chu`, `il faut` ↔ `faut`),
  - fautes usuelles (`malgré que`, `aujourd'hui`, `parmi`, `quand même`).
- Dictionnaire FR **compact embarqué** pour la vérification d'appartenance
  (structure type trie/bloom filter) — sous réserve de mesure mémoire (V1).
- Profils de registre (familier QC / familier FR / standard) comme **données**.
- Whitelist / blacklist utilisateur (local d'abord, App Group en bonus).
- Dégradation gracieuse : si une couche tombe, le clavier tape quand même.

### ⚠️ Risqué — à valider par POC avant de s'engager

- **Taille réelle du dictionnaire tenable** dans le budget mémoire (V1).
- **Communication app ↔ extension** sans Full Access, et qualité de
  dégradation quand Full Access est absent (V2).
- **Suggestions par distance d'édition** (Levenshtein/Damerau) en temps réel
  sur un gros lexique : faisable seulement avec index adapté (V4).
- **Homophones contextuels** (`a`/`à`, `et`/`est`, `ce`/`se`, `ces`/`ses`/`c'est`)
  avec le contexte limité du proxy (V3) — partiel, pas garanti.
- **Stabilité de la suggestion bar** sous frappe rapide / rotation / changement
  de champ (cycle de vie de l'extension).

### ❌ Probablement infaisable pour le MVP (à isoler en spike, hors cœur)

- **Modèle ML / LLM embarqué dans l'extension** : incompatible avec V1 en l'état.
  → Doit rester un spike optionnel, jamais une dépendance du MVP.
- **Analyse grammaticale profonde / syntaxe complète** en temps réel sous
  contrainte mémoire (accords complexes, conjugaison généralisée).
- **Analyse du document entier** : la limitation du proxy (V3) l'empêche.
- **Correction via LLM réseau** : nécessite Full Access + soulève
  confidentialité, latence et coût. Hors MVP.

## 4. Hypothèses à vérifier par prototype (entrées de la Phase 0)

| ID | Hypothèse | POC | Critère de validation |
|----|-----------|-----|------------------------|
| H1 | L'extension reste sous le seuil jetsam avec un dico FR compact chargé | POC-MEM | Pic mémoire mesuré < 80 % du seuil observé, pas de jetsam en usage soutenu |
| H2 | App ↔ extension communiquent via App Group quand Full Access est ON, et dégradent proprement quand OFF | POC-IPC | Lecture/écriture OK avec Full Access ; fallback embarqué OK sans |
| H3 | Le dico se charge assez vite et tient en mémoire (mmap/format binaire) | POC-DICT | Chargement < 200 ms, pas de pic mémoire fatal |
| H4 | La suggestion bar reste stable (pas de crash/freeze) sous stress | POC-BAR | 0 crash sur séquence de stress scriptée |
| H5 | La correction déterministe répond sous le seuil de perception | POC-LAT | p95 latence par frappe < 30-50 ms |
| H6 | Le clavier reste fonctionnel si une couche avancée est désactivée/échoue | POC-FALLBACK | Frappe + corrections de base OK avec couches avancées coupées |

## 5. Conclusion de faisabilité (provisoire)

Le produit est **réaliste en MVP** s'il se limite à un moteur **déterministe
local** avec dictionnaire compact, suggestion bar maison et profils de registre,
le tout protégé par une dégradation gracieuse. Les ambitions ML/contextuelles
lourdes doivent rester **expérimentales et isolées**. Aucune décision
architecturale lourde ne doit être figée avant les POC H1–H6.
