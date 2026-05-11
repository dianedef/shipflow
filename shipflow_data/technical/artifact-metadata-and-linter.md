---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "1.2.0"
project: ShipFlow
created: "2026-05-01"
updated: "2026-05-11"
status: reviewed
source_skill: sf-start
scope: artifact-metadata-and-linter
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - templates/artifacts/
  - tools/shipflow_metadata_lint.py
  - shipflow-metadata-migration-guide.md
  - shipflow_data/editorial/
depends_on:
  - artifact: "shipflow-metadata-migration-guide.md"
    artifact_version: "0.2.0"
    required_status: draft
supersedes: []
evidence:
  - "Metadata migration guide, templates, and linter source."
  - "editorial_content_context added for shipflow_data/editorial governance artifacts."
  - "competitive_intelligence and affiliate_program_registry added for project business registries."
next_review: "2026-06-01"
next_step: "/sf-docs technical audit metadata"
---

# Artifact Metadata And Linter

## Purpose

This doc covers ShipFlow artifact frontmatter, templates, and `tools/shipflow_metadata_lint.py`. Read it before changing artifact schemas, adding a template, or changing metadata validation behavior.

## Owned Files

| Path | Role | Edit notes |
| --- | --- | --- |
| `templates/artifacts/*.md` | Artifact templates | Keep frontmatter fields compatible with linter |
| `templates/artifacts/technical_module_context.md` | Template for subsystem technical docs | Official linted artifact type |
| `templates/artifacts/editorial_content_context.md` | Template for editorial governance docs | Official linted artifact type for public-content governance |
| `templates/artifacts/competitive_intelligence.md` | Template for project competitors, alternatives, inspirations, and anti-patterns | Official linted artifact type for business research registries |
| `templates/artifacts/affiliate_program_registry.md` | Template for affiliate, referral, partner, sponsorship, and disclosure tracking | Official linted artifact type; never store secrets in generated files |
| `tools/shipflow_metadata_lint.py` | Dependency-free frontmatter validator | Keep standard-library only |
| `shipflow-metadata-migration-guide.md` | Human procedure for metadata adoption | Update when schema behavior changes |

## Entrypoints

- `python3 tools/shipflow_metadata_lint.py`: default active artifact lint.
- `python3 tools/shipflow_metadata_lint.py <paths>`: narrow lint target.
- `python3 tools/shipflow_metadata_lint.py --all-markdown <paths>`: strict mode for all Markdown in scope.

## Invariants

- The linter uses Python standard library only.
- Active ShipFlow artifacts carry `metadata_schema_version`, `artifact_version`, `status`, `source_skill`, `scope`, `risk_level`, `security_impact`, `docs_impact`, `depends_on`, and related governance fields.
- Reviewed, ready, or active artifacts should not stay at `0.x` versions.
- Operational trackers such as `TASKS.md`, `AUDIT_LOG.md`, `PROJECTS.md`, `TEST_LOG.md`, and `BUGS.md` are not decision artifacts.
- `technical_module_context` is an official linted artifact type in v1.
- `editorial_content_context` is an official linted artifact type for `shipflow_data/editorial/` governance docs and requires content surfaces, claim register, page intent, and next review metadata.
- `competitive_intelligence` is an official linted artifact type for project-level competitor, alternative, inspiration, and anti-pattern registries.
- `affiliate_program_registry` is an official linted artifact type for affiliate and partner program registries; it must keep secrets out of Markdown and include disclosure and secrets policies.
- Optional official artifact paths are linted when present, including when passed explicitly by absolute path; absence of `project-competitors-and-inspirations.md` or `affiliate-programs.md` is compliant.
- Legacy root ShipFlow artifacts such as `BUSINESS.md`, `PRODUCT.md`, `BRANDING.md`, `GTM.md`, `ARCHITECTURE.md`, `CONTENT_MAP.md`, `CONTEXT.md`, `CONTEXT-FUNCTION-TREE.md`, `GUIDELINES.md`, `INSPIRATION.md`, and `AFFILIATES.md` are migration sources only. The linter must fail them at project root and point to their canonical `shipflow_data/` destination.

## Failure Modes

- A new template without linter support can create uncheckable artifacts.
- Over-expanding default lint targets can break runtime content with framework-specific frontmatter.
- Missing `depends_on` versions can hide stale contract usage.
- Parsing must stay conservative because the linter is a lightweight frontmatter checker, not a full YAML interpreter.

## Security Notes

- Metadata and docs must not contain secrets or sensitive logs.
- Linter changes should not follow external paths or perform network access.
- Error output should identify files and fields without leaking file contents.

## Validation

```bash
python3 tools/shipflow_metadata_lint.py --help
python3 tools/shipflow_metadata_lint.py shipflow_data/technical templates/artifacts/technical_module_context.md skills/references/technical-docs-corpus.md
python3 tools/shipflow_metadata_lint.py shipflow_data/editorial templates/artifacts/editorial_content_context.md skills/references/editorial-content-corpus.md
python3 tools/shipflow_metadata_lint.py shipflow_data/business templates/artifacts/competitive_intelligence.md templates/artifacts/affiliate_program_registry.md
```

## Reader Checklist

- Template changed -> run linter on that template and update this doc if fields changed.
- New governance artifact type changed -> update `ARTIFACT_REQUIRED`, its template, and the relevant governance docs.
- Linter artifact requirements changed -> update migration guide, workflow docs, and `sf-docs`.
- Metadata parse behavior changed -> include a narrow regression check with representative artifacts.

## Maintenance Rule

Update this doc when metadata fields, artifact types, default lint targets, template contracts, or linter validation rules change.
