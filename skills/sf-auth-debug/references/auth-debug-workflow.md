---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipFlow
created: "2026-05-16"
updated: "2026-05-16"
status: draft
source_skill: sf-start
scope: sf-auth-debug-auth-debug-workflow
owner: unknown
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/sf-auth-debug/SKILL.md
  - skills/sf-auth-debug/references/auth-debug-workflow.md
depends_on:
  - artifact: "skills/references/skill-instruction-layering.md"
    artifact_version: "0.1.0"
    required_status: "draft"
supersedes: []
evidence:
  - "Extracted from skills/sf-auth-debug/SKILL.md during Compact ShipFlow Skill Instructions Phase 3."
next_review: "2026-06-16"
next_step: "/sf-verify Compact ShipFlow Skill Instructions Phase 3"
---

# Auth Debug Workflow

## Purpose

Auth debug workflow, provider-reference routing, reproduction strategy, Playwright proof, Sentry/PM2 evidence, and report details.

This reference preserves the detailed pre-compaction instructions for `sf-auth-debug`. The top-level `SKILL.md` is now the activation contract; load this file only when the selected mode needs the detailed workflow, checklist, templates, provider routing, examples, or report details below.

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
- Current date: !`date '+%Y-%m-%d'`
- Project name: !`basename $(pwd)`
- Git branch: !`git branch --show-current 2>/dev/null || echo "unknown"`
- Git status: !`git status --short 2>/dev/null || echo "Not a git repo"`
- ShipFlow development mode: !`rg -n "ShipFlow Development Mode|development_mode|validation_surface|ship_before_preview_test|post_ship_verification|deployment_provider" CLAUDE.md SHIPFLOW.md 2>/dev/null || echo "No project development mode documented"`
- Vercel project link: !`cat .vercel/project.json 2>/dev/null || echo "no .vercel/project.json"`
- CLAUDE.md (constraints / URLs): !`grep -i "auth\\|clerk\\|supabase\\|google\\|oauth\\|domain\\|url\\|vercel\\|netlify" CLAUDE.md 2>/dev/null | head -20 || echo "no CLAUDE.md"`
- Local TASKS.md (if exists): !`cat TASKS.md 2>/dev/null | head -40 || echo "No local TASKS.md"`

## Your task

Diagnostiquer un flux d'authentification cassé avec un vrai navigateur, sans supposer que le login complet sera automatisable.

`sf-auth-debug` est une skill de diagnostic spécialisée. Elle ne remplace pas `sf-spec`, `sf-fix`, `sf-start` ou `sf-verify`.
Elle intervient quand le sujet touche à l'auth réelle côté navigateur:
- Clerk
- Supabase Auth
- OAuth / Google login
- redirects et callbacks
- cookies / session
- middleware / guards
- retour inattendu vers login
- boucle d'auth

Boundary: use `/sf-browser` for public UI, visual, console, network, and non-auth navigation checks. Keep `sf-auth-debug` for Clerk, Supabase Auth, OAuth, cookies, sessions, callbacks, tenants, protected routes, and auth provider behavior.

Le but n'est pas de "faire passer Playwright à tout prix".
Le but est de localiser précisément le point de rupture et de produire un diagnostic exploitable par la suite du workflow.

Références locales à charger selon le contexte:
- `${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}/specs/master-auth-playbook.md` comme playbook transverse obligatoire avant tout diagnostic auth multi-app ou tout bug auth non trivial. L'utiliser pour classifier la famille auth, les invariants, la preuve minimale, les stop conditions, et les checklists sécurité/env/redirect.
- `references/clerk-tooling.md` pour choisir entre Clerk MCP, Clerk CLI et Playwright selon le type de bug
- `references/clerk-testing.md` pour savoir comment tester Clerk avec Playwright, Testing Tokens, comptes de test, OTP de test, et limites dev/prod
- `references/clerk.md` pour Clerk, Next.js, middleware, redirects, sessions, Google social connection via Clerk
- `references/supabase-testing.md` pour savoir comment tester Supabase avec stack locale, Mailpit, SSR cookies, RLS, et limites d'automatisation
- `references/supabase-tooling.md` pour choisir entre Supabase MCP, Supabase CLI et Playwright selon le type de bug
- `references/vercel-tooling.md` pour choisir entre Vercel MCP et Vercel CLI sur les sujets de déploiement, logs et runtime
- `references/google-oauth.md` pour les règles OAuth Google, redirect URI, state, consent screen, limites d'automatisation
- `references/convex-tooling.md` pour choisir entre Convex MCP, Convex CLI et sync de config d'auth
- `references/convex-clerk.md` pour les apps qui propagent l'identité Clerk vers Convex
- `references/playwright-auth.md` pour la méthode de preuve navigateur, les stratégies de session et les règles de secret hygiene
- `references/astro-clerk.md` pour les sites Astro avec `@clerk/astro`, SSR, middleware et Account Portal
- `references/flutter-clerk-convex.md` pour les apps Flutter avec Clerk beta et accès Convex
- `references/python-convex.md` pour scripts Python, jobs, imports et clients Convex
- `references/sdk-policy.md` pour choisir stable/beta/non-officiel dans le stack ShipFlow
- `references/flutter-web-clerkjs-bridge.md` pour le pattern ContentFlow: Flutter web + routes HTML ClerkJS + bridge Dart
- `${SHIPFLOW_ROOT:-$HOME/shipflow}/skills/references/project-development-mode.md` pour savoir si la preuve auth doit se faire en local ou après push sur preview Vercel
- `${SHIPFLOW_ROOT:-$HOME/shipflow}/skills/references/sentry-observability.md` quand le flow auth échoue avec une exception runtime, un error boundary, un 5xx, un event ID, ou un signal Sentry côté client/serveur
- `${SHIPFLOW_ROOT:-$HOME/shipflow}/skills/references/supabase-auth.md` pour Supabase Auth, `@supabase/ssr`, cookies, redirects, callbacks et limites `getUser()` / `getSession()`
- `${SHIPFLOW_ROOT:-$HOME/shipflow}/skills/references/flutter-web-clerkjs-auth-pattern.md` comme documentation technique transverse à réutiliser dans les autres repos Flutter
- `${SHIPFLOW_ROOT:-$HOME/shipflow}/skills/references/tubeflow-youtube-oauth-nextjs-convex-pattern.md` comme documentation technique transverse pour YouTube OAuth via Next.js + Convex
- `${SHIPFLOW_ROOT:-$HOME/shipflow}/skills/references/playwright-mcp-runtime.md` avant tout appel Playwright MCP, pour eviter le fallback Linux ARM64 vers Google Chrome stable absent

Ne charger que les références utiles au bug courant. Si une info de référence est critique et peut avoir changé récemment, vérifier ponctuellement la documentation officielle, puis mettre à jour la référence locale si nécessaire.

Les snapshots de `TASKS.md` lus ici sont informatifs seulement.
`sf-auth-debug` ne doit jamais modifier `TASKS.md`, `AUDIT_LOG.md` ou `PROJECTS.md`.

---

### Step 1 — Consommer le contexte existant

Ne pas repartir de zéro si le problème est déjà cadré.

Charger d'abord `${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}/specs/master-auth-playbook.md` si le fichier existe, sauf si le bug est explicitement un micro-ajustement mono-fichier sans impact auth réel.
Appliquer ce playbook comme garde-fou de diagnostic:
- identifier la famille auth du projet (`Clerk + Convex`, `Flutter web + ClerkJS`, `Supabase`, `Firebase`, `Convex Auth`, `Google OAuth`, autre)
- vérifier l'invariant "login + session restore + opération backend protégée + logout", pas seulement l'affichage d'une page login
- utiliser ses stop conditions pour éviter de conclure sur local quand preview/prod est la vraie surface
- reprendre ses règles de redaction: jamais de tokens, cookies, codes OAuth, secrets ou mots de passe dans le rapport
- si le playbook est absent, signaler `Master auth playbook: missing` et continuer avec les références spécifiques au stack

Priorité des sources:
1. spec existante
2. bug report ou demande utilisateur
3. diff courant / fichiers récents
4. exploration du code

Si `$ARGUMENTS` est fourni, l'utiliser comme point de départ.

Extraire ou reformuler explicitement:
- acteur concerné
- environnement visé (`local`, `staging`, `prod`)
- mode de développement ShipFlow (`local`, `vercel-preview-push`, `hybrid`, ou `unknown-vercel`)
- URL ou flow à tester
- provider d'auth (`Clerk`, `Supabase`, `Google`, autre)
- comportement observé
- comportement attendu

Si une info manque et change matériellement le diagnostic, poser une question courte et ciblée.

Toujours reformuler le problème comme une mini user story:
- acteur
- déclencheur
- rupture
- résultat attendu

Lire `${SHIPFLOW_ROOT:-$HOME/shipflow}/skills/references/project-development-mode.md`, puis inspecter `CLAUDE.md` ou `SHIPFLOW.md`:
- Si le mode est `vercel-preview-push`, utiliser une URL de déploiement confirmée par `sf-prod` comme surface de preuve pour tout bug auth/callback/session qui dépend du navigateur ou de l'environnement hébergé.
- Si le mode est `hybrid`, utiliser local seulement pour les signaux purement UI/static. Pour OAuth, callbacks, cookies secure/sameSite, domaines autorisés, variables d'env déployées, middleware serverless/edge, ou bug visible seulement en preview/prod, exiger la séquence `sf-ship` -> `sf-prod` avant de déclarer le flow réparé.
- Si le mode manque et que Vercel est détecté, classer `unknown-vercel`, signaler le trou documentaire, et ne pas conclure que local prouve preview/prod.

---

### Step 2 — Identifier la stratégie de repro

Choisir l'approche la plus réaliste avant de lancer Playwright.

Garder la surface de test cohérente avec le mode projet:
- `local`: Playwright peut cibler le serveur local quand le flow auth est configuré pour localhost.
- `vercel-preview-push`: si des changements non poussés sont nécessaires au diagnostic, router d'abord vers `/sf-ship [scope]`, puis `/sf-prod [project or URL]`; reprendre `sf-auth-debug` sur l'URL confirmée par `sf-prod`.
- `hybrid`: diagnostiquer localement seulement jusqu'au point utile; pour OAuth/callback/session/domaine/cookies hébergés, basculer vers preview après `sf-prod`.
- `unknown-vercel`: demander ou documenter le mode avant de traiter un succès local comme une preuve hébergée.

Cas autorisés:
- flow public jusqu'au bouton de login
- flow auth simple par formulaire
- flow OAuth partiellement automatisé pour observer où ça casse
- flow assisté par l'utilisateur si une étape humaine est nécessaire
- session déjà ouverte si le contexte la fournit

Ne pas promettre une automatisation complète si le flow passe par:
- MFA forte
- captcha
- device approval
- magic link non accessible
- WebAuthn / passkeys
- garde-fous anti-bot externes

Si l'auth complète n'est pas automatisable, continuer quand même le diagnostic jusqu'au point utile:
- bouton cliquable ou non
- redirect correcte ou non
- domaine de callback correct ou non
- retour vers l'app réussi ou non
- message d'erreur visible ou non

---

### Step 3 — Explorer le code minimum utile

Lire seulement les fichiers les plus pertinents avant d'agir:
- config Clerk / auth provider
- routes login / callback / middleware
- guards serveur ou client
- variables d'environnement liées à auth
- pages ou composants du flow cassé

Charger les références locales pertinentes avant de conclure:
- Clerk ou `@clerk/*` détecté -> lire `references/clerk-tooling.md`, puis `references/clerk-testing.md` si l'agent doit réellement tester, puis `references/clerk.md`
- Supabase Auth, `@supabase/ssr`, `@supabase/supabase-js`, `supabase.auth`, `auth/v1`, callback email/OAuth Supabase, ou dossier `supabase/` détecté -> lire `references/supabase-tooling.md`, puis `references/supabase-testing.md` si l'agent doit réellement tester, puis `${SHIPFLOW_ROOT:-$HOME/shipflow}/skills/references/supabase-auth.md`
- Vercel ou problème de runtime/deploy/logs détecté -> lire `references/vercel-tooling.md`
- Sentry détecté, event ID visible, 5xx, crash, error boundary, ou exception runtime pendant le flow auth -> lire `${SHIPFLOW_ROOT:-$HOME/shipflow}/skills/references/sentry-observability.md`
- App PM2 sans pointeur Sentry fourni/visible -> utiliser les logs PM2 locaux et les checks Doppler caviardés décrits dans `${SHIPFLOW_ROOT:-$HOME/shipflow}/skills/references/sentry-observability.md`
- Mode `vercel-preview-push`, `hybrid` avec flow hébergé, ou Vercel détecté -> lire aussi `${SHIPFLOW_ROOT:-$HOME/shipflow}/skills/references/project-development-mode.md` et utiliser `sf-prod` pour obtenir l'URL de déploiement fiable avant Playwright
- Google OAuth direct ou social login Google -> lire `references/google-oauth.md`
- Convex détecté -> lire `references/convex-tooling.md`
- Convex avec Clerk ou session backend Convex -> lire `references/convex-clerk.md`
- Diagnostic Playwright, session persistée, preuve navigateur ou auth automatisée -> lire `${SHIPFLOW_ROOT:-$HOME/shipflow}/skills/references/playwright-mcp-runtime.md`, puis `references/playwright-auth.md`
- Astro ou `@clerk/astro` détecté -> lire `references/astro-clerk.md`
- Flutter, Dart, `clerk_flutter`, `clerk_auth`, ou `convex_dart` détecté -> lire `references/flutter-clerk-convex.md`
- Flutter web avec ClerkJS, `web_auth/`, `clerk-runtime.js`, `/sign-in`, `/sso-callback`, ou bridge JS/Dart -> lire `references/flutter-web-clerkjs-bridge.md`
- Implémentation ou correction d'auth Flutter web dans un autre repo -> lire aussi `${SHIPFLOW_ROOT:-$HOME/shipflow}/skills/references/flutter-web-clerkjs-auth-pattern.md`
- YouTube OAuth, Google API scopes, `refresh_token`, `/api/auth/youtube`, ou connexion YouTube depuis Flutter -> lire aussi `${SHIPFLOW_ROOT:-$HOME/shipflow}/skills/references/tubeflow-youtube-oauth-nextjs-convex-pattern.md`
- Python script/job qui appelle Convex -> lire `references/python-convex.md`
- Choix de SDK, dépendance beta, ou package non-officiel -> lire `references/sdk-policy.md`

Chercher notamment:
- URL de callback attendue
- domaines autorisés
- `SITE_URL`, redirect allow list, et `redirectTo` attendu
- clés d'environnement manquantes
- middleware trop large ou mal ordonné
- mauvaise distinction `public` / `protected`
- lecture/écriture de session ou cookie
- redirect post-login

Le but ici est de guider l'observation Playwright, pas de faire une revue exhaustive.

---

### Step 4 — Reproduire avec Playwright MCP

Utiliser Playwright pour observer le comportement réel.

Avant le premier appel `mcp__playwright__*`, appliquer la preflight Playwright MCP de `${SHIPFLOW_ROOT:-$HOME/shipflow}/skills/references/playwright-mcp-runtime.md`:
- si la config Playwright MCP pointe vers Google Chrome stable, un channel `chrome`, ou seulement `["-y", "@playwright/mcp@latest"]` sur Linux ARM64, ne pas lancer Playwright comme preuve; router vers `/sf-fix BUG-2026-05-02-001`
- si la config est correcte mais que le MCP renvoie encore `/opt/google/chrome/chrome`, conclure que le process MCP courant est stale et demander un reload Codex/MCP avant de retester
- le rapport final doit indiquer `Playwright MCP runtime: executable-path <path>`, `chromium fallback`, ou `blocked/stale config`

Si le mode projet exige une preview Vercel:
- ne pas ouvrir une URL locale comme preuve finale du flow auth
- utiliser l'URL de preview/déploiement confirmée par `sf-prod`
- si `sf-prod` n'a pas encore confirmé le déploiement du dernier push, arrêter le diagnostic avec next step `/sf-prod [project or URL]`

Minimum à capturer:
- URL de départ
- action jouée
- URL après redirect
- page finale affichée
- message visible si erreur
- console browser si utile
- requêtes réseau auth si utile

Ordre recommandé:
1. ouvrir l'URL pertinente
2. capturer un snapshot initial
3. cliquer le CTA de login ou l'action qui déclenche l'auth
4. attendre la navigation ou le changement d'état
5. capturer la page d'arrivée
6. si besoin, inspecter console et réseau

Si une étape humaine est nécessaire:
- amener l'utilisateur jusqu'à l'écran utile
- noter exactement à quel moment l'automatisation s'arrête
- reprendre l'observation dès que possible

Ne pas conclure "Google bloque" sans preuve plus précise.
Nommer l'étape exacte:
- bouton absent
- popup refusée
- redirect externe incorrecte
- callback app en erreur
- retour à `/sign-in`
- session non persistée

---

### Step 5 — Isoler la cause probable

Classifier le bug dans une catégorie principale:
- `UI trigger`
  - bouton inactif, mauvais lien, popup, JS cassé
- `OAuth redirect`
  - mauvais domaine, mauvais callback, state invalide, mismatch d'environnement
- `Clerk configuration`
  - publishable key, domain, allowed redirect, provider config
- `Supabase SSR / token refresh`
  - middleware/proxy absent, cookies non rafraichis, `getSession()` utilisé comme preuve serveur, callback ou redirectTo incohérent
- `Session / cookies`
  - cookie absent, non persisté, domaine incohérent, secure/sameSite problématique
- `Middleware / protection`
  - route protégée trop tôt, boucle login, redirect incorrecte
- `Auth-to-DB boundary`
  - session OK mais requêtes Supabase refusées par RLS, client serveur/admin mal choisi, identité non propagée
- `App post-login flow`
  - callback ok mais app ne consomme pas la session correctement

Pour chaque hypothèse, chercher au moins une preuve observable:
- URL
- message d'erreur
- statut réseau
- contenu DOM
- config ou code lu dans le repo
- issue/event Sentry corrélé au même environnement et au même flow, si disponible

Éviter les diagnostics vagues du type "Clerk ne marche pas".

---

### Step 6 — Produire un diagnostic exploitable

Le résultat doit être actionnable par `sf-fix`, `sf-start` ou `sf-verify`.

Sortie attendue:

```text
## Auth Debug: [titre]

User story:
- [acteur] veut [action] afin de [valeur]

Environment:
- [local / staging / prod]

Development mode:
- [local / vercel-preview-push / hybrid / unknown-vercel]
- Validation authority: [local authoritative / preview required via sf-ship -> sf-prod / partial only]

Flow tested:
- [URL de départ]
- [action déclenchée]

Observed result:
- [ce qui se passe réellement]

Expected result:
- [ce qui devrait se passer]

Failure point:
- [étape exacte où ça casse]

Primary diagnosis:
- [catégorie + hypothèse principale]

Evidence:
- [déploiement vérifié par sf-prod / non requis / manquant]
- [URL finale]
- [message visible]
- [signal réseau / console utile]
- [Sentry issue/event corrélé ou limite Sentry]
- [fichier ou config pertinent]

Recommended next step:
- [fix concret ou vérification ciblée]

Automation status:
- [full / partial / blocked by human step]
```

Si le problème est suffisamment clair et local, proposer directement le prochain mouvement:
- corriger le code
- ajuster l'env
- modifier callback/domain
- retester après patch

Si le diagnostic reste incomplet, dire exactement ce qui manque.

---

### Intégration avec ShipFlow

Utiliser `sf-auth-debug` comme capability intégrée au workflow existant:
- après `sf-spec` si la spec décrit un bug d'auth à confirmer
- depuis `sf-fix` quand un bug auth doit être trié rapidement
- pendant `sf-start` si l'implémentation dépend d'un diagnostic navigateur réel
- avant `sf-verify` pour prouver que le flux cassé a été reproduit
- après un fix pour confirmer que la rupture a disparu
- après `sf-ship` et `sf-prod` quand le projet utilise `vercel-preview-push` ou un mode `hybrid` concerné par auth hébergée

Règle d'intégration:
- consommer d'abord la spec ou le bug report existant
- ne découvrir que ce qui manque au diagnostic
- ne pas refaire une spec implicite si une spec explicite existe déjà

---

### Rules

- Ne pas supposer que Playwright peut terminer un login Google complet
- Ne pas demander des cookies bruts par défaut
- Ne pas proposer de stocker les identifiants du compte principal comme solution standard
- Préférer une observation réelle à un raisonnement abstrait quand le flow est reproductible
- Toujours nommer l'étape exacte de rupture
- Toujours distinguer symptôme, preuve, hypothèse et correctif recommandé
- Si un pointeur Sentry est fourni ou visible, l'utiliser comme preuve corrélée et caviardée; ne jamais supposer un accès dashboard et ne jamais coller de payload brut, breadcrumb sensible, token, cookie ou donnée privée.
- Si l'auth complète est bloquée, pousser le diagnostic aussi loin que possible au lieu d'abandonner trop tôt
- Ne jamais traiter un succès auth local comme preuve suffisante d'une preview Vercel quand le projet est en `vercel-preview-push` ou quand le bug dépend de callback, domaine, cookie, env déployée, edge/serverless ou provider OAuth hébergé.
