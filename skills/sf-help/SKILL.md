---
name: sf-help
description: "Answer ShipFlow skills, workflows, modes, and prompt questions."
argument-hint: <help topic or route question>
---

## Canonical Paths

Before resolving any ShipFlow-owned file, load `$SHIPFLOW_ROOT/skills/references/canonical-paths.md` (`$SHIPFLOW_ROOT` defaults to `$HOME/shipflow`). ShipFlow tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPFLOW_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Instruction Layering

This `SKILL.md` is the activation contract. Before editing or expanding this skill, load `$SHIPFLOW_ROOT/skills/references/skill-instruction-layering.md` and keep bulky workflow detail in skill-local references.

## Chantier Tracking

Trace category: `non-applicable`.
Process role: `helper`.

This skill does not write to chantier specs. If invoked inside a spec-first flow, do not modify `Skill Run History`; include `Chantier: non applicable` or `Chantier: non trace` only when useful.

## Report Modes

Before producing the final report, load `$SHIPFLOW_ROOT/skills/references/reporting-contract.md`.

Default to `report=user`: concise, outcome-first, and in the user's active language. Use `report=agent`, `handoff`, `verbose`, or `full-report` only when the user or next owner needs detailed evidence.

## Required References

Always load shared references only when their gate applies. Load skill-local references precisely by mode:

- `references/help-catalog.md`: Skill catalog, workflow cycles, prompts, scoring notes, file references, and quick answers.

The canonical `Chantier Registry` doctrine lives in `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md`; this skill only summarizes it for help output.

## Mode Detection

Parse `$ARGUMENTS` and choose the smallest safe mode.

- If the user asks a direct help question, answer concisely from the top-level route and `references/help-catalog.md` as needed.
- If the user needs full skill taxonomy, workflow cheat sheets, or quick answers, load `references/help-catalog.md`.
- Use `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md` for canonical trace/process role doctrine instead of maintaining a duplicate role matrix here.
- For `Skills at a Glance`, `Quick Answers`, workflow cycles, audit scoring, and file-reference help, load `references/help-catalog.md`.

## Core Execution Rules

- Do not write chantier specs or trackers.
- Keep answers user-facing and in the active user language.
- Route to an owner skill when the user asks ShipFlow to do work rather than explain it.

## Stop Conditions

Stop and report blocked when:

- A required reference is missing or contradicts this activation contract.
- The requested work would change behavior outside this skill's scope.
- A safety, security, documentation, source-faithfulness, or chantier guardrail would need to be weakened.
- The action would edit unrelated dirty files or mutate durable state without an owner-skill contract.

## Validation

Validate this skill after edits with:

- `rg -n "Trace category|Process role|Chantier Registry|Skills at a Glance|Quick Answers|references/" skills/sf-help/SKILL.md`
- `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
- `tools/shipflow_sync_skills.sh --check --all`
