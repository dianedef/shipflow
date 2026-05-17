---
name: sf-audit-copywriting
description: "Audit marketing copy, offer, persona, and persuasion."
argument-hint: <page, URL, content file, funnel, or project>
---

## Canonical Paths

Before resolving any ShipFlow-owned file, load `$SHIPFLOW_ROOT/skills/references/canonical-paths.md` (`$SHIPFLOW_ROOT` defaults to `$HOME/shipflow`). ShipFlow tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPFLOW_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Instruction Layering

This `SKILL.md` is the activation contract. Before editing or expanding this skill, load `$SHIPFLOW_ROOT/skills/references/skill-instruction-layering.md` and keep bulky workflow detail in skill-local references.

## Chantier Tracking

Trace category: `conditionnel`.
Process role: `source-de-chantier`.

Before producing the final report, load `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md`. If attached to one unique chantier spec, write the run trace there. If no unique chantier exists, do not write to a spec.

## Chantier Potential Intake

Because this skill has process role `source-de-chantier`, evaluate the standard threshold from `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md` before the final report. Add a `Chantier potentiel` block when findings reveal non-trivial future work and no unique chantier owns it.

## Report Modes

Before producing the final report, load `$SHIPFLOW_ROOT/skills/references/reporting-contract.md`.

Default to `report=user`: concise, outcome-first, and in the user's active language. Use `report=agent`, `handoff`, `verbose`, or `full-report` only when the user or next owner needs detailed evidence.

## Required References

Always load shared references only when their gate applies. Load skill-local references precisely by mode:

- `references/copywriting-audit-workflow.md`: Copywriting modes, persuasion frameworks, scoring matrices, conversion/trust criteria, examples, and report details.

## Mode Detection

Parse `$ARGUMENTS` and choose the smallest safe mode.

- GLOBAL MODE: load `references/copywriting-audit-workflow.md` and audit the funnel or project-level copy system.
- PAGE/FILE MODE: load `references/copywriting-audit-workflow.md` and audit the named surface.
- FIX MODE: only rewrite copy when the user asked for fixes or the active chantier owns remediation.

## Core Execution Rules

- Preserve claim-evidence, compliance, trust, persona, offer, and conversion checks.
- Evaluate `Chantier potentiel` when findings require multi-page, positioning, legal, trust, or funnel decisions.
- Do not invent business claims, testimonials, proof, pricing, or guarantees.

## Stop Conditions

Stop and report blocked when:

- A required reference is missing or contradicts this activation contract.
- The requested work would change behavior outside this skill's scope.
- A safety, security, documentation, source-faithfulness, or chantier guardrail would need to be weakened.
- The action would edit unrelated dirty files or mutate durable state without an owner-skill contract.

## Validation

Validate this skill after edits with:

- `rg -n "Trace category|Process role|Chantier Potential|Report Modes|score|conversion|trust" skills/sf-audit-copywriting/SKILL.md`
- `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
- `tools/shipflow_sync_skills.sh --check --all`
