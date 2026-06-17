# Issues — Découpage en phases

> Statut : v1 (cadrage). Aucune issue démarrée. En attente de validation du plan.
> Format par issue : ID · titre · phase · priorité · dépendances · description ·
> acceptance criteria · validation commands · status.
>
> Statuts possibles : `todo` · `in-progress` · `blocked` · `done` · `dropped`.

---

## Phase 0 — Faisabilité / spikes / POC critiques

### POC-MEM
- **Titre** : Mesurer la mémoire réelle de l'extension avec dico chargé
- **Phase** : 0 · **Priorité** : P0 (bloquant) · **Dépendances** : ISSUE-101
- **Description** : Charger un dico FR compact dans l'extension, mesurer le pic
  mémoire en usage soutenu, identifier le seuil jetsam sur device cible.
- **Acceptance** : pic mesuré documenté ; verdict si un dico utile tient sous
  80 % du seuil ; décision sur la taille/format du dico.
- **Validation** : run sur device réel + Instruments (Allocations), log du pic
  via `os_proc_available_memory()`. Résultat consigné dans `problem-log` si KO.
- **Status** : todo

### POC-IPC
- **Titre** : Communication app ↔ extension via App Group
- **Phase** : 0 · **Priorité** : P0 · **Dépendances** : ISSUE-101
- **Description** : Écrire un réglage dans l'app, le lire dans l'extension via
  App Group, avec et sans Full Access. Valider la dégradation.
- **Acceptance** : lecture/écriture OK avec Full Access ; sans Full Access, le
  fallback embarqué fonctionne sans crash.
- **Validation** : test manuel scripté ON/OFF Full Access + assertion logguée.
- **Status** : todo

### POC-DICT
- **Titre** : Chargement et perf du dictionnaire
- **Phase** : 0 · **Priorité** : P0 · **Dépendances** : POC-MEM
- **Description** : Comparer formats (texte, binaire, mmap) pour temps de
  chargement et empreinte mémoire.
- **Acceptance** : chargement < 200 ms, pas de pic fatal, format retenu décidé.
- **Validation** : `swift test --filter DictLoadPerf` (PerfTests).
- **Status** : todo

### POC-BAR
- **Titre** : Stabilité de la suggestion bar sous stress
- **Phase** : 0 · **Priorité** : P0 · **Dépendances** : ISSUE-101
- **Description** : Séquence de stress (frappe rapide, rotation, changement de
  champ, champ sécurisé) sur une suggestion bar minimale.
- **Acceptance** : 0 crash / 0 freeze sur la séquence.
- **Validation** : test UI scripté sur l'extension.
- **Status** : todo

### POC-LAT
- **Titre** : Latence de correction locale
- **Phase** : 0 · **Priorité** : P0 · **Dépendances** : POC-DICT
- **Description** : Mesurer la latence du pipeline déterministe par frappe.
- **Acceptance** : p95 < 50 ms (cible 30 ms).
- **Validation** : `swift test --filter CorrectionLatency`.
- **Status** : todo

### POC-FALLBACK
- **Titre** : Fallback si une couche avancée échoue
- **Phase** : 0 · **Priorité** : P0 · **Dépendances** : POC-MEM, POC-IPC
- **Description** : Forcer l'échec des couches 2/3/4 et vérifier que la frappe
  + corrections de base restent OK.
- **Acceptance** : clavier pleinement utilisable couches avancées coupées.
- **Validation** : `swift test --filter FallbackChain`.
- **Status** : todo

> **Règle Phase 0** : si un POC invalide une hypothèse (H1–H6), on met à jour
> `architecture.md`, `decision-log.md` et ces issues **avant** de continuer.

---

## Phase 1 — Squelette app + extension stable

### ISSUE-101
- **Titre** : Bootstrap projet Xcode (App + Extension + SharedCore)
- **Phase** : 1 · **Priorité** : P0 · **Dépendances** : —
- **Description** : Créer les 3 cibles, App Group, signatures, dispo de
  l'extension, CI de build.
- **Acceptance** : le projet build ; le clavier apparaît et tape ; SharedCore
  est lié aux deux cibles.
- **Validation** : `xcodebuild -scheme ClavierFR build` ; `swift build`.
- **Status** : todo

### ISSUE-102
- **Titre** : Clavier de base + frappe brute (Couche 0)
- **Phase** : 1 · **Priorité** : P0 · **Dépendances** : ISSUE-101
- **Description** : Disposition de touches, insertText/deleteBackward, bascule
  AZERTY, espace, retour. Aucune correction encore.
- **Acceptance** : on peut écrire un texte complet sans correction, sans crash.
- **Validation** : test UI de frappe basique + build.
- **Status** : todo

### ISSUE-103
- **Titre** : Suggestion bar (coquille)
- **Phase** : 1 · **Priorité** : P1 · **Dépendances** : ISSUE-102, POC-BAR
- **Description** : Barre à 3 emplacements de suggestions, branchée à vide.
- **Acceptance** : barre stable, tap insère le texte d'un emplacement de test.
- **Validation** : test UI scripté + build.
- **Status** : todo

---

## Phase 2 — Moteur local de corrections déterministes

### ISSUE-201
- **Titre** : Pipeline de correction déterministe (Couche 1)
- **Phase** : 2 · **Priorité** : P0 · **Dépendances** : ISSUE-103, POC-LAT
- **Description** : Apostrophes, espaces, table de fautes usuelles, accents
  fréquents. Sortie = suggestions ordonnées.
- **Acceptance** : ≥ 90 % de réussite sur le jeu de test déterministe ; p95 < 50 ms.
- **Validation** : `swift test --filter DeterministicCorrection`.
- **Status** : todo

### ISSUE-202
- **Titre** : Vérification d'appartenance lexicale + format dico
- **Phase** : 2 · **Priorité** : P0 · **Dépendances** : POC-DICT, ISSUE-201
- **Description** : Intégrer le dico au format retenu, API `contains(word)`.
- **Acceptance** : lookup correct, mémoire sous budget, chargement OK.
- **Validation** : `swift test --filter DictionaryLookup`.
- **Status** : todo

### ISSUE-203
- **Titre** : Suggestions par distance d'édition (Couche 2)
- **Phase** : 2 · **Priorité** : P1 · **Dépendances** : ISSUE-202
- **Description** : Candidats Damerau-Levenshtein ≤ 2 via index, classés.
- **Acceptance** : suggestions pertinentes sur fautes courantes ; p95 < 50 ms.
- **Validation** : `swift test --filter EditDistanceSuggestions`.
- **Status** : todo

---

## Phase 3 — Moteur contextuel léger / homophones

### ISSUE-301
- **Titre** : Règles homophones sur contexte gauche (Couche 3)
- **Phase** : 3 · **Priorité** : P2 · **Dépendances** : ISSUE-201
- **Description** : `a/à`, `et/est`, `ce/se`, `ces/ses/c'est`, `ou/où`, `la/là`
  via petites règles. Best-effort, désactivable.
- **Acceptance** : gains mesurables sur jeu de test homophones, 0 régression sur
  déterministe, désactivable proprement (contexte vide ⇒ skip).
- **Validation** : `swift test --filter Homophones`.
- **Status** : todo

---

## Phase 4 — Personnalisation utilisateur

### ISSUE-401
- **Titre** : Profils de registre (QC / FR / standard)
- **Phase** : 4 · **Priorité** : P1 · **Dépendances** : ISSUE-201, POC-IPC
- **Description** : Lexiques protégés + contractions par profil ; jamais
  sur-corriger le registre actif.
- **Acceptance** : 0 faux positif sur le lexique du profil actif.
- **Validation** : `swift test --filter Profiles`.
- **Status** : todo

### ISSUE-402
- **Titre** : Whitelist / blacklist utilisateur
- **Phase** : 4 · **Priorité** : P1 · **Dépendances** : ISSUE-401
- **Description** : Édition dans l'app, partage App Group, application dans le
  moteur, fallback embarqué sans Full Access.
- **Acceptance** : mots whitelistés jamais corrigés ; corrections blacklistées
  jamais proposées ; OK sans Full Access.
- **Validation** : `swift test --filter UserLists`.
- **Status** : todo

### ISSUE-403
- **Titre** : Écran de réglages (intensité, apostrophes, accents)
- **Phase** : 4 · **Priorité** : P2 · **Dépendances** : ISSUE-402
- **Description** : UI app pour piloter le comportement du moteur.
- **Acceptance** : réglages persistés et pris en compte par l'extension.
- **Validation** : test manuel scripté + `swift test --filter Settings`.
- **Status** : todo

---

## Phase 5 — Robustesse, tests, optimisation, polish

### ISSUE-501
- **Titre** : Suite de stress de l'extension
- **Phase** : 5 · **Priorité** : P0 · **Dépendances** : Phase 1-4
- **Description** : Frappe rapide, rotation, champs sécurisés, mémoire soutenue.
- **Acceptance** : 0 crash, pas de jetsam, pas de frappe perdue.
- **Validation** : suite de stress scriptée.
- **Status** : todo

### ISSUE-502
- **Titre** : Budget perf (latence + mémoire) tenu
- **Phase** : 5 · **Priorité** : P0 · **Dépendances** : ISSUE-501
- **Description** : Vérifier p95 latence et pic mémoire sur l'ensemble du pipeline.
- **Acceptance** : p95 < 50 ms ; mémoire < 80 % du seuil.
- **Validation** : `swift test --filter Perf` + run Instruments.
- **Status** : todo

### ISSUE-503
- **Titre** : Onboarding (activation + Full Access) et polish
- **Phase** : 5 · **Priorité** : P2 · **Dépendances** : ISSUE-403
- **Description** : Guide d'activation, explication Full Access, états dégradés
  visibles, accessibilité.
- **Acceptance** : parcours d'activation clair, états dégradés compréhensibles.
- **Validation** : test manuel + revue.
- **Status** : todo
