# ShipFlow Model Routing

Vérifié contre les docs OpenAI le 2026-04-24.

Cette référence doit rester courte. Si une question dépend du "latest", de la disponibilité exacte ou d'un changement récent, revalider contre la doc OpenAI officielle avant de répondre.

## Short model map

- `gpt-5.5`
  - modèle premium actuel pour tâches complexes, ambiguës ou à fort coût d'erreur
  - disponible dans Codex avec contexte 400K
  - plus cher par token que `gpt-5.4`, donc à réserver aux cas où la qualité prime
- `gpt-5.4`
  - option premium équilibrée quand `gpt-5.5` serait surdimensionné
  - bon choix pour architecture et arbitrages importants avec meilleur contrôle du coût
- `gpt-5.4-mini`
  - meilleur point d'entrée vitesse/coût/qualité pour petites et moyennes tâches
  - bon choix pour triage, exploration, sous-tâches et itérations répétées
- `gpt-5.3-codex`
  - spécialisé coding agentique
  - bon fit pour refacto, debugging long, sessions d'implémentation multi-fichiers, usage intensif des outils
- `gpt-5.3-codex-spark`
  - à utiliser quand la vitesse locale prime, surtout pour deltas UI ou changements ciblés
- `gpt-5.2`
  - génération précédente
  - à éviter par défaut, sauf continuité de comportement ou préférence utilisateur

## Routing matrix

| Situation | Primary | Reasoning | Fast fallback | Cheap fallback |
| --- | --- | --- | --- | --- |
| Spec ambiguë, arbitrage, architecture | `gpt-5.5` | `high` | `gpt-5.4` | `gpt-5.4-mini` |
| Implémentation multi-fichiers, refacto, bug difficile | `gpt-5.3-codex` | `medium` ou `high` | `gpt-5.3-codex-spark` | `gpt-5.4-mini` |
| Petite feature claire, fix local, triage | `gpt-5.4-mini` | `medium` | `gpt-5.3-codex-spark` | `gpt-5.4-mini` |
| Itération UI ciblée | `gpt-5.3-codex-spark` | `low` ou `medium` | `gpt-5.4-mini` | `gpt-5.4-mini` |
| Longue boucle agentique en terminal | `gpt-5.3-codex` | `medium` | `gpt-5.5` | `gpt-5.4-mini` |
| Budget serré sur une dizaine de petits chantiers | `gpt-5.4-mini` | `low` ou `medium` | `gpt-5.3-codex-spark` | `gpt-5.4-mini` |

## Default heuristics

- Si tu hésites entre `gpt-5.5` et `gpt-5.3-codex` :
  - prends `gpt-5.5` si le problème est surtout de comprendre, décider et limiter le risque d'erreur
  - prends `gpt-5.3-codex` si le problème est surtout d'exécuter proprement dans le code
- Si tu hésites entre `gpt-5.5` et `gpt-5.4` :
  - prends `gpt-5.5` si l'erreur coûterait cher ou que le scope est très ambigu
  - prends `gpt-5.4` si la tâche reste premium mais bornée, ou si le budget est contraint
- Si tu hésites entre `gpt-5.4-mini` et un plus gros modèle :
  - démarre avec `gpt-5.4-mini` si la tâche est réversible et bien bornée
  - monte d'un cran seulement si tu observes de la dérive, des oublis ou des boucles inutiles
- Si tu passes déjà par `sf-spec` puis `sf-ready` :
  - la clarté du contrat réduit le besoin d'un gros modèle
  - beaucoup de tâches deviennent de bons candidats pour `gpt-5.4-mini` ou `gpt-5.3-codex`

## Cost notes (Codex)

- D'après la rate card OpenAI (mise à jour 2026-04-23), `gpt-5.5` est environ 2x plus cher par token que `gpt-5.4`.
- `gpt-5.5` peut néanmoins rester rentable sur des tâches difficiles si le nombre total de tentatives baisse.
- En cas de doute coût/qualité, commencer par `gpt-5.4`, puis upgrader vers `gpt-5.5` seulement si la qualité n'est pas au niveau attendu.
