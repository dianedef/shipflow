---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipFlow
created: "2026-05-16"
updated: "2026-05-16"
status: draft
source_skill: sf-start
scope: sf-docs-mode-playbooks
owner: unknown
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/sf-docs/SKILL.md
  - shipflow_data/technical/
  - shipflow_data/editorial/
  - shipflow_data/workflow/specs/
depends_on:
  - artifact: "skills/sf-docs/references/core-governance.md"
    artifact_version: "0.1.0"
    required_status: "draft"
supersedes: []
evidence:
  - "Extracted from sf-docs SKILL.md during compact-skill pilot."
next_review: "2026-06-16"
next_step: "/sf-verify Compact ShipFlow Skill Instructions"
---

# sf-docs Mode Playbooks

## FILE MODE

1. Read target file and one import level.
2. Document non-obvious behavior (why, edge cases, public contract).
3. Follow local style (JSDoc/TSDoc/docstrings/component header comments).
4. Avoid documenting obvious code.

## TECHNICAL DOCS MODE

Load `skills/references/technical-docs-corpus.md`, then read project `shipflow_data/technical/code-docs-map.md` (fallback legacy `docs/technical/code-docs-map.md`).

Use mode variants:

- bootstrap: missing technical layer
- audit: verify layer coherency
- update-plan: changed code paths require documentation update plan

Minimum checks:

- mapped code areas have primary docs or explicit non-coverage
- technical docs contain `Purpose`, `Owned Files`, `Entrypoints`, `Invariants`, `Validation`, `Reader Checklist`, `Maintenance Rule`
- `code-docs-map.md` includes path patterns, validations, triggers

Output update plans with fields:

- code changed
- subsystem
- primary doc
- secondary docs
- action (`none|review|update|create`)
- priority
- reason
- owner role
- parallel-safe
- notes

## EDITORIAL GOVERNANCE MODE

Load `skills/references/editorial-content-corpus.md`, then project editorial governance docs (`shipflow_data/editorial/*` fallback legacy `docs/editorial/*`).

Use mode variants:

- bootstrap: missing editorial governance with public surfaces detected
- audit: verify claims/page intents/content map/gates
- update-plan: changed public content requires editorial update plan

Must check:

- content-map coverage for public surfaces
- claim register for sensitive claims and proof status
- page intent map coherence
- editorial gate expectations
- runtime content schema compatibility

If no public/editorial surfaces are detected, report `skipped - no editorial surfaces detected`.

## README MODE

Generate or update README using project evidence:

- one-line project description
- features
- quick start
- structure
- stack
- env vars
- scripts
- contributing

If README exists and user preference is unclear, ask merge/replace/skip.

## API MODE

Document detected API endpoints:

- method/path
- auth expectations
- request/response schemas
- status codes
- usage examples

Prefer output location aligned with project (`docs/API.md` or local API docs pattern).

## COMPONENTS MODE

Document component contracts:

- purpose
- props/slots with real types
- usage examples
- dependencies

Prefer project-native output (`docs/COMPONENTS.md` or local pattern).

## AUDIT MODE

Run documentation coherency audit:

- inventory docs and doc-like surfaces
- compare code vs docs for drift and missing coverage
- validate metadata on applicable ShipFlow artifacts
- validate professional bug model documentation
- validate language doctrine
- validate freshness of context docs and dependency versions when applicable

Prioritize user-risk docs (install, auth, billing, migration, API, troubleshooting).

## UPDATE MODE

Run silent audit first, then apply selected remediations.

Required gates:

- preserve governance corpus ownership boundaries
- only run skill-budget audit when scope touches skills/discovery metadata
- persist conversation-derived durable decisions to proper docs surfaces
- keep bug model documentation consistent
- create/update canonical business/product/branding/architecture/gtm/content-map/guidelines docs when missing and justified

Priority buckets:

- P0 dangerous drift
- P1 conventions
- P2 stale docs
- P3 missing coverage

## LAYOUT MIGRATION MODE

Move root legacy ShipFlow artifacts into canonical `shipflow_data/` paths without destructive overwrite.

Rules:

- classify each source as moveable/collision/external-root-ok/tracker/runtime-content
- prefer `git mv` inside git repos
- do not overwrite collisions silently
- run metadata lint and legacy path grep checks

## METADATA MODE

Frontmatter migration is additive, not content rewrite.

Rules:

- load migration guide + metadata linter when available
- define scope before edits
- classify candidates (`migrate`, `already compliant`, `runtime content`, `tracker excluded`, `archive excluded`, `ambiguous`)
- preserve body unchanged
- infer only obvious metadata values, otherwise `unknown` and lower confidence
- lint changed scope

## AUTO MODE

Detect likely gaps and ask user what to document next (README/API/components/env/changelog/missing docs).

## Final Reporting Templates

Keep user-facing reports concise by default. Include only sections that affect next action:

- outcome
- evidence
- limits/gaps
- next step
- chantier block when relevant

For blocked or explicit handoff runs, switch to detailed `report=agent` format.
