# Journal des décisions

> Format : ID · date · décision · contexte · alternatives · conséquences · statut.
> Dernière mise à jour : 2026-06-17

---

### D1 — Trois cibles : App / Extension / SharedCore
- **Date** : 2026-06-17
- **Décision** : séparer App principale, Keyboard Extension et un framework
  partagé SharedCore contenant toute la logique métier.
- **Contexte** : besoin de testabilité hors UI et de réutilisation app/extension.
- **Alternatives** : tout dans l'extension (non testable, couplé) ; logique
  dupliquée (dérive). Rejetées.
- **Conséquences** : logique testable en `swift test`, extension/app fines.
- **Statut** : acceptée (cadrage).

### D2 — MVP 100 % local et déterministe
- **Date** : 2026-06-17
- **Décision** : le MVP ne dépend ni du réseau ni d'un modèle ML embarqué.
- **Contexte** : contraintes mémoire (V1) et confidentialité/revue (V6).
- **Alternatives** : LLM embarqué (incompatible mémoire au MVP) ; LLM réseau
  (Full Access requis, latence, confidentialité). Repoussées en spike.
- **Conséquences** : fonctionne hors-ligne, sans Full Access, faible risque.
- **Statut** : acceptée (cadrage).

### D3 — Dégradation gracieuse en couches court-circuitables
- **Date** : 2026-06-17
- **Décision** : pipeline en 5 couches (0 frappe → 4 expérimental), chacune
  désactivable ; la frappe brute ne dépend d'aucune couche de correction.
- **Contexte** : exigence de stabilité et de dégradation gracieuse.
- **Alternatives** : pipeline monolithique (un échec casse tout). Rejetée.
- **Conséquences** : robustesse maximale, complexité de coordination maîtrisée.
- **Statut** : acceptée (cadrage).

### D4 — App Group = enrichissement, pas dépendance dure
- **Date** : 2026-06-17
- **Décision** : profils/listes lus via App Group si Full Access ON, sinon
  valeurs embarquées par défaut.
- **Contexte** : Full Access optionnel côté utilisateur (V2).
- **Alternatives** : exiger Full Access (friction, refus possible). Rejetée.
- **Conséquences** : produit utile sans Full Access ; bonus si activé.
- **Statut** : acceptée (cadrage).

### D5 — Phase 0 bloquante avant implémentation lourde
- **Date** : 2026-06-17
- **Décision** : exécuter les POC H1–H6 avant de figer l'architecture du moteur
  et la taille du dictionnaire.
- **Contexte** : risques mémoire/IPC/latence non vérifiés empiriquement.
- **Alternatives** : coder directement (risque de tout refaire). Rejetée.
- **Conséquences** : décisions de taille/format pilotées par mesure.
- **Statut** : acceptée (cadrage).
