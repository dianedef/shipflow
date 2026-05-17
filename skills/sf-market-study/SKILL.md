---
name: sf-market-study
description: "Research demand, competitors, keywords, and monetization."
argument-hint: <niche or product idea>
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

- `references/market-study-workflow.md`: Market study workflow, demand analysis, competition, sizing, monetization, brand/domain checks, AI visibility, risk, and verdict details.

## Mode Detection

Parse `$ARGUMENTS` and choose the smallest safe mode.

- STUDY: load `references/market-study-workflow.md` before demand, competition, sizing, monetization, or go/no-go analysis.
- MCP/DATA: load the workflow reference before choosing DataForSEO or complementary tools.
- FOLLOW-UP: route implementation, content, product, or GTM decisions to `/sf-spec` when findings cross chantier threshold.

## Core Execution Rules

- Preserve demand evidence, competition, market sizing, monetization, domain/brand, AI visibility, and risk-assessment rules.
- Evaluate `Chantier potentiel` when research produces product, GTM, content, architecture, or implementation decisions.
- Do not invent market data, competitor facts, pricing, affiliate terms, or demand evidence.

## Stop Conditions

Stop and report blocked when:

- A required reference is missing or contradicts this activation contract.
- The requested work would change behavior outside this skill's scope.
- A safety, security, documentation, source, claim, auth, production, redaction, or chantier guardrail would need to be weakened.
- The action would edit unrelated dirty files or mutate durable state without an owner-skill contract.

## Validation

Validate this skill after edits with:

- `rg -n "Trace category|Process role|Chantier Potential|demand|competition|monetization|GO / NO-GO|references/" skills/sf-market-study/SKILL.md`
- `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
- `tools/shipflow_sync_skills.sh --check --all`
