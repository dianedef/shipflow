#!/bin/bash
# blacksmith-login.sh - Blacksmith OAuth login helper via ephemeral SSH tunnel.

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
NC='\033[0m'

CONFIG_DIR="$HOME/.shipflow"
CURRENT_CONNECTION_FILE="$CONFIG_DIR/current_connection"
CURRENT_IDENTITY_FILE="$CONFIG_DIR/current_identity_file"
LOGIN_TIMEOUT_SECONDS="${SHIPFLOW_BLACKSMITH_LOGIN_TIMEOUT_SECONDS:-600}"

REMOTE_HOST=""
SSH_IDENTITY_FILE=""
TMP_DIR=""
OAUTH_OUTPUT_FILE=""
TUNNEL_LOG_FILE=""
REMOTE_SSH_PID=""
TUNNEL_PID=""

remote_blacksmith_path_prefix='export PATH="$HOME/.local/bin:$HOME/bin:/usr/local/bin:/usr/bin:/bin:$PATH";'

usage() {
    cat <<'EOF'
Usage: shipflow-blacksmith-login

Run this from your local machine. It starts `blacksmith auth login` on the
configured remote ShipFlow server, opens a temporary SSH callback tunnel, and
then opens or prints the official Blacksmith OAuth URL locally.
EOF
}

print_header() {
    echo -e "${BLUE}🔨 ShipFlow Blacksmith OAuth Login${NC}"
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

extract_oauth_url() {
    sed -nE 's/.*(https:\/\/[^[:space:]"]+).*/\1/p' "$OAUTH_OUTPUT_FILE" | tail -1
}

parse_blacksmith_oauth_port_from_text() {
    local text="$1"
    local port=""

    port="$(printf "%s\n" "$text" | sed -nE 's/.*[?&]callback_port=([0-9]{2,5})([^0-9].*)?$/\1/p' | tail -1)"
    if [ -n "$port" ]; then
        echo "$port"
        return 0
    fi

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
    parse_blacksmith_oauth_port_from_text "$(cat "$OAUTH_OUTPUT_FILE")"
}

open_browser_or_print() {
    local oauth_url="$1"
    echo -e "${BLUE}🌐 URL Blacksmith OAuth:${NC}"
    echo "$oauth_url"
    echo ""

    if command -v open >/dev/null 2>&1; then
        open "$oauth_url" >/dev/null 2>&1 || true
        echo -e "${GREEN}✓ Navigateur ouvert via open${NC}"
    elif command -v xdg-open >/dev/null 2>&1; then
        xdg-open "$oauth_url" >/dev/null 2>&1 || true
        echo -e "${GREEN}✓ Navigateur ouvert via xdg-open${NC}"
    elif command -v wslview >/dev/null 2>&1; then
        wslview "$oauth_url" >/dev/null 2>&1 || true
        echo -e "${GREEN}✓ Navigateur ouvert via wslview${NC}"
    elif command -v cmd.exe >/dev/null 2>&1; then
        cmd.exe /c start "" "$oauth_url" >/dev/null 2>&1 || true
        echo -e "${GREEN}✓ Navigateur ouvert via cmd.exe${NC}"
    else
        echo -e "${YELLOW}⚠ Aucun opener auto détecté.${NC}"
        echo -e "${YELLOW}  Ouvre l'URL ci-dessus manuellement dans ton navigateur local.${NC}"
    fi
}

wait_for_output_or_timeout() {
    local waited=0
    local max_wait=45
    while [ "$waited" -lt "$max_wait" ]; do
        if ! kill -0 "$REMOTE_SSH_PID" 2>/dev/null; then
            break
        fi
        if extract_oauth_url >/dev/null 2>&1 && extract_callback_port >/dev/null 2>&1; then
            return 0
        fi
        sleep 1
        waited=$((waited + 1))
    done
    return 1
}

remote_has_blacksmith_cli() {
    run_remote_ssh "bash -lc '$remote_blacksmith_path_prefix command -v blacksmith >/dev/null 2>&1'"
}

remote_has_blacksmith_credentials() {
    run_remote_ssh "bash -lc 'test -s \"\$HOME/.blacksmith/credentials\"'"
}

wait_remote_login_completion() {
    local timeout_seconds="$1"
    local elapsed=0

    while kill -0 "$REMOTE_SSH_PID" 2>/dev/null; do
        sleep 1
        elapsed=$((elapsed + 1))
        if [ "$elapsed" -ge "$timeout_seconds" ]; then
            echo -e "${RED}✗ Timeout OAuth atteint (${timeout_seconds}s).${NC}"
            return 1
        fi
    done

    wait "$REMOTE_SSH_PID"
}

run_blacksmith_login() {
    local oauth_url=""
    local callback_port=""

    local test_args=("-o" "BatchMode=yes")
    while IFS= read -r arg; do
        test_args+=("$arg")
    done < <(ssh_args)
    if ! ssh "${test_args[@]}" "$REMOTE_HOST" "echo ok" >/dev/null 2>&1; then
        echo -e "${RED}✗ SSH inaccessible vers '$REMOTE_HOST'.${NC}"
        echo -e "${YELLOW}  Ouvre le menu local 'urls', choisis c) Configurer nouveau serveur, puis vérifie l'IP, l'utilisateur et la clé.${NC}"
        return 1
    fi

    if ! remote_has_blacksmith_cli; then
        echo -e "${RED}✗ Blacksmith CLI absent sur le serveur distant.${NC}"
        echo -e "${YELLOW}  À lancer dans un terminal connecté au serveur:${NC}"
        echo "  curl -fsSL https://get.blacksmith.sh | sh"
        return 1
    fi

    if remote_has_blacksmith_credentials; then
        echo -e "${GREEN}✓ T'inquiète, c'est bon, t'es connecté.${NC}"
        return 0
    fi

    : > "$OAUTH_OUTPUT_FILE"
    : > "$TUNNEL_LOG_FILE"
    REMOTE_SSH_PID=""
    TUNNEL_PID=""

    run_remote_ssh "bash -lc '$remote_blacksmith_path_prefix BROWSER=echo blacksmith auth login & pid=\$!; wait \$pid'" \
        > "$OAUTH_OUTPUT_FILE" \
        2>&1 &
    REMOTE_SSH_PID="$!"

    if ! wait_for_output_or_timeout; then
        echo -e "${RED}✗ Impossible d'extraire URL OAuth + port callback depuis la sortie Blacksmith.${NC}"
        echo -e "${YELLOW}Sortie Blacksmith capturée:${NC}"
        sed 's/^/  /' "$OAUTH_OUTPUT_FILE" | tail -20
        echo -e "${YELLOW}  Si une URL a été affichée sans port callback, colle-la ici pour qu'on adapte le parseur.${NC}"
        return 1
    fi

    oauth_url="$(extract_oauth_url || true)"
    callback_port="$(extract_callback_port || true)"
    if [ -z "$oauth_url" ] || [ -z "$callback_port" ]; then
        echo -e "${RED}✗ Données OAuth incomplètes (URL/port).${NC}"
        return 1
    fi

    if ! check_local_port_free "$callback_port"; then
        echo -e "${RED}✗ Port local déjà occupé: $callback_port${NC}"
        return 1
    fi

    echo -e "${BLUE}🔁 Tunnel Blacksmith OAuth: localhost:${callback_port} -> ${REMOTE_HOST}:127.0.0.1:${callback_port}${NC}"
    local tunnel_args=("-N" "-L" "${callback_port}:127.0.0.1:${callback_port}")
    while IFS= read -r arg; do
        tunnel_args+=("$arg")
    done < <(ssh_args)
    ssh "${tunnel_args[@]}" "$REMOTE_HOST" >"$TUNNEL_LOG_FILE" 2>&1 &
    TUNNEL_PID="$!"
    sleep 1
    if ! kill -0 "$TUNNEL_PID" 2>/dev/null; then
        echo -e "${RED}✗ Impossible de démarrer le tunnel SSH OAuth Blacksmith.${NC}"
        return 1
    fi

    open_browser_or_print "$oauth_url"
    echo -e "${YELLOW}⏳ Finalise le login Blacksmith dans le navigateur...${NC}"

    if ! wait_remote_login_completion "$LOGIN_TIMEOUT_SECONDS"; then
        return 1
    fi

    if remote_has_blacksmith_credentials; then
        echo -e "${GREEN}✓ Login Blacksmith confirmé sur le serveur distant.${NC}"
        return 0
    fi

    echo -e "${RED}✗ Login terminé mais credentials Blacksmith non détectés sur le serveur.${NC}"
    return 1
}

main() {
    set -euo pipefail

    if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
        usage
        exit 0
    fi

    print_header
    mkdir -p "$CONFIG_DIR"
    load_remote_host

    trap cleanup EXIT INT TERM

    TMP_DIR="$(mktemp -d)"
    OAUTH_OUTPUT_FILE="$TMP_DIR/blacksmith-oauth-login.log"
    TUNNEL_LOG_FILE="$TMP_DIR/blacksmith-oauth-tunnel.log"

    echo -e "${BLUE}Connexion distante:${NC} ${GREEN}$REMOTE_HOST${NC}"
    echo ""

    if ! run_blacksmith_login; then
        echo -e "${RED}✗ Flow Blacksmith OAuth terminé avec erreur.${NC}"
        exit 1
    fi

    echo -e "${GREEN}✅ Flow Blacksmith OAuth terminé avec succès.${NC}"
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    main "$@"
fi
