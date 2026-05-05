---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "1.0.2"
project: ShipFlow
created: "2026-05-01"
updated: "2026-05-05"
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
  - "Blacksmith OAuth callback tunnel added for remote CLI auth."
  - "Managed tunnel detection accepts SSH targets before or after -L in process args."
next_review: "2026-06-01"
next_step: "/sf-docs technical audit local"
---

# Local Tunnels And MCP Login

## Purpose

This doc covers the local tools that connect a workstation to a remote ShipFlow server: app tunnels, saved SSH connection state, remote PM2 and Flutter Web `tmux` port discovery, `shipflow-mcp-login` for remote Codex MCP OAuth callbacks, and `shipflow-blacksmith-login` for remote Blacksmith CLI OAuth callbacks.

## Owned Files

| Path | Role | Edit notes |
| --- | --- | --- |
| `local/local.sh` | Interactive local menu for tunnel lifecycle, status, server config, and MCP login | Preserve shared connection file semantics |
| `local/dev-tunnel.sh` | Non-interactive managed tunnel helper | Keep managed PID selection narrow |
| `local/mcp-login.sh` | Remote Codex MCP OAuth login tunnel flow | Do not store OAuth tokens |
| `local/blacksmith-login.sh` | Remote Blacksmith OAuth login tunnel flow | Do not read or store Blacksmith token contents |
| `local/remote-helpers.sh` | SSH target, identity, and remote port helper functions | Validate inputs before building SSH args |
| `local/install.sh`, `local/install_local.ps1` | Local installer scripts | Keep platform-specific assumptions explicit |
| `local/README.md` | Operator-facing setup and troubleshooting | Update when commands or flow change |

## Entrypoints

- `urls` and `tunnel`: shell aliases to `local/local.sh`.
- `shipflow-mcp-login <provider|all>`: launches remote Codex MCP login and opens a temporary callback tunnel.
- `shipflow-blacksmith-login`: launches remote `blacksmith auth login` and opens a temporary callback tunnel.
- `local/dev-tunnel.sh`: direct tunnel helper for scripted or simplified flows.

## Control Flow

```text
local/local.sh
  -> load current connection
  -> fetch remote session identity with animated TTY scan feedback
  -> fetch remote PM2 ports and active Flutter Web tmux ports
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

```text
shipflow-blacksmith-login
  -> run remote blacksmith auth login with BROWSER=echo
  -> extract OAuth callback port
  -> open temporary ssh -L tunnel
  -> open or print Blacksmith URL
  -> wait for remote login completion
  -> verify ~/.blacksmith/credentials exists without reading it
  -> clean up tunnel
```

## Invariants

- SSH target and identity path are validated before use; accepted targets are valid IPv4 addresses, dotted DNS names, exact aliases from `~/.ssh/config`, or `user@host` forms using those host rules.
- Bare SSH identity filenames resolve from the menu launch directory, then `~/.ssh/`, then the user's home directory; the saved identity path should be absolute.
- Local port occupancy is checked before opening a tunnel.
- Managed tunnel stop logic should select ShipFlow-owned tunnels, not broad process patterns.
- Raw SSH process listing is debug-only operator output via `SHIPFLOW_DEBUG=1`.
- Active Flutter Web `tmux` ports are discovered from the server-side
  `SHIPFLOW_FLUTTER_WEB_SESSIONS_FILE` registry and included only when the
  recorded `tmux` session still exists.
- OAuth tokens remain owned by Codex and the provider; ShipFlow only routes the callback.
- Blacksmith auth tokens remain owned by Blacksmith CLI on the remote server;
  ShipFlow only checks credentials-file presence.
- Saved connection state is shared by app tunnels, MCP login, and Blacksmith login.
- Remote SSH helper calls run in batch mode so menu scans fail visibly instead of blocking on hidden SSH prompts.
- The startup session scan is operator feedback only; set `SHIPFLOW_NO_ANIMATION=1` to disable the animated TTY loader.

## Failure Modes

- Callback connection refused usually means the fresh OAuth port was not tunneled.
- Blacksmith `localhost` callback failures have the same root cause as MCP
  OAuth callback failures when the CLI runs remotely and the browser is local.
- Reusing an old OAuth URL can fail because provider URLs and callback ports are per attempt.
- A malformed SSH identity path or target can become an SSH option if validation regresses.
- Duplicate local ports should block before creating partial tunnels.
- A stale Flutter Web registry entry should be ignored by local tunnel tools
  when its `tmux` session is no longer active.

## Security Notes

- Never document or log private hosts, private keys, tokens, callback payloads, cookies, or provider secrets.
- Treat saved connection files as local operator state, not public documentation.
- Provider names must be validated before they are passed to remote commands.

## Validation

```bash
bash -n local/local.sh local/dev-tunnel.sh local/mcp-login.sh local/blacksmith-login.sh local/remote-helpers.sh local/install.sh
rg -n "validate_connection_target|validate_identity_file|check_local_port_free|parse_mcp_oauth_port_from_text" local/
```

PowerShell changes require a separate syntax/manual review on a PowerShell-capable host.

## Reader Checklist

- `local/` changed -> review this doc and `local/README.md`.
- MCP or Blacksmith OAuth flow changed -> review `README.md`, `local/README.md`,
  and the public remote MCP guide if user-visible.
- SSH parsing changed -> run an adversarial validation pass for option injection and malformed key paths.

## Maintenance Rule

Update this doc when saved connection semantics, tunnel lifecycle, remote helper validation, MCP OAuth provider flow, or local operator commands change.
