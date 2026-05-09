---
artifact: documentation
metadata_schema_version: "1.0"
artifact_version: "0.1.9"
project: "shipflow"
created: "2026-04-25"
updated: "2026-05-09"
status: draft
source_skill: manual
scope: "context"
owner: "unknown"
confidence: "medium"
risk_level: "low"
security_impact: "none"
docs_impact: "yes"
linked_systems: ["shipflow.sh", "lib.sh", "menu_gum.sh", "menu_bash.sh", "config.sh", "install.sh", "local/local.sh", "local/dev-tunnel.sh"]
depends_on: []
supersedes: []
evidence: ["Function extraction from shipflow.sh, lib.sh, config.sh, install.sh, local/local.sh, local/dev-tunnel.sh", "Blacksmith setup menu helpers added to lib.sh", "Blacksmith OAuth callback tunnel added to local tooling", "Codex MCP on-demand launcher added to lib.sh", "Grouped root menu and submenu wrappers added to menu frontends", "Root menu shortcuts aligned with visible menu labels", "Disk overview helpers added to the Health Check monitor", "Agent history and cache cleanup helpers added to disk cleanup", "PM2 log cleanup/rotation and disk usage detail helpers added"]
next_step: "/sf-docs update CONTEXT-FUNCTION-TREE.md"
---

# Context / Arbre de Fonctions

## Purpose

Ce document sert de point d'entree rapide pour comprendre la structure fonctionnelle de ShipFlow sans relire tout `lib.sh`.

## Runtime Map

```text
shipflow.sh
  -> source lib.sh
  -> source menu_gum.sh or menu_bash.sh
  -> main()
     -> run_menu_shortcut() for early codex/co launch
     -> check_prerequisites()
     -> cleanup_orphan_projects()
     -> run_menu() OR run_menu_shortcut()

run_menu()
  -> MAIN_MENU_ITEMS root actions
  -> grouped submenu wrappers
  -> action_* handlers
  -> core environment functions in lib.sh
  -> PM2 / Flox / user Caddy / local tooling

run_menu_shortcut()
  -> action_codex_launcher() for codex/co
  -> resolve_menu_shortcut_action()
  -> MAIN_MENU_ITEMS visible root actions
  -> action_* handler
```

## File Roles

- `shipflow.sh`: point d'entree du CLI.
- `lib.sh`: coeur applicatif. UI, validation, PM2, Flox, sessions, dashboard, deploy, publish.
- `config.sh`: variables d'environnement et validation de config.
- `install.sh`: bootstrap serveur, aliases, Codex config, liens de skills.
- `local/local.sh`: menu local pour tunnels SSH et statut distant.
- `local/dev-tunnel.sh`: tunnel manager non interactif base sur PM2 distant.

## Function Tree

### `shipflow.sh`

```text
main
  -> check_prerequisites
  -> cleanup_orphan_projects
  -> run_menu OR run_menu_shortcut
```

### `config.sh`

```text
shipflow_print_config
shipflow_validate_config
```

### `install.sh`

```text
logging
  -> success
  -> error
  -> info
  -> warning

codex / shell setup
  -> configure_statusline
  -> configure_codex_tui
  -> configure_codex_rmcp
  -> configure_codex_*_mcp
  -> ensure_skill_link
  -> configure_skills
  -> configure_aliases
  -> configure_data
  -> setup_user
```

### `local/dev-tunnel.sh`

```text
remote session identity
  -> fetch_server_session_info
```

### `local/local.sh`

```text
connection management
  -> load_current_connection
  -> save_current_connection
  -> add_saved_connection
  -> get_saved_connections
  -> select_connection

remote session info
  -> fetch_server_session_info
  -> get_server_session_info
  -> display_server_session_banner

menu / local UX
  -> print_header
  -> show_menu
  -> run_mcp_login_menu
  -> run_blacksmith_login_menu
  -> pause
  -> main

remote OAuth callback tunnels
  -> local/mcp-login.sh
  -> local/blacksmith-login.sh

tunnel lifecycle
  -> get_active_ports
  -> get_tunnel_processes
  -> get_tunnel_pids
  -> is_local_tunnel_ready
  -> verify_tunnels_ready
  -> start_tunnels
  -> show_urls
  -> stop_tunnels
  -> show_status
```

### `lib.sh`

```text
bootstrap / safety
  -> error_trap_handler
  -> cleanup_temp_files
  -> register_temp_file

UI helpers
  -> ui_choose
  -> ui_read_choice
  -> ui_run_menu_action
  -> ui_input
  -> ui_confirm
  -> ui_box_header
  -> ui_header
  -> ui_spinner
  -> ui_pause
  -> ui_skip_next_pause
  -> ui_return_back
  -> ui_should_skip_next_pause
  -> ui_is_back_choice
  -> ui_is_back_selection

visible menu keys
  -> print_menu_shortcut_usage
  -> resolve_menu_shortcut_action
  -> run_menu_shortcut

menu frontends
  -> menu_gum.sh::_gum_run_menu
  -> menu_gum.sh::_gum_run_nested_menu
  -> menu_bash.sh::_bash_run_menu
  -> menu_bash.sh::_bash_run_nested_menu
  -> action_environments_menu
  -> action_tools_web_menu
  -> action_system_menu
  -> action_agents_ci_menu

Codex launcher
  -> action_mcp_menu
  -> action_codex_launcher
  -> codex_select_workspace
  -> codex_select_mcp_preset
  -> codex_select_custom_mcps
  -> codex_launch_with_mcps

system health
  -> disk_free_bytes
  -> disk_free_human
  -> disk_total_human
  -> disk_used_human
  -> disk_filesystem
  -> disk_used_pct
  -> disk_warn_threshold_bytes
  -> disk_gb_to_bytes
  -> disk_pressure_level
  -> disk_is_low_space
  -> print_disk_pressure_warning
  -> format_bytes
  -> print_usage_bar
  -> cleanup_disk_light
  -> cleanup_disk_aggressive
  -> path_size_bytes
  -> agent_history_old_files
  -> agent_history_old_sizes
  -> agent_history_old_count
  -> agent_history_old_bytes
  -> agent_history_prune_empty_dirs
  -> cleanup_agent_history_old
  -> agent_cache_log_paths
  -> agent_cache_log_bytes
  -> cleanup_agent_cache_logs
  -> pm2_home_dir
  -> pm2_logs_bytes
  -> pm2_logrotate_installed
  -> pm2_logrotate_status
  -> truncate_file_zero
  -> cleanup_pm2_logs
  -> configure_pm2_logrotate
  -> cleanup_pm2_logs_with_rotation
  -> print_du_top
  -> print_top_files_by_size
  -> print_project_dir_top
  -> disk_usage_details_menu
  -> disk_cleanup_menu
  -> mem_available_kb
  -> mem_total_kb
  -> mem_available_human
  -> mem_total_human
  -> mem_is_low
  -> mem_top_processes
  -> mem_long_running_processes
  -> mem_alerts
  -> system_monitor_menu

updates / caches
  -> run_with_timeout
  -> count_apt_updates
  -> count_npm_updates
  -> count_pip_updates
  -> count_rustup_updates
  -> updates_refresh_cache
  -> updates_total_cached
  -> read_menu_status_cache
  -> refresh_menu_status_cache_sync
  -> refresh_menu_status_cache_async_if_stale
  -> updates_menu

secrets / logging / parsing
  -> save_secret
  -> load_secret
  -> init_logging
  -> log
  -> parse_json

setup / prerequisites
  -> check_prerequisites
  -> show_tools_status
  -> install_sdk_menu

Blacksmith setup guidance
  -> blacksmith_cli_path
  -> blacksmith_credentials_file
  -> blacksmith_is_connected
  -> blacksmith_print_status
  -> blacksmith_show_setup_checklist
  -> blacksmith_select_project_path
  -> blacksmith_show_testbox_project_guide
  -> blacksmith_show_runner_tags
  -> blacksmith_show_security_note
  -> action_blacksmith_setup

validation
  -> validate_project_path
  -> validate_env_name
  -> validate_repo_name

status messaging
  -> success
  -> error
  -> info
  -> warning

PM2 / ports
  -> get_pm2_data_cached
  -> invalidate_pm2_cache
  -> get_pm2_app_data
  -> list_pm2_app_names
  -> pm2_app_exists_by_name
  -> get_pm2_status_by_name
  -> list_all_stop_targets
  -> pm2_stop_app_by_name
  -> is_port_in_use
  -> get_all_pm2_ports
  -> find_available_port
  -> get_pm2_status
  -> get_port_from_pm2

user Caddy lifecycle
  -> refresh_user_caddy_from_pm2
  -> sync_caddy_after_pm2_change
  -> stop_user_caddy
  -> stop_caddy_if_no_pm2_apps
  -> aggressive_cleanup_menu

Flutter Web interactive dev
  -> flutter_web_sessions_file
  -> flutter_web_session_name
  -> list_flutter_web_projects
  -> flutter_web_registry_lines
  -> start_flutter_web_tmux_session
  -> send_flutter_web_key
  -> action_flutter_web

environment discovery
  -> resolve_project_path
  -> list_all_environments
  -> list_all_environment_identifiers
  -> cleanup_orphan_projects
  -> select_environment
  -> select_stop_target

session identity
  -> init_session
  -> get_session_id
  -> generate_hash_art
  -> get_session_code
  -> display_session_banner
  -> reset_session
  -> get_session_info
  -> get_session_info_for_ssh

GitHub / project detection
  -> list_github_repos
  -> get_github_username
  -> detect_pubspec_kind
  -> detect_dart_entrypoint
  -> detect_project_type
  -> validate_flox_runtime_package_token
  -> ensure_flox_runtime_packages
  -> python_runtime_command
  -> init_flox_env
  -> fix_port_config
  -> detect_dev_command

Doppler helpers
  -> escape_single_quotes_for_bash
  -> project_has_doppler_manifest
  -> project_has_doppler_scope
  -> should_enable_doppler

environment lifecycle
  -> env_start
  -> env_stop
  -> env_remove
  -> env_rename
  -> env_restart

web inspector
  -> generate_css_selector
  -> remove_next_script_import_if_unused
  -> remove_web_inspector_snippet
  -> web_inspector_is_enabled
  -> init_web_inspector
  -> toggle_web_inspector

health / dashboard
  -> get_status_icon
  -> get_pm2_health_data
  -> detect_crash_loop
  -> diagnose_app_errors
  -> health_check_all
  -> auto_fix_known_issues
  -> batch_stop_all
  -> batch_start_all
  -> batch_restart_all
  -> show_dashboard

logs / deploy / publish support
  -> view_environment_logs
  -> shipflow_init_project
  -> deploy_github_project

CLI action wrappers
  -> action_dashboard
  -> action_shipflow_overview
  -> action_deploy
  -> action_restart
  -> action_stop
  -> action_remove
  -> action_rename
  -> action_start_all
  -> action_stop_all
  -> action_restart_all
  -> action_mobile
  -> action_health
  -> action_reboot_vm
  -> action_exit
  -> action_view_logs
  -> action_navigate
  -> action_open_code
  -> action_inspector
  -> action_session
  -> action_publish
  -> action_adv_help
  -> action_cleanup
  -> action_updates
  -> action_tools
  -> action_install_sdk
  -> action_mcp_menu
  -> action_codex_launcher
  -> action_blacksmith_setup

menu / docs surfaces
  -> show_shipflow_menu
  -> show_help
  -> show_mobile_guide
```

## Read-First Paths

Si tu dois modifier le comportement principal du CLI :

1. `shipflow.sh`
2. `lib.sh`
3. `config.sh`
4. `menu_gum.sh` or `menu_bash.sh`

Si tu dois modifier le workflow local SSH :

1. `local/local.sh`
2. `local/dev-tunnel.sh`
3. `lib.sh` for shared remote session helpers

Si tu dois modifier l'installation :

1. `install.sh`
2. `config.sh`
3. `README.md`

## Hotspots

- `env_start`: plus gros noeud fonctionnel pour lancement, detection, port, PM2, Flox et refresh Caddy utilisateur.
- `show_dashboard`: vue centrale d'etat et aggregation PM2.
- `deploy_github_project`: flux de deploy distant depuis GitHub.
- `action_publish`: publication Caddy + DuckDNS.
- `local/local.sh main`: UX locale de tunnels SSH.

## Notes

- `lib.sh` combine logique metier, UI, operations systeme et menu wrappers. C'est pratique, mais c'est aussi le principal point de complexite du repo.
- Les invalidations PM2 (`invalidate_pm2_cache`) sont critiques apres start/stop/delete.
- Le frontend de menu est delegue a `menu_gum.sh` ou `menu_bash.sh`, non detailles ici.
