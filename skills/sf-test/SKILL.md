---
name: sf-test
description: "Manual QA for feature flows, retests, environments, logs, and bug capture."
argument-hint: [optional: feature, flow, bug id, --retest BUG-ID, --prod, --preview, --local]
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
- Git diff stat: !`git diff --stat 2>/dev/null || echo "no diff"`
- ShipFlow development mode: !`rg -n "ShipFlow Development Mode|development_mode|validation_surface|ship_before_preview_test|post_ship_verification|deployment_provider" CLAUDE.md SHIPFLOW.md 2>/dev/null || echo "No project development mode documented"`
- Recent commits: !`git log --oneline -8 2>/dev/null || echo "no commits"`
- Master TASKS.md: !`cat ${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}/TASKS.md 2>/dev/null | head -80 || echo "No master TASKS.md"`
- Local TASKS.md: !`cat TASKS.md 2>/dev/null | head -80 || echo "No local TASKS.md"`
- Existing test log: !`tail -80 TEST_LOG.md 2>/dev/null || echo "No TEST_LOG.md"`
- Existing bugs: !`tail -80 BUGS.md 2>/dev/null || echo "No BUGS.md"`
- Available specs: !`find docs specs -maxdepth 3 -type f -name "*.md" 2>/dev/null | sort | head -40`
- Existing docs/pages: !`find docs src content app site/src/content -maxdepth 3 -type f \( -name "*.md" -o -name "*.mdx" -o -name "*.astro" -o -name "*.tsx" \) 2>/dev/null | head -60`

## Your Task

Run a guided manual test campaign for the current work, then log the evidence.

This skill exists because technical checks and pre-ship verification can still leave one question unanswered:

```text
Did a real human try the real user flow?
```

`sf-test` must:
- identify the feature or bug flow to test
- generate concrete manual steps the user can follow
- prompt the user with structured result choices
- wait for the user's answer before claiming a result
- write a durable `TEST_LOG.md` entry
- write or update a durable `BUGS.md` entry when the result fails
- route the next step to `sf-fix`, `sf-auth-debug`, `sf-verify`, or `sf-ship`

Do not treat this skill as a generic "run tests" command. It is guided manual QA plus project memory.

For one-off browser proof that does not need a guided manual QA campaign, `TEST_LOG.md`, `BUGS.md`, or a bug dossier, route to `/sf-browser [URL or objective]`. Keep `sf-test` for scenario planning, human confirmation, durable test logs, retests, and bug records.

## Core Rule

Never invent test results.

If you did not observe the behavior yourself with tooling and the user has not reported the result, the status is `not run`.

Before generating a manual test, read `${SHIPFLOW_ROOT:-$HOME/shipflow}/skills/references/project-development-mode.md` and inspect the project-local `## ShipFlow Development Mode` section in `CLAUDE.md` or `SHIPFLOW.md`.

If the project mode is `vercel-preview-push` and the requested test targets changed app behavior:
- Do not generate a preview/manual test while the repo has dirty code changes that have not been shipped.
- Route first to `/sf-ship [scope]`.
- After a successful push, route to `/sf-prod [project or URL]` and wait for the matching Vercel deployment.
- Only then generate the manual test using the deployment URL confirmed by `sf-prod`.

If the project mode is `hybrid`, apply the same gate for hosted-only flows: auth/OAuth, callbacks, webhooks, deployment env vars, Vercel routing, edge/serverless behavior, preview/prod data, or issues that reproduce only remotely.

If the user explicitly requests `--local` in a preview-push project, allow the local test but label it as non-authoritative for deployed behavior and still route to `sf-ship` -> `sf-prod` when preview evidence is required.

The normal flow is:

```text
generate protocol -> ask user to perform it -> collect answer -> log evidence -> route next step
```

If the platform supports an interactive choice tool, use it for the result prompt. If not, ask the user a concise question with numbered or bulleted choices and wait for their reply.

## Mode Detection

Parse `$ARGUMENTS`:

- empty: infer the most likely recent feature from git diff, recent commits, in-progress tasks, and specs
- free text: use it as the feature or flow to test
- `--local`: local environment test
- `--preview`: preview/staging environment test
- `--prod`: production environment test; avoid destructive or irreversible actions unless explicitly approved
- `--retest BUG-ID`: retest a known bug from `BUGS.md`
- a route or URL: use it as the starting surface when relevant
- a spec path: use that spec as the test contract

If the scope is unclear, ask one targeted question:

```text
Quel flow veux-tu tester exactement ?
```

Prefer options inferred from current context:
- recent feature
- in-progress task
- changed route/page/API
- open bug id
- "Tout le travail récent"

## Step 1 — Reconstruct the Test Contract

Build a lightweight contract before writing prompts.

Use, in this order:
- a matching ready spec if available
- the bug record when retesting
- recent git diff and commits
- in-progress task descriptions
- docs or README references only when they clarify expected user behavior

Extract:
- feature or bug name
- user story in one line
- environment: `local`, `preview`, `prod`, or `unknown`
- entry point: route, command, screen, page, or action
- expected success behavior
- expected error behavior
- risky edge case to include
- data, auth, payment, destructive, or external side-effect constraints
- evidence needed to judge pass/fail

If the expected behavior is ambiguous in a way that changes product meaning, permissions, data, money, destructive side effects, or security, stop and ask the user before testing.

## Step 2 — Choose Scenario Types

Generate only scenarios that match the feature.

Common scenario families:

- **Happy path**: the intended user flow succeeds
- **Persistence path**: reload, revisit, saved state, session, or stored data still works
- **Permission path**: protected route, owner/admin/member, logged-out behavior
- **Error path**: invalid input, missing dependency, declined auth, expired session, unavailable backend
- **Regression path**: nearby flow that might have been broken by the change
- **Retest path**: exact reproduction steps from a known bug

For auth, OAuth, callbacks, protected routes, cookies, or session persistence:
- include browser-level steps
- include reload and direct protected-route checks when relevant
- if the test fails, route to `sf-auth-debug` unless the bug is obviously unrelated to auth configuration or browser state

For production:
- keep steps read-only or reversible by default
- explicitly mark any step that creates data, sends email, triggers billing, deletes data, publishes content, or calls external services
- ask for confirmation before destructive or costly test steps

## Step 3 — Prompt the User

Give the user a compact test card.

Format:

```text
Manual test: [feature/flow]
Environment: [local/preview/prod/unknown]
Goal: [one-line expected user outcome]

Steps:
1. ...
2. ...
3. ...

Report the result:
- PASS: [success condition]
- FAIL_ERROR: [error page/message]
- FAIL_LOADING: infinite loading or blocked pending state
- FAIL_REDIRECT: wrong route, loop, or sent back to login
- FAIL_DATA: missing, stale, duplicated, or wrong data
- FAIL_PERMISSION: user can/cannot access something incorrectly
- FAIL_UI: visible UI break, inaccessible control, or confusing state
- BLOCKED: could not run the test
- OTHER: describe what happened
```

Ask for only the evidence needed:
- final URL or screen
- visible error message
- whether data/session persisted after reload
- account/role used, when relevant
- screenshot path or copied console/network error, if the user has it

Do not overwhelm the user with every possible edge case in one prompt. For a broad feature, run 2-4 scenarios sequentially.

## Step 4 — Interpret the Reply

Normalize the user's answer into:

- `pass`
- `fail`
- `blocked`
- `not run`

Also capture:
- category: `error`, `loading`, `redirect`, `data`, `permission`, `ui`, `unknown`
- observed behavior
- expected behavior
- reproduction steps actually executed
- environment
- evidence supplied
- confidence: `high`, `medium`, or `low`
- whether a bug should be opened

If the reply is vague, ask one follow-up question before logging a failure:

```text
Tu étais sur quelle URL ou quel écran au moment du blocage, et qu'est-ce qui était visible ?
```

Do not ask more than needed to make the bug actionable.

## Step 5 — Write Compact TEST_LOG.md

Right before editing `TEST_LOG.md`, re-read it from disk if it exists.

If it does not exist, create it.

Append a compact entry only. Do not rewrite old entries.

Use this compact format:

```markdown
## YYYY-MM-DD - [Feature or Flow]

- Scope: [feature|spec|BUG-ID]
- Environment: [local|preview|prod|unknown]
- Tester: user
- Source: sf-test
- Status: [pass|fail|blocked|not run]
- Confidence: [high|medium|low]
- Result summary: [one short line]
- Bug pointer: [none | BUG-ID -> bugs/BUG-ID.md]
- Evidence pointer: [none | test-evidence/BUG-ID/... | external reference]
- Follow-up: [none | /sf-fix BUG-ID | /sf-test --retest BUG-ID | next command]
```

Rules:
- `TEST_LOG.md` stays compact. It is a tracker, not a full bug dossier.
- Do not mark `pass` unless the user or tooling confirmed the success condition.
- Use `blocked` when the user could not run the scenario.
- Use `not run` only when recording a planned campaign that was not executed.
- Do not paste long logs in `TEST_LOG.md`; keep only pointers.

## Step 6 — Professional Bug Model (Compact Index + Bug Dossier)

When a scenario fails (or `--retest BUG-ID` is used), follow the three-layer model:
- `TEST_LOG.md`: compact scenario history and pointers
- `BUGS.md`: compact bug index
- `bugs/BUG-ID.md`: detailed bug dossier (`artifact: bug_record`)

Optional heavy evidence location:
- `test-evidence/BUG-ID/` only for redacted evidence that is too large for markdown

Canonical statuses:
- `open`
- `needs-info`
- `needs-repro`
- `in-diagnosis`
- `fix-attempted`
- `fixed-pending-verify`
- `closed`
- `closed-without-retest`
- `duplicate`
- `wontfix`

`sf-test` status rules:
- may set or keep: `open`, `needs-info`, `needs-repro`, `fixed-pending-verify`
- must never mark `closed` directly
- may use `closed-without-retest` only with explicit operator-visible reason and residual risk

Allowed transition policy for `sf-test`:
- `open` -> `needs-info` or `needs-repro` when reproduction/evidence is incomplete
- `open` or `fix-attempted` -> `fixed-pending-verify` only after a passing retest
- `fixed-pending-verify` -> `open` when a retest fails again
- no other transition is allowed transition unless explicitly justified in the dossier

Evidence and redaction policy:
- Never store raw secrets or private data in trackers or bug dossier.
- Always redact before persistence: tokens, cookies, raw headers, private payloads, private emails, personal data, HAR dumps, or sensitive screenshots.
- Use `test-evidence/BUG-ID/` for redacted large artifacts; keep only compact pointers in markdown.
- Reject relative paths escaping repo root (`..`) for stored evidence pointers.

## Step 7 — Write or Update BUGS.md + bugs/BUG-ID.md

If the normalized result is `fail`, or when running `--retest BUG-ID`, update `BUGS.md` and `bugs/BUG-ID.md`.

### 7.1 Compact BUGS.md index rules

Right before editing `BUGS.md`, re-read it from disk.

`BUGS.md` must stay compact. Each entry is a pointer, not a full narrative.

Recommended index line format:

```markdown
- BUG-YYYY-MM-DD-001 | open | high | [short title] | last-tested: YYYY-MM-DD | dossier: bugs/BUG-YYYY-MM-DD-001.md
```

Preserve legacy `BUGS.md` content. New entries follow the compact pointer model.

### 7.2 BUG-ID generation and collision handling

New ID format:

```text
BUG-YYYY-MM-DD-NNN
```

Before assigning an ID:
1. Re-read `BUGS.md` and collect same-day suffixes from lines containing `BUG-YYYY-MM-DD-*`.
2. List files `bugs/BUG-YYYY-MM-DD-*.md` and collect suffixes.
3. Pick `NNN` greater than every suffix found in either place.

Immediately before writing dossier file:
1. Check whether `bugs/BUG-ID.md` already exists.
2. If it exists, re-read both `BUGS.md` and `bugs/` once, increment suffix, and retry.
3. If collision repeats after retry, stop and report collision; do not overwrite.

### 7.3 Duplicate detection

Before creating a new bug dossier, search for an open bug with clearly matching reproduction + observed behavior.
- If clearly same bug: update existing `BUG-ID` and cross-link.
- If similar but not provably identical: create a new `BUG-ID` and add `Related bugs` links.

### 7.4 bug dossier update rules (`bugs/BUG-ID.md`)

For a new bug, create `bugs/BUG-ID.md` from `templates/artifacts/bug_record.md`.

For existing bug, append only; never erase history.

Required sections to keep current:
- Summary (title, status, severity, next step)
- Reproduction / Expected / Observed
- Evidence (redacted pointers)
- Diagnosis Notes
- Fix Attempts
- Retest History
- Redaction Status

### 7.5 `--retest BUG-ID` behavior

`--retest BUG-ID` is dossier-first:
1. Read `BUGS.md` and `bugs/BUG-ID.md`.
2. Re-run reproduction steps from the bug dossier.
3. Append one line to dossier `Retest History`.
4. Update dossier status with allowed transitions:
   - pass -> `fixed-pending-verify`
   - fail -> `open` (or `needs-repro` when reproduction became unreliable)
5. Write only compact pointers in `TEST_LOG.md` and `BUGS.md`; do not duplicate full context.

### 7.6 Severity defaults

- `critical`: data loss, payment, security, destructive action, privacy leak, total production outage
- `high`: login blocked, core workflow blocked, protected route broken, paid/core feature unusable
- `medium`: important workflow degraded with workaround
- `low`: cosmetic, copy, minor UI issue, non-blocking edge case

## Step 8 — Route Next Step

After logging:

- if all required scenarios pass: recommend `/sf-verify [scope]` if not already done, otherwise `/sf-ship`
- if preview-push deployment is required before a valid test: recommend `/sf-ship [scope]` first, then `/sf-prod [project or URL]`, then rerun `/sf-test --preview [scope]`
- if a bug was opened: recommend `/sf-fix [bug title]`
- if auth/browser evidence is needed: recommend `/sf-auth-debug [bug title]`
- if non-auth one-off browser evidence is needed without a durable manual test log: recommend `/sf-browser [URL or scope] [objective]`
- if the test was blocked by unclear expected behavior: recommend `/sf-spec [scope]` or `/sf-ready [scope]`
- if the test was blocked by environment/deploy: recommend `/sf-prod` or the project-specific deployment check

## Output Format

When first prompting the user, output only:

```text
## Manual Test: [feature]

Environment: [environment]
Goal: [goal]

Steps:
1. ...

Report the result:
- PASS: ...
- FAIL_ERROR: ...
- FAIL_LOADING: ...
- FAIL_REDIRECT: ...
- FAIL_DATA: ...
- FAIL_PERMISSION: ...
- FAIL_UI: ...
- BLOCKED: ...
- OTHER: ...
```

After the user replies and logs are written, output:

```text
## Test Logged: [feature]

Result: [pass|fail|blocked|not run]
Scenario: [name]
Evidence: [short summary]

Files updated:
- TEST_LOG.md (compact)
- BUGS.md (compact index) [if applicable]
- bugs/BUG-ID.md (bug dossier) [if applicable]
- test-evidence/BUG-ID/... [optional, redacted only]

Next step:
- [exact command]
```

## Rules

- Prompt the user; do not silently skip the human test loop.
- Do not log a result before the user answers, unless browser/tool evidence was directly collected in this run.
- Do not invent URLs, accounts, screenshots, logs, or errors.
- Keep test steps concrete and executable.
- Prefer one focused scenario at a time over a huge QA checklist.
- Record operational evidence in `TEST_LOG.md`, keep `BUGS.md` as a compact index, and keep full bug context in each bug dossier.
- Do not put YAML frontmatter in `TEST_LOG.md` or `BUGS.md`.
- Keep bug dossier entries actionable enough for `sf-fix`.
- Redact sensitive evidence before writing; do not store raw secrets.
- Preserve existing log and bug history.
- Do not commit or push.
