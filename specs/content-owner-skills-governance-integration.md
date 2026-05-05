---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "ShipFlow"
created: "2026-05-04"
created_at: "2026-05-04 23:24:03 UTC"
updated: "2026-05-04"
updated_at: "2026-05-04 23:30:03 UTC"
status: ready
source_skill: sf-spec
source_model: "GPT-5 Codex"
scope: skill-maintenance
owner: Diane
user_story: "En tant qu'utilisatrice ShipFlow qui route le contenu via sf-content et sf-repurpose, je veux que les skills de redaction, enrichissement, copy, copywriting et SEO appliquent toutes la gouvernance editoriale et technique, afin que les mises a jour de contenu, claims, pages publiques et docs ne divergent pas des contrats ShipFlow."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/sf-enrich/SKILL.md
  - skills/sf-redact/SKILL.md
  - skills/sf-audit-copy/SKILL.md
  - skills/sf-audit-copywriting/SKILL.md
  - skills/sf-audit-seo/SKILL.md
  - skills/references/editorial-content-corpus.md
  - skills/references/technical-docs-corpus.md
  - docs/editorial/
  - docs/technical/code-docs-map.md
  - CONTENT_MAP.md
  - site/src/content/skills/
  - skills/REFRESH_LOG.md
depends_on:
  - artifact: "CONTENT_MAP.md"
    artifact_version: "0.6.0"
    required_status: draft
  - artifact: "docs/editorial/README.md"
    artifact_version: "1.0.0"
    required_status: reviewed
  - artifact: "docs/editorial/editorial-update-gate.md"
    artifact_version: "1.0.0"
    required_status: reviewed
  - artifact: "skills/references/editorial-content-corpus.md"
    artifact_version: "1.1.0"
    required_status: active
  - artifact: "skills/references/technical-docs-corpus.md"
    artifact_version: "1.1.0"
    required_status: active
  - artifact: "docs/technical/code-docs-map.md"
    artifact_version: "1.0.0"
    required_status: reviewed
supersedes: []
evidence:
  - "User request 2026-05-04: improve the skills with incomplete integration after the governance audit."
  - "Read-only audit found sf-enrich, sf-redact, sf-audit-copy, sf-audit-copywriting, and sf-audit-seo partially or insufficiently integrated with editorial and technical governance."
  - "docs/editorial/README.md defines Editorial Update Plan and Claim Impact Plan outputs."
  - "docs/technical/code-docs-map.md and skills/references/technical-docs-corpus.md define Documentation Update Plan expectations for mapped code/content changes."
next_step: "/sf-skill-build improve incomplete content-owner skill governance integration"
---

# Spec: Content Owner Skills Governance Integration

## Title

Content Owner Skills Governance Integration

## Status

Ready.

The target skills and missing integration points are known from the immediately preceding audit. No naming, placement, public promise, data, or security decision remains open.

## User Story

En tant qu'utilisatrice ShipFlow qui route le contenu via sf-content et sf-repurpose, je veux que les skills de redaction, enrichissement, copy, copywriting et SEO appliquent toutes la gouvernance editoriale et technique, afin que les mises a jour de contenu, claims, pages publiques et docs ne divergent pas des contrats ShipFlow.

## Minimal Behavior Contract

The five owner skills must load the editorial governance corpus before changing, judging, or recommending public content, and load the technical docs corpus before changes that affect mapped code, runtime content, site files, schemas, skill contracts, or documentation. Their final reports must include an `Editorial Update Plan` or explicit no-impact justification when public content is in scope, a `Claim Impact Plan` when sensitive public claims are affected, and a `Documentation Update Plan` or no-impact justification when mapped technical/docs surfaces are touched.

## Success Behavior

- Preconditions: `CONTENT_MAP.md`, `docs/editorial/`, `skills/references/editorial-content-corpus.md`, `skills/references/technical-docs-corpus.md`, and `docs/technical/code-docs-map.md` exist.
- Trigger: User runs one of `sf-enrich`, `sf-redact`, `sf-audit-copy`, `sf-audit-copywriting`, or `sf-audit-seo` on public content, runtime content, docs, or site files.
- User/operator result: The skill follows the same governance loading order and reports standard update plans instead of ad hoc governance notes.
- System effect: Skill contracts and public skill docs are aligned; no runtime schema is changed.
- Success proof: Runtime sync checks, skill budget audit, metadata lint, targeted rg checks, and site build pass.
- Silent success: Not allowed; report must show the governance plans or explicit no-impact status.

## Error Behavior

- If a public claim lacks evidence, the skill reports `needs proof`, `claim mismatch`, or `blocked`.
- If no declared blog/article surface exists, the skill reports `surface missing: blog`.
- If runtime content schema rejects governance metadata, the skill preserves the schema and reports context versions outside runtime frontmatter.
- If a mapped technical surface changes, the skill produces a `Documentation Update Plan` or no-impact justification.
- If validation fails, stop before closure or ship.

## Scope In

- Update `skills/sf-enrich/SKILL.md`.
- Update `skills/sf-redact/SKILL.md`.
- Update `skills/sf-audit-copy/SKILL.md`.
- Update `skills/sf-audit-copywriting/SKILL.md`.
- Update `skills/sf-audit-seo/SKILL.md`.
- Update public skill pages only where the visible promise changes.
- Update `skills/REFRESH_LOG.md`.

## Scope Out

- Creating a new `sf-copy` skill.
- Rewriting any skill from scratch.
- Creating a blog, newsletter, social, CMS, or article surface.
- Changing `site/src/content.config.ts`.
- Committing or pushing.

## Constraints

- Preserve existing skill invocation names.
- Keep changes additive and close to governance/loading/reporting sections.
- Preserve runtime content schemas.
- Do not strengthen public claims beyond evidence.
- Preserve unrelated dirty worktree changes, including `TASKS.md`.

## Dependencies

- Runtime: local skill files and Astro public skill pages.
- Document contracts: listed in frontmatter `depends_on`.
- Metadata gaps: None for the governance references used here.

## Invariants

- `CONTENT_MAP.md` remains the canonical content routing map.
- `docs/editorial/` governs public content impact, page intent, claim boundaries, and schema risk.
- `docs/technical/code-docs-map.md` governs mapped technical documentation impact.
- Owner skills keep their domain boundaries; `sf-content` and `sf-repurpose` route into them, but do not duplicate their internals.

## Links & Consequences

- Upstream systems: `sf-content`, `sf-repurpose`, content map, editorial corpus, technical docs corpus.
- Downstream systems: public content edits, docs updates, SEO/copy reports, public skill pages, build validation.
- Cross-cutting checks: public claims, docs drift, runtime schema preservation, SEO/AEO claims, skill budget.

## Documentation Coherence

- Public skill pages should mention governance outputs only where the operator-visible expectation changes.
- No change needed to `docs/technical/code-docs-map.md`; it already maps `skills/**/SKILL.md`, `site/**`, and `CONTENT_MAP.md`.
- No change needed to `docs/editorial/README.md`; it already defines the target output plans.

## Implementation Tasks

- [x] Task 1: Add shared editorial and technical governance contract language to the five target skills.
  - File: `skills/sf-enrich/SKILL.md`, `skills/sf-redact/SKILL.md`, `skills/sf-audit-copy/SKILL.md`, `skills/sf-audit-copywriting/SKILL.md`, `skills/sf-audit-seo/SKILL.md`
  - Action: Add or strengthen corpus loading, standard plan outputs, and stop conditions.
  - User story link: Ensures each owner skill follows the same governance contracts.
  - Depends on: None
  - Validate with: `rg` checks and `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
  - Notes: Keep edits additive and bounded.
- [x] Task 2: Update public skill pages if the public promise changes.
  - File: `site/src/content/skills/*.md`
  - Action: Add concise governance-output language where useful.
  - User story link: Keeps public pages aligned with internal skill behavior.
  - Depends on: Task 1
  - Validate with: `npm --prefix site run build`
  - Notes: Do not add ShipFlow governance frontmatter.
- [x] Task 3: Record the refresh.
  - File: `skills/REFRESH_LOG.md`
  - Action: Add a dated note for the five-skill governance integration.
  - User story link: Preserves skill maintenance history.
  - Depends on: Task 1
  - Validate with: `git diff --check`
  - Notes: Keep the note compact.

## Acceptance Criteria

- [x] AC 1: Each target skill names `editorial-content-corpus.md` and the standard `Editorial Update Plan` / `Claim Impact Plan` outputs.
- [x] AC 2: Each target skill names `technical-docs-corpus.md` or `docs/technical/code-docs-map.md` and standard `Documentation Update Plan` output/no-impact justification.
- [x] AC 3: `sf-audit-copywriting` and `sf-audit-seo` load the editorial corpus before public-content scoring.
- [x] AC 4: Content-writing skills preserve missing blog and runtime schema stop conditions.
- [x] AC 5: Validation commands pass or blockers are reported.

## Test Strategy

- Unit: None, because this is skill contract text.
- Integration: `tools/shipflow_sync_skills.sh --check --skill <name>` for each changed skill.
- Manual: targeted `rg` checks for governance terms and final diff review.

## Risks

- Security impact: yes, because public claims can include security, privacy, compliance, AI, speed, savings, and availability claims; mitigated by claim-register and proof-gap requirements.
- Product/data/performance risk: low runtime risk because no app behavior or schema changes are intended.

## Execution Notes

- Read first: `CONTENT_MAP.md`, `docs/editorial/README.md`, `docs/editorial/editorial-update-gate.md`, `skills/references/editorial-content-corpus.md`, `skills/references/technical-docs-corpus.md`, and the five target skills.
- Validate with: runtime sync checks, skill budget audit, metadata lint for this spec and references, targeted `rg`, `git diff --check`, and site build if public pages change.
- Stop conditions: budget hard failure, metadata lint failure, build failure, ambiguous dirty scope, or any change that would require creating a new content surface.

## Open Questions

None.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-05-04 23:24:03 UTC | sf-spec | GPT-5 Codex | Created ready spec for five content-owner skills governance integration from explicit user request and prior audit evidence. | ready | /sf-skill-build improve incomplete integrations |
| 2026-05-04 23:24:03 UTC | sf-ready | GPT-5 Codex | Checked readiness inline: target files, governance references, acceptance criteria, validation, and stop conditions are explicit. | ready | /sf-skill-build improve incomplete integrations |
| 2026-05-04 23:30:03 UTC | sf-skill-build | GPT-5 Codex | Added editorial and technical governance output contracts to five owner skills, aligned public skill pages, and updated refresh log. | implemented | validation complete; no commit/push |
| 2026-05-04 23:30:03 UTC | sf-verify | GPT-5 Codex | Verified runtime sync, metadata lint, skill budget audit, targeted rg checks, diff check, placeholder scan review, and Astro build. | verified | user review or ship route without unrelated TASKS.md |

## Current Chantier Flow

- `sf-spec`: done, ready spec created.
- `sf-ready`: done, inline readiness accepted from explicit scope and prior audit.
- `sf-start`: done via sf-skill-build implementation.
- `sf-verify`: done, validation passed.
- `sf-end`: not launched.
- `sf-ship`: not launched; commit/push explicitly out of scope for this run.

Next step: user review, then bounded ship if desired.
