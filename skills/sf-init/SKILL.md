---
name: sf-init
description: "Args: project path optional. Bootstrap a new project for ShipFlow tracking — detect stack, generate CLAUDE.md, create TASKS.md, register in PROJECTS.md"
disable-model-invocation: true
argument-hint: '[project-path] (omit to init current directory)'
---

## Canonical Paths

Before resolving any ShipFlow-owned file, load `$SHIPFLOW_ROOT/skills/references/canonical-paths.md` (`$SHIPFLOW_ROOT` defaults to `/home/claude/shipflow`). ShipFlow tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPFLOW_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Chantier Tracking

Trace category: `conditionnel`.
Process role: `support-de-chantier`.

Before producing the final report, load `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md` when this run is attached to a spec-first chantier. If exactly one active `specs/*.md` chantier is identified, append the current run to `Skill Run History`, update `Current Chantier Flow` when the run changes the chantier state, and include a final `Chantier` block. If no unique chantier is identified, do not write to any spec; report `Chantier: non applicable` or `Chantier: non trace` with the reason.


## Context

- Current directory: !`pwd`
- Package.json: !`cat package.json 2>/dev/null | head -60 || echo "no package.json"`
- Requirements.txt: !`cat requirements.txt 2>/dev/null | head -20 || echo "no requirements.txt"`
- Shell scripts: !`ls -1 *.sh 2>/dev/null | head -10 || echo "no .sh files"`
- Existing CLAUDE.md: !`head -30 CLAUDE.md 2>/dev/null || echo "no CLAUDE.md"`
- Existing TASKS.md: !`head -20 TASKS.md 2>/dev/null || echo "no TASKS.md"`
- Directory listing: !`ls -la 2>/dev/null | head -30`
- Git remote: !`git remote -v 2>/dev/null | head -2 || echo "no git"`
- Project structure: !`find . -maxdepth 2 -type d 2>/dev/null | grep -v node_modules | grep -v .git | grep -v dist | sort | head -30`

## Mode detection

- **`$ARGUMENTS` is a path** → Init the project at that path.
- **`$ARGUMENTS` is empty** → Init the current directory.

---

## Flow

### Step 1: Detect project type

Analyze the project to determine:
- **Stack**: framework (Astro, Next.js, React, React Native, Vue, Python, Bash), runtime (Node, Python, Bun)
- **Package manager**: npm, yarn, pnpm, pip, none (detect from lockfiles)
- **UI framework**: React, Vue, Svelte, none
- **CSS solution**: Tailwind, UnoCSS, CSS Modules, styled-components, none
- **Content type**: blog, docs, app, CLI, API, library
- **i18n**: locale dirs, i18n config, bilingual content
- **Auth**: Clerk, Auth.js, Supabase Auth, none
- **Backend / DB**: Convex, Supabase Postgres, Firebase, custom API, none
- **Storage**: Supabase Storage, S3/R2, Firebase Storage, local, none
- **Hosting / platform signals**: Vercel, Netlify, Cloudflare, none
- **Payments**: Stripe, LemonSqueezy, none

### Step 2: Generate CLAUDE.md template

Create a `CLAUDE.md` with:

```markdown
# CLAUDE.md

This file provides guidance to Claude Code when working in this project.

## Project Overview
[Auto-detected: name, description, stack]

## Commands
[Auto-detected from package.json scripts, Makefile, or shell scripts]

## Architecture
[Auto-detected: directory structure, key patterns]

## Key Conventions
[Framework-specific conventions based on detected stack]
```

Use **AskUserQuestion** to let the user review and confirm:
- Question: "I've detected [stack summary]. Here's the generated CLAUDE.md — should I create it?"
- Options:
  - **Create as-is** — "Save the generated CLAUDE.md" (Recommended)
  - **Edit first** — "Let me review and adjust before saving"
  - **Skip** — "Don't create CLAUDE.md"

### Step 3: Create TASKS.md

**Architecture**: TASKS.md lives in `~/shipflow_data/projects/[name]/TASKS.md` (personal data, not in git) and is symlinked into the project directory as `[project_dir]/TASKS.md`.

`TASKS.md` is an operational tracker, not a metadata-bearing decision artifact. Do not add ShipFlow YAML frontmatter to generated `TASKS.md` files. Durable business, brand, guideline, spec, research, audit, review, or decision content belongs in separate artifacts with metadata.

**Check first**: skip entirely if `TASKS.md` already exists (file or symlink) in the project directory.

If it does not exist:
1. Create directory `~/shipflow_data/projects/[name]/`
2. Create `~/shipflow_data/projects/[name]/TASKS.md` with the canonical format below
3. Create symlink: `ln -s ~/shipflow_data/projects/[name]/TASKS.md [project_dir]/TASKS.md`

Never create a bare placeholder — populate with real tasks detected in Step 1:

```markdown
# Tasks — [project name]

> **Priority:** 🔴 P0 blocker · 🟠 P1 high · 🟡 P2 normal · 🟢 P3 low · ⚪ deferred
> **Status:** 📋 todo · 🔄 in progress · ✅ done · ⛔ blocked · 💤 deferred

---

## Setup

| Pri | Task | Status |
|-----|------|--------|
| 🔴 | [First critical task based on detected stack — e.g. "Configure env vars", "Set up auth", "Deploy first build"] | 📋 todo |
| 🟠 | [Second high-priority task] | 📋 todo |

---

## [Core Feature Area — detected from project]

| Pri | Task | Status |
|-----|------|--------|
| 🟠 | [Feature task] | 📋 todo |
| 🟡 | [Normal task] | 📋 todo |

---

## Backlog

| Pri | Task | Status |
|-----|------|--------|
| 🟢 | [Future improvement] | 💤 deferred |

---

## Audit Findings
<!-- Populated by /sf-audit — dated sections added automatically:

### Audit: [Domain] (YYYY-MM-DD)

**Fixed:**
- [x] Issue resolved

**Remaining:**
- [ ] 🔴 Blocker still open
- [ ] 🟠 High-priority finding
-->
```

Populate the initial tasks intelligently from what was detected in Step 1 (stack, framework, existing files, package.json scripts). Do not leave placeholder text like `[First critical task]` — replace with real tasks for this project.

### Step 4: Register in PROJECTS.md

Read `/home/claude/shipflow_data/PROJECTS.md` and add a row to both tables:

Before editing `/home/claude/shipflow_data/PROJECTS.md` here, or `/home/claude/shipflow_data/TASKS.md` later in Step 6:
- Treat the snapshots loaded earlier in the skill as informational only.
- Right before editing the shared file, re-read it from disk and use that version as authoritative.
- Apply a minimal targeted row or section insert/update; never rewrite the whole file from stale context.
- If the expected table, project row, or section moved, re-read once and recompute.
- If it is still ambiguous after the second read, stop and ask the user instead of forcing the write.

**Project Registry table**:
```
| [name] | [path] | [stack summary] |
```

**Domain Applicability table** — auto-detect defaults:
- Code: ✓ (always)
- Design: ✓ if has UI
- Copy: ✓ if has user-facing content
- SEO: ✓ if web project with public pages
- GTM: ✓ if commercial intent
- Translate: ✓ if i18n detected
- Deps: ✓ if has package manager
- Perf: ✓ (always)

### Step 5: Generate business & brand context files

Créer les fichiers de contexte business/marque directement dans le repo du projet. Ces documents sont des contrats de décision du projet et leur source canonique doit rester au plus près du code, des specs et de la documentation qu'ils gouvernent.

`shipflow_data` reste réservé au tracking partagé (`TASKS.md`, `AUDIT_LOG.md`, `PROJECTS.md`). Ne pas y déplacer `BUSINESS.md`, `BRANDING.md`, `CONTENT_MAP.md` ou `GUIDELINES.md` par défaut.

**Pour chaque fichier** : vérifier d'abord s'il existe déjà dans le projet. Si oui, sauter.

BUSINESS.md, BRANDING.md, CONTENT_MAP.md et GUIDELINES.md sont des artefacts ShipFlow, pas de simples notes. Ils doivent commencer par un frontmatter YAML ShipFlow avec `metadata_schema_version`, `artifact_version`, `status`, `confidence`, `risk_level`, `evidence`, `next_review`, `depends_on` et `supersedes`. À l'initialisation, utiliser `metadata_schema_version: "1.0"` et `artifact_version: "0.1.0"` tant que le contenu n'a pas été revu explicitement par l'utilisateur; passer à `artifact_version: "1.0.0"` seulement si les réponses utilisateur couvrent les décisions essentielles sans placeholder.

#### 5a. BUSINESS.md

Utiliser **AskUserQuestion** pour recueillir le contexte business :
- Question : "Décris ton projet en une phrase — qu'est-ce que ça fait et pour qui ?"
- (texte libre via "Other")

Puis générer `[project_dir]/BUSINESS.md` :

```markdown
---
artifact: business_context
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: "[project name]"
created: "[YYYY-MM-DD]"
updated: "[YYYY-MM-DD]"
status: "draft"
source_skill: sf-init
scope: "business"
owner: "[user or team if known]"
confidence: "low"
risk_level: "medium"
business_model: "[detected or unknown]"
target_audience: "[short ICP/persona or unknown]"
value_proposition: "[one-line promise or unknown]"
market: "[country/language/niche or unknown]"
docs_impact: "yes"
security_impact: "unknown"
evidence:
  - "[user answer or detected source]"
depends_on: []
supersedes: []
next_review: "[YYYY-MM-DD]"
next_step: "/sf-docs update"
---

# Business — [project name]

## Mission
[Déduit de la réponse utilisateur — en 1-2 phrases]

## Proposition de valeur
[Quel problème résout-on ? Pourquoi nous plutôt qu'un concurrent ?]

## Audience cible
[Qui sont les utilisateurs ? Quel est leur niveau ? Quels sont leurs pain points ?]

## Business model
[Freemium, SaaS, e-commerce, contenu monétisé, service... — déduit du stack détecté : Stripe = payant, pas de payment = gratuit/early stage]

## Distribution
[Comment les utilisateurs trouvent le produit ? SEO, réseaux sociaux, bouche-à-oreille, paid ads...]

## Concurrents connus
[À compléter plus tard — laisser vide avec un placeholder "À renseigner via /sf-market-study"]
```

Si l'utilisateur donne une réponse courte, compléter intelligemment à partir du stack détecté et du contenu existant. Marquer clairement les sections devinées avec `<!-- à confirmer -->`.

#### 5b. BRANDING.md

Utiliser **AskUserQuestion** :
- Question : "Quel ton pour ce projet ?"
- Options :
  - **Pro & accessible** — "Expert mais pas condescendant, tutoiement OK" (Recommandé)
  - **Corporate & formel** — "Vouvoiement, ton institutionnel"
  - **Décontracté & fun** — "Familier, emojis OK, humour"
  - **Technique & précis** — "Documentation style, pas de fluff"

Puis générer `[project_dir]/BRANDING.md` :

```markdown
---
artifact: brand_context
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: "[project name]"
created: "[YYYY-MM-DD]"
updated: "[YYYY-MM-DD]"
status: "draft"
source_skill: sf-init
scope: "branding"
owner: "[user or team if known]"
confidence: "low"
risk_level: "medium"
target_audience: "[from BUSINESS.md if known]"
value_proposition: "[from BUSINESS.md if known]"
market: "[country/language/niche or unknown]"
docs_impact: "yes"
security_impact: "none"
evidence:
  - "[tone selected by user]"
depends_on:
  - artifact: BUSINESS.md
    artifact_version: "0.1.0"
    required_status: "draft|reviewed"
supersedes: []
next_review: "[YYYY-MM-DD]"
next_step: "/sf-docs update"
---

# Branding — [project name]

## Voix de marque
[Ton choisi — description en 2-3 phrases]

## Style d'adresse
[tu/vous — déduit du ton + langue du projet]

## Personnalité
[3-5 adjectifs qui décrivent la marque — ex: "fiable, direct, chaleureux"]

## Tagline
[À compléter — laisser vide si pas encore défini]

## Valeurs
[Déduites de la mission et du ton — 3-5 valeurs]

## Ce qu'on n'est PAS
[Anti-patterns de communication — ex: "jamais condescendant, jamais corporate bullshit"]
```

#### 5c. GUIDELINES.md

Générer automatiquement depuis ce qui a été détecté en Step 1 + CLAUDE.md. Pas de question à l'utilisateur — c'est technique.

`[project_dir]/GUIDELINES.md` :

```markdown
---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: "[project name]"
created: "[YYYY-MM-DD]"
updated: "[YYYY-MM-DD]"
status: "draft"
source_skill: sf-init
scope: "guidelines"
owner: "[user or team if known]"
confidence: "medium"
risk_level: "medium"
docs_impact: "yes"
security_impact: "unknown"
linked_systems: ["[detected auth/payments/backend/hosting if any]"]
evidence:
  - "Detected stack and project files during sf-init"
depends_on:
  - artifact: CLAUDE.md
    artifact_version: "unknown"
    required_status: "draft|reviewed"
supersedes: []
next_review: "[YYYY-MM-DD]"
next_step: "/sf-docs audit"
---

# Guidelines — [project name]

## Stack technique
[Résumé du stack détecté]

## Conventions de code
[Extraites de CLAUDE.md, eslint config, prettier config, etc.]

## Structure du projet
[Arborescence des dossiers clés avec leur rôle]

## Conventions de contenu
[Langue du contenu, format des dates, format des URLs/slugs — détecté depuis le code]

## Outils et services
[Auth, payments, analytics, CMS, hosting — détectés en Step 1]
```

### Step 6: Create CHANGELOG.md + update master TASKS.md

**CHANGELOG.md** lives directly in the project directory (committed to git, visible to other devs).

If `CHANGELOG.md` doesn't exist in the project dir, create it:

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased] — [today's date]

### Added
- Initial project setup
```

**Master TASKS.md** — add a section to `/home/claude/shipflow_data/TASKS.md`:

```markdown
## [project name]

**Stack**: [summary] | **Phase**: Setup
```

### Step 7: Configure MCP servers

Always configure the Shipflow codebase MCP server, Context7 MCP, and OpenAI Docs MCP for this project by writing (or updating) `.claude/settings.json`.

If Clerk is detected in the project, propose adding the Clerk MCP and configure it when the user accepts.
Detection signals:
- `@clerk/*` in `package.json`
- source-level Clerk integration such as `clerkMiddleware`, `ClerkProvider`, or `@clerk/*` imports

If Convex is detected in the project, propose adding the Convex MCP and configure it when the user accepts.
Detection signals:
- `convex/` directory
- `convex.json`
- `convex.config.ts` or `convex.config.js`
- `convex` or `@convex-dev/*` in `package.json`

If Vercel is detected in the project, propose adding the Vercel MCP and configure it when the user accepts.
Detection signals:
- `vercel.json`
- `.vercel/project.json`
- `vercel` or `@vercel/*` in `package.json`

If Supabase is detected in the project, propose adding the Supabase MCP and configure it when the user accepts.
Detection signals:
- `supabase/` directory
- `supabase/config.toml`
- `@supabase/*` or `supabase` in `package.json`
- source-level Supabase integration such as `@supabase/*` imports, `supabase.auth`, or `createClient(...)`

Base config:

```json
{
  "mcpServers": {
    "codebase": {
      "command": "python3",
      "args": ["/home/claude/shipflow/tools/codebase-mcp/server.py", "[ABSOLUTE_PROJECT_PATH]"]
    },
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp@latest"]
    },
    "openaiDeveloperDocs": {
      "url": "https://developers.openai.com/mcp"
    }
  },
  "disabledMcpServers": ["codebase"]
}
```

If Clerk is accepted, add:

```json
"clerk": {
  "url": "https://mcp.clerk.com/mcp"
}
```

If Convex is accepted, add:

```json
"convex": {
  "command": "npx",
  "args": ["-y", "convex@latest", "mcp", "start"]
}
```

If Vercel is accepted, add:

```json
"vercel": {
  "url": "https://mcp.vercel.com"
}
```

If Supabase is accepted, add:

```json
"supabase": {
  "url": "https://mcp.supabase.com/mcp"
}
```

- Replace `[ABSOLUTE_PROJECT_PATH]` with the actual absolute path of the project.
- If `.claude/settings.json` already exists and has `mcpServers`, merge the base keys plus accepted detected integrations without overwriting other entries.
- Always add `codebase` to `disabledMcpServers` so the MCP is installed but inactive by default.
- Do not add `clerk` to `disabledMcpServers` by default when it is enabled for the project.
- Do not add `context7` to `disabledMcpServers` by default. Context7 should be available for current official docs, but only consumes model context when a tool call retrieves documentation.
- Do not add `openaiDeveloperDocs` to `disabledMcpServers` by default. OpenAI Docs MCP should be available for current OpenAI product/API/model docs, but only consumes model context when a tool call retrieves documentation.
- Do not add `convex`, `vercel`, or `supabase` to `disabledMcpServers` by default when they are enabled for the project.
- Create `.claude/` directory if needed.
- Skip silently if `/home/claude/shipflow/tools/codebase-mcp/server.py` doesn't exist.

Operational guidance:
- OpenAI Docs MCP is the first source for current OpenAI API, Codex, model-selection, migration, and prompting guidance.
- Clerk MCP is for current SDK snippets and implementation patterns, not live auth-state inspection.
- Clerk CLI is for diagnostics and config operations such as `clerk doctor`, `clerk env pull`, `clerk config pull`, `clerk config patch`, and `clerk api`.
- Supabase MCP is for project state, SQL/logs/docs access, and schema-aware assistance. Prefer development or staging projects, not production.
- Supabase CLI is for local stack control, project linking, migrations, and type generation such as `supabase start`, `supabase link`, `supabase db pull`, `supabase db push`, and `supabase gen types`.
- For real auth-flow proof, use browser automation such as Playwright.

Also append the codebase-mcp usage protocol to the generated `CLAUDE.md` (after the Commands section):

```markdown
## Context MCP — Token-Saving Protocol

This project uses a local codebase MCP server for efficient context management.

### Every turn:
1. **Call `context_continue` FIRST** — returns files already in memory, avoids re-reads.
2. **Call `context_retrieve`** with your query to find relevant files.
3. **Use `context_read`** instead of Read for code exploration (tracks token budget).
4. **After editing**, call `context_register_edit` with a one-sentence summary.

See `/home/claude/shipflow/tools/codebase-mcp/README.md` for full tool reference.
```

#### 5d. CONTENT_MAP.md

Générer automatiquement depuis les dossiers détectés (`src/content`, `content`, `docs`, `app`, `pages`, routes marketing, collections Astro/MDX, changelog, FAQ/support si présents). Utiliser `templates/artifacts/content_map.md` comme structure.

`[project_dir]/CONTENT_MAP.md` doit cartographier :
- blog et articles
- documentation produit/API/support
- landing pages et pages marketing
- FAQ, changelog, newsletter/social si présents
- cocons sémantiques, pages piliers et pages de support
- règles de mise à jour entre surfaces

Ne pas le transformer en calendrier éditorial ou backlog. Si aucun blog/newsletter/FAQ n'existe, noter la surface comme absente ou `planned`, pas comme chemin inventé.

### Step 8: Confirm domain applicability

Use **AskUserQuestion**:
- Question: "Which audit domains apply to [project name]?"
- `multiSelect: true`
- Options: Code, Design, Copy, SEO, GTM, Translate, Deps, Perf
- Pre-select based on auto-detection from Step 4
- Description for each: what was detected (or "not detected — opt in manually")

Update PROJECTS.md with the user's confirmed selection.

### Step 9: Report

```
PROJECT INITIALIZED: [name]
═══════════════════════════════════
Stack:       [detected stack]
Path:        [project path]
CLAUDE.md:   [created / skipped / already existed]
TASKS.md:    [created / skipped / already existed]
BUSINESS.md: [created / skipped / already existed]
BRANDING.md: [created / skipped / already existed]
CONTENT_MAP.md: [created / skipped / already existed]
GUIDELINES.md: [created / skipped / already existed]
MCP:         [configured / skipped]
PROJECTS:    [registered / already registered]
Domains:     [list of applicable domains]
═══════════════════════════════════
Next steps:
  /sf-audit        — Run initial audit
  /sf-check        — Verify build passes
  /sf-tasks        — Start tracking work
```

---

## Important

- Never overwrite an existing CLAUDE.md without asking.
- Never overwrite an existing TASKS.md.
- If the project is already in PROJECTS.md, update the row instead of adding a duplicate.
- Detect the stack from actual files, not just project name.
- The generated CLAUDE.md should match the style of existing project CLAUDE.md files in the workspace.
