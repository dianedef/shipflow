---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipFlow
created: "2026-05-03"
created_at: "2026-05-03 00:00:00 UTC"
updated: "2026-05-04"
updated_at: "2026-05-04 04:45:00 UTC"
status: ready
source_skill: sf-build
source_model: "GPT-5 Codex"
scope: workflow
owner: Diane
user_story: "As a ShipFlow operator, I want skills to default to concise human reports while still supporting detailed agent handoff reports on request, so standalone skill usage stays readable without losing technical traceability for internal orchestration."
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/references/reporting-contract.md
  - skills/references/chantier-tracking.md
  - skills/sf-spec/SKILL.md
  - skills/sf-ready/SKILL.md
  - skills/sf-build/SKILL.md
  - skills/sf-ship/SKILL.md
  - skills/sf-start/SKILL.md
  - skills/sf-verify/SKILL.md
  - skills/sf-end/SKILL.md
  - skills/sf-deploy/SKILL.md
  - skills/sf-skill-build/SKILL.md
  - skills/sf-bug/SKILL.md
  - skills/sf-audit*/SKILL.md
  - docs/technical/skill-runtime-and-lifecycle.md
  - shipflow-spec-driven-workflow.md
depends_on:
  - artifact: "docs/technical/code-docs-map.md"
    artifact_version: "1.0.0"
    required_status: reviewed
  - artifact: "docs/technical/skill-runtime-and-lifecycle.md"
    artifact_version: "1.5.0"
    required_status: reviewed
  - artifact: "skills/references/chantier-tracking.md"
    artifact_version: "0.4.0"
    required_status: draft
supersedes: []
evidence:
  - "User decision 2026-05-03: sf-ship successful reports should collapse push, repo state, checks, and bookkeeping into one line."
  - "User decision 2026-05-03: default user reports should be concise; detailed reports should remain available for agent handoff."
  - "User decision 2026-05-03: audit skills should follow the same mechanism, with concise findings by default and fuller detail for handoff."
next_step: "/sf-verify specs/skill-reporting-modes-and-compact-reports.md"
---

# Spec: Skill Reporting Modes And Compact Reports

## Status

ready

## User Story

As a ShipFlow operator, I want skills to default to concise human reports while still supporting detailed agent handoff reports on request, so standalone skill usage stays readable without losing technical traceability for internal orchestration.

## Minimal Behavior Contract

ShipFlow skills that produce final reports must use a shared reporting contract. Default mode is `report=user`: concise, outcome-first, and quiet on successful checks. Detailed mode is explicit through `report=agent`, `handoff`, `verbose`, or `full-report`; it is for internal orchestration, debugging, or delegated agent handoff. Skills must not try to magically infer the caller. Master skills that need detailed downstream evidence should pass the explicit handoff flag. Blocked, failed, or partial outcomes must still include enough detail to be actionable.

## Success Behavior

- Successful ship reports collapse push, repo state, checks, and bookkeeping into one status line.
- Lifecycle reports use a compact chantier block: path first, then one `Flux:` line.
- Empty `Reste a faire`, `Prochaine etape`, `Trace spec`, and verdict boilerplate are omitted in user mode.
- Audit reports remain findings-first but default to top issues, proof gaps, and next step instead of full matrices.
- Agent mode may use existing detailed templates, validation matrices, evidence lists, and handoff notes.

## Error Behavior

- Failed checks, blocked ships, unresolved high-risk bugs, missing evidence, and partial verification must be explicit even in concise mode.
- A skill should include the exact failing gate, command, file, or next action when the user cannot proceed without it.
- If a master skill wants a detailed downstream report, it must request `report=agent` explicitly.

## Scope In

- Add a shared reporting reference.
- Update chantier reporting doctrine.
- Adopt the report modes in master lifecycle skills.
- Adopt the audit report mode in the `sf-audit*` family.
- Update technical and workflow docs.

## Scope Out

- Do not rewrite every historical detailed report template line by line.
- Do not remove detailed audit matrices; reserve them for agent/handoff mode.
- Do not infer user-vs-agent caller from runtime state.
- Do not change git, validation, or chantier trace semantics.

## Current Chantier Flow

| Skill | Status |
|-------|--------|
| sf-spec | ready |
| sf-ready | ready |
| sf-start | implemented |
| sf-verify | verified |
| sf-end | closed |
| sf-ship | shipped |

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-05-03 | sf-build | GPT-5 Codex | Created reporting modes spec and implemented shared contract. | implemented | /sf-verify specs/skill-reporting-modes-and-compact-reports.md |
| 2026-05-04 04:45:00 UTC | sf-build | GPT-5 Codex | Resumed the existing reporting modes chantier, verified the bounded scope, and prepared closure through sf-end and sf-ship. | implemented | /sf-ship "Add compact skill reporting modes" |
| 2026-05-04 04:45:00 UTC | sf-verify | GPT-5 Codex | Verified shared reporting contract, lifecycle and audit skill wiring, technical/workflow docs coherence, metadata, language doctrine, and bug gate scope. | verified | /sf-end specs/skill-reporting-modes-and-compact-reports.md |
| 2026-05-04 04:45:00 UTC | sf-end | GPT-5 Codex | Closed tracker and changelog bookkeeping for compact skill reporting modes. | closed | /sf-ship "Add compact skill reporting modes" |
| 2026-05-04 04:45:00 UTC | sf-ship | GPT-5 Codex | Ran scoped checks, committed, and pushed compact skill reporting modes. | shipped | none |
