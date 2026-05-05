---
name: sf-build
description: "Master user-facing orchestration from story to spec, verify, close, and ship."
argument-hint: <story, bug, or goal>
---

## Canonical Paths

Before resolving any ShipFlow-owned file, load `$SHIPFLOW_ROOT/skills/references/canonical-paths.md` (`$SHIPFLOW_ROOT` defaults to `$HOME/shipflow`). ShipFlow tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPFLOW_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Chantier Tracking

Trace category: `obligatoire`.
Process role: `lifecycle`.

Before executing, load `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md`. If exactly one chantier spec is in scope, read `Skill Run History` and `Current Chantier Flow`, then append a current `sf-build` row with result `implemented`, `partial`, `blocked`, or `rerouted`, update `Current Chantier Flow`, and end with the compact `Chantier` block from `$SHIPFLOW_ROOT/skills/references/reporting-contract.md`.

If no unique spec exists, do not write to a spec and report `Chantier: non applicable` or `Chantier: non trace` with the reason.

## Report Modes

Before producing the final report, load `$SHIPFLOW_ROOT/skills/references/reporting-contract.md`.

Default to `report=user`: concise, outcome-first, and using the compact chantier block. Use `report=agent` only when explicitly requested or when `sf-build` is preparing an internal handoff for another agent. When invoking downstream skills for internal evidence, pass `report=agent` or `handoff` only when detailed evidence is needed; otherwise keep their default concise output.

## Master Delegation

Before choosing execution topology, load `$SHIPFLOW_ROOT/skills/references/master-delegation-semantics.md`.

This skill follows that reference; local nuances below only narrow or route it. `sf-build` owns end-to-end lifecycle orchestration through `sf-end` and `sf-ship`, and keeps `main-only`, `delegated sequential`, and `spec-gated parallel` as its explicit reportable execution modes.

## Master Workflow Lifecycle

Before resolving lifecycle gates, load `$SHIPFLOW_ROOT/skills/references/master-workflow-lifecycle.md`.

Use the shared skeleton for intake, work item resolution, readiness, model/topology routing, execution through owner skills, validation, verification, and post-verify closure/ship. Local sections below define `sf-build` routes and stop conditions only.

## Context

- Current directory: !`pwd`
- Current date: !`date '+%Y-%m-%d'`
- Project name: !`basename $(pwd)`
- Git branch: !`git branch --show-current 2>/dev/null || echo "unknown"`
- Git status: !`git status --short 2>/dev/null || echo "not a git repo"`
- Master TASKS.md: !`cat ${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}/TASKS.md 2>/dev/null || echo "No master TASKS.md"`
- Local TASKS.md (if exists): !`cat TASKS.md 2>/dev/null || echo "No local TASKS.md"`
- Available specs: !`find specs docs -maxdepth 2 -type f -name "*.md" 2>/dev/null | sort | head -80`

## Mission

`sf-build` is the user-facing lifecycle orchestrator.

It must keep user interaction high level (decisions and status) while executing the full ShipFlow path:

`intake -> existing chantier check -> spec/readiness loop -> governance corpus gate -> model routing gate -> start -> verify -> end -> ship`

The objective is not fewer safeguards. The objective is fewer manual commands and fewer technical detours for the user.

## Execution Modes

### `main-only`

Use only for pure conversational output where no file read/edit/validation/ship is needed, for explicit planning mode without mutation, or when the user explicitly requests no subagent.

### `delegated sequential` (default)

`/sf-build <story>` or `$sf-build <story>` is explicit bounded delegation consent for the current chantier. Use the shared master delegation semantics for subagent defaults, short approvals, mini-contracts, degradation, and reporting.

### `spec-gated parallel`

Allowed only when a ready spec defines safe `Execution Batches` under the shared reference. Without explicit safe batches, parallelism is blocked.

## Existing Chantier Check

Before creating any spec:

1. Search active specs in `specs/*.md`.
2. Compare user story, expected result, linked systems, impacted files/surfaces, and `Current Chantier Flow`.
3. Prefer continuing the matching active spec.
4. Create a new spec only when promise or outcome is genuinely new.
5. If multiple specs are plausible, ask a user decision instead of guessing.

## Question Gate

Before asking a user-facing question, load `$SHIPFLOW_ROOT/skills/references/question-contract.md`.

Ask only when the answer changes behavior, security, data, permissions, money movement, destructive side effects, staging scope, public claims, validation proof, closure, or ship risk.

### Decision Question Framing

When a material question is needed, especially during Plan Mode or before committing to an implementation plan, never ask a bare question. Frame it for a business decision maker, not a technical operator.

Before the actual question, include:

- Problem root: what ambiguity, constraint, or conflict exists and why it appears now.
- Business stakes: what the decision changes for revenue, trust, speed, cost, risk, data/security, positioning, or future optionality.
- Practical options: 2-3 plain-language options with concrete consequences and tradeoffs.
- Honorable recommendation: the best-practice answer, marked as recommended, with the reason and the condition that would make another option better.
- Decision request: one precise question the user can answer without understanding implementation details.

If the best-practice answer is clear, low-risk, reversible, inside the existing contract, compatible with the current technical/product/editorial context, aligned with current best practices, and verifiable in the current run, choose it and continue instead of asking. If the obvious or requested option conflicts with project context, public/editorial claims, architecture, security posture, or current best practices, surface the conflict and ask unless a safe compatible alternative is obvious and inside scope. If the question is still necessary, make the recommended option first and explain why it is the most responsible default. Avoid jargon; translate technical details into business consequences.

Preferred path:

- use integrated prompt tooling (for example `AskUserQuestion`) when available
- otherwise use short plain-text questions with 2-3 prepared options and allow free-form answers
- when integrated prompt tooling has limited room, send the decision framing as a short user-facing paragraph before the prompt, then use concise option labels and descriptions

Questions and status updates must use the active user language.
Internal contracts, section anchors, and stable machine-readable labels stay in English.

## Spec and Readiness Loop

Apply the shared work item and readiness rules from `$SHIPFLOW_ROOT/skills/references/master-workflow-lifecycle.md`.

For non-trivial work:

1. Run or route to `sf-spec`.
2. Run `sf-ready`.
3. If `not ready`, apply one correction pass and rerun readiness.
4. Stop after a bounded loop (default max 3 readiness iterations) with `blocked` or a user decision.
5. Do not run `sf-start` until the spec is `ready`.

For trivial and local work that is safe without a full spec, allow a direct mini-contract and continue in `delegated sequential` mode.

## Fresh Context Handling

When execution is `spec-first`, prefer a fresh execution context for delegated implementation if the runtime allows it. If a fresh context cannot be created and scope risk is material, ask the user to open a new thread before continuing.

## Governance Corpus Gate

Before `sf-start`, check project-local governance state:

- `docs/technical/`
- `docs/technical/code-docs-map.md`
- `CONTENT_MAP.md`
- applicable `docs/editorial/`
- `$SHIPFLOW_ROOT/skills/references/technical-docs-corpus.md`
- `$SHIPFLOW_ROOT/skills/references/editorial-content-corpus.md`

Decision outcomes must be explicit:

- `already existed`
- `created`
- `needs audit`
- `skipped` (with reason)
- `blocked`

If missing or stale, route to `sf-docs` bootstrap/audit or block. Do not continue by relying on chat memory.

## Documentation Update Gate

After each large sequential block or each parallel wave:

1. Run a Technical Reader pass against `docs/technical/code-docs-map.md`.
2. Produce or refresh a `Documentation Update Plan`.
3. Apply impacted technical docs through a write-capable executor or integrator.
4. Block the next wave unless docs are `complete`, `no impact`, or `pending final integration` with reason and resolution condition.

## Editorial Update Gate

When visible behavior, public docs, README promises, FAQ, pricing, support copy, skill pages, content surfaces, or claims are affected:

1. Run an Editorial Reader pass.
2. Produce `Editorial Update Plan` and `Claim Impact Plan` when needed.
3. Apply updates through a write-capable executor or integrator.
4. Block closure/ship unless status is `complete`, `no editorial impact`, or `pending final copy` with reason and resolution condition.

## Model Routing Gate

Apply the shared model/topology routing gate from `$SHIPFLOW_ROOT/skills/references/master-workflow-lifecycle.md`.

Before `sf-start`, load `$SHIPFLOW_ROOT/skills/sf-model/references/model-routing.md` and choose model profile based on complexity, ambiguity, failure cost, expected duration, and topology.

Default:

- simple/local: keep one fast model
- non-trivial/risky: apply `sf-model` guidance and record the choice

## Browser Evidence Routing

Do not treat browser/manual proof as one generic bucket.

- Use `sf-browser` for non-auth browser evidence: route assertions, visual state, console/network, screenshots, interactions.
- Use `sf-auth-debug` for auth/session/callback/cookie/provider/tenant/protected-route issues.
- Use `sf-prod` for hosted deployment/runtime truth, logs, serverless/edge behavior, or live deployment health.
- Use `sf-test` for durable manual QA scripts, retests, and structured test logs.

## Implementation and Verification Orchestration

When the contract is ready:

1. Run `sf-start` to implement.
2. Run `sf-verify` against user story and behavior contract.
3. Route to browser/manual proof skills when required.
4. If verification fails, reroute to correction (direct fix or spec update) before closure.

Do not close or ship half-coded outcomes.

## End and Ship Orchestration

After verification passes:

1. Run `sf-end` for closure and tracker alignment.
2. Run `sf-ship` with bounded staging scope for the current chantier.
3. Never use `all-dirty`/`ship-all` without explicit user request.
4. If proof remains partial, ask explicit risk acceptance before shipping.

Successful post-verify runs must continue through closure and ship. Do not end
the `sf-build` report with `Next step: /sf-end`, `Next step: /sf-ship`,
`Prochaine etape: /sf-end`, or `Prochaine etape: /sf-ship` merely because those
skills are next in the lifecycle. Those are internal lifecycle actions that
`sf-build` owns once verification is good enough.

Only leave `sf-end` or `sf-ship` as a user next step when a named stop condition
prevents orchestration in the current run. The report must state the concrete
blocker, for example ambiguous closure mode, missing risk acceptance, unclear
staging scope, unrelated dirty files that cannot be safely excluded, failed
checks, missing required manual/browser/prod evidence, or a downstream skill
failure.

When closure mode is ambiguous, ask the `sf-end` closure decision question
instead of stopping silently. When shipping intent or staging scope is ambiguous,
ask the `sf-ship` intent/scope question instead of silently handing the user a
manual command. When manual, browser, auth, or hosted proof is required, route to
`sf-browser`, `sf-auth-debug`, `sf-prod`, or `sf-test` and explain what evidence
is still missing. In `vercel-preview-push` or preview-required `hybrid` mode,
ship first, then route immediately to `sf-prod`; do not ask for manual preview
testing before the matching deployment exists.

## Stop Conditions

Stop and ask or reroute when:

- spec ownership is ambiguous
- readiness does not pass
- requested parallelism has no safe `Execution Batches`
- file ownership overlaps in a parallel plan
- governance corpus state is missing/stale and unresolved
- a change would alter existing behavior without explicit decision
- permission/data/security semantics remain ambiguous
- docs freshness is required and unresolved (`fresh-docs gap` or `fresh-docs conflict`)
- verification is insufficient for the promised user outcome
- ship scope includes unrelated dirty files and user did not authorize it

## Internal Role References

Load these role contracts from `$SHIPFLOW_ROOT/skills/references/subagent-roles/` when delegating:

- `technical-reader.md`
- `editorial-reader.md`
- `sequential-executor.md`
- `wave-executor.md`
- `integrator.md`

Do not expose these role files as user-facing commands.

## Final Report

Apply `$SHIPFLOW_ROOT/skills/references/reporting-contract.md`. The default user-facing report is concise; the detailed phase report is reserved for `report=agent`, blocked runs, or explicit handoff.

User-mode report:

```text
## Built: [task]

Result: [implemented / partial / blocked]
[All checks passed ✅ | Checks failed: ... | Checks skipped: ...]
Evidence: [browser/prod/manual route or not needed]
Risk: [only if non-empty]
Next step: [only if real]

## Chantier

[spec path | non applicable: reason | non trace: reason]

Flux: sf-spec [marker] -> sf-ready [marker] -> sf-start [marker] -> sf-verify [marker] -> sf-end [marker] -> sf-ship [marker]
[Reste a faire: only if non-empty]
[Prochaine etape: only if non-empty]
```

Agent-mode report:

```text
## Built: [task]

Mode: [direct/spec-first]
Execution mode: [main-only/delegated sequential/spec-gated parallel]
Contract: [spec path or mini-contract]
Result: [implemented/partial/blocked]

Phases:
- Existing Chantier Check -> [result]
- Spec/Readiness -> [result]
- Governance Corpus Gate -> [result]
- Model Routing Gate -> [result]
- Start/Verify -> [result]
- End/Ship -> [result]

Evidence routing:
- Browser proof: [sf-browser/sf-auth-debug/sf-prod/sf-test/not needed]

Validation:
- [check] -> [pass/fail]

Risks or gaps:
- [item or none]

Next step:
- [real blocker/remediation action only; do not list /sf-end or /sf-ship after successful verification unless orchestration was blocked]

## Chantier

Skill courante: sf-build
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
- [command or none]

Verdict sf-build:
- [implemented | partial | blocked | rerouted]
```

## Rules

- Orchestrate; do not duplicate every atomic skill.
- Keep user interaction concise and decision-oriented.
- Preserve user changes and avoid unrelated refactors.
- Keep technical and editorial coherence gates explicit.
- Follow `$SHIPFLOW_ROOT/skills/references/master-delegation-semantics.md` for delegated sequential defaults, short approval semantics, subagent/parallelism boundaries, and `Execution Batches`.
- Do not commit or push directly from `sf-build`; delegate closure and ship through `sf-end` and `sf-ship`.
- Do not make the user manually run `sf-end` or `sf-ship` after successful verification unless a named stop condition blocks automatic orchestration.
