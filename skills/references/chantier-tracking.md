---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipFlow
created: "2026-04-27"
updated: "2026-04-27"
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
depends_on:
  - artifact: "specs/specs-as-chantier-registry.md"
    artifact_version: "1.0.0"
    required_status: "ready"
supersedes: []
evidence:
  - "Spec specs-as-chantier-registry.md defines specs/ as the global chantier registry."
next_review: "2026-05-27"
next_step: "/sf-verify Specs as chantier registry"
---

# Chantier Tracking Doctrine

`specs/` is the global registry for spec-first chantiers. Do not create a separate registry in `TASKS.md`, `AUDIT_LOG.md`, `PROJECTS.md`, or `shipflow_data`.

## Categories

- `obligatoire`: lifecycle spec-first skills. When a unique chantier spec is identified, read the spec, append or update `Skill Run History`, update `Current Chantier Flow`, and end the user report with a `Chantier` block and `Verdict <skill>: ...`.
- `conditionnel`: cross-cutting skills. Trace only when the run is attached to one unique chantier spec. If no unique spec is available, do not write to any spec and report `Chantier: non applicable` or `Chantier: non trace` with the reason.
- `non-applicable`: helper/session/discovery skills. Do not write to specs. If invoked inside a chantier flow, mention that chantier tracking is non-applicable or not traced and point to the lifecycle next step when useful.

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
```
