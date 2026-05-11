---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipFlow
created: "2026-05-01"
updated: "2026-05-11"
status: reviewed
source_skill: sf-start
scope: decisions
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - templates/artifacts/decision_record.md
  - shipflow_data/technical/architecture.md
  - shipflow_data/technical/guidelines.md
  - shipflow_data/workflow/specs/
depends_on:
  - artifact: "shipflow_data/technical/architecture.md"
    artifact_version: "1.1.0"
    required_status: reviewed
  - artifact: "shipflow_data/technical/guidelines.md"
    artifact_version: "1.4.0"
    required_status: reviewed
supersedes: []
evidence:
  - "decision_record template, architecture/guidelines docs, and current specs."
  - "project-governance-layout decision added for canonical shipflow_data project corpus layout."
next_review: "2026-06-01"
next_step: "/sf-docs technical audit decisions"
---

# Decisions Bridge

## Purpose

This doc explains where durable technical decisions live and how they differ from specs, context docs, and subsystem technical docs.

## Owned Files

| Path | Role | Edit notes |
| --- | --- | --- |
| `templates/artifacts/decision_record.md` | Template for ADR-style decisions | Keep metadata linter-compatible |
| `shipflow_data/technical/architecture.md` | Global structure and boundaries | Store current architecture, not every historical debate |
| `shipflow_data/technical/guidelines.md` | General technical doctrine | Store durable rules and anti-patterns |
| `shipflow_data/workflow/specs/*.md` | Chantiers and run history | Store task-specific decisions and evidence |
| `shipflow_data/technical/*.md` | Subsystem operational context | Store code-proximate behavior and maintenance rules |
| `shipflow_data/technical/decisions/*.md` | ADR-style decisions | Store durable cross-cutting choices such as governance layout |

## Entrypoints

- `templates/artifacts/decision_record.md`: start here when a durable ADR-style decision artifact is needed.
- `shipflow_data/technical/architecture.md`: update when a decision changes global structure, system boundaries, or architectural invariants.
- `shipflow_data/technical/guidelines.md`: update when a decision becomes a general engineering or documentation rule.
- `shipflow_data/workflow/specs/*.md`: link the decision when it governs a specific chantier.
- `shipflow_data/technical/decisions/project-governance-layout.md`: canonical decision for project-local `shipflow_data/` layout and root legacy migration.

## Decision Routing

- Use `decision_record` when a choice is durable, cross-cutting, or likely to be revisited.
- Use a spec when the decision belongs to a chantier and must guide implementation.
- Use `shipflow_data/technical/architecture.md` when the accepted decision changes global structure.
- Use `shipflow_data/technical/guidelines.md` when the accepted decision becomes a general engineering rule.
- Use a subsystem technical doc when the decision changes how agents should edit or validate that subsystem.

## Invariants

- Technical docs do not replace specs or ADRs.
- Specs keep chantier history; technical docs keep durable subsystem knowledge.
- Current behavior remains grounded in code and validated docs.
- Decision records need enough rationale and consequences to be useful without chat history.

## Failure Modes

- Hiding durable architecture choices inside a chat or tracker creates rediscovery work.
- Copying full spec history into technical docs makes them stale and noisy.
- Updating a decision contract without updating dependent specs can create version drift.

## Security Notes

- Decision records can mention security posture, but must not include secrets, raw logs, credentials, or private exploit details beyond what is needed for action.
- Decisions affecting permissions, data exposure, external side effects, or destructive operations require explicit evidence and verification paths.

## Validation

```bash
python3 tools/shipflow_metadata_lint.py templates/artifacts/decision_record.md shipflow_data/technical/decisions shipflow_data/technical/architecture.md shipflow_data/technical/guidelines.md shipflow_data/workflow/specs
rg -n "decision|rationale|consequences|templates/artifacts/decision_record.md" shipflow_data/technical/decisions.md
```

## Reader Checklist

- A spec records a decision that should outlive the chantier -> propose a decision record or update the relevant contract.
- `shipflow_data/technical/architecture.md` or `shipflow_data/technical/guidelines.md` changed -> check affected specs and technical docs for version drift.
- A technical doc needs history -> link to a decision record or spec instead of copying the history.

## Maintenance Rule

Update this doc when decision routing, ADR templates, architecture/guideline boundaries, or spec-to-doc decision flow changes.
