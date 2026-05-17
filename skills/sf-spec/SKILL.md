---
name: sf-spec
description: "Write specs with user stories, contracts, risks, and plans."
argument-hint: [optional: description de ce qu'on veut construire]
---

## Canonical Paths

Before resolving any ShipFlow-owned file, load `$SHIPFLOW_ROOT/skills/references/canonical-paths.md` (`$SHIPFLOW_ROOT` defaults to `$HOME/shipflow`). ShipFlow tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPFLOW_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Instruction Layering

This `SKILL.md` is the activation contract. Before editing or expanding this skill, load `$SHIPFLOW_ROOT/skills/references/skill-instruction-layering.md` and keep bulky workflow detail in skill-local references.

## Chantier Tracking

Trace category: `obligatoire`.
Process role: `lifecycle`.

Before creating or updating a spec-first chantier, load `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md`. `sf-spec` must initialize the chantier registry entry inside the spec itself: frontmatter includes `created_at`, `updated_at`, and `source_model`; the body includes `Skill Run History` and `Current Chantier Flow`; and the first history row records the current `sf-spec` run. End the report with the compact `Chantier` block from `$SHIPFLOW_ROOT/skills/references/reporting-contract.md`. If no chantier spec is created or updated, report `Chantier: non applicable` or `Chantier: non trace` with the reason.

If the user input or a source skill provides a `Chantier potentiel` block, treat it as primary intake context. Preserve its proposed title, reason, severity, scope, evidence, recommended spec, and next step in the new or updated spec instead of flattening it into a vague task description.

## Report Modes

Before producing the final report, load `$SHIPFLOW_ROOT/skills/references/reporting-contract.md`.

Default to `report=user`: concise, spec-path first, next-step oriented, and using the compact chantier block. Use `report=agent`, blocked, handoff, verbose, or full report only when detailed evidence is needed.

## Required References

Load only the references needed for the active run:

- `references/spec-creation-workflow.md`: detailed context gathering, user-story reconstruction, investigation, spec template, validation, metadata, acceptance criteria, and final report rules.
- `$SHIPFLOW_ROOT/skills/references/documentation-freshness-gate.md`: required only when the spec depends on framework, SDK, service, API, auth/session, build, migration, cache, routing, or integration behavior.
- Supabase, Sentry, development-mode, or other shared references only when the workflow reference triggers their gate.

## Mode Detection

Parse `$ARGUMENTS` and the latest user request, then choose the smallest safe path.

- New non-trivial work or a `Chantier potentiel` intake: load `references/spec-creation-workflow.md` and create or update a durable spec.
- Small/local work where a spec would add no useful contract: report `Chantier: non applicable` and route directly to the owner skill.
- Missing actor, trigger, observable result, scope boundary, or security/data policy that changes behavior: ask a targeted question before writing the spec.

## Core Execution Rules

- A ready spec must be autonomous enough for a fresh agent: user story, minimal behavior contract, success/error behavior, scope, tasks, acceptance criteria, risks, linked systems, documentation impact, and run history.
- Specs are written for implementation, not brainstorming; avoid placeholders, vague tasks, and undocumented assumptions.
- `sf-spec` creates or updates the durable chantier spec only; it does not edit `TASKS.md`, `AUDIT_LOG.md`, or `PROJECTS.md`.
- External-doc freshness, security, auth, tenant, data, money, destructive, and public-claim ambiguities must be resolved before the spec is called ready.

## Stop Conditions

Stop and report blocked when:

- A material product, security, data, tenant, external-side-effect, or workflow-integrity decision is missing.
- The requested implementation path would satisfy tasks but not the user story.
- A required shared reference is missing or contradicts this activation contract.
- The spec would need `TBD`, hidden assumptions, or untestable acceptance criteria.

## Validation

Validate this skill after edits with:

- `rg -n "Trace category|Process role|Chantier potentiel|Report Modes|Required References|Mode Detection|ready spec|TASKS.md|references/spec-creation-workflow" skills/sf-spec/SKILL.md`
- `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
- `tools/shipflow_sync_skills.sh --check --all`
