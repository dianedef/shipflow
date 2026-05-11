---
artifact: decision_record
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "shipflow"
created: "2026-05-11"
updated: "2026-05-11"
status: reviewed
source_skill: sf-docs
scope: "project-governance-layout"
owner: "Diane"
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
decision: "ShipFlow governance artifacts must live under project-local shipflow_data/ subdirectories, not as root Markdown files."
rationale: "Root ShipFlow docs created confusion across projects and made compliance ambiguous. A strict layout makes artifacts discoverable, lintable, migratable, and easier to explain publicly."
consequences: "Legacy root governance files become migration sources only. Skills, linter, docs, and the public site must route to shipflow_data/ canonical paths."
evidence:
  - "User clarified on 2026-05-11 that root ShipFlow Markdown artifacts are not compliant."
  - "Local scan found root legacy governance files in shipflow_app, tubeflow_expo, socialflow, gocharbon, and other project folders."
depends_on:
  - artifact: "shipflow_data/technical/architecture.md"
    artifact_version: "1.1.0"
    required_status: reviewed
  - artifact: "shipflow_data/technical/guidelines.md"
    artifact_version: "1.4.0"
    required_status: reviewed
supersedes: []
next_step: "/sf-docs migrate-layout"
---

# Project Governance Layout

## Decision

Project roots should keep only files that are true entrypoints for humans or external tools:

- `README.md`
- `AGENT.md`
- `AGENTS.md` as a symlink to `AGENT.md`
- `CLAUDE.md` when the project explicitly uses it as repository guidance
- `CHANGELOG.md` when maintained as a public or project changelog

ShipFlow governance artifacts must live under project-local `shipflow_data/`.

## Canonical Layout

```text
shipflow_data/
  business/
    business.md
    product.md
    branding.md
    gtm.md
    project-competitors-and-inspirations.md
    affiliate-programs.md

  technical/
    README.md
    context.md
    context-function-tree.md
    architecture.md
    guidelines.md
    code-docs-map.md
    decisions/

  editorial/
    README.md
    content-map.md
    public-surface-map.md
    page-intent-map.md
    claim-register.md
    editorial-update-gate.md
    astro-content-schema-policy.md
    blog-and-article-surface-policy.md

  workflow/
    specs/
    bugs/
    research/
    reviews/
    audits/
    verification/
    test-evidence/
    TASKS.md
    AUDIT_LOG.md

  archives/
```

Optional registries are compliant when absent. If present, they must live at the canonical path and pass metadata lint.

## Legacy Root Mapping

| Legacy root file | Canonical destination |
| --- | --- |
| `BUSINESS.md` | `shipflow_data/business/business.md` |
| `PRODUCT.md` | `shipflow_data/business/product.md` |
| `BRANDING.md` | `shipflow_data/business/branding.md` |
| `GTM.md` | `shipflow_data/business/gtm.md` |
| `INSPIRATION.md` | `shipflow_data/business/project-competitors-and-inspirations.md` |
| `AFFILIATES.md` | `shipflow_data/business/affiliate-programs.md` |
| `CONTEXT.md` | `shipflow_data/technical/context.md` |
| `CONTEXT-FUNCTION-TREE.md` | `shipflow_data/technical/context-function-tree.md` |
| `ARCHITECTURE.md` | `shipflow_data/technical/architecture.md` |
| `GUIDELINES.md` | `shipflow_data/technical/guidelines.md` |
| `CONTENT_MAP.md` | `shipflow_data/editorial/content-map.md` |
| `TASKS.md` | `shipflow_data/workflow/TASKS.md` |
| `AUDIT_LOG.md` | `shipflow_data/workflow/AUDIT_LOG.md` |
| `specs/*.md` | `shipflow_data/workflow/specs/*.md` |
| `bugs/*.md` | `shipflow_data/workflow/bugs/*.md` |
| `research/*.md` | `shipflow_data/workflow/research/*.md` |
| `reviews/*.md` | `shipflow_data/workflow/reviews/*.md` |
| `audits/*.md` | `shipflow_data/workflow/audits/*.md` |

## Skill Mapping

| Skill | Responsibility |
| --- | --- |
| `sf-init` | Create new project governance files directly in `shipflow_data/`; never create legacy root governance files. |
| `sf-docs update` | Audit canonical docs and report root legacy artifacts as layout violations. |
| `sf-docs migrate-layout` | Move root legacy artifacts into `shipflow_data/`, resolve collisions, update references, then run metadata lint. |
| `sf-docs metadata` | Validate metadata only after layout classification; root legacy governance files are not compliant even with valid frontmatter. |
| `sf-start` / `sf-verify` | Prefer canonical `shipflow_data/` dependencies; treat root references in old specs as legacy context and flag migration debt. |
| `sf-content` / `sf-repurpose` | Read `shipflow_data/editorial/content-map.md` and optional business registries; recommend `sf-docs migrate-layout` when public content depends on root legacy docs. |
| `sf-market-study` / `sf-audit-gtm` | Read and update business/GTM/registry artifacts only at canonical `shipflow_data/business/` paths. |
| `sf-ship` / `sf-end` | Do not close layout-changing work until linter and docs references agree on canonical paths. |

## Compliance Rules

- A root legacy governance file is non-compliant even if it has valid ShipFlow frontmatter.
- Fallback reads are allowed only to support migration or old-spec verification.
- Duplicate root and `shipflow_data/` copies are not allowed as parallel sources of truth.
- Operational trackers are not decision contracts and do not need ShipFlow frontmatter, but their project-local compliant location is `shipflow_data/workflow/`.
- Root `TASKS.md` and `AUDIT_LOG.md` are legacy project tracker locations unless an external project tool explicitly requires them.
- Runtime content must keep its application schema and must not be forced into ShipFlow metadata.

## Migration Gate

Before moving files, `sf-docs migrate-layout` must:

1. Inventory root legacy artifacts.
2. Detect destination collisions.
3. Preserve user changes and avoid overwriting existing canonical files.
4. Update internal references from root names to canonical paths where safe.
5. Run the metadata linter on the project.
6. Report unresolved collisions separately from completed moves.

## Consequences

This decision creates a stricter compliance model. Existing projects with root `BUSINESS.md`, `CONTENT_MAP.md`, `CONTEXT.md`, `TASKS.md`, `AUDIT_LOG.md`, or similar files must be migrated before they can be considered layout-compliant.
