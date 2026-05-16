---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipFlow
created: "2026-05-16"
updated: "2026-05-16"
status: draft
source_skill: sf-start
scope: sf-verify-gates
owner: unknown
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/sf-verify/SKILL.md
  - skills/references/documentation-freshness-gate.md
  - skills/references/project-development-mode.md
  - skills/references/sentry-observability.md
depends_on:
  - artifact: "skills/references/chantier-tracking.md"
    artifact_version: "0.5.0"
    required_status: "draft"
  - artifact: "skills/references/reporting-contract.md"
    artifact_version: "1.2.0"
    required_status: "active"
supersedes: []
evidence:
  - "Extracted from sf-verify SKILL.md during compact-skill pilot."
next_review: "2026-06-16"
next_step: "/sf-verify Compact ShipFlow Skill Instructions"
---

# sf-verify Detailed Gates

## Step Skeleton

1. Identify scope/work item.
2. Resolve development mode and required validation surface.
3. Verify user story outcome.
4. Verify success behavior and error behavior.
5. Verify metadata/versioned contracts and `depends_on` coherence.
6. Verify fresh external docs gate when dependency behavior matters.
7. Verify completeness (tasks, acceptance criteria, expected files).
8. Verify bug gate from `bugs/*.md` (+ optional `BUGS.md` index).
9. Verify correctness against code/tests/invariants/linked consequences.
10. Verify coherence (project patterns, language doctrine, docs coherence).
11. Verify dependency, risk, and quick technical checks.
12. Report verdict with next command and chantier block.

## Development Mode Gate

Use `project-development-mode.md` to classify:

- `local`
- `vercel-preview-push`
- `hybrid`
- `unknown-vercel`
- `unknown`

Rules:

- In preview/hybrid modes, do not mark ready-to-ship when required hosted/browser/manual proof is missing.
- For preview-required proof, route through `sf-ship -> sf-prod -> sf-test --preview` or `sf-auth-debug` / `sf-browser`.

## Success / Error Behavior Gate

Always report both:

- expected observable success + system effect + evidence
- expected error handling + forbidden bad states + evidence

If success/error behavior is unproven:

- `partial` when risk is moderate and contract remains mostly stable
- `not verified` or `blocked` for high-risk contract gaps (security, data, money, destructive behavior, external critical integrations)

## Metadata / Version Gate

When spec exists:

- verify spec metadata presence (`metadata_schema_version`, `artifact_version`, `status`, `updated`)
- verify `depends_on` coherence with current referenced docs versions/statuses
- flag outdated/missing dependency contracts

Escalation:

- `warning` for non-critical version drift
- `critical` when drift can alter permissions, pricing, security, data behavior, public claims, or architecture contract

## Fresh Docs Gate

Use `documentation-freshness-gate.md`.

Verdicts:

- `fresh-docs checked`
- `fresh-docs not needed`
- `fresh-docs gap`
- `fresh-docs conflict`

Critical domains require current official/contextual references before confident verification: auth, permissions, security, migrations, payment, tenant boundaries, webhooks, critical integrations.

## Bug Gate

Source of truth is `bugs/*.md`. `BUGS.md` is optional index only.

Verdicts:

- `bug gate clear`
- `partial-risk`
- `blocks ship`
- `not assessed`

Any open high/critical bug in scope blocks ready-to-ship verdict.

## Coherence Gates

### Project / Code Coherence

- respect CLAUDE/project constraints
- respect local architecture/style conventions
- verify linked systems and downstream consequences

### Language Doctrine

For touched ShipFlow artifacts:

- internal contracts in English
- user-facing output in active language
- French accents for French user-facing text (except technical identifiers/commands)
- stable machine anchors in English

### Documentation Coherence

When behavior/contracts changed:

- docs aligned or explicit no-impact justification
- stale docs are warnings or critical depending on user risk

## Dependency And Risk Gate

Check diff for:

- new dependencies relevance and vulnerability risk
- obvious security/performance/data risks
- destructive/migration hazards

## Technical Checks Gate

Run quick checks only (no local build by default):

- lint/typecheck/tests where available and relevant
- if required checks fail -> `critical`

## Reporting Contract (Required Blocks)

Include compact but explicit sections:

- summary table
- critical / warning / suggestion
- user story verdict
- success/error verdict
- metadata/contract version verdict
- language doctrine verdict
- fresh docs verdict
- development mode verdict
- Sentry observability status when applicable
- bug gate verdict
- workflow next step
- chantier block

Never output `⚠` or `✗` without a concrete next command.

## Graceful Degradation

When context artifacts are missing, continue with explicit confidence limits and list skipped checks/reasons.
