---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipFlow
created: "2026-04-28"
created_at: "2026-04-28 22:27:54 UTC"
updated: "2026-04-29"
updated_at: "2026-04-29 00:41:27 UTC"
status: ready
source_skill: sf-spec
source_model: "GPT-5 Codex"
scope: migration
owner: ShipFlow maintainer
user_story: "En tant qu'operateur ShipFlow qui code au quotidien depuis un compte non-root, je veux que ShipFlow installe et configure Claude Code et OpenAI Codex en mode autonome pour le bon profil utilisateur, afin d'eviter les prompts inutiles, les doublons avec dotfiles et les configurations IA appliquees au mauvais compte."
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - shipflow/install.sh
  - shipflow/README.md
  - shipflow/INSTALLATION-OWNERSHIP-SPEC.md
  - shipflow/specs/install-user-targeting.md
  - dotfiles/install.sh
  - dotfiles/lib.sh
  - dotfiles/README.md
  - dotfiles/codex/config.toml
  - dotfiles/claude/settings.local.json
depends_on:
  - artifact: "BUSINESS.md"
    artifact_version: "1.1.0"
    required_status: "reviewed"
  - artifact: "BRANDING.md"
    artifact_version: "1.0.0"
    required_status: "reviewed"
  - artifact: "GUIDELINES.md"
    artifact_version: "1.0.0"
    required_status: "reviewed"
  - artifact: "README.md"
    artifact_version: "0.1.0"
    required_status: "draft"
  - artifact: "INSTALLATION-OWNERSHIP-SPEC.md"
    artifact_version: "0.1.0"
    required_status: "draft"
  - artifact: "specs/install-user-targeting.md"
    artifact_version: "0.1.0"
    required_status: "draft"
supersedes:
  - "INSTALLATION-OWNERSHIP-SPEC.md"
  - "specs/install-user-targeting.md"
evidence:
  - "shipflow/install.sh configure deja ~/.claude/settings.json, ~/.codex/config.toml, MCP, skills et aliases pour root puis tous les comptes /home/*."
  - "shipflow/install.sh declare encore claude et codex NON_APPLICABLE / geres par dotfiles dans son rapport d'installation."
  - "dotfiles/install.sh installe @openai/codex dans npm-tools et re-installe @anthropic-ai/claude-code + @openai/codex dans install_ai_tools."
  - "dotfiles/install.sh configure encore les MCP Claude/Codex et symlink ~/.codex/config.toml vers dotfiles/codex/config.toml."
  - "L'utilisateur a tranche que ShipFlow doit posseder Claude/Codex/MCP/skills et que le compte non-root de travail doit recevoir une configuration IA autonome sans prompts inutiles."
  - "Codex local: codex-cli 0.125.0 expose approval_policy et sandbox_mode via ~/.codex/config.toml; Claude Code local: 2.1.121 expose --dangerously-skip-permissions et --permission-mode bypassPermissions."
next_step: "/sf-start AI agent install ownership and autonomous permissions"
---

# Spec: AI agent install ownership and autonomous permissions

## Title

AI agent install ownership and autonomous permissions

## Status

ready

## User Story

En tant qu'operateur ShipFlow qui code au quotidien depuis un compte non-root, je veux que ShipFlow installe et configure Claude Code et OpenAI Codex en mode autonome pour le bon profil utilisateur, afin d'eviter les prompts inutiles, les doublons avec dotfiles et les configurations IA appliquees au mauvais compte.

## Minimal Behavior Contract

Quand l'installateur ShipFlow est lance pour preparer un environnement de travail, il doit installer ou verifier Claude Code et OpenAI Codex, demander ou determiner explicitement quels profils utilisateur recevront la configuration IA, appliquer aux profils non-root selectionnes une configuration autonome sans demandes de permission inutiles, et retirer de dotfiles la responsabilite Claude/Codex/MCP/skills afin qu'un seul systeme possede ce domaine. Si un binaire, un profil ou une ecriture de configuration echoue, l'installateur doit le signaler clairement, continuer seulement quand l'etat reste coherent, et ne jamais appliquer le mode autonome a un profil non selectionne ou a root sans choix explicite.

## Success Behavior

- Preconditions: `sudo ./install.sh` est lance depuis ShipFlow sur une machine avec bash, jq et npm disponibles ou installables; au moins un profil operationnel non-root existe ou l'installateur peut recommander sa creation; dotfiles est present ou absent sans bloquer la phase ShipFlow.
- Trigger: fin de la phase systeme ShipFlow, avant la configuration `setup_user` actuelle.
- User/operator result: l'operateur voit le scope systeme puis le scope utilisateur, la liste des comptes eligibles, les comptes rejetes avec la raison, les profils selectionnes, la politique IA appliquee, les profils ignores et le statut de Claude/Codex.
- System effect: pour chaque profil non-root selectionne, `claude` et `codex` sont installes ou verifies dans le PATH utilisateur, `~/.claude/settings.json` contient la politique autonome Claude, `~/.codex/config.toml` contient la politique autonome Codex, les MCP et skills ShipFlow sont configures, et `.bashrc` expose les alias ShipFlow coherents.
- Autonomous defaults: Codex recoit `approval_policy = "never"` et `sandbox_mode = "danger-full-access"` dans le fichier utilisateur `~/.codex/config.toml`; Claude recoit `permissions.defaultMode = "bypassPermissions"` et `permissions.skipDangerousModePermissionPrompt = true` dans `~/.claude/settings.json`, plus un alias `c` qui lance explicitement `claude --dangerously-skip-permissions --permission-mode bypassPermissions`.
- Safe escape hatch: les alias documentes doivent permettre de lancer un mode prudent sans modifier la config principale, par exemple `cask='claude --permission-mode default'` et `coask='codex --ask-for-approval on-request --sandbox danger-full-access'`.
- No-dotfiles fallback: si dotfiles n'a pas prepare `~/.npm-global` et son PATH, ShipFlow doit preparer le strict minimum par utilisateur cible pour installer ou reutiliser `claude` et `codex` sans creer de fichiers root-owned dans un home non-root; si ce minimum ne peut pas etre etabli proprement, ShipFlow doit stopper pour ce compte avant toute mutation IA.
- Proof of success: `command -v claude`, `command -v codex`, validation JSON/TOML des fichiers generes, inspection des valeurs de permission, verification que `~/.npm-global/bin` ou un chemin equivalent choisi par ShipFlow est resolu pour l'utilisateur cible quand un install user-local est necessaire, rapport d'installation ShipFlow indiquant `claude` et `codex` comme geres par ShipFlow, et absence des blocs MCP/Codex/Claude geres par dotfiles apres reexecution de dotfiles.

## Error Behavior

- If no non-root operational user exists, ShipFlow completes only the system/global setup, prints a clear recommendation to create a non-root operational user, and does not silently apply autonomous AI config to root.
- If root is selected for autonomous AI config, the installer requires an explicit interactive confirmation or non-interactive opt-in such as `SHIPFLOW_AI_ALLOW_ROOT_AUTONOMOUS=1`; otherwise root can receive standard ShipFlow config without autonomous permissions.
- If `SHIPFLOW_INSTALL_USERS_MODE=user-list` is provided with an empty list, duplicate usernames, unknown usernames, service accounts, locked accounts, no-login accounts, or accounts whose home cannot be resolved to the selected account's real personal directory, the installer rejects those entries explicitly, marks them `invalid` or `rejected`, and performs no config mutation for them.
- If a user is selected through an interactive menu, only users that passed the eligibility filter can be selected; hidden or ineligible accounts must never become selectable through display-name confusion or positional mismatch.
- If npm or network installation fails for Claude/Codex, the installer reports the missing binary per target user, leaves existing configs intact, does not mark the user as fully configured, and provides the exact retry command.
- If dotfiles is absent and ShipFlow cannot establish a safe user-local npm prefix and PATH for the target account, the installer reports that account as blocked before any Claude/Codex install attempt and does not write partial AI config.
- If a target user's home, `.bashrc`, `.claude`, or `.codex` cannot be written, the installer logs that user as failed, continues to other selected users, and never creates root-owned files inside a non-root home.
- If dotfiles is re-run after migration, it must not recreate Claude/Codex/MCP ownership artifacts; if legacy dotfiles-managed blocks are detected, they are removed only when clearly delimited or explicitly owned by dotfiles.
- Must never happen: autonomous mode applied to an unselected account; config mutation on an account that failed eligibility checks; writes into another user's account "because needed"; user-owned config created as root; duplicate or conflicting MCP blocks in `~/.codex/config.toml`; Claude/Codex installed twice by two scripts; secrets printed in logs; project dependencies installed globally as a side effect.

## Problem

The current installation boundary is inconsistent. ShipFlow already configures Claude/Codex settings, MCP servers, skills, statusline, aliases and `shipflow_data` for root and every `/home/*` account, but its report still says `claude` and `codex` are managed by dotfiles. Dotfiles still installs Codex in `npm-tools`, installs Claude/Codex again in `install_ai_tools`, configures Claude/Codex MCP, symlinks a Codex config template, and links Claude skills. This creates double ownership, stale or conflicting config blocks, and a poor daily workflow where the non-root operator can still receive permission prompts from Codex or Claude.

## Solution

Make ShipFlow the sole owner of Claude Code, OpenAI Codex, ShipFlow MCP registration, ShipFlow skills and autonomous agent permissions. Move Claude/Codex binary installation or validation into ShipFlow user-scope setup, add explicit user targeting before per-user configuration, apply autonomous permissions only to selected operational profiles with root guarded by explicit opt-in, and remove Claude/Codex/MCP/skills responsibilities from dotfiles while keeping dotfiles focused on generic shell/editor/tooling.

## Scope In

- ShipFlow `install.sh` owns installation or verification of `@anthropic-ai/claude-code` and `@openai/codex`.
- ShipFlow `install.sh` owns user-target selection for AI/code configuration and stops silently configuring all `/home/*` profiles by default.
- ShipFlow `install.sh` writes/updates Claude autonomous permission settings in `~/.claude/settings.json`.
- ShipFlow `install.sh` writes/updates Codex autonomous permission settings in `~/.codex/config.toml`.
- ShipFlow `install.sh` updates aliases for `shipflow`, `sf`, `c`, `co`, safe escape hatches, and any ShipFlow-owned MCP helper aliases.
- ShipFlow `install.sh` report lists Claude/Codex as ShipFlow-managed with per-user status.
- dotfiles removes Claude/Codex install, Codex config symlink, Claude skills symlink, Claude/Codex MCP mutation, and AI aliases owned by ShipFlow.
- dotfiles can still prepare generic prerequisites: shell integration, PATH, `~/.npm-global`, `node`, `npm`, editor/file tooling and non-root user bootstrap.
- Documentation updates in both repos explain the ownership split, autonomous mode, root/non-root policy, and migration behavior.

## Scope Out

- Rewriting all ShipFlow install architecture.
- Rewriting all dotfiles component taxonomy beyond Claude/Codex/MCP/ShipFlow-owned AI artifacts.
- Managing all third-party AI tools such as Kilocode, OpenCode or Gemini unless they are explicitly used by ShipFlow workflow.
- Project dependency installation inside application repos.
- LDAP/AD/group-directory user management.
- Enterprise managed settings for Claude or Codex.
- Removing existing user secrets or OAuth credentials.

## Constraints

- ShipFlow remains root-capable for system/global setup but day-to-day autonomous AI configuration is intended for a regular non-root operational user.
- User-scope writes must run with correct ownership or be followed by safe `chown` of only ShipFlow-created paths.
- Existing user custom settings outside ShipFlow-managed blocks must be preserved.
- Legacy dotfiles cleanup must be idempotent and limited to clearly owned artifacts.
- `~/.codex/config.toml` must remain valid TOML after every run.
- `~/.claude/settings.json` must remain valid JSON after every run.
- Non-interactive install must be explicit through env vars; it must not guess the daily user by cloud-provider names.
- Dangerous autonomous mode is intentional, but must be observable, target-scoped and reversible through documented aliases/config.
- Eligibility for non-root autonomous config must be policy-driven, not name-driven: valid targets are only local human-operated accounts, not `root`, not system/service accounts, not locked accounts, and not no-login accounts; everything else is rejected unless a future spec expands the boundary.
- The script may do what is necessary for the selected account, but only inside that account's resolved personal directory and in system files explicitly owned by the root installer flow.
- ShipFlow must be able to bootstrap the minimal user-local npm prefix/PATH needed for Claude/Codex ownership even when dotfiles was never run, or else fail closed for that user before any AI mutation.

## Dependencies

- Local runtime: bash, jq, awk, sed, npm, Node.js, TOML-compatible Codex config, JSON-compatible Claude settings.
- Local CLI versions observed on 2026-04-28: `codex-cli 0.125.0`, `Claude Code 2.1.121`.
- Fresh docs checked:
  - OpenAI Codex configuration reference: `~/.codex/config.toml` is user-level config; `approval_policy` supports `never`; `sandbox_mode` supports `danger-full-access`; source: https://developers.openai.com/codex/config-reference.
  - Anthropic Claude Code settings: `permissions.defaultMode` supports `bypassPermissions`, and `skipDangerousModePermissionPrompt` applies to bypass mode in user settings; source: https://docs.anthropic.com/en/docs/claude-code/settings.
- Existing ShipFlow contracts:
  - `INSTALLATION-OWNERSHIP-SPEC.md` draft is superseded by this spec.
  - `specs/install-user-targeting.md` draft is incorporated by this spec.
- Existing dotfiles contracts:
  - dotfiles remains responsible for generic user-local npm prefix and shell PATH setup.
  - ShipFlow may bootstrap only the minimum user-local npm prefix/PATH required for ShipFlow-owned Claude/Codex when dotfiles did not prepare it; this is a compatibility fallback, not a return of generic tooling ownership to ShipFlow.

## Invariants

- One ownership source for Claude/Codex/MCP/ShipFlow skills: ShipFlow.
- dotfiles must not mutate `~/.claude` or `~/.codex` for ShipFlow-owned behavior after migration.
- User-scope AI config is applied only to selected target users.
- Selected target users are a subset of explicit eligible users; unknown, system, service, locked, no-login, or unresolved-home accounts are never mutated.
- Per-user mutation is confined to the selected account's resolved personal directory; "necessary" never authorizes writes into another user's account.
- Root is installer/admin by default, not the assumed daily autonomous coding account.
- Autonomous mode must be visible in install output and reversible/documented.
- Project dependencies are never installed globally by ShipFlow or dotfiles.
- Re-running ShipFlow and dotfiles is safe and does not reintroduce duplicate config blocks.

## Links & Consequences

- Upstream:
  - `shipflow/install.sh` system setup provides Node/npm and existing MCP configuration helpers.
  - dotfiles may create/prep the non-root user and generic PATH/npm prefix before ShipFlow runs.
- Downstream:
  - `~/.claude/settings.json`, `~/.codex/config.toml`, `~/.bashrc`, `~/.claude/skills`, `~/.codex/skills`, `~/shipflow_data`.
  - ShipFlow README and dotfiles README install guidance.
  - Existing install reports and `INSTALL-RUN-TRACE.md` need consistent terminology.
- Operational consequences:
  - When dotfiles was never run, ShipFlow may need to create or repair the per-user PATH/bootstrap lines required for `~/.npm-global/bin` in the selected account's `~/.bashrc` before attempting user-local AI installs.
  - Existing users with dotfiles-managed Codex symlinks must be migrated to real user config or have the symlink removed before ShipFlow writes.
  - Existing Claude/Codex sessions may need restart to pick up new config.
  - Users who want cautious sessions must use explicit safe aliases or temporary CLI overrides.
- Security consequences:
  - Autonomous mode increases blast radius of AI-generated commands. The mitigation is target scoping to non-root operational users, explicit root opt-in, visible reports, and no silent all-user mutation.
  - Incorrect target discovery could mutate service or stale accounts. The mitigation is an allow-by-eligibility policy with explicit rejection reasons, no raw `/home/*` loop, and no writes outside the selected account's personal directory.

## Documentation Coherence

- Update `shipflow/README.md`:
  - ShipFlow owns Claude/Codex install/config, MCP, skills and autonomous permissions.
  - Explain user targeting and non-root daily workflow.
  - Document autonomous defaults and safe escape hatch aliases.
  - Replace `root + /home/*` wording with selected user behavior.
- Update `dotfiles/README.md`:
  - Remove claims that dotfiles installs/configures Claude Code, Codex, or Claude/Codex MCP.
  - Explain that dotfiles prepares generic tooling and that ShipFlow handles AI/code agent workflow.
- Update `INSTALLATION-OWNERSHIP-SPEC.md`:
  - Mark as superseded or point to this spec.
- Update `specs/install-user-targeting.md`:
  - Mark as superseded or point to this spec.
- Update `CHANGELOG.md` after implementation.
- Optional: update `INSTALL-RUN-TRACE.md` only if the implementation run reveals notable migration observations.

## Edge Cases

- Fresh server with only root: system setup may run, but autonomous AI user config is deferred with a clear recommendation to create a non-root operational user.
- Server with multiple real users: interactive mode lists candidates and configures only selected users; non-interactive mode requires `SHIPFLOW_INSTALL_USERS_MODE=user-list` and `SHIPFLOW_INSTALL_USERS`.
- `SHIPFLOW_INSTALL_USERS` contains unknown, duplicate, or ineligible usernames: ShipFlow rejects them deterministically, reports the rejected entries, and does not silently fall back to all-users or root.
- A local account exists but uses `/usr/sbin/nologin`, `/bin/false`, is locked, or has a missing/unwritable personal directory: ShipFlow treats it as ineligible for autonomous config.
- Existing `~/.codex/config.toml` is a symlink to dotfiles: ShipFlow must replace or migrate it safely before writing, preserving user custom content where possible.
- Existing dotfiles MCP block exists in Codex config: ShipFlow removes only the `# >>> dotfiles codex mcp >>>` managed block or matching dotfiles-managed sections.
- Existing Claude MCP entries created by dotfiles CLI: ShipFlow must decide by ownership markers or known server names and avoid destructive removal of unrelated user MCPs.
- User has custom Claude permission deny rules: ShipFlow must preserve them unless they conflict with autonomous defaults, then report the conflict instead of deleting.
- npm global prefix points to root because ShipFlow runs with sudo: user-scope install must run as the target user or explicitly set target user's npm prefix.
- dotfiles was never run for the target account: ShipFlow must create the minimal local npm prefix/PATH bootstrap it needs in that account's `~/.bashrc`, or fail closed before attempting user-local installs.
- `claude` or `codex` already installed globally: ShipFlow can reuse if visible to the target user, but report source and avoid duplicate user-local installs unless needed.
- Re-run after partial failure: failed users can be retried without duplicating successful users.
- Non-interactive CI: defaults must be explicit; if no user list is provided, keep compatibility only through documented `all-users` mode, not through silent guessing.

## Implementation Tasks

- [ ] Task 1: Consolidate the ownership spec references
  - File: `INSTALLATION-OWNERSHIP-SPEC.md`
  - Action: mark the draft as superseded by `specs/ai-agent-install-ownership-and-autonomous-permissions.md` and remove any remaining open decision that conflicts with this spec.
  - User story link: gives agents one canonical contract for ownership.
  - Depends on: None
  - Validate with: `rg -n "superseded|ai-agent-install-ownership" INSTALLATION-OWNERSHIP-SPEC.md`
  - Notes: Do not delete the historical context.

- [ ] Task 2: Consolidate user targeting into this chantier
  - File: `specs/install-user-targeting.md`
  - Action: mark the draft as superseded or merged into this spec, keeping its history but pointing future work to this chantier.
  - User story link: avoids implementing user targeting separately from autonomous AI permissions.
  - Depends on: Task 1
  - Validate with: `rg -n "superseded|ai-agent-install-ownership" specs/install-user-targeting.md`
  - Notes: This prevents two partially overlapping `/sf-start` efforts.

- [ ] Task 3: Add explicit user target selection in ShipFlow
  - File: `install.sh`
  - Action: replace the unconditional `setup_user "$HOME" "root"` plus `/home/*` loop with a target selection phase supporting interactive selection and env-driven non-interactive modes: `SHIPFLOW_INSTALL_USERS_MODE=all-users|user-list` and `SHIPFLOW_INSTALL_USERS`.
  - User story link: prevents configuration on non-selected profiles.
  - Depends on: None
  - Validate with: `bash -n install.sh`; test homes for root-only, selected-user and all-users modes.
  - Notes: Keep a documented compatibility path for all-users, but make the selected scope visible in output.

- [ ] Task 4: Add operational user detection and root guard
  - File: `install.sh`
  - Action: replace the raw `/home/*` discovery with explicit eligibility filtering from `/etc/passwd`: reject unknown users, duplicate selections, `root`, service/system users, locked users, no-login shells, unresolved personal directories, and unwritable personal directories; show username/home/shell/sudo hints for eligible users only; warn when no non-root user exists; require explicit opt-in before applying autonomous mode to root.
  - User story link: keeps autonomous AI work scoped to the intended daily account.
  - Depends on: Task 3
  - Validate with: test fixtures or shell functions simulating no non-root user, one user, multiple users, invalid usernames, duplicate usernames, no-login users, and unwritable homes.
  - Notes: Do not create users in ShipFlow by default; defer to dotfiles/bootstrap guidance unless a future spec changes that.

- [ ] Task 5: Bootstrap minimal user-local PATH and npm prefix when dotfiles is absent
  - File: `install.sh`
  - Action: add a narrow fallback that ensures the selected user's local npm prefix and PATH are usable for ShipFlow-owned AI tools when dotfiles never prepared them; write only the minimum PATH/bootstrap lines ShipFlow needs into that user's `~/.bashrc` and never claim generic tooling ownership.
  - User story link: allows ShipFlow to configure the intended non-root operator even when dotfiles is absent.
  - Depends on: Task 4
  - Validate with: `sudo -u <user> bash -lc 'npm config get prefix && command -v npm'`; inspect `~/.bashrc` for one ShipFlow-managed PATH bootstrap block only when needed.
  - Notes: If the fallback cannot be established without ambiguity or root-owned artifacts, fail closed for that user.

- [ ] Task 6: Install or verify Claude/Codex per selected user
  - File: `install.sh`
  - Action: add `install_ai_agent_clis_for_user` that verifies `claude` and `codex` in the target user's PATH and installs `@anthropic-ai/claude-code` and `@openai/codex` user-locally when missing.
  - User story link: ShipFlow becomes the actual owner of daily AI coding tools.
  - Depends on: Task 4, Task 5
  - Validate with: target user PATH check; `sudo -u <user> bash -lc 'command -v claude && command -v codex'`.
  - Notes: Avoid root-owned files in user homes; preserve existing global installs if already visible.

- [ ] Task 7: Configure Claude autonomous permissions
  - File: `install.sh`
  - Action: extend Claude settings merge to set `.permissions.defaultMode = "bypassPermissions"` and `.permissions.skipDangerousModePermissionPrompt = true` for selected non-root users; preserve existing `allow`, `ask`, `deny`, MCP and statusLine settings.
  - User story link: Claude sessions stop asking for routine permission prompts for the daily operator.
  - Depends on: Task 4, Task 6
  - Validate with: `jq '.permissions.defaultMode, .permissions.skipDangerousModePermissionPrompt' "$HOME/.claude/settings.json"` in a test home.
  - Notes: If `permissions.disableBypassPermissionsMode` is present, report a conflict and do not remove it silently.

- [ ] Task 8: Configure Codex autonomous permissions
  - File: `install.sh`
  - Action: add an idempotent Codex config updater that writes or updates root-level `approval_policy = "never"` and `sandbox_mode = "danger-full-access"` without duplicating keys or corrupting existing TOML.
  - User story link: Codex runs without approval prompts for the selected daily operator.
  - Depends on: Task 4, Task 6
  - Validate with: `python3 -c 'import tomllib; tomllib.load(open(".../.codex/config.toml","rb"))'` and `rg -n 'approval_policy|sandbox_mode'`.
  - Notes: Remove duplicate root-level keys before writing; handle dotfiles symlink migration first.

- [ ] Task 9: Add autonomous and safe aliases
  - File: `install.sh`
  - Action: update `configure_aliases` to manage a ShipFlow AI alias block with `c`, `co`, `cask`, `coask`, `shipflow`, and `sf`, replacing stale aliases owned by previous ShipFlow/dotfiles blocks.
  - User story link: gives the operator fast daily commands and an explicit cautious escape hatch.
  - Depends on: Task 5, Task 7, Task 8
  - Validate with: inspect `.bashrc` after repeated runs; aliases appear once and point to the intended commands.
  - Notes: Prefer a delimited ShipFlow block over unstructured appends.

- [ ] Task 10: Update ShipFlow report and verification output
  - File: `install.sh`
  - Action: change report rows for `claude` and `codex` from `NON_APPLICABLE | gere par dotfiles` to ShipFlow-managed per-user statuses, including autonomous mode, eligible users, rejected users, skipped users, and blocked users when PATH/npm fallback could not be established.
  - User story link: makes ownership and result observable to the operator.
  - Depends on: Task 4, Task 5, Task 6, Task 7, Task 8
  - Validate with: generated install report includes Claude/Codex status and selected user scope.
  - Notes: Report root autonomous mode separately from non-root autonomous mode.

- [ ] Task 11: Remove Claude/Codex ownership from dotfiles install flow
  - File: `/home/ubuntu/dotfiles/install.sh`
  - Action: remove `@openai/codex` from `install_npm_tools`, remove or no-op `install_ai_tools` for Claude/Codex, remove Claude/Codex MCP mutation, remove Codex config symlink and Claude skills symlink, and remove ShipFlow-owned AI aliases.
  - User story link: eliminates duplicate installers and conflicting config writers.
  - Depends on: Task 6, Task 7, Task 8
  - Validate with: `rg -n '@openai/codex|@anthropic-ai/claude-code|claude mcp|merge_codex_mcp_config|codex/config.toml|alias c=|alias co=' /home/ubuntu/dotfiles/install.sh`
  - Notes: dotfiles may still display detected presence as informational only if it does not mutate Claude/Codex state.

- [ ] Task 12: Update dotfiles helper/component metadata
  - File: `/home/ubuntu/dotfiles/lib.sh`
  - Action: remove or reclassify dotfiles component entries for `claude-code`, Claude/Codex MCP, ShipFlow-owned aliases and health checks so menus/docs do not offer actions dotfiles no longer owns.
  - User story link: prevents users from reintroducing overlap through dotfiles component menus.
  - Depends on: Task 11
  - Validate with: `rg -n 'claude-code|codex|mcp|Claude Code MCP' /home/ubuntu/dotfiles/lib.sh`
  - Notes: Keep generic MCP reference symlink only if clearly not Claude/Codex client config.

- [ ] Task 13: Update ShipFlow documentation
  - File: `README.md`
  - Action: document ShipFlow ownership of Claude/Codex/MCP/skills, selected-user install behavior, eligibility and rejection rules, no-dotfiles fallback behavior, autonomous defaults, root guard and safe aliases.
  - User story link: operators understand what ShipFlow changes and where daily IA config lives.
  - Depends on: Task 3 through Task 10
  - Validate with: `rg -n 'Claude|Codex|autonomous|bypassPermissions|approval_policy|SHIPFLOW_INSTALL_USERS' README.md`
  - Notes: Replace stale `root + /home/*` wording.

- [ ] Task 14: Update dotfiles documentation
  - File: `/home/ubuntu/dotfiles/README.md`
  - Action: state that dotfiles owns generic tooling only and delegates Claude/Codex/MCP/ShipFlow skills to ShipFlow.
  - User story link: prevents operators from running the wrong script for AI config.
  - Depends on: Task 11, Task 12
  - Validate with: `rg -n 'Claude Code Skills|Codex|MCP|ShipFlow' /home/ubuntu/dotfiles/README.md`
  - Notes: Update install examples if they imply dotfiles is the AI workflow owner.

- [ ] Task 15: Add focused install validation harness
  - File: `test_validation.sh`
  - Action: extend or add test scenarios using temporary homes to validate target user selection, eligibility filtering, invalid/rejected user handling, minimal npm/PATH fallback, JSON/TOML validity, alias idempotence, dotfiles overlap removal, and report output.
  - User story link: makes the ownership migration verifiable before shipping.
  - Depends on: Task 3 through Task 14
  - Validate with: `bash test_validation.sh` and targeted `bash -n install.sh /home/ubuntu/dotfiles/install.sh /home/ubuntu/dotfiles/lib.sh`.
  - Notes: Do not run destructive user creation in the harness.

## Acceptance Criteria

- [ ] CA 1: Given a fresh ShipFlow install with one non-root operational user selected, when installation completes, then `claude` and `codex` are available in that user's PATH and reported as ShipFlow-managed.
- [ ] CA 2: Given a selected non-root user, when ShipFlow configures Claude, then `~/.claude/settings.json` contains `permissions.defaultMode = "bypassPermissions"` and `permissions.skipDangerousModePermissionPrompt = true` while preserving existing MCP/statusLine settings.
- [ ] CA 3: Given a selected non-root user, when ShipFlow configures Codex, then `~/.codex/config.toml` is valid TOML and contains one effective `approval_policy = "never"` and one effective `sandbox_mode = "danger-full-access"`.
- [ ] CA 4: Given root is not explicitly opted into autonomous mode, when ShipFlow runs as root, then root is not silently configured for autonomous AI permissions.
- [ ] CA 5: Given no non-root operational user exists, when ShipFlow runs, then system setup may complete but user-scope autonomous AI config is skipped with a clear recommendation to create/select a non-root user.
- [ ] CA 6: Given multiple `/home/*` users exist, when the operator selects only one, then only that user's `.claude`, `.codex`, `.bashrc` and `shipflow_data` are changed.
- [ ] CA 7: Given non-interactive mode uses `SHIPFLOW_INSTALL_USERS_MODE=user-list`, when `SHIPFLOW_INSTALL_USERS` contains valid users, then only those users are configured and the report lists skipped users.
- [ ] CA 8: Given non-interactive mode uses `SHIPFLOW_INSTALL_USERS_MODE=user-list`, when `SHIPFLOW_INSTALL_USERS` contains an unknown, duplicate, service, no-login, locked, `root`, or unresolved-home account, then that entry is rejected explicitly and receives no config mutation.
- [ ] CA 9: Given dotfiles was never run for a selected user, when ShipFlow needs a user-local Claude/Codex install, then ShipFlow creates only the minimum PATH/npm-prefix bootstrap needed for that user or marks that user blocked before any AI config write.
- [ ] CA 9b: Given ShipFlow configures one selected account, when the install completes, then no per-user file outside that selected account's personal directory was created or modified as part of that user's AI setup.
- [ ] CA 10: Given `~/.codex/config.toml` is a symlink to dotfiles, when ShipFlow migrates it, then Codex config becomes writable by the target user and dotfiles no longer owns the file.
- [ ] CA 11: Given dotfiles is re-run after migration, when it finishes, then it does not install Claude/Codex, does not mutate `~/.claude` or `~/.codex` for ShipFlow-owned settings, and does not recreate ShipFlow-owned AI aliases.
- [ ] CA 12: Given the install is run twice, when inspecting `.bashrc`, `~/.claude/settings.json`, and `~/.codex/config.toml`, then aliases and managed config blocks are not duplicated.
- [ ] CA 13: Given Claude/Codex install fails for one selected user, when the installer finishes, then that user is marked partial/failed and other selected users remain correctly configured.
- [ ] CA 14: Given documentation is read after implementation, when an operator compares ShipFlow and dotfiles docs, then only ShipFlow claims Claude/Codex/MCP/skills ownership.
- [ ] CA 15: Given a cautious session is needed, when the operator runs `cask` or `coask`, then Claude/Codex start with prompt/standard behavior without editing the main autonomous config.
- [ ] CA 16: Given an interactive selection flow, when eligible and ineligible accounts coexist, then only eligible accounts are displayed as selectable and rejected accounts are still reported with their rejection reason.

## Test Strategy

- Static:
  - `bash -n install.sh`
  - `bash -n /home/ubuntu/dotfiles/install.sh`
  - `bash -n /home/ubuntu/dotfiles/lib.sh`
  - `rg` checks for removed overlap patterns in dotfiles.
- Config validity:
  - `jq` validation for generated `~/.claude/settings.json`.
  - `python3 -c 'import tomllib; ...'` for generated `~/.codex/config.toml`.
- Integration with temporary homes:
  - root-only target.
  - one non-root selected user.
  - two non-root users with one selected.
  - all-users compatibility mode.
  - invalid usernames and duplicate usernames in `SHIPFLOW_INSTALL_USERS`.
  - no-login, locked, `root`, or unwritable-home accounts.
  - dotfiles absent with user-local npm/PATH fallback required.
  - preexisting dotfiles Codex symlink.
  - preexisting custom Claude permission rules.
- Manual:
  - Launch `claude` and `codex` as selected user after shell reload.
  - Verify `c`, `co`, `cask`, `coask`.
  - Re-run dotfiles and confirm it does not retake Claude/Codex ownership.
- Non-goal for tests:
  - Do not create real production users in automated tests.
  - Do not test external OAuth/auth flows for MCP servers.

## Risks

- Security: high. Autonomous Claude/Codex can run commands and edit files with minimal friction. Mitigation: target selected non-root users, root autonomous opt-in only, visible reports, safe aliases, and no silent all-user mutation.
- Authorization boundary: high. Incorrect target enumeration could mutate service or stale accounts. Mitigation: eligibility filter, explicit rejection reasons, and no mutation for unknown or ineligible users.
- Boundary control: high. “Do what is necessary” could otherwise justify writes into the wrong account. Mitigation: per-user mutation limited to the selected account's personal directory plus explicit root-owned system files.
- Data/secrets: medium. AI tools may read/write user files. Mitigation: do not log secrets, preserve existing deny rules where present, and document the blast radius.
- Operational: medium. Migrating symlinked Codex config can break Codex if TOML is invalid. Mitigation: validate TOML after write and stop on corruption.
- Product/UX: medium. Users accustomed to dotfiles owning AI tools may be surprised. Mitigation: update both READMEs and install reports.
- Compatibility: medium. Existing scripts may rely on `./install.sh --only=mcp` in dotfiles. Mitigation: dotfiles should print the ShipFlow command for Claude/Codex/MCP instead of silently doing nothing.
- Supply chain: medium. npm installs for Claude/Codex remain external package installs. Mitigation: keep current package names explicit and report versions; deeper pinning belongs to the existing supply-chain hardening task.

## Execution Notes

- Read first:
  - `install.sh`
  - `/home/ubuntu/dotfiles/install.sh`
  - `/home/ubuntu/dotfiles/lib.sh`
  - `README.md`
  - `/home/ubuntu/dotfiles/README.md`
- Approach:
  1. Implement ShipFlow user targeting and root guard before changing permissions.
  2. Add eligibility filtering and explicit rejection reporting for target accounts.
  3. Add the minimal per-user npm/PATH fallback needed when dotfiles was never run.
  4. Add ShipFlow-owned Claude/Codex binary install/validation.
  5. Add autonomous config writers with JSON/TOML validation.
  6. Add aliases/reporting.
  7. Remove dotfiles overlap.
  8. Update docs and tests.
- Use existing patterns:
  - Existing `configure_*_mcp` functions for JSON/TOML merge style.
  - Existing `configure_skills` symlink verification.
  - Existing install report generation.
- Avoid:
  - Ad hoc string edits that duplicate TOML keys.
  - Broad `rm -rf` cleanup.
  - Any unmarked deletion of user config.
  - Project dependency installs.
  - Name-based heuristics such as assuming `ubuntu`, `debian`, or any cloud-default username is the intended operator.
  - Interpreting “necessary” as permission to write into another user's home or into unspecified shell init files.
- Commands:
  - `bash -n install.sh`
  - `bash -n /home/ubuntu/dotfiles/install.sh /home/ubuntu/dotfiles/lib.sh`
  - `python3 -c 'import tomllib; tomllib.load(open(PATH, "rb"))'`
  - `jq empty PATH`
  - `rg -n '@openai/codex|@anthropic-ai/claude-code|claude mcp|merge_codex_mcp_config|codex/config.toml|alias c=|alias co=' /home/ubuntu/dotfiles`
- Stop conditions:
  - Cannot safely determine target user ownership.
  - Eligibility logic still includes accounts that the operator cannot distinguish safely from service/system accounts.
  - The fallback would need to modify files outside the selected account's personal directory or outside the root installer's explicit system-file scope.
  - TOML/JSON validation fails after config write.
  - `permissions.disableBypassPermissionsMode` exists in Claude settings.
  - Existing config has no ownership markers and cleanup would require guessing.
  - npm install path would create root-owned files in a non-root home.
- Fresh external docs verdict:
  - `fresh-docs checked` for Codex config and Claude permission settings using official docs listed in Dependencies.

## Open Questions

None.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-04-28 22:27:54 UTC | sf-spec | GPT-5 Codex | Created canonical spec for ShipFlow ownership of Claude/Codex installation, autonomous permissions, user targeting, and dotfiles overlap removal | draft | /sf-ready AI agent install ownership and autonomous permissions |
| 2026-04-28 23:10:00 UTC | sf-ready | GPT-5 Codex | Readiness review of ownership, autonomous permissions, user targeting, and dotfiles overlap removal spec | not ready | /sf-spec AI agent install ownership and autonomous permissions |
| 2026-04-28 23:28:00 UTC | sf-spec | GPT-5 Codex | Updated the spec to define target-user eligibility, invalid-selection handling, and ShipFlow fallback when dotfiles did not prepare user-local npm/PATH | draft | /sf-ready AI agent install ownership and autonomous permissions |
| 2026-04-28 23:40:00 UTC | sf-ready | GPT-5 Codex | Readiness review after eligibility and fallback updates | not ready | /sf-spec AI agent install ownership and autonomous permissions |
| 2026-04-29 00:06:00 UTC | sf-spec | GPT-5 Codex | Clarified the concrete mutation boundary: selected human-operated non-root accounts only, writes limited to the selected account personal directory and explicit root-owned system files, with `~/.bashrc` as the PATH fallback target | draft | /sf-ready AI agent install ownership and autonomous permissions |
| 2026-04-29 00:41:27 UTC | sf-ready | GPT-5 Codex | Readiness gate passed after structure, behavioral contract, adversarial review, and security controls validation | ready | /sf-start AI agent install ownership and autonomous permissions |
| 2026-04-29 02:00:00 UTC | sf-start | GPT-5 Codex | Implemented ShipFlow ownership changes for user targeting, autonomous Claude/Codex permissions, per-user bootstrap, dotfiles overlap removal, and ownership docs updates | implemented | /sf-verify AI agent install ownership and autonomous permissions |
| 2026-04-29 02:10:00 UTC | sf-end | GPT-5 Codex | Closed implementation session with bookkeeping updates (TASKS/CHANGELOG/spec trace) while keeping verification pending | deferred | /sf-verify AI agent install ownership and autonomous permissions |
| 2026-04-29 02:15:00 UTC | sf-ship | GPT-5 Codex | Shipped closure trace commit for the chantier spec while preserving narrow scope (spec-only ship) | shipped | /sf-verify AI agent install ownership and autonomous permissions |

## Current Chantier Flow

- sf-spec: done (draft updated)
- sf-ready: done (ready)
- sf-start: implemented
- sf-verify: not launched
- sf-end: deferred
- sf-ship: shipped

Next step:
- /sf-verify AI agent install ownership and autonomous permissions
