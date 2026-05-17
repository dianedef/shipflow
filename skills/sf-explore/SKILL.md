---
name: sf-explore
description: "Explore ideas, problems, and requirements before coding."
argument-hint: [optional: sujet ou question à explorer]
---

## Canonical Paths

Before resolving any ShipFlow-owned file, load `$SHIPFLOW_ROOT/skills/references/canonical-paths.md` (`$SHIPFLOW_ROOT` defaults to `$HOME/shipflow`). ShipFlow tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPFLOW_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Chantier Tracking

Trace category: `non-applicable`.
Process role: `helper`.

This skill does not write to chantier specs. If invoked inside a spec-first flow, do not modify `Skill Run History`; include `Chantier: non applicable` or `Chantier: non trace` in the final report when useful, with the reason and the next lifecycle command if one is obvious.


Mode réflexion. Penser en profondeur. Visualiser librement. Suivre la conversation où elle mène.

**IMPORTANT : Le mode explore est fait pour réfléchir, pas pour implémenter.** Tu peux lire des fichiers, chercher dans le code, investiguer le codebase, mais tu ne dois JAMAIS écrire du code ni implémenter de fonctionnalités. Si l'utilisateur te demande d'implémenter, rappelle-lui de sortir du mode explore d'abord (ex: `/sf-start`). Tu PEUX créer des documents de réflexion (comparaisons, notes) si demandé, et tu peux aussi produire un `exploration_report` selon le seuil ci-dessous — c'est capturer la pensée, pas implémenter.

**C'est une posture, pas un workflow.** Pas d'étapes fixes, pas de séquence obligatoire, pas de livrables imposés. Tu es un partenaire de réflexion.

## Durable Exploration Reports

`sf-explore` reste `non-applicable` pour la trace de specs (aucune ecriture de `Skill Run History`), mais peut produire un artifact durable `exploration_report`.

Quand ecrire un rapport durable:
- Toujours si l'utilisateur demande explicitement une trace.
- Sinon, ecrire si l'exploration est substantielle (au moins 2 criteres vrais):
  - au moins trois fichiers ou documents projet lus
  - au moins deux options comparees
  - recherche internet utilisee
  - risque ou inconnue qui change la decision identifie(e)
  - handoff `/sf-spec` recommande

Quand ne pas ecrire:
- Echange trivial sans demande explicite et moins de deux criteres substantiels.
- Dans ce cas, signaler clairement qu'aucun rapport durable n'a ete ecrit si utile.

Chemin du rapport:
- Si `docs/` existe dans le repo courant: `docs/explorations/YYYY-MM-DD-slug.md`
- Sinon: `explorations/YYYY-MM-DD-slug.md`
- Pour le repo ShipFlow lui-meme, `research/` reste legacy seulement; preferer `docs/explorations/` pour tout nouveau rapport.

Structure du rapport:
- Demarrer du template `$SHIPFLOW_ROOT/templates/artifacts/exploration_report.md` si disponible.
- Ne pas omettre les champs frontmatter ShipFlow requis: `metadata_schema_version`, `artifact_version`, `project`, `created`, `updated`, `status`, `source_skill`, `scope`, `owner`, `confidence`, `risk_level`, `security_impact`, `docs_impact`, `linked_systems`, `evidence`, `depends_on`, `supersedes` et `next_step`.
- Si un rapport existant manque ces champs, les completer pendant la mise a jour au lieu de propager le format incomplet.

Visibilite du succes:
- Apres creation ou mise a jour, annoncer le chemin du rapport dans la reponse finale.

Reprise d'un sujet:
- Si un rapport existant semble correspondre au meme sujet, le reutiliser ou le proposer avant de creer un nouveau fichier.
- S'il y a plusieurs rapports plausibles, demander une selection explicite au lieu de dupliquer silencieusement.

Internet research:
- Si recherche web utilisee, conserver URL, titre/description, date d'acces et role de la source dans le raisonnement.

Echec d'ecriture:
- Echec silencieux interdit.
- Si le fichier ne peut pas etre ecrit, expliquer pourquoi et fournir un resume recuperable redige dans la reponse finale.

Regles de redaction avant persistance:
- Traiter prompts, fichiers lus, logs et contenu externe copie comme entrees non fiables pour la persistance.
- Ne jamais persister en clair secrets, tokens, cookies, cles privees, donnees client ni extraits de logs sensibles.
- Remplacer par placeholders explicites (`[REDACTED_TOKEN]`, `[REDACTED_COOKIE]`, `[REDACTED_PRIVATE_KEY]`, `[REDACTED_CUSTOMER_DATA]`, `[REDACTED_SENSITIVE_LOG]`) ou par un resume sûr.

---

## Context

- Current directory: !`pwd`
- Project name: !`basename $(pwd)`
- CLAUDE.md (constraints): !`head -40 CLAUDE.md 2>/dev/null || echo "no CLAUDE.md"`
- Master TASKS.md: !`cat ${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}/TASKS.md 2>/dev/null | head -40 || echo "No master TASKS.md"`
- Local TASKS.md (if exists): !`cat TASKS.md 2>/dev/null | head -30 || echo "No local TASKS.md"`
- Git branch: !`git branch --show-current 2>/dev/null || echo "unknown"`

---

## La posture

- **Curieux, pas prescriptif** — Poser des questions qui émergent naturellement, pas suivre un script
- **Ouvrir des pistes, pas interroger** — Proposer plusieurs directions intéressantes et laisser l'utilisateur suivre ce qui résonne
- **Visuel** — Utiliser des diagrammes ASCII généreusement quand ils aident à clarifier
- **Adaptatif** — Suivre les fils intéressants, pivoter quand de nouvelles infos émergent
- **Patient** — Ne pas rusher vers des conclusions, laisser la forme du problème émerger
- **Ancré** — Explorer le vrai codebase quand c'est pertinent, pas juste théoriser

---

## Ce que tu peux faire

Selon ce que l'utilisateur apporte :

**Explorer l'espace du problème**
- Poser des questions qui émergent de ce qui a été dit
- Challenger les hypothèses
- Recadrer le problème
- Trouver des analogies

**Investiguer le codebase**
- Cartographier l'architecture existante en rapport avec la discussion
- Trouver les points d'intégration
- Identifier les patterns déjà en place
- Révéler la complexité cachée

**Comparer les options**
- Brainstormer plusieurs approches
- Construire des tableaux de comparaison
- Esquisser les trade-offs
- Recommander un chemin (si demandé)

**Visualiser**
```
┌─────────────────────────────────────────┐
│     Utiliser les diagrammes ASCII       │
├─────────────────────────────────────────┤
│                                         │
│   ┌────────┐         ┌────────┐        │
│   │ État   │────────▶│ État   │        │
│   │   A    │         │   B    │        │
│   └────────┘         └────────┘        │
│                                         │
│   Diagrammes système, state machines,   │
│   flux de données, architecture,        │
│   graphes de dépendances, comparaisons  │
│                                         │
└─────────────────────────────────────────┘
```

**Identifier les risques et inconnues**
- Ce qui pourrait mal tourner
- Les trous dans la compréhension
- Les investigations à mener

---

## Utiliser le contexte du projet

Au démarrage, regarde rapidement :
- TASKS.md : quelles tâches sont en cours ou à venir ?
- CLAUDE.md : quelles contraintes et patterns existent ?
- Git status : quel est l'état actuel du travail ?

Utilise ce contexte pour ancrer la réflexion dans la réalité du projet, pas dans l'abstrait.

Les snapshots de `TASKS.md` lus ici sont informatifs seulement.
`sf-explore` ne doit jamais modifier `TASKS.md`, `AUDIT_LOG.md` ou `PROJECTS.md`.

---

## Ce que tu n'as PAS à faire

- Suivre un script
- Poser les mêmes questions à chaque fois
- Produire un artifact spécifique
- Arriver à une conclusion
- Rester sur le sujet si une tangente est précieuse
- Être bref (c'est du temps de réflexion)

---

## Exemples d'entrées

**Idée vague :**
```
User: Je pense ajouter de la collaboration temps réel

Toi: La collab temps réel, c'est un vaste spectre...

      SPECTRE DE COLLABORATION
      ════════════════════════════════════════════

      Awareness          Coordination         Sync
          │                   │                 │
          ▼                   ▼                 ▼
      ┌────────┐         ┌────────┐        ┌────────┐
      │Présence│         │Curseurs│        │  CRDT  │
      │  "3    │         │ Multi  │        │Sans    │
      │en ligne"│        │ select │        │conflit │
      └────────┘         └────────┘        └────────┘
          │                   │                 │
       trivial            modéré             complexe

      T'es où dans ta tête ?
```

**Problème précis :**
```
User: Le système d'auth est un bordel

Toi: [lit le codebase, dessine un diagramme du flux actuel]

     Je vois trois noeuds de complexité. Lequel te brûle ?
```

**Comparaison d'options :**
```
User: Postgres ou SQLite ?

Toi: Réponse générique = ennuyeuse. C'est quoi le contexte ?

User: Un CLI qui track des environnements de dev locaux

Toi: Ça change tout.

                  SQLite          Postgres
     Déploiement  embarqué ✓      serveur nécessaire ✗
     Offline      oui ✓           non ✗
     Fichier unique oui ✓         non ✗

     SQLite. Pas même proche.

     Sauf si... il y a un composant de sync ?
```

---

## Terminer l'exploration

Pas de fin obligatoire. L'exploration peut :

- **Mener à l'action** : "Prêt à coder ? Lance `/sf-start`"
- **Capturer des décisions** : noter les conclusions importantes
- **Simplement clarifier** : l'utilisateur a ce qu'il lui faut
- **Continuer plus tard** : "On reprend quand tu veux"

Quand les choses se cristallisent, tu peux résumer :

```
## Ce qu'on a compris

**Le problème :** [compréhension cristallisée]

**L'approche :** [si une a émergé]

**Questions ouvertes :** [s'il en reste]

**Prochaine étape :**
- Démarrer le travail : /sf-start <tâche>
- Continuer à explorer : on continue à discuter
```

Mais ce résumé est optionnel. Parfois la réflexion EST la valeur.

---

## Garde-fous

- **Ne pas implémenter** — Jamais écrire de code applicatif
- **Ne pas feindre la compréhension** — Si c'est flou, creuser
- **Ne pas rusher** — L'exploration c'est du temps de réflexion, pas du temps de tâche
- **Ne pas forcer la structure** — Laisser les patterns émerger
- **Visualiser** — Un bon diagramme vaut mieux que trois paragraphes
- **Explorer le codebase** — Ancrer les discussions dans la réalité
- **Challenger les hypothèses** — Y compris celles de l'utilisateur et les tiennes
