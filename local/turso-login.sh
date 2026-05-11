#!/bin/bash
# turso-login.sh - Turso CLI login helper for a remote ShipFlow server.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/../config.sh" ]; then
    # shellcheck source=../config.sh
    source "$SCRIPT_DIR/../config.sh"
fi
# shellcheck source=remote-helpers.sh
source "$SCRIPT_DIR/remote-helpers.sh"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

CONFIG_DIR="$HOME/.shipflow"
CURRENT_CONNECTION_FILE="$CONFIG_DIR/current_connection"
CURRENT_IDENTITY_FILE="$CONFIG_DIR/current_identity_file"
LOGIN_TIMEOUT_SECONDS="${SHIPFLOW_TURSO_LOGIN_TIMEOUT_SECONDS:-600}"

REMOTE_HOST=""
SSH_IDENTITY_FILE=""
PROJECT_DIR="${SHIPFLOW_TURSO_REMOTE_PROJECT_DIR:-}"
FORCE_HEADLESS=1
TMP_DIR=""
LOGIN_OUTPUT_FILE=""
TUNNEL_LOG_FILE=""
REMOTE_SSH_PID=""
TUNNEL_PID=""

usage() {
    cat <<'EOF'
Usage: shipflow-turso-login [options]

Run this from your local machine. It starts Turso CLI auth on the configured
remote ShipFlow server. Turso's supported remote/WSL mode is headless, so this
helper uses `turso auth login --headless` by default, opens or prints the auth
URL locally, then asks you to confirm before it verifies `turso auth whoami`.

Options:
  --project-dir <path>   Run remote Turso through `flox activate -d <path> --`.
  --headless             Use `turso auth login --headless` (default).
  --browser-callback     Try browser callback/tunnel mode instead.
  -h, --help             Show this help.

Examples:
  shipflow-turso-login
  shipflow-turso-login --project-dir /home/<user>/<projet>
EOF
}

print_header() {
    local brand="ShipFlow DevServer"
    local title="Turso Login"
    echo -e "${CYAN}╔══════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                                                  ║${NC}"
    echo -e "${CYAN}║  ${YELLOW}              ${brand}              ${CYAN}  ║${NC}"
    echo -e "${CYAN}║  ${YELLOW}               ${title}                ${CYAN}  ║${NC}"
    echo -e "${CYAN}║                                                  ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════╝${NC}"
    echo ""
}

remote_quote() {
    printf '%q' "$1"
}

run_remote_bash() {
    run_remote_ssh "bash -lc $(remote_quote "$1")"
}

remote_turso_command() {
    local subcommand="$1"
    local quoted_project_dir

    if [ -n "$PROJECT_DIR" ]; then
        quoted_project_dir="$(remote_quote "$PROJECT_DIR")"
        printf 'flox activate -d %s -- turso %s' "$quoted_project_dir" "$subcommand"
    else
        printf 'turso %s' "$subcommand"
    fi
}

load_remote_host() {
    if [ -f "$CURRENT_CONNECTION_FILE" ]; then
        REMOTE_HOST="$(cat "$CURRENT_CONNECTION_FILE")"
    else
        REMOTE_HOST="${REMOTE_HOST:-$SHIPFLOW_SSH_REMOTE_HOST}"
        if [ -z "$REMOTE_HOST" ] && grep -qE '^[[:space:]]*Host[[:space:]]+hetzner([[:space:]]|$)' "$HOME/.ssh/config" 2>/dev/null; then
            REMOTE_HOST="hetzner"
        fi
    fi

    if [ -z "$REMOTE_HOST" ]; then
        echo -e "${RED}✗ Aucune connexion distante ShipFlow configurée.${NC}"
        echo -e "${YELLOW}  Ouvre le menu local 'urls', choisis c) Configurer nouveau serveur, puis entre l'adresse SSH.${NC}"
        exit 1
    fi

    if ! validate_connection_target "$REMOTE_HOST"; then
        echo -e "${RED}✗ Connexion distante invalide: $REMOTE_HOST${NC}"
        echo -e "${YELLOW}  Corrige ~/.shipflow/current_connection via le menu local.${NC}"
        exit 1
    fi

    if [ -f "$CURRENT_IDENTITY_FILE" ]; then
        SSH_IDENTITY_FILE="$(cat "$CURRENT_IDENTITY_FILE")"
    fi

    if ! validate_identity_file "$SSH_IDENTITY_FILE"; then
        echo -e "${RED}✗ Clé SSH configurée invalide ou introuvable: $SSH_IDENTITY_FILE${NC}"
        echo -e "${YELLOW}  Ouvre 'urls', choisis c) Configurer nouveau serveur, puis renseigne le bon chemin de clé.${NC}"
        exit 1
    fi
}

parse_args() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            -h|--help)
                usage
                exit 0
                ;;
            --headless)
                FORCE_HEADLESS=1
                shift
                ;;
            --browser-callback)
                FORCE_HEADLESS=0
                shift
                ;;
            --project-dir)
                if [ -z "${2:-}" ]; then
                    echo -e "${RED}✗ --project-dir attend un chemin.${NC}"
                    exit 1
                fi
                PROJECT_DIR="$2"
                shift 2
                ;;
            *)
                echo -e "${RED}✗ Option inconnue: $1${NC}"
                usage
                exit 1
                ;;
        esac
    done
}

cleanup() {
    if [ -n "${TUNNEL_PID:-}" ] && kill -0 "$TUNNEL_PID" 2>/dev/null; then
        kill "$TUNNEL_PID" 2>/dev/null || true
        wait "$TUNNEL_PID" 2>/dev/null || true
    fi

    if [ -n "${REMOTE_SSH_PID:-}" ] && kill -0 "$REMOTE_SSH_PID" 2>/dev/null; then
        kill "$REMOTE_SSH_PID" 2>/dev/null || true
        wait "$REMOTE_SSH_PID" 2>/dev/null || true
    fi

    if [ -n "${TMP_DIR:-}" ] && [ -d "$TMP_DIR" ]; then
        rm -rf "$TMP_DIR"
    fi
}

check_local_port_free() {
    local port="$1"
    if command -v lsof >/dev/null 2>&1 && lsof -nP -iTCP:"$port" -sTCP:LISTEN >/dev/null 2>&1; then
        return 1
    fi
    if command -v ss >/dev/null 2>&1 && ss -ltn "( sport = :$port )" 2>/dev/null | grep -q ":$port"; then
        return 1
    fi
    return 0
}

wait_remote_callback_port_ready() {
    local port="$1"
    local waited=0
    local max_wait=20

    while [ "$waited" -lt "$max_wait" ]; do
        if run_remote_bash "command -v ss >/dev/null 2>&1 && ss -ltn '( sport = :$port )' 2>/dev/null | grep -q ':$port'"; then
            return 0
        fi
        sleep 0.5
        waited=$((waited + 1))
    done

    return 1
}

wait_local_tunnel_ready() {
    local port="$1"
    local waited=0
    local max_wait=20

    while [ "$waited" -lt "$max_wait" ]; do
        if command -v nc >/dev/null 2>&1 && nc -z 127.0.0.1 "$port" >/dev/null 2>&1; then
            return 0
        fi
        if command -v lsof >/dev/null 2>&1 && lsof -nP -iTCP:"$port" -sTCP:LISTEN >/dev/null 2>&1; then
            return 0
        fi
        sleep 0.5
        waited=$((waited + 1))
    done

    return 1
}

extract_auth_url() {
    sed -nE 's/.*(https:\/\/[^[:space:]"]+).*/\1/p' "$LOGIN_OUTPUT_FILE" | tail -1
}

parse_turso_callback_port_from_text() {
    local text="$1"
    local port=""

    port="$(printf "%s\n" "$text" | sed -nE 's/.*redirect_uri=http%3A%2F%2F(127\.0\.0\.1|localhost)%3A([0-9]{2,5})%2Fcallback.*/\2/p' | tail -1)"
    if [ -n "$port" ]; then
        echo "$port"
        return 0
    fi

    port="$(printf "%s\n" "$text" | sed -nE 's/.*http:\/\/(127\.0\.0\.1|localhost):([0-9]{2,5})\/callback.*/\2/p' | tail -1)"
    if [ -n "$port" ]; then
        echo "$port"
        return 0
    fi

    return 1
}

extract_callback_port() {
    parse_turso_callback_port_from_text "$(cat "$LOGIN_OUTPUT_FILE")"
}

open_browser_or_print() {
    local auth_url="$1"
    local opened=0

    echo -e "${BLUE}🌐 URL Turso:${NC}"
    echo "$auth_url"
    echo ""

    if command -v open >/dev/null 2>&1; then
        open "$auth_url" >/dev/null 2>&1 && opened=1
    elif command -v xdg-open >/dev/null 2>&1; then
        xdg-open "$auth_url" >/dev/null 2>&1 && opened=1
    elif command -v wslview >/dev/null 2>&1; then
        wslview "$auth_url" >/dev/null 2>&1 && opened=1
    elif command -v cmd.exe >/dev/null 2>&1; then
        cmd.exe /c start "" "$auth_url" >/dev/null 2>&1 && opened=1
    elif command -v python3 >/dev/null 2>&1; then
        python3 -m webbrowser "$auth_url" >/dev/null 2>&1 && opened=1
    fi

    if [ "$opened" -eq 1 ]; then
        echo -e "${GREEN}✓ Navigateur local ouvert${NC}"
    else
        echo -e "${YELLOW}⚠ Impossible d'ouvrir automatiquement le navigateur.${NC}"
        echo -e "${YELLOW}  Ouvre l'URL Turso ci-dessus manuellement dans ton navigateur local.${NC}"
    fi
}

prompt_headless_verification() {
    echo ""
    echo -e "${YELLOW}Après avoir terminé le login Turso dans ton navigateur, reviens ici.${NC}"
    echo -e "${YELLOW}Appuie sur Entrée pour vérifier l'auth côté serveur.${NC}"
    if [ -r /dev/tty ]; then
        read -r _ < /dev/tty || true
    else
        read -r _ || true
    fi
}

wait_for_url_or_timeout() {
    local waited=0
    local max_wait=45
    while [ "$waited" -lt "$max_wait" ]; do
        if ! kill -0 "$REMOTE_SSH_PID" 2>/dev/null; then
            break
        fi
        if extract_auth_url >/dev/null 2>&1; then
            return 0
        fi
        sleep 1
        waited=$((waited + 1))
    done
    return 1
}

check_remote_ssh() {
    local test_args=("-o" "BatchMode=yes")
    while IFS= read -r arg; do
        test_args+=("$arg")
    done < <(ssh_args)
    if ! ssh "${test_args[@]}" "$REMOTE_HOST" "echo ok" >/dev/null 2>&1; then
        echo -e "${RED}✗ SSH inaccessible vers '$REMOTE_HOST'.${NC}"
        echo -e "${YELLOW}  Ouvre le menu local 'urls', choisis c) Configurer nouveau serveur, puis vérifie l'IP, l'utilisateur et la clé.${NC}"
        return 1
    fi
}

verify_remote_turso_cli() {
    local check_command

    if [ -n "$PROJECT_DIR" ]; then
        check_command="command -v flox >/dev/null 2>&1 && test -d $(remote_quote "$PROJECT_DIR")"
        if ! run_remote_bash "$check_command"; then
            echo -e "${RED}✗ Flox absent ou project-dir introuvable sur le serveur: $PROJECT_DIR${NC}"
            return 1
        fi
    elif ! run_remote_bash 'command -v turso >/dev/null 2>&1'; then
        echo -e "${RED}✗ Turso CLI absent sur le serveur distant.${NC}"
        echo -e "${YELLOW}  Installe Turso sur le serveur ou utilise --project-dir avec un env Flox qui fournit turso.${NC}"
        return 1
    fi

    return 0
}

verify_remote_auth() {
    local command
    local output
    command="$(remote_turso_command 'auth whoami')"
    output="$(run_remote_bash "$command" 2>&1 || true)"
    printf '%s\n' "$output"

    [ -n "$output" ] || return 1
    if printf '%s\n' "$output" | grep -Eqi 'not logged in|please login|not authenticated|unauthenticated'; then
        return 1
    fi

    return 0
}

wait_remote_login_completion() {
    local timeout_seconds="$1"
    local elapsed=0

    while kill -0 "$REMOTE_SSH_PID" 2>/dev/null; do
        sleep 1
        elapsed=$((elapsed + 1))
        if [ "$elapsed" -ge "$timeout_seconds" ]; then
            echo -e "${RED}✗ Timeout login Turso atteint (${timeout_seconds}s).${NC}"
            return 1
        fi
    done

    wait "$REMOTE_SSH_PID"
}

start_remote_login() {
    local login_command

    if [ "$FORCE_HEADLESS" -eq 1 ]; then
        login_command="$(remote_turso_command 'auth login --headless')"
    else
        login_command="$(remote_turso_command 'auth login')"
        login_command="BROWSER=echo $login_command"
    fi

    run_remote_bash "$login_command" > >(tee -a "$LOGIN_OUTPUT_FILE") 2> >(tee -a "$LOGIN_OUTPUT_FILE" >&2) &
    REMOTE_SSH_PID="$!"
}

run_turso_login() {
    local auth_url=""
    local callback_port=""

    if ! check_remote_ssh; then
        return 1
    fi

    if ! verify_remote_turso_cli; then
        return 1
    fi

    if verify_remote_auth >/dev/null 2>&1; then
        echo -e "${GREEN}✓ Turso est déjà connecté sur le serveur distant.${NC}"
        verify_remote_auth
        return 0
    fi

    : > "$LOGIN_OUTPUT_FILE"
    : > "$TUNNEL_LOG_FILE"
    REMOTE_SSH_PID=""
    TUNNEL_PID=""

    start_remote_login

    if ! wait_for_url_or_timeout; then
        echo -e "${RED}✗ Impossible d'extraire l'URL de login Turso depuis la sortie distante.${NC}"
        echo -e "${YELLOW}Sortie Turso capturée:${NC}"
        sed 's/^/  /' "$LOGIN_OUTPUT_FILE" | tail -30
        return 1
    fi

    auth_url="$(extract_auth_url || true)"
    callback_port="$(extract_callback_port || true)"
    if [ -z "$auth_url" ]; then
        echo -e "${RED}✗ URL Turso manquante.${NC}"
        return 1
    fi

    if [ -n "$callback_port" ]; then
        if ! check_local_port_free "$callback_port"; then
            echo -e "${RED}✗ Port local déjà occupé: $callback_port${NC}"
            return 1
        fi

        echo -e "${BLUE}⏳ Attente du callback Turso distant sur 127.0.0.1:${callback_port}...${NC}"
        if ! wait_remote_callback_port_ready "$callback_port"; then
            echo -e "${YELLOW}⚠ Callback distant non détecté sur le port ${callback_port}.${NC}"
            echo -e "${YELLOW}  Je tente quand même le tunnel; si le navigateur échoue, relance avec --headless.${NC}"
        fi

        echo -e "${BLUE}🔁 Tunnel Turso OAuth: localhost:${callback_port} -> ${REMOTE_HOST}:127.0.0.1:${callback_port}${NC}"
        local tunnel_args=("-N" "-o" "ExitOnForwardFailure=yes" "-L" "${callback_port}:127.0.0.1:${callback_port}")
        while IFS= read -r arg; do
            tunnel_args+=("$arg")
        done < <(ssh_args)
        ssh "${tunnel_args[@]}" "$REMOTE_HOST" >"$TUNNEL_LOG_FILE" 2>&1 &
        TUNNEL_PID="$!"
        sleep 0.5
        if ! kill -0 "$TUNNEL_PID" 2>/dev/null || ! wait_local_tunnel_ready "$callback_port"; then
            echo -e "${RED}✗ Impossible de démarrer le tunnel SSH OAuth Turso.${NC}"
            [ -s "$TUNNEL_LOG_FILE" ] && sed 's/^/  /' "$TUNNEL_LOG_FILE" | tail -10
            return 1
        fi
        echo -e "${GREEN}✓ Tunnel Turso prêt sur localhost:${callback_port}${NC}"
    else
        echo -e "${YELLOW}⚠ Aucun callback localhost détecté; Turso semble utiliser un login headless/device.${NC}"
        echo -e "${YELLOW}  Pas de tunnel nécessaire pour ce mode.${NC}"
    fi

    open_browser_or_print "$auth_url"
    echo -e "${YELLOW}⏳ Finalise le login Turso dans le navigateur...${NC}"

    if [ "$FORCE_HEADLESS" -eq 1 ]; then
        prompt_headless_verification
        if kill -0 "$REMOTE_SSH_PID" 2>/dev/null; then
            wait "$REMOTE_SSH_PID" || true
        fi
    else
        if ! wait_remote_login_completion "$LOGIN_TIMEOUT_SECONDS"; then
            return 1
        fi
    fi

    echo -e "${BLUE}👤 Vérification Turso distante...${NC}"
    if verify_remote_auth; then
        echo -e "${GREEN}✓ Login Turso confirmé sur le serveur distant.${NC}"
        return 0
    fi

    echo -e "${RED}✗ Login terminé mais auth Turso non confirmée sur le serveur.${NC}"
    if [ "$FORCE_HEADLESS" -eq 1 ]; then
        echo -e "${YELLOW}  Si Turso ne persiste pas l'auth après ce lien headless, utilise le fallback:${NC}"
        echo -e "  ${CYAN}urls → d) Turso → f) Fallback: copier la session Turso locale${NC}"
    fi
    return 1
}

main() {
    set -euo pipefail

    parse_args "$@"
    print_header
    mkdir -p "$CONFIG_DIR"
    load_remote_host

    trap cleanup EXIT INT TERM

    TMP_DIR="$(mktemp -d)"
    LOGIN_OUTPUT_FILE="$TMP_DIR/turso-login.log"
    TUNNEL_LOG_FILE="$TMP_DIR/turso-login-tunnel.log"

    echo -e "${BLUE}Connexion distante:${NC} ${GREEN}$REMOTE_HOST${NC}"
    if [ -n "$PROJECT_DIR" ]; then
        echo -e "${BLUE}Turso remote:${NC} ${GREEN}flox activate -d $PROJECT_DIR -- turso${NC}"
    fi
    echo ""

    if ! run_turso_login; then
        echo -e "${RED}✗ Flow Turso login terminé avec erreur.${NC}"
        exit 1
    fi

    echo -e "${GREEN}✅ Flow Turso login terminé avec succès.${NC}"
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    main "$@"
fi
