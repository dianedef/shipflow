---
name: sf-start
description: "Execute ready specs or clear local tasks with guardrails."
argument-hint: <task description or TASKS.md item>
---

## Canonical Paths

Before resolving any ShipFlow-owned file, load `$SHIPFLOW_ROOT/skills/references/canonical-paths.md` (`$SHIPFLOW_ROOT` defaults to `$HOME/shipflow`). ShipFlow tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPFLOW_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Instruction Layering

This `SKILL.md` is the activation contract. Before editing or expanding this skill, load `$SHIPFLOW_ROOT/skills/references/skill-instruction-layering.md` and keep bulky workflow detail in skill-local references.

## Chantier Tracking

Trace category: `obligatoire`.
Process role: `lifecycle`.

Before executing from a ready spec, load `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md`, read the spec's `Skill Run History` and `Current Chantier Flow`, and preserve that flow in the execution contract. When a unique spec is used, append a current `sf-start` row with result `implemented`, `partial`, `blocked`, or `rerouted`, update `Current Chantier Flow`, and end the report with the compact `Chantier` block from `$SHIPFLOW_ROOT/skills/references/reporting-contract.md`. If the task is direct or no unique chantier spec is identified, do not write to a spec; report `Chantier: non applicable` or `Chantier: non trace` with the reason.

Result semantics:
- Use `implemented` when the planned code, docs, and tests within `sf-start` scope were completed, even if runtime, manual, hosted, production, Sentry, or device-only verification remains pending.
- Use `partial` only when implementation work itself is incomplete, intentionally deferred, or some planned files or tasks could not be finished.
- Missing manual QA, hosted preview proof, Sentry dashboard evidence, production verification, or device-only validation must not downgrade `sf-start` from `implemented` to `partial`; record those gaps for `sf-verify` instead.
- If local checks fail because the implementation is broken, use `partial` or `blocked` depending on whether the fix can continue. If checks fail because the environment cannot run a proof surface outside `sf-start` scope, keep `implemented` and route to `sf-verify partial`.

## Report Modes

Before producing the final report, load `$SHIPFLOW_ROOT/skills/references/reporting-contract.md`.

Default to `report=user`: concise, outcome-first, and using the compact chantier block. Use `report=agent`, blocked, handoff, verbose, or full report only when detailed evidence is needed.

## Required References

Load only the references needed for the active run:

- `references/execution-workflow.md`: detailed task identification, scope triage, execution contract, model/delegation choice, implementation loop, validation, spec trace, and final report rules.
- `$SHIPFLOW_ROOT/skills/references/documentation-freshness-gate.md`: required only when the task depends on framework, SDK, service, API, auth/session, build, migration, cache, routing, or integration behavior.
- `$SHIPFLOW_ROOT/skills/references/project-development-mode.md`: required before deriving the execution contract for project validation surface.
- Supabase, Sentry, auth-debug, browser, or model-routing references only when the workflow reference triggers their gate.

## Mode Detection

Parse `$ARGUMENTS`, available ready specs, and the latest user request.

- Direct mode: small, local, clear tasks may execute without a durable spec; create a silent mini-contract before editing.
- Spec-first mode: non-trivial, ambiguous, multi-file, auth/data/migration/API/security, external integration, or cross-domain work requires a ready spec before implementation.
- Existing ready spec: load `references/execution-workflow.md`, read the spec fully, derive the execution contract, then implement.
- Missing or unready spec: stop and route to `/sf-spec`, `/sf-ready`, then `/sf-start`.

## Core Execution Rules

- `sf-start` implements; it should not stop at planning when a valid execution contract exists.
- Preserve the user story outcome over task-checkbox completion.
- Read only the files needed for the execution contract and linked systems that can change correctness.
- Prefer fresh-context execution for non-trivial spec-first work when available, but keep the main thread responsible for integration, validation, and user-facing truth.
- Do not weaken documentation, security, redaction, chantier, or validation gates to finish faster.

## Stop Conditions

Stop and report blocked or rerouted when:

- No ready spec exists for non-trivial work.
- The spec is missing minimal behavior, success/error behavior, linked systems, explicit tasks, acceptance criteria, or decisive constraints.
- Product/security/data/tenant/destructive/external-side-effect ambiguity remains.
- The implementation path would satisfy listed tasks while missing the promised user outcome.
- Required references are missing or contradict this activation contract.

## Validation

Validate this skill after edits with:

- `rg -n "Trace category|Process role|Result semantics|implemented|partial|Report Modes|Required References|Spec-first|ready spec|references/execution-workflow" skills/sf-start/SKILL.md`
- `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
- `tools/shipflow_sync_skills.sh --check --all`
