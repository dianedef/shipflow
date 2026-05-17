---
name: sf-enrich
description: "Enrich content with research, user focus, and conversion fit."
argument-hint: <file-path or folder>
---

## Canonical Paths

Before resolving any ShipFlow-owned file, load `$SHIPFLOW_ROOT/skills/references/canonical-paths.md` (`$SHIPFLOW_ROOT` defaults to `$HOME/shipflow`). ShipFlow tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPFLOW_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Instruction Layering

This `SKILL.md` is the activation contract. Before editing or expanding this skill, load `$SHIPFLOW_ROOT/skills/references/skill-instruction-layering.md` and keep bulky workflow detail in skill-local references.

## Chantier Tracking

Trace category: `conditionnel`.
Process role: `support-de-chantier`.

Before producing the final report, load `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md` when this run is attached to a spec-first chantier. If exactly one active chantier spec is identified, append the current run to `Skill Run History`; otherwise do not write to any spec. Do not originate a chantier unless the user explicitly asks to formalize follow-up work.

## Report Modes

Before producing the final report, load `$SHIPFLOW_ROOT/skills/references/reporting-contract.md`.

Default to `report=user`: concise, findings-first for audits and failures, outcome-first for successful support runs, and in the user's active language. Use `report=agent`, `handoff`, `verbose`, or `full-report` only when detailed evidence is needed.

## Required References

Always load shared references only when their gate applies. Load skill-local references precisely by mode:

- `references/enrichment-workflow.md`: Content enrichment workflow, research, rewrite, AI visibility, conversion layer, quality checks, metadata, and reporting details.

## Mode Detection

Parse `$ARGUMENTS` and choose the smallest safe mode.

- CONTENT ENRICHMENT: load `references/enrichment-workflow.md` before research, rewrite, enrichment, or quality checks.
- PUBLIC CONTENT: load editorial and technical corpus references before changing public pages, claims, schemas, or mapped docs.
- RESEARCH: use fresh source checks when enriching factual, market, tool, platform, or current-practice content.

## Core Execution Rules

- Preserve source, claim, editorial surface, AI visibility, conversion, and quality gates.
- Do not originate a chantier unless the user explicitly asks to formalize follow-up work.
- Do not invent facts, metrics, public claims, comparisons, or external recommendations.

## Stop Conditions

Stop and report blocked when:

- A required reference is missing or contradicts this activation contract.
- The requested work would change behavior outside this skill's scope.
- A safety, security, documentation, source, claim, auth, production, redaction, or chantier guardrail would need to be weakened.
- The action would edit unrelated dirty files or mutate durable state without an owner-skill contract.

## Validation

Validate this skill after edits with:

- `rg -n "Trace category|Process role|Governance Corpora|source|claim|AI visibility|conversion|references/" skills/sf-enrich/SKILL.md`
- `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
- `tools/shipflow_sync_skills.sh --check --all`
