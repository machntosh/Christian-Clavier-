# État d'avancement

> Dernière mise à jour : 2026-06-18

## Phase courante

**Phase 1 (squelette) + amorce Phase 2 — code écrit, validation déléguée.**
Le bootstrap projet (ISSUE-101) et le moteur déterministe sont implémentés et
relus. Ils n'ont **pas pu être compilés ni testés** dans cet environnement
(Linux, sans Swift ni Xcode — voir PROB-001).

## Résumé

- Branche : `claude/ios-french-keyboard-app-tcv14r`.
- 8 documents de cadrage + code livrés.
- **SharedCore** (Swift Package autonome) : moteur de correction en couches,
  lexique, profils de registre, listes utilisateur, App Group store, fallback.
- **Tests XCTest** : corpus déterministe (≥ 90 % visé), registre/listes,
  couches avancées + Damerau-Levenshtein, fallback, App Group, smoke latence.
- **App** (SwiftUI) + **Keyboard Extension** (UIKit) : coquilles fonctionnelles.
- **project.yml** (XcodeGen) + entitlements App Group.

## Ce qui est validé

- Logique métier **relue manuellement** (cohérence des couches, du tri, du
  fallback, des cas du corpus).
- ⚠️ **Aucune validation par exécution** : `swift test` et build Xcode restent
  à lancer sur macOS. Tant que ce n'est pas vert, rien n'est déclaré « stable ».

## Validation sans Mac (mise en place 2026-06-19)

L'utilisateur n'a pas de Mac (Xcode est macOS-only). La validation passe par
**GitHub Actions** (`.github/workflows/ci.yml`), sans Mac local :

1. `swift test` sur runner **Linux** — valide toute la logique SharedCore.
2. `xcodegen generate` + build App/Keyboard pour simulateur sur runner
   **macOS hébergé** — vérifie que les cibles iOS compilent.

La logique SharedCore est aussi testable localement via la **toolchain Swift
officielle pour Windows**. La soumission App Store finale exigera toujours
macOS (option : cloud Mac — MacStadium / MacinCloud / EC2 Mac).

POC device **toujours bloqués hors device réel** : POC-MEM (mémoire/jetsam),
POC-LAT (latence réelle), POC-BAR (stress suggestion bar), POC-IPC (Full Access
ON/OFF). Un simulateur ne mesure pas le seuil jetsam — ce sont les preuves
restantes avant de déclarer la stabilité.

## Ce qui reste risqué / à abandonner

- Inchangé vs cadrage : ML/LLM embarqué (spike only), grammaire profonde,
  analyse document entier, LLM réseau. Voir feasibility.md.

## Avancement par phase

| Phase | Intitulé | Statut |
|-------|----------|--------|
| 0 | POC critiques | partiel (FALLBACK + IPC logiques faits ; device bloqués) |
| 1 | Squelette app + extension | code écrit (à compiler) |
| 2 | Moteur déterministe | code écrit (à tester) |
| 3 | Homophones contextuels | code écrit (sous-ensemble haute précision) |
| 4 | Personnalisation | code écrit (profils + listes + réglages app) |
| 5 | Robustesse / perf / polish | non démarrée (dépend des POC device) |

## Prochaine action

Exécuter `swift test` sur un Mac, consigner le résultat, puis lancer les POC
device (mémoire/latence/stress) pour transformer « code écrit » en « validé ».

## Journal de mise à jour

- 2026-06-17 — Création des 8 documents de cadrage. Plan présenté.
- 2026-06-18 — Bootstrap (ISSUE-101) + moteur déterministe + tests + coquilles
  iOS écrits. PROB-001 (pas de toolchain ici). Décision D6 (SPM + XcodeGen).
