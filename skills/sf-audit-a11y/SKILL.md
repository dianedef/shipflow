---
name: sf-audit-a11y
description: "Accessibility audit."
argument-hint: '[file-path | "global"] (omit for full project)'
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

Default to `report=user`: concise, findings-first for audits and failures, outcome-first for successful support runs, and in the user's active language. Use `report=agent`, `handoff`, `verbose`, or `full-report` only when detailed evidence is needed.

## Required References

Always load shared references only when their gate applies. Load skill-local references precisely by mode:

- `references/accessibility-audit-workflow.md`: Accessibility audit workflow, WCAG/APG checks, keyboard/focus/ARIA phases, severity rules, and report details.

## Mode Detection

Parse `$ARGUMENTS` and choose the smallest safe mode.

- PROJECT MODE: load `references/accessibility-audit-workflow.md` for full WCAG/APG accessibility audits.
- FILE MODE: load the workflow reference and audit the named component, route, or file.
- GLOBAL MODE: load the workflow reference and summarize systemic accessibility posture across the workspace.

## Core Execution Rules

- Preserve WCAG 2.2, keyboard, focus, ARIA, screen-reader, target-size, and Flutter accessibility checks.
- Evaluate `Chantier potentiel` for systemic accessibility findings, multi-surface remediation, or validation that exceeds a direct fix.
- Do not treat visual appearance alone as accessibility proof.

## Stop Conditions

Stop and report blocked when:

- A required reference is missing or contradicts this activation contract.
- The requested work would change behavior outside this skill's scope.
- A safety, security, documentation, source, claim, auth, production, redaction, or chantier guardrail would need to be weakened.
- The action would edit unrelated dirty files or mutate durable state without an owner-skill contract.

## Validation

Validate this skill after edits with:

- `rg -n "Trace category|Process role|Chantier Potential|Report Modes|WCAG|keyboard|focus|ARIA|references/" skills/sf-audit-a11y/SKILL.md`
- `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
- `tools/shipflow_sync_skills.sh --check --all`
