---
name: sf-model
description: "Args: task description, spec path, or scope. Choisir le bon modèle pour une tâche ShipFlow avant exécution. Use when Codex/OpenAI or Claude Code needs routing between premium, coding-agentic, fast, cheap, or planning-focused models according to scope, cost, latency, reliability, provider runtime, and freshness requirements."
argument-hint: <task description, spec path, ou scope>
---

## Canonical Paths

Before resolving any ShipFlow-owned file, load `$SHIPFLOW_ROOT/skills/references/canonical-paths.md` (`$SHIPFLOW_ROOT` defaults to `/home/claude/shipflow`). ShipFlow tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPFLOW_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Chantier Tracking

Category: `non-applicable`.

This skill does not write to chantier specs. If invoked inside a spec-first flow, do not modify `Skill Run History`; include `Chantier: non applicable` or `Chantier: non trace` in the final report when useful, with the reason and the next lifecycle command if one is obvious.


## Context

- Current directory: !`pwd`
- Current date: !`date '+%Y-%m-%d'`
- Project name: !`basename $(pwd)`
- Git branch: !`git branch --show-current 2>/dev/null || echo "unknown"`
- Available specs: !`find docs specs -maxdepth 2 -type f -name "*.md" 2>/dev/null | sort | head -40`
- Local TASKS.md (if exists): !`cat TASKS.md 2>/dev/null || echo "No local TASKS.md"`

## Your task

Choisir un modèle avant une exécution ShipFlow, que la session tourne dans Codex/OpenAI ou dans Claude Code, sans transformer cette étape en débat interminable.

Le but de `sf-model` est de répondre à six questions :
- quel runtime/provider est concerné maintenant ?
- quel modèle prendre maintenant ?
- quel niveau de reasoning ou alias Claude choisir ?
- quelle alternative plus rapide existe ?
- quelle alternative moins chère existe ?
- à partir de quand il faut arrêter d'optimiser et juste lancer `/sf-start` ?

Lire `references/model-routing.md` avant de décider.

### Step 1 — Identifier le runtime et le scope

Déterminer d'abord le runtime réel ou demandé :
- `Codex/OpenAI` si la session utilise Codex, les modèles `gpt-*`, l'OpenAI API, ou une demande explicite OpenAI.
- `Claude Code` si la session utilise Claude Code, les aliases `opus`, `sonnet`, `haiku`, `opusplan`, ou une demande explicite Claude.
- Si aucun runtime n'est explicite, choisir celui de la session courante.

Si `$ARGUMENTS` est fourni, l'utiliser comme scope.

Sinon, déduire le meilleur scope possible depuis :
- la spec la plus probable dans `docs/` ou `specs/`
- la tâche en cours dans `TASKS.md`
- le contexte immédiat de la session

Si une spec existe pour ce scope, l'utiliser comme source principale.

### Step 2 — Classifier la tâche

Classer le travail selon la dimension dominante :
- `architecture` : cadrage, arbitrages, ambiguïtés, contrats
- `agentic-code` : implémentation longue, multi-fichiers, refacto, debugging
- `fast-iteration` : petits deltas, triage, exploration, boucles rapides
- `ui-focus` : ajustements front ciblés, itérations visuelles locales
- `economy` : tâche claire mais budget/latence prioritaires

Puis estimer :
- complexité : `low` / `medium` / `high`
- longueur de session attendue : `short` / `medium` / `long`
- coût d'erreur : `low` / `medium` / `high`
- besoin de vitesse : `low` / `medium` / `high`

### Step 3 — Vérifier la fraîcheur quand nécessaire

Pour les décisions OpenAI qui dépendent de "latest", "current", "default", "best model", disponibilité, migration, pricing ou comparaison actuelle :
- utiliser d'abord `mcp__openaiDeveloperDocs__fetch_openai_doc` sur `https://developers.openai.com/api/docs/guides/latest-model.md`
- si besoin, chercher/fetcher d'autres pages avec les outils `mcp__openaiDeveloperDocs__*`
- si le MCP ne répond pas, fallback seulement vers les domaines officiels OpenAI et signaler le fallback

Pour Claude Code, privilégier les aliases documentés (`opusplan`, `opus`, `sonnet`, `sonnet[1m]`, `haiku`) plutôt que des slugs datés, sauf demande explicite de nom complet.

Ne pas inventer de benchmark, prix, disponibilité, contexte ou capacité.

### Step 4 — Router vers un modèle

Utiliser la matrice provider-aware de `references/model-routing.md` et choisir :
- un `Primary model`
- un `Reasoning effort` pour Codex/OpenAI, ou le comportement d'alias pour Claude Code
- un `Fast fallback`
- un `Cheap fallback`

Règles de décision Codex/OpenAI :
- préférer `gpt-5.5` pour les tâches ambiguës, transverses, ou à fort coût d'erreur
- préférer `gpt-5.4` quand il faut rester premium mais avec un meilleur contrôle du coût
- préférer `gpt-5.3-codex` pour le vrai travail agentique de code quand le problème est surtout d'implémenter, refactorer, debugger et tenir une longue boucle d'exécution
- préférer `gpt-5.4-mini` pour les boucles rapides, le triage, les petites modifs, l'exploration et les tâches répétitives
- préférer `gpt-5.3-codex-spark` pour les itérations UI ciblées ou les modifications locales qui doivent aller vite
- éviter `gpt-5.2` par défaut sauf besoin explicite de continuité ou préférence empirique utilisateur

Règles de décision Claude Code :
- préférer `opusplan` quand il faut une vraie phase de plan/architecture puis exécuter efficacement
- préférer `opus` pour raisonnement complexe, arbitrages risqués, revue adverse ou cadrage difficile
- préférer `sonnet` pour le coding quotidien, l'implémentation multi-fichiers maîtrisée et les longues boucles équilibrées
- préférer `sonnet[1m]` quand la contrainte principale est une très longue session/contexte dans Claude Code
- préférer `haiku` pour triage, tâches simples, classifications, petites recherches ou boucles à coût/latence minimaux

### Step 5 — Calibrer le reasoning

Pour Codex/OpenAI :
- `low` : tâche claire, locale, réversible
- `medium` : valeur par défaut pour la plupart des tâches de dev
- `high` : problème ambigu, cross-system, ou besoin de prudence
- `xhigh` : seulement si le coût d'erreur est élevé et que la vitesse importe peu

Pour Claude Code :
- utiliser l'alias comme principal levier de raisonnement
- recommander `/model <alias>` si un changement de modèle est utile
- ne pas simuler des niveaux OpenAI `low/medium/high` pour Claude

Ne pas sur-utiliser les options lourdes sur les tâches faciles.

### Step 6 — Décider s'il faut vraiment router

Si la tâche est petite, claire et locale, éviter d'ajouter du process :
- recommander directement le modèle rapide/économique du runtime
- dire explicitement de lancer `/sf-start`

Si la tâche est non triviale :
- recommander le modèle
- donner la commande suivante exacte

### Rapport attendu

```text
## Model Choice: [scope]

Runtime: [Codex/OpenAI | Claude Code]
Primary model: [model or alias]
Reasoning: [low / medium / high / xhigh, or Claude alias behavior]

Why:
- [reason 1]
- [reason 2]

Fast fallback: [model or alias]
Cheap fallback: [model or alias]

Freshness check:
- [OpenAI Docs MCP used / not needed / unavailable fallback]

When to upgrade:
- [condition]

When to downgrade:
- [condition]

Next step:
- /sf-start [scope]
```

### Rules

- Être court et décisionnel
- Lire `references/model-routing.md` à chaque usage
- Ne pas inventer de benchmark précis
- Considérer `gpt-5.5` comme disponible dans Codex si la doc OpenAI officielle courante le confirme
- Si l'utilisateur demande le "latest" ou une comparaison actuelle OpenAI, vérifier la doc OpenAI officielle via MCP avant d'affirmer
- Pour Claude Code, recommander les aliases stables plutôt que des slugs datés sauf demande explicite
- Préférer une décision assez bonne tout de suite à une optimisation obsessionnelle
- Si deux modèles sont proches, arbitrer surtout sur latence, coût, nature agentique et risque d'erreur
