---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipFlow + dotfiles
created: "2026-04-28"
created_at: "2026-04-28 14:15:00 UTC"
updated: "2026-04-28"
updated_at: "2026-04-28 14:15:00 UTC"
status: draft
scope: cross-repository
owner: ShipFlow maintainer
user_story: "En tant qu'operateur qui initialise un serveur de travail, je veux une separation claire entre l'installation du tooling generique et l'installation IA/code, afin d'eviter les conflits de droits, les doublons et les configurations appliquees au mauvais utilisateur."
confidence: medium
risk_level: medium
security_impact: yes
docs_impact: yes
linked_repositories:
  - ShipFlow
  - dotfiles
linked_systems:
  - shipflow/install.sh
  - shipflow/specs/install-user-targeting.md
  - dotfiles/install.sh
  - dotfiles/lib.sh
evidence:
  - "shipflow/install.sh installe aujourd'hui des dependances systeme et configure root + tous les comptes /home, mais n'installe pas explicitement Claude Code ni OpenAI Codex."
  - "dotfiles/install.sh installe aujourd'hui du tooling terminal, des outils IA via npm, des configs Claude/Codex/MCP, et peut creer un utilisateur non-root en mode root interactif."
  - "User request: dotfiles should focus on generic tooling; ShipFlow should own AI/code/developpement actif responsibilities."
next_step: "Aligner les scripts et README sur cette spec avant implementation."
---

# Spec: Ownership d'installation entre dotfiles et ShipFlow

## Title

Separation des responsabilites d'installation entre `dotfiles` et `ShipFlow`

## Status

draft

## Problem

Les deux repos installent ou configurent aujourd'hui des elements proches:
- `dotfiles` installe des outils terminal/editor, mais aussi des outils IA (`claude`, `codex`, MCP, aliases IA).
- `ShipFlow` configure les espaces Claude/Codex/skills/MCP, mais installe aussi plusieurs CLIs globales et configure automatiquement `root` + tous les utilisateurs `/home`.

Cette superposition rend flou:
- qui installe les binaires IA,
- qui configure `~/.claude` et `~/.codex`,
- quel script gere la creation ou la recommandation d'un utilisateur non-root,
- quel script a le droit de toucher `root`,
- quels packages doivent etre globaux, user-local, ou propres a un projet.

## Desired Direction

`dotfiles` doit etre le bootstrap de tooling generique. Il prepare un environnement de shell/developpement confortable, portable et non specialise IA.

`ShipFlow` doit etre le bootstrap IA/code/developpement actif. Il possede les assistants IA, les MCP, les skills, les conventions Claude/Codex, et les donnees de travail ShipFlow.

Les deux scripts doivent etre complementaires, pas concurrents.

## Ownership Policy

### dotfiles owns: generic tooling

`dotfiles` est responsable de:
- shell integration: `.bashrc`, aliases generiques, PATH.
- terminal/editor/file tooling: `nvim`, `fzf`, `starship`, `zoxide`, `yazi`, `ranger`, fonts.
- generic developer utilities: `git`, `gh`, `curl`, `wget`, `ripgrep`, `fd`, `bat`, `lsd`, `trash-cli`.
- runtime managers or generic runtimes when needed for tooling: `nvm`, `node`, `npm` prefix user-local.
- user-local installation defaults: `~/.local/bin`, `~/.npm-global`, `~/.config`.
- optional creation or preparation of the operational non-root user during first server bootstrap.

`dotfiles` must not own:
- Claude Code or OpenAI Codex agent configuration.
- MCP server registration for Claude/Codex.
- ShipFlow skills, agent skills, or active AI workflow config.
- project dependency installs (`npm install`, `pnpm install`, etc. inside an app).
- blanket configuration of every `/home/*` profile.

### ShipFlow owns: AI, code agents, active development

`ShipFlow` est responsable de:
- Claude Code / Codex install policy or validation.
- `~/.claude`, `~/.codex`, skills, MCP servers, statusline, agent settings.
- ShipFlow aliases and active workflow entrypoints (`shipflow`, `sf`, optional `co` if Codex is in scope).
- `~/shipflow_data` and active development metadata.
- AI/code CLIs when they are part of the ShipFlow workflow: `claude`, `codex`, MCP helper CLIs, agent-specific tooling.
- explicit user targeting for profiles that receive AI/code configuration.

`ShipFlow` must not own:
- generic terminal/editor dotfiles.
- OS-level bootstrap unrelated to AI/code workflow, except where required by ShipFlow runtime.
- project dependency installation outside a clearly selected project context.
- automatic mutation of all users unless explicitly selected.

## Scope Model

Every install action must be classified before implementation:

- **System/global scope**: packages or services shared by the machine.
  - Requires root or sudo.
  - Examples: apt packages, system services, `/usr/local/bin`, `/opt`.
  - Must be minimized and documented.

- **User scope**: configuration or tools for one operational profile.
  - Uses `$HOME`, `~/.local/bin`, `~/.npm-global`, `~/.config`, `~/.claude`, `~/.codex`.
  - Must target one explicit user or a selected user list.

- **Project scope**: app dependencies and generated app state.
  - Runs inside a project directory.
  - Must be driven by the project package manager and lockfiles.
  - Must not be installed globally by either bootstrap script.

## User Policy

Root is an installer/admin account, not the daily working account.

This is not tied to one cloud provider. Server images differ:
- Oracle images may provide `opc`.
- Ubuntu images may provide `ubuntu`.
- Amazon Linux images may provide `ec2-user`.
- Debian images may provide `debian`.
- Hetzner or manual installs may start with only `root`.

Therefore the scripts must detect users by system state, not by hardcoded usernames.

Target behavior:
- If running as root on a new server, detect whether at least one regular non-root operational user exists.
- If no suitable user exists, prompt the operator to create one before user-scope configuration.
- If suitable users exist, prompt which user(s) should receive user-scope configuration.
- Do not silently configure every `/home/*` profile.
- User-scope configuration must target:
  - current invoking user,
  - selected existing users,
  - newly created operational user,
  - or all detected users including `root`.

Creation policy:
- `dotfiles` may own the first-server non-root user bootstrap because it prepares the generic shell/tooling environment.
- `ShipFlow` should not independently create users by default; it should detect, explain, and either reuse the selected user or defer to the bootstrap path.
- If ShipFlow does gain user creation later, it must use the same contract and not duplicate dotfiles behavior.

The prompt must explain the reason in plain language:
- `root` can change the whole machine and is appropriate for system package installation.
- daily work as `root` increases the blast radius of mistakes, generated commands, editor actions, package installs, and credential writes.
- a regular non-root user keeps day-to-day tools, secrets, config, and project files scoped to the operator account.
- sudo can still be used deliberately when an admin action is needed.

## User Detection Contract

A "regular operational user" is a local account that:
- exists in `/etc/passwd`,
- has a valid home directory,
- has a login shell suitable for interactive work,
- is not `root`,
- is not a system/service account.

Detection must be provider-neutral:
- enumerate real local users rather than assuming `ubuntu`, `opc`, `debian`, or `ec2-user`,
- display detected candidates with username, home, shell, and sudo/group status when available,
- allow manual entry of a username if the operator knows the desired account.

Interactive choices should include:
- create a new operational user,
- configure all detected users, including `root`,
- configure selected users from the detected list.

Recommended selection:
- `root` + the main non-root operational user.

This keeps the installer small while still supporting the important cases:
- full compatibility / broad install,
- explicit per-user targeting,
- root access to installed user-level tools when the operator deliberately selects it.

Non-interactive mode must be explicit through env vars or flags. It may use `all-users` or `user-list`, matching the two interactive modes.

## Installer Communication Contract

The scripts must inform the operator throughout installation:
- current scope: system/global, user, or project,
- effective user: root, invoking sudo user, selected target user,
- why root is being used for system steps,
- why user-level configuration is being applied to a selected non-root account,
- what will not be installed globally,
- final summary of users configured and users skipped.

Public documentation must include the same doctrine:
- supported server shape is "root for setup + regular user for daily work",
- cloud images may ship different default users,
- no username is assumed,
- user selection/creation is part of first-run bootstrap,
- root-only daily work is intentionally discouraged.

## Current State Assessment

### dotfiles

Already aligned:
- Has `USER_LOCAL_MODE` and installs many tools into `~/.local/bin` / `~/.npm-global`.
- Can work without sudo for user-local installs.
- Has an interactive non-root user creation path when launched as root.
- Mostly configures the current `$HOME`, not all `/home/*` users.

Needs alignment:
- Moves or stops owning `claude`, `codex`, MCP, and AI aliases/configs.
- Stops running ShipFlow installer automatically unless explicitly requested.
- Documents that it is generic tooling only.
- Ensures root execution creates/prepares a non-root user, then runs user-scope setup under that user.

### ShipFlow

Already aligned:
- Owns Claude/Codex config, skills, MCP, statusline, ShipFlow aliases, `shipflow_data`.
- Has a draft spec for explicit user targeting.

Needs alignment:
- Stops configuring `root + all /home/*` by default.
- Defines whether it installs `claude` and `codex` binaries or only validates them.
- Moves generic tooling responsibilities out of ShipFlow unless required by ShipFlow runtime.
- Uses explicit user targeting for all user-scope AI/code configuration.

## Minimal Behavior Contract

For a fresh server:
1. `dotfiles` prepares a non-root operational user and generic tooling.
2. `ShipFlow` configures AI/code workflow for the selected operational user.
3. Root is used only for system/global operations.
4. User-level config is never applied to unselected profiles.
5. Project dependencies are never installed globally by either script.

For an existing workstation:
1. `dotfiles` updates generic tooling for the current user.
2. `ShipFlow` updates AI/code config for the current or explicitly selected user.
3. No script assumes that all `/home/*` accounts are valid targets.

## Scope In

- Shared ownership contract between both repos.
- Classification of install responsibilities.
- Non-root user policy.
- Global/user/project scope definitions.
- Guidance for future implementation and documentation patches.

## Scope Out

- Immediate refactor of either script.
- Exact CLI prompt UX.
- Migration of package installs between repos.
- Removal of current behavior before compatibility strategy is chosen.

## Acceptance Criteria

- [ ] AC1: Documentation states that `dotfiles` owns generic tooling and `ShipFlow` owns AI/code workflow.
- [ ] AC2: Both install scripts classify actions as system/global, user, or project scope.
- [ ] AC3: No user-scope config is applied to all `/home/*` users unless explicitly selected.
- [ ] AC4: Fresh-server bootstrap detects absence of a non-root operational user and prompts or recommends creation.
- [ ] AC5: `dotfiles` no longer silently owns Claude/Codex/MCP configuration once ShipFlow owns that domain.
- [ ] AC6: ShipFlow either installs `claude`/`codex` or validates and explains the missing binaries; the responsibility is explicit.
- [ ] AC7: Project dependencies are never installed globally by either script.
- [ ] AC8: Root remains acceptable for system setup but is not presented as the default daily working user.

## Implementation Notes For Later

- Treat this file as the root cross-repo spec.
- Keep `specs/install-user-targeting.md` as the ShipFlow-specific implementation spec until merged or superseded.
- Before code changes, decide whether AI CLI binary installation moves from `dotfiles` to `ShipFlow`, or whether `ShipFlow` only validates existing binaries.
- Avoid changing both scripts independently without a shared migration note, because current installs have overlapping behavior.

## Open Questions

- Should `ShipFlow` install `claude` and `codex`, or should it require them and provide exact install guidance?
- Should `dotfiles` be allowed to call `shipflow/install.sh`, or should it only print the next command?
- What is the default user target for non-interactive server bootstrap: `all-users` for compatibility, or require explicit `user-list`?
- Should compatibility mode preserve existing broad behavior behind an explicit flag?
