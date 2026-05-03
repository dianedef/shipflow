---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipFlow
created: "2026-05-03"
created_at: "2026-05-03 10:04:53 UTC"
updated: "2026-05-03"
updated_at: "2026-05-03 11:40:29 UTC"
status: ready
source_skill: sf-spec
source_model: "GPT-5 Codex"
scope: feature
owner: Diane
user_story: "As a ShipFlow operator managing bugs across sessions, I want one sf-bug entrypoint that routes intake, dossier state, fix attempts, retests, verification, and ship risk, so the professional bug loop is followed without manually remembering every command."
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - "skills/sf-bug/SKILL.md"
  - "skills/sf-bug/agents/openai.yaml"
  - "skills/sf-test/SKILL.md"
  - "skills/sf-fix/SKILL.md"
  - "skills/sf-verify/SKILL.md"
  - "skills/sf-ship/SKILL.md"
  - "skills/sf-help/SKILL.md"
  - "skills/references/chantier-tracking.md"
  - "docs/technical/skill-runtime-and-lifecycle.md"
  - "README.md"
  - "shipflow-spec-driven-workflow.md"
  - "site/src/content/skills/sf-bug.md"
  - "skills/REFRESH_LOG.md"
depends_on:
  - artifact: "specs/professional-bug-management.md"
    artifact_version: "1.0.0"
    required_status: "ready"
  - artifact: "docs/technical/skill-runtime-and-lifecycle.md"
    artifact_version: "unknown"
    required_status: "draft"
supersedes: []
evidence:
  - "User request 2026-05-03: create sf-bug because the professional bug loop is already defined but not orchestrated."
  - "Professional Bug Management shipped the three-layer model: TEST_LOG.md, BUGS.md, bugs/BUG-ID.md, and test-evidence/BUG-ID/."
  - "Existing skills own individual phases: sf-test logs/retests, sf-fix fixes, sf-auth-debug and sf-browser gather evidence, sf-verify gates closure, sf-ship reports bug risk."
next_step: "none"
---

# Spec: sf-bug Professional Bug Loop Orchestrator

## Title

sf-bug Professional Bug Loop Orchestrator

## Status

ready

## User Story

As a ShipFlow operator managing bugs across sessions, I want one `sf-bug` entrypoint that routes intake, dossier state, fix attempts, retests, verification, and ship risk, so the professional bug loop is followed without manually remembering every command.

## Minimal Behavior Contract

`sf-bug` is the bug lifecycle orchestrator. It must inspect the current bug context, choose the next correct existing skill, and preserve the professional bug model. It must not duplicate the internals of `sf-test`, `sf-fix`, `sf-auth-debug`, `sf-browser`, `sf-verify`, or `sf-ship`. It should make the loop easier to run, not weaker.

Canonical loop:

```text
sf-bug -> sf-test -> bug dossier -> sf-fix -> sf-test --retest -> sf-verify -> sf-ship
```

## Scope In

- Create `skills/sf-bug/SKILL.md`.
- Route bug intake from free text, `BUG-ID`, `--retest`, `--close`, `--ship`, and empty dashboard-like usage.
- Read `BUGS.md` and `bugs/BUG-ID.md` when present.
- Pick the next command based on bug status, severity, project development mode, and evidence needs.
- Preserve dossier-first behavior and redaction/security rules from Professional Bug Management.
- Update help, workflow doctrine, technical lifecycle docs, public skill page, and chantier taxonomy.
- Publish current-user Claude/Codex runtime links for `sf-bug`.

## Scope Out

- Replace `sf-test`, `sf-fix`, `sf-auth-debug`, `sf-browser`, `sf-verify`, `sf-ship`, or `sf-docs`.
- Build a UI, global bug registry, external tracker sync, or migration tool.
- Close bugs without retest evidence or explicit `closed-without-retest` exception.
- Store raw sensitive evidence or large logs inline.

## Ownership Boundaries

- `sf-test` owns manual QA, failed-test capture, retest history, and compact test logs.
- `sf-fix` owns diagnosis and fix attempts.
- `sf-auth-debug` owns auth/session/OAuth/browser-auth diagnosis.
- `sf-browser` owns one-off non-auth browser evidence.
- `sf-verify` owns final closure and coherence gates.
- `sf-ship` owns commit/push and bug-risk reporting.
- `sf-bug` owns orchestration, status interpretation, and next-step routing.

## Mode Contract

- Empty arguments: summarize actionable open bugs and recommend the highest-priority next command.
- `BUG-ID`: read `BUGS.md` and `bugs/BUG-ID.md`, interpret status, and route.
- Free text: route to `/sf-test [scope]` for observed failures needing durable capture, or `/sf-fix [summary]` only when the bug is already actionable enough for direct intake.
- `--retest BUG-ID`: route to `/sf-test --retest BUG-ID`.
- `--fix BUG-ID`: route to `/sf-fix BUG-ID`.
- `--verify BUG-ID`: route to `/sf-verify BUG-ID`.
- `--ship BUG-ID`: require verification-compatible state first, then route to `/sf-ship BUG-ID` or block with bug risk.
- `--close BUG-ID`: refuse direct closure unless dossier has passing retest or an explicit closure exception route is chosen.

## Stop Conditions

- Missing or malformed `BUG-ID` dossier when the requested mode depends on it.
- Conflicting `BUGS.md` index and dossier status without enough evidence to reconcile safely.
- User asks to close a bug without retest evidence or visible exception.
- Evidence includes secrets, cookies, tokens, private payloads, production PII, raw headers, or unredacted screenshots.
- The next step would mutate production or run destructive reproduction without explicit approval.
- High/critical bug is still open and user asks to ship as clean.

## Acceptance Criteria

- [x] AC 1: Given no `sf-bug` skill exists, when the skill is created, then it has compact frontmatter and a clear orchestration mission.
- [x] AC 2: Given a `BUG-ID`, when `sf-bug` runs, then it reads the compact index and dossier before routing.
- [x] AC 3: Given a bug is `fix-attempted`, when `sf-bug` routes, then the next step is retest, not closure.
- [x] AC 4: Given a bug is `fixed-pending-verify`, when `sf-bug` routes, then the next step is verification before closure or ship.
- [x] AC 5: Given a high/critical bug is open, when `sf-bug --ship BUG-ID` runs, then it blocks clean shipping or reports partial risk.
- [x] AC 6: Given auth/session/OAuth evidence is needed, when `sf-bug` triages, then it routes to `sf-auth-debug`; non-auth browser proof routes to `sf-browser`.
- [x] AC 7: Given current-user runtime skill links are checked, then Claude and Codex symlinks for `sf-bug` resolve to the ShipFlow skill.
- [x] AC 8: Given public skill discovery changed, then help, README/workflow docs, technical lifecycle docs, chantier tracking, and the public skill page mention `sf-bug`.

## Validation Plan

- `tools/shipflow_sync_skills.sh --repair --skill sf-bug`
- `tools/shipflow_sync_skills.sh --check --skill sf-bug`
- `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
- `python3 tools/shipflow_metadata_lint.py specs/sf-bug-professional-bug-loop-orchestrator.md README.md shipflow-spec-driven-workflow.md docs/technical skills/references/chantier-tracking.md`
- `npm --prefix site run build`
- Focused `rg` checks for `sf-bug`, bug routing, and stale duplicate ownership wording.

## Security Notes

Bug orchestration touches evidence and may reference sensitive runtime failures. `sf-bug` must preserve the existing redaction rules and never persist raw secrets, cookies, tokens, private payloads, raw request headers, production PII, or screenshots that reveal sensitive data.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-05-03 10:04:53 UTC | sf-spec | GPT-5 Codex | Created ready spec for sf-bug professional bug loop orchestrator | ready | /sf-skill-build sf-bug |
| 2026-05-03 10:04:53 UTC | sf-ready | GPT-5 Codex | Readiness accepted from bounded user request and existing shipped Professional Bug Management contract | ready | /sf-skill-build sf-bug |
| 2026-05-03 10:12:30 UTC | sf-skill-build | GPT-5 Codex | Created sf-bug skill contract, public page, docs/help updates, runtime links, and validation pass | implemented | /sf-ship "add sf-bug professional bug orchestrator" |
| 2026-05-03 11:40:29 UTC | sf-ship | GPT-5 Codex | Closed trackers, reran validation, staged scoped sf-bug changes, and shipped the bug lifecycle orchestrator | shipped | none |

## Current Chantier Flow

- `sf-spec`: done, ready spec created.
- `sf-ready`: ready by bounded scope and existing professional bug loop doctrine.
- `sf-start`: implemented through `sf-skill-build`.
- `sf-verify`: passed by focused validation against this spec.
- `sf-end`: folded into full `sf-ship end` bookkeeping.
- `sf-ship`: shipped.

Next step: none
