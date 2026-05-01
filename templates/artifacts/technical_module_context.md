---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: "[project name]"
created: "YYYY-MM-DD"
updated: "YYYY-MM-DD"
status: draft
source_skill: sf-docs
scope: "[subsystem]"
owner: "[owner]"
confidence: medium
risk_level: medium
security_impact: unknown
docs_impact: yes
linked_systems: []
depends_on: []
supersedes: []
evidence: []
next_review: "YYYY-MM-DD"
next_step: "/sf-docs technical audit"
---

# Technical Module Context: [Subsystem]

## Purpose

[Explain the subsystem in 2-4 sentences. Focus on what an agent must understand before editing code.]

## Owned Files

| Path | Role | Edit notes |
| --- | --- | --- |
| `[path]` | [role] | [constraints] |

## Entrypoints

- `[file or command]`: [when it runs and what it triggers]

## Control Flow

```text
[entry]
  -> [step]
  -> [result]
```

## Invariants

- [Rule that must remain true.]

## Failure Modes

- [Observable failure and expected handling.]

## Security Notes

- [Secrets, permissions, data exposure, destructive operation, or `None`.]

## Validation

```bash
[focused validation command]
```

## Reader Checklist

- [Code path or trigger] -> [doc action]

## Maintenance Rule

Update this doc when [files, entrypoints, invariants, validations, or security constraints] change.
