---
name: sf-redact
description: "Long-form drafting for articles, guides, editorials, and brand voice."
argument-hint: '<nombre> <format> [sujet] (ex: "3 blog", "1 editorial IA en éducation", "2 informational")'
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

- `references/redaction-workflow.md`: Long-form drafting workflow, identity absorption, planning, research, drafting, optimization, quality control, metadata, and report details.

## Mode Detection

Parse `$ARGUMENTS` and choose the smallest safe mode.

- DRAFTING: load `references/redaction-workflow.md` before planning, researching, drafting, optimizing, or quality checking long-form content.
- PUBLIC SURFACE: load editorial and technical corpus references before choosing or changing public content surfaces.
- RESEARCH: apply fresh source checks when factual, market, tool, legal, or current-practice claims are involved.

## Core Execution Rules

- Preserve brand voice, source evidence, public-claim, editorial surface, copyright, disclosure, and quality gates.
- Do not originate a chantier unless the user explicitly asks to formalize follow-up work.
- Do not invent facts, quotes, legal claims, performance claims, pricing, or customer proof.

## Stop Conditions

Stop and report blocked when:

- A required reference is missing or contradicts this activation contract.
- The requested work would change behavior outside this skill's scope.
- A safety, security, documentation, source, claim, auth, production, redaction, or chantier guardrail would need to be weakened.
- The action would edit unrelated dirty files or mutate durable state without an owner-skill contract.

## Validation

Validate this skill after edits with:

- `rg -n "Trace category|Process role|Governance Corpora|source|claim|copyright|quality|references/" skills/sf-redact/SKILL.md`
- `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
- `tools/shipflow_sync_skills.sh --check --all`
