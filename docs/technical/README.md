---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipFlow
created: "2026-05-01"
updated: "2026-05-01"
status: reviewed
source_skill: sf-start
scope: technical-docs-index
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - docs/technical/
  - docs/technical/code-docs-map.md
  - AGENT.md
  - CONTEXT.md
depends_on:
  - artifact: "specs/shipflow-technical-documentation-layer-for-ai-agents.md"
    artifact_version: "1.0.0"
    required_status: ready
supersedes: []
evidence:
  - "Spec defines docs/technical as the internal code-proximate documentation layer."
next_review: "2026-06-01"
next_step: "/sf-docs technical audit"
---

# Technical Documentation

## Purpose

`docs/technical/` is the internal code-proximate documentation layer for ShipFlow. It tells agents which durable subsystem doc to read, which files are owned by that subsystem, which invariants must survive edits, and which checks prove the change.

This layer complements the existing docs:

- `ARCHITECTURE.md` stays the global system view.
- `CONTEXT.md` stays the compact operational map.
- `GUIDELINES.md` stays the general engineering doctrine.
- `specs/*.md` stay chantier contracts and run history.
- `docs/technical/*.md` documents durable subsystem behavior near the code.

## Read Order

1. Open `docs/technical/code-docs-map.md` and match the changed path.
2. Open the primary technical doc for that subsystem.
3. Open secondary docs only when the map says the change crosses a boundary.
4. After a code-changing wave, produce a `Documentation Update Plan` from the map.
5. Update impacted docs sequentially unless a ready spec assigns disjoint files to separate executors.

## Docs

| Doc | Open when the task touches |
| --- | --- |
| `code-docs-map.md` | Any code change, Reader pass, final integration, or docs gate |
| `runtime-cli.md` | `shipflow.sh`, `lib.sh`, `config.sh`, PM2/Flox/Caddy/DuckDNS flows |
| `local-tunnels-and-mcp-login.md` | `local/`, SSH tunnels, remote helper scripts, MCP OAuth login |
| `skill-runtime-and-lifecycle.md` | `skills/`, lifecycle skills, references, templates, Reader/Executor rules |
| `artifact-metadata-and-linter.md` | `templates/artifacts/`, `tools/shipflow_metadata_lint.py`, frontmatter contracts |
| `codebase-mcp.md` | `tools/codebase-mcp/` |
| `public-site-and-content-runtime.md` | `site/`, `CONTENT_MAP.md`, public/private doc boundaries |
| `installer-and-user-scope.md` | `install.sh`, root/user setup, aliases, skill links, MCP config |
| `decisions.md` | ADR-style decisions, `decision_record` templates, durable decision routing |

## Non-Coverage

The layer does not create one doc per file. Small legacy files such as menu frontend variants, historical archives, and standalone test fixtures are covered through the closest subsystem doc or through an explicit Reader note when a change proves they need a dedicated doc.

## Validation

Run the checks listed in `code-docs-map.md` for the changed paths. At minimum, technical-doc changes should pass:

```bash
rg -n "Maintenance Rule|Validation|Owned files|Entrypoints" docs/technical templates/artifacts/technical_module_context.md
python3 tools/shipflow_metadata_lint.py docs/technical templates/artifacts/technical_module_context.md
```

## Maintenance Rule

Update this index when a technical doc is added, renamed, removed, or when a major code area gains an explicit non-coverage reason. Keep this file as an index; put subsystem details in the subsystem docs.
