# État d'avancement

> Dernière mise à jour : 2026-06-17

## Phase courante

**Cadrage (pré-Phase 0)** — documents de cadrage produits, en attente de
validation du plan par le porteur du produit avant toute implémentation lourde.

## Résumé

- Repo initialisé à blanc sur la branche `claude/ios-french-keyboard-app-tcv14r`.
- 8 documents de cadrage créés dans `docs/`.
- Matrice faisable / risqué / infaisable établie (voir `feasibility.md`).
- Plan en phases (0 → 5) et issues exécutables défini (voir `issues.md`).
- **Aucune ligne de code produit ni de POC lancé** : on attend le go.

## Ce qui est validé

- Aucun élément validé empiriquement (pas encore de POC).
- Décisions de cadrage D1–D5 actées (voir `decision-log.md`).

## Ce qui reste risqué (à valider par POC en Phase 0)

- H1 mémoire extension · H2 App Group / Full Access · H3 chargement dico ·
  H4 stabilité suggestion bar · H5 latence · H6 fallback.

## Ce qui doit probablement être abandonné / repoussé

- Modèle ML/LLM embarqué dans l'extension (spike seulement, hors MVP).
- Correction grammaticale profonde temps réel.
- Analyse du document entier (limite du proxy).
- Correction via LLM réseau (Full Access + confidentialité + latence).

## Avancement par phase

| Phase | Intitulé | Statut |
|-------|----------|--------|
| 0 | POC critiques | non démarrée |
| 1 | Squelette app + extension | non démarrée |
| 2 | Moteur déterministe | non démarrée |
| 3 | Homophones contextuels | non démarrée |
| 4 | Personnalisation | non démarrée |
| 5 | Robustesse / perf / polish | non démarrée |

## Prochaine action

Validation du plan, puis démarrage **Phase 0 / ISSUE-101** (bootstrap projet)
en préalable aux POC mémoire et IPC.

## Journal de mise à jour

- 2026-06-17 — Création des 8 documents de cadrage. Plan présenté pour validation.
