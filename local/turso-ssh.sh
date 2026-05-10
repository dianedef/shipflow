#!/bin/bash
# turso-ssh.sh - Transfer Turso CLI auth state to the configured ShipFlow server.

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
LOCAL_TURSO_CONFIG_DIR="${SHIPFLOW_TURSO_CONFIG_DIR:-$HOME/.config/turso}"

REMOTE_HOST=""
SSH_IDENTITY_FILE=""
COPY_CONFIG=1
DB_NAME=""
PROJECT_DIR="${SHIPFLOW_TURSO_REMOTE_PROJECT_DIR:-}"

usage() {
    cat <<'EOF'
Usage: shipflow-turso-ssh [options] [db-name]

Copies the local Turso CLI auth config to the configured ShipFlow server over
SSH, then verifies `turso auth whoami` on the remote host. If db-name is
provided, it also runs the ContentFlow schema checks for jobs and
CustomerPersona.

Options:
  --no-copy              Skip scp and only verify remote Turso auth/checks.
  --project-dir <path>   Run remote Turso through `flox activate -d <path> --`.
  -h, --help             Show this help.

Examples:
  shipflow-turso-ssh
  shipflow-turso-ssh contentflow-prod2
  shipflow-turso-ssh --project-dir /home/ubuntu/contentflow/contentflow_lab contentflow-prod2
EOF
}

print_header() {
    echo -e "${CYAN}╔══════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                                                  ║${NC}"
    echo -e "${CYAN}║  ${YELLOW}              ShipFlow DevServer              ${CYAN}  ║${NC}"
    echo -e "${CYAN}║  ${YELLOW}               Turso SSH Auth                ${CYAN}  ║${NC}"
    echo -e "${CYAN}║                                                  ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════╝${NC}"
    echo ""
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
        echo -e "${YELLOW}  Ouvre le menu local 'urls', choisis c) Configurer nouveau serveur, puis renseigne l'hôte SSH.${NC}"
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
            --no-copy)
                COPY_CONFIG=0
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
            --*)
                echo -e "${RED}✗ Option inconnue: $1${NC}"
                usage
                exit 1
                ;;
            *)
                if [ -n "$DB_NAME" ]; then
                    echo -e "${RED}✗ Un seul db-name est accepté.${NC}"
                    usage
                    exit 1
                fi
                DB_NAME="$1"
                shift
                ;;
        esac
    done

    if [ -n "$DB_NAME" ] && [[ ! "$DB_NAME" =~ ^[A-Za-z0-9._:-]+$ ]]; then
        echo -e "${RED}✗ Nom de base invalide: $DB_NAME${NC}"
        echo -e "${YELLOW}  Format autorisé: lettres, chiffres, '.', '_', '-' et ':'.${NC}"
        exit 1
    fi
}

remote_quote() {
    printf '%q' "$1"
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

run_remote_bash() {
    run_remote_ssh "bash -lc $(remote_quote "$1")"
}

check_remote_ssh() {
    local test_args=("-o" "BatchMode=yes")
    while IFS= read -r arg; do
        test_args+=("$arg")
    done < <(ssh_args)

    if ! ssh "${test_args[@]}" "$REMOTE_HOST" "echo ok" >/dev/null 2>&1; then
        echo -e "${RED}✗ SSH inaccessible vers '$REMOTE_HOST'.${NC}"
        echo -e "${YELLOW}  Vérifie l'IP, l'utilisateur et la clé dans le menu local 'urls'.${NC}"
        exit 1
    fi
}

copy_turso_config() {
    local scp_args=()

    if [ ! -d "$LOCAL_TURSO_CONFIG_DIR" ]; then
        echo -e "${RED}✗ Config Turso locale introuvable: $LOCAL_TURSO_CONFIG_DIR${NC}"
        echo -e "${YELLOW}  Connecte-toi d'abord localement: turso auth login --headless${NC}"
        return 1
    fi

    echo -e "${BLUE}📦 Préparation du dossier distant ~/.config/turso...${NC}"
    run_remote_bash 'mkdir -p "$HOME/.config/turso" && chmod 700 "$HOME/.config" "$HOME/.config/turso"'

    while IFS= read -r arg; do
        scp_args+=("$arg")
    done < <(ssh_args)

    echo -e "${BLUE}🔐 Copie de la session Turso vers ${GREEN}$REMOTE_HOST${BLUE}...${NC}"
    scp -r "${scp_args[@]}" "$LOCAL_TURSO_CONFIG_DIR/." "$REMOTE_HOST:~/.config/turso/" >/dev/null
    run_remote_bash 'chmod -R go-rwx "$HOME/.config/turso"'
    echo -e "${GREEN}✓ Config Turso copiée sans afficher de token.${NC}"
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
    command="$(remote_turso_command 'auth whoami')"
    echo -e "${BLUE}👤 Vérification Turso distante...${NC}"
    if run_remote_bash "$command"; then
        echo -e "${GREEN}✓ Auth Turso confirmée sur le serveur.${NC}"
        return 0
    fi

    echo -e "${RED}✗ Turso n'est pas authentifié sur le serveur.${NC}"
    echo -e "${YELLOW}  Relance sans --no-copy après un login local: turso auth login --headless${NC}"
    return 1
}

run_remote_sql() {
    local db="$1"
    local sql="$2"
    local command
    command="$(remote_turso_command "db shell $(remote_quote "$db") $(remote_quote "$sql")")"
    run_remote_bash "$command"
}

run_contentflow_checks() {
    local db="$1"

    echo ""
    echo -e "${BLUE}🧱 Tables clés dans ${GREEN}$db${BLUE}:${NC}"
    run_remote_sql "$db" "SELECT name FROM sqlite_master WHERE type='table' AND name IN ('jobs','CustomerPersona','UserSettings','Project','UserProviderCredential');"

    echo ""
    echo -e "${BLUE}🧱 Colonnes jobs:${NC}"
    run_remote_sql "$db" "PRAGMA table_info(jobs);"

    echo ""
    echo -e "${BLUE}🧱 Colonnes CustomerPersona:${NC}"
    run_remote_sql "$db" "PRAGMA table_info(CustomerPersona);"
}

main() {
    set -euo pipefail

    parse_args "$@"
    print_header
    load_remote_host

    echo -e "${BLUE}Connexion distante:${NC} ${GREEN}$REMOTE_HOST${NC}"
    if [ -n "$PROJECT_DIR" ]; then
        echo -e "${BLUE}Turso remote:${NC} ${GREEN}flox activate -d $PROJECT_DIR -- turso${NC}"
    fi
    echo ""

    check_remote_ssh

    if [ "$COPY_CONFIG" -eq 1 ]; then
        copy_turso_config
    else
        echo -e "${YELLOW}⚠ Copie ignorée (--no-copy).${NC}"
    fi

    verify_remote_turso_cli
    verify_remote_auth

    if [ -n "$DB_NAME" ]; then
        run_contentflow_checks "$DB_NAME"
    else
        echo ""
        echo -e "${YELLOW}Passe un nom de base pour lancer les checks SQL, par exemple:${NC}"
        echo -e "  ${CYAN}shipflow-turso-ssh contentflow-prod2${NC}"
    fi

    echo ""
    echo -e "${GREEN}✅ Flow Turso SSH terminé.${NC}"
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    main "$@"
fi
