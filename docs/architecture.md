# SPEC technique — Architecture

> Statut : v1 (cadrage). Sujet à révision après POC Phase 0.
> Dernière mise à jour : 2026-06-17

## 1. Structure Xcode (cible)

```
ClavierFR.xcodeproj (ou Package.swift + projet)
├── App/                      # Cible app principale (SwiftUI)
│   ├── ClavierFRApp.swift
│   ├── Onboarding/           # Guide d'activation + Full Access
│   ├── Settings/             # Profils, intensité, listes perso
│   └── Lists/                # Édition whitelist / blacklist
├── Keyboard/                 # Cible Keyboard Extension
│   ├── KeyboardViewController.swift
│   ├── SuggestionBar/        # Vue suggestion bar maison
│   ├── KeyLayout/            # Disposition AZERTY/QWERTY
│   └── Glue/                 # Adaptateur proxy ↔ SharedCore
├── SharedCore/               # Framework partagé (logique pure, testable)
│   ├── Correction/           # Moteur déterministe + contextuel léger
│   ├── Dictionary/           # Chargement/format dico, lookup
│   ├── Profiles/             # Modèles de registre
│   ├── UserData/             # Whitelist/blacklist, App Group store
│   ├── Telemetry/            # Mesures perf (debug)
│   └── Fallback/             # Garde-fous de dégradation
├── Resources/                # Dictionnaires, données de profils
└── Tests/
    ├── SharedCoreTests/      # Unitaires (rapides, sans UI)
    └── PerfTests/            # Latence / mémoire
```

**Règle d'or** : toute la logique métier vit dans **SharedCore** (testable hors
UI). L'extension et l'app sont des coquilles fines au-dessus.

## 2. Séparation app / extension / shared core

- **App** : onboarding, réglages, gestion des listes, écriture du profil dans
  l'App Group. Ne contient **aucune** logique de correction propre.
- **Extension** : cycle de vie clavier, capture des frappes, rendu suggestion
  bar, appel synchrone au moteur SharedCore. Budget mémoire surveillé.
- **SharedCore** : moteur, dictionnaires, profils, données utilisateur,
  fallback, télémétrie. Pur Swift, 100 % testable en ligne de commande.

## 3. Moteurs de correction (en couches, du plus sûr au plus risqué)

1. **Couche 0 — Frappe brute** : insère la touche. Ne dépend de rien.
2. **Couche 1 — Déterministe (MVP cœur)** :
   - normalisation apostrophes/espaces,
   - table de contractions selon profil,
   - accents fréquents par dictionnaire,
   - fautes usuelles par table,
   - vérification d'appartenance lexicale.
3. **Couche 2 — Suggestions par distance d'édition** : candidats par
   Damerau-Levenshtein bornée (≤ 2) sur index du dico.
4. **Couche 3 — Homophones contextuels (léger)** : règles sur petit contexte
   gauche (`a/à`, `et/est`, `ce/se`, `ces/ses/c'est`, `ou/où`, `la/là`).
   Best-effort, désactivable.
5. **Couche 4 — Expérimental (spike, hors MVP)** : modèle embarqué / réseau.
   Jamais une dépendance du MVP.

Chaque couche peut être **désactivée** indépendamment (réglage ou fallback).

## 4. Dictionnaires

- Source : lexique FR libre (ex. lexiques ouverts type Lexique/Hunspell FR),
  filtré et normalisé.
- Format embarqué : **binaire compact** (trie compressé / FST ou bloom filter
  pour l'appartenance + liste indexée pour les suggestions), chargé en
  **mmap** quand possible pour limiter la pression mémoire.
- Décision de taille pilotée par **POC-MEM / POC-DICT**, pas par envie.
- Données de profil (lexiques familiers) séparées du dico standard.

## 5. Profils utilisateur

```
Profile {
  id: "familier_qc" | "familier_fr" | "standard"
  protectedLexicon: Set<String>   // jamais corrigés
  contractions: [Rule]            // équivalences familières
  intensity: off | suggest | aggressive
}
```

## 6. Flux de données

```
Frappe → KeyboardViewController
       → Glue lit documentContextBeforeInput (si dispo)
       → SharedCore.CorrectionEngine(profil, listes)
           Couche1 → Couche2 → Couche3 (chacune court-circuitable)
       → Suggestions → SuggestionBar
       → Sélection utilisateur → proxy.insertText / deleteBackward
```

Profil + listes : lus depuis App Group (Full Access ON) sinon depuis les
valeurs **embarquées** par défaut.

## 7. Stratégie de logs

- Logs **debug uniquement** (compilés hors release) via `os_log`.
- Aucune frappe ni contenu utilisateur loggé en clair (confidentialité + revue).
- Métriques perf (latence, pic mémoire) en debug, agrégées localement.
- Journal des erreurs de couche → déclenche la dégradation, pas un crash.

## 8. Stratégie de tests (résumé)

- Unitaires SharedCore sur chaque couche + profils + listes.
- Tests de non-régression linguistique (jeux par profil).
- Tests perf (latence, mémoire) ciblés.
- Stress UI de l'extension. Détail dans `test-strategy.md`.

## 9. Décisions architecturales clés (voir decision-log.md)

- D1 : 3 cibles (App / Extension / SharedCore).
- D2 : MVP 100 % local et déterministe, sans réseau ni ML obligatoire.
- D3 : dégradation gracieuse en couches court-circuitables.
- D4 : App Group = enrichissement, jamais une dépendance dure.
