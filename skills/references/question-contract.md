---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipFlow
created: "2026-05-05"
updated: "2026-05-05"
status: active
source_skill: sf-skill-build
scope: skill-question-contract
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/*/SKILL.md
  - skills/references/master-workflow-lifecycle.md
  - skills/references/entrypoint-routing.md
  - skills/references/reporting-contract.md
  - docs/technical/skill-runtime-and-lifecycle.md
  - shipflow-spec-driven-workflow.md
depends_on: []
supersedes: []
evidence:
  - "User request 2026-05-04: skill questions should be numbered, explain why, include helpful icons, and identify the recommended answer."
  - "User clarification 2026-05-04: a default is acceptable only when it is compatible with the current technical/product/editorial context and current best practices."
next_review: "2026-06-05"
next_step: "/sf-verify shared question contract"
---

# Question Contract

## Purpose

This reference defines how ShipFlow skills ask user-facing questions.

The goal is to keep questions rare, useful, and easy to answer by number. A question is a decision brief: it tells the operator why the decision matters, which answer ShipFlow recommends by default when a responsible default exists, and why that recommendation fits the current context.

## Applies To

Load this contract before any user-facing:

- routing question
- clarification question
- product, persona, scope, or content-surface question
- security, data, permission, destructive, staging, closure, or ship-risk question
- blocked-state recovery question
- selection question for project, file, URL, domain, check set, package, market, or content source

Do not use it for internal analysis, progress updates, final reports, or subagent instructions where the subagent is forbidden to ask the user.

## Ask Threshold

Ask only when the answer changes at least one material outcome:

- owner skill, lifecycle path, or durable work item type
- user-visible behavior, product scope, audience, persona, or content surface
- security, privacy, data retention, permissions, auth, tenant boundary, money movement, or destructive behavior
- public claim, SEO target, brand promise, legal/compliance posture, or cost
- architecture, framework, dependency, provider, runtime behavior, or deployment mode
- staging, deployment, release, closure, ship scope, or bug risk
- validation strategy when the wrong proof would create false confidence

Proceed without asking only when the default answer is all of these:

- clear from the request and known project context
- low-risk and reversible
- inside the existing contract, spec, or accepted scope
- compatible with the current technical, product, and editorial context
- aligned with current best practices for the affected stack, provider, security posture, and user workflow
- verifiable with the evidence available in the current run

If the obvious or requested option conflicts with project context, public/editorial claims, architecture, security posture, or current best practices, do not silently choose it. Either choose the safe compatible alternative when it is obvious and inside scope, or ask a numbered decision question that explains the conflict.

Never ask broad "anything else?" questions.

## Required Shape

Every user-facing question must be answerable by number. Start each question with a numeric marker:

```text
1. [icon] [decision title]
```

Use the user's active language for labels and explanation. Stable commands, paths, IDs, and status values may stay literal.

Each question must include:

- decision title: the decision in plain language
- why: why the skill needs the answer now
- recommendation: the best default answer and why it is recommended, when a responsible default exists
- options: 2-3 practical choices when useful, with number-prefixed labels
- answer instruction: tell the user they can answer with the number or name another route

Use small icons only as scanning aids. Icons never replace the text label and are optional when the runtime or context favors plain ASCII.

## Plain-Text Format

```text
1. [icon] [Titre de decision]
Pourquoi: [ce qui est bloque, contradictoire ou risque]
Recommande: [option] - [pourquoi c'est le meilleur defaut dans ce contexte]

Options:
1. [Option recommandee] - [consequence]
2. [Alternative] - [consequence]

Reponds avec le numero, ou precise une autre option.
```

For English users, use `Why`, `Recommended`, `Options`, and `Reply with the number`.

## Recommendation Rules

The recommended answer must be the most responsible default, not the easiest path for the agent.

Prefer recommendations that:

- preserve user trust, data safety, and reversibility
- match the current spec, product contract, and repo conventions
- respect technical docs, `docs/technical/code-docs-map.md`, `CONTENT_MAP.md`, editorial governance, and public claim boundaries when applicable
- follow current best practices for the stack, provider, security model, and deployment mode
- minimize cost or public exposure unless the user explicitly wants that tradeoff
- keep implementation scope small enough to verify
- avoid premature shipping when proof is missing

Name the condition that would make another option better when that matters.
