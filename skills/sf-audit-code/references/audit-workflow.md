---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipFlow
created: "2026-05-16"
updated: "2026-05-16"
status: draft
source_skill: sf-start
scope: sf-audit-code-audit-workflow
owner: unknown
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/sf-audit-code/SKILL.md
  - skills/sf-audit-code/references/audit-workflow.md
depends_on:
  - artifact: "skills/references/skill-instruction-layering.md"
    artifact_version: "0.1.0"
    required_status: "draft"
supersedes: []
evidence:
  - "Extracted from skills/sf-audit-code/SKILL.md during Compact ShipFlow Skill Instructions Phase 2."
next_review: "2026-06-16"
next_step: "/sf-verify Compact ShipFlow Skill Instructions Phase 2"
---

# Audit Workflow

## Purpose

GLOBAL, FILE, and PROJECT mode workflow, phase checklists, scoring, fix/report rules, and tracking details.

This reference preserves the detailed pre-compaction instructions for `sf-audit-code`. The top-level `SKILL.md` is now the activation contract; load this file only when the selected mode needs the detailed workflow, checklist, templates, or examples below.

## Detailed Instructions

## Canonical Paths

Before resolving any ShipFlow-owned file, load `$SHIPFLOW_ROOT/skills/references/canonical-paths.md` (`$SHIPFLOW_ROOT` defaults to `$HOME/shipflow`). ShipFlow tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPFLOW_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Chantier Tracking

Trace category: `conditionnel`.
Process role: `source-de-chantier`.

Before producing the final report, load `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md` when this run is attached to a spec-first chantier. If exactly one active `specs/*.md` chantier is identified, append the current run to `Skill Run History`, update `Current Chantier Flow` when the run changes the chantier state, and include a final `Chantier` block. If no unique chantier is identified, do not write to any spec; report `Chantier: non applicable` or `Chantier: non trace` with the reason.

## Chantier Potential Intake

Because this skill has process role `source-de-chantier`, evaluate the standard threshold from `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md` before the final report. If the findings reveal non-trivial future work and no unique chantier owns it, do not write to an existing spec; add a `Chantier potentiel` block with `oui`, `non`, or `incertain`, a proposed title, reason, severity, scope, evidence, recommended `/sf-spec ...` command, and next step. If the work is only a direct local fix or already belongs to the current chantier, state `Chantier potentiel: non` with the concrete reason.

## Report Modes

Before producing the final report, load `$SHIPFLOW_ROOT/skills/references/reporting-contract.md`.

Default to `report=user`: concise, findings-first, and focused on top issues, proof gaps, chantier potential, and the next real action. Use `report=agent`, `handoff`, `verbose`, or `full-report` for the detailed audit matrix, domain checklist output, command evidence, assumptions, confidence limits, and handoff notes.


## Context

- Current directory: !`pwd`
- Project CLAUDE.md: !`head -120 CLAUDE.md 2>/dev/null || echo "no CLAUDE.md"`
- Business metadata: !`for pair in "shipflow_data/business/business.md BUSINESS.md" "shipflow_data/business/branding.md BRANDING.md" "shipflow_data/technical/guidelines.md GUIDELINES.md"; do set -- $pair; if [ -f "$1" ]; then f="$1"; elif [ -f "$2" ]; then f="$2"; else echo "$2: missing (no $1)"; continue; fi; printf '%s: ' "$f"; sed -n '1,40p' "$f" | grep -E '^(metadata_schema_version|artifact_version|status|updated|confidence|next_review):' | tr '\n' ' '; printf '\n'; done`
- Package.json: !`cat package.json 2>/dev/null | head -80 || echo "no package.json"`
- Dependencies: !`cat package.json 2>/dev/null | grep -E '"(dependencies|devDependencies)"' -A 100 | head -80 || pip list 2>/dev/null | head -40 || echo "unknown"`
- Lockfile: !`ls -1 package-lock.json yarn.lock pnpm-lock.yaml requirements.txt Pipfile.lock 2>/dev/null | head -3 || echo "none"`
- Project structure: !`find . -maxdepth 3 -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" -o -name "*.astro" -o -name "*.vue" -o -name "*.py" -o -name "*.sh" \) 2>/dev/null | grep -v node_modules | grep -v .git | grep -v dist | sort | head -60`
- Config files: !`ls -1 tsconfig*.json astro.config.* next.config.* vite.config.* vitest.config.* .eslintrc* eslint.config.* prettier.config.* .env.example 2>/dev/null || echo "none"`
- CI/CD: !`ls -1 .github/workflows/*.yml Dockerfile docker-compose.yml 2>/dev/null || echo "none"`

## Mode detection

- **`$ARGUMENTS` is "global"** → GLOBAL MODE: audit ALL projects in the workspace.
- **`$ARGUMENTS` is a file path** → FILE MODE: deep code review of that single file.
- **`$ARGUMENTS` is empty** → PROJECT MODE: full architecture/perf/security/reliability audit.

---

## Audit doctrine

Audit against the current ShipFlow doctrine:
- start from the `User Story` or the most likely user-facing promise, not from implementation trivia
- judge whether the product behavior is coherent for the actor, trigger, expected outcome, and scope boundaries
- look for workflow bypass, replay, misuse, stale state, and inconsistent outcomes
- review security with modern expectations, proportionate to risk
- keep the audit actionable: concrete evidence, concrete impact, concrete next step

If no explicit user story exists, reconstruct the most likely one from routes, UI labels, docs, tests, and task context. State clearly when it is inferred.

Before scoring, always answer:
- who is the actor?
- what outcome is the code trying to deliver?
- what user-visible or operator-visible behavior proves success?
- what linked systems, invariants, and trust boundaries could break?

If an ambiguity changes product meaning, permissions, data exposure, tenant isolation, money movement, destructive behavior, or external side effects, do not smooth it over. Ask the user a targeted question or mark the finding as blocking.

## Metadata versioning doctrine

`BUSINESS.md`, `BRANDING.md`, and `GUIDELINES.md` are ShipFlow decision contracts when code behavior implements a user promise, role model, trust posture, workflow, pricing boundary, onboarding path, or public claim. Before scoring:
- Read/report `artifact_version`, `status`, `updated`, `confidence`, and `next_review` when available.
- If `artifact_version`, `status`, or `updated` is missing, add a proof gap: `business doc metadata incomplete`.
- If `status` is `draft`, `stale`, `outdated`, `deprecated`, or `confidence` is `low`, cap confidence and state that product-code scoring depends on an unreviewed decision contract.
- If `next_review` is before today's absolute date, treat the document as stale unless a newer replacement is explicit.
- If behavior, permissions, data retention, payment logic, AI behavior, security posture, or workflow expectations rely on stale or unversioned docs, do not give `A` to `User Story Fit`, `Workflow Integrity`, or `Security`.
- Include a `Business metadata versions` section in every report.

Use ShipFlow versioning semantics: patch = clarification with no behavior/decision change, minor = changed decision guidance inside the same product strategy, major = changed ICP, positioning, pricing model, trust posture, permission model, data posture, or core product promise.

---

## GLOBAL MODE

Audit ALL projects in the workspace for code quality, architecture, security, and reliability.

1. Read `${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}/PROJECTS.md` — check the **Domain Applicability** table. Identify projects with ✓ in the Code column.

2. Use **AskUserQuestion** to let the user choose:
   - Question: "Which projects should I audit for code quality?"
   - `multiSelect: true`
   - One option per applicable project: label = project name, description = stack from PROJECTS.md
   - All projects pre-listed as options

3. Use the **Task tool** to launch one agent per **selected** project — ALL IN A SINGLE MESSAGE (parallel). Each agent: `subagent_type: "general-purpose"`.

   Agent prompt must include:
   - `cd [path]` then read `CLAUDE.md` for project context
   - The absolute date, exact project path, and the config/manifests already surfaced by this skill (`package.json`, lockfiles, config files, CI files)
   - The complete **PROJECT MODE** section from this skill (all 9 phases: Scope & User Story → Workflow Integrity & Product Coherence → Architecture → Performance → Security → Reliability → Modern Best Practices → Fix → Report)
   - The **Tracking** section from this skill
   - Rule: **read-only analysis** — no code fixes, only update AUDIT_LOG.md and TASKS.md
   - Rule: before scoring, identify the explicit or inferred user story, linked systems, consumers, contracts, trust boundaries, and probable downstream consequences
   - Rule: do one adversarial pass for bypass, double submission, stale state, replay, partial failure, and unauthorized actor paths
   - Rule: read/report `BUSINESS.md`, `BRANDING.md`, and `GUIDELINES.md` metadata versions when they affect product behavior, trust posture, roles, pricing, or claims; flag missing, stale, low-confidence, or unversioned contracts as proof gaps before scoring
   - Rule: do not ask follow-up questions; if context is missing, state assumptions / confidence limits and continue
   - Required sub-report sections: `Scope understood`, `User story`, `Business metadata versions`, `Context read`, `Linked systems & consequences`, `Adversarial review`, `Security review`, `Findings`, `Confidence / missing context`

4. After all agents return, compile a **cross-project code report**:

   ```
   GLOBAL CODE AUDIT — [date]
   ═══════════════════════════════════════
   PROJECT SCORES
     [project]    [A/B/C/D]  —  summary
     ...
   CROSS-PROJECT PATTERNS
     [Systemic issues in 2+ projects]
   ALL ISSUES BY SEVERITY
     🔴 [project] file:line — description
     🟠 [project] file:line — description
     🟡 [project] file:line — description
   Total: X critical, Y high, Z medium across N projects
   ═══════════════════════════════════════
   ```

5. Update `${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}/AUDIT_LOG.md` (one row per project, Code column) and `${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}/TASKS.md` (each project's `### Audit: Code` subsection).

6. Ask: **"Which projects should I fix?"** — list projects with scores. Fix only approved projects, one at a time.

---

## FILE MODE

### Step 1: Gather context

1. Read the target file (`$ARGUMENTS`).
2. Read files it imports/depends on (follow the imports, 1 level deep).
3. Read the types/interfaces it uses.
4. Identify the file's role: component, page, API route, utility, config, test, etc.
5. Infer or locate the user story / product promise this file serves:
   - Use nearby docs, route names, UI labels, tests, comments, and task context.
   - State the actor, trigger, expected outcome, and value.
   - If inferred rather than explicit, say so.
6. Identify linked systems, trust boundaries, and consequences:
   - consumers, routes, jobs, APIs, webhooks, storage, analytics, auth, tenant boundaries, admin surfaces
   - preconditions, postconditions, invariants, and failure modes
7. Identify project conventions this file must fit:
   - Look for existing equivalents before suggesting “new utils”:
     - Search for same responsibility by filename (`date*`, `error*`, `format*`, `validate*`, `client*`, `logger*`) and by key identifiers.
     - Check canonical folders (`utils/`, `lib/`, `shared/`, `common/`, `services/`, `core/`) for existing helpers.
   - Determine the standard patterns in this codebase for:
     - Validation (Zod/Valibot/Pydantic/hand-rolled), error handling (Result types vs exceptions), logging, API clients, state management.
   - If multiple competing patterns exist, note it as **convention drift** and recommend consolidation (don’t introduce a 3rd pattern).

### Step 2: Audit the file

Score each category **A/B/C/D**. Be strict.

#### 1. User Story Fit & Product Coherence
- [ ] The file clearly serves a user-facing or operator-facing outcome
- [ ] Actor, trigger, expected result, and scope boundaries are understandable from code/context
- [ ] Behavior matches the likely product promise, not just a technical proxy
- [ ] Empty, error, loading, denied, expired, and retry states are coherent for the user
- [ ] Copy, status, and side effects do not mislead the user about what really happened
- [ ] If multiple actors/roles exist, each sees behavior consistent with permissions and intent

#### 2. Workflow Integrity & Abuse Resistance
- [ ] The flow cannot be trivially bypassed by skipping UI steps or calling internals directly
- [ ] Duplicate submission, replay, refresh, back-button, stale state, and concurrent action risks are handled
- [ ] Partial failure does not leave the workflow, data, or permissions in an incoherent state
- [ ] State transitions are explicit and reject invalid orderings
- [ ] Trust is not delegated to the UI when server/API enforcement is required
- [ ] Abuse cases are considered for the file's role: unauthorized actor, malformed input, cross-tenant access, webhook spoofing, poisoned content, etc.

#### 3. Architecture & Structure
- [ ] Single responsibility — file does one thing well
- [ ] Under 300 lines (if over, should it be split?)
- [ ] Clear function/component boundaries (each function < 50 lines)
- [ ] No circular imports
- [ ] Proper separation: logic vs presentation vs data access
- [ ] Exports are intentional (not exporting internals)

#### 4. System Fit & Reuse (anti-duplication)
- [ ] Uses existing utilities/modules instead of re-implementing
- [ ] Naming/signatures match existing conventions (don’t create near-duplicates)
- [ ] Follows the project’s established patterns (validation, errors, logging, data access)
- [ ] No “context-free” helpers (generic utils that should live in shared modules)
- [ ] If this introduces a new abstraction, it’s justified (measurable reuse / simplifies call sites)

#### 5. Type Safety
- [ ] No `any` types
- [ ] Function parameters and return types are typed
- [ ] API responses / external data validated at boundary (Zod, Valibot, runtime check)
- [ ] No type assertions (`as`) that bypass safety
- [ ] Enums or const maps instead of magic strings/numbers

#### 6. Error Handling
- [ ] Every async call has error handling
- [ ] Errors are not swallowed (no empty `catch {}`)
- [ ] User-facing errors are helpful and actionable
- [ ] Edge cases handled: null, undefined, empty arrays, network failure
- [ ] No unhandled promise rejections
- [ ] Runtime exceptions are reported to Sentry with safe release/environment context and sanitized tags, contexts, breadcrumbs, logs, and replay settings when the project uses Sentry

#### 7. Performance
- [ ] No unnecessary re-renders (React: stable callbacks, proper deps arrays)
- [ ] No expensive computations on every render (memoize if needed)
- [ ] No N+1 queries or waterfall fetches
- [ ] Large imports are tree-shakeable or lazy-loaded
- [ ] Images/assets properly optimized if referenced

#### 8. Security
- [ ] Authentication is explicit where required; identity is not assumed from the client
- [ ] Authorization is enforced per action/resource, including server-side checks when needed
- [ ] User or external input is validated before use, with bounds and format checks proportionate to risk
- [ ] No `dangerouslySetInnerHTML` / `set:html` with unsafe data
- [ ] No secrets or hardcoded credentials
- [ ] No `eval()`, `new Function()`, or dynamic code execution
- [ ] No open redirects, XSS, injection, IDOR, or cross-tenant access vectors
- [ ] Sensitive data is not leaked through logs, errors, cache, analytics, client state, Sentry contexts, breadcrumbs, replays, uptime checks, source maps, or alert/webhook payloads
- [ ] External integrations, webhooks, uploads, generated content, and async jobs have trust checks
- [ ] Availability / abuse controls exist when relevant: rate limits, quotas, body size limits, retry discipline, idempotency

#### 9. Modern Practices
- [ ] Uses current framework patterns (not deprecated APIs)
- [ ] Hooks over class components (React)
- [ ] Reactive queries over fetch-in-effect (Convex, React Query)
- [ ] Async/await over raw promises or callbacks
- [ ] No commented-out code
- [ ] Naming is clear and consistent

#### 10. Reliability
- [ ] Tests exist for this file (or should they?)
- [ ] Edge cases considered (empty state, max length, concurrent access)
- [ ] Cleanup on unmount (subscriptions, timers, event listeners)
- [ ] Fails gracefully — one error doesn't crash the whole page

### Step 3: Fix

For each issue rated B or worse:
1. Explain the problem with the specific line.
2. Explain the concrete user impact, product incoherence, abuse path, or security risk.
3. Fix it directly in the code (prefer **reuse over invention**: delete duplicates and call the existing helper/module).
4. For architectural choices, propose 2 options and ask.

### Step 4: Report

```
CODE REVIEW: [file name]
─────────────────────────────────────
Business metadata:
  BUSINESS.md    artifact_version=[x|missing] status=[x|missing] updated=[date|missing] confidence=[x|missing]
  BRANDING.md    artifact_version=[x|missing] status=[x|missing] updated=[date|missing] confidence=[x|missing]
  GUIDELINES.md  artifact_version=[x|missing] status=[x|missing] updated=[date|missing] confidence=[x|missing]
User Story Fit     [A/B/C/D] — one-line summary
Workflow Integrity [A/B/C/D] — one-line summary
Architecture       [A/B/C/D] — one-line summary
System Fit & Reuse [A/B/C/D] — one-line summary
Type Safety        [A/B/C/D] — one-line summary
Error Handling     [A/B/C/D] — one-line summary
Performance        [A/B/C/D] — one-line summary
Security           [A/B/C/D] — one-line summary
Modern Practices   [A/B/C/D] — one-line summary
Reliability        [A/B/C/D] — one-line summary
─────────────────────────────────────
OVERALL            [A/B/C/D]

Fixed: X issues | Needs decision: Y

User Story:
- [explicit or inferred story]

Product coherence:
- [main coherence finding]

Adversarial review:
- [main bypass / abuse / bad-state finding]

Security review:
- [main security finding]
```

---

## PROJECT MODE

### Workspace root detection

If the current directory has no project markers (no `package.json`, no `requirements.txt`, no `src/` dir, no `lib.sh`) BUT contains multiple project subdirectories — you are at the **workspace root**, not inside a project.

Use **AskUserQuestion**:
- Question: "You're at the workspace root. Which project(s) should I audit for code quality?"
- `multiSelect: true`
- Options:
  - **All projects** — "Run code audit across every project" (Recommended)
  - One option per project from `${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}/PROJECTS.md`: label = project name, description = stack

Then proceed to **GLOBAL MODE** with the selected projects.

### PHASE 1: SCOPE & USER STORY

Read the project structure, entry points, docs, route map, tests, and 10-15 key files. Establish the product contract before technical scoring.

#### 1.1 User Story & Outcome
- [ ] An explicit user story exists in docs/tasks/specs, or a credible inferred one can be reconstructed from the product
- [ ] Actor, trigger, expected behavior, and value are identifiable
- [ ] The main promise is observable in the product, not only implied in implementation details
- [ ] Scope boundaries are visible: what this product deliberately does not do
- [ ] Critical operator-facing failure signals are named before scoring: errors, slow spans, log patterns, custom metrics, cron jobs, uptime URLs, releases, and mobile build size where relevant

#### 1.2 Product Coherence
- [ ] Main flows feel coherent from UI to backend to data side effects
- [ ] Loading, empty, error, denied, expired, retry, and recovery states make sense to the user
- [ ] Status labels and confirmations reflect actual system state
- [ ] Cross-surface behavior is coherent: route guards, admin tools, jobs, emails, webhooks, exports, mobile vs web if relevant

#### 1.3 Links, Consequences & Trust Boundaries
- [ ] Upstream/downstream systems are identified
- [ ] Data contracts, auth boundaries, tenant boundaries, and external trust assumptions are visible
- [ ] Invariants and side effects are named before scoring

If the user story is unclear but materially changes the audit conclusion, ask a targeted user question before proceeding. Otherwise, state the inferred story and confidence level.

---

### PHASE 2: WORKFLOW INTEGRITY & PRODUCT COHERENCE

Critique the product as an adversary and as a disappointed user.

#### 2.1 Workflow Integrity
- [ ] Important flows cannot be bypassed by direct route/API access, skipping steps, or stale client state
- [ ] Duplicate submissions, retries, refreshes, back/forward nav, and replayed webhooks or jobs are handled
- [ ] Invalid state transitions are rejected
- [ ] Partial failure, timeout, cancellation, and rollback paths are coherent
- [ ] Async jobs and manual actions do not race into inconsistent outcomes
- [ ] Critical async jobs, webhooks, queues, scheduled tasks, and external callbacks have an observable success/failure signal suitable for a Cron Monitor, Metric Monitor, or structured log monitor
- [ ] Alert-worthy failures create or update triageable Sentry issues before notification routing is assumed; Monitors own detection, Alerts own routing

#### 2.2 Abuse & Misuse Cases
- [ ] Unauthorized user, malicious user, cross-tenant user, or low-privilege operator paths were considered
- [ ] External service failure or poisoned input does not silently corrupt the workflow
- [ ] The design does not assume "UI visibility = permission"
- [ ] High-value operations have adequate confirmation, auditability, or idempotency where relevant

#### 2.3 Product Quality Signals
- [ ] The product solves the right problem, not a narrower technical surrogate
- [ ] Feature behavior is consistent with surrounding product patterns
- [ ] Naming, copy, and interaction patterns reduce user confusion instead of adding it

---

### PHASE 3: ARCHITECTURE

Read the project structure, entry points, configs, and 10-15 key files. Audit:

#### 3.1 Project Structure & Organization
- [ ] Clear separation of concerns (pages/routes, components, utils, services, types)
- [ ] No circular dependencies between modules
- [ ] No god files (> 300 lines doing too many things)
- [ ] Barrel exports (`index.ts`) are not re-exporting the entire tree (bundle bloat)
- [ ] Config is centralized
- [ ] Environment variables are typed and validated at startup

#### 3.2 Data Flow & State Management
- [ ] Data flows in one direction (no prop drilling > 3 levels)
- [ ] Server state and client state separated
- [ ] No redundant state (derived values computed, not stored)
- [ ] API/database calls in a service layer, not inside components
- [ ] Real-time subscriptions cleaned up on unmount
- [ ] No stale closures in effects/callbacks

#### 3.3 Error Boundaries & Resilience
- [ ] Error boundaries at route level
- [ ] API calls have proper error handling
- [ ] Network failures show user-friendly messages
- [ ] Retry logic for transient failures
- [ ] Partial failures handled gracefully

#### 3.4 Type Safety
- [ ] `strict: true` in tsconfig
- [ ] No `any` types
- [ ] API responses validated at boundary
- [ ] Shared types between frontend/backend
- [ ] Enums or const maps instead of magic strings

#### 3.5 Consistency & Reuse (anti-duplication / convention drift)
- [ ] Common utilities exist exactly once (no “near-duplicate” helpers across `utils/`, `lib/`, `shared/`)
- [ ] Error handling is standardized (don’t have multiple competing patterns unless clearly scoped)
- [ ] Validation is standardized at boundaries (pick one approach per layer)
- [ ] Logging/telemetry is consistent and monitor-ready: structured logs, spans, metrics, tags, and contexts use stable names, bounded attributes, and shared conventions
- [ ] Sentry monitor/alert configuration in code, IaC, scripts, runbooks, or docs uses the Monitors/Alerts split, not deprecated Metric Alert or Issue Alert API assumptions
- [ ] No parallel state-management paradigms competing in the same app (unless intentionally isolated)
- [ ] New code follows conventions set in the last 3–6 months (avoid regressions to legacy patterns)

#### 3.6 Dependency Health (quick check)

> Deep dependency analysis has moved to `/sf-deps`.

- [ ] Lock file committed

---

### PHASE 4: PERFORMANCE (quick scan)

> Deep performance analysis has moved to `/sf-perf`.

Quick architecture-level checks only:

- [ ] No N+1 query patterns or waterfall fetches
- [ ] No synchronous blocking operations in async code paths
- [ ] Code splitting exists at route level
- [ ] No client-side rendering for content that should be static/SSR

---

### PHASE 5: SECURITY

#### 5.1 Authentication & Authorization
- [ ] Auth tokens stored securely (httpOnly cookies or equivalent)
- [ ] Every API route, action, job trigger, or webhook entry checks authentication when required
- [ ] Authorization checked per resource and per action, not just per screen
- [ ] Session expiration, refresh rotation, revocation, and privilege changes are handled
- [ ] OAuth state parameter / callback integrity validated
- [ ] Tenant, org, project, or account boundaries enforced server-side

#### 5.2 Input Validation & Injection
- [ ] All input validated server-side
- [ ] Parameterized queries (no string concatenation)
- [ ] HTML output escaped (check `dangerouslySetInnerHTML`, `set:html`)
- [ ] File uploads validate type, size, content
- [ ] No `eval()` or `new Function()` with user input
- [ ] Markdown/rendered/generated content is sanitized or constrained
- [ ] URL, redirect, search, filter, sort, and identifier inputs have allowlists or constraints
- [ ] Webhooks and third-party callbacks verify authenticity and expected schema

#### 5.3 Secrets & Configuration
- [ ] No secrets in source code
- [ ] `.env` files in `.gitignore`
- [ ] Secrets via env vars or secret manager
- [ ] No secrets in logs or error messages
- [ ] `.env.example` exists
- [ ] Sensitive config is least-privilege and scoped to the environment

#### 5.4 HTTP Security
- [ ] HTTPS enforced
- [ ] Security headers set (CSP, X-Frame-Options, etc.)
- [ ] CORS restrictive (not `*`)
- [ ] Cookies: `Secure`, `HttpOnly`, `SameSite`
- [ ] Rate limiting on auth endpoints
- [ ] CSRF protection exists where cookie-authenticated mutations need it
- [ ] Download / upload endpoints do not expose broader files or origins than intended

#### 5.5 Data Protection
- [ ] PII not logged or cached publicly
- [ ] User data deletion possible (RGPD)
- [ ] File uploads stored outside web root
- [ ] Sensitive data minimized in analytics, telemetry, caches, and client state
- [ ] Sentry contexts, breadcrumbs, logs, custom metric attributes, replay settings, uptime headers/bodies, and alert/webhook payloads exclude secrets, tokens, auth codes, private URLs, user content, and unnecessary PII
- [ ] Source map, debug symbol, and Sentry auth-token upload config keeps tokens in CI secrets and prevents public `.map` exposure after upload
- [ ] Backups, exports, and support/admin tools do not widen access accidentally

#### 5.6 Availability & Abuse Resistance
- [ ] Rate limiting, quotas, or job concurrency guards exist where abuse cost is meaningful
- [ ] Expensive actions are idempotent or deduplicated where relevant
- [ ] Fan-out, retry storms, infinite loops, or unbounded queue growth are unlikely
- [ ] Public endpoints and automations have protections against spam, brute force, and cost explosion

---

### PHASE 6: RELIABILITY

#### 6.1 Error Handling
- [ ] Errors caught at every async boundary
- [ ] Errors logged with context
- [ ] Sentry captures operationally meaningful exceptions and monitor-created issues with environment, release, dist/build/source-map context, and without sensitive payloads
- [ ] External service failures have fallback
- [ ] Unhandled rejections caught at process level

#### 6.2 Testing
- [ ] Coverage exists for critical paths
- [ ] Tests not brittle
- [ ] E2E tests cover main journey
- [ ] Tests run in CI
- [ ] Edge cases tested

#### 6.3 Observability
- [ ] Structured logging (not just `console.log`)
- [ ] Sentry instrumentation and monitor coverage are configured unless the project documents an explicit static-site exception
- [ ] Sentry release, environment, dist/build id, source maps/debug IDs, issue/event IDs, and monitor/alert source scope are usable for production or preview incidents
- [ ] Monitors and Alerts are treated separately in evidence: Monitors define detection thresholds and issue creation; Alerts define sources, triggers, filters, and actions
- [ ] Metric Monitors for critical flows use appropriate datasets and thresholds across errors, spans, logs, releases, or application metrics, with fixed/change/dynamic thresholds chosen from expected traffic patterns
- [ ] Alerts have explicit owners, source scope, environment scope, trigger/filter rationale, notification frequency, and severity routing
- [ ] Cron and uptime coverage exists for operator-critical scheduled jobs and public or protected health-critical URLs, unless the static-site exception explicitly applies
- [ ] Health check endpoint exists

#### 6.4 Deployment & Recovery
- [ ] Build reproducible
- [ ] Zero-downtime deployment possible
- [ ] Rollback straightforward
- [ ] Database migrations backward-compatible

---

### PHASE 7: MODERN BEST PRACTICES

#### 7.1 Framework-Specific (detect and apply)

**Astro 5**: Content Collections v2, `<Image>`, View Transitions, minimal client JS, `astro:env`.

**Next.js 15+**: App Router, Server Components by default, `next/image` + `next/font`, `loading.tsx` + `error.tsx`, Metadata API.

**React**: Hooks only, Suspense for async, no `useEffect` for data fetching, stable event handlers.

**Convex**: Reactive queries, idempotent mutations, actions for external APIs only, indexes defined, Convex storage API.

**Python**: Type hints, Pydantic, async for I/O, no mutable defaults, virtual env.

#### 7.2 Code Quality
- [ ] Formatter configured (Prettier, Black)
- [ ] Linter configured and passing
- [ ] No commented-out code
- [ ] Functions < 50 lines, single purpose
- [ ] Naming clear and consistent

---

### PHASE 8: FIX

Fix all issues in code. Priority:
1. **CRITICAL USER / SECURITY** — broken user promise, auth bypass, cross-tenant leak, injection, secrets, destructive incoherence
2. **WORKFLOW INTEGRITY** — replay, duplicate action, invalid state transition, missing idempotency, partial failure corruption
3. **PRODUCT COHERENCE** — misleading status, wrong actor flow, missing denied/error/recovery states
4. **ARCHITECTURE** — circular deps, god files, untyped boundaries, convention drift in critical paths
5. **RELIABILITY** — silent error swallowing, missing error boundaries, weak observability on high-risk flows
6. **PERFORMANCE** — critical issues only (N+1, blocking ops); run `/sf-perf` for deep analysis
7. **BEST PRACTICES** — deprecated patterns, legacy APIs

### PHASE 9: REPORT

```
CODE AUDIT: [project name] — [stack detected]
═══════════════════════════════════════════════════

BUSINESS METADATA VERSIONS
  BUSINESS.md    artifact_version=[x|missing] status=[x|missing] updated=[date|missing] confidence=[x|missing] next_review=[date|missing]
  BRANDING.md    artifact_version=[x|missing] status=[x|missing] updated=[date|missing] confidence=[x|missing] next_review=[date|missing]
  GUIDELINES.md  artifact_version=[x|missing] status=[x|missing] updated=[date|missing] confidence=[x|missing] next_review=[date|missing]
  Proof gaps: [missing/stale/unversioned docs that affected scoring, or none]

USER STORY & PRODUCT COHERENCE         [A/B/C/D]
  User Story / Outcome                 [A/B/C/D]
  Product Coherence                    [A/B/C/D]
  Links / Consequences / Trust         [A/B/C/D]

WORKFLOW INTEGRITY                     [A/B/C/D]
  Workflow Integrity                   [A/B/C/D]
  Abuse & Misuse Cases                 [A/B/C/D]
  Product Quality Signals              [A/B/C/D]

ARCHITECTURE                           [A/B/C/D]
  Structure & Organization             [A/B/C/D]
  Data Flow & State                    [A/B/C/D]
  Error Resilience                     [A/B/C/D]
  Type Safety                          [A/B/C/D]
  Consistency & Reuse                  [A/B/C/D]
  Dependency Health (quick)            [A/B/C/D]  → /sf-deps for full audit

PERFORMANCE (quick scan)               [A/B/C/D]  → /sf-perf for full audit

SECURITY                               [A/B/C/D]
  Auth & Authorization                 [A/B/C/D]
  Input Validation                     [A/B/C/D]
  Secrets Management                   [A/B/C/D]
  HTTP Security                        [A/B/C/D]
  Data Protection                      [A/B/C/D]
  Availability & Abuse Resistance      [A/B/C/D]

RELIABILITY                            [A/B/C/D]
  Error Handling                       [A/B/C/D]
  Testing                              [A/B/C/D]
  Observability                        [A/B/C/D]

MODERN PRACTICES                       [A/B/C/D]
  Framework Best Practices             [A/B/C/D]
  Code Quality                         [A/B/C/D]
═══════════════════════════════════════════════════
OVERALL                                [A/B/C/D]

USER STORY
- [explicit or inferred one-line story]
- Story status: [well supported / partially supported / unclear]

PRODUCT COHERENCE
- [main coherence strength or failure]

ADVERSARIAL REVIEW
- [most important bypass / replay / bad-state / trust-boundary finding]

SECURITY REVIEW
- [most important security strength or gap]

CRITICAL fixes applied:     X
HIGH fixes applied:         X
MEDIUM fixes applied:       X
Architectural decisions needed: X (detailed below)

TOP 5 IMPROVEMENTS (by impact):
1. [description + files affected]
2. ...
```

---

## Tracking (all modes)

Shared file write protocol for `AUDIT_LOG.md` and `TASKS.md`:
- Treat the snapshots loaded at skill start as informational only.
- Right before each write, re-read the target file from disk and use that version as authoritative.
- Append or replace only the intended row or subsection; never rewrite the whole file from stale context.
- If the expected anchor moved or changed, re-read once and recompute.
- If it is still ambiguous after the second read, stop and ask the user instead of forcing the write.

After generating the report and applying fixes:

### Log the audit

Append a row to two files:

1. **Global `${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}/AUDIT_LOG.md`**: append `| date | project | scope | — | — | — | — | — | — | [score] | crit/high/med |` (fill only the Code column, `—` for others).
2. **Project-local `./AUDIT_LOG.md`**: same but without the Project column.

Create either file if missing, using the table header from the master `/audit` skill format.

### Update TASKS.md

1. **Local TASKS.md** (project root): add/replace an `### Audit: Code` subsection with critical (🔴), high (🟠), and medium (🟡) issues as task rows.
2. **Master `${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}/TASKS.md`**: find the project's section, add/replace an `### Audit: Code` subsection with the same tasks. Update the Dashboard "Top Priority" if critical issues found.

---

## Important (all modes)

- Be ruthlessly honest. A-level means "I would deploy this to production with confidence today."
- Detect the stack automatically. Only audit relevant sections.
- Security findings are never optional — flag them regardless of focus.
- User-story misfit and product incoherence are first-class findings, not "nice to have" comments.
- Always do one adversarial pass: "How would this flow break, be bypassed, or be abused?"
- Use modern security expectations: authn, authz, trust boundaries, multi-tenant isolation, abuse resistance, and secure failure modes, not only classic XSS/SQLi.
- When a fix touches shared infrastructure, apply once at the source.
- Be extra strict about duplication and “convention drift” (common in AI-assisted codebases): prefer consolidating existing patterns over adding new ones.
- For shell/Bash projects: focus on input validation, quoting, `set -euo pipefail`, ShellCheck.
- Don't refactor working code for aesthetics. Only change code with a concrete issue.
