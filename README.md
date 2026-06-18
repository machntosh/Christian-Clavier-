# Clavier FR familier / QC

Clavier iOS (app + Keyboard Extension) qui corrige les fautes fréquentes du
français **sans trahir le registre familier / québécois**. Voir `docs/` pour le
cadrage complet (faisabilité, PRD, architecture, issues, journaux).

## Structure

```
Package.swift              # SharedCore : logique pure, testable (swift test)
Sources/SharedCore/        # Moteur de correction en couches + données
Tests/SharedCoreTests/     # Tests XCTest (corpus, fallback, IPC, perf)
App/                       # App principale (SwiftUI) — réglages/onboarding
Keyboard/                  # Keyboard Extension (UIKit)
project.yml                # Manifeste XcodeGen (génère le .xcodeproj)
docs/                      # Cadrage et suivi
```

## Principe d'architecture

- Toute la logique métier vit dans **SharedCore**, validable **sans Xcode ni
  device** via `swift test`.
- L'app et l'extension sont des coquilles fines au-dessus.
- Pipeline de correction **en couches court-circuitables** (apostrophe → accent
  → faute usuelle → contraction → homophone → distance d'édition). La frappe
  brute ne dépend d'aucune couche : **dégradation gracieuse** garantie.
- App Group = enrichissement (réglages partagés), **jamais** une dépendance
  dure : sans « Full Access », le clavier fonctionne avec ses défauts embarqués.

## Valider la logique (sur une machine avec Swift)

```bash
swift test            # exécute toute la suite SharedCore
swift test --filter DeterministicCorrectionTests
```

## Générer et ouvrir le projet iOS (macOS + Xcode requis)

```bash
brew install xcodegen
xcodegen generate     # produit ClavierFR.xcodeproj depuis project.yml
open ClavierFR.xcodeproj
```

## État de validation

⚠️ Le code a été **écrit puis revu** mais **pas compilé dans l'environnement de
développement** (Linux, sans toolchain Swift ni Xcode). La compilation, les
tests `swift test` et les POC device (mémoire/jetsam, latence, stabilité de la
barre) restent à exécuter sur macOS/iOS. Détail dans `docs/status.md`.
