---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipFlow
created: "2026-05-01"
updated: "2026-05-01"
status: reviewed
source_skill: sf-start
scope: installer-and-user-scope
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - install.sh
  - README.md
  - local/install.sh
depends_on:
  - artifact: "README.md"
    artifact_version: "0.1.0"
    required_status: draft
  - artifact: "GUIDELINES.md"
    artifact_version: "1.2.0"
    required_status: reviewed
supersedes: []
evidence:
  - "README installer section and install.sh function inventory."
next_review: "2026-06-01"
next_step: "/sf-docs technical audit installer"
---

# Installer And User Scope

## Purpose

This doc covers `install.sh` and the root/user boundary for ShipFlow setup. Read it before changing system dependencies, global binaries, aliases, skill links, Codex/Claude config, MCP registration, or `~/shipflow_data` bootstrap behavior.

## Owned Files

| Path | Role | Edit notes |
| --- | --- | --- |
| `install.sh` | Root-level server bootstrap and per-user setup | Preserve idempotence and explicit root-only behavior |
| `README.md` | Operator install contract | Update when commands, privilege, or installed tooling changes |
| `local/install.sh`, `local/install_local.ps1` | Workstation-side setup | Keep separate from root server install assumptions |
| `.env.example` | Example configuration | Keep secrets as placeholders only |

## Entrypoints

- `sudo ./install.sh`: server installer.
- `setup_user`: per-user configuration for eligible users.
- `configure_*_mcp`: Claude/Codex MCP provider setup.
- `configure_skills`, `configure_aliases`, `configure_data`: user workflow setup.

## Control Flow

```text
sudo ./install.sh
  -> verify root scope
  -> install system tools
  -> configure global commands
  -> collect eligible users
  -> setup_user
  -> write aliases, skill links, MCP config, Codex config, shipflow_data
  -> generate install report
```

## Invariants

- Server install is root-level and should fail clearly without root.
- Daily work should run under an operational user, not by forcing all state into root.
- Existing user config must be preserved outside ShipFlow-managed blocks.
- Symlinks and aliases should be idempotent and updated consistently.
- Installer errors should stop before partial or misleading success.

## Failure Modes

- Live downloads or package installers can fail partially; messages must identify the failing step.
- `--only` or component-scoped install paths can leave stale aliases or symlinks if final synchronization is skipped.
- Missing runtime tools should produce direct diagnostics, not secondary shell errors.
- Incorrect user targeting can install private workflow config for the wrong account.

## Security Notes

- Do not paste tokens, private MCP credentials, or shell config secrets into docs.
- Treat root-level writes and `/usr/local` changes as high-impact.
- Preserve non-destructive validation paths for installer changes.

## Validation

```bash
bash -n install.sh local/install.sh
rg -n "configure_aliases|configure_skills|configure_data|setup_user|collect_target_users|configure_codex" install.sh
```

For behavioral changes, prefer a disposable host/container or a narrowly scoped installer dry run before claiming install success.

## Reader Checklist

- `install.sh` changed -> review this doc and `README.md`.
- Alias/symlink behavior changed -> check local and server install docs.
- MCP config changed -> check provider docs references and remote login docs.
- User targeting changed -> check installer ownership specs.

## Maintenance Rule

Update this doc when install privilege, user targeting, package/tool list, symlink/alias behavior, MCP setup, Codex/Claude config, or `shipflow_data` bootstrap behavior changes.
