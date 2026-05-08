---
name: sf-bug
description: "Bug loop orchestrator for intake, bug files, fixes, retests, verification, and ship risk."
argument-hint: [optional: BUG-ID | bug summary | --fix BUG-ID | --retest BUG-ID | --verify BUG-ID | --ship BUG-ID]
---

## Canonical Paths

Before resolving any ShipFlow-owned file, load `$SHIPFLOW_ROOT/skills/references/canonical-paths.md` (`$SHIPFLOW_ROOT` defaults to `$HOME/shipflow`). ShipFlow tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPFLOW_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Chantier Tracking

Trace category: `conditionnel`.
Process role: `source-de-chantier`.

Before producing the final report, load `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md` when this run is attached to a spec-first chantier. If exactly one active `specs/*.md` chantier is identified, append the current run to `Skill Run History`, update `Current Chantier Flow` when the run changes the chantier state, and include a final `Chantier` block. If no unique chantier is identified, do not write to any spec; report `Chantier: non applicable` or `Chantier: non trace` with the reason.

## Report Modes

Before producing the final report, load `$SHIPFLOW_ROOT/skills/references/reporting-contract.md`.

Default to `report=user`: concise, lifecycle-first, and using the compact chantier block. The detailed report template below is for `report=agent`, blocked runs, or explicit handoff.

## Master Delegation

Before choosing execution topology, load `$SHIPFLOW_ROOT/skills/references/master-delegation-semantics.md`.

This skill follows that reference; local nuances below only narrow it. Bug-loop orchestration defaults to delegated sequential for bug-file/state checks, evidence gathering, fix attempts, retests, verification, closure preparation, and ship preparation when subagents are available. Parallel bug work requires ready `Execution Batches`.

## Master Workflow Lifecycle

Before resolving bug lifecycle state, load `$SHIPFLOW_ROOT/skills/references/master-workflow-lifecycle.md`.

Use the shared bug work item model: one Markdown bug file under `bugs/*.md` is the source of truth for one bug work item. `BUGS.md`, when present, is only an optional compact/generated/triage view and must not override the bug file.

## Chantier Potential Intake

Because this skill has process role `source-de-chantier`, evaluate the standard threshold from `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md` before the final report. If the bug reveals non-trivial future work and no unique chantier owns it, do not write to an existing spec; add a `Chantier potentiel` block with `oui`, `non`, or `incertain`, a proposed title, reason, severity, scope, evidence, recommended `/sf-spec ...` command, and next step.

## Context

- Current directory: !`pwd`
- Current date: !`date '+%Y-%m-%d'`
- Project name: !`basename $(pwd)`
- Git branch: !`git branch --show-current 2>/dev/null || echo "unknown"`
- Git status: !`git status --short 2>/dev/null || echo "Not a git repo"`
- ShipFlow development mode: !`rg -n "ShipFlow Development Mode|development_mode|validation_surface|ship_before_preview_test|post_ship_verification|deployment_provider" CLAUDE.md SHIPFLOW.md 2>/dev/null || echo "No project development mode documented"`
- Bug files: !`find bugs -maxdepth 1 -type f -name "BUG-*.md" 2>/dev/null | sort | tail -40 || echo "No bugs directory"`
- Optional bug triage view: !`tail -80 BUGS.md 2>/dev/null || echo "No BUGS.md"`
- Recent test log: !`tail -60 TEST_LOG.md 2>/dev/null || echo "No TEST_LOG.md"`

## Mission

`sf-bug` is the professional bug loop lifecycle executor.

It orchestrates the lifecycle through owner skills and bounded subagents:

```text
intake -> sf-test -> bug file -> sf-fix -> sf-test --retest -> sf-verify -> sf-ship
```

The goal is fewer manual decisions and fewer manual commands, not weaker gates. When scope, evidence, and risk are clear, `sf-bug` should keep executing the lifecycle in delegated sequential mode instead of ending with a command for the operator to run next.

`sf-bug` must not treat a bug as closed just because code changed, a retest was requested, a deploy succeeded, or the operator wants to move on.

## Ownership Boundaries

Orchestrate existing skills; do not duplicate their internals.

- `sf-test` owns guided manual QA, failed-test capture, `TEST_LOG.md`, bug files under `bugs/*.md`, optional `BUGS.md` triage updates, and retests.
- `sf-fix` owns bug diagnosis, direct/spec-first repair routing, and fix attempts.
- `sf-auth-debug` owns auth, OAuth, sessions, callbacks, cookies, tenants, and protected-route browser diagnosis.
- `sf-browser` owns narrow non-auth browser evidence.
- `sf-verify` owns closure, user-story coherence, and remaining bug-risk verification.
- `sf-ship` owns commit/push and pre-ship bug-risk reporting.
- `sf-bug` owns status interpretation, safety gates, execution topology, lifecycle continuation, owner-skill routing, integration of downstream evidence, and final bug-loop reporting.

Delegate or route to a narrower skill when that skill owns the phase. Stop with a next command only when a stop condition, missing approval, unavailable subagent, unavailable proof surface, or explicit user request prevents continuing in the current run.

## Mode Detection

Parse `$ARGUMENTS`:

- empty -> inspect `bugs/*.md` and optional `BUGS.md`, then continue or recommend the highest-priority safe bug action.
- `BUG-YYYY-MM-DD-NNN` -> read the bug file first, use the optional compact index only as secondary context, interpret status, and continue through the next lifecycle step when safe.
- free text -> decide whether this is an observed failure needing `sf-test`, a narrow actionable bug needing `sf-fix`, or an ambiguous defect needing `sf-spec`; continue through that owner when safe.
- `--fix BUG-ID` -> delegate to `sf-fix BUG-ID` after confirming the bug file exists.
- `--retest BUG-ID` -> delegate to `sf-test --retest BUG-ID`.
- `--verify BUG-ID` -> delegate to `sf-verify BUG-ID`.
- `--ship BUG-ID` -> verify bug state first; delegate to `sf-ship BUG-ID` only when the bug state does not block clean shipping.
- `--close BUG-ID` -> refuse direct closure unless the bug file contains passing retest evidence or an explicit `closed-without-retest` exception path is chosen.

If arguments include multiple bug IDs, ask which one to handle first unless the user explicitly requests a dashboard summary.

## Step 1 — Load Bug State

When a `BUG-ID` is present:

1. Open `bugs/BUG-ID.md` immediately before interpreting status.
2. Re-read optional `BUGS.md` only if present, as secondary triage context.
3. Extract:
   - title, status, severity, next step
   - reproduction, expected behavior, observed behavior
   - evidence and redaction status
   - diagnosis notes
   - fix attempts
   - retest history
   - linked spec, task, commit, or release scope when present
4. If `BUGS.md` and the bug file disagree, prefer the bug file for detailed evidence but report the inconsistency and route to the safest next step.

If optional `BUGS.md` references a missing bug file:

- keep or report the index row without treating it as durable proof
- classify state as `needs-info`
- continue through `sf-test --retest BUG-ID` or `sf-fix BUG-ID` only if enough context remains to make that safe
- otherwise ask for recovery context

If a bug file exists without an index row:

- report the optional index gap
- continue through `sf-test --retest BUG-ID` or `sf-fix BUG-ID` after confirming the bug file frontmatter and status are usable

## Step 2 — Interpret Status

Use canonical professional bug states:

- `open`: continue through `sf-fix BUG-ID`, or through evidence gathering when reproduction is weak.
- `needs-info`: ask for the missing environment, observed behavior, expected behavior, or evidence.
- `needs-repro`: continue through `sf-test --retest BUG-ID`, `sf-browser`, or `sf-auth-debug` based on the missing proof.
- `in-diagnosis`: continue through `sf-fix BUG-ID` unless another skill is actively running.
- `fix-attempted`: continue through `sf-test --retest BUG-ID`; do not verify or ship as clean yet.
- `fixed-pending-verify`: continue through `sf-verify BUG-ID`.
- `closed`: report no action unless the user is investigating a regression or release notes.
- `closed-without-retest`: report residual risk and continue through `sf-test --retest BUG-ID` if closure confidence matters.
- `duplicate`: route to the canonical bug ID; do not fork work.
- `wontfix`: report the decision and only reopen if the product decision changed.

Severity changes routing:

- `critical` or `high`: do not ship as clean while status is `open`, `needs-info`, `needs-repro`, `in-diagnosis`, or `fix-attempted`.
- `medium` or `low`: shipping may proceed only with explicit partial-risk wording when verification has not closed the loop.

## Step 3 — Choose Evidence Path

Run the evidence owner before fixing when the missing proof matters:

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

1. Read the bug file and optional index.
2. If severity is high/critical and status is not `fixed-pending-verify`, `closed`, `duplicate`, or `wontfix`, block clean shipping.
3. If status is `fixed-pending-verify`, continue through `sf-verify BUG-ID` first.
4. If status is `closed`, `duplicate`, or `wontfix`, continue through `sf-ship BUG-ID` only if the code scope is otherwise bounded.
5. If user explicitly accepts partial-risk shipping, continue through `sf-ship BUG-ID` with a risk note; do not claim bug closure.

For `--close BUG-ID`:

- `closed` requires passing retest evidence in `Retest History` plus verification-compatible state.
- `closed-without-retest` requires visible reason, residual risk, and operator-facing exception text.
- If neither condition is met, continue through `sf-test --retest BUG-ID` or `sf-verify BUG-ID` when safe.

## Security And Evidence Rules

- Never print or persist raw secrets, tokens, cookies, private keys, raw auth headers, private payloads, production PII, or sensitive screenshots.
- Keep `TEST_LOG.md` and optional `BUGS.md` compact.
- Keep full detail in `bugs/BUG-ID.md`.
- Store only redacted large evidence under `test-evidence/BUG-ID/`.
- Reject evidence paths that escape the repo with `..`.
- Do not use UI visibility as proof of authorization.

## Stop Conditions

Stop and report `blocked` when:

- the requested `BUG-ID` is malformed
- the bug file is missing or too inconsistent for safe routing
- the user requests closure without retest evidence or a valid exception
- the next action could mutate production or destructive data without explicit approval
- sensitive evidence is unredacted
- a clean ship is requested while high/critical bug state is still unresolved
- the project development mode requires preview evidence that has not gone through `sf-ship -> sf-prod`

## Final Report

```text
## Bug Loop: [BUG-ID or summary]

Mode: [dashboard/intake/fix/retest/verify/ship/close]
Bug state: [status, severity, bug file path]
Classification: [needs capture / needs evidence / needs fix / needs retest / needs verify / shippable / blocked]
Execution mode: [main-only / delegated sequential / spec-gated parallel]
Development mode: [local / vercel-preview-push / hybrid / unknown]
Evidence posture: [sufficient / missing / sensitive-blocked / not needed]
Security posture: [ok / risk]
Decision: [executed / routed / blocked / no action]

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
- [executed | routed | blocked | no action]
```

## Rules

- Execute the bug loop through owner skills and bounded subagents; do not repair code directly inside the `sf-bug` master thread.
- Do not write bug files directly except to report routing gaps; use `sf-test` or `sf-fix` for durable bug mutations.
- Do not close bugs from intent, code diff, deployment status, or optimistic wording.
- Do not route preview/manual/browser retests before `sf-ship -> sf-prod` when project mode requires deployed evidence.
- Follow the shared master delegation reference for delegated sequential defaults and spec/batch-gated parallelism.
- Prefer continuing the next safe lifecycle action over ending with a broad report when a bug is actionable and no stop condition blocks execution.
- Ask only when the missing answer changes severity, status, destructive risk, closure, or ship risk.
- Do not commit or push.
