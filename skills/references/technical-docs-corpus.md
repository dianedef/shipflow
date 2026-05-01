---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipFlow
created: "2026-05-01"
updated: "2026-05-01"
status: active
source_skill: sf-start
scope: technical-docs-corpus
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - docs/technical/
  - docs/technical/code-docs-map.md
  - templates/artifacts/technical_module_context.md
  - skills/sf-docs/SKILL.md
depends_on:
  - artifact: "docs/technical/code-docs-map.md"
    artifact_version: "1.0.0"
    required_status: reviewed
supersedes: []
evidence:
  - "Ready spec requires a skill-facing reference for technical docs loading."
next_review: "2026-06-01"
next_step: "/sf-docs technical audit"
---

# Technical Docs Corpus

## Purpose

This reference tells ShipFlow skills how to use the internal `docs/technical/` layer without loading the whole repository or turning agent entry files into mega-docs.

## Loading Rule

1. Read `docs/technical/code-docs-map.md` first for any code-changing task.
2. Match changed or target paths to the map.
3. Load only the primary technical doc and necessary secondary docs.
4. Produce a `Documentation Update Plan` after every code-changing execution wave and again during end verification.
5. Keep shared docs sequential unless the ready spec assigns disjoint ownership.

## `sf-docs` Technical Mode Contract

`sf-docs technical` or `sf-docs technical audit` should:

- verify that every major code area in `code-docs-map.md` has a primary technical doc or explicit non-coverage reason
- scaffold missing subsystem docs from `templates/artifacts/technical_module_context.md`
- check stale path references, missing validations, missing `Maintenance Rule` sections, and missing Reader triggers
- verify that `technical_module_context` files pass `tools/shipflow_metadata_lint.py`
- fail or report a blocking gap when a mapped code area changed but no impacted doc appears in the `Documentation Update Plan`

## Documentation Update Plan

Use the format defined in `docs/technical/code-docs-map.md`. The owner role is usually `executor` for the subsystem doc and `integrator` for shared files such as `code-docs-map.md`, `AGENT.md`, `CONTEXT.md`, `GUIDELINES.md`, and `shipflow-spec-driven-workflow.md`.

## Safety Rules

- The Reader diagnoses impact; it does not silently edit docs unless explicitly assigned.
- `docs/technical/` is internal-only in v1.
- Do not copy secrets, tokens, private URLs, raw logs, cookies, or credentials into technical docs.
- Do not add per-file `last_verified_against` fields in v1.
- If `AGENTS.md` exists, it must be a symlink to `AGENT.md`.

## Maintenance Rule

Update this reference when the technical docs map, template, Reader plan format, or `sf-docs` technical mode contract changes.
