---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipFlow
created: "2026-05-01"
updated: "2026-05-01"
status: reviewed
source_skill: sf-start
scope: local-tunnels-and-mcp-login
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - local/
  - local/README.md
  - README.md
depends_on:
  - artifact: "GUIDELINES.md"
    artifact_version: "1.2.0"
    required_status: reviewed
supersedes: []
evidence:
  - "local/README.md and function inventory for local scripts."
next_review: "2026-06-01"
next_step: "/sf-docs technical audit local"
---

# Local Tunnels And MCP Login

## Purpose

This doc covers the local tools that connect a workstation to a remote ShipFlow server: app tunnels, saved SSH connection state, remote PM2 port discovery, and `shipflow-mcp-login` for remote Codex MCP OAuth callbacks.

## Owned Files

| Path | Role | Edit notes |
| --- | --- | --- |
| `local/local.sh` | Interactive local menu for tunnel lifecycle, status, server config, and MCP login | Preserve shared connection file semantics |
| `local/dev-tunnel.sh` | Non-interactive managed tunnel helper | Keep managed PID selection narrow |
| `local/mcp-login.sh` | Remote Codex MCP OAuth login tunnel flow | Do not store OAuth tokens |
| `local/remote-helpers.sh` | SSH target, identity, and remote PM2 helper functions | Validate inputs before building SSH args |
| `local/install.sh`, `local/install_local.ps1` | Local installer scripts | Keep platform-specific assumptions explicit |
| `local/README.md` | Operator-facing setup and troubleshooting | Update when commands or flow change |

## Entrypoints

- `urls` and `tunnel`: shell aliases to `local/local.sh`.
- `shipflow-mcp-login <provider|all>`: launches remote Codex MCP login and opens a temporary callback tunnel.
- `local/dev-tunnel.sh`: direct tunnel helper for scripted or simplified flows.

## Control Flow

```text
local/local.sh
  -> load current connection
  -> fetch remote PM2 ports
  -> validate local port availability
  -> start autossh tunnels
  -> show localhost URLs
```

```text
shipflow-mcp-login
  -> run remote codex mcp login
  -> extract OAuth callback port
  -> open temporary ssh -L tunnel
  -> open or print provider URL
  -> wait for remote login completion
  -> clean up tunnel
```

## Invariants

- SSH target and identity path are validated before use.
- Local port occupancy is checked before opening a tunnel.
- Managed tunnel stop logic should select ShipFlow-owned tunnels, not broad process patterns.
- OAuth tokens remain owned by Codex and the provider; ShipFlow only routes the callback.
- Saved connection state is shared by app tunnels and MCP login.

## Failure Modes

- Callback connection refused usually means the fresh OAuth port was not tunneled.
- Reusing an old OAuth URL can fail because provider URLs and callback ports are per attempt.
- A malformed SSH identity path or target can become an SSH option if validation regresses.
- Duplicate local ports should block before creating partial tunnels.

## Security Notes

- Never document or log private hosts, private keys, tokens, callback payloads, cookies, or provider secrets.
- Treat saved connection files as local operator state, not public documentation.
- Provider names must be validated before they are passed to remote commands.

## Validation

```bash
bash -n local/local.sh local/dev-tunnel.sh local/mcp-login.sh local/remote-helpers.sh local/install.sh
rg -n "validate_connection_target|validate_identity_file|check_local_port_free|parse_mcp_oauth_port_from_text" local/
```

PowerShell changes require a separate syntax/manual review on a PowerShell-capable host.

## Reader Checklist

- `local/` changed -> review this doc and `local/README.md`.
- MCP OAuth flow changed -> review `README.md` and the public remote MCP guide if user-visible.
- SSH parsing changed -> run an adversarial validation pass for option injection and malformed key paths.

## Maintenance Rule

Update this doc when saved connection semantics, tunnel lifecycle, remote helper validation, MCP OAuth provider flow, or local operator commands change.
