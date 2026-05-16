---
name: sf-audit-design
description: "UI/UX design audit."
disable-model-invocation: true
argument-hint: '[file-path | "global" | "deep"] (omit for full project standard audit)'
---

## Canonical Paths

Before resolving any ShipFlow-owned file, load `$SHIPFLOW_ROOT/skills/references/canonical-paths.md` (`$SHIPFLOW_ROOT` defaults to `$HOME/shipflow`). ShipFlow tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPFLOW_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Instruction Layering

Load `$SHIPFLOW_ROOT/skills/references/skill-instruction-layering.md` before execution. This skill keeps the activation surface local and loads detailed audit matrices from references.

## Chantier Tracking

Trace category: `conditionnel`.
Process role: `source-de-chantier`.

Before producing the final report, load `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md` when this run is attached to a spec-first chantier. If exactly one active `shipflow_data/workflow/specs/*.md` chantier is identified, append the current run to `Skill Run History`, update `Current Chantier Flow` when the run changes the chantier state, and include a final `Chantier` block. If no unique chantier is identified, do not write to any spec; report `Chantier: non applicable` or `Chantier: non trace` with the reason.

## Chantier Potential Intake

Because this skill has process role `source-de-chantier`, evaluate the standard threshold from `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md` before the final report. If findings reveal non-trivial follow-up work and no unique chantier owns it, include a `Chantier potentiel` block with explicit recommendation to `/sf-spec ...`.

## Report Modes

Before producing the final report, load `$SHIPFLOW_ROOT/skills/references/reporting-contract.md`.

Default to `report=user`: concise, findings-first, top issues + proof gaps + chantier potential + next action.
Use `report=agent`, `handoff`, `verbose`, or `full-report` for full matrices and exhaustive checklist output.

## Context

- Current directory: !`pwd`
- Project CLAUDE.md: !`head -100 CLAUDE.md 2>/dev/null || echo "no CLAUDE.md"`
- Branding summary: !`if [ -f shipflow_data/business/branding.md ]; then head -60 shipflow_data/business/branding.md; else head -60 BRANDING.md 2>/dev/null || echo "no shipflow_data/business/branding.md (and no legacy BRANDING.md)"; fi`
- Representative pages/components: !`find src/pages src/app src/components -name "*.astro" -o -name "*.tsx" -o -name "*.vue" 2>/dev/null | grep -v node_modules | sort | head -80`

## Mode Detection

- `$ARGUMENTS == deep` -> `DEEP MODE`
- `$ARGUMENTS == global` -> `GLOBAL MODE`
- `$ARGUMENTS` is a file path -> `PAGE MODE`
- empty args -> `PROJECT MODE`

## Required References

Always load:

1. `$SHIPFLOW_ROOT/skills/sf-audit-design/references/audit-gates.md`
2. `$SHIPFLOW_ROOT/skills/sf-audit-design/references/audit-checklists.md`

Load on demand:

- `DEEP MODE`: launch specialist skills (`sf-audit-design-tokens`, `sf-audit-components`, `sf-audit-a11y`) per instructions in `audit-gates.md`.
- `GLOBAL MODE`: use cross-project routing and tracking protocol from `audit-gates.md`.

## Core Execution Rules

- Findings-first reporting is mandatory.
- Audit must include product coherence and documentation mismatch risks when UI claims/states diverge.
- Business metadata quality must be reported when it affects confidence (`artifact_version`, `status`, `updated`, `confidence`, `next_review`).
- Preserve accessibility and safety guardrails; never soften critical findings to reduce effort.
- Use file:line evidence and a one-line "Why it matters" principle for priority findings.

## Stop Conditions

Stop and report `blocked` when:

- no auditable scope can be identified
- required reference is missing and no safe fallback exists
- deep/global orchestration requested but bounded audit missions cannot be formed safely

## Tracking Contract

Use the shared read-before-write protocol for `AUDIT_LOG.md` and `TASKS.md` documented in `audit-gates.md`.

## Validation

Run focused checks for skill-contract coherence:

```bash
rg -n "Trace category|Process role|Chantier potentiel|reporting-contract|skill-instruction-layering|references/" skills/sf-audit-design/SKILL.md
python3 tools/skill_budget_audit.py --skills-root skills --format markdown
```
