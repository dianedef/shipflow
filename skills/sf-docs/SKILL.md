---
name: sf-docs
description: "Documentation generation and audit for README, API docs, component docs, metadata, and drift."
disable-model-invocation: true
argument-hint: [file-path | "readme" | "api" | "components" | "audit" | "update" | "metadata" | "migrate-frontmatter" | "migrate-layout" | "technical" | "technical audit" | "editorial" | "editorial audit"]
---

## Canonical Paths

Before resolving any ShipFlow-owned file, load `$SHIPFLOW_ROOT/skills/references/canonical-paths.md` (`$SHIPFLOW_ROOT` defaults to `$HOME/shipflow`). ShipFlow tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPFLOW_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Chantier Tracking

Trace category: `conditionnel`.
Process role: `support-de-chantier`.

Before producing the final report, load `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md` when this run is attached to a spec-first chantier. If exactly one active `specs/*.md` chantier is identified, append the current run to `Skill Run History`, update `Current Chantier Flow` when the run changes the chantier state, and include a final `Chantier` block. If no unique chantier is identified, do not write to any spec; report `Chantier: non applicable` or `Chantier: non trace` with the reason.


## Context

- Current directory: !`pwd`
- Project CLAUDE.md: !`head -80 CLAUDE.md 2>/dev/null || echo "no CLAUDE.md"`
- Business context: !`if [ -f shipflow_data/business/business.md ]; then head -40 shipflow_data/business/business.md; else head -40 BUSINESS.md 2>/dev/null || echo "no shipflow_data/business/business.md (root BUSINESS.md is migration source only)"; fi`
- Brand voice: !`if [ -f shipflow_data/business/branding.md ]; then head -40 shipflow_data/business/branding.md; else head -40 BRANDING.md 2>/dev/null || echo "no shipflow_data/business/branding.md (root BRANDING.md is migration source only)"; fi`
- Product context: !`if [ -f shipflow_data/business/product.md ]; then head -40 shipflow_data/business/product.md; else head -40 PRODUCT.md 2>/dev/null || echo "no shipflow_data/business/product.md (root PRODUCT.md is migration source only)"; fi`
- Architecture context: !`if [ -f shipflow_data/technical/architecture.md ]; then head -40 shipflow_data/technical/architecture.md; else head -40 ARCHITECTURE.md 2>/dev/null || echo "no shipflow_data/technical/architecture.md (and no legacy ARCHITECTURE.md)"; fi`
- GTM context: !`if [ -f shipflow_data/business/gtm.md ]; then head -40 shipflow_data/business/gtm.md; else head -40 GTM.md 2>/dev/null || echo "no shipflow_data/business/gtm.md (root GTM.md is migration source only)"; fi`
- Competitors/inspirations registry: !`if [ -f shipflow_data/business/project-competitors-and-inspirations.md ]; then head -40 shipflow_data/business/project-competitors-and-inspirations.md; else echo "no optional shipflow_data/business/project-competitors-and-inspirations.md"; fi`
- Affiliate programs registry: !`if [ -f shipflow_data/business/affiliate-programs.md ]; then head -40 shipflow_data/business/affiliate-programs.md; else echo "no optional shipflow_data/business/affiliate-programs.md"; fi`
- Guidelines: !`if [ -f shipflow_data/technical/guidelines.md ]; then head -40 shipflow_data/technical/guidelines.md; else head -40 GUIDELINES.md 2>/dev/null || echo "no shipflow_data/technical/guidelines.md (and no legacy GUIDELINES.md)"; fi`
- Content map: !`if [ -f shipflow_data/editorial/content-map.md ]; then head -40 shipflow_data/editorial/content-map.md; else head -40 CONTENT_MAP.md 2>/dev/null || echo "no shipflow_data/editorial/content-map.md (root CONTENT_MAP.md is migration source only)"; fi`
- Package.json: !`cat package.json 2>/dev/null | head -40 || echo "no package.json"`
- Existing README: !`head -20 README.md 2>/dev/null || echo "no README.md"`
- Project structure: !`find . -maxdepth 3 -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" -o -name "*.astro" -o -name "*.vue" -o -name "*.py" \) 2>/dev/null | grep -v node_modules | grep -v .git | grep -v dist | sort | head -40`

## Mode detection

- **`$ARGUMENTS` is a file path** → FILE MODE: document that specific file.
- **`$ARGUMENTS` is "readme"** → README MODE: generate or update README.md.
- **`$ARGUMENTS` is "api"** → API MODE: document all API endpoints.
- **`$ARGUMENTS` is "components"** → COMPONENTS MODE: document all UI components.
- **`$ARGUMENTS` is "audit"** → AUDIT MODE: vérifier la cohérence de toute la doc existante.
- **`$ARGUMENTS` is "update"** → UPDATE MODE: harmoniser et mettre à jour la doc existante.
- **`$ARGUMENTS` is "metadata" or "migrate-frontmatter"** → METADATA MODE: migrer et vérifier le frontmatter ShipFlow des artefacts actifs.
- **`$ARGUMENTS` is "migrate-layout" or "layout"** → LAYOUT MIGRATION MODE: ranger les anciens artefacts ShipFlow racine dans les chemins canoniques `shipflow_data/`.
- **`$ARGUMENTS` is "technical", "technical audit", or "docs/technical"** → TECHNICAL DOCS MODE: scaffold or audit the code-proximate technical documentation layer.
- **`$ARGUMENTS` is "editorial", "editorial audit", or "docs/editorial"** → EDITORIAL GOVERNANCE MODE: scaffold or audit the public-content governance layer.
- **`$ARGUMENTS` is empty** → AUTO MODE: detect gaps and suggest what to document.

---

## Documentation coherence doctrine

La documentation est une surface produit active :
- quand une feature change, vérifier README, docs, guides, exemples, FAQ, onboarding, pricing, changelog, support copy, screenshots, `.env.example` et API docs si pertinents
- quand une conversation révèle une preuve produit, une règle workflow durable, une objection client récurrente, ou une clarification utile, ne pas la laisser seulement dans le chat; router via `shipflow_data/editorial/content-map.md`, puis mettre à jour la surface publique ou technique pertinente
- quand une demande touche du contenu public, une promesse publique, une FAQ, une page site, un README affichable publiquement, une page skill publique, un prix ou un claim, charger `skills/references/editorial-content-corpus.md` puis `shipflow_data/editorial/`
- vérifier le `claim register` pour les claims sensibles et la `page intent` map pour les routes publiques avant de changer la copie
- préserver l'`Astro content schema` et le frontmatter de `runtime content`; ne pas ajouter de metadata ShipFlow à `site/src/content/**` si `site/src/content.config.ts` ne l'accepte pas
- ne pas documenter des capacités non prouvées par le code ou les specs
- distinguer `implemented`, `verified`, `assumed`, `deprecated` et `removed`
- signaler les docs stale comme risque produit quand elles touchent sécurité, paiement, permissions, API publique, migration, données sensibles ou actions destructives
- quand le scope touche les bugs, vérifier le modèle professionnel: `TEST_LOG.md` compact, bug file source de vérité dans `bugs/BUG-ID.md`, `BUGS.md` optionnel/généré comme vue de triage compacte, preuves redigées dans `test-evidence/BUG-ID/`

En mode `update` ou `audit`, prioriser les docs qui peuvent faire échouer un utilisateur réel : installation, configuration, auth, billing, migration, API, onboarding, troubleshooting.

## Governance corpus ownership

`sf-docs` is the official owner for project-local governance corpus creation, adoption, update, and audit.

- `sf-init` may create first-run baseline governance scaffolding and report status.
- `sf-docs technical` bootstraps or audits `shipflow_data/technical/` and `shipflow_data/technical/code-docs-map.md` (fallback legacy `docs/technical/`).
- `sf-docs editorial` bootstraps or audits `shipflow_data/editorial/` when public/content surfaces exist (fallback legacy `docs/editorial/`).
- `sf-docs update` treats `shipflow_data/business/project-competitors-and-inspirations.md` and `shipflow_data/business/affiliate-programs.md` as optional business governance artifacts: do not create them for every project, but if either exists, require ShipFlow metadata compliance and include it in docs drift checks.
- `sf-docs update` detects missing `shipflow_data/technical/`, missing `shipflow_data/editorial/`, stale `shipflow_data/editorial/content-map.md`, root legacy content map debt, invalid `AGENT.md` / `AGENTS.md` compatibility, and routes each layer to creation, audit, skip, or blocked status.
- `sf-docs migrate-layout` owns root legacy artifact cleanup. It moves or reports `BUSINESS.md`, `PRODUCT.md`, `BRANDING.md`, `GTM.md`, `ARCHITECTURE.md`, `CONTENT_MAP.md`, `CONTEXT.md`, `CONTEXT-FUNCTION-TREE.md`, `GUIDELINES.md`, `TASKS.md`, `AUDIT_LOG.md`, root `specs/`, root `bugs/`, and root research/review/audit folders into canonical `shipflow_data/` locations.
- Future project work must not ask operators to rerun ShipFlow's shipped governance specs. Use `/sf-docs technical`, `/sf-docs editorial`, or `/sf-docs update` instead.

Success and failure must be visible. Report technical governance and editorial governance as `created`, `already existed`, `needs audit`, `skipped`, or `blocked` with the recovery command.

Markdown docs generated by this skill for ShipFlow/project documentation must include YAML frontmatter:

```yaml
---
artifact: documentation
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: "[project name]"
created: "[YYYY-MM-DD]"
updated: "[YYYY-MM-DD]"
status: "[draft|reviewed|stale]"
source_skill: sf-docs
scope: "[readme|api|components|audit|update|file]"
owner: "[user or team if known]"
confidence: "[high|medium|low]"
security_impact: "[none|yes|unknown]"
docs_impact: "[none|yes|unknown]"
linked_systems: []
depends_on: []
supersedes: []
evidence: []
next_step: "[recommended command]"
---
```

Business, product, GTM, competitive intelligence, affiliate program, architecture, content map, and technical context files are ShipFlow artifacts too. Their canonical locations are `shipflow_data/business/business.md`, `shipflow_data/business/branding.md`, `shipflow_data/business/product.md`, `shipflow_data/business/gtm.md`, `shipflow_data/business/project-competitors-and-inspirations.md`, `shipflow_data/business/affiliate-programs.md`, `shipflow_data/technical/architecture.md`, `shipflow_data/technical/context.md`, `shipflow_data/technical/context-function-tree.md`, `shipflow_data/editorial/content-map.md`, and `shipflow_data/technical/guidelines.md`. Legacy root files (`BUSINESS.md`, `BRANDING.md`, `PRODUCT.md`, `ARCHITECTURE.md`, `GTM.md`, `CONTEXT.md`, `CONTEXT-FUNCTION-TREE.md`, `CONTENT_MAP.md`, `GUIDELINES.md`, `TASKS.md`, `AUDIT_LOG.md`) are migration sources only. They are not compliant final locations in project repos. Canonical artifacts must use the ShipFlow schema with these minimum fields:

```yaml
---
artifact: "[business_context|brand_context|product_context|architecture_context|gtm_context|competitive_intelligence|affiliate_program_registry|technical_guidelines]"
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: "[project name]"
created: "[YYYY-MM-DD]"
updated: "[YYYY-MM-DD]"
status: "[draft|reviewed|stale|deprecated]"
source_skill: "[sf-init|sf-docs|manual]"
scope: "[business|branding|product|architecture|gtm|project-competitors-and-inspirations|affiliate-programs|guidelines]"
owner: "[user or team if known]"
confidence: "[high|medium|low]"
risk_level: "[low|medium|high]"
docs_impact: "yes"
security_impact: "[none|yes|unknown]"
evidence: []
depends_on: []
supersedes: []
next_review: "[YYYY-MM-DD]"
next_step: "[recommended command]"
---
```

Use `depends_on` when an artifact relies on another decision contract, for example branding depending on business, GTM depending on business plus branding, architecture depending on guidelines, guidelines depending on `CLAUDE.md`, or a spec depending on business plus guidelines. Use `supersedes` when the artifact replaces an older file, a renamed doc, or a previous version whose assumptions are no longer current.

This ShipFlow schema is mandatory for project documentation produced by ShipFlow (`shipflow_data/`, specs, reports, API docs, component docs, reviews, audits, research, `AGENT.md`, and root compatibility exceptions when they are official artifacts). `CLAUDE.md` is an optional official ShipFlow artifact when the repo explicitly adopts it as the maintained repository-guidance contract; in that case it should carry ShipFlow frontmatter too. Application runtime content keeps its own schema (`src/content/**`, app-rendered MD/MDX/blog files, framework-specific collections).

Operational tracking files are explicitly excluded from mandatory metadata frontmatter:
- `shipflow_data/workflow/TASKS.md`
- `shipflow_data/workflow/AUDIT_LOG.md`
- `${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}/PROJECTS.md`
- `TEST_LOG.md`
- `BUGS.md`

They are trackers/registries, not decision contracts. Do not add frontmatter to them during docs audit/update. If a tracker contains a durable decision, spec, business rule, or research conclusion, extract that content into a dedicated ShipFlow artifact with metadata and leave the tracker entry as a pointer or task. Root `TASKS.md` and `AUDIT_LOG.md` are layout migration sources unless an external project tool explicitly requires them.

Technical module context files are ShipFlow artifacts too. `shipflow_data/technical/*.md` (fallback legacy `docs/technical/*.md`) and `templates/artifacts/technical_module_context.md` use `artifact: technical_module_context`. They must include at least the common governance fields plus `linked_systems` and `next_review`, and they must pass `$SHIPFLOW_ROOT/tools/shipflow_metadata_lint.py`.

Bug workflow distinction:
- `TEST_LOG.md` and `BUGS.md` are tracker files (no required frontmatter).
- `bugs/BUG-ID.md` is the bug file artifact (`artifact: bug_record`) and must stay detailed.
- `test-evidence/BUG-ID/` holds optional redacted heavy evidence and should be referenced by path, not pasted inline in trackers.
- Docs must not present `BUGS.md` as the full bug source-of-truth location.

Location rule:
- `shipflow_data` hosts tracking and registry files, and is the preferred location for project governance artifacts in this architecture phase.
- `shipflow_data/business/*`, `shipflow_data/editorial/*`, and `shipflow_data/technical/*` are preferred locations for those document families.
- During docs audit/update, do not duplicate project decision docs across root and `shipflow_data`. Keep one canonical location and avoid creating parallel legacy copies.

When adopting ShipFlow in an existing project, migrate old ShipFlow docs without metadata by adding the standard frontmatter. Preserve the body and only infer fields that are evident; use `unknown` or `medium|low` confidence instead of inventing proof.

For frontmatter migration, read `shipflow-metadata-migration-guide.md` before editing when it exists. Validate the intended scope with the canonical ShipFlow linter at `$SHIPFLOW_ROOT/tools/shipflow_metadata_lint.py` (`$SHIPFLOW_ROOT` defaults to `$HOME/shipflow`). If the migration guide or canonical linter is missing from `$SHIPFLOW_ROOT`, continue with this skill's schema rules but report the missing ShipFlow installation support as a confidence gap.

---

## Artifact versioning flow

ShipFlow uses two different version numbers:

- `metadata_schema_version` tracks the YAML metadata format. Keep it at `"1.0"` unless the ShipFlow metadata schema itself changes.
- `artifact_version` tracks the decision content of the document. Change it whenever the artifact's business, brand, technical or product meaning changes.

Use semantic versioning for `artifact_version`:

- `0.x.y` = draft, migrated or not fully reviewed. Use this for generated files with placeholders, inferred content, low confidence or missing evidence.
- `1.0.0` = first reviewed decision contract. Use this when the artifact is complete enough for specs, audits and implementation to depend on it.
- Patch bump, for example `1.0.1` = non-decision correction: typo, formatting, clearer wording, broken link, updated date, no change to product behavior or decision meaning.
- Minor bump, for example `1.1.0` = compatible decision update: refined ICP, clearer value proposition, added supported platform, updated guideline, new channel, new non-breaking constraint.
- Major bump, for example `2.0.0` = decision break: new target customer, changed business model, pricing strategy change, brand repositioning, architecture convention reversal, auth/data/payment/security assumption changed.

When bumping `artifact_version`:

- update `updated`
- keep `created` unchanged
- update `status`, `confidence`, `risk_level`, `evidence` and `next_review`
- add `supersedes` if the new artifact replaces a previous file or materially obsolete version
- search for specs, audits, reviews and docs that reference the old version in `depends_on`
- mark dependent artifacts as needing recheck when their `depends_on` version no longer matches the current decision contract

If the canonical decision contracts in `shipflow_data/business/`, `shipflow_data/technical/`, or `shipflow_data/editorial/content-map.md` are `stale`, `draft` with low confidence, or have outdated dependencies, do not silently use them as authoritative. Legacy root equivalents are compatibility fallbacks only. Ask a targeted question or report a blocking documentation risk before changing product behavior, copy, onboarding, pricing, security, GTM claims, API, content routing, or architecture.

---

## FILE MODE

Document a specific file with inline documentation.

### Flow

1. Read the target file and all its imports (1 level deep).
2. Analyze: exports, functions, types, classes, side effects.
3. Add documentation:
   - **TypeScript/JavaScript**: JSDoc/TSDoc comments for exports
   - **Python**: docstrings (Google style)
   - **Astro/Vue**: component description comment at top
4. Don't document obvious code. Focus on:
   - Why, not what
   - Non-obvious parameters and return values
   - Edge cases and gotchas
   - Usage examples for public APIs

---

## TECHNICAL DOCS MODE

Create, scaffold, or audit ShipFlow's internal code-proximate technical documentation layer.

### Flow

1. Load `$SHIPFLOW_ROOT/skills/references/technical-docs-corpus.md`, then load project-local `shipflow_data/technical/code-docs-map.md` when present (fallback legacy `docs/technical/code-docs-map.md`). If both are missing, treat it as a first-run bootstrap trigger, not an immediate read failure.
2. Classify the request:
   - `technical`, `shipflow_data/technical`, or legacy `docs/technical` with missing docs -> scaffold from `templates/artifacts/technical_module_context.md`.
   - missing `shipflow_data/technical/README.md` or missing `shipflow_data/technical/code-docs-map.md` -> bootstrap the baseline technical governance layer, then audit it.
   - `technical audit` -> audit existing docs without rewriting unrelated content.
   - a changed-path list or diff context -> produce a `Documentation Update Plan`.
3. For first-run bootstrap, create or update only the shared technical governance files needed to make the layer usable:
   - `shipflow_data/technical/README.md` (or legacy `docs/technical/README.md`)
   - `shipflow_data/technical/code-docs-map.md` (or legacy `docs/technical/code-docs-map.md`)
   - explicit `non-coverage` rows or notes when no major code area can be mapped safely
   - next step `/sf-docs technical audit` when generated entries need deeper review
4. Build the initial `code-docs-map.md` from detected code paths and validation commands:
   - shell CLI or scripts -> `bash -n` and focused smoke commands
   - Node/Astro/Next/Vite/UI paths -> package scripts and build/lint/typecheck when available
   - API/backend/auth/storage paths -> focused tests, schema or policy checks when present
   - unknown or unmapped code -> `non-coverage` with reason and required next review
5. For scaffolding, create or update only the requested subsystem docs plus the shared map when needed:
   - `shipflow_data/technical/README.md` (or legacy `docs/technical/README.md`)
   - `shipflow_data/technical/code-docs-map.md` (or legacy `docs/technical/code-docs-map.md`)
   - subsystem docs named in the map
   - `templates/artifacts/technical_module_context.md` when the template itself is missing or stale
6. For audit, verify:
   - every major mapped code area has a primary technical doc or explicit non-coverage reason
   - every technical doc has `Purpose`, `Owned Files`, `Entrypoints`, `Invariants`, `Validation`, `Reader Checklist`, and `Maintenance Rule`
   - `code-docs-map.md` includes path patterns, primary docs, validations, and docs update triggers
   - stale path references and commands are reported
   - `technical_module_context` artifacts pass metadata lint
   - `AGENTS.md` is absent or a symlink to `AGENT.md`
   - `shipflow_data/technical/` is not routed as public site content
7. For changed code, output a `Documentation Update Plan` in this format:

```markdown
## Documentation Update Plan

- Code changed: `path/or/pattern`
- Subsystem: `name`
- Primary technical doc: `shipflow_data/technical/example.md`
- Secondary docs: `...`
- Required action: `none | review | update | create`
- Priority: `low | medium | high`
- Reason: `why this doc is impacted`
- Owner role: `executor | integrator`
- Parallel-safe: `yes | no`
- Notes: `constraints or blockers`
```

### Role Rules

- The Reader diagnoses documentation impact; an executor or integrator applies updates.
- Shared files are sequential by default: `shipflow_data/technical/code-docs-map.md` (or legacy `docs/technical/code-docs-map.md`), `AGENT.md`, `shipflow_data/technical/context.md`, `shipflow_data/technical/guidelines.md`, `shipflow-spec-driven-workflow.md`, and `tools/shipflow_metadata_lint.py`.
- Parallel technical-doc work is allowed only when a ready spec defines disjoint file ownership.
- Code changes cannot ship while mapped technical docs are stale or missing.
- Do not add per-file `last_verified_against` fields in v1.
- Do not publish `shipflow_data/technical/` to the public site in v1.

### Validation

Run focused checks for the affected docs:

```bash
rg -n "Maintenance Rule|Validation|Owned Files|Entrypoints" shipflow_data/technical templates/artifacts/technical_module_context.md
python3 tools/shipflow_metadata_lint.py shipflow_data/technical shipflow_data/editorial templates/artifacts/technical_module_context.md skills/references/technical-docs-corpus.md
test ! -e AGENTS.md || { test -L AGENTS.md && test "$(readlink AGENTS.md)" = "AGENT.md"; }
```

Report any stale docs, missing map entries, missing validation rules, public/private boundary leaks, or metadata failures as documentation coherence gaps.

---

## EDITORIAL GOVERNANCE MODE

Create, scaffold, or audit ShipFlow's public-content governance layer.

This mode treats public content drift as a documentation risk when README, public docs, FAQ, pricing, site pages, public skill pages, or claims no longer match product truth.

### Flow

1. Load `$SHIPFLOW_ROOT/skills/references/editorial-content-corpus.md`, `shipflow_data/editorial/content-map.md` when present (fallback `CONTENT_MAP.md`), and `shipflow_data/editorial/README.md` when present (fallback legacy `docs/editorial/README.md`). If both README locations are missing, treat it as a first-run bootstrap trigger, not an immediate read failure.
2. Classify the request:
   - `editorial` or `docs/editorial` with missing docs -> scaffold from `templates/artifacts/editorial_content_context.md`.
   - missing `shipflow_data/editorial/README.md` with public surfaces -> bootstrap the baseline editorial governance layer, then audit it.
   - no detected public/content surfaces -> report `no editorial surfaces detected` and name `/sf-docs editorial` as the future adoption command.
   - `editorial audit` -> audit existing governance docs without rewriting unrelated content.
   - a changed public surface, claim, README, FAQ, pricing, public docs, or skill-page diff -> produce an `Editorial Update Plan`.
3. Detect public surfaces before creating files:
   - README public promises, public docs, FAQ, pricing, support copy, public skill pages, site routes, landing pages, blog/article intent, newsletter/social surfaces, `src/content`, `content/`, Astro/MDX runtime content, and framework content collections
   - if blog/article work is requested but no declared blog route exists, report `surface missing: blog`
   - preserve runtime content schemas; do not add ShipFlow metadata to runtime content unless the schema accepts it
4. For first-run bootstrap or scaffolding, create or update only the requested editorial governance docs plus shared maps when needed:
   - `shipflow_data/editorial/README.md` (or `docs/editorial/README.md`)
   - `shipflow_data/editorial/public-surface-map.md` (or `docs/editorial/public-surface-map.md`)
   - `shipflow_data/editorial/page-intent-map.md` (or `docs/editorial/page-intent-map.md`)
   - `shipflow_data/editorial/claim-register.md` (or `docs/editorial/claim-register.md`)
   - `shipflow_data/editorial/editorial-update-gate.md` (or `docs/editorial/editorial-update-gate.md`)
   - `shipflow_data/editorial/astro-content-schema-policy.md` (or `docs/editorial/astro-content-schema-policy.md`)
   - `shipflow_data/editorial/blog-and-article-surface-policy.md` (or `docs/editorial/blog-and-article-surface-policy.md`)
   - `templates/artifacts/editorial_content_context.md` when the template itself is missing or stale
5. For audit, verify:
   - `shipflow_data/editorial/content-map.md` (or `CONTENT_MAP.md`) points to the editorial governance layer
   - public surfaces in `site/src/pages/`, README, FAQ/pricing/docs overview, and public skill pages are represented or explicitly excluded
   - `shipflow_data/editorial/claim-register.md` (or `docs/editorial/claim-register.md`) covers sensitive public claims and unsupported public claims are marked `needs proof`, `claim mismatch`, or `blocked`
   - `shipflow_data/editorial/page-intent-map.md` (or `docs/editorial/page-intent-map.md`) records route intent, CTA, source contracts, and shared-file risk
   - `shipflow_data/editorial/editorial-update-gate.md` (or `docs/editorial/editorial-update-gate.md`) defines `Editorial Update Plan`, `Claim Impact Plan`, `no editorial impact`, and `pending final copy`
   - `shipflow_data/editorial/astro-content-schema-policy.md` (or `docs/editorial/astro-content-schema-policy.md`) protects Astro content schema and runtime content frontmatter
   - blog/article requests without a declared route produce `surface missing: blog`
   - `editorial_content_context` artifacts pass `$SHIPFLOW_ROOT/tools/shipflow_metadata_lint.py`
6. For changed public content, output an `Editorial Update Plan` in the format from `shipflow_data/editorial/editorial-update-gate.md` (fallback legacy `docs/editorial/editorial-update-gate.md`).

### Editorial Documentation Update Rules

- The Editorial Reader diagnoses impact; an executor or integrator applies updates.
- Shared editorial files are sequential by default.
- Do not publish internal-only technical details or private operational data into public pages.
- Do not strengthen public claims beyond `shipflow_data/business/business.md` (or `BUSINESS.md`), `shipflow_data/business/product.md` (or `PRODUCT.md`), `shipflow_data/business/branding.md` (or `BRANDING.md`), `shipflow_data/business/gtm.md` (or `GTM.md`), specs, verified behavior, and claim evidence.
- Do not change Astro runtime content frontmatter unless the local schema accepts it.

### Validation

```bash
python3 tools/shipflow_metadata_lint.py docs/editorial templates/artifacts/editorial_content_context.md
rg -n "Editorial Update Plan|Claim Impact Plan|pending final copy|surface missing|Astro content schema" docs/editorial
```

---

## README MODE

Generate or update `README.md` for the project.

### Flow

1. Analyze the project: package.json, CLAUDE.md, directory structure, framework, features.
2. Generate sections:

```markdown
# [Project Name]

[One-line description]

## Features
- [Auto-detected from code and package.json]

## Quick Start
[Install + run commands from package.json scripts]

## Project Structure
[Key directories and their purpose]

## Tech Stack
[Framework, UI, backend, auth — auto-detected]

## Environment Variables
[From .env.example or CLAUDE.md]

## Scripts
[All package.json scripts with descriptions]

## Contributing
[Standard section]
```

3. If README.md exists, use **AskUserQuestion**:
   - Question: "README.md already exists. How should I update it?"
   - Options:
     - **Merge** — "Add missing sections, keep existing content" (Recommended)
     - **Replace** — "Overwrite with fresh generation"
     - **Skip** — "Don't modify README.md"

---

## API MODE

Document all API routes/endpoints.

### Flow

1. Find all API route files:
   - Next.js: `app/api/**/route.ts`, `pages/api/**/*.ts`
   - Astro: `src/pages/api/**/*.ts`
   - Convex: `convex/*.ts` (queries, mutations, actions)
   - Python: FastAPI routes, Flask routes
2. For each endpoint, document:
   - **Method**: GET, POST, PUT, DELETE
   - **Path**: full URL path
   - **Auth**: required? what type?
   - **Request body**: schema/type
   - **Response**: schema/type + status codes
   - **Example**: curl or fetch example
3. Output to `docs/API.md` or inline in the route files (ask user preference).

---

## COMPONENTS MODE

Document all UI components.

### Flow

1. Find all component files in the project.
2. For each component, document:
   - **Name**: component name
   - **Description**: what it does (from code analysis)
   - **Props/Slots**: all accepted props with types and defaults
   - **Usage example**: how to use the component
   - **Dependencies**: what it imports/requires
3. Output to `docs/COMPONENTS.md` or as a component index.

---

## AUDIT MODE

Vérifier que la doc existante est cohérente avec le code, à jour, et respecte les conventions.

### Flow

1. **Inventorier toute la doc existante :**
   - README.md, CLAUDE.md, AGENT.md, CHANGELOG.md
   - `shipflow_data/technical/context.md` (fallback `CONTEXT.md`), `shipflow_data/technical/context-function-tree.md` (fallback `CONTEXT-FUNCTION-TREE.md`), `shipflow_data/editorial/content-map.md` (fallback `CONTENT_MAP.md`)
   - `shipflow_data/business/business.md`, `shipflow_data/business/branding.md`, `shipflow_data/business/product.md`, `shipflow_data/business/gtm.md`, `shipflow_data/technical/architecture.md`, `shipflow_data/technical/guidelines.md` (fallback legacy root equivalents)
   - `TEST_LOG.md`, `BUGS.md`, `bugs/` et `test-evidence/` quand présents
   - FOUNDER.md / AUTHOR.md, INSPIRATION.md, SOURCE.md
   - Dossier `docs/` (tous les fichiers .md)
   - JSDoc/TSDoc/docstrings dans le code
   - Commentaires d'en-tête de composants
   - `.env.example` vs variables réellement utilisées
   - Frontmatter ShipFlow sur les artefacts internes : specs, reports, reviews, research, audit docs, API/component docs générées, AGENT/CONTEXT docs
   - Si l'audit porte sur ShipFlow, `skills/`, `skills/*/SKILL.md`, la discovery de skills, ou la compatibilité Codex/Claude Code, frontmatter des skills via `$SHIPFLOW_ROOT/tools/skill_budget_audit.py`

2. **Vérifier la cohérence code ↔ doc :**
   - **Drift** : la doc mentionne-t-elle des fonctions/fichiers/routes qui n'existent plus ?
   - **Manques** : y a-t-il des exports publics, routes API, ou composants non documentés ?
   - **Exemples cassés** : les exemples de code dans la doc sont-ils encore valides ? (imports, noms de fonctions, signatures)
   - **Structure de fichiers** : l'arborescence documentée correspond-elle à la réalité ?
   - **Variables d'env** : `.env.example` liste-t-il toutes les variables utilisées dans le code ? Y a-t-il des variables documentées mais inutilisées ?
   - **Feature behavior** : les docs décrivent-elles encore le comportement actuel des features, permissions, limites, erreurs, pricing et intégrations ?
   - **Public promises** : les pages/docs promettent-elles sécurité, conformité, IA, automatisation, disponibilité ou gains sans preuve dans le produit ?
   - **Conversation persistence** : une conversation récente a-t-elle établi une preuve produit, une règle workflow durable, ou une FAQ utile qui n'existe pas encore dans README, docs, site, FAQ, skill pages, `shipflow_data/editorial/content-map.md`, ou docs techniques ?
   - **Professional bug loop** : la doc décrit-elle correctement les rôles `TEST_LOG.md` (tracker compact), `bugs/BUG-ID.md` (bug file source de vérité), `BUGS.md` (vue optionnelle/générée de triage), et `test-evidence/BUG-ID/` (preuves redigées) ?
   - **Bug tracker vs artifact** : une doc confond-elle `BUGS.md` avec le bug file source de vérité ?
   - **ShipFlow metadata** : les artefacts internes ShipFlow ont-ils le frontmatter obligatoire (`artifact`, `project`, `created`, `updated`, `status`, `scope`, `source_skill`) ?
   - **Skill budget compliance** : uniquement si la demande ou les fichiers touchent `skills/`, `skills/*/SKILL.md`, `agents/openai.yaml`, les descriptions/discovery de skills, ou la conformité Codex/Claude Code; lire `$SHIPFLOW_ROOT/skills/references/skill-context-budget.md`, puis lancer `$SHIPFLOW_ROOT/tools/skill_budget_audit.py --skills-root "$SHIPFLOW_ROOT/skills" --format markdown` et vérifier `name`, `path`, `description` en une phrase, absence de `Args:`, seuils `120/140/200`, total `name+description+path < 8000`, et corps `SKILL.md > 500` lignes.
   - **Version sync** : les specs, audits et reviews référencent-ils des versions business/techniques encore actuelles dans `depends_on` ?

3. **Vérifier les conventions :**
   - **ShipFlow language doctrine** : pour les artefacts ShipFlow, lire `shipflow_data/technical/guidelines.md` et `shipflow-spec-driven-workflow.md` si présents, puis vérifier que les contrats internes attendus sont en anglais (`SKILL.md` instructions, workflow rules, YAML/frontmatter keys, stable section headings, acceptance criteria, stop conditions, validation notes, technical decision docs).
   - **User-facing active language** : les questions, progress updates, rapports finaux, onboarding copy et product-visible text doivent rester dans la langue active de l'utilisateur ou du projet.
   - **Accents français** : si la langue active est le français, vérifier que le texte user-facing est en français naturel avec accents corrects; signaler l'écriture sans accents sauf identifiant technique, commande, slug ou format ASCII-only.
   - **No casual language mixing** : signaler le mélange non justifié de langues dans un même artefact; autoriser les ancres machine stables en anglais (`Status`, `Scope In`, `Acceptance Criteria`, `Skill Run History`) et les citations clairement labellisées dans leur langue d'origine.
   - **Format** : les fichiers .md suivent-ils un format cohérent entre eux ? (titres, sections, style)
   - **CLAUDE.md** : les règles et patterns documentés reflètent-ils le code actuel ?
   - **Nommage** : les noms de fichiers de doc suivent-ils une convention cohérente ?

4. **Vérifier la fraîcheur :**
   - Comparer la date du dernier commit qui touche la doc vs les commits récents qui touchent le code
   - Identifier les fichiers de doc qui n'ont pas été mis à jour depuis longtemps alors que le code associé a changé
   - Vérifier les numéros de version, dates, et compteurs mentionnés dans la doc

5. **Générer un rapport :**

```
## Audit Documentation — [projet]

### Résumé
| Check              | Résultat          |
|--------------------|-------------------|
| Cohérence code/doc | N drifts trouvés  |
| Conventions        | N écarts          |
| Fraîcheur          | N fichiers stale  |
| Couverture         | X% documenté      |

### DRIFT (doc ≠ code)
- [ ] [fichier.md:ligne] mentionne `functionX` qui n'existe plus
- [ ] [README.md] arborescence ne correspond plus à la réalité

### CONVENTIONS
- [ ] [skills/example/SKILL.md] internal workflow contract is not English where ShipFlow expects English
- [ ] [README.md] user-facing copy is not in the active user/project language
- [ ] [fichier.md] accents manquants : "genere" → "génère"
- [ ] [docs/guide.md] mélange casual FR/EN dans un même artefact sans citation ni ancre machine
- [ ] [docs/API.md] format incohérent avec docs/COMPONENTS.md

### STALE (doc périmée)
- [ ] [CLAUDE.md] dernière mise à jour il y a 3 mois, 15 commits code depuis
- [ ] [docs/feature.md] décrit l'ancien comportement d'une feature modifiée

### MANQUES (code non documenté)
- [ ] `src/api/payments.ts` — 4 endpoints sans documentation
- [ ] `src/components/Modal.tsx` — props non documentées

### METADATA SHIPFLOW
- [ ] `shipflow_data/workflow/specs/payment-flow.md` — frontmatter ShipFlow manquant
- [ ] `REVIEW-2026-04-25.md` — `confidence` / `risk_level` non renseignés
- [ ] `shipflow_data/workflow/specs/onboarding.md` — dépend de `shipflow_data/business/business.md@1.0.0` alors que `shipflow_data/business/business.md` est passé en `1.1.0`

### SKILL BUDGET COMPLIANCE
- [ ] `skills/sf-docs/SKILL.md` — `description` > 200 caractères ou contient `Args:`
- [ ] `skills/sf-example/SKILL.md` — `name` ne correspond pas au dossier
- [ ] Budget global `name + description + path` > 8000 caractères
- [ ] `skills/sf-large/SKILL.md` — corps > 500 lignes, extraire les détails vers `references/`

### PROFESSIONAL BUG MODEL
- [ ] [README.md] décrit `BUGS.md` comme source de vérité au lieu d'une vue de triage optionnelle vers bug file
- [ ] [workflow doc] ne mentionne pas `sf-test --retest BUG-ID` ni `Retest History` du bug file
- [ ] [guide QA] colle des logs bruts au lieu de pointer vers `test-evidence/BUG-ID/` redigé

### CONTEXTE BUSINESS/MARQUE
- [ ] `shipflow_data/business/business.md` absent — audience, proposition de valeur, business model non documentés
- [ ] `shipflow_data/business/product.md` absent — problèmes, workflows et non-goals non documentés
- [ ] `shipflow_data/business/gtm.md` absent — promesse publique, canaux et objections non documentés
- [ ] `shipflow_data/editorial/content-map.md` absent — surfaces de contenu, blog, docs, landing pages et cocons sémantiques non cartographiés
- [ ] `shipflow_data/business/branding.md` incomplet — section "Valeurs" contient `<!-- à confirmer -->`
- [ ] `shipflow_data/technical/architecture.md` stale — composants, flux ou invariants ne correspondent plus au code
- [ ] `shipflow_data/technical/guidelines.md` stale — stack détecté ≠ stack documenté

### RISQUES PRODUIT
- [ ] [docs/API.md] doc d'autorisation incomplète pour endpoint public
- [ ] [pricing.md] promet une capacité non présente dans le produit
```

---

## UPDATE MODE

Harmoniser et mettre à jour la doc existante pour la rendre cohérente.

### Flow

1. **Lancer d'abord un audit silencieux** (même logique que AUDIT MODE mais sans rapport).

1aa. **Vérifier le budget des skills seulement si la mise à jour touche les skills** :
   - Si la mise à jour touche `skills/`, `skills/*/SKILL.md`, `agents/openai.yaml`, les descriptions/discovery de skills, ou une preuve de conformité Codex/Claude Code, lire `$SHIPFLOW_ROOT/skills/references/skill-context-budget.md`, puis lancer `$SHIPFLOW_ROOT/tools/skill_budget_audit.py --skills-root "$SHIPFLOW_ROOT/skills"`.
   - Sinon, ne pas lancer cet audit : la conformité des skills ne doit pas devenir une charge globale pour les tâches documentaires sans lien avec les skills.
   - Si le script manque, signaler que la conformité des descriptions de skills n'est pas prouvée.
   - En mode `update`, ne pas réécrire toutes les descriptions automatiquement sauf demande explicite; classer les violations comme P0/P1/P2 selon impact.

1ab. **Persister les preuves et règles sorties d'une conversation** :
   - Relire `shipflow_data/editorial/content-map.md` quand la demande vient d'une conversation produit, d'une clarification utilisateur, d'un résultat d'audit, ou d'une preuve client nouvellement formulée.
   - Classer la surface cible: README, docs overview, FAQ, page skill, skill workflow interne, changelog, support copy, ou site public.
   - Écrire les surfaces `must write` et `should write` quand l'utilisateur demande d'appliquer ou dit de continuer.
   - Ne pas transformer une idée de chat en promesse publique si la preuve n'est pas présente dans le code, une spec prête, un audit, ou un résultat de validation.
   - Si une idée doit vivre dans un workflow de skill, mettre à jour le `SKILL.md` concerné plutôt que seulement une page éditoriale.

1ac. **Adopter ou auditer les corpus de gouvernance** :
   - Lire `skills/references/technical-docs-corpus.md` et `skills/references/editorial-content-corpus.md` depuis `$SHIPFLOW_ROOT`.
   - Vérifier `AGENT.md` comme entrypoint canonique et `AGENTS.md` comme symlink de compatibilité seulement. Si `AGENTS.md` est un vrai fichier ou pointe ailleurs, signaler `compatibility conflict`.
   - Si un projet contient du code mais pas `shipflow_data/technical/README.md` ou pas `shipflow_data/technical/code-docs-map.md`, lancer le comportement de bootstrap de `sf-docs technical`, puis auditer la couche créée. Si une couche legacy `docs/technical/` existe, la traiter comme source de migration.
   - Si aucun code significatif n'est détecté, reporter `technical governance: skipped - no code areas detected`; ne pas inventer de chemins.
   - Si des surfaces publiques existent mais pas `shipflow_data/editorial/README.md` (fallback legacy `docs/editorial/README.md`), lancer le comportement de bootstrap de `sf-docs editorial`, puis auditer la couche créée.
   - Si aucune surface publique ou de contenu n'est détectée, reporter `editorial governance: skipped - no editorial surfaces detected`.
   - Si `shipflow_data/editorial/content-map.md` est absent mais des surfaces publiques existent, créer ou mettre à jour `shipflow_data/editorial/content-map.md` avant `shipflow_data/editorial/` afin que la couche éditoriale ait une carte source. Si un root `CONTENT_MAP.md` existe, le traiter comme source de migration.
   - Si une couche ne peut pas être créée sans risque de collision, de schéma runtime incompatible, ou de copie de claims non prouvés, reporter `blocked` avec la prochaine commande sûre (`/sf-docs technical`, `/sf-docs editorial`, ou `/sf-spec` si la politique manque).

1a. **Vérifier la cohérence du modèle bug dans la doc** :
   - Les docs QA/ops expliquent `TEST_LOG.md` comme tracker compact.
   - Les docs QA/ops expliquent `bugs/BUG-ID.md` comme source de vérité et `BUGS.md` comme vue de triage optionnelle/générée.
   - Les docs mentionnent `bugs/BUG-ID.md` pour le détail (repro, expected/observed, Fix Attempts, Retest History, statut).
   - Les docs mentionnent `test-evidence/BUG-ID/` pour les preuves volumineuses, avec redaction obligatoire.
   - Les docs ne demandent pas d'ajouter de frontmatter à `TEST_LOG.md`/`BUGS.md` (tracker rule).

1b. **Vérifier les registres business optionnels quand ils existent :**
   - `shipflow_data/business/project-competitors-and-inspirations.md` est optionnel. Ne pas le créer automatiquement pour tous les projets. S'il existe, il doit utiliser `artifact: competitive_intelligence`, les champs requis par le linter, des URLs/dates de preuve quand disponibles, et une séparation claire entre observation, inférence et inspiration.
   - `shipflow_data/business/affiliate-programs.md` est optionnel. Ne pas le créer automatiquement pour tous les projets. S'il existe, il doit utiliser `artifact: affiliate_program_registry`, les champs requis par le linter, une policy de disclosure, et une règle explicite interdisant secrets, tokens privés, coordonnées bancaires ou informations fiscales.
   - Si un projet contient des concurrents/inspirations ou affiliations dans `shipflow_data/business/business.md`, `shipflow_data/business/gtm.md`, `README.md`, `shipflow_data/workflow/TASKS.md`, `PROJECTS.md`, ou une note ad hoc, recommander l'extraction vers le registre optionnel seulement si l'information gouverne réellement le positionnement, la monétisation, une recommandation publique ou une disclosure.
   - Si un registre optionnel existe mais échoue au linter, corriger sa compliance ou rapporter `metadata compliance not proven`; ne pas supprimer le registre pour éviter la conformité.

1c. **Migrer les anciens artefacts ShipFlow si nécessaire :**
   - Ajouter le frontmatter ShipFlow obligatoire aux specs, reviews, audits, research reports et docs projet qui n'en ont pas.
   - Préserver le contenu existant.
   - Inférer seulement les champs évidents depuis le nom de fichier, le titre, la date et le contenu.
   - Utiliser `unknown` pour les champs non prouvés et `confidence: low` quand les métadonnées sont reconstruites.
   - Utiliser `artifact_version: "0.1.0"` pour les artefacts migrés non revus, puis passer à `1.0.0` après revue explicite.
   - Ajouter `depends_on` quand un artefact mentionne clairement une doc business/technique versionnée.
   - Ne pas migrer les contenus applicatifs runtime (`src/content/**`, blog MDX, pages SEO) vers le schéma ShipFlow.

2. **Vérifier les fichiers de contexte business/produit/architecture/GTM/marque :**

   Pour chaque fichier canonique (`shipflow_data/business/business.md`, `shipflow_data/business/branding.md`, `shipflow_data/business/product.md`, `shipflow_data/technical/architecture.md`, `shipflow_data/business/gtm.md`, `shipflow_data/editorial/content-map.md`, `shipflow_data/technical/guidelines.md`) avec fallback legacy racine si présent :

   **Si absent** → le créer en posant les questions nécessaires :
   - `shipflow_data/business/business.md` : **AskUserQuestion** "Décris ton projet en une phrase — qu'est-ce que ça fait et pour qui ?" puis générer
   - `shipflow_data/business/branding.md` : **AskUserQuestion** "Quel ton pour ce projet ?" avec options adaptées
   - `shipflow_data/business/product.md` : poser les questions minimales sur le problème, les workflows cœur, et les non-goals si le code ne suffit pas
   - `shipflow_data/technical/architecture.md` : auto-générer depuis la structure, les entry points, les flux et les dépendances détectées, puis affiner si nécessaire
   - `shipflow_data/business/gtm.md` : poser les questions minimales sur segment prioritaire, promesse publique, canaux et preuves si le repo ne suffit pas
   - `shipflow_data/editorial/content-map.md` : auto-générer depuis les dossiers de contenu détectés, les pages publiques, les docs, les collections, les routes marketing et les clusters sémantiques visibles; utiliser `templates/artifacts/content_map.md` comme base
   - `shipflow_data/technical/guidelines.md` : auto-généré depuis le stack détecté, pas de question
   - Chaque fichier créé doit inclure le frontmatter ShipFlow obligatoire, démarrer en `artifact_version: "0.1.0"` si une partie est inférée, et documenter `evidence`, `depends_on`, `supersedes`, `next_review`, `status`, `confidence` et `risk_level`.

   **Si présent mais incomplet** (sections avec `<!-- à confirmer -->`, < 5 lignes de contenu, sections vides) → proposer de compléter :
   - Lire le fichier existant
   - Identifier les sections vides ou marquées à confirmer
   - Poser des questions ciblées UNIQUEMENT sur les sections manquantes
   - Compléter sans écraser le contenu existant
   - Après mise à jour, appliquer le bump d'`artifact_version` approprié : patch si clarification éditoriale, minor si nouvelle décision compatible, major si changement de cible, business model, pricing, positionnement, architecture, données, sécurité ou promesse produit.

   **Si présent et complet** → vérifier la cohérence :
   - business : l'audience décrite correspond-elle au contenu du site ? le business model est-il cohérent avec les intégrations détectées ?
   - branding : le ton décrit correspond-il au ton réel du contenu existant ?
   - product : les workflows et non-goals décrits correspondent-ils aux capacités réellement visibles ?
   - architecture : les composants, flux et invariants décrits correspondent-ils au code réel ?
   - GTM : les promesses, preuves et canaux sont-ils compatibles avec ce que le produit et les docs peuvent soutenir honnêtement ?
   - content map : les chemins blog/docs/landing/FAQ/support/newsletter, les cocons sémantiques, les pages piliers et les règles de mise à jour correspondent-ils aux surfaces réelles ?
   - guidelines : le stack documenté correspond-il au stack réel ?
   - Metadata : `metadata_schema_version`, `artifact_version`, `status`, `confidence`, `risk_level`, `evidence`, `next_review`, `depends_on` et `supersedes` sont-ils présents et cohérents ?
   - Version sync : les dépendances référencées existent-elles encore avec la version attendue ? Les specs/reviews/audits qui dépendent d'une ancienne version doivent-ils être marqués à rechecker ?
   - Si incohérence trouvée : proposer la correction avec **AskUserQuestion** "Le contexte business mentionne [X] mais le code montre [Y]. Je mets à jour ?"

   Stocker les fichiers directement dans le repo du projet, sous leurs chemins canoniques `shipflow_data/...`.

   Les registres `shipflow_data/business/project-competitors-and-inspirations.md` et `shipflow_data/business/affiliate-programs.md` sont des contrats business optionnels. Ne les ajouter que si l'utilisateur le demande, si une étude de marché/GTM en produit le besoin, ou si des liens/recommandations publics rémunérés existent. Quand ils existent, les inclure dans la validation metadata et la cohérence documentaire.

3. **Classer les problèmes techniques par priorité :**
   - **P0** : drift dangereux (doc qui induit en erreur — mauvaises commandes, fonctions supprimées)
   - **P1** : conventions non respectées (doctrine de langue ShipFlow, langue active, accents, format)
   - **P2** : doc périmée mais pas fausse (dates, compteurs, arborescences)
   - **P3** : manques de couverture (code non documenté)

4. **Proposer un plan d'action** avec **AskUserQuestion** :
   - Question : "Quels niveaux de problèmes je corrige ?"
   - `multiSelect: true`
   - Options :
     - **P0 — Drift dangereux** — "Doc qui induit en erreur" (Recommandé)
     - **P1 — Conventions** — "Langue, accents, format"
     - **P2 — Doc périmée** — "Dates, compteurs, arborescences"
     - **P3 — Couverture** — "Ajouter la doc manquante"

5. **Appliquer les corrections** pour les niveaux sélectionnés :
   - Corriger chaque fichier de doc concerné
   - Pour les arborescences : régénérer depuis le filesystem réel
   - Pour les compteurs/dates : mettre à jour avec les valeurs actuelles
   - Pour les accents : corriger systématiquement
   - Pour la doctrine de langue ShipFlow : convertir seulement les sections touchées; garder les contrats internes en anglais, le contenu user-facing dans la langue active, les ancres machine en anglais, et les citations dans leur langue originale.
   - Pour les manques : ajouter la documentation (inline ou fichier séparé selon le pattern existant)

6. **Rapport final :**

```
## Mise à jour Documentation — [projet]

**Contexte business/marque :**
- shipflow_data/business/business.md : [créé / complété / mis à jour / OK]
- shipflow_data/business/branding.md : [créé / complété / mis à jour / OK]
- shipflow_data/business/product.md : [créé / complété / mis à jour / OK]
- shipflow_data/technical/architecture.md : [créé / complété / mis à jour / OK]
- shipflow_data/business/gtm.md : [créé / complété / mis à jour / OK]
- shipflow_data/editorial/content-map.md : [créé / complété / mis à jour / OK]
- shipflow_data/technical/guidelines.md : [créé / mis à jour / OK]
- project-competitors-and-inspirations.md : [absent optionnel / créé / complété / mis à jour / OK / compliance gap]
- affiliate-programs.md : [absent optionnel / créé / complété / mis à jour / OK / compliance gap]

**Doc technique corrigée :**
- [N] drifts corrigés (P0)
- [N] conventions alignées (P1)
- [N] fichiers rafraîchis (P2)
- [N] docs ajoutées (P3)

**Corpus de gouvernance :**
- AGENT.md / AGENTS.md : [OK / created / compatibility conflict / blocked]
- shipflow_data/technical : [created / already existed / needs audit / skipped - no code areas detected / blocked]
- shipflow_data/editorial : [created / already existed / needs audit / skipped - no editorial surfaces detected / blocked]
- shipflow_data/editorial/content-map.md : [created / updated / already existed / stale / blocked]

**Fichiers modifiés :**
- shipflow_data/business/business.md — section Audience complétée
- shipflow_data/business/product.md — workflows cœur clarifiés
- shipflow_data/technical/architecture.md — flux et invariants ajoutés
- shipflow_data/business/gtm.md — segment, promesse et objections formalisés
- shipflow_data/editorial/content-map.md — surfaces blog/docs/landing et cocons sémantiques cartographiés
- README.md — arborescence mise à jour, compteur skills corrigé
- CLAUDE.md — section Framework actualisée
- docs/API.md — 3 endpoints ajoutés, 1 endpoint supprimé retiré
```

---

## LAYOUT MIGRATION MODE

Move legacy root ShipFlow artifacts into the canonical project-local `shipflow_data/` corpus.

Use this mode for:
- `$ARGUMENTS` = `migrate-layout`
- `$ARGUMENTS` = `layout`
- explicit user requests such as "range les docs ShipFlow", "move root ShipFlow markdown", "migrate project docs to shipflow_data", or "clean root governance files"

### Flow

1. **Inventory root legacy artifacts**
   - Detect root files:
     - `BUSINESS.md` -> `shipflow_data/business/business.md`
     - `PRODUCT.md` -> `shipflow_data/business/product.md`
     - `BRANDING.md` -> `shipflow_data/business/branding.md`
     - `GTM.md` -> `shipflow_data/business/gtm.md`
     - `INSPIRATION.md` -> `shipflow_data/business/project-competitors-and-inspirations.md`
     - `AFFILIATES.md` -> `shipflow_data/business/affiliate-programs.md`
     - `CONTEXT.md` -> `shipflow_data/technical/context.md`
     - `CONTEXT-FUNCTION-TREE.md` -> `shipflow_data/technical/context-function-tree.md`
     - `ARCHITECTURE.md` -> `shipflow_data/technical/architecture.md`
     - `GUIDELINES.md` -> `shipflow_data/technical/guidelines.md`
     - `CONTENT_MAP.md` -> `shipflow_data/editorial/content-map.md`
     - `TASKS.md` -> `shipflow_data/workflow/TASKS.md`
     - `AUDIT_LOG.md` -> `shipflow_data/workflow/AUDIT_LOG.md`
   - Detect root directories:
     - `specs/` -> `shipflow_data/workflow/specs/`
     - `bugs/` -> `shipflow_data/workflow/bugs/`
     - `research/` -> `shipflow_data/workflow/research/`
     - `reviews/` -> `shipflow_data/workflow/reviews/`
     - `audits/` -> `shipflow_data/workflow/audits/`
     - `verification/` -> `shipflow_data/workflow/verification/`

2. **Classify each item**
   - `moveable`: destination missing and source is a ShipFlow governance artifact.
   - `collision`: destination already exists; compare before deciding.
   - `external-root-ok`: `README.md`, `AGENT.md`, `AGENTS.md` symlink, optional `CLAUDE.md`, optional `CHANGELOG.md`, or project/tool-native docs that are not ShipFlow governance.
   - `tracker`: root `TASKS.md` and root `AUDIT_LOG.md` are layout migration candidates; canonical `shipflow_data/workflow/TASKS.md`, `shipflow_data/workflow/AUDIT_LOG.md`, `${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}/PROJECTS.md`, `BUGS.md`, and `TEST_LOG.md` are trackers and do not get frontmatter.
   - `runtime-content`: leave in place unless a project-specific migration is required.

3. **Move safely**
   - Create destination directories.
   - Move only `moveable` items.
   - Do not overwrite destination files.
   - For collisions, report both files and require a merge decision unless content is byte-identical.
   - Preserve git history where possible with `git mv` when inside a git repo; otherwise use a normal move.

4. **Update references**
   - Replace root governance references with canonical paths in touched docs and skill-owned docs where safe.
   - Do not rewrite quoted historical evidence unless it would confuse the active contract.
   - Keep legacy names only when explicitly labeled as migration sources or historical references.

5. **Validate**
   - Run:

```bash
SHIPFLOW_ROOT="${SHIPFLOW_ROOT:-$HOME/shipflow}"
"$SHIPFLOW_ROOT/tools/shipflow_metadata_lint.py"
```

   - Run targeted link/path checks for moved names:

```bash
rg -n "BUSINESS\\.md|PRODUCT\\.md|BRANDING\\.md|GTM\\.md|ARCHITECTURE\\.md|CONTENT_MAP\\.md|CONTEXT\\.md|CONTEXT-FUNCTION-TREE\\.md|GUIDELINES\\.md" .
```

6. **Report**

```text
## Layout Migration — [project]

Moved:
- [source] -> [destination]

Collisions:
- [source] -> [destination]: [reason / next action]

Root files allowed:
- README.md
- AGENT.md
- AGENTS.md -> AGENT.md
- CLAUDE.md [if adopted]
- CHANGELOG.md [if maintained]

Validation:
- metadata lint: [passed / failed]
- root legacy artifacts remaining: [none / list]
```

---

## METADATA MODE

Migrer et vérifier le frontmatter ShipFlow des anciens artefacts actifs sans réécrire leur contenu.

Use this mode for:
- `$ARGUMENTS` = `metadata`
- `$ARGUMENTS` = `migrate-frontmatter`
- explicit user requests such as "migrate frontmatter", "make docs metadata compliant", "verify ShipFlow metadata", or "check docs compliance"

### Flow

1. **Lire la doctrine de migration**
   - Lire `shipflow-metadata-migration-guide.md` si présent.
   - Lire `shipflow-spec-driven-workflow.md` si présent et si le scope touche specs, readiness, verification, audits or decision contracts.
   - Lire le linter canonique ShipFlow: `$SHIPFLOW_ROOT/tools/shipflow_metadata_lint.py` (`$SHIPFLOW_ROOT` par défaut `${SHIPFLOW_ROOT:-$HOME/shipflow}`).
   - Si un de ces fichiers est absent, continuer avec la doctrine de cette skill et signaler le gap.

2. **Définir le scope avant édition**
   - Scope par défaut pour legacy adoption :
     - `AGENT.md`
     - `shipflow_data/technical/context.md`; root `CONTEXT.md` only as migration source
     - `shipflow_data/technical/context-function-tree.md`; root `CONTEXT-FUNCTION-TREE.md` only as migration source
     - `shipflow_data/editorial/content-map.md`; root `CONTENT_MAP.md` only as migration source
     - `shipflow_data/business/business.md`; root `BUSINESS.md` only as migration source
     - `shipflow_data/business/branding.md`; root `BRANDING.md` only as migration source
     - `shipflow_data/business/product.md`; root `PRODUCT.md` only as migration source
     - `shipflow_data/technical/architecture.md`; root `ARCHITECTURE.md` only as migration source
     - `shipflow_data/business/gtm.md`; root `GTM.md` only as migration source
     - `shipflow_data/business/project-competitors-and-inspirations.md` si le fichier existe
     - `shipflow_data/business/affiliate-programs.md` si le fichier existe
     - `shipflow_data/technical/guidelines.md`; root `GUIDELINES.md` only as migration source
     - `shipflow_data/workflow/specs/*.md`; root `specs/*.md` only as migration source
     - `docs/**/*.md` seulement si le dossier existe et contient des artefacts ShipFlow actifs
   - `CLAUDE.md` n'entre dans ce scope que si le repo l'a explicitement promu comme artefact officiel de guidance.
   - Ne pas élargir automatiquement à tous les `.md` du repo.
   - Ne pas migrer `archive/`, anciennes notes ad hoc, rapports historiques, ou docs expérimentales sauf si l'utilisateur les promeut explicitement comme artefacts actifs.
   - Si l'utilisateur demande "toutes les docs", interpréter comme "tous les artefacts ShipFlow actifs" et rapporter les exclusions.

3. **Classer chaque fichier candidat**

   Produire mentalement ou dans le rapport ces catégories :
   - `migrate` — artefact ShipFlow actif sans frontmatter ou avec frontmatter incomplet.
   - `already compliant` — artefact actif avec frontmatter valide.
   - `runtime content` — contenu applicatif dont le frontmatter est consommé par le framework (`src/content/**`, blog MDX, pages SEO, collections Astro, etc.).
   - `tracker excluded` — canonical `shipflow_data/workflow/TASKS.md`, `shipflow_data/workflow/AUDIT_LOG.md`, and `${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}/PROJECTS.md`.
   - `archive excluded` — archive, notes historiques, rapports obsolètes.
   - `ambiguous` — fichier dont le rôle n'est pas clair.

   Pour `runtime content`, préserver le schéma applicatif. Ne pas ajouter de frontmatter ShipFlow si cela peut casser le parser.

   Pour `tracker excluded`, ne jamais ajouter de frontmatter. Si le tracker contient une décision durable, recommander d'extraire cette décision dans un artefact séparé. Si le tracker est encore à la racine du projet (`TASKS.md` ou `AUDIT_LOG.md`), le classer `legacy root tracker` et le migrer vers `shipflow_data/workflow/` quand cela ne casse pas un outil externe.

   Pour `legacy root artifact`, ne pas le considérer compliant même s'il a du frontmatter valide. Le migrer vers le chemin canonique sous `shipflow_data/`, puis supprimer ou archiver le fichier racine seulement si cela ne casse pas un outil externe. `AGENT.md`, `README.md`, `AGENTS.md` symlink, `CHANGELOG.md`, et `CLAUDE.md` explicitement adopté sont les exceptions racine.

   Pour `ambiguous`, demander confirmation si la migration changerait la source de vérité, la visibilité publique, le runtime, ou le périmètre officiel. Sinon laisser exclu et rapporter.

4. **Migrer de façon additive**
   - Ajouter uniquement le frontmatter ShipFlow.
   - Préserver intégralement le body.
   - Ne pas normaliser les titres, sections, langue, style, liens ou contenu pendant la passe metadata.
   - Inférer seulement les champs évidents depuis le chemin, le titre, le contenu, la date et les contrats cités.
   - Utiliser `unknown` quand une valeur n'est pas prouvée.
   - Utiliser `confidence: low` pour une migration reconstruite.
   - Utiliser `status: draft` et `artifact_version: "0.1.0"` tant qu'il n'y a pas eu revue explicite.
   - Pour un artefact déjà `reviewed`, `ready` ou `active`, vérifier que `artifact_version >= 1.0.0`; sinon garder prudent ou demander confirmation.
   - Ajouter `depends_on` seulement quand une dépendance business/technique est clairement citée.
   - Ajouter `supersedes` seulement si le fichier remplace explicitement une ancienne source.

5. **Valider avec le linter**
   - Après migration, lancer le linter sur le scope prévu :

```bash
SHIPFLOW_ROOT="${SHIPFLOW_ROOT:-$HOME/shipflow}"
"$SHIPFLOW_ROOT/tools/shipflow_metadata_lint.py"
```

   - Si le scope est explicite, préférer :

```bash
SHIPFLOW_ROOT="${SHIPFLOW_ROOT:-$HOME/shipflow}"
"$SHIPFLOW_ROOT/tools/shipflow_metadata_lint.py" AGENT.md shipflow_data/editorial/content-map.md shipflow_data/business/business.md shipflow_data/business/product.md shipflow_data/business/branding.md shipflow_data/business/gtm.md shipflow_data/business/project-competitors-and-inspirations.md shipflow_data/business/affiliate-programs.md shipflow_data/technical/context.md shipflow_data/technical/context-function-tree.md shipflow_data/technical/architecture.md shipflow_data/technical/guidelines.md shipflow_data/workflow/specs docs
```

   - Si `CLAUDE.md` est officialisé dans le repo, l'ajouter explicitement au scope de validation au lieu de l'imposer partout par défaut.

   - Pour une vérification large volontaire, utiliser `--all-markdown` seulement si l'utilisateur a explicitement demandé de contrôler tous les Markdown, en sachant que les contenus runtime et archives peuvent produire des faux positifs.
   - Si le linter échoue, corriger les erreurs de frontmatter dans les fichiers migrés. Ne pas "corriger" en ajoutant du frontmatter à des fichiers exclus.
   - Si le linter ne peut pas être lancé, rapporter `metadata compliance not proven`.

6. **Rapport final**

```text
## Metadata Migration — [project]

Scope:
- Intended: [paths]
- Migrated: [N files]
- Already compliant: [N files]
- Excluded runtime content: [N files]
- Excluded trackers: [N files]
- Excluded archives/history: [N files]
- Ambiguous: [N files]

Validation:
- Linter: [passed / failed / not available]
- Command: [exact command]

Files changed:
- [file] — [frontmatter added/normalized, body preserved]

Remaining gaps:
- [ambiguous file / missing proof / linter limitation / runtime schema risk]
```

### Rules

- Metadata migration is not a content rewrite.
- Prefer a narrow official scope over an endless cleanup of historical Markdown.
- Do not pretend inferred metadata is reviewed. Use `draft`, `0.1.0`, `confidence: low`, and `unknown`.
- Do not make runtime content compliant at the cost of breaking the app.
- Do not add frontmatter to operational trackers.
- Always report what was excluded and why.

---

## AUTO MODE

Detect documentation gaps and suggest what to document.

### Flow

1. Check for:
   - Missing README.md
   - Undocumented exports (no JSDoc/docstring)
   - API routes without documentation
   - Components without prop documentation
   - Missing .env.example
   - Missing CHANGELOG.md
2. Use **AskUserQuestion**:
   - Question: "I found these documentation gaps. What should I document?"
   - `multiSelect: true`
   - Options based on detected gaps

---

## Important

- **Read actual code** — never invent functionality that doesn't exist.
- **Match existing doc style** — if the project uses a specific documentation format, follow it.
- **French for French projects** — GoCharbon, claiire, plaisirsurprise (FR content).
- **ShipFlow language doctrine** — internal contracts use English; user-facing interaction uses the active user/project language; stable machine-readable labels stay English; quoted user input, source evidence, legal text, and external material keep their original language.
- Every code example must be **syntactically correct** and **runnable**.
- Don't over-document. Simple, self-explanatory code doesn't need comments.
- For component docs, include the actual prop types from the source code.
- Keep README concise — link to detailed docs instead of putting everything in one file.
- **Accents français obligatoires.** Lors de toute création ou modification de contenu en français, vérifier systématiquement que TOUS les accents sont présents et corrects (é, è, ê, à, â, ù, û, ô, î, ï, ç, œ, æ). Les accents manquants sont une faute d'orthographe. Relire chaque texte produit pour s'assurer qu'aucun accent n'a été oublié — c'est une erreur très fréquente à corriger impérativement.
