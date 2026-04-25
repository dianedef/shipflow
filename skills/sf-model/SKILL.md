---
name: sf-model
description: Choisir le bon modèle pour une tâche ShipFlow avant exécution. Use when Codex needs to router entre GPT-5.5, GPT-5.4, GPT-5.4 mini, GPT-5.3-Codex, GPT-5.3-Codex-Spark ou GPT-5.2 selon le scope, le coût, la latence, la fiabilité attendue et la nature du travail.
argument-hint: <task description, spec path, ou scope>
---

## Context

- Current directory: !`pwd`
- Current date: !`date '+%Y-%m-%d'`
- Project name: !`basename $(pwd)`
- Git branch: !`git branch --show-current 2>/dev/null || echo "unknown"`
- Available specs: !`find docs specs -maxdepth 2 -type f -name "*.md" 2>/dev/null | sort | head -40`
- Local TASKS.md (if exists): !`cat TASKS.md 2>/dev/null || echo "No local TASKS.md"`

## Your task

Choisir un modèle avant une exécution Codex, sans transformer cette étape en débat interminable.

Le but de `sf-model` est de répondre à cinq questions :
- quel modèle prendre maintenant ?
- quel niveau de reasoning choisir ?
- quelle alternative plus rapide existe ?
- quelle alternative moins chère existe ?
- à partir de quand il faut arrêter d'optimiser et juste lancer `/sf-start` ?

Lire `references/model-routing.md` avant de décider.

### Step 1 — Identifier le scope

Si `$ARGUMENTS` est fourni, l'utiliser.

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

### Step 3 — Router vers un modèle

Utiliser la matrice de `references/model-routing.md` et choisir :
- un `Primary model`
- un `Reasoning effort`
- un `Fast fallback`
- un `Cheap fallback`

Règles de décision :
- préférer `gpt-5.5` pour les tâches ambiguës, transverses, ou à fort coût d'erreur
- préférer `gpt-5.4` quand il faut rester premium mais avec un meilleur contrôle du coût
- préférer `gpt-5.3-codex` pour le vrai travail agentique de code quand le problème est surtout d'implémenter, refactorer, debugger et tenir une longue boucle d'exécution
- préférer `gpt-5.4-mini` pour les boucles rapides, le triage, les petites modifs, l'exploration et les tâches répétitives
- préférer `gpt-5.3-codex-spark` pour les itérations UI ciblées ou les modifications locales qui doivent aller vite
- éviter `gpt-5.2` par défaut sauf besoin explicite de continuité ou préférence empirique utilisateur

### Step 4 — Calibrer le reasoning

Règles simples :
- `low` : tâche claire, locale, réversible
- `medium` : valeur par défaut pour la plupart des tâches de dev
- `high` : problème ambigu, cross-system, ou besoin de prudence
- `xhigh` : seulement si le coût d'erreur est élevé et que la vitesse importe peu

Ne pas sur-utiliser `high` ou `xhigh` sur les tâches faciles.

### Step 5 — Décider s'il faut vraiment router

Si la tâche est petite, claire et locale, éviter d'ajouter du process :
- recommander directement `gpt-5.4-mini` ou `gpt-5.3-codex-spark`
- dire explicitement de lancer `/sf-start`

Si la tâche est non triviale :
- recommander le modèle
- donner la commande suivante exacte

### Rapport attendu

```text
## Model Choice: [scope]

Primary model: [model]
Reasoning: [low / medium / high / xhigh]

Why:
- [reason 1]
- [reason 2]

Fast fallback: [model]
Cheap fallback: [model]

When to upgrade:
- [condition]

When to downgrade:
- [condition]

Next step:
- /sf-start [scope]
```

### Rules

- Être court et décisionnel
- Ne pas inventer de benchmark précis
- Considérer `gpt-5.5` comme disponible dans Codex (contexte 2026-04-24), et non plus comme simple "test"
- Si l'utilisateur demande le "latest" ou une comparaison actuelle, vérifier la doc OpenAI officielle avant d'affirmer
- Préférer une décision assez bonne tout de suite à une optimisation obsessionnelle
- Si deux modèles sont proches, arbitrer surtout sur latence, coût et nature agentique de la tâche
