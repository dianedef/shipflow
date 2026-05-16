---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipFlow
created: "2026-05-16"
updated: "2026-05-16"
status: draft
source_skill: sf-start
scope: sf-audit-design-gates
owner: unknown
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/sf-audit-design/SKILL.md
  - skills/sf-audit-design-tokens/SKILL.md
  - skills/sf-audit-components/SKILL.md
  - skills/sf-audit-a11y/SKILL.md
depends_on:
  - artifact: "skills/references/reporting-contract.md"
    artifact_version: "1.2.0"
    required_status: "active"
supersedes: []
evidence:
  - "Extracted from sf-audit-design SKILL.md during compact-skill pilot."
next_review: "2026-06-16"
next_step: "/sf-verify Compact ShipFlow Skill Instructions"
---

# sf-audit-design Gates

## Pre-check

If branding context is missing, keep auditing but add a warning that brand-coherence scoring is confidence-limited.

## Metadata Confidence Gate

When business/branding/guidelines docs exist, read their metadata fields:

- `artifact_version`
- `status`
- `updated`
- `confidence`
- `next_review`

If metadata is missing/stale/low-confidence, cap confidence and flag proof gaps before assigning top grades.

## Mode Contracts

### DEEP MODE

Use deep mode for large projects or when audit-grade proof by domain is required.

Execution:

1. Launch three specialist missions in parallel:
   - `sf-audit-design-tokens`
   - `sf-audit-components`
   - `sf-audit-a11y`
2. Each mission is read-only and returns structured findings, subscores, severity counts, top fixes, proof gaps.
3. Consolidate one unified deep report.
4. Deep-mode overall score is the **worst** domain score.
5. Update tracking files after synthesis.

### GLOBAL MODE

Audit multiple workspace projects:

1. Read `${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}/PROJECTS.md`.
2. Select applicable design projects.
3. Run one read-only audit mission per selected project.
4. Consolidate cross-project patterns + severity rollup + top improvements.
5. Update global and local tracking where applicable.

### PAGE MODE

Audit one page and imported layout/components/styles. Use checklist reference and provide scoped fixes or bounded recommendations.

### PROJECT MODE

Run full project audit when no explicit mode is selected. Include inventory, outdated patterns, page scans, cross-page consistency, priority improvements, and scorecard.

## Tracking Protocol

Before writing `AUDIT_LOG.md` or `TASKS.md`:

1. Re-read target file from disk.
2. Apply minimal row/subsection edit only.
3. If anchors moved and remain ambiguous after re-read, stop and ask user.

Use this for:

- local `./AUDIT_LOG.md`
- global `${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}/AUDIT_LOG.md`
- local `TASKS.md`
- global `${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}/TASKS.md`

## Reporting Contract

Minimum report sections:

- scope
- business metadata versions and proof gaps
- top findings by severity (file:line + why)
- priority improvements (bounded effort)
- confidence / missing context
- chantier potential

Use concise user mode by default. Keep full matrices for explicit agent/handoff mode.
