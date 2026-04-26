---
artifact: architecture_context
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "shipflow"
created: "2026-04-26"
updated: "2026-04-26"
status: reviewed
source_skill: manual
scope: architecture
owner: "unknown"
confidence: high
risk_level: medium
linked_systems:
  - "shipflow.sh"
  - "lib.sh"
  - "config.sh"
  - "install.sh"
  - "local/local.sh"
  - "skills/"
  - "templates/artifacts/"
  - "tools/shipflow_metadata_lint.py"
external_dependencies:
  - "Flox"
  - "PM2"
  - "Caddy"
  - "DuckDNS"
  - "SSH"
invariants:
  - "PM2 cache must be invalidated after state mutations"
  - "Project paths must be validated and absolute"
  - "ShipFlow artifact docs must use versioned metadata"
security_impact: yes
docs_impact: yes
evidence:
  - "Core files and function tree extracted from the repo"
  - "CLAUDE.md documents PM2 caching, port allocation, idempotence, and validation rules"
depends_on:
  - artifact: "GUIDELINES.md"
    artifact_version: "1.0.0"
    required_status: "reviewed"
supersedes: []
next_review: "2026-05-26"
next_step: "/sf-docs audit ARCHITECTURE.md"
---

# Architecture Context

## System Shape

ShipFlow has two connected layers:

- a server-side environment control layer for runtime operations
- a documentation and workflow layer for AI-assisted execution discipline

The repo is not split into small services. It is centered around shell-based orchestration plus Markdown artifact governance.

## Entry Points

- `shipflow.sh` for the main CLI.
- `local/local.sh` for local SSH tunnel operations.
- `install.sh` for server bootstrap and user environment setup.
- `skills/*/SKILL.md` plus templates and linter for workflow execution.

## Runtime Boundaries

- Runtime control lives in shell orchestration and external tools rather than in a long-running application server.
- Process truth lives in PM2.
- Environment isolation lives in Flox.
- Public exposure lives in Caddy and DuckDNS.
- Workflow governance lives in Markdown artifacts, skills, and metadata validation.

## Major Components

- `lib.sh`: main orchestration library and the largest functional hotspot.
- `config.sh`: configuration source and validation layer.
- `local/`: local access and tunnel management.
- `skills/`: task-specific workflows and governance behavior.
- `templates/artifacts/`: normalized artifact structures.
- `tools/shipflow_metadata_lint.py`: executable metadata contract validator.

## Data And Control Flows

- CLI flow: `shipflow.sh` -> `lib.sh` -> menu actions -> PM2/Flox/Caddy operations.
- Local tunnel flow: `local/local.sh` -> SSH connection selection -> remote state inspection -> tunnel lifecycle.
- Doc/workflow flow: skills -> templates -> markdown artifacts -> metadata lint -> verification.

## Data And State

- PM2 state is cached locally for responsiveness and must be invalidated after mutations.
- Secrets and connection state are stored separately from the main workflow docs.
- Decision state is carried in versioned Markdown artifacts, not in operational trackers.

## External Dependencies

- Flox isolates runtimes.
- PM2 owns running process state.
- Caddy and DuckDNS expose public URLs.
- SSH supports remote access and local tunnel flows.

## Invariants

- PM2 mutation without cache invalidation is a correctness bug.
- Unsafe project paths are rejected rather than normalized optimistically.
- Generated or runtime-managed config should not be hand-edited as source of truth.
- Workflow docs are treated as contracts; trackers are not.

## Hotspots

- `lib.sh::env_start`
- `lib.sh::show_dashboard`
- `lib.sh::deploy_github_project`
- `lib.sh::action_publish`
- `local/local.sh::main`

## Known Constraints

- The centralization of logic in `lib.sh` speeds iteration but increases blast radius.
- The architecture depends on shell scripting, so structural clarity depends heavily on docs and function indexing.
- Context and decision artifacts are necessary because the codebase mixes runtime orchestration and workflow doctrine in one repo.
