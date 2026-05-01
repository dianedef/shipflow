---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipFlow
created: "2026-05-01"
updated: "2026-05-01"
status: reviewed
source_skill: sf-start
scope: code-docs-map
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - docs/technical/
  - skills/references/technical-docs-corpus.md
  - shipflow-spec-driven-workflow.md
depends_on:
  - artifact: "docs/technical/README.md"
    artifact_version: "1.0.0"
    required_status: reviewed
supersedes: []
evidence:
  - "Repository inventory and ready spec task map."
next_review: "2026-06-01"
next_step: "/sf-docs technical audit"
---

# Code Docs Map

## Purpose

This is the canonical map from ShipFlow code paths to technical docs, validation checks, and documentation update triggers. The Reader uses it to produce a `Documentation Update Plan`; executors and integrators apply the resulting documentation updates.

Shared files in this map are sequential integration files. Do not assign concurrent edits to `code-docs-map.md`, `AGENT.md`, `CONTEXT.md`, `GUIDELINES.md`, `shipflow-spec-driven-workflow.md`, or `tools/shipflow_metadata_lint.py` unless a ready spec defines a non-overlapping strategy.

## Map

| Path pattern | Subsystem | Primary technical doc | Secondary docs | Required validation | Docs update trigger |
| --- | --- | --- | --- | --- | --- |
| `shipflow.sh` | Runtime CLI | `docs/technical/runtime-cli.md` | `CONTEXT-FUNCTION-TREE.md`, `ARCHITECTURE.md` | `bash -n shipflow.sh`; focused CLI smoke when behavior changes | Entrypoint, sourcing, menu dispatch, startup, or visible CLI behavior changes |
| `lib.sh` | Runtime CLI | `docs/technical/runtime-cli.md` | `CONTEXT-FUNCTION-TREE.md`, `GUIDELINES.md` | `bash -n lib.sh`; relevant function smoke or grep proof | PM2/Flox/Caddy/DuckDNS behavior, validation, dashboard, health, publish, or environment lifecycle changes |
| `config.sh` | Runtime CLI | `docs/technical/runtime-cli.md` | `README.md` | `bash -n config.sh`; config validation smoke when changed | Config variable, default, or validation contract changes |
| `local/**` | Local tunnels and MCP login | `docs/technical/local-tunnels-and-mcp-login.md` | `local/README.md`, `README.md` | `bash -n local/*.sh`; PowerShell syntax review when `.ps1` changes | SSH target, identity path, tunnel lifecycle, MCP OAuth, or local UX changes |
| `install.sh` | Installer and user scope | `docs/technical/installer-and-user-scope.md` | `README.md`, `GUIDELINES.md` | `bash -n install.sh`; dry-run/review of touched installer branch | Root/user split, symlink, alias, MCP config, package install, or destructive behavior changes |
| `skills/**/SKILL.md` | Skill runtime and lifecycle | `docs/technical/skill-runtime-and-lifecycle.md` | `shipflow-spec-driven-workflow.md`, `skills/references/technical-docs-corpus.md` | `python3 tools/skill_budget_audit.py --skills-root skills --format markdown` when skill surfaces change | Skill routing, lifecycle, validation, documentation gate, or model/topology behavior changes |
| `skills/references/**` | Skill references | `docs/technical/skill-runtime-and-lifecycle.md` | `skills/references/technical-docs-corpus.md` | Metadata lint for references with frontmatter; targeted rg checks | Reference doctrine or path-resolution behavior changes |
| `templates/artifacts/**` | Artifact metadata and linter | `docs/technical/artifact-metadata-and-linter.md` | `shipflow-metadata-migration-guide.md` | `python3 tools/shipflow_metadata_lint.py templates/artifacts` | Template field, artifact type, or required metadata changes |
| `tools/shipflow_metadata_lint.py` | Artifact metadata and linter | `docs/technical/artifact-metadata-and-linter.md` | `shipflow-metadata-migration-guide.md` | `python3 tools/shipflow_metadata_lint.py --help`; targeted lint command | Required fields, statuses, artifact types, default targets, or parse behavior changes |
| `tools/codebase-mcp/**` | Codebase MCP | `docs/technical/codebase-mcp.md` | `tools/codebase-mcp/README.md`, `tools/codebase-mcp/TIPS.md` | Python syntax check and focused MCP tool behavior review | Context budget, tool names, file indexing, memory, or setup behavior changes |
| `site/**` | Public site and content runtime | `docs/technical/public-site-and-content-runtime.md` | `CONTENT_MAP.md`, `site/README.md` | `npm --prefix site run build` when practical | Public route, public docs, skill page, content boundary, or publishing behavior changes |
| `CONTENT_MAP.md` | Public content routing | `docs/technical/public-site-and-content-runtime.md` | `README.md`, `shipflow-spec-driven-workflow.md` | Metadata lint; link/path review | Public surface role, content destination, or cross-surface update rule changes |
| `AGENT.md`, `AGENTS.md` | Agent entrypoint | `docs/technical/skill-runtime-and-lifecycle.md` | `docs/technical/README.md` | `test ! -e AGENTS.md || { test -L AGENTS.md && test "$(readlink AGENTS.md)" = "AGENT.md"; }` | Agent routing, technical docs pointer, or compatibility alias changes |
| `CONTEXT.md`, `CONTEXT-FUNCTION-TREE.md` | Context layer | `docs/technical/runtime-cli.md` | `docs/technical/README.md` | Metadata lint; path existence review | Entrypoint, hotspot, file role, or code navigation changes |
| `ARCHITECTURE.md`, `GUIDELINES.md` | Global technical contracts | `docs/technical/decisions.md` | `docs/technical/README.md` | Metadata lint; dependency version review | Invariant, architecture, technical doctrine, or doc-maintenance rule changes |
| `specs/**` | Chantiers | `docs/technical/skill-runtime-and-lifecycle.md` | `docs/technical/decisions.md` | Metadata lint for changed spec; chantier flow review | Workflow, linked system, validation, or docs impact requirements change |

## Documentation Update Plan Format

```markdown
## Documentation Update Plan

- Code changed: `path/or/pattern`
- Subsystem: `name`
- Primary technical doc: `docs/technical/example.md`
- Secondary docs: `...`
- Required action: `none | review | update | create`
- Priority: `low | medium | high`
- Reason: `why this doc is impacted`
- Owner role: `executor | integrator`
- Parallel-safe: `yes | no`
- Notes: `constraints or blockers`
```

## Reader Rules

- The Reader diagnoses documentation impact; it does not become the default docs executor.
- A mapped code change requires a docs update or a written no-impact justification.
- Missing map coverage is a docs-planning failure and must be reported.
- Shared map and entrypoint docs are not parallel-safe.
- `docs/technical/` is internal-only in v1 and must not be published as site content.

## Maintenance Rule

Update this map whenever a code area, technical doc, validation command, or docs update trigger changes. This file is shared infrastructure; edit it sequentially during final integration.
