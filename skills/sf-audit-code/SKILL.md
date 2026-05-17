---
name: sf-audit-code
description: "Audit code correctness, security, architecture, and tests."
argument-hint: <file, directory, diff, PR, or project>
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

- `references/audit-workflow.md`: GLOBAL, FILE, and PROJECT mode workflow, phase checklists, scoring, fix/report rules, and tracking details.

## Mode Detection

Parse `$ARGUMENTS` and choose the smallest safe mode.

- GLOBAL MODE: load `references/audit-workflow.md` and audit the current workspace at project level.
- FILE MODE: load `references/audit-workflow.md` and audit the named file or diff.
- PROJECT MODE: load `references/audit-workflow.md` and run the broader product/code/architecture/security scan.

## Core Execution Rules

- Findings first. Prioritize correctness, security, data integrity, architecture, reliability, and missing tests.
- Evaluate `Chantier potentiel` before the final report when findings exceed a direct local fix.
- Do not weaken permission, secret, data, destructive-action, or tenant-boundary guardrails during fixes.

## Stop Conditions

Stop and report blocked when:

- A required reference is missing or contradicts this activation contract.
- The requested work would change behavior outside this skill's scope.
- A safety, security, documentation, source-faithfulness, or chantier guardrail would need to be weakened.
- The action would edit unrelated dirty files or mutate durable state without an owner-skill contract.

## Validation

Validate this skill after edits with:

- `rg -n "Chantier Potential|Report Modes|GLOBAL MODE|FILE MODE|PROJECT MODE|security|findings" skills/sf-audit-code/SKILL.md`
- `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
- `tools/shipflow_sync_skills.sh --check --all`
