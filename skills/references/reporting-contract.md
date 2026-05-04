---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipFlow
created: "2026-05-03"
updated: "2026-05-04"
status: active
source_skill: sf-build
scope: skill-reporting-contract
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/*/SKILL.md
  - skills/references/chantier-tracking.md
  - specs/
depends_on:
  - artifact: "specs/skill-reporting-modes-and-compact-reports.md"
    artifact_version: "1.1.0"
    required_status: ready
supersedes: []
evidence:
  - "User decision 2026-05-03: concise user reports by default, detailed agent reports by explicit mode."
  - "User decision 2026-05-04: user reports should organize ship status as outcome, evidence, then limits, match the user's active language, and allow a few sober status emojis."
next_review: "2026-06-04"
next_step: "/sf-verify skill reporting modes"
---

# Reporting Contract

## Purpose

This reference defines the default final-report shape for ShipFlow skills.

The goal is to reduce user-facing noise without weakening traceability. Successful runs should be short. Failed, blocked, partial, or security-sensitive runs should include enough detail to act safely.

## Report Modes

Default mode is `report=user`.

Use `report=user` when:

- the skill is launched directly by the operator
- no explicit report mode is provided
- the run succeeds and the user only needs outcome, checks, risk, and next step

Use `report=agent` when:

- an orchestrator needs a handoff report for another agent
- the user asks for `handoff`, `verbose`, `full-report`, or `agent report`
- the next step depends on detailed file lists, validation matrices, evidence, or unresolved gate state

Do not infer caller identity from runtime state. If a master skill wants a detailed downstream report, it must pass `report=agent` or an equivalent explicit handoff flag.

## User Mode

Keep the final report compact and outcome-first.

Match the user's active language for user-facing labels and explanatory
sentences. Stable commands, file paths, status values, and machine-readable
contract labels may stay in English when translation would weaken traceability.

Use a few status emojis when they improve scanning, not as decoration. Good
defaults are `🚀` for pushed/shipped, `✅` for passed checks, `⚠️` for limits or
risk, `📝` for docs/bookkeeping, and `🎯` for final lifecycle completion. Do
not decorate every line, and keep agent/handoff reports mostly plain except for
status markers.

For ship reports, organize user-mode text as:

1. outcome: commit, branch, push, and repo state
2. evidence: checks, build proof, browser/prod/manual proof, or docs evidence
3. limits: partial validation, missing bug gate, unknown development mode, or
   remaining action

For successful ship/close flows, combine push, repo state, checks, and bookkeeping into one line when possible:

```text
🚀 Pushed to origin/main. Repo clean. ✅ Checks passed. 📝 Tasks/Changelog updated.
```

Use these check summaries:

- `All checks passed ✅` when all attempted or required checks passed.
- `✅ Checks passed: <short list>` when naming the checks is clearer than a generic success line.
- `All checks passed except: <check>, <check>` only when the run legitimately continues despite accepted or non-blocking gaps.
- `Checks skipped: <reason>` when checks were intentionally skipped.
- `Checks failed: <check>` when the run is blocked or not shipped.

Only include sections that change the user's next decision:

- result
- checks summary
- bug/security/risk gate when non-empty or relevant
- documentation/public-content gap when relevant
- next step only when it is real
- chantier block only when a chantier is in scope or explicitly non-traced

Translate internal gate names into their user consequence when possible. Prefer
`⚠️ Limites: pas de BUGS.md, donc risque bug non evalue` over a bare
`Bug risk gate: not assessed` when the active user language is French.

Omit empty or redundant lines such as `Reste a faire: none`, `Prochaine etape: none`, `Trace spec: ecrite`, and `Verdict <skill>` when the heading or status already says the same thing.

## Agent Mode

Agent mode may include:

- files changed
- commands run
- validation matrices
- evidence references
- detailed phase gates
- documentation/editorial plans
- unresolved risks with owner and next command
- full chantier trace metadata

Agent mode must still avoid dumping raw secrets, cookies, tokens, private logs, or unnecessary bulk output.

## Compact Chantier Block

Use this block in user mode:

```text
## Chantier

specs/example.md

Flux: sf-spec ✅ -> sf-ready ✅ -> sf-start ✅ -> sf-verify ✅ -> sf-end ✅ -> sf-ship ✅🎯
Reste a faire: <only if non-empty>
Prochaine etape: <only if non-empty>
```

Use `non applicable: <reason>` or `non trace: <reason>` in place of the spec path when no spec is written.

Use fuller chantier metadata only in `report=agent`, when blocked, or when another agent needs the trace state.

## Audit Reports

Audit skills still report findings first.

In `report=user`, use:

```text
## Audit: <scope>

Result: <clear / issues found / blocked>
Top findings:
- <severity> <file:line or area> - <issue>

Proof gaps: <short list or none>
Chantier potentiel: <oui/non/incertain> - <reason>
Next step: <command or action, only if real>
```

For large global audits, keep the project/domain matrix only when it helps compare projects. Prefer top findings and systemic patterns over exhaustive per-file detail in the user-facing closeout.

In `report=agent`, include the detailed domain checklist output, scoring matrix, command evidence, assumptions, confidence limits, and handoff notes.

## Failure Rule

Concise does not mean vague. If a run is blocked, partial, or risky, include:

- the blocking gate
- the concrete evidence
- the safest next action
- whether the current work can or cannot ship
