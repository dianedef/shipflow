---
name: sf-fix
description: "Triage and repair bugs, regressions, and failing behavior."
argument-hint: <bug description, error message, or failing behavior>
---

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
- Master TASKS.md: !`cat ${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}/TASKS.md 2>/dev/null || echo "No master TASKS.md"`
- Local TASKS.md (if exists): !`cat TASKS.md 2>/dev/null || echo "No local TASKS.md"`

## Your task

Use bug language, not session language.

`sf-fix` is the bug-oriented entrypoint that decides whether the issue should:
- be fixed directly now, or
- go through a spec-first path before implementation.

Goal: close small, clear bugs quickly without breaking the user promise, product coherence, or security posture.

### Routing rule

- **Direct fix path** (small/local/clear):
  - single area or small surface
  - expected behavior already obvious from the bug, product context, or existing code
  - low ambiguity on user-visible outcome
  - no migration/auth/data contract change
  - no material risk to permissions, visibility, workflow integrity, or external side effects
- **Spec-first path** (non-trivial/ambiguous):
  - multi-file or cross-system impact
  - unclear expected behavior
  - edge cases likely
  - migration/data/auth/perf implications
  - ambiguity that could materially change behavior, scope, or security

### Step 1 — Capture the bug

If `$ARGUMENTS` is provided, use it.
If empty, ask: "Quel bug veux-tu corriger ?"

Collect only what is needed:
- observed behavior
- expected behavior
- where it happens
- available repro steps or error message

Always reconstruct the bug as a tiny user story before triage:
- actor
- trigger
- broken behavior
- expected outcome / user value

If the user did not state it explicitly, infer a one-line story and confirm it briefly.

Ask targeted clarification prompts only when the missing answer would materially change:
- visible behavior or scope
- affected actor or permission boundary
- destructive side effects, retries, or failure handling
- data exposure, tenant isolation, or security posture

Prefer decision-forcing questions such as:
- "Quand ce cas arrive, on doit bloquer l'action, la rendre invisible, ou afficher une erreur explicite ?"
- "Le bug concerne tous les utilisateurs connectés, seulement les admins, ou seulement le owner ?"
- "En cas d'échec partiel, on retry, on rollback, ou on laisse l'état en erreur visible ?"

### Step 1.5 — BUG-ID and bug file intake (required)

Direct bug fixes still require durable bug memory. `sf-fix` must finish with a bug reference and one Markdown bug file under `bugs/*.md` unless the issue is an explicit minor-exception case.

Minor-exception cases are narrow and must be justified explicitly in the final report:
- typo/copy-only fix with no workflow impact
- purely cosmetic visual defect with no state, permission, data, or interaction consequence
- duplicate of an already-tracked `BUG-ID` with no new diagnosis or fix history to add

When `$ARGUMENTS` includes a `BUG-ID` (`BUG-YYYY-MM-DD-NNN`) or a bug title that matches a bug file or optional `BUGS.md` triage view:
- open `bugs/BUG-ID.md` right before bug intake and treat it as source of truth
- re-read optional `BUGS.md` only as secondary discovery or triage context when present
- locate the optional index row for `BUG-ID` only after the bug file is known

If multiple bugs match a title, prefer the open one with the most recent `last-tested` date and ask the user to confirm when ambiguous.

Reconstruct the bug story from the bug file, not from chat memory:
- Reproduction / Expected / Observed
- Evidence and redaction status
- Diagnosis Notes
- Fix Attempts
- Retest History
- current status and next step

If `bugs/BUG-ID.md` is missing but `BUGS.md` has an entry:
- keep the index row
- report `needs-info`
- do not invent details; ask for recovery context or reroute to `/sf-test --retest BUG-ID`

If no matching `BUG-ID` or bug file exists and the issue is not a justified minor exception:
- create or reserve a new durable bug record before or during the direct fix flow
- before assigning the ID, list `bugs/BUG-YYYY-MM-DD-*.md`, re-read optional `BUGS.md` if present, and choose the next UTC-date suffix greater than every suffix found in either place
- immediately before writing `bugs/BUG-ID.md`, check for a collision; if it exists, re-read both sources once, increment and retry; if the collision repeats, stop and report it instead of overwriting
- write or refresh a compact `BUGS.md` index pointer only when that optional triage view exists or is generated by the project workflow
- create `bugs/BUG-ID.md` from `templates/artifacts/bug_record.md`
- reconstruct the initial bug story from the current report and code context instead of leaving the fix attached only to chat history
- use the same canonical statuses and evidence/redaction rules as `sf-test`

If the issue qualifies for a minor exception:
- do not create a bug file only if the final report says `Bug trace exception: yes`
- include the reason and residual memory tradeoff explicitly
- never use the exception for auth, data, workflow, permission, API, redirect, cache, payment, external effect, or stateful UI bugs

Status handling for active fix work:
- when investigation starts, move status to `in-diagnosis` and append a Diagnosis Notes row
- every concrete code attempt appends a Fix Attempts row in the bug file
- if no passing retest exists, status cannot be `closed`

### Step 2 — Quick technical triage (silent)

Read only the 3-5 most relevant files and classify the bug as `direct` or `spec-first`.

Apply the shared Documentation Freshness Gate from `${SHIPFLOW_ROOT:-$HOME/shipflow}/skills/references/documentation-freshness-gate.md` during triage when the bug may depend on current framework, SDK, service, API, auth/session, build, migration, cache, routing, or integration behavior. Local repo versions and patterns come first; Context7 official docs come next; official web docs are the fallback.

Apply the shared Project Development Mode gate from `${SHIPFLOW_ROOT:-$HOME/shipflow}/skills/references/project-development-mode.md` before deciding how the fix can be retested:
- Read the project-local `## ShipFlow Development Mode` section in `CLAUDE.md` or `SHIPFLOW.md`.
- If the mode is `vercel-preview-push`, quick local checks are allowed, but browser/manual/integration retest evidence requires `sf-ship` -> `sf-prod` first.
- If the mode is `hybrid`, require `sf-ship` -> `sf-prod` for hosted-only bugs: auth callbacks, OAuth redirect URLs, webhooks, deployment env vars, Vercel routing, edge/serverless runtime, preview/prod data, or bugs that reproduce only on a hosted URL.
- If the section is missing and Vercel signals exist, classify the validation mode as `unknown-vercel`, report the documentation gap, and do not claim a preview retest until the mode is clarified.
- If the user confirms the project mode during the fix, update `CLAUDE.md` or `SHIPFLOW.md` with the canonical section from the reference before routing to retest.

If Supabase is detected and the bug touches auth, storage, upload, DB, or RLS behavior, load only the relevant references among `${SHIPFLOW_ROOT:-$HOME/shipflow}/skills/references/supabase-auth.md`, `${SHIPFLOW_ROOT:-$HOME/shipflow}/skills/references/supabase-storage.md`, `${SHIPFLOW_ROOT:-$HOME/shipflow}/skills/references/supabase-db.md` before classifying or patching.

During triage, verify four things before choosing `direct`:
- **User story fit**: the expected fix is clearly tied to the promised user outcome
- **Product coherence**: the intended behavior matches adjacent flows, copy, permissions, and existing conventions
- **Documentation coherence**: the bug fix does not leave docs, FAQ, examples, onboarding, changelog, pricing or support copy describing the old behavior
- **Fresh external docs**: if the fix depends on external documented behavior, current official docs support the chosen path, or the task is rerouted/flagged as `fresh-docs gap` or `fresh-docs conflict`
- **Security impact**: the fix does not rely on UI-only protection or create a gap in auth, authz, validation, or data exposure
- **Blast radius**: linked systems and regressions are still local enough for a direct fix

If the bug touches browser authentication, protected routes, OAuth redirects, Clerk or Supabase session state, callback handling, or "works in code but fails in browser" behavior:
- prefer using `sf-auth-debug` as the diagnostic layer before or during the fix
- use it to locate the exact failure step instead of inferring the auth break only from static code
- keep `sf-fix` as the router and execution owner; `sf-auth-debug` provides evidence, not a separate workflow

If the bug includes a crash, error boundary, 5xx, visible Sentry/support event ID, production exception, or suspected deployed-runtime failure:
- load `${SHIPFLOW_ROOT:-$HOME/shipflow}/skills/references/sentry-observability.md`
- use only supplied or visible Sentry issue/event evidence to identify the failing release, environment, stack frame, and affected surface
- never assume direct Sentry dashboard access; if no Sentry pointer exists and the app is PM2-managed, use bounded local PM2 logs and redacted Doppler presence/scope checks as supporting runtime evidence
- keep Sentry evidence redacted; do not paste raw payloads, breadcrumbs, replay contents, headers, cookies, tokens, private URLs, or PII into bug files or reports
- if no Sentry pointer is available, report the observability gap instead of claiming no runtime error exists

If the bug needs browser reproduction but is not auth-specific, prefer `/sf-browser [URL or route] [objective]` for public UI, visual, console, network, or non-auth navigation evidence before patching. Keep `sf-fix` as the execution owner when a direct fix is still appropriate.

Force `spec-first` if any unresolved point could change:
- who can see/do the action
- what data becomes visible, editable, deletable, or triggerable
- whether the workflow can be bypassed, replayed, or left inconsistent
- whether external systems, billing, notifications, jobs, or automations behave differently

If classification confidence is low (mixed signals), use **AskUserQuestion**:
- Question: "Le scope du bug est borderline. Quelle voie prends-tu ?"
- `multiSelect: false`
- Options:
  - **Corriger directement** — "Tu tentes un fix local immédiat et tu vérifies ensuite"
  - **Passer par spec-first** — "Tu clarifies le contrat avant de coder"
  - **Diagnostic seulement** — "Tu veux un diagnostic + plan sans exécution"

### Step 3 — Choose the path and execute

If `direct`:
- implement the fix directly
- ensure the bug is attached to durable project memory before ending the run:
  - reuse an existing `BUG-ID` when the bug already exists
  - otherwise create `bugs/BUG-ID.md` and optional `BUGS.md` triage pointer unless a justified minor exception applies
- keep scope local to the classified delta
- preserve the user story outcome, not only the failing technical symptom
- preserve product coherence with nearby flows and conventions
- update or flag documentation that describes the fixed behavior when user-facing behavior changes
- preserve security-by-default:
  - do not assume UI visibility is a security control
  - validate untrusted inputs where relevant
  - preserve auth/authz checks and tenant/resource boundaries
  - prevent obvious replay, double-submit, stale-state, or invalid-order issues when relevant
- mark task `in progress` in TASKS tracking
- treat the TASKS snapshots loaded at skill start as informational only
- right before editing any TASKS file, re-read it from disk and use that version as authoritative
- apply a minimal targeted edit to the relevant row only; never rewrite the whole file from stale context
- if the expected row or section moved, re-read once and recompute; if it is still ambiguous, stop and ask the user
- run relevant checks for the changed area
- run at least one user-story sanity check
- if the development mode requires Vercel preview-push validation, do not ask for or record a passing manual/browser retest yet; route next to `/sf-ship [BUG-ID or bug title]`, then `/sf-prod [project or URL]`, then `/sf-test --preview --retest BUG-ID`
- if `sf-fix` is the first skill to persist this bug, create an initial bug file that includes:
  - summary/title/status/severity/next step
  - reproduction / expected / observed
  - diagnosis notes for the current investigation
  - redaction status and evidence pointers if any exist
- append a new `Fix Attempts` row in the bug file with:
  - timestamp UTC
  - files changed
  - hypothesis
  - validation command (or why not run)
  - result (`failed|partial|passed`)
  - Sentry issue/event pointer, `no pointer supplied`, `PM2-Doppler fallback`, or `not applicable`, when runtime evidence is relevant
  - next retest command (`/sf-test --retest BUG-ID`)
- after patching, keep status `fix-attempted` until retest evidence exists
- include the Documentation Freshness Gate verdict when it was triggered, especially the dependency/version and Context7 or official docs source that influenced the fix
- if the bug involves auth, redirects, protected pages, or session behavior in the browser, run or emulate `sf-auth-debug` logic to reproduce and re-check the broken flow
- run a documentation coherence check when the bug changes visible behavior, API behavior, permissions, pricing, integration behavior, or support expectations
- run at least one quick coherence/security sanity check when the bug touches auth, data, workflow, external effects, or non-trivial state
- allow `fixed-pending-verify` only after a passing retest is appended in `Retest History`
- refuse `closed` without retest evidence
- allow `closed-without-retest` only as explicit exception with visible reason and residual risk in the bug file
- run `sf-verify` logic after the retest to confirm closure

If `spec-first`:
- do not code yet
- explicitly route to:
  1. `/sf-spec [bug title]`
  2. `/sf-ready [bug title or spec path]`
  3. `/sf-start [bug title]`

If `diagnostic only`:
- do not code
- if the bug is auth/browser-flow related, prefer `/sf-auth-debug [bug title]`
- if the bug needs non-auth browser evidence, prefer `/sf-browser [URL or route] [objective]`
- otherwise report the suspected root cause and concrete next step command

### Step 4 — Report

Output:

```text
## Bug Intake: [title]

Classification: [direct / spec-first]
Reason: [short rationale]
User story: [actor + expected outcome]
Bug reference: [BUG-ID | minor exception]
Bug file: [bugs/BUG-ID.md | minor exception]
Bug trace exception: [no | yes + reason]
Clarifications asked: [none / short list]
Product coherence: [ok / risk]
Documentation coherence: [ok / risk / not impacted]
Fresh external docs: [checked / not needed / gap / conflict]
Sentry evidence: [supplied pointer correlated / no pointer supplied / PM2-Doppler fallback / not applicable]
Development mode: [local / vercel-preview-push / hybrid / unknown-vercel]
Preview verification gate: [not needed / requires sf-ship -> sf-prod / completed]
Security posture: [ok / risk]
Bug status transition: [in-diagnosis -> fix-attempted -> fixed-pending-verify | other]
Retest evidence: [required / present / missing]
Action taken: [fixed directly / routed]

Next step:
- [exact command to run]

Scope estimate: [small / medium / large]
```

### Rules

- Prefer direct path for truly small and clear bugs
- Prefer spec-first when ambiguity could create rework
- Never hide uncertainty; route early instead
- Keep triage short and actionable
- Ask the user instead of guessing when ambiguity changes product meaning or security posture
- A direct fix must still defend product coherence, not only pass the local repro
- A direct fix must still leave durable bug memory unless a narrow minor exception is explicitly justified
- A direct fix that changes feature behavior must align docs or explicitly report the doc gap
- A direct fix must keep or improve security posture; never weaken controls for speed
- If direct-fix verification fails or reveals broader ambiguity, reroute to spec-first
- If the user chooses `diagnostic only`, do not implement
- Do not close a bug without retest evidence in `bugs/BUG-ID.md` (`Retest History`).
- Do not treat a local retest as closure evidence when the documented project mode requires Vercel preview-push validation.
