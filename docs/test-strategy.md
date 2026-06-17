# Stratégie de test

> Statut : v1 (cadrage). Dernière mise à jour : 2026-06-17

## 1. Principes

- La logique vit dans **SharedCore** → testable sans UI, en ligne de commande
  (`swift test`), donc rapide et exécutable en CI.
- L'UI (app + extension) est fine → testée par tests UI ciblés et stress manuel
  scripté sur device/simulateur.
- **Aucun composant n'est déclaré stable sans preuve** (mesure ou test vert).

## 2. Niveaux de test

### 2.1 Unitaires (SharedCore)
- Couche 1 déterministe : apostrophes, accents, contractions, fautes usuelles.
- Couche 2 : suggestions par distance d'édition (qualité + bornes).
- Couche 3 : homophones (gains + non-régression).
- Profils : 0 faux positif sur lexique du registre actif.
- Listes : whitelist/blacklist appliquées.
- Fallback : chaîne de dégradation, couche par couche.

### 2.2 Non-régression linguistique
- Jeux de données par profil (`qc`, `fr`, `standard`) :
  - corpus « doit corriger » (faute → correction attendue),
  - corpus « ne doit pas toucher » (registre familier, slang, prénoms).
- Métrique : taux de réussite et taux de faux positifs, suivis dans le temps.

### 2.3 Performance
- **Latence** : p50/p95 du pipeline par frappe. Seuil : p95 < 50 ms.
- **Mémoire** : pic via `os_proc_available_memory()` + Instruments. Seuil :
  < 80 % du seuil jetsam mesuré.
- **Chargement dico** : < 200 ms.

### 2.4 Stress / stabilité (extension)
- Frappe rapide soutenue (ex. 10 frappes/s pendant N minutes).
- Rotation d'écran, changement de champ, champs sécurisés, champ vide.
- Bascule Full Access ON/OFF.
- Critère : 0 crash, 0 jetsam, 0 frappe perdue/dupliquée.

## 3. Données de test

- `Tests/Fixtures/qc.tsv`, `fr.tsv`, `standard.tsv` : `entrée → attendu`.
- `Tests/Fixtures/protect_*.txt` : termes à ne jamais corriger.
- Versionnés, étendus à chaque bug (un bug = un cas de test ajouté).

## 4. Commandes de validation

| But | Commande |
|-----|----------|
| Build complet | `xcodebuild -scheme ClavierFR build` |
| Unitaires core | `swift test` |
| Sous-ensemble | `swift test --filter <Suite>` |
| Perf | `swift test --filter Perf` |
| Mémoire | run device + Instruments (Allocations) |

## 5. Critères de sortie par phase

- **Phase 0** : POC H1–H6 statués (validé / invalidé / à revoir).
- **Phase 1** : build vert, frappe sans crash.
- **Phase 2** : ≥ 90 % réussite déterministe, latence sous seuil.
- **Phase 3** : gains homophones sans régression.
- **Phase 4** : 0 faux positif profil, listes respectées, OK sans Full Access.
- **Phase 5** : stress 0 crash, budget perf tenu.

## 6. Intégration continue

- À chaque modification significative : `swift build` + `swift test` au minimum.
- Les tests de perf et de stress tournent avant clôture de phase.
- Un test rouge bloque le passage à l'issue suivante (sauf blocage documenté
  dans `problem-log.md`).
