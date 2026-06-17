# PRD — Clavier iOS français familier / québécois

> Statut : v1 (cadrage). Dernière mise à jour : 2026-06-17

## 1. Vision produit

Un clavier iOS qui aide à **écrire un français correct sans trahir le ton
familier** de l'utilisateur. Il corrige d'abord ce qui agace le plus au
quotidien (apostrophes, accents, contractions, fautes usuelles, homophones
fréquents) tout en **préservant l'argot et le registre choisi** (familier QC,
familier FR, standard). Promesse centrale : *« ça reste ma façon de parler,
mais sans les fautes bêtes »*.

## 2. Cas d'usage

- **U1** — J'écris vite un message : `jai oublié decole` → `j'ai oublié d'école`
  proposé, sans toucher à mon « decole » si je l'ajoute en whitelist.
- **U2** — Registre QC : je tape `chu tanné`, le clavier **ne le corrige pas**
  en « je suis » car le profil familier QC est actif.
- **U3** — Homophone fréquent : `je v a la maison` → suggestion `vais à`.
- **U4** — Faute usuelle : `malgré que` → suggestion `bien que` (info, non forcée).
- **U5** — Je désactive Full Access : le clavier corrige quand même avec son
  dictionnaire embarqué.
- **U6** — Je gère ma liste perso de mots (slang, prénoms, marques) dans l'app.

## 3. Non-objectifs (MVP)

- Pas de correction grammaticale profonde / analyse syntaxique complète.
- Pas de modèle LLM embarqué ni d'appel réseau obligatoire.
- Pas d'analyse du document entier (impossible via le proxy).
- Pas de multi-langue : FR uniquement au départ.
- Pas de prédiction de mot « next-word » avancée au MVP (option ultérieure).

## 4. Contraintes iOS (rappel, détail dans feasibility.md)

- Budget mémoire extension très bas (seuil jetsam ~48 Mo, à mesurer).
- App Group / réseau conditionnés à « Allow Full Access ».
- Contexte texte limité et parfois vide via `UITextDocumentProxy`.
- Latence par frappe critique (< 30-50 ms visé).
- Suggestion bar et logique d'autocorrection entièrement maison.

## 5. Architecture cible (résumé ; détail dans architecture.md)

Trois cibles : **App principale**, **Keyboard Extension**, **SharedCore**
(framework de logique partagée). Le moteur de correction déterministe vit dans
SharedCore et tourne **dans l'extension**, en local, sans dépendance externe.

## 6. Plan de dégradation gracieuse

| Couche | Si elle échoue / absente | Comportement |
|--------|--------------------------|--------------|
| LLM / contextuel avancé (futur) | Toujours optionnel | Ignorée, aucune régression |
| Homophones contextuels | Contexte vide ou erreur | On saute, corrections déterministes maintenues |
| App Group (profil, listes perso) | Full Access OFF | On utilise profil + dico **embarqués** par défaut |
| Dictionnaire de suggestions | Chargement échoue | On garde les corrections par **table déterministe** |
| Tout le moteur | Exception | Le clavier **tape quand même** les touches (jamais de blocage) |

Principe : **chaque couche supérieure est facultative**. La frappe brute ne
dépend d'aucune couche de correction.

## 7. Critères de succès (MVP)

- Le clavier s'installe, tape, et corrige les fautes fréquentes ciblées.
- ≥ 90 % de réussite sur un jeu de test de corrections déterministes.
- Le registre familier actif n'est jamais « sur-corrigé » (0 faux positif sur
  le lexique du profil).
- Fonctionne **sans Full Access** (mode dégradé documenté).

## 8. Critères de stabilité

- 0 crash de l'extension sur la suite de stress (frappe rapide, rotation,
  changements de champ, champs sécurisés).
- Pas de jetsam sur session prolongée (mémoire sous seuil mesuré).
- Aucune frappe perdue ou dupliquée sous charge.

## 9. Stratégie de test (résumé ; détail dans test-strategy.md)

Tests unitaires sur SharedCore (corrections déterministes, profils, listes),
tests de perf (latence, mémoire), tests de stress UI sur l'extension, jeux de
données linguistiques par profil.

## 10. Stratégie de mesure perf mémoire / latence

- Mémoire : `os_proc_available_memory()` / instruments, journalisation du pic
  en debug, alerte si on approche le seuil.
- Latence : horodatage autour du pipeline de correction, p50/p95 loggés en debug.
- Budget cible : mémoire < 80 % du seuil jetsam mesuré ; latence p95 < 50 ms.

## 11. Registre et personnalisation utilisateur

- **Profils** : `familier_qc`, `familier_fr`, `standard` (sélectionnables).
  Chaque profil porte un lexique « à ne pas corriger » + règles de contraction.
- **Whitelist** : mots que l'utilisateur protège (jamais corrigés).
- **Blacklist** : corrections qu'il refuse systématiquement.
- **Réglages** : intensité de correction (off / suggérer / agressif),
  apostrophes auto on/off, accents auto on/off.
- Personnalisation gérée dans l'app, partagée via App Group (si Full Access),
  avec valeurs par défaut embarquées sinon.
