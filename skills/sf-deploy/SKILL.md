---
name: sf-deploy
description: "Release orchestrator for checks, ship, deploy, proof, verify, and changelog."
argument-hint: [optional: project, URL, --preview, --prod, skip-check, no-changelog]
---

## Canonical Paths

Before resolving any ShipFlow-owned file, load `$SHIPFLOW_ROOT/skills/references/canonical-paths.md` (`$SHIPFLOW_ROOT` defaults to `$HOME/shipflow`). ShipFlow tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPFLOW_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Chantier Tracking

Trace category: `obligatoire`.
Process role: `lifecycle`.

Before deploying a spec-first chantier, load `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md`, then read the spec's `Skill Run History` and `Current Chantier Flow` when a unique spec exists. Append a current `sf-deploy` row with result `deployed`, `partial`, `blocked`, or `rerouted`, update `Current Chantier Flow`, and end the report with a `Chantier` block plus `Verdict sf-deploy: ...`.

If no unique chantier spec is identified, do not write to a spec; report `Chantier: non applicable` or `Chantier: non trace` with the reason.

## Context

- Current directory: !`pwd`
- Current date: !`date '+%Y-%m-%d'`
- Project name: !`basename $(pwd)`
- Git branch: !`git branch --show-current 2>/dev/null || echo "unknown"`
- Git status: !`git status --short 2>/dev/null || echo "Not a git repo"`
- Git diff stat: !`git diff HEAD --stat 2>/dev/null || echo ""`
- Latest commit: !`git log --oneline -1 2>/dev/null || echo "no commits"`
- ShipFlow development mode: !`rg -n "ShipFlow Development Mode|development_mode|validation_surface|ship_before_preview_test|post_ship_verification|deployment_provider" CLAUDE.md SHIPFLOW.md 2>/dev/null || echo "No project development mode documented"`
- Existing bugs: !`tail -80 BUGS.md 2>/dev/null || echo "No BUGS.md"`
- Available specs: !`find specs docs -maxdepth 2 -type f -name "*.md" 2>/dev/null | sort | head -80`

## Mission

`sf-deploy` is the release confidence orchestrator.

It runs the release path:

```text
scope -> sf-check -> sf-ship -> sf-prod -> sf-browser/sf-auth-debug/sf-test -> sf-verify -> sf-changelog
```

The goal is fewer manual commands, not fewer gates. `sf-deploy` must not treat a passing check, pushed commit, deployment status, or `200 OK` as proof that the release works.

## Ownership Boundaries

Orchestrate existing skills; do not duplicate their internals.

- `sf-check` owns typecheck, lint, build, tests, and optional repair.
- `sf-ship` owns staging, commit, push, and pre-ship bug risk.
- `sf-prod` owns deployment discovery, provider state, build logs, runtime logs, and live health.
- `sf-browser` owns non-auth page-level browser proof after the deployment URL is known.
- `sf-auth-debug` owns login, OAuth, cookies, sessions, callbacks, tenants, and protected-route proof.
- `sf-test` owns guided manual QA, durable `TEST_LOG.md`, `BUGS.md`, and bug dossiers.
- `sf-verify` owns final user-story and coherence verification.
- `sf-changelog` owns release-note generation.

Route to a narrower skill instead of continuing when the user clearly asks for only that phase.

## Mode Detection

Parse `$ARGUMENTS`:

- empty -> deploy the current project and current bounded release scope.
- `skip-check` -> skip `sf-check` only; keep ship, prod, proof, and verify gates explicit.
- `no-changelog` -> skip the optional changelog route.
- `--preview` -> prefer preview/staging deploy proof.
- `--prod` -> prefer production deploy proof and keep destructive/manual test steps read-only unless approved.
- URL -> use it as the deploy or browser-proof target after checking whether `sf-prod` still needs to confirm deployment truth.
- project name -> pass it to `sf-prod` and any downstream proof skill.

If the user only wants:

- a commit/push -> route to `/sf-ship`.
- deployed state/logs -> route to `/sf-prod`.
- one page assertion -> route to `/sf-browser`.
- auth flow diagnosis -> route to `/sf-auth-debug`.
- a durable manual QA campaign -> route to `/sf-test`.

## Phase 1 — Scope And Risk Gate

Identify:

- release scope and changed files
- target environment: `local`, `preview`, `production`, or `unknown`
- project development mode from `$SHIPFLOW_ROOT/skills/references/project-development-mode.md` plus `CLAUDE.md` or `SHIPFLOW.md`
- whether the release touches auth, data, permissions, payments, webhooks, background jobs, migrations, public pages, docs, or external side effects
- linked open high or critical bugs from `BUGS.md`

Ask one targeted question only when the answer changes staging scope, target environment, skip-check risk, destructive side effects, or release framing.

Stop before shipping when:

- dirty files are unrelated or ambiguous
- high or critical linked bugs are still open and not explicitly accepted as release risk
- the project mode requires hosted validation but the deployment target is unknown
- the requested action would mutate production data without explicit approval

## Phase 2 — Pre-Ship Checks

Unless `skip-check` is present, run or route through:

```text
/sf-check nofix
```

Use `nofix` by default because deploy orchestration should not silently widen into an implementation pass. If checks fail, stop and report the failed command plus the repair route:

```text
/sf-check fix
```

If `skip-check` is present, continue only with a visible risk note. Skipping checks never means the release is safe.

## Phase 3 — Ship

Run or route through:

```text
/sf-ship [bounded release scope]
```

Do not stage or commit files directly inside `sf-deploy`. If `sf-ship` blocks on checks, secrets, bug risk, unrelated dirty files, or push failure, stop at that gate.

After a successful push, record:

- commit SHA
- branch
- ship mode
- whether hosted validation is required by project development mode

## Phase 4 — Deployment Truth

Run or route through:

```text
/sf-prod [project or URL]
```

For Vercel projects, `sf-prod` should use Vercel MCP as the primary deployment truth source when available. Do not continue to browser or manual proof until the matching deployment URL is known and ready, unless the report explicitly marks deployment proof as partial.

If `sf-prod` finds a failed build, runtime error, pending deployment timeout, missing URL, or logs that require repair, stop and route to the appropriate repair path:

- `/sf-check fix` for local build/check failures
- `/sf-fix [deploy/runtime issue]` for narrow defects
- `/sf-spec [release incident]` for risky or cross-system incidents

## Phase 5 — Post-Deploy Evidence Routing

Choose proof based on the release scope:

- Auth, OAuth, cookies, sessions, callbacks, tenants, protected routes -> `/sf-auth-debug [target]`
- Non-auth route, visual state, screenshot, console, network, or page assertion -> `/sf-browser [URL] [objective]`
- Full user flow, human confirmation, retest, or durable QA record -> `/sf-test --preview|--prod [scope]`
- No browser/manual proof needed -> state why and continue to `sf-verify`

Do not invent proof. If the evidence is not collected, report it as missing and keep the release verdict partial or blocked.

## Phase 6 — Verify

Run or route through:

```text
/sf-verify [spec or release scope]
```

`sf-verify` must check the user story, success and error behavior, bug gate, documentation coherence, and project development mode implications. If verification fails, stop and return the corrective next step.

## Phase 7 — Changelog Route

If the release is verified and `no-changelog` is absent, route to:

```text
/sf-changelog
```

Skip changelog only when:

- the change is internal or no meaningful user-facing release note exists
- the user passed `no-changelog`
- the release remains partial or blocked

Do not treat changelog generation as proof of release health.

## Stop Conditions

Stop and report `blocked` when:

- release scope is ambiguous
- checks fail and the user did not request a force-through path
- `sf-ship` blocks or push fails
- deployment state cannot be matched to the shipped commit/branch
- `sf-prod` reports failed, pending-timeout, or partial deployment truth
- required browser/auth/manual proof is missing
- `sf-verify` fails
- public docs or support copy are known stale for the changed behavior
- the release would include unrelated dirty files without explicit approval
- logs or screenshots would expose secrets or private data

## Final Report

```text
## Deploy: [project or scope]

Result: [deployed / partial / blocked / rerouted]
Environment: [local / preview / production / unknown]
Development mode: [local / vercel-preview-push / hybrid / unknown]

Phases:
- Scope and risk gate -> [status]
- sf-check -> [pass/fail/skipped/not needed]
- sf-ship -> [shipped/blocked/not run]
- sf-prod -> [ready/failed/pending/partial/not run]
- Evidence routing -> [sf-browser/sf-auth-debug/sf-test/not needed/missing]
- sf-verify -> [verified/partial/failed/not run]
- sf-changelog -> [updated/skipped/not run]

Evidence:
- Commit: [sha or none]
- Deployment URL: [url or none]
- Browser/manual proof: [summary or missing]
- Logs: [summary or not collected]

Risks or gaps:
- [item or none]

Next step:
- [command or none]

## Chantier

Skill courante: sf-deploy
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

Verdict sf-deploy:
- [deployed | partial | blocked | rerouted]
```

## Rules

- Keep release truth evidence-based.
- Prefer blocking over overstating readiness.
- Use existing skills for implementation, ship, deploy, and proof internals.
- Never print secrets, cookies, tokens, private headers, or raw sensitive logs.
- Never mutate production data, send emails, publish content, charge money, or delete records during deploy proof without explicit approval.
