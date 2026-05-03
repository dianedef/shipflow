---
name: sf-bug
description: "Bug loop orchestrator for intake, dossiers, fixes, retests, verification, and ship risk."
argument-hint: [optional: BUG-ID | bug summary | --fix BUG-ID | --retest BUG-ID | --verify BUG-ID | --ship BUG-ID]
---

## Canonical Paths

Before resolving any ShipFlow-owned file, load `$SHIPFLOW_ROOT/skills/references/canonical-paths.md` (`$SHIPFLOW_ROOT` defaults to `$HOME/shipflow`). ShipFlow tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPFLOW_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Chantier Tracking

Trace category: `conditionnel`.
Process role: `source-de-chantier`.

Before producing the final report, load `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md` when this run is attached to a spec-first chantier. If exactly one active `specs/*.md` chantier is identified, append the current run to `Skill Run History`, update `Current Chantier Flow` when the run changes the chantier state, and include a final `Chantier` block. If no unique chantier is identified, do not write to any spec; report `Chantier: non applicable` or `Chantier: non trace` with the reason.

## Chantier Potential Intake

Because this skill has process role `source-de-chantier`, evaluate the standard threshold from `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md` before the final report. If the bug reveals non-trivial future work and no unique chantier owns it, do not write to an existing spec; add a `Chantier potentiel` block with `oui`, `non`, or `incertain`, a proposed title, reason, severity, scope, evidence, recommended `/sf-spec ...` command, and next step.

## Context

- Current directory: !`pwd`
- Current date: !`date '+%Y-%m-%d'`
- Project name: !`basename $(pwd)`
- Git branch: !`git branch --show-current 2>/dev/null || echo "unknown"`
- Git status: !`git status --short 2>/dev/null || echo "Not a git repo"`
- ShipFlow development mode: !`rg -n "ShipFlow Development Mode|development_mode|validation_surface|ship_before_preview_test|post_ship_verification|deployment_provider" CLAUDE.md SHIPFLOW.md 2>/dev/null || echo "No project development mode documented"`
- Existing bug index: !`tail -80 BUGS.md 2>/dev/null || echo "No BUGS.md"`
- Recent test log: !`tail -60 TEST_LOG.md 2>/dev/null || echo "No TEST_LOG.md"`
- Bug dossiers: !`find bugs -maxdepth 1 -type f -name "BUG-*.md" 2>/dev/null | sort | tail -40 || echo "No bugs directory"`

## Mission

`sf-bug` is the professional bug loop orchestrator.

It routes the lifecycle:

```text
intake -> sf-test -> bug dossier -> sf-fix -> sf-test --retest -> sf-verify -> sf-ship
```

The goal is fewer manual decisions, not weaker gates. `sf-bug` must not treat a bug as closed just because code changed, a retest was requested, a deploy succeeded, or the operator wants to move on.

## Ownership Boundaries

Orchestrate existing skills; do not duplicate their internals.

- `sf-test` owns guided manual QA, failed-test capture, `TEST_LOG.md`, `BUGS.md`, bug dossiers, and retests.
- `sf-fix` owns bug diagnosis, direct/spec-first repair routing, and fix attempts.
- `sf-auth-debug` owns auth, OAuth, sessions, callbacks, cookies, tenants, and protected-route browser diagnosis.
- `sf-browser` owns narrow non-auth browser evidence.
- `sf-verify` owns closure, user-story coherence, and remaining bug-risk verification.
- `sf-ship` owns commit/push and pre-ship bug-risk reporting.
- `sf-bug` owns status interpretation, safety gates, and next-command routing.

Route to a narrower skill when the user clearly asks for only that phase.

## Mode Detection

Parse `$ARGUMENTS`:

- empty -> inspect `BUGS.md` and recent bug dossiers, then recommend the highest-priority next bug command.
- `BUG-YYYY-MM-DD-NNN` -> read the compact index and dossier, interpret status, and route to the next lifecycle step.
- free text -> decide whether this is an observed failure needing `/sf-test [scope]`, a narrow actionable bug needing `/sf-fix [summary]`, or an ambiguous defect needing `/sf-spec [bug title]`.
- `--fix BUG-ID` -> route to `/sf-fix BUG-ID` after confirming the dossier exists.
- `--retest BUG-ID` -> route to `/sf-test --retest BUG-ID`.
- `--verify BUG-ID` -> route to `/sf-verify BUG-ID`.
- `--ship BUG-ID` -> verify bug state first; route to `/sf-ship BUG-ID` only when the bug state does not block clean shipping.
- `--close BUG-ID` -> refuse direct closure unless the dossier contains passing retest evidence or an explicit `closed-without-retest` exception path is chosen.

If arguments include multiple bug IDs, ask which one to handle first unless the user explicitly requests a dashboard summary.

## Step 1 — Load Bug State

When a `BUG-ID` is present:

1. Re-read `BUGS.md` immediately before interpreting status.
2. Open `bugs/BUG-ID.md`.
3. Extract:
   - title, status, severity, next step
   - reproduction, expected behavior, observed behavior
   - evidence and redaction status
   - diagnosis notes
   - fix attempts
   - retest history
   - linked spec, task, commit, or release scope when present
4. If `BUGS.md` and the dossier disagree, prefer the dossier for detailed evidence but report the inconsistency and route to the safest next step.

If `BUGS.md` references a missing dossier:

- keep the index row intact
- classify state as `needs-info`
- route to `/sf-test --retest BUG-ID` or `/sf-fix BUG-ID` only if enough context remains to make that safe
- otherwise ask for recovery context

If a dossier exists without an index row:

- report the index gap
- route to `/sf-test --retest BUG-ID` or `/sf-fix BUG-ID` only after confirming the dossier frontmatter and status are usable

## Step 2 — Interpret Status

Use canonical professional bug states:

- `open`: route to `/sf-fix BUG-ID`, or to evidence gathering when reproduction is weak.
- `needs-info`: ask for the missing environment, observed behavior, expected behavior, or evidence.
- `needs-repro`: route to `/sf-test --retest BUG-ID`, `/sf-browser`, or `/sf-auth-debug` based on the missing proof.
- `in-diagnosis`: route to `/sf-fix BUG-ID` unless another skill is actively running.
- `fix-attempted`: route to `/sf-test --retest BUG-ID`; do not verify or ship as clean yet.
- `fixed-pending-verify`: route to `/sf-verify BUG-ID`.
- `closed`: report no action unless the user is investigating a regression or release notes.
- `closed-without-retest`: report residual risk and route to `/sf-test --retest BUG-ID` if closure confidence matters.
- `duplicate`: route to the canonical bug ID; do not fork work.
- `wontfix`: report the decision and only reopen if the product decision changed.

Severity changes routing:

- `critical` or `high`: do not ship as clean while status is `open`, `needs-info`, `needs-repro`, `in-diagnosis`, or `fix-attempted`.
- `medium` or `low`: shipping may proceed only with explicit partial-risk wording when verification has not closed the loop.

## Step 3 — Choose Evidence Path

Route before fixing when the missing proof matters:

- Auth, OAuth, cookies, sessions, callbacks, tenants, protected routes -> `/sf-auth-debug [BUG-ID or title]`
- Non-auth route, visible state, console, network, screenshot, or page assertion -> `/sf-browser [URL or scope] [objective]`
- Full user flow, human confirmation, durable test record, or retest -> `/sf-test [scope]` or `/sf-test --retest BUG-ID`
- Unclear expected behavior, permission contract, data contract, or product rule -> `/sf-spec [bug title]`

Do not invent reproduction results, browser evidence, screenshots, account roles, console logs, or user confirmations.

## Step 4 — Apply Development Mode Gate

Read `$SHIPFLOW_ROOT/skills/references/project-development-mode.md` and the project-local `## ShipFlow Development Mode` section in `CLAUDE.md` or `SHIPFLOW.md`.

- `local`: local retests and browser checks can be authoritative when the bug is local.
- `vercel-preview-push`: preview/manual/browser/integration retest evidence requires `sf-ship -> sf-prod -> sf-test --preview --retest BUG-ID`.
- `hybrid`: require the preview-push sequence for hosted-only bugs: auth callbacks, OAuth redirect URLs, webhooks, deployment env vars, edge/serverless runtime, Vercel routing, preview/prod data, or bugs that reproduce only remotely.
- missing mode with Vercel signals: classify as `unknown-vercel` and do not claim preview retest authority.

## Step 5 — Ship And Closure Gate

For `--ship BUG-ID`:

1. Read the bug dossier and index.
2. If severity is high/critical and status is not `fixed-pending-verify`, `closed`, `duplicate`, or `wontfix`, block clean shipping.
3. If status is `fixed-pending-verify`, route to `/sf-verify BUG-ID` first.
4. If status is `closed`, `duplicate`, or `wontfix`, route to `/sf-ship BUG-ID` only if the code scope is otherwise bounded.
5. If user explicitly accepts partial-risk shipping, route to `/sf-ship BUG-ID` with a risk note; do not claim bug closure.

For `--close BUG-ID`:

- `closed` requires passing retest evidence in `Retest History` plus verification-compatible state.
- `closed-without-retest` requires visible reason, residual risk, and operator-facing exception text.
- If neither condition is met, route to `/sf-test --retest BUG-ID` or `/sf-verify BUG-ID`.

## Security And Evidence Rules

- Never print or persist raw secrets, tokens, cookies, private keys, raw auth headers, private payloads, production PII, or sensitive screenshots.
- Keep `TEST_LOG.md` and `BUGS.md` compact.
- Keep full detail in `bugs/BUG-ID.md`.
- Store only redacted large evidence under `test-evidence/BUG-ID/`.
- Reject evidence paths that escape the repo with `..`.
- Do not use UI visibility as proof of authorization.

## Stop Conditions

Stop and report `blocked` when:

- the requested `BUG-ID` is malformed
- the dossier is missing or too inconsistent for safe routing
- the user requests closure without retest evidence or a valid exception
- the next action could mutate production or destructive data without explicit approval
- sensitive evidence is unredacted
- a clean ship is requested while high/critical bug state is still unresolved
- the project development mode requires preview evidence that has not gone through `sf-ship -> sf-prod`

## Final Report

```text
## Bug Loop: [BUG-ID or summary]

Mode: [dashboard/intake/fix/retest/verify/ship/close]
Bug state: [status, severity, dossier path]
Classification: [needs capture / needs evidence / needs fix / needs retest / needs verify / shippable / blocked]
Development mode: [local / vercel-preview-push / hybrid / unknown]
Evidence posture: [sufficient / missing / sensitive-blocked / not needed]
Security posture: [ok / risk]
Decision: [route / blocked / no action]

Next step:
- [exact command]

## Chantier potentiel

Chantier potentiel: [oui/non/incertain]
Titre propose: [title or None]
Raison: [short reason]
Severite: [P0/P1/P2/P3/unknown]
Scope: [files/projects/domains/workflows affected]
Evidence:
- [bug state or observation]
Spec recommandee: [/sf-spec ... | None]
Prochaine etape: [command or None]

## Chantier

Skill courante: sf-bug
Chantier: [spec path | non applicable | non trace]
Trace spec: [ecrite | non ecrite | non applicable]
Flux:
- sf-spec: [status]
- sf-ready: [status]
- sf-start: [status]
- sf-verify: [status]
- sf-end: [status]
- sf-ship: [status]

Reste a faire:
- [item or None]

Prochaine etape:
- [command]

Verdict sf-bug:
- [routed | blocked | no action]
```

## Rules

- Orchestrate the bug loop; do not repair code directly inside `sf-bug`.
- Do not write bug dossiers directly except to report routing gaps; use `sf-test` or `sf-fix` for durable bug mutations.
- Do not close bugs from intent, code diff, deployment status, or optimistic wording.
- Do not route preview/manual/browser retests before `sf-ship -> sf-prod` when project mode requires deployed evidence.
- Prefer the safest next command over a broad report when a bug is actionable.
- Ask only when the missing answer changes severity, status, destructive risk, closure, or ship risk.
- Do not commit or push.
