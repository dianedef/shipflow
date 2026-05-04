---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "1.0.3"
project: ShipFlow
created: "2026-05-01"
updated: "2026-05-04"
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
| `config.sh` | Central configuration defaults and validation | Keep defaults explicit and validation actionable |
| `CONTEXT-FUNCTION-TREE.md` | Navigation aid for large shell files | Update when major functions or flows move |

## Entrypoints

- `shipflow` / `sf`: installed wrappers that call `shipflow.sh`.
- `shipflow.sh::main`: checks prerequisites, cleans orphan state, then starts
  the menu or runs a one-shot top-level menu shortcut.
- `lib.sh::run_menu`: dispatches interactive menu choices to `action_*` handlers.
- `lib.sh::run_menu_shortcut`: dispatches a single CLI shortcut argument such
  as `sf u` to the same top-level action while preserving action confirmations.
- `menu_bash.sh` / `menu_gum.sh`: render the top-level menu and use shared
  key input helpers so `x`, `Esc`, and `Backspace` act consistently for Back.
- `lib.sh` UI helpers: `ui_read_choice`, `ui_run_menu_action`,
  `ui_return_back`, and the skip-next-pause signal define the reusable
  Back/cancel contract for nested menus, including selections made through
  `$(ui_choose ...)` command substitutions.
- `lib.sh::ui_run_menu_action`: centralizes menu action dispatch. Top-level
  interactive actions run in `screen` mode so command output starts from a
  clean screen instead of below the root menu, while nested menus can keep
  `inline` behavior.
- `lib.sh::ui_box_header`: prints fixed-width boxed CLI headers so left and
  right borders stay aligned across dashboard, logs, health, and success blocks.
- `lib.sh::env_start`, `env_stop`, `env_restart`, `env_remove`: core environment lifecycle.
- `lib.sh::action_flutter_web`: interactive Flutter Web preview through `tmux`
  with hot reload/hot restart control.
- `lib.sh::action_blacksmith_setup`: guided official-first Blacksmith setup
  screen for CLI presence, local auth status, GitHub App guidance, runner tags,
  and Testbox init commands. It prints required terminal commands instead of
  running interactive install/auth/project mutation steps automatically, and
  routes remote Blacksmith auth through the local tunnel menu.
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
  -> PM2 / Flox / Caddy / DuckDNS side effect
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
- Interactive preview uses `tmux` from `action_flutter_web`, starts
  `flutter run -d web-server --web-hostname 0.0.0.0 --web-port <port>` inside
  the project Flox environment, records the session in
  `SHIPFLOW_FLUTTER_WEB_SESSIONS_FILE`, and sends `r`/`R` to that session for
  hot reload or hot restart.

## Invariants

- PM2 is the execution state source.
- `invalidate_pm2_cache` must run after PM2 mutations.
- Project paths must be validated and absolute before runtime use.
- Port allocation must avoid active socket collisions and PM2 hidden collisions.
- User-visible success and failure should be observable.
- Top-level interactive menu actions should be dispatched through
  `ui_run_menu_action` in `screen` mode; nested menus may use `inline` when
  they already own their screen lifecycle.
- Back/cancel paths should signal parent redraw through the shared UI helpers
  instead of returning like completed actions.
- Boxed CLI headers should use `ui_box_header` rather than hand-counted spaces.
- Generated ecosystem/runtime config is not the hand-edited source of truth.
- Dart/Flutter runtime provisioning failures must stop startup before PM2 launch.
- Flutter Web `tmux` preview sessions are interactive developer sessions, not
  PM2-managed production-like processes.

## Failure Modes

- Missing prerequisites should produce an actionable error before secondary failures.
- Unknown shortcut arguments should fail visibly with the available top-level keys.
- Back actions should redraw the parent menu directly instead of requiring an
  extra pause keypress.
- Back/cancel state can be lost when a selector runs inside Bash command
  substitution unless the shared skip-next-pause signal is used.
- PM2 cache drift can make dashboard, health, and port decisions wrong.
- Caddy/DuckDNS publishing failures must not be reported as successful public exposure.
- Broad shell parsing can misread structured state; use `jq`, Node, or existing structured helpers where available.
- Invalid Dart/Flutter package overrides (paths, shell fragments, option-like tokens) must be rejected before invoking `flox install`.
- Missing `tmux` should block only the interactive Flutter Web preview path and
  produce an actionable operator message.
- Missing Blacksmith CLI or auth should be shown as a setup status, not as a
  runtime failure; the menu must print the official next command when an
  interactive Blacksmith step is required.

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
```

Run a focused runtime smoke for the touched behavior when practical, for example dashboard/status for read-only changes or a non-production test project for lifecycle changes.

## Reader Checklist

- `shipflow.sh`, `lib.sh`, or `config.sh` changed -> review this doc and `code-docs-map.md`.
- Function structure moved -> update `CONTEXT-FUNCTION-TREE.md`.
- User-facing CLI behavior changed -> check `README.md` and `CONTEXT.md`.
- Publish or secret handling changed -> check security notes and public docs.

## Maintenance Rule

Update this doc when runtime entrypoints, lifecycle flows, PM2/Flox/Caddy/DuckDNS behavior, validations, or security constraints change.
