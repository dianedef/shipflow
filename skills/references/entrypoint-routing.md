---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipFlow
created: "2026-05-04"
updated: "2026-05-04"
status: active
source_skill: sf-skill-build
scope: entrypoint-routing
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/shipflow/SKILL.md
  - skills/sf-build/SKILL.md
  - skills/sf-maintain/SKILL.md
  - skills/sf-bug/SKILL.md
  - skills/sf-deploy/SKILL.md
  - skills/sf-content/SKILL.md
  - skills/sf-skill-build/SKILL.md
  - skills/sf-audit/SKILL.md
  - skills/references/master-delegation-semantics.md
  - skills/references/question-contract.md
  - docs/skill-launch-cheatsheet.md
  - README.md
  - shipflow-spec-driven-workflow.md
depends_on:
  - artifact: "skills/references/master-delegation-semantics.md"
    artifact_version: "1.1.0"
    required_status: active
  - artifact: "skills/references/question-contract.md"
    artifact_version: "1.0.0"
    required_status: active
  - artifact: "skills/references/master-workflow-lifecycle.md"
    artifact_version: "1.1.0"
    required_status: active
supersedes: []
evidence:
  - "User decision 2026-05-04: create `shipflow` as the primary non-technical router across the existing skill taxonomy."
  - "User decision 2026-05-04: `shipflow` should use direct main-thread handoff to selected master skills instead of nested master-skill subagents."
  - "User decision 2026-05-04: ambiguous routing questions should be numbered decision briefs with a responsible recommendation."
next_review: "2026-06-04"
next_step: "/sf-verify specs/shipflow-primary-router-skill.md"
---

# Entrypoint Routing

## Purpose

This reference defines the shared routing rules for `shipflow`, the primary natural-language entrypoint for ShipFlow.

It does not replace lifecycle, bug, release, content, maintenance, audit, or skill-maintenance owner contracts. It decides which existing contract should own the request.

It defines only the routing-question rule. Load `skills/references/question-contract.md` for the shared question/default contract, then ask one concise numbered question when the route is materially ambiguous.

## Core Rule

Route to the smallest existing owner that can safely own the outcome.

If the request needs more than one phase, route to the relevant master skill. If the request clearly names one specialist phase, route to that focused owner skill. If no file work or lifecycle action is needed, answer directly.

## Execution Topology

Use direct main-thread handoff for selected skills.

Do not launch selected master skills inside subagents. The selected master skill owns any delegated sequential execution after handoff through `skills/references/master-delegation-semantics.md`.

A read-only routing scout is allowed only for cheap classification evidence and must not edit, stage, commit, push, deploy, mutate trackers, invoke a master skill, or launch further subagents.

## Routing Matrix

| Operator intent | Primary route |
| --- | --- |
| Pure question, explanation, model/help clarification, or advice with no files | Direct answer |
| Feature, product change, code work, site work, docs work, workflow improvement, broad bug-like goal without durable bug state | `sf-build` |
| Recurring upkeep, dependency posture, docs drift, checks, audits, migrations, project hygiene, security maintenance | `sf-maintain` |
| Observed defect, `BUG-ID`, retest, bug closure, bug fix state, bug ship risk | `sf-bug` |
| Release confidence, preview/prod deployment, deployed truth, runtime logs, production health, post-deploy proof | `sf-deploy` |
| Content strategy, repurposing, drafting, enrichment, SEO/copy audit, editorial governance, content apply/publish | `sf-content` |
| New skill, skill modification, skill runtime visibility, skill public page, skill docs/help coherence | `sf-skill-build` |
| One obvious audit domain only | relevant `sf-audit-*` or `sf-audit` |
| One obvious focused lane: checks, docs, browser proof, auth diagnosis, manual QA, dependency posture, migration, final ship | focused owner skill |
| Ambiguous material route | Ask one concise numbered routing question |

## Ambiguity Rules

Ask when the answer changes:

- owner skill
- durable work item type
- security, data, permission, or destructive posture
- public claim or content surface
- staging, deployment, closure, or ship semantics
- whether the run should mutate files or stay read-only

Do not ask when a best-practice route is clear, low-risk, reversible, already covered by an existing owner skill, compatible with current project context, and verifiable in the current run.

When a routing question is required, it follows `skills/references/question-contract.md`: numbered, concise, clear about why the route changes behavior or risk, and explicit about the recommended route when a responsible recommendation exists.

## Handoff Requirements

A direct handoff must preserve:

- the original user instruction
- selected skill argument
- report mode when explicit
- stop conditions and owner-skill gates
- active user language for user-facing questions and reports

The router may state the route briefly, then continue under the selected skill contract. It should not end with a manual command recommendation unless handoff is blocked or the user only asked which skill to use.

## Non-Goals

- Do not create a new master lifecycle.
- Do not duplicate specialist internals.
- Do not create specs, bug files, content, commits, deployments, or public claims directly.
- Do not treat direct handoff as parallelism.
- Do not use nested master-skill-in-subagent execution.
