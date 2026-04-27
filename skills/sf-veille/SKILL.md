---
name: sf-veille
description: "Args: URLs or paste content. Analyze URLs or pasted content for business relevance — fetches, summarizes, then prompts per-link triage (ignorer/backlog contenu/backlog archi/creuser) with actions into TASKS.md and tools.md"
disable-model-invocation: true
argument-hint: <URLs or paste content>
---

## Canonical Paths

Before resolving any ShipFlow-owned file, load `$SHIPFLOW_ROOT/skills/references/canonical-paths.md` (`$SHIPFLOW_ROOT` defaults to `/home/claude/shipflow`). ShipFlow tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPFLOW_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Chantier Tracking

Trace category: `conditionnel`.
Process role: `source-de-chantier`.

Before producing the final report, load `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md` when this run is attached to a spec-first chantier. If exactly one active `specs/*.md` chantier is identified, append the current run to `Skill Run History`, update `Current Chantier Flow` when the run changes the chantier state, and include a final `Chantier` block. If no unique chantier is identified, do not write to any spec; report `Chantier: non applicable` or `Chantier: non trace` with the reason.

## Chantier Potential Intake

Because this skill has process role `source-de-chantier`, evaluate the standard threshold from `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md` before the final report. If the findings reveal non-trivial future work and no unique chantier owns it, do not write to an existing spec; add a `Chantier potentiel` block with `oui`, `non`, or `incertain`, a proposed title, reason, severity, scope, evidence, recommended `/sf-spec ...` command, and next step. If the work is only a direct local fix or already belongs to the current chantier, state `Chantier potentiel: non` with the concrete reason.


## Context

- Current directory: !`pwd`
- Workspace CLAUDE.md (tous les projets): !`cat ~/shipflow_data/CLAUDE.md 2>/dev/null || echo "no shipflow_data/CLAUDE.md"`
- Project registry: !`cat ~/shipflow_data/PROJECTS.md 2>/dev/null || echo "no PROJECTS.md"`
- Memory index: !`cat ~/.claude/projects/-home-claude/memory/MEMORY.md 2>/dev/null || echo "no memory"`

## Chargement du contexte business

**Source de vérité : `~/shipflow_data/`** — contient CLAUDE.md (workspace overview avec tous les projets et stacks), PROJECTS.md (registry avec chemins et domaines), et les données de suivi.

Pour chaque projet mentionné dans PROJECTS.md, lire son CLAUDE.md local si besoin de contexte détaillé :
```
cat [project_path]/CLAUDE.md
```

Charger aussi les mémoires pertinentes depuis `~/.claude/projects/-home-claude/memory/` pour le contexte business (objectifs, décisions, contraintes).

---

## Mode detection

- **`$ARGUMENTS` contains URLs** (http/https) → Fetch and analyze each URL.
- **`$ARGUMENTS` contains text without URLs** → Analyze the pasted content directly.
- **`$ARGUMENTS` is empty** → Use **AskUserQuestion**:
  - Question: "Colle les liens ou le contenu à analyser"
  - Freeform text input

---

## Flow

### Step 1: Extract inputs

Parse `$ARGUMENTS` to separate:
- **URLs** — each http/https link found
- **Raw text** — everything else (pasted content, notes, descriptions)

If there are more than 3 URLs, batch them into groups of 2-3 and launch **parallel Agent subagents** for speed. Each agent gets the full business context + its batch of URLs.

### Step 2: Fetch & analyze

For each URL:
1. Use **WebFetch** to get the page content
2. If WebFetch fails or returns minimal content, use **mcp__firecrawl__firecrawl_scrape** as fallback
3. Extract: what the page/tool/product offers, target audience, pricing model, tech stack if visible

For pasted text:
1. Identify what it describes (tool, article, trend, technique, product)
2. Search the web for additional context if the text is ambiguous

### Step 3: Prepare summaries

Pour chaque élément, préparer un **résumé court** (3-4 lignes max) en français :
- Ce que c'est (1 ligne)
- Pourquoi ça pourrait nous intéresser — quel(s) projet(s) et sur quel axe (1-2 lignes)
- Score rapide : projet le plus pertinent + score /10

Les 4 axes d'évaluation (utiliser en interne pour le scoring, ne pas tous détailler dans le résumé — mentionner seulement les axes pertinents) :

| Axe | Ce qu'on cherche |
|-----|-----------------|
| **Contenu** | Peut-on s'en inspirer pour améliorer le contenu de nos sites web ou réseaux sociaux ? Contenu éducationnel, divertissant, engageant. |
| **Architecture** | Peut-on améliorer nos architectures techniques ? Performance, UX, stack, AI, infra, patterns. |
| **Concurrence & inspiration** | Est-ce un concurrent ou un produit similaire dont on peut s'inspirer ? |
| **Opportunité collab** | Opportunité de collaboration, partenariat, intégration, ou cross-promotion ? |

Score chaque projet 0-10. Être honnête — un 2/10 c'est bien. Ne pas gonfler les scores.

**Détection de concurrents** : vérifier systématiquement si le lien est un concurrent direct ou indirect d'un de nos projets (même marché, même audience, même problème résolu). Si oui, le signaler clairement dans le résumé avec le tag **⚔️ CONCURRENT** et le projet concerné.

### Step 4: Triage interactif — lien par lien

Traiter **un seul lien à la fois** — une seule question par AskUserQuestion pour maximiser le nombre d'options (4 max par question).

**Format d'affichage avant chaque question :**

```
## Triage — #[N]/[total]

**[Nom]** ([URL])
[résumé 3-4 lignes — ce que c'est, pourquoi ça nous concerne]

| Projet | Score | Pourquoi |
|--------|:-----:|----------|
| [projet1] | X/10 | [1 ligne — axe pertinent] |
| [projet2] | X/10 | [1 ligne — axe pertinent] |
(lister uniquement les projets scorés >= 3)
```

**Puis AskUserQuestion** avec **une question pour ce lien**. Les options doivent être **spécifiques au lien analysé** — pas des options génériques. Chaque option doit :
1. Commencer par un **numéro** (pour que l'utilisateur puisse combiner via "Other" — ex: "1+3")
2. Inclure le **nom du projet** concerné
3. Préciser le **type d'action** concret (pas juste "backlog contenu")

**Construire les options ainsi** (max 4, choisir les plus pertinentes pour CE lien) :

`1. Ignorer` — toujours en première option.

Pour les 3 options restantes, piocher dans cette palette et adapter au contexte du lien :

**🔍 Concurrent / benchmark** (PRIORITAIRE — la veille porte souvent sur des concurrents) :
- `🔍 [Projet] — benchmark concurrent (features, pricing, UX vs nous)` — comparer point par point
- `🔍 [Projet] — analyser leur copywriting/positionnement` — étudier comment ils vendent
- `🔍 [Projet] — analyser leur stack technique` — tech, hébergement, API, intégrations
- `🔍 [Projet] — surveiller concurrent (ajouter à la watchlist)` — pas d'action immédiate mais noter

**📝 Contenu** :
- `📝 [Projet] — article blog [type]` — types : portrait entreprise, guide comparatif, tutoriel, avis/review, opinion, pilier, FAQ
- `📝 [Projet] — post social [plateforme]` — LinkedIn, Twitter/X, Instagram
- `📝 [Projet] — script vidéo YouTube`
- `📝 [Projet] — newsletter / étude de cas`

**🏗️ Architecture / produit** :
- `🏗️ [Projet] — intégrer [outil/API/service précis]`
- `🏗️ [Projet] — s'inspirer UX/design [feature précise]`
- `🏗️ [Projet] — tester le produit et documenter`
- `🏗️ [Projet] — reproduire le pattern [pattern précis]`

**🤝 Collaboration** :
- `🤝 [Projet] — contacter pour partenariat/affiliation`
- `🤝 [Projet] — cross-promotion / guest post`

**Règles de sélection des 3 options (hors Ignorer) :**
1. Si le lien est un **concurrent direct** d'un de nos projets → toujours proposer un benchmark en option 2
2. Si le lien a un **score >= 5 sur plusieurs projets** → proposer des actions sur des projets différents
3. **Prioriser** les actions les plus impactantes, pas les plus évidentes
4. Les options surplus (qui ne tiennent pas dans les 4) → les lister dans la description de "Other" : `"Combine par numéros (ex: '2+3') ou : 📝 Quit Coke post social, 🏗️ ContentFlowz pipeline scraping, 🤝 contacter pour affiliation..."`

**Répéter** pour chaque lien jusqu'à ce que tous soient triés.

### Step 5: Exécuter les décisions

Pour chaque lien selon la décision de l'utilisateur :

Avant d'écrire dans `/home/claude/shipflow_data/TASKS.md` ou `~/shipflow/research/tools.md` :
- traiter les snapshots lus au début comme informatifs seulement
- relire le fichier cible depuis le disque juste avant l'écriture et utiliser cette version comme source de vérité
- appliquer un ajout ou une mise à jour minimale sur l'entrée visée, jamais une réécriture complète depuis un contexte périmé
- si l'ancre ou la fiche attendue a bougé, relire une fois et recalculer
- si c'est encore ambigu après cette seconde lecture, s'arrêter et demander à l'utilisateur

#### Si "Ignorer"
- Ne rien faire. Le lien apparaîtra dans le rapport final comme IGNORÉ.

#### Si "Backlog contenu"
- Ajouter une tâche dans `/home/claude/shipflow_data/TASKS.md` sous le projet concerné, format :
  ```
  - [ ] 📝 [Description de la tâche contenu] — source: [URL] (veille [date])
  ```
- Ajouter une fiche dans `tools.md` (voir format Step 6).

#### Si "Backlog archi"
- Ajouter une tâche dans `/home/claude/shipflow_data/TASKS.md` sous le projet concerné, format :
  ```
  - [ ] 🏗️ [Description de la tâche archi/tech] — source: [URL] (veille [date])
  ```
- Ajouter une fiche dans `tools.md` (voir format Step 6).

#### Si "Creuser maintenant"
- Lancer immédiatement une recherche approfondie (WebSearch, WebFetch supplémentaires, benchmark concurrents, etc.)
- Produire un mini-rapport détaillé avec actions concrètes
- Demander ensuite à l'utilisateur s'il veut aussi ajouter un ticket backlog

#### Si "Other" (réponse libre)
- Interpréter intelligemment et exécuter. Exemples : "backlog contenu + archi", "creuser pour tubeflow", "juste noter dans tools.md".

### Step 6: Save files

Produire **2 fichiers** dans `~/shipflow/research/` (créer le dossier si besoin) :

#### Fichier 1 : Rapport de veille
**Chemin :** `~/shipflow/research/veille-[YYYY-MM-DD].md`
Si un rapport existe déjà pour ce jour, append `-2`, `-3`, etc.

Contient le rapport final avec les **décisions de l'utilisateur** (pas des verdicts auto-générés) :

```
VEILLE STRATEGIQUE — [date]
[count] liens analyses
═══════════════════════════════════════

## Tableau recapitulatif

| # | Lien/Sujet | Projet principal | Score | Decision |
|---|------------|:---:|:---:|---------|
| 1 | [name]     | [projet] | X/10 | [IGNORÉ / BACKLOG CONTENU / BACKLOG ARCHI / CREUSÉ] |
| ...

## Détails

### [#N] [Item name] — [DECISION]
- **Quoi** : [2 lignes]
- **Projet** : [projet] ([score]/10)
- **Axes pertinents** : [contenu / archi / concurrence / collab — seulement ceux qui s'appliquent]
- **Action** : [ce qui a été fait — tâche ajoutée, recherche lancée, ou rien]

═══════════════════════════════════════
CREUSÉ: X | BACKLOG: X | IGNORÉ: X
```

#### Fichier 2 : Fiches outils (append)
**Chemin :** `~/shipflow/research/tools.md`

Ce fichier est **persistant** — on y accumule les fiches des outils/liens intéressants au fil des sessions de veille. Ne pas écraser le contenu existant, **ajouter à la suite**.

Ajouter une fiche pour chaque lien classé **BACKLOG** ou **CREUSÉ** (pas les IGNORÉS) :

```markdown
---

## [Nom de l'outil/lien] — [description courte]

**Lien :** [URL]
**Date de veille :** [YYYY-MM-DD]
**Business :** [projet le plus pertinent] ([score]/10)

**Pourquoi c'est intéressant :**
- [bullet 1 — cas d'usage concret]
- [bullet 2]
- [bullet 3 si pertinent]

**Précautions :**
- [risques, limites, contraintes légales]

**Quand revisiter :** [condition précise ou date]
```

Si le lien est déjà dans `tools.md` (même URL), **mettre à jour la fiche existante** au lieu d'en créer une nouvelle.

### Step 7: Résumé final

Afficher un récap compact des actions effectuées :
- Nombre de tâches ajoutées à TASKS.md (avec les projets concernés)
- Nombre de fiches ajoutées/mises à jour dans tools.md
- Liens creusés (avec résumé des findings)
- Rapport sauvegardé : chemin du fichier

---

## Important

- **Langue du rapport : toujours français.** Même si les liens sont en anglais.
- **Être spécifique.** "Pourrait être utile" n'est pas une analyse. Dire exactement COMMENT et POUR QUOI.
- **Ne pas sur-scorer.** Être honnête. Un 2/10 c'est bien.
- **Penser cross-projets.** Un même lien peut être CREUSER pour un projet et IGNORER pour un autre. Évaluer chaque projet du registry.
- **Source de vérité : `~/shipflow_data/`** — toujours charger CLAUDE.md et PROJECTS.md de ce dossier avant d'analyser. Sans contexte, l'analyse est générique et inutile. Compléter avec les mémoires.
- **4 axes, pas 5.** Contenu (web + réseaux, éducationnel + divertissant) | Architecture (apps rapides, intelligentes, un plaisir à utiliser) | Concurrence/inspiration (produit, contenu, copywriting) | Opportunité collab (partenariats, intégrations, cross-promo).
- **Paralléliser** les fetches et analyses via des agents quand il y a plus de 3 URLs. La vitesse compte pour une veille.
- **Accents français obligatoires** dans tout le rapport.
- **Le tableau récap doit lister TOUS les projets pertinents**, pas seulement 3. Se baser sur PROJECTS.md pour connaître la liste complète.
