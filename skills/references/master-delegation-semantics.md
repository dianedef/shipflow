---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.2.0"
project: ShipFlow
created: "2026-05-04"
updated: "2026-05-06"
status: active
source_skill: sf-build
scope: master-delegation-semantics
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/shipflow/SKILL.md
  - skills/sf-build/SKILL.md
  - skills/sf-maintain/SKILL.md
  - skills/sf-content/SKILL.md
  - skills/sf-design/SKILL.md
  - skills/sf-skill-build/SKILL.md
  - skills/sf-deploy/SKILL.md
  - skills/sf-bug/SKILL.md
  - skills/sf-audit/SKILL.md
  - docs/technical/skill-runtime-and-lifecycle.md
  - shipflow-spec-driven-workflow.md
  - README.md
depends_on: []
supersedes: []
evidence:
  - "User decision 2026-05-04: the primary `shipflow` router should use direct main-thread handoff to selected master skills, not nested master-skill subagents."
  - "User decision 2026-05-04: master skills keep the master conversation clean by delegating file, validation, closure, and ship work to bounded sequential subagents when available."
  - "User decision 2026-05-04: delegation/subagent execution is distinct from parallelism; parallelism means simultaneous subagents and requires ready Execution Batches."
  - "User decision 2026-05-04: short natural-language confirmations continue the current chantier in delegated sequential mode after diagnosis or proposal; they are interpreted by intent, not exact keyword."
  - "User decision 2026-05-06: sf-design joins the master/orchestrator topology set."
next_review: "2026-06-04"
next_step: "/sf-verify master delegation semantics"
---

# Master Delegation Semantics

## Purpose

This reference defines how ShipFlow master and orchestrator skills choose execution topology without duplicating delegation doctrine in every skill contract.

The goal is a clean master conversation: the master skill owns decisions, routing, status, integration, and final reporting, while bounded execution contexts handle routine file work, validation, closure preparation, and ship preparation when the runtime supports them.

## Applies To

This applies to master and orchestrator skills that pilot multiple phases, owner skills, or execution contexts, including `shipflow`, `sf-build`, `sf-maintain`, `sf-content`, `sf-design`, `sf-skill-build`, `sf-deploy`, `sf-bug`, and `sf-audit`.

`shipflow` is a special case: it is a primary router, not a lifecycle executor. It loads this reference to avoid invalid topology, then uses direct main-thread handoff to the selected skill. It must not launch selected master skills inside subagents.

Atomic owner skills may cite this reference only when they launch or coordinate subagents themselves.

## Concepts

- `delegation`: assigning a bounded mission to another execution context.
- `subagent`: the delegated execution context that reads, edits, validates, gathers evidence, prepares integration, or prepares ship under a bounded mission.
- `parallelism`: running more than one subagent at the same time.

Delegation to one sequential subagent is not parallelism. It is the normal way a master skill keeps the user-facing thread focused.

## Default

When subagents are available, the default topology for master-skill work that reads files, edits files, validates, prepares closure, or prepares ship is `delegated sequential`.

Use one bounded subagent at a time. A small scope may use a mini-contract, but small scope is not an exception to delegation. If file work or validation is needed and subagents are available, the master should delegate sequentially instead of doing routine diffs or patches in the master conversation.

Each delegated mission must include:

- project root
- active spec or mini-contract
- assigned mission
- owned files or surfaces
- forbidden files or surfaces
- selected model or alias
- reasoning effort, or the Claude alias behavior when using Claude Code
- fast or cheap fallback when the selected model is unavailable or too costly
- model application status: `override applied`, `recommended only`, or `not supported by runtime`
- validation commands
- report mode
- stop conditions

Do not claim that a subagent used a model override unless the runtime actually accepted that override. If the orchestration layer cannot set the subagent model, keep the recommendation in the mission text and report the run as degraded when that matters for risk, cost, or evidence.

## Short Confirmations

After a master skill has diagnosed the current chantier, proposed a bounded action, or named the next safe mission, a short natural-language confirmation in the active conversation language means, by intent rather than exact keyword:

```text
continue the current chantier in delegated sequential mode with one bounded subagent
```

Do not reinterpret short confirmations as consent for parallel subagents. Do not ask a second delegation-consent question unless the next action changes scope, risk, data, permissions, destructive behavior, staging, closure, or ship semantics.

## Parallelism

Parallelism means simultaneous subagents. It is allowed only through ready `Execution Batches`.

Ready `Execution Batches` must define:

- non-overlapping write ownership
- dependency order
- per-batch validation
- integration owner

Without ready batches, parallelism is blocked. The next action is spec or batch refinement, not opportunistic fan-out.

Read-only audit fan-out may run in simultaneous subagents only when the master skill has an explicit selected batch matrix, such as project x domain, and each agent is forbidden to edit files. Any fix, tracker rewrite, content update, closure, or ship work after that returns to delegated sequential unless a ready spec defines write-safe `Execution Batches`.

## Exceptions And Degradation

Allowed exceptions to delegated sequential are:

- pure conversational `main-only` responses
- runtime subagents are unavailable
- the user explicitly requests no subagent
- Plan Mode or decision framing where no mutation, file validation, closure, or ship action will occur

If subagents are unavailable or explicitly refused, ask before degrading to master or single-agent mode for file work, validation, closure, or ship. The user-facing question should describe the practical impact: more technical detail in the master thread and less isolation between orchestration and execution.

## Master Role Responsibilities

The master skill owns:

- clarifying material decisions
- selecting execution topology
- setting the bounded mission
- assigning write ownership
- preventing overlapping writes
- providing concise status
- integrating outputs
- checking evidence and validation results
- routing docs, editorial, proof, closure, ship, or deployment gates
- reporting the result and real blockers

The master skill should not perform routine diffs, patches, validation sweeps, or ship preparation itself when a bounded subagent can do that work.

## Stop Conditions

Stop, ask, reroute, or refine the spec when:

- the active chantier or mini-contract is ambiguous
- subagents are unavailable and the user has not accepted degradation
- requested parallelism lacks ready `Execution Batches`
- write ownership overlaps or is undefined
- the next action changes material scope, permissions, data, destructive behavior, closure, staging, or ship semantics
- validation, proof, docs, editorial, closure, or ship gates are unresolved
- unrelated dirty files would enter the execution or ship scope

## Reporting Expectations

User-facing reports stay concise. They should include the execution mode only when it matters for trust, evidence, or next steps.

Agent or handoff reports may include:

- execution topology
- delegated mission summaries
- owned and forbidden file sets
- validation commands and results
- integration notes
- stop conditions hit or cleared

Never present parallel work as merely "delegation"; name simultaneous subagents as parallelism and point to the ready `Execution Batches` that made it safe.
