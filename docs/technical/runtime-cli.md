---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "1.0.10"
project: ShipFlow
created: "2026-05-01"
updated: "2026-05-09"
status: reviewed
source_skill: sf-start
scope: runtime-cli
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - shipflow.sh
  - lib.sh
  - menu_gum.sh
  - menu_bash.sh
  - config.sh
  - CONTEXT-FUNCTION-TREE.md
depends_on:
  - artifact: "ARCHITECTURE.md"
    artifact_version: "1.0.0"
    required_status: reviewed
  - artifact: "GUIDELINES.md"
    artifact_version: "1.2.0"
    required_status: reviewed
supersedes: []
evidence:
  - "Function inventory from shipflow.sh, lib.sh, config.sh, and CONTEXT-FUNCTION-TREE.md."
  - "Blacksmith setup menu added for official CLI/Testbox guidance without token handling."
  - "Remote Blacksmith auth now routes to local SSH callback tunnel instead of direct server login."
  - "Main menu shortened with grouped submenus."
  - "Root menu labels simplified to visible user actions without abstract section headers."
  - "Health Check system monitor now shows disk capacity alongside memory."
  - "Disk cleanup now includes protected agent-history and agent-cache cleanup choices."
  - "Disk details and PM2 log cleanup/rotation added to explain and cap disk usage."
  - "Main menu session identity now renders inside the top status header."
next_review: "2026-06-01"
next_step: "/sf-docs technical audit runtime-cli"
---

# Runtime CLI

## Purpose

This doc covers the server-side CLI runtime: `shipflow.sh`, `lib.sh`, and `config.sh`. It is the first technical doc to read when changing environment lifecycle, dashboard, publishing, health, PM2, Flox, Caddy, DuckDNS, session identity, or CLI menu behavior.

## Owned Files

| Path | Role | Edit notes |
| --- | --- | --- |
| `shipflow.sh` | Thin CLI entrypoint that sources runtime and menu files, then calls `main` | Keep thin; do not move business logic here |
| `lib.sh` | Main orchestration library for UI, validation, PM2/Flox/Caddy operations, health, deploy, publish, and actions | High blast radius; prefer focused changes and syntax checks |
| `menu_gum.sh`, `menu_bash.sh` | Menu frontends that render the root menu and grouped submenus | Keep frontend behavior equivalent; update both variants together |
| `config.sh` | Central configuration defaults and validation | Keep defaults explicit and validation actionable |
| `CONTEXT-FUNCTION-TREE.md` | Navigation aid for large shell files | Update when major functions or flows move |

## Entrypoints

- `shipflow` / `sf`: installed wrappers that call `shipflow.sh`.
- `shipflow.sh::main`: checks prerequisites, cleans orphan state, then starts
  the menu or runs a one-shot visible root menu key.
- `sf codex` / `sf co`: early Codex launcher shortcut that bypasses
  environment cleanup, asks for a workspace/MCP preset when needed, then
  replaces the ShipFlow process with `codex`.
- `lib.sh::run_menu`: dispatches interactive menu choices to `action_*` handlers.
- `lib.sh::run_menu_shortcut`: dispatches a single CLI menu-key argument such
  as `sf t` to the matching visible root action in `MAIN_MENU_ITEMS`.
- `menu_gum.sh` / `menu_bash.sh`: render the root menu from `MAIN_MENU_ITEMS`
  and grouped submenus from `ENVIRONMENT_MENU_ITEMS`, `TOOLS_WEB_MENU_ITEMS`,
  `SYSTEM_MENU_ITEMS`, and `AGENTS_CI_MENU_ITEMS`. Startup rendering should
  avoid per-item subprocesses; the Gum frontend should batch styling through
  one boxed render instead of one `gum style` call per item. The root menu uses
  a two-column layout on wide terminals and falls back to one column on narrow
  terminals. ShipFlow's own tracker overview is exposed as a dedicated root
  action instead of being nested under agents.
- `menu_bash.sh` / `menu_gum.sh`: render menus and use shared key input helpers
  so `x`, `Esc`, and `Backspace` act consistently for Back.
- `lib.sh` UI helpers: `ui_read_choice`, `ui_run_menu_action`,
  `ui_return_back`, and the skip-next-pause signal define the reusable
  Back/cancel contract for nested menus, including selections made through
  `$(ui_choose ...)` command substitutions.
- `lib.sh::ui_run_menu_action`: centralizes menu action dispatch. Top-level
  interactive actions run in `screen` mode so command output starts from a
  clean screen instead of below the root menu, while nested menus can keep
  `inline` behavior.
- `lib.sh::ui_header`: prints the main menu status header and can embed the
  session identity block inside the same top frame.
- `lib.sh::ui_box_header`: prints fixed-width boxed CLI headers so left and
  right borders stay aligned across dashboard, logs, health, and success blocks.
- `lib.sh::env_start`, `env_stop`, `env_restart`, `env_remove`: core environment lifecycle.
- `lib.sh::list_pm2_app_names`, `list_all_stop_targets`, and
  `pm2_stop_app_by_name`: PM2 stop safety helpers used to stop both
  disk-discovered environments and PM2-only orphan entries.
- `lib.sh::action_flutter_web`: interactive Flutter Web preview through `tmux`
  with hot reload/hot restart control.
- `lib.sh::action_blacksmith_setup`: guided official-first Blacksmith setup
  screen for CLI presence, local auth status, GitHub App guidance, runner tags,
  and Testbox init commands. It prints required terminal commands instead of
  running interactive install/auth/project mutation steps automatically, and
  routes remote Blacksmith auth through the local tunnel menu.
- `lib.sh::action_codex_launcher`: interactive Codex launcher for choosing a
  workspace and enabling selected MCP providers for the new Codex session only.
- `lib.sh::action_mcp_menu`: grouped MCP/Codex menu that routes to the Codex
  launcher or the local OAuth tunnel instructions.
- `lib.sh::action_reboot_vm`: explicit confirmed VM reboot action from the
  system menu. It supports `SHIPFLOW_REBOOT_DRY_RUN=1` for smoke checks.
- `lib.sh::mcp_cleanup_menu`: health-menu cleanup for local MCP process
  groups. It lists provider/RAM/uptime/parent Codex evidence and stops only a
  confirmed process group.
- `lib.sh::action_health`: renders the system monitor with RAM, disk, swap,
  process, and PM2 health first, then uses explicit one-key actions for cleanup
  commands. It must not route destructive cleanup options through
  searchable/default-select menus.
- `lib.sh::disk_cleanup_menu`: one-key disk cleanup flow for old Codex/Claude
  history files, agent caches/logs, and package/browser disk caches. It shows
  estimated recoverable space and protects project directories, auth, config,
  skills, memories, and recent agent histories.
- `lib.sh::disk_usage_details_menu`: read-only disk usage detail view for the
  largest PM2 log files, `$HOME` entries, project/work directories, and root
  filesystem entries.
- `lib.sh::cleanup_pm2_logs_with_rotation`: truncates PM2 daemon/app logs and
  configures `pm2-logrotate` (`max_size=50M`, `retain=5` by default) so PM2
  logs cannot refill the disk unchecked.
- Command submenus that can start, stop, restart, launch, or clean up runtime
  state should use explicit one-key choices or confirmations; `ui_filter_choose`
  is reserved for longer data-selection lists and flushes pending input before
  opening the filter.
- `lib.sh::refresh_user_caddy_from_pm2` and
  `sync_caddy_after_pm2_change`: user-mode Caddy lifecycle helpers. They write
  runtime config under the operator's `~/.shipflow/runtime/caddy`, refresh
  routes from online PM2 apps, and stop Caddy when no PM2 app is online.
- `lib.sh::action_publish`: public exposure through Caddy and DuckDNS.

## Control Flow

```text
shipflow.sh
  -> source config/menu/runtime
  -> main
  -> check_prerequisites
  -> cleanup_orphan_projects
  -> run_menu OR run_menu_shortcut
  -> action_* handler
  -> PM2 / Flox / user Caddy / optional DuckDNS side effect
```

For projects detected from `pubspec.yaml`, runtime provisioning is explicit:
- `dart` projects must ensure Dart packages in project Flox before launch.
- `flutter` projects must ensure Flutter packages in project Flox before launch.
- existing `.flox` environments are repaired idempotently for Dart/Flutter
  runtime packages before startup continues.
- runtime override variables are treated as untrusted input and validated as
  simple Flox package tokens before any `flox install` call.

Flutter Web has two runtime paths:
- PM2-managed launch remains available through the normal environment lifecycle.
- A `package.json` without a supported JS framework or exact runnable `dev` /
  `start` script must not block `pubspec.yaml` detection; mixed Flutter +
  Convex projects still use the Flutter Web command.
- Interactive preview uses `tmux` from `action_flutter_web`, starts
  `flutter run -d web-server --web-hostname 0.0.0.0 --web-port <port>` inside
  the project Flox environment, records the session in
  `SHIPFLOW_FLUTTER_WEB_SESSIONS_FILE`, and sends `r`/`R` to that session for
  hot reload or hot restart.

## Invariants

- PM2 is the execution state source.
- `invalidate_pm2_cache` must run after PM2 mutations.
- User-mode Caddy follows PM2 online state: environment start refreshes routes,
  environment stop refreshes or stops it, and Stop All stops it when no PM2 app
  remains online.
- The system Caddy service is a legacy/public HTTPS path and should not be left
  running when no PM2 app is online.
- Stop flows must cover PM2 entries even when their project directories are no
  longer resolvable from disk, then persist the stopped state with PM2.
- Generated PM2 ecosystem configs for dev servers must bound automatic restart
  loops so broken commands cannot fill logs indefinitely.
- Project paths must be validated and absolute before runtime use.
- Port allocation must avoid active socket collisions and PM2 hidden collisions.
- User-visible success and failure should be observable.
- Project tracking initialization must keep ShipFlow-owned `TASKS.md` under
  `SHIPFLOW_DATA_DIR` and must not create project-local `TASKS.md` symlinks.
  Legacy symlinks from older ShipFlow versions should be removed when they
  point into `shipflow_data`.
- Root interactive menu actions should be dispatched through
  `ui_run_menu_action` in `screen` mode; grouped submenus may use `inline` when
  they already own their screen lifecycle.
- Back/cancel paths should signal parent redraw through the shared UI helpers
  instead of returning like completed actions.
- Boxed CLI headers should use `ui_box_header` rather than hand-counted spaces.
- Generated ecosystem/runtime config is not the hand-edited source of truth.
- Codex MCP providers are off by default; the runtime launcher enables selected
  providers with session-only config overrides and must not persistently flip
  `~/.codex/config.toml`.
- Dart/Flutter runtime provisioning failures must stop startup before PM2 launch.
- Flutter Web `tmux` preview sessions are interactive developer sessions, not
  PM2-managed production-like processes.

## Failure Modes

- Missing prerequisites should produce an actionable error before secondary failures.
- Unknown shortcut arguments should fail visibly with the available visible root menu keys.
- Back actions should redraw the parent menu directly instead of requiring an
  extra pause keypress.
- Back/cancel state can be lost when a selector runs inside Bash command
  substitution unless the shared skip-next-pause signal is used.
- PM2 cache drift can make dashboard, health, and port decisions wrong.
- Disk-only environment discovery can miss stale PM2 entries; stop flows should
  union project-discovered environments with PM2 app names.
- Unbounded PM2 autorestart can turn a missing directory, missing dependency, or
  failing dev command into a restart storm and log growth incident.
- User-mode Caddy startup failures must not block PM2 app startup, but they must
  be visible with the runtime log path.
- Caddy/DuckDNS publishing failures must not be reported as successful public exposure.
- Broad shell parsing can misread structured state; use `jq`, Node, or existing structured helpers where available.
- Invalid Dart/Flutter package overrides (paths, shell fragments, option-like tokens) must be rejected before invoking `flox install`.
- Missing `tmux` should block only the interactive Flutter Web preview path and
  produce an actionable operator message.
- Missing Blacksmith CLI or auth should be shown as a setup status, not as a
  runtime failure; the menu must print the official next command when an
  interactive Blacksmith step is required.
- The Codex launcher should fail before `exec` when Codex is absent, a selected
  workspace is invalid, or an MCP name is malformed; it must not kill existing
  Codex conversations or MCP processes.
- MCP cleanup should target only local MCP server process groups, ask for
  confirmation, and refuse any process group that contains a `codex` process.
- Disk cleanup must keep project directories out of scope and must not delete
  agent auth/config/skills/memories; history cleanup is retention-based.
- Package-manager caches such as PNPM are disk cleanup targets, not RAM/process
  cleanup targets.
- PM2 logs can dominate disk usage; disk cleanup should expose their size, offer
  a confirmed flush, and configure rotation rather than relying on manual
  operator cleanup.

## Security Notes

- Do not log tokens, DuckDNS secrets, private paths containing credentials, or raw environment values.
- Public URL publishing is externally visible and needs explicit validation.
- Destructive actions must stay idempotent and confirmation-gated where the UX expects it.
- Blacksmith credentials are detected only by local credentials-file presence;
  the runtime must not read, print, store, or transform token contents.

## Validation

```bash
bash -n shipflow.sh lib.sh config.sh
test_flox_runtime_provisioning.sh
rg -n "invalidate_pm2_cache" lib.sh
printf 'x\n' | env SHIPFLOW_PROJECTS_DIR=/tmp/shipflow-empty ./shipflow.sh u
SHIPFLOW_CODEX_DRY_RUN=1 ./shipflow.sh codex --dir "$PWD" supabase playwright
printf 'x' | bash -lc 'source ./lib.sh; action_health'
printf 'x\n' | bash -lc 'source ./lib.sh; disk_cleanup_menu'
SHIPFLOW_PM2_LOG_CLEANUP_DRY_RUN=1 bash -lc 'source ./lib.sh; cleanup_pm2_logs_with_rotation'
bash -lc 'source ./lib.sh; disk_usage_details_menu'
SHIPFLOW_MCP_CLEANUP_DRY_RUN=1 bash -lc 'source ./lib.sh; mcp_cleanup_menu'
SHIPFLOW_USER_CADDY_DRY_RUN=1 bash -lc 'source ./lib.sh; refresh_user_caddy_from_pm2'
printf 'o\n' | SHIPFLOW_REBOOT_DRY_RUN=1 bash -lc 'source ./lib.sh; action_reboot_vm'
```

Run a focused runtime smoke for the touched behavior when practical, for example dashboard/status for read-only changes or a non-production test project for lifecycle changes.

## Reader Checklist

- `shipflow.sh`, `lib.sh`, or `config.sh` changed -> review this doc and `code-docs-map.md`.
- Function structure moved -> update `CONTEXT-FUNCTION-TREE.md`.
- User-facing CLI behavior changed -> check `README.md` and `CONTEXT.md`.
- Publish or secret handling changed -> check security notes and public docs.

## Maintenance Rule

Update this doc when runtime entrypoints, lifecycle flows, PM2/Flox/Caddy/DuckDNS behavior, validations, or security constraints change.
