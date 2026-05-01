---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipFlow
created: "2026-05-01"
updated: "2026-05-01"
status: reviewed
source_skill: sf-start
scope: codebase-mcp
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - tools/codebase-mcp/
depends_on: []
supersedes: []
evidence:
  - "tools/codebase-mcp/README.md, TIPS.md, and server.py inventory."
next_review: "2026-06-01"
next_step: "/sf-docs technical audit codebase-mcp"
---

# Codebase MCP

## Purpose

This doc covers the local Codebase MCP server under `tools/codebase-mcp/`. The server helps Claude Code retrieve project context, read excerpts, track decisions, and reduce repeated file reads.

## Owned Files

| Path | Role | Edit notes |
| --- | --- | --- |
| `tools/codebase-mcp/server.py` | MCP server implementation | Preserve repo-local file boundaries and read budgets |
| `tools/codebase-mcp/README.md` | Install and tool reference | Update when tools or setup change |
| `tools/codebase-mcp/TIPS.md` | Usage guidance | Update when workflow guidance changes |

## Entrypoints

- MCP config command: `python3 tools/codebase-mcp/server.py /absolute/path/to/project`.
- Core loop: `context_continue`, `context_retrieve`, `context_read`, edit registration, session wrap.
- Retrieval helpers: symbol listing, token counting, usage logging, decision storage.

## Invariants

- The server is local, not cloud-hosted.
- Project paths should stay scoped to the configured project root.
- File reads are excerpted and budgeted.
- Cache invalidation follows edits through `context_register_edit`.
- Generated memory should avoid secrets and private logs.

## Failure Modes

- Reading too broadly can defeat token-saving goals.
- Stale cache after edits can make future context wrong.
- Tool names or contracts drifting from README/TIPS makes agent usage unreliable.
- Ignoring large/generated directories can accidentally index build output or dependencies.

## Security Notes

- Do not send file contents to a network service from this server.
- Do not persist secrets, cookies, tokens, or credentials as decisions or session summaries.
- Keep ignore lists current for generated and dependency directories.

## Validation

```bash
python3 -m py_compile tools/codebase-mcp/server.py
rg -n "context_continue|context_retrieve|context_read|context_register_edit|session_wrap" tools/codebase-mcp
```

## Reader Checklist

- `server.py` tool behavior changed -> update README and TIPS.
- Budget, cache, or ignore behavior changed -> update this doc.
- MCP install command changed -> update README and any installer references.

## Maintenance Rule

Update this doc when MCP tool names, setup, budgets, indexing, cache invalidation, storage behavior, or security boundaries change.
