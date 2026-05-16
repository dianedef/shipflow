---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipFlow
created: "2026-05-16"
updated: "2026-05-16"
status: draft
source_skill: sf-start
scope: sf-docs-core-governance
owner: unknown
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/sf-docs/SKILL.md
  - shipflow_data/technical/
  - shipflow_data/editorial/
  - shipflow_data/business/
  - shipflow-metadata-migration-guide.md
depends_on:
  - artifact: "skills/references/technical-docs-corpus.md"
    artifact_version: "1.1.0"
    required_status: "active"
  - artifact: "skills/references/editorial-content-corpus.md"
    artifact_version: "1.1.0"
    required_status: "active"
supersedes: []
evidence:
  - "Extracted from sf-docs SKILL.md during compact-skill pilot."
next_review: "2026-06-16"
next_step: "/sf-verify Compact ShipFlow Skill Instructions"
---

# sf-docs Core Governance

## Documentation Coherence Doctrine

Documentation is an active product surface. When behavior changes, check impacted docs (README, guides, onboarding, API docs, FAQ, pricing, support copy, examples, screenshots, `.env.example`, changelog).

Never document capabilities that are not proven by code, specs, or verified behavior.

Use explicit behavior labels when relevant: `implemented`, `verified`, `assumed`, `deprecated`, `removed`.

Treat stale docs as product risk, especially for security, permissions, billing, migration, public API, destructive actions, or sensitive-data workflows.

## Governance Corpus Ownership

`sf-docs` is the owner for project-local governance corpus creation, update, and audit.

- `sf-docs technical` owns technical governance layer bootstrapping/auditing.
- `sf-docs editorial` owns editorial/public-content governance bootstrapping/auditing.
- `sf-docs update` aligns docs drift and can route to technical/editorial bootstrap or audit.
- `sf-docs migrate-layout` owns legacy root ShipFlow artifact migration to canonical `shipflow_data/` paths.
- `sf-docs metadata` owns frontmatter migration/compliance for active ShipFlow artifacts.

`AGENT.md` is canonical. `AGENTS.md` must be a compatibility symlink only.

## Metadata And Artifact Rules

ShipFlow-generated governance artifacts require frontmatter with versioned contracts. Keep `metadata_schema_version: "1.0"` unless schema changes.

Use semantic versioning for `artifact_version`:

- `0.x.y` draft/inferred/migration state
- `1.0.0+` reviewed contract state
- patch: non-decision corrections
- minor: compatible decision updates
- major: decision-breaking changes

When bumping artifact version:

- update `updated`
- keep `created`
- keep metadata coherence (`status`, `confidence`, `risk_level`, `evidence`, `next_review`, `depends_on`, `supersedes`)

## Canonical Artifact Families

Preferred governance locations:

- `shipflow_data/business/*`
- `shipflow_data/technical/*`
- `shipflow_data/editorial/*`
- `shipflow_data/workflow/specs/*`

Legacy root files (`BUSINESS.md`, `PRODUCT.md`, `BRANDING.md`, `GTM.md`, `ARCHITECTURE.md`, `CONTENT_MAP.md`, `CONTEXT.md`, `CONTEXT-FUNCTION-TREE.md`, `GUIDELINES.md`, root `specs/`) are migration sources.

## Tracker Exception Rule

Do not enforce frontmatter on operational trackers:

- `shipflow_data/workflow/TASKS.md`
- `shipflow_data/workflow/AUDIT_LOG.md`
- `${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}/PROJECTS.md`
- `TEST_LOG.md`
- `BUGS.md`

If a tracker contains durable decision content, extract that decision into a versioned ShipFlow artifact and keep the tracker as pointer/task.

## Bug Workflow Documentation Rule

Documentation must preserve the professional bug model:

- `bugs/BUG-ID.md` is source of truth
- `BUGS.md` is optional/generated triage view
- `TEST_LOG.md` is compact QA tracker
- heavy proof belongs in `test-evidence/BUG-ID/` with redaction

## Language Doctrine

- Internal ShipFlow contracts stay in English.
- User-facing content/reporting stays in active user/project language.
- Stable machine labels can stay in English.
- For French user-facing text, accents are mandatory unless the token is an identifier/command/ASCII-only format.

## Security And Redaction

- Never expose secrets, tokens, private keys, cookies, or sensitive private logs.
- Never strengthen public claims beyond verified product/system truth.
- Never mutate runtime content schemas (`site/src/content/**` etc.) in ways that break app parsers.

## Validation Minimum

Always run metadata lint on changed frontmatter artifacts and add focused path checks for migrated canonical references.
