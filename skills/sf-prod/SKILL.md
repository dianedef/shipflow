---
name: sf-prod
description: Vérifier que la prod fonctionne après un push — status du deploy, logs Vercel, health check de l'URL live
argument-hint: [optional: project name or URL]
---

## Context

- Current directory: !`pwd`
- Project name: !`basename $(pwd)`
- Git remote: !`git remote -v 2>/dev/null | head -1 || echo "no remote"`
- Latest commit: !`git log --oneline -1 2>/dev/null || echo "no commits"`
- CLAUDE.md (for prod URL): !`grep -i "url\|domain\|vercel\|netlify\|prod" CLAUDE.md 2>/dev/null | head -5 || echo "no CLAUDE.md or no URL found"`

## Your task

Vérifier que le dernier déploiement en production a réussi. Trois checks : status du deploy, health check de l'URL, et accès aux logs si erreur.

---

### Step 1 — Identifier le projet

Si `$ARGUMENTS` est fourni, l'utiliser comme nom de projet ou URL.

Sinon, utiliser le répertoire courant. Si pas de git remote, utiliser **AskUserQuestion** :
- Question : "Quel projet vérifier ?"
- Options depuis `/home/claude/shipflow_data/PROJECTS.md`

**Extraire le owner/repo** depuis le git remote :
```bash
# git@github.com:owner/repo.git → owner/repo
# https://github.com/owner/repo.git → owner/repo
```

### Step 2 — Vérifier le status du dernier deploy

**Via GitHub commit statuses API** (Vercel, Netlify y publient leurs résultats) :

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
1. `target_url` du deployment status (URL du preview Vercel)
2. URL dans CLAUDE.md (domaine custom)
3. Demander à l'utilisateur via **AskUserQuestion**

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

### Step 4 — En cas d'erreur : accéder aux logs

**Quel que soit le résultat (success ou failure), récupérer les logs du build :**

1. **Récupérer l'URL du dashboard automatiquement** via GitHub API :
   ```bash
   # Le target_url pointe directement vers la page du build Vercel/Netlify
   DASHBOARD_URL=$(gh api "repos/{owner}/{repo}/commits/$SHA/statuses" --jq '.[0].target_url')
   ```
   Ex : `https://vercel.com/diane-ds-projects/winflowz/8eyp8qqwq1qcaZC9KkmzdEmQi5SM`

2. **Scraper les logs du build** avec Firecrawl ou Playwright MCP (dans cet ordre de préférence) :

   **Option A — Firecrawl** (plus rapide, pas besoin de browser) :
   ```
   mcp__firecrawl__firecrawl_scrape → URL du dashboard
   ```
   Extraire : messages d'erreur, warnings, durée du build, status final.

   **Option B — Playwright** (si Firecrawl ne peut pas accéder à la page — auth requise) :
   ```
   mcp__playwright__browser_navigate → URL du dashboard
   mcp__playwright__browser_snapshot → capturer le contenu de la page
   ```
   Chercher les éléments contenant les logs de build, erreurs, stack traces.

   **Option C — Fallback** (si aucun MCP ne fonctionne) :
   Afficher le lien et demander à l'utilisateur de copier-coller les logs.

3. **Analyser les logs récupérés** :
   - Identifier l'erreur principale (première erreur dans le build log)
   - Extraire le fichier et la ligne si mentionnés
   - Classifier : erreur de type (TypeScript, ESLint, import manquant, env var manquante, runtime error)

4. **Si erreur détectée** — proposer des actions via **AskUserQuestion** :
   - "Le build a échoué. Que veux-tu faire ?"
   - Options :
     - **Corriger automatiquement** — "Je corrige l'erreur identifiée et je re-push" (Recommandé)
     - **Lancer /sf-check** — "Diagnostic complet avant de corriger"
     - **Rollback** — "Reverter le dernier commit et re-push"
     - **Ignorer** — "Je gère manuellement"

5. **Si success** — résumer les infos du build :
   - Durée du build (si visible dans les logs)
   - Warnings éventuels (même si le build passe, les warnings sont utiles)
   - URL de preview du déploiement

### Step 5 — Rapport

Si tout est OK :
```
## Prod Check — [project name]

**Dernier commit :** abc1234 — "feat: add payment flow"
**Deploy :**        ✓ success (il y a 3 min)
**Build :**         32s, 0 warnings
**URL :**           https://winflowz.vercel.app
**Health check :**  ✓ 200 OK (142ms)

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

---

### Rules

- Ne jamais rollback automatiquement — toujours demander confirmation
- Si le build est encore pending, patienter (30s x 3) avant de déclarer un problème
- Toujours fournir le lien vers les logs — l'utilisateur peut vouloir regarder lui-même
- Si pas de CI/CD détecté (pas de statuses sur le commit), proposer un simple curl + signaler que le projet n'a pas de deploy automatique
- Compatible Vercel, Netlify, et tout service qui publie des GitHub commit statuses
