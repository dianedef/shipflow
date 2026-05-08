---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "0.4.4"
project: ShipFlow
created: "2026-04-27"
updated: "2026-05-08"
status: draft
source_skill: sf-start
scope: chantier-tracking
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - specs/
  - skills/*/SKILL.md
  - skills/shipflow/SKILL.md
  - skills/sf-deploy/SKILL.md
  - skills/sf-maintain/SKILL.md
  - skills/sf-design/SKILL.md
  - skills/references/reporting-contract.md
  - skills/references/final-report-timestamp.md
  - skills/references/master-workflow-lifecycle.md
depends_on:
  - artifact: "specs/specs-as-chantier-registry.md"
    artifact_version: "1.0.0"
    required_status: "ready"
supersedes: []
evidence:
  - "Spec specs-as-chantier-registry.md defines specs/ as the global chantier registry."
  - "shipflow added as the primary helper router; selected owner skills own durable state and chantier tracing."
  - "sf-deploy added as a lifecycle release orchestrator."
  - "sf-maintain promoted from recurring maintenance source-de-chantier to lifecycle master skill."
  - "Compact user-facing reporting contract added with explicit agent handoff mode."
  - "Master workflow lifecycle reference added: bug work items use bugs/*.md as source of truth; BUGS.md is optional/generated/triage view."
  - "Final report timestamp moved into a shared reporting brick loaded through reporting-contract.md."
  - "sf-design added as an obligatoire lifecycle master skill."
  - "sf-bug clarified as bug lifecycle execution through owner skills and bounded subagents."
next_review: "2026-05-27"
next_step: "/sf-verify Specs as chantier registry"
---

# Chantier Tracking Doctrine

`specs/` is the global registry for spec-first chantiers. Do not create a separate registry in `TASKS.md`, `AUDIT_LOG.md`, `PROJECTS.md`, or `shipflow_data`.

## Two-Axis Classification

Chantier tracking has two separate axes. Do not collapse them into one label.

Trace category answers: may this skill write a run trace into an existing chantier spec?

- `obligatoire`: lifecycle spec-first skills. When a unique chantier spec is identified, read the spec, append or update `Skill Run History`, update `Current Chantier Flow`, and end the user report with the compact `Chantier` block from `skills/references/reporting-contract.md`.
- `conditionnel`: cross-cutting skills. Trace only when the run is attached to one unique chantier spec. If no unique spec is available, do not write to any spec and report `Chantier: non applicable` or `Chantier: non trace` with the reason. Final output still follows `skills/references/reporting-contract.md`.
- `non-applicable`: helper/session/discovery skills. Do not write to specs. If invoked inside a chantier flow, mention that chantier tracking is non-applicable or not traced and point to the lifecycle next step when useful. Non-applicable for spec trace does not forbid non-spec durable artifacts when a skill contract allows them (for example `sf-explore` and `exploration_report`).

Process role answers: can this skill originate, support, steer, or merely inspect a chantier?

- `lifecycle`: creates, readies, executes, verifies, closes, or ships a unique chantier.
- `source-de-chantier`: may reveal work that deserves a new spec when no unique chantier exists.
- `support-de-chantier`: helps execute or document a chantier but should not normally originate one.
- `pilotage`: manages priorities, backlog, tasks, review, or continuation; can route to `sf-spec` on explicit user intent, but does not turn every planning note into a chantier.
- `helper`: read-only or session helper; does not propose a chantier unless the user explicitly asks to formalize one.

`source-de-chantier` is not a trace category. A skill can be `conditionnel` for spec writes and `source-de-chantier` for intake.

## Chantier Potential Threshold

A source skill must evaluate the standard `seuil` for chantier potential before its final report when it finds future work outside a single direct fix.

Use `Chantier potentiel: oui` when at least one of these is true:

- P0/P1 severity, production incident, security/data risk, auth/session breakage, deployment breakage, or critical dependency exposure.
- Multiple files (`plusieurs fichiers`), projects, domains, teams, or workflow phases are affected.
- A product, technical, architecture, migration, pricing, permission, data-retention, or tenant-boundary decision is required.
- The work needs staged execution, rollback/retry planning, validation by another skill, or user/operator confirmation.
- The finding cannot be completed safely as an immediate local fix in the current run.

Use `Chantier potentiel: non` when the finding is a narrow local fix, the current chantier already owns the work, the report is informational only, or the evidence is too weak for a spec. Still name the reason.

Use `Chantier potentiel: incertain` when the evidence is incomplete or the severity/scope is unclear. Name the missing proof and route to exploration, retest, or explicit user selection.

Never open a chantier for every micro-finding, never attach to an ambiguous spec, and never create a new spec directly from a source skill. The next durable step is `/sf-spec ...`.

## Chantier Potentiel Block

Source skills should add this block after their findings and before or near the regular `Chantier` block:

```text
## Chantier potentiel

Chantier potentiel: oui | non | incertain
Titre propose: <short chantier title or None>
Raison: <why this does or does not cross the threshold>
Severite: P0 | P1 | P2 | P3 | unknown
Scope: <files/projects/domains/workflows affected>
Evidence:
- <finding, command, file, URL, or observed behavior>
Spec recommandee: /sf-spec <title and compact context>
Prochaine etape: <next ShipFlow command or explicit none>
```

This block coexists with the compact `Chantier` block. If the source skill is already attached to one unique chantier and the findings remain inside that chantier, use `Chantier potentiel: non` and point back to the current lifecycle next step.

## Role Matrix

| Skill group | Trace category | Process role | Source threshold |
|-------------|----------------|--------------|------------------|
| `sf-spec`, `sf-ready`, `sf-build`, `sf-maintain`, `sf-design`, `sf-deploy`, `sf-start`, `sf-verify`, `sf-end`, `sf-ship` | `obligatoire` | `lifecycle` | Not a source; continue or create the owned chantier through the lifecycle gates. |
| `sf-audit*`, `sf-deps`, `sf-perf` | `conditionnel` | `source-de-chantier` | Major audit findings, P0/P1, cross-domain P2 clusters, or fixes needing a spec. |
| `sf-auth-debug`, `sf-prod`, `sf-check`, `sf-test`, `sf-migrate`, `sf-fix`, `sf-bug` | `conditionnel` | `source-de-chantier` | Incidents, failing flows, migration risk, bug files, bug lifecycle execution, or validation failures beyond a direct fix. |
| `sf-market-study`, `sf-veille`, `sf-research` | `conditionnel` | `source-de-chantier` | Strategic or research output that requires a product, content, architecture, or implementation decision. |
| `sf-docs`, `sf-enrich`, `sf-redact`, `sf-repurpose`, `sf-scaffold`, `sf-changelog`, `sf-design-playground`, `sf-skills-refresh`, `sf-init` | `conditionnel` | `support-de-chantier` | Route to a source or `/sf-spec` only when the user explicitly asks to formalize follow-up work. |
| `sf-tasks`, `sf-backlog`, `sf-priorities`, `sf-review`, `continue` | `conditionnel` | `pilotage` | Do not create a chantier from every note; route only when the user or evidence requires a durable spec. |
| `shipflow`, `sf-context`, `sf-model`, `sf-help`, `sf-status`, `sf-resume`, `sf-explore`, `name` | `non-applicable` | `helper` | Not a source; can recommend or directly hand off to the lifecycle next step when useful. `shipflow` routes only; selected owner skills own durable state and chantier tracing. `sf-explore` may write `exploration_report` artifacts but still must not write chantier spec history. |

## Spec Write Rules

- Before writing, identify exactly one `specs/*.md` file with ShipFlow frontmatter.
- If matching is ambiguous, stop and ask for an explicit spec instead of guessing.
- Preserve all existing metadata and contract sections.
- Add `Skill Run History` if it is missing, using this table:

```markdown
## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
```

- Use the best available model label. If the runtime does not expose it, use `unknown` or the operator-provided name.
- Never invent past runs. Only record the current run or facts already present in the spec/report.

## Final Report Block

Load `$SHIPFLOW_ROOT/skills/references/reporting-contract.md` before producing final output. That contract also loads the shared final-report timestamp brick. Use the compact block in `report=user` and the fuller metadata block only in `report=agent`, blocked runs, or handoffs that need trace state.

Compact user-mode block:

```text
## Chantier

<spec path | non applicable: reason | non trace: reason>

Flux: sf-spec <marker> -> sf-ready <marker> -> sf-start <marker> -> sf-verify <marker> -> sf-end <marker> -> sf-ship <marker>
Reste a faire: <only if non-empty>
Prochaine etape: <only if non-empty>
```

Detailed agent-mode block:

```text
## Chantier

Skill courante: <skill>
Chantier: <spec path | non applicable | non trace>
Trace spec: ecrite | non ecrite | non applicable
Flux:
- sf-spec: <status>
- sf-ready: <status>
- sf-start: <status>
- sf-verify: <status>
- sf-end: <status>
- sf-ship: <status>

Reste a faire:
- <item or None>

Prochaine etape:
- <command or explicit none>

Verdict <skill>:
- <verdict>
Horodatage du verdict: YYYY-MM-DD HH:mm Paris time
```
