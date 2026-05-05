---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipFlow
created: "2026-05-04"
updated: "2026-05-04"
status: active
source_skill: sf-skill-build
scope: master-workflow-lifecycle
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/sf-build/SKILL.md
  - skills/sf-maintain/SKILL.md
  - skills/sf-content/SKILL.md
  - skills/sf-skill-build/SKILL.md
  - skills/sf-deploy/SKILL.md
  - skills/sf-bug/SKILL.md
  - skills/sf-audit/SKILL.md
  - skills/references/master-delegation-semantics.md
  - skills/references/question-contract.md
  - skills/references/chantier-tracking.md
  - docs/technical/skill-runtime-and-lifecycle.md
  - shipflow-spec-driven-workflow.md
  - README.md
depends_on:
  - artifact: "skills/references/master-delegation-semantics.md"
    artifact_version: "1.1.0"
    required_status: active
  - artifact: "skills/references/question-contract.md"
    artifact_version: "1.0.0"
    required_status: active
  - artifact: "skills/references/chantier-tracking.md"
    artifact_version: "0.4.1"
    required_status: draft
supersedes: []
evidence:
  - "User decision 2026-05-04: master skills should share the same workflow skeleton instead of duplicating lifecycle doctrine."
  - "User decision 2026-05-04: bug work uses one Markdown bug file per bug under bugs/*.md; BUGS.md is optional/generated/triage view, not the source of truth."
  - "User decision 2026-05-04: user-facing questions should share a numbered, context-aware question/default contract."
next_review: "2026-06-04"
next_step: "/sf-verify master workflow lifecycle reference"
---

# Master Workflow Lifecycle

## Purpose

This reference defines the shared lifecycle skeleton for ShipFlow master and orchestrator skills.

It does not redefine delegation, subagent, short-confirmation, or parallelism semantics. Load `skills/references/master-delegation-semantics.md` for execution topology.

## Applies To

Use this reference from master and orchestrator skills that pilot more than one phase or owner skill, including `sf-build`, `sf-maintain`, `sf-content`, `sf-skill-build`, `sf-deploy`, `sf-bug`, and `sf-audit`.

Atomic owner skills may cite this reference only when they need to align their own handoff language with the master lifecycle.

## Work Item Abstraction

A master skill always pilots a single current work item unless it is explicitly in read-only dashboard mode.

Supported work item types:

- `chantier spec`: a `specs/*.md` file for non-trivial spec-first work.
- `bug file`: one Markdown file under `bugs/*.md` for one bug work item.
- `mini-contract`: a short in-report contract for narrow local work that is safe without a full spec.
- `release scope`: the bounded set of files, commit, deployment target, and proof obligations for a release.
- `audit finding set`: a read-only or source-de-chantier finding set that may recommend a future spec.
- `content surface`: a bounded content goal, source, target surface, claim set, and validation surface.
- `skill-maintenance target`: one skill contract or tightly bounded set of skill/public-doc surfaces.

The work item decides source of truth:

- Spec-first work: `specs/*.md` is the source of truth and chantier registry.
- Bug work: `bugs/*.md` is the source of truth for reproduction, status, diagnosis, fix attempts, retest history, closure, and residual risk.
- Bug triage view: `BUGS.md`, when present, is only a compact optional/generated/triage index that points to bug files. It is not mandatory and must not override a bug file.
- Mini-contract work: the final report or active handoff contract is the source until the work either closes or is promoted to a spec or bug file.

Do not create separate source-of-truth registries in `TASKS.md`, `AUDIT_LOG.md`, `PROJECTS.md`, `shipflow_data`, or `BUGS.md`.

## Shared Skeleton

Master skills adapt this skeleton to their local owner routes:

```text
intake
  -> work item resolution
  -> readiness gate
  -> model/topology routing
  -> delegated or owner-skill execution
  -> targeted validation and evidence routing
  -> verification
  -> post-verify closure
  -> bounded ship/deploy/release routing
```

### 1. Intake And Routing

Normalize the user request into one current work item. Route to the owning skill when the request clearly names only one specialist phase.

Ask only when the answer changes behavior, scope, security, data, permissions, destructive side effects, public claims, closure, staging, or ship risk.

Before asking a user-facing question, load `skills/references/question-contract.md`. The question contract decides when a default is safe enough to choose without asking and how to format numbered decision questions.

### 2. Work Item Resolution

Before creating a new durable artifact, search for an existing matching work item:

- `specs/*.md` for spec-first chantiers.
- `bugs/*.md` for bug work items.
- `BUGS.md` only as a secondary index if it exists.
- current release scope, audit scope, content target, or skill target for master-specific work.

If exactly one work item owns the request, continue it. If several match, ask the user to choose. If none exists and the work is non-trivial, create or route to the correct durable artifact owner.

### 3. Readiness Gate

Use a full spec when the work is non-trivial, cross-file, cross-surface, risky, public-claim-sensitive, security/data-impacting, deployment-impacting, or needs staged validation.

Use a bug file when the work is a concrete defect, regression, failed test, retest, bug closure, or bug ship-risk question.

Use a mini-contract only when the work is narrow, local, low-risk, and verifiable in the current run.

Do not start implementation from a draft, ambiguous, or contradictory work item.

### 4. Model And Topology Routing

Before expensive or risky execution, choose the model profile using `sf-model` guidance or the relevant local model-routing reference.

Before file work, validation, closure preparation, or ship preparation, choose topology using `skills/references/master-delegation-semantics.md`.

Record the choice when it affects trust, cost, evidence, or handoff.

### 5. Execution Through Owners

Master skills orchestrate; owner skills own specialist internals.

Examples:

- `sf-start` owns spec implementation.
- `sf-fix` owns bug diagnosis and fix attempts.
- `sf-test` owns durable manual QA, retests, and bug-file mutation.
- `sf-docs` owns documentation corpus creation/update/audit.
- `sf-ship` owns staging, commit, and push.
- `sf-prod`, `sf-browser`, and `sf-auth-debug` own deployment/browser/auth proof.

Do not duplicate owner internals inside a master skill for convenience.

### 6. Validation And Evidence Routing

Run checks and evidence collection that match the changed surface. Do not invent proof.

Use proof owners by evidence type:

- local checks: `sf-check` or project validation commands
- hosted deployment truth: `sf-prod`
- non-auth browser/page proof: `sf-browser`
- auth/session/provider/protected-route proof: `sf-auth-debug`
- durable manual QA or bug retest evidence: `sf-test`

### 7. Verification

Run or route through `sf-verify` when the user story, release scope, content promise, bug closure, or skill maintenance outcome needs coherence verification.

If verification fails, route back to correction, retest, spec update, or blocked report. Do not proceed to closure or ship as if the work passed.

### 8. Post-Verify Closure And Ship

After verification passes, the master skill should continue through its owned closure and ship route unless a named stop condition blocks it.

Typical routes:

- `sf-build`: `sf-end -> sf-ship`
- `sf-maintain`: `sf-end` when a chantier needs closure bookkeeping, then `sf-ship` or `sf-deploy`
- `sf-content`: `sf-verify -> sf-ship` for bounded content changes
- `sf-skill-build`: `sf-docs/help update -> sf-ship`
- `sf-deploy`: `sf-check -> sf-ship -> sf-prod -> proof -> sf-verify -> sf-changelog`
- `sf-bug`: retest/verify/ship-risk routing from the bug file

Do not end a successful post-verify master report with a manual `/sf-end`, `/sf-ship`, or `/sf-deploy` next step unless a concrete blocker prevents orchestration in the current run.

## Bug Work Item Rules

Use this vocabulary:

- `bug work item`: the lifecycle unit for one bug.
- `bug file`: the durable Markdown source of truth under `bugs/*.md`.
- `bug index` or `triage view`: optional `BUGS.md` if present.

Avoid folder-like bug vocabulary in new shared doctrine and master-skill instructions. Existing legacy references should be cleaned when touched.

Bug source-of-truth rules:

- Read `bugs/BUG-ID.md` first when a bug ID is known.
- Use `BUGS.md` only to discover candidate bug IDs or show a compact dashboard.
- If `BUGS.md` disagrees with the bug file, the bug file wins and the index should be regenerated or reconciled.
- If a bug file exists without `BUGS.md`, the bug still exists and can be routed.
- If `BUGS.md` references a missing bug file, treat it as an index gap, not as durable evidence.

## Stop Conditions

Stop, ask, or reroute when:

- no single work item can be identified
- the current work item is not ready
- a bug has no usable bug file and cannot be reconstructed safely
- the requested operation would bypass an owner skill's gate
- validation or evidence is missing for the promised outcome
- verification fails
- closure or ship scope includes unrelated dirty files
- the next action changes material scope, security, data, permissions, destructive behavior, public claims, staging, or release semantics

## Reporting

User reports should stay concise:

- result
- work item path or scope
- route taken
- validation/evidence
- remaining blockers only when real
- compact chantier block when applicable

Agent/handoff reports may add work item resolution details, model/topology choice, owner-skill routes, validation matrices, and stop conditions.
