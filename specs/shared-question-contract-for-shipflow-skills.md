---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipFlow
created: "2026-05-05"
created_at: "2026-05-05 17:07:53 UTC"
updated: "2026-05-05"
updated_at: "2026-05-05 17:14:48 UTC"
status: ready
source_skill: sf-skill-build
source_model: "GPT-5 Codex"
scope: skill-maintenance
owner: Diane
user_story: "As a ShipFlow operator, I want all skills to share one question/default contract, so questions are rare, numbered, contextual, and recommended defaults are chosen only when they are safe and verifiable."
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/question-contract.md
  - skills/references/master-workflow-lifecycle.md
  - skills/references/entrypoint-routing.md
  - skills/sf-build/SKILL.md
  - skills/shipflow/SKILL.md
  - README.md
  - shipflow-spec-driven-workflow.md
  - docs/skill-launch-cheatsheet.md
  - docs/technical/skill-runtime-and-lifecycle.md
  - site/src/content/skills/shipflow.md
  - site/src/content/skills/sf-build.md
depends_on:
  - artifact: "skills/references/master-workflow-lifecycle.md"
    artifact_version: "1.1.0"
    required_status: active
  - artifact: "skills/references/entrypoint-routing.md"
    artifact_version: "1.1.0"
    required_status: active
supersedes: []
evidence:
  - "conversation-shipflow-questions-contextuelles-des-skills.md captured the earlier question-contract draft and user decisions."
  - "User decision 2026-05-04: questions should be numbered, explain why, include helpful icons when useful, and name the recommended answer."
  - "User decision 2026-05-04: a skill may proceed by default only when the default is compatible with project context and current best practices."
next_step: "none"
---

# Spec: Shared Question Contract For ShipFlow Skills

## Title

Shared Question Contract For ShipFlow Skills

## Status

Ready.

The behavior is already decided from the captured conversation. No naming, placement, or public-promise question remains open.

## User Story

As a ShipFlow operator, I want all skills to share one question/default contract, so questions are rare, numbered, contextual, and recommended defaults are chosen only when they are safe and verifiable.

## Minimal Behavior Contract

ShipFlow skills must use one shared question/default doctrine for user-facing questions. They should ask only when the answer changes route, scope, risk, proof, closure, ship posture, public claims, or technical/product/editorial direction. They may proceed without asking only when the default is clear, low-risk, reversible, inside scope, compatible with current context and best practices, and verifiable in the current run.

## Success Behavior

- Preconditions: ShipFlow master/orchestrator skills already load shared lifecycle and routing references.
- Trigger: A skill needs to choose whether to ask the user or proceed by default.
- User/operator result: The skill asks a numbered decision question with why, recommendation, and practical options, or proceeds with a context-safe default and states important assumptions when useful.
- System effect: the shared reference is reused instead of duplicating question doctrine in every skill.
- Success proof: metadata lint, skill budget audit, runtime skill sync, targeted text checks, diff whitespace check, and site build pass.
- Silent success: not allowed; material assumptions or questions must be visible.

## Error Behavior

- If no responsible default exists, the skill asks a question instead of guessing.
- If the obvious option conflicts with project context, public claims, architecture, security posture, or current best practices, the skill surfaces the conflict.
- If a runtime prompt tool cannot express the full decision brief, the skill sends a short framing paragraph first and uses concise prompt options.
- If validation fails, stop before shipping.

## Scope In

- Create `skills/references/question-contract.md`.
- Wire the shared contract into master lifecycle and entrypoint routing references.
- Keep local `sf-build` and `shipflow` question gates aligned with the shared contract.
- Update technical docs, workflow docs, README, launch cheatsheet, help, refresh log, and public skill pages where the promise is visible.

## Scope Out

- Rewriting every skill body.
- Forcing every atomic skill to load the reference when it does not ask user-facing questions.
- Changing skill invocation names.
- Changing runtime prompt tooling.
- Shipping unrelated dirty files.

## Constraints

- Internal skill contracts stay in English.
- User-facing questions use the active user language.
- Icons are helpful scanning aids, not required semantic content.
- The shared contract must reduce duplicated doctrine rather than add long local question sections to every skill.

## Implementation Tasks

- [x] Task 1: Add the shared question contract reference.
  - File: `skills/references/question-contract.md`
  - Validate with: `python3 tools/shipflow_metadata_lint.py skills/references/question-contract.md`

- [x] Task 2: Wire the contract into master lifecycle and routing references.
  - Files: `skills/references/master-workflow-lifecycle.md`, `skills/references/entrypoint-routing.md`
  - Validate with: `rg -n "question-contract|Question Contract" skills/references/master-workflow-lifecycle.md skills/references/entrypoint-routing.md`

- [x] Task 3: Align the main local question gates.
  - Files: `skills/sf-build/SKILL.md`, `skills/shipflow/SKILL.md`
  - Validate with: `rg -n "question-contract|compatible with the current" skills/sf-build/SKILL.md skills/shipflow/SKILL.md`

- [x] Task 4: Update docs and public surfaces.
  - Files: `README.md`, `shipflow-spec-driven-workflow.md`, `docs/skill-launch-cheatsheet.md`, `docs/technical/skill-runtime-and-lifecycle.md`, `skills/sf-help/SKILL.md`, `site/src/content/skills/shipflow.md`, `site/src/content/skills/sf-build.md`
  - Validate with: metadata lint where applicable and `npm --prefix site run build`.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-05-05 17:07:53 UTC | sf-skill-build | GPT-5 Codex | Created the shared question-contract chantier from the captured conversation, after confirming prior duplicate/frontmatter/runtime warnings were no longer reproducible. | implemented | /sf-verify specs/shared-question-contract-for-shipflow-skills.md |
| 2026-05-05 17:14:23 UTC | sf-verify | GPT-5 Codex | Verified shared question contract integration: metadata lint, skill budget audit, runtime skill sync, targeted wording checks, bug gate review, AGENTS alias check, diff whitespace, and clean Astro build after purging stale content cache. | verified | /sf-ship "shared question contract" |
| 2026-05-05 17:14:48 UTC | sf-ship | GPT-5 Codex | Quick ship requested for `shared question contract`; staged the bounded question-contract scope after checks, then committed and pushed it. | shipped | none |

## Current Chantier Flow

- `warning cleanup`: done; Astro build, skill budget audit, runtime sync, and metadata lint are clean in the current repo state.
- `sf-spec`: done; ready spec created from the captured conversation and user request.
- `sf-ready`: ready by prior explicit user decisions.
- `sf-skill-build`: implemented; shared contract and integration surfaces updated.
- `sf-verify`: verified; metadata lint, skill budget, runtime sync, targeted wording checks, bug gate review, AGENTS alias check, diff whitespace, and Astro build passed.
- `sf-ship`: shipped; quick mode commit + push.
