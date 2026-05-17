---
name: sf-init
description: "Bootstrap ShipFlow tracking, stack detection, and registries."
argument-hint: <project path or bootstrap instruction>
---

## Canonical Paths

Before resolving any ShipFlow-owned file, load `$SHIPFLOW_ROOT/skills/references/canonical-paths.md` (`$SHIPFLOW_ROOT` defaults to `$HOME/shipflow`). ShipFlow tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPFLOW_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Instruction Layering

This `SKILL.md` is the activation contract. Before editing or expanding this skill, load `$SHIPFLOW_ROOT/skills/references/skill-instruction-layering.md` and keep bulky workflow detail in skill-local references.

## Chantier Tracking

Trace category: `conditionnel`.
Process role: `support-de-chantier`.

Before producing the final report, load `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md` when this run is attached to a spec-first chantier. If exactly one active chantier spec is identified, append the current run to `Skill Run History`; otherwise do not write to any spec.

## Report Modes

Before producing the final report, load `$SHIPFLOW_ROOT/skills/references/reporting-contract.md`.

Default to `report=user`: concise, outcome-first, and in the user's active language. Use `report=agent`, `handoff`, `verbose`, or `full-report` only when the user or next owner needs detailed evidence.

## Required References

Always load shared references only when their gate applies. Load skill-local references precisely by mode:

- `references/bootstrap-workflow.md`: Detailed bootstrap workflow, generated artifact templates, MCP setup, governance corpus bootstrap, and final reporting details.

## Mode Detection

Parse `$ARGUMENTS` and choose the smallest safe mode.

- Detect whether the request is a new project bootstrap, existing project governance refresh, MCP/server setup, or bootstrap audit.
- For any mode, load `references/bootstrap-workflow.md` before creating or updating project files.

## Core Execution Rules

- Preserve absolute-path validation expectations and project-root safety checks.
- Do not rewrite existing project governance artifacts unless the bootstrap workflow explicitly allows it.
- Do not originate a chantier unless the user explicitly asks to formalize setup policy work.

## Stop Conditions

Stop and report blocked when:

- A required reference is missing or contradicts this activation contract.
- The requested work would change behavior outside this skill's scope.
- A safety, security, documentation, source-faithfulness, or chantier guardrail would need to be weakened.
- The action would edit unrelated dirty files or mutate durable state without an owner-skill contract.

## Validation

Validate this skill after edits with:

- `rg -n "Trace category|Process role|canonical-paths|project-development-mode|governance|report" skills/sf-init/SKILL.md`
- `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
- `tools/shipflow_sync_skills.sh --check --all`
