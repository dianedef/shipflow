---
name: sf-repurpose
description: "Repurpose sources into docs, marketing, FAQs, or site updates."
argument-hint: <source file, transcript, notes, URL, or repurposing goal>
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

- `references/repurpose-workflow.md`: Source reconstruction, output selection, diffusion map, transformation catalog, safety pass, and owner handoff rules.
- `references/output-pack.md`: Standard structured output pack used during Phase 3.

## Mode Detection

Parse `$ARGUMENTS` and choose the smallest safe mode.

- Read-Only Delegation: if subagents are used for source reading, they must not edit files, mutate trackers, or create content surfaces.
- Execution contract: first reconstruct source truth, then decide justified outputs, then build only the requested or warranted output pack.
- SOURCE ANALYSIS: load `references/repurpose-workflow.md` to reconstruct source truth and justified outputs.
- OUTPUT PACK: load `references/output-pack.md` when building the structured pack.
- CONTENT IMPACT: load editorial/technical corpus references before public content, claim, workflow, or docs changes.
- Owner Skill Handoffs: route implementation, audit, docs, SEO, copy, or content application to the owning skill when the repurpose output becomes executable work.

## Core Execution Rules

- Stay source-faithful: do not invent claims, proof, product promises, legal statements, or article surfaces.
- Preserve copyright, claim-register, editorial surface, and output-placement constraints.
- Do not originate a chantier unless the user explicitly asks to formalize the follow-up work.

## Stop Conditions

Stop and report blocked when:

- A required reference is missing or contradicts this activation contract.
- The requested work would change behavior outside this skill's scope.
- A safety, security, documentation, source-faithfulness, or chantier guardrail would need to be weakened.
- The action would edit unrelated dirty files or mutate durable state without an owner-skill contract.

## Validation

Validate this skill after edits with:

- `rg -n "Read-Only Delegation|Execution contract|source|copyright|claim|output-pack|Owner Skill Handoffs" skills/sf-repurpose/SKILL.md`
- `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
- `tools/shipflow_sync_skills.sh --check --all`
