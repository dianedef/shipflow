---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "ShipFlow"
created: "2026-05-04"
created_at: "2026-05-04 11:00:48 UTC"
updated: "2026-05-04"
updated_at: "2026-05-04 17:03:03 UTC"
status: ready
source_skill: sf-spec
source_model: "GPT-5 Codex"
scope: skill-maintenance
owner: Diane
confidence: high
user_story: "En tant qu'utilisatrice ShipFlow qui repurpose des conversations, je veux que sf-repurpose reste read-only, analyse les contenus existants en documentation interne et en publication publique, puis route les suites d'ecriture vers les owner skills, afin de garder une analyse rapide et parallele sans melanger reflexion et edition."
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/sf-repurpose/SKILL.md
  - skills/sf-repurpose/references/output-pack.md
  - skills/references/master-delegation-semantics.md
  - site/src/content/skills/sf-repurpose.md
  - skills/REFRESH_LOG.md
  - CONTENT_MAP.md
  - docs/editorial/
depends_on:
  - artifact: "CONTENT_MAP.md"
    artifact_version: "0.5.0"
    required_status: draft
  - artifact: "skills/references/editorial-content-corpus.md"
    artifact_version: "1.1.0"
    required_status: active
supersedes: []
evidence:
  - "User request 2026-05-04: sf-repurpose should include creation ideas and also analyze existing internal documentation and public publication surfaces."
  - "User wants the skill to find where conversation discoveries, explanations, demonstrations, and audience misconceptions can improve existing content."
  - "User review 2026-05-04: existing-content placement is read-heavy and should use parallel read-only subagents when available."
  - "User decision 2026-05-04: sf-repurpose should be read-only for content/docs and route writing to owner skills."
  - "User decision 2026-05-04: no sf-copy skill exists now; use current owner skills for docs, enrichment, redact, copy audits, and SEO."
  - "Existing sf-repurpose already owns source-faithful repurposing, action-first article ideas, content-map routing, and editorial governance checks."
next_step: "User review before sf-end"
---

# Spec: sf-repurpose Existing Content Placement Opportunities

## Status

Ready.

Placement decision: update the existing `sf-repurpose` skill. This is a report-shape and placement-analysis improvement inside the existing repurposing workflow, not a new skill and not a replacement for `sf-enrich`.

## User Story

En tant qu'utilisatrice ShipFlow qui repurpose des conversations, je veux que `sf-repurpose` reste read-only, analyse les contenus existants en documentation interne et en publication publique, puis route les suites d'ecriture vers les owner skills, afin de garder une analyse rapide et parallele sans melanger reflexion et edition.

## Behavior Contract

`sf-repurpose` must not only propose net-new content. For each source or conversation with useful signal, it must evaluate existing internal docs and public content surfaces and report where the insight should be added, demonstrated, clarified, or intentionally skipped.

The required output section is `Existing Content Opportunities`, split into `Internal Docs` and `Public Content`. Each opportunity includes the surface/file, placement idea, audience learning moment, source proof, content move, priority, and next step.

`sf-repurpose` is read-only for project content and docs. It may trace its run into one active spec, but it must not edit content/docs/site files. When writing is needed, it produces `Owner Skill Handoffs`: `sf-docs` for documentation, `sf-enrich` for existing content improvements, `sf-redact` for new long-form/editorial, `sf-audit-copy` and `sf-audit-copywriting` for copy quality/conversion audits, and `sf-audit-seo` for search intent and discoverability.

## Acceptance Criteria

- [x] `sf-repurpose` requires existing-content placement analysis unless explicitly out of scope.
- [x] The analysis separates internal documentation from public content.
- [x] Each opportunity explains what the audience did not know, misunderstood, or would understand better.
- [x] The output pack reference includes `Existing Content Opportunities`.
- [x] The public skill page promises existing-content improvement opportunities.
- [x] The skill references the shared master delegation semantics and allows parallel read-only fan-out for non-overlapping surface scans.
- [x] The skill removes direct apply/write behavior and routes writing to owner skills.
- [x] `Owner Skill Handoffs` are included in the output pack.
- [x] The skill still preserves source-faithfulness, claim safety, content-map routing, and missing blog surface policy.
- [x] The run stops before `sf-end` for user review.

## Scope

In:

- Update `skills/sf-repurpose/SKILL.md`.
- Update `skills/sf-repurpose/references/output-pack.md`.
- Update `site/src/content/skills/sf-repurpose.md`.
- Update `skills/REFRESH_LOG.md`.
- Create this spec and stop before `sf-end`.
- Include `skills/references/master-delegation-semantics.md` in review/ship scope if still untracked.

Out:

- Applying actual content changes to public pages or docs from `sf-repurpose`.
- Creating a blog/article surface.
- Changing `sf-content`, `sf-enrich`, `sf-redact`, or audit skills.
- Creating a new `sf-copy` skill.
- Committing or pushing.
- Shipping unrelated dirty worktree changes.

## Test Strategy

Run:

```bash
tools/shipflow_sync_skills.sh --check --skill sf-repurpose
python3 tools/skill_budget_audit.py --skills-root skills --format markdown
python3 tools/shipflow_metadata_lint.py specs/sf-repurpose-existing-content-placement-opportunities.md
npm --prefix site run build
rg -n "Read-Only Delegation|master-delegation-semantics|parallel read-only|Existing Content Placement Contract|Existing Content Opportunities|Owner Skill Handoffs|sf-docs|sf-enrich|sf-redact|sf-audit-copy|sf-audit-copywriting|sf-audit-seo|apply mode|write the content" skills/sf-repurpose/SKILL.md skills/sf-repurpose/references/output-pack.md site/src/content/skills/sf-repurpose.md
git diff --check
```

Fresh external docs verdict: `fresh-docs not needed`, because this change only updates local skill/report contracts and validates through local scripts and the site build.

## Documentation Update Plan

Status: complete.

- Skill contract changed: `skills/sf-repurpose/SKILL.md`.
- Skill reference changed: `skills/sf-repurpose/references/output-pack.md`.
- Technical docs: no impact; no runtime lifecycle doctrine changed.
- Help/README/workflow: no impact; discoverability mode did not change.

## Editorial Update Plan

Status: complete.

- Public surface: `site/src/content/skills/sf-repurpose.md`.
- Claim impact: low; page describes report output, not a new unsupported product claim.
- Blog/article surface: unchanged.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-05-04 11:00:48 UTC | sf-spec | GPT-5 Codex | Created the contract for existing-content placement opportunities in `sf-repurpose`. | ready | `/sf-skill-build skills/sf-repurpose/SKILL.md` |
| 2026-05-04 11:00:48 UTC | sf-ready | GPT-5 Codex | Checked that placement, scope, acceptance criteria, and stop-before-end review gate are explicit. | ready | edit `sf-repurpose` |
| 2026-05-04 11:00:48 UTC | sf-skill-build | GPT-5 Codex | Updated `sf-repurpose`, its output pack reference, public page, and refresh log. | implemented | validation |
| 2026-05-04 11:02:50 UTC | sf-verify | GPT-5 Codex | Verified runtime sync, metadata lint, skill budget audit, targeted rg checks, diff check, and Astro build. | verified; build passed with non-blocking duplicate-id warning in dirty worktree | user review before sf-end |
| 2026-05-04 11:08:30 UTC | sf-skill-build | GPT-5 Codex | Added shared delegation reference and parallel read-only fan-out rules for existing-content scans. | implemented | user review before sf-end |
| 2026-05-04 11:26:47 UTC | sf-verify | GPT-5 Codex | Revalidated runtime sync, metadata lint, skill budget audit, targeted rg checks, and diff check after delegation update. | verified; user review gate still active | remove apply mode |
| 2026-05-04 17:02:16 UTC | sf-skill-build | GPT-5 Codex | Removed direct apply/write behavior and added owner-skill handoff routing. | implemented | validation before user review |
| 2026-05-04 17:03:03 UTC | sf-verify | GPT-5 Codex | Verified runtime sync, metadata lint, skill budget audit, targeted rg checks, diff check, placeholder scan, and Astro build after read-only handoff changes. | verified; build passed with non-blocking duplicate-id warning in dirty worktree | user review before sf-end |
| 2026-05-04 19:09:36 UTC | sf-ship | GPT-5 Codex | Shipped all dirty repository changes in quick mode, including `sf-repurpose` read-only handoff work and related site/docs updates. | shipped | no formal closeout; optional follow-up review |

## Current Chantier Flow

```text
sf-spec: ready
sf-ready: ready
sf-start: implemented via sf-skill-build
sf-verify: verified
sf-end: skipped in quick ship
sf-ship: shipped
```

## Current State

- Chantier identified: yes.
- Current spec: `specs/sf-repurpose-existing-content-placement-opportunities.md`.
- Review gate: stop before `sf-end` as requested by the user.
- Dirty scope must stay bounded because unrelated worktree changes already exist.
- Required next step: user review; do not run `sf-end`, commit, or push yet.
