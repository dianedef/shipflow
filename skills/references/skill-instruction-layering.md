---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipFlow
created: "2026-05-16"
updated: "2026-05-16"
status: draft
source_skill: sf-start
scope: skill-instruction-layering
owner: unknown
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/*/SKILL.md
  - skills/references/skill-context-budget.md
  - skills/references/chantier-tracking.md
  - skills/references/reporting-contract.md
  - shipflow_data/technical/skill-runtime-and-lifecycle.md
depends_on:
  - artifact: "skills/references/skill-context-budget.md"
    artifact_version: "0.2.0"
    required_status: "draft"
  - artifact: "skills/references/chantier-tracking.md"
    artifact_version: "0.5.0"
    required_status: "draft"
  - artifact: "skills/references/reporting-contract.md"
    artifact_version: "1.2.0"
    required_status: "active"
supersedes: []
evidence:
  - "Spec compact-shipflow-skill-instructions.md requested layered compaction for pilot skills."
  - "Repeated top-level doctrine across long skills was identified as instruction dilution risk."
next_review: "2026-06-16"
next_step: "/sf-verify Compact ShipFlow Skill Instructions"
---

# Skill Instruction Layering

## Purpose

Define the progressive-disclosure contract for ShipFlow skills so compaction reduces repetition without removing operational guardrails.

## Top-Level `SKILL.md` Contract

Each `SKILL.md` must keep a compact activation surface that is independently understandable after required references are loaded.

Required local sections:

1. Role and invocation contract (`name`, `description`, args hints).
2. `Canonical Paths` loader.
3. `Trace category` and `Process role` when chantier tracking applies.
4. Report mode contract and pointer to `skills/references/reporting-contract.md`.
5. Mode or route detection.
6. Local stop conditions and validation commands.
7. Explicit list of required references and when each one must be loaded.

The top-level skill body must prioritize first-screen clarity over exhaustive examples.

## What Must Stay Local

Keep these elements in `SKILL.md` even when a reference exists:

- Skill role and scope boundaries.
- Non-negotiable stop conditions specific to this skill.
- Result semantics or verdict semantics that downstream lifecycle skills depend on.
- Routing choices that decide which reference to load.
- Any section labels mechanically checked by downstream workflows.

Never remove `Trace category`, `Process role`, chantier routing visibility, canonical-paths loading, reporting-contract loading, redaction/security gates, or documentation-update gates just to reduce lines.

## What Moves To Shared References

Use `skills/references/*.md` for doctrine reused across multiple skills:

- chantier and lifecycle doctrine
- reporting formats
- canonical path resolution
- documentation freshness rules
- development mode / validation surface rules
- Sentry and observability expectations
- cross-skill language and metadata doctrine

Do not copy large shared doctrine blocks into multiple skill bodies.

## What Moves To Skill-Local References

Use `$SHIPFLOW_ROOT/skills/<skill>/references/*.md` for long, skill-specific detail:

- domain checklists and scoring matrices
- long mode playbooks
- extended examples
- migration checklists
- large report templates

Local references should be split by purpose. Avoid creating one new mega-reference.

## Exception Policy For Long Skills

If a pilot skill still exceeds 500 lines after safe extraction:

1. Keep the stricter local guardrail.
2. Document why compaction would be unsafe.
3. Record the exception in the active chantier/spec report.
4. Optionally substitute a fallback pilot from the approved list when required by the spec.

Safety beats line-count reduction.

## Validation After Compaction

Always run:

```bash
python3 tools/skill_budget_audit.py --skills-root skills --format markdown
tools/shipflow_sync_skills.sh --check --all
```

For changed references and docs with frontmatter:

```bash
python3 tools/shipflow_metadata_lint.py <changed-artifacts>
```

Use focused `rg` checks to verify mandatory labels and shared-reference links remain visible in compacted skill bodies.

## Integration Notes

- Do not rename skill directories, `name:` fields, or invocation keys during compaction.
- Resolve ShipFlow-owned references from `${SHIPFLOW_ROOT:-$HOME/shipflow}`.
- Keep reports concise for users, detailed only when explicit handoff or blocked state requires it.
