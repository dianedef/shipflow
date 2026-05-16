---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipFlow
created: "2026-05-16"
updated: "2026-05-16"
status: draft
source_skill: sf-start
scope: sf-prod-production-verification-workflow
owner: unknown
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/sf-prod/SKILL.md
  - skills/sf-prod/references/production-verification-workflow.md
depends_on:
  - artifact: "skills/references/skill-instruction-layering.md"
    artifact_version: "0.1.0"
    required_status: "draft"
supersedes: []
evidence:
  - "Extracted from skills/sf-prod/SKILL.md during Compact ShipFlow Skill Instructions Phase 3."
next_review: "2026-06-16"
next_step: "/sf-verify Compact ShipFlow Skill Instructions Phase 3"
---

# Production Verification Workflow

## Purpose

Production and preview verification workflow, deployment status, health checks, logs, Blacksmith evidence, reporting, and stop rules.

This reference preserves the detailed pre-compaction instructions for `sf-prod`. The top-level `SKILL.md` is now the activation contract; load this file only when the selected mode needs the detailed workflow, checklist, templates, provider routing, examples, or report details below.

## Detailed Instructions

## Canonical Paths

Before resolving any ShipFlow-owned file, load `$SHIPFLOW_ROOT/skills/references/canonical-paths.md` (`$SHIPFLOW_ROOT` defaults to `$HOME/shipflow`). ShipFlow tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPFLOW_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Chantier Tracking

Trace category: `conditionnel`.
Process role: `source-de-chantier`.

Before producing the final report, load `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md` when this run is attached to a spec-first chantier. If exactly one active `specs/*.md` chantier is identified, append the current run to `Skill Run History`, update `Current Chantier Flow` when the run changes the chantier state, and include a final `Chantier` block. If no unique chantier is identified, do not write to any spec; report `Chantier: non applicable` or `Chantier: non trace` with the reason.

## Chantier Potential Intake

Because this skill has process role `source-de-chantier`, evaluate the standard threshold from `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md` before the final report. If the findings reveal non-trivial future work and no unique chantier owns it, do not write to an existing spec; add a `Chantier potentiel` block with `oui`, `non`, or `incertain`, a proposed title, reason, severity, scope, evidence, recommended `/sf-spec ...` command, and next step. If the work is only a direct local fix or already belongs to the current chantier, state `Chantier potentiel: non` with the concrete reason.


## Context

- Current directory: !`pwd`
- Project name: !`basename $(pwd)`
- Git remote: !`git remote -v 2>/dev/null | head -1 || echo "no remote"`
- Latest commit: !`git log --oneline -1 2>/dev/null || echo "no commits"`
- Current branch: !`git branch --show-current 2>/dev/null || echo "unknown"`
- Vercel project link: !`cat .vercel/project.json 2>/dev/null || echo "no .vercel/project.json"`
- ShipFlow development mode: !`rg -n "ShipFlow Development Mode|development_mode|validation_surface|ship_before_preview_test|post_ship_verification|deployment_provider" CLAUDE.md SHIPFLOW.md 2>/dev/null || echo "No project development mode documented"`
- CLAUDE.md (for prod URL): !`grep -i "url\|domain\|vercel\|netlify\|prod" CLAUDE.md 2>/dev/null | head -5 || echo "no CLAUDE.md or no URL found"`

## Your task

Vérifier que le dernier déploiement en production a réussi. Trois checks : status du deploy, health check de l'URL, et accès aux logs si erreur.
Le but est de donner un signal de confiance honnête sur la prod, pas un faux "tout va bien" basé sur un seul `200 OK`.

Si le déploiement ou le build passe par GitHub Actions sur Blacksmith runners, lire aussi `${SHIPFLOW_ROOT:-$HOME/shipflow}/shipflow_data/technical/blacksmith.md` avant de conclure sur les logs, les métriques, le sizing runner, ou l'accès SSH.

Lire `${SHIPFLOW_ROOT:-$HOME/shipflow}/skills/references/sentry-observability.md` quand le projet expose Sentry ou quand le signal prod dépend d'une erreur runtime, d'un 5xx, d'un crash, d'un flow auth/paiement/données, d'un job, d'un webhook, ou d'une erreur visible après déploiement.

Le registry `PROJECTS.md` est en lecture seule dans cette skill.
`sf-prod` ne doit jamais modifier `TASKS.md`, `AUDIT_LOG.md` ou `PROJECTS.md`.

Lire `${SHIPFLOW_ROOT:-$HOME/shipflow}/skills/references/project-development-mode.md` avant de choisir la cible. Si le projet est en mode `vercel-preview-push`, `sf-prod` vérifie le déploiement Vercel correspondant au dernier commit poussé et renvoie l'URL de preview prête pour les tests. Dans ce mode, le mot "prod" désigne le gate post-push, pas forcément le domaine de production custom.

After `sf-prod` confirms the deployment URL and deploy/runtime state, route page-level browser assertions, visual checks, console summaries, and non-auth network checks to `/sf-browser [URL] [objective]`. Keep deployment discovery, Vercel status, build logs, runtime logs, and live health ownership in `sf-prod`.

---

### Step 1 — Identifier le projet

Si `$ARGUMENTS` est fourni, l'utiliser comme nom de projet ou URL.

Sinon, utiliser le répertoire courant. Si pas de git remote, utiliser **AskUserQuestion** :
- Question : "Quel projet vérifier ?"
- Options depuis `${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}/PROJECTS.md`

**Extraire le owner/repo** depuis le git remote :
```bash
# git@github.com:owner/repo.git → owner/repo
# https://github.com/owner/repo.git → owner/repo
```

### Step 2 — Vérifier le status du dernier deploy

**Source primaire Vercel MCP quand Vercel est détecté :**

Si `.vercel/project.json` existe, si le status GitHub pointe vers Vercel, ou si le mode projet est `vercel-preview-push` :
1. Utiliser le serveur MCP Vercel avant de conclure :
   - `mcp__vercel__list_deployments` pour trouver les déploiements récents du projet.
   - `mcp__vercel__get_deployment` pour suivre le déploiement qui correspond au dernier commit, à la branche courante ou à l'URL fournie.
   - `mcp__vercel__get_deployment_build_logs` pour les logs build.
   - `mcp__vercel__get_runtime_logs` si le build est vert mais que le health check ou le flow live échoue.
2. Attendre l'état final du déploiement via MCP (`READY`, `ERROR`, `CANCELED`, ou équivalent). Ne pas demander un test preview tant que le déploiement correspondant au push n'est pas prêt.
3. Si aucun `teamId` ou `projectId` n'est connu, lire `.vercel/project.json`, puis utiliser `list_teams` / `list_projects` pour retrouver le projet. Si cela reste impossible, signaler le blocage et utiliser les GitHub statuses comme fallback partiel.
4. Si plusieurs déploiements existent, préférer celui qui correspond au dernier SHA local (`git rev-parse HEAD`) et à la branche courante. Signaler explicitement si la correspondance SHA/branche n'a pas pu être prouvée.

**Via GitHub commit statuses API** (Vercel, Netlify y publient leurs résultats) :

Utiliser cette voie comme fallback ou comme corroboration lorsque Vercel MCP n'est pas disponible, pas comme source primaire pour un projet Vercel en mode preview-push.

```bash
# Récupérer le SHA du dernier commit
SHA=$(gh api repos/{owner}/{repo}/commits --jq '.[0].sha')

# Récupérer les statuses de ce commit
gh api "repos/{owner}/{repo}/commits/$SHA/statuses" --jq '.[0:5] | .[] | {state, context, description, target_url}'
```

**Interpréter le résultat :**

| State | Signification | Action |
|-------|--------------|--------|
| `success` | Deploy réussi | Continuer vers le health check |
| `pending` | Build en cours | Attendre et réessayer |
| `failure` | Build échoué | Afficher l'erreur + récupérer les logs |
| `error` | Erreur système | Afficher le lien vers le dashboard |
| Aucun status | Pas de CI/CD détecté | Signaler et proposer un curl direct |

Si plusieurs statuses existent, ne pas s'arrêter au premier résultat ambigu. Prioriser le status du provider de déploiement le plus récent et signaler les conflits éventuels (ex: GitHub check vert mais deploy provider en échec).

**Si pending — polling patient :**

Boucle d'attente avec backoff progressif :
1. Attendre 30s → re-check
2. Attendre 45s → re-check
3. Attendre 60s → re-check
4. Attendre 60s → re-check (total ~3min15)
5. Attendre 60s → re-check (total ~4min15)
6. Attendre 60s → re-check (total ~5min15)
7. Attendre 90s → re-check (total ~6min45)
8. Attendre 90s → re-check (total ~8min15)
9. Attendre 90s → re-check (total ~9min45)
10. Attendre 90s → re-check (total ~11min15)

**Pendant l'attente**, afficher un point de progression toutes les 30s pour montrer que c'est actif :
```
⏳ Build en cours... (30s)
⏳ Build en cours... (1min15)
⏳ Build en cours... (2min15)
```

**Si toujours pending après 10 tentatives (~11 min)** : arrêter le polling et proposer via **AskUserQuestion** :
- Question : "Le build prend plus de 11 minutes. Que faire ?"
- Options :
  - **Continuer à attendre** — "Relancer 5 tentatives supplémentaires (~5 min)"
  - **Abandonner** — "Afficher le lien du dashboard pour suivi manuel"

### Step 3 — Health check de l'URL live

**Trouver l'URL de prod** (dans cet ordre) :
1. URL du déploiement confirmé par Vercel MCP quand disponible
2. `target_url` du deployment status (URL du preview Vercel)
3. URL dans CLAUDE.md (domaine custom)
4. Demander à l'utilisateur via **AskUserQuestion**

**Lancer le check :**
```bash
curl -s -o /dev/null -w "%{http_code}" [URL] --max-time 10
```

| Code | Résultat |
|------|----------|
| 200-299 | Site live et fonctionnel |
| 301-308 | Redirection (vérifier la cible) |
| 4xx | Erreur client (page introuvable, auth requise) |
| 5xx | Erreur serveur — problème de build ou de runtime |
| Timeout | Site ne répond pas |

Ne pas assimiler automatiquement `200-299` à "prod OK". Vérifier et signaler les hypothèses risquées suivantes si elles ne sont pas couvertes :
- la page d'accueil répond mais le flow principal n'a pas été exercé
- la réponse provient d'une page marketing/statique alors que la feature livrée concerne un flow applicatif
- une redirection masque un domaine mal configuré, un environnement preview, ou une page de login inattendue
- le endpoint de health est vert mais le produit public peut encore échouer sur auth, permissions, paiements, webhooks, jobs ou données

Quand c'est faisable sans inventer de scénario fragile, ajouter un check de cohérence léger en plus du simple `curl` :
- vérifier l'URL finale après redirection (`curl -I -L` ou équivalent)
- vérifier qu'on touche bien le domaine de prod attendu
- vérifier un marqueur simple de contenu si la page principale doit afficher un titre ou un mot-clé connu
- si une preuve Sentry Uptime Monitor est fournie, comparer le résultat `curl` avec le monitor : URL/méthode, intervalle, timeout, critères de succès, dernier état, et issue liée si déclenchée

Si la release concerne l'auth, une zone protégée, un dashboard privé, ou un callback OAuth:
- signaler qu'un `200` public ne prouve pas le flow principal
- recommander un passage `sf-auth-debug` ou une vérification Playwright ciblée si le doute principal porte sur login, session ou redirect
- recommander `/sf-browser [URL] [objective]` for a non-auth browser assertion after the deployment URL is confirmed

Si la nature de la release rend le health check insuffisant, dire explicitement ce qui n'a pas été vérifié au lieu de conclure trop fort.

### Step 4 — Collecter les logs sans troncature

**Quel que soit le résultat (success ou failure), collecter les logs de build en mode complet, puis filtrer les erreurs :**

1. **Récupérer le déploiement cible** :
   - Depuis le `target_url` du status GitHub (Vercel/Netlify).
   - Si Vercel, extraire `teamId`, `projectId` et `idOrUrl` du déploiement.

2. **Source primaire Vercel: logs paginés (obligatoire avant toute conclusion)** :
   - Utiliser `mcp__vercel__get_deployment_build_logs`.
   - Ne pas se limiter à un seul appel avec petite `limit`.
   - Paginer/relancer jusqu'à stabilisation (plus de nouvelles lignes) ou jusqu'au plafond de sécurité ci-dessous.
   - Plafond recommandé: jusqu'à 5000 lignes ou 10 appels successifs, puis marquer explicitement "collecte partielle" si incomplet.

2.5. **Preuve runtime Sentry quand disponible** :
   - Lire la référence Sentry partagée avant d'utiliser un issue/event comme preuve.
   - Ne jamais supposer un accès direct au dashboard Sentry depuis la skill.
   - Utiliser seulement les issue/event/monitor/alert IDs fournis par l'utilisateur, affichés par l'app, présents dans les logs, ou déjà disponibles dans le contexte.
   - Distinguer Sentry Monitor et Alert : le Monitor détecte et crée/met à jour une issue; l'Alert route la notification ou l'action.
   - Si un monitor breach est fourni/visible, relier seulement les preuves caviardées : `monitor id/name/type -> issue shortId/event id -> alert/workflow id -> delivery action`.
   - Pour une ancienne Metric Alert migrée, demander la preuve du Metric Monitor et de l'Alert connectée : signal/query/agrégat, environnement, fenêtre, seuil, issue ouverte/récente, action de routage.
   - Pour les Cron Monitors, relever la fenêtre de check-in, l'état missed/failed/success, la tolérance, et l'issue liée si déclenchée.
   - Pour les Uptime Monitors, relever URL/méthode, intervalle, critères de succès, dernier état, et issue liée si déclenchée.
   - Si un event ID est visible dans l'app, les logs ou un error boundary, l'inclure comme pointeur caviardé.
   - Si aucun pointeur Sentry n'est disponible, le signaler comme limite de confiance et passer aux preuves PM2/Doppler quand elles sont disponibles.

2.6. **Fallback PM2 local / Doppler par défaut hors pointeur Sentry** :
   - Utiliser les logs PM2 locaux comme preuve runtime bornée quand l'app est gérée par PM2.
   - Exemples à adapter au projet :
   ```bash
   pm2 list
   pm2 logs contentflow_lab --lines 80 --nostream
   tail -f ~/.pm2/logs/contentflow-lab-out.log
   tail -f ~/.pm2/logs/contentflow-lab-error.log
   ```
   - Préférer `pm2 logs ... --lines N --nostream` pour les rapports; utiliser `tail -f` seulement pendant un diagnostic live, puis résumer.
   - Pour Doppler, vérifier uniquement présence, scope, config et chargement des variables attendues. Ne jamais afficher les valeurs de secrets.
   - Si aucun pointeur Sentry n'était exploitable mais que PM2/Doppler l'a été, reporter explicitement : `Sentry: no direct dashboard access; PM2/Doppler checked`.

3. **Filtrage erreurs/warnings (obligatoire)** :
   - Après collecte brute, filtrer localement les lignes pertinentes.
   - Priorité de filtres:
     - erreurs: `Error:`, `failed`, `exited with 1`, `Target .* failed`
     - fichiers/positions: `lib/.*:[0-9]+:[0-9]+`, `src/.*:[0-9]+:[0-9]+`
     - warnings critiques: `warning`, `WARN`, `deprecated`, `missing env`
   - Exemples:
   ```bash
   rg -n "Error:|failed|exited with 1|Target .* failed" build-logs.txt
   rg -n "lib/.*:[0-9]+:[0-9]+|src/.*:[0-9]+:[0-9]+" build-logs.txt
   rg -n "warning|WARN|deprecated|missing env" build-logs.txt
   ```

4. **Fallback si logs incomplets ou tronqués** :
   - Si la réponse indique troncature (`truncated`, volume incomplet, stack trace sans erreur source), relancer la collecte avec pagination supplémentaire.
   - Si toujours incomplet via MCP, utiliser le dashboard Vercel (web) pour capturer le bloc complet d'erreur.
   - Toujours fournir le `DASHBOARD_URL` dans le rapport final.

5. **Analyser les logs filtrés** :
   - Identifier la **première erreur causale** (pas seulement la stack finale).
   - Extraire fichier/ligne/colonne si présent.
   - Classifier: TypeScript, ESLint, import, env var, runtime, build toolchain, autre.
   - Inclure 3 à 8 lignes de contexte utiles autour de l'erreur principale quand possible.

6. **Si erreur détectée** — proposer des actions via **AskUserQuestion** :
   - "Le build a échoué. Que veux-tu faire ?"
   - Options :
     - **Corriger automatiquement** — "Je corrige l'erreur identifiée et je re-push" (Recommandé)
     - **Lancer /sf-check** — "Diagnostic complet avant de corriger"
     - **Rollback** — "Reverter le dernier commit et re-push"
     - **Ignorer** — "Je gère manuellement"

7. **Si success** — résumer aussi les signaux faibles :
   - Durée du build (si visible)
   - Warnings éventuels
   - URL de preview/déploiement
   - Mention explicite si les logs ont été partiels malgré statut `success`

Même en cas de succès, remonter les warnings qui indiquent une fragilité produit ou sécurité, par exemple :
- variable d'environnement manquante mais fallback silencieux
- migration, seed, cache, queue ou job ignoré
- warning de bundle/config qui peut casser en runtime
- domaine, headers, CSP, auth callback ou secret potentiellement mal configuré

Si les logs ou le contexte révèlent une hypothèse non prouvée sur la sécurité ou la cohérence du déploiement, l'écrire dans le rapport au lieu de laisser entendre que la prod est entièrement sûre.

### Step 4.5 — Blacksmith Logs, Metrics, And SSH Access

Utiliser cette étape quand le build ou déploiement cible tourne sur un runner `blacksmith-*`, quand le workflow produit un APK/AAB, ou quand les logs GitHub/Vercel ne suffisent pas à expliquer l'échec.

**Source de vérité pratique :**

1. Blacksmith Run History pour retrouver le job exact.
2. Blacksmith Logs pour chercher dans les logs par `repo`, `workflow`, `branch`, `job_name`, `step_name`, et `level`.
3. Blacksmith Metrics pour vérifier CPU/RAM/network avant de recommander un runner plus gros.
4. Blacksmith SSH Access uniquement si le job est encore vivant, retenu par un monitor, ou gardé par un step `sleep`.

**Recherches utiles :**

```text
repo:<repo> branch:<branch> level:error,warn
repo:<repo> job_name:"<android job>" level:error,warn
repo:<repo> step_name:"Build debug APK" "Execution failed"
repo:<repo> "OutOfMemory"
repo:<repo> "SIGKILL"
repo:<repo> "NDK"
repo:<repo> "tauri android build"
```

**SSH Access :**

- L'accès SSH Blacksmith doit avoir été activé côté organisation.
- Seul l'utilisateur GitHub qui a déclenché le job peut se connecter au runner.
- La commande SSH est affichée dans le step `Setup runner` ou dans l'alerte Monitor avec VM retention.
- Si la commande SSH n'est pas disponible dans le contexte agent, demander à l'utilisateur de la coller ou fournir le chemin précis pour la retrouver.
- Utiliser SSH pour inspecter l'état du runner, pas pour relancer une release ou modifier la prod.

Commandes de diagnostic autorisées en SSH, à résumer sans secrets :

```bash
pwd
ls -la src-tauri/gen/android/app/build/outputs || true
find src-tauri/gen/android/app/build/outputs -type f | sort || true
ls "$ANDROID_HOME/ndk" || true
du -sh ~/.gradle ~/.cargo ~/.pnpm-store 2>/dev/null || true
df -h
ps aux | sort -nrk 3 | head -20
```

Ne jamais exécuter `env | sort` dans un rapport utilisateur sans redaction stricte. Si des variables d'environnement sont inspectées en SSH, ne rapporter que les noms nécessaires et jamais les valeurs.

**Si le job se termine trop vite pour SSH :**

Recommander un step de debug conditionnel dans le workflow concerné :

```yaml
- name: Keep runner available after failure
  if: failure()
  run: |
    echo "Failure detected; use the Blacksmith setup step SSH command."
    sleep 1800
```

Ne pas recommander ce step sur les succès. Signaler le coût runner quand la VM est retenue.

### Step 5 — Rapport

Si tout est OK :
```
## Prod Check — [project name]

**Dernier commit :** abc1234 — "feat: add payment flow"
**Deploy :**        ✓ success (il y a 3 min)
**Build :**         32s, 0 warnings
**URL :**           https://winflowz.vercel.app
**Health check :**  ✓ 200 OK (142ms)
**Mode dev :**      vercel-preview-push
**Source deploy :** Vercel MCP
**Sentry :**        ISSUE-ID fourni/visible ou no direct dashboard access; PM2/Doppler checked
**Sentry Monitors/Alerts :** monitor issue correlated / alert routing correlated / no direct dashboard access; no operator evidence supplied / n/a

Tout est live.
```

Si erreur :
```
## Prod Check — [project name]

**Dernier commit :** abc1234 — "feat: add payment flow"
**Deploy :**        ✗ failure
**Logs :**          [lien dashboard Vercel]

**Erreur identifiée :**
  Type: TypeScript error
  Fichier: src/components/PaymentForm.tsx:42
  Message: Property 'amount' does not exist on type 'Props'

**Options :** Corriger automatiquement | /sf-check | Rollback | Ignorer
```

Dans tous les cas, ajouter une ligne `Hypothèses / risques restants` dès qu'un point important n'a pas été prouvé. Exemples :
- "Le domaine répond, mais le flow de paiement n'a pas été exercé."
- "Le deploy est vert, mais aucun signal n'a confirmé que les variables d'env de prod sont correctes."
- "Le site répond en 200, mais la vérification n'a pas couvert auth, permissions ou webhooks."

---

### Rules

- Ne jamais rollback automatiquement — toujours demander confirmation
- Si le build est encore pending, patienter selon la boucle de polling ci-dessus avant de déclarer un problème
- Toujours fournir le lien vers les logs — l'utilisateur peut vouloir regarder lui-même
- Ne jamais conclure sur un échec avec des logs tronqués: d'abord collecter/paginer, ensuite filtrer.
- En cas de Vercel, privilégier `get_deployment_build_logs` + filtrage local; dashboard web en fallback, pas en source primaire.
- En cas de GitHub Actions sur Blacksmith, utiliser Run History, Logs, Metrics et SSH Access comme escalade de debug quand les logs standards ne suffisent pas; l'accès SSH ne remplace pas les logs dans le rapport final.
- Quand Sentry est configuré, ne jamais supposer un accès dashboard; corréler seulement les pointeurs fournis/visibles au release/environnement courant et inclure seulement des pointeurs caviardés.
- Quand Sentry Monitors/Alerts sont en scope, ne pas confondre détection et routage : le Monitor prouve la condition surveillée, l'Alert prouve la notification/action.
- En mode `vercel-preview-push`, Vercel MCP est la source primaire pour attendre la fin du déploiement; les GitHub commit statuses ne suffisent pas à autoriser le test preview.
- Si pas de CI/CD détecté (pas de statuses sur le commit), proposer un simple curl + signaler que le projet n'a pas de deploy automatique
- Compatible Vercel, Netlify, et tout service qui publie des GitHub commit statuses
- Ne jamais déclarer "prod OK" si seuls des signaux partiels ont été vérifiés. Préférer une conclusion précise du type : "deploy vert et URL répond, mais validation fonctionnelle/sécurité partielle".
- Si la release semble sensible (auth, paiement, données privées, permissions, multi-tenant, webhooks, admin), être explicite sur l'absence éventuelle de preuve côté sécurité ou cohérence produit et recommander `/sf-verify` ou une vérification manuelle ciblée.
- Si le risque principal est un flow d'auth navigateur, recommander explicitement `/sf-auth-debug [URL ou bug]`.
- If the main remaining risk is a non-auth browser assertion after deployment confirmation, recommend `/sf-browser [URL] [objective]`.
