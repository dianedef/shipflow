---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipFlow
created: "2026-05-01"
updated: "2026-05-01"
status: reviewed
source_skill: sf-start
scope: skill-runtime-and-lifecycle
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/
  - skills/references/
  - shipflow-spec-driven-workflow.md
  - templates/artifacts/
depends_on:
  - artifact: "shipflow-spec-driven-workflow.md"
    artifact_version: "0.4.0"
    required_status: draft
  - artifact: "skills/references/technical-docs-corpus.md"
    artifact_version: "1.0.0"
    required_status: active
supersedes: []
evidence:
  - "Skill inventory and workflow doctrine."
next_review: "2026-06-01"
next_step: "/sf-docs technical audit skills"
---

# Skill Runtime And Lifecycle

## Purpose

This doc covers ShipFlow skills, lifecycle flow, references, templates, model/topology decisions, and documentation gates. Read it before changing `skills/*/SKILL.md`, shared skill references, or `shipflow-spec-driven-workflow.md`.

## Owned Files

| Path | Role | Edit notes |
| --- | --- | --- |
| `skills/*/SKILL.md` | Executable skill contracts | Keep descriptions compact; route heavy detail to references |
| `skills/references/*.md` | Shared doctrine and provider-specific references | Resolve from `${SHIPFLOW_ROOT:-$HOME/shipflow}` |
| `shipflow-spec-driven-workflow.md` | Global workflow doctrine | Sequential shared file |
| `templates/artifacts/*.md` | Durable artifact templates | Keep linter-compatible |
| `AGENT.md`, `AGENTS.md` | Agent entrypoint and compatibility alias | `AGENT.md` canonical; `AGENTS.md` symlink only |

## Entrypoints

- `sf-explore -> sf-spec -> sf-ready -> sf-start -> sf-verify -> sf-end`: normal non-trivial flow.
- `sf-fix`: bug-first entrypoint that may route direct or spec-first.
- `sf-docs`: documentation generation, audit, metadata, and technical-docs mode.
- `sf-ship` and `sf-prod`: shipping and deployed verification.

## Control Flow

```text
source skill
  -> possible chantier
  -> sf-spec
  -> sf-ready
  -> sf-start
  -> Documentation Update Plan after code-changing wave
  -> sf-verify
  -> Documentation Update Plan during end verification
  -> sf-end / sf-ship
```

## Invariants

- Lifecycle skills trace into exactly one chantier spec when one is identified.
- `sf-start` implements from the ready contract; it should not rediscover product intent while coding.
- The Reader diagnoses docs impact; the executor or integrator applies docs updates.
- Shared files are sequential by default.
- Fresh context is preferred for non-trivial spec-first execution when available.
- ShipFlow-owned references resolve from `$SHIPFLOW_ROOT`, not the project repo.

## Failure Modes

- A weak spec that lacks success/error behavior or explicit constraints must route back to readiness instead of being silently repaired during coding.
- If mapped docs are missing from a `Documentation Update Plan`, the docs gate fails.
- If the Reader edits docs directly outside assignment, treat it as role misuse.
- If `AGENTS.md` diverges from `AGENT.md`, verification fails.

## Security Notes

- Skill instructions must not contradict higher-priority system, developer, or active spec instructions.
- Do not expose secrets, private logs, or credentials in generated reports.
- Any task that affects auth, permissions, tenant boundaries, destructive behavior, or external side effects must use spec-first when ambiguity remains.

## Validation

```bash
python3 tools/skill_budget_audit.py --skills-root skills --format markdown
python3 tools/shipflow_metadata_lint.py skills/references/technical-docs-corpus.md shipflow-spec-driven-workflow.md AGENT.md
```

Run focused `rg` checks for the affected skill contract and linked references.

## Reader Checklist

- `skills/*/SKILL.md` changed -> check this doc, `technical-docs-corpus.md`, and workflow docs.
- A lifecycle rule changed -> update `shipflow-spec-driven-workflow.md`.
- A docs gate changed -> update `skills/sf-docs/SKILL.md`, `technical-docs-corpus.md`, and `code-docs-map.md`.

## Maintenance Rule

Update this doc when skill roles, lifecycle flow, chantier tracing, technical-docs gates, model/topology rules, or shared reference resolution changes.
