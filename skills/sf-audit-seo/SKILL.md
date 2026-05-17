---
name: sf-audit-seo
description: "Audit SEO health, metadata, indexing, and intent fit."
argument-hint: <page, URL, content file, or project>
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

- `references/seo-audit-workflow.md`: SEO modes, technical/on-page/content/schema/internal-linking/AI-visibility checklists, tracking, and report details.

## Mode Detection

Parse `$ARGUMENTS` and choose the smallest safe mode.

- GLOBAL MODE: load `references/seo-audit-workflow.md` and audit project-level SEO infrastructure and content architecture.
- PAGE MODE: load `references/seo-audit-workflow.md` and audit the named page, URL, or route.
- FIX MODE: only change SEO files or content when explicitly requested or owned by the active chantier.

## Core Execution Rules

- Load technical/editorial corpus references before changing mapped docs, public content, metadata, sitemap, robots, or schema surfaces.
- Governance Corpora: use `$SHIPFLOW_ROOT/skills/references/technical-docs-corpus.md` and `$SHIPFLOW_ROOT/skills/references/editorial-content-corpus.md` when SEO findings touch mapped docs, public content, claims, sitemap, robots, metadata, or schema.
- Apply the Documentation Freshness Gate before changing external SEO/Search/OpenAI/ChatGPT doctrine.
- Preserve structured data and AI Visibility checks by loading `references/seo-audit-workflow.md` for technical SEO, schema, internal linking, and AEO/GEO review.
- Evaluate `Chantier potentiel` for indexation, schema, content architecture, AI visibility, or multi-page remediation.

## Stop Conditions

Stop and report blocked when:

- A required reference is missing or contradicts this activation contract.
- The requested work would change behavior outside this skill's scope.
- A safety, security, documentation, source-faithfulness, or chantier guardrail would need to be weakened.
- The action would edit unrelated dirty files or mutate durable state without an owner-skill contract.

## Validation

Validate this skill after edits with:

- `rg -n "Governance Corpora|OpenAI|ChatGPT|Chantier Potential|Report Modes|structured data|AI Visibility" skills/sf-audit-seo/SKILL.md`
- `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
- `tools/shipflow_sync_skills.sh --check --all`
