# Journal des problèmes

> Format par problème : ID · date · issue liée · sévérité · symptôme · analyse ·
> correction tentée · résultat · statut.
>
> Sévérité : `critique` · `majeure` · `mineure`.
> Statut : `ouvert` · `résolu` · `contourné` · `bloqué`.
>
> Priorité de traitement : tout ce qui menace la stabilité de l'extension, la
> mémoire, les crashs, la réactivité clavier, ou crée une régression de
> correction passe en premier.

---

### PROB-001
- **Date** : 2026-06-18
- **Issue liée** : ISSUE-101 / Phase 0
- **Sévérité** : majeure
- **Symptôme** : impossible de compiler ou d'exécuter le code Swift dans
  l'environnement de développement.
- **Contexte** : environnement d'exécution Linux, sans toolchain Swift ni Xcode.
- **Hypothèse cause** : `swift` absent ; le paquet apt « swift » est le stockage
  objet OpenStack, pas le langage ; `download.swift.org` bloqué par la politique
  réseau (`host_not_allowed`).
- **Correction tentée** : vérification toolchain (`which swift`, `swift
  --version`), test réseau vers download.swift.org, recherche apt.
- **Résultat** : aucune toolchain installable ici. Le code SharedCore a été
  conçu comme Swift Package autonome pour être validé via `swift test` dès
  qu'un Mac est disponible ; une relecture manuelle a été faite à la place.
- **Statut** : contourné. Mise à jour 2026-06-19 : l'utilisateur n'a pas de Mac
  (Xcode étant macOS-only). Validation déléguée à **GitHub Actions**
  (`.github/workflows/ci.yml`) — `swift test` sur runner Linux + build iOS sur
  runner macOS hébergé, sans Mac local. La logique SharedCore peut aussi être
  testée localement via la toolchain Swift officielle pour Windows.


<!--
Gabarit à copier pour chaque nouvelle entrée :

### PROB-001
- **Date** : YYYY-MM-DD
- **Issue liée** :
- **Sévérité** : critique | majeure | mineure
- **Symptôme** :
- **Contexte** :
- **Hypothèse cause** :
- **Correction tentée** :
- **Résultat** :
- **Statut** : ouvert | résolu | contourné | bloqué
-->
