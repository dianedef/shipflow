#!/bin/bash
# dev-tunnel.sh - Crée des tunnels SSH automatiques pour tous les ports PM2 actifs

set -e

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/../config.sh" ]; then
    source "$SCRIPT_DIR/../config.sh"
fi
# shellcheck source=remote-helpers.sh
source "$SCRIPT_DIR/remote-helpers.sh"

# Configuration directory
CONFIG_DIR="$HOME/.shipflow"
CURRENT_CONNECTION_FILE="$CONFIG_DIR/current_connection"
CURRENT_IDENTITY_FILE="$CONFIG_DIR/current_identity_file"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

get_managed_tunnel_pids() {
    ps -eo pid=,args= | while read -r pid cmd; do
        [ -n "$pid" ] || continue
        if [[ "$cmd" == *autossh* ]] &&
            [[ "$cmd" == *" -L "*":localhost:"* ]] &&
            [[ " $cmd " == *" $REMOTE_HOST "* ]]; then
            printf "%s\n" "$pid"
        fi
    done
}

stop_existing_tunnels() {
    local pids pid
    pids="$(get_managed_tunnel_pids || true)"
    [ -n "$pids" ] || return 0

    while IFS= read -r pid; do
        [ -n "$pid" ] || continue
        kill "$pid" 2>/dev/null || true
    done <<< "$pids"
}

is_local_port_free() {
    local port="$1"
    if command -v lsof >/dev/null 2>&1; then
        ! lsof -nP -iTCP:"$port" -sTCP:LISTEN >/dev/null 2>&1
        return
    fi
    if command -v ss >/dev/null 2>&1; then
        ! ss -ltn "( sport = :$port )" 2>/dev/null | grep -q ":$port"
        return
    fi
    return 0
}

center_session_banner_text() {
    local text="$1"
    local width="${2:-50}"
    local text_len=${#text}

    if [ "$text_len" -ge "$width" ]; then
        printf "%s" "$text"
        return
    fi

    local pad=$(( (width - text_len) / 2 ))
    printf "%*s%s" "$pad" "" "$text"
}

# Load saved connection or use default
if [ -f "$CURRENT_CONNECTION_FILE" ]; then
    REMOTE_HOST=$(cat "$CURRENT_CONNECTION_FILE")
else
    REMOTE_HOST="${REMOTE_HOST:-${SHIPFLOW_SSH_REMOTE_HOST:-}}"
    if [ -z "$REMOTE_HOST" ] && grep -qE '^[[:space:]]*Host[[:space:]]+hetzner([[:space:]]|$)' "$HOME/.ssh/config" 2>/dev/null; then
        REMOTE_HOST="hetzner"
    fi
fi

if [ -z "$REMOTE_HOST" ]; then
    echo -e "${RED}✗ Aucune connexion distante ShipFlow configurée.${NC}"
    echo -e "${YELLOW}  Configurez votre nouveau serveur depuis le menu local:${NC}"
    echo "  ~/shipflow/local/local.sh"
    echo -e "${YELLOW}  Puis choisissez c) Configurer nouveau serveur.${NC}"
    exit 1
fi

if ! validate_connection_target "$REMOTE_HOST"; then
    echo -e "${RED}✗ Connexion distante invalide: $REMOTE_HOST${NC}"
    echo -e "${YELLOW}  Format: user@host ou alias SSH, sans option SSH ni espace.${NC}"
    exit 1
fi

SSH_IDENTITY_FILE=""
if [ -f "$CURRENT_IDENTITY_FILE" ]; then
    SSH_IDENTITY_FILE=$(cat "$CURRENT_IDENTITY_FILE")
fi

if ! validate_identity_file "$SSH_IDENTITY_FILE"; then
    echo -e "${RED}✗ Clé SSH configurée invalide ou introuvable: $SSH_IDENTITY_FILE${NC}"
    echo -e "${YELLOW}  Ouvrez le menu local puis choisissez c) Configurer nouveau serveur.${NC}"
    exit 1
fi

SSH_CONFIG="$HOME/.ssh/config"

if [[ "${1:-}" == "--stop" || "${1:-}" == "stop" ]]; then
    echo -e "${BLUE}🛑 Arrêt des tunnels SSH pour ${GREEN}$REMOTE_HOST${NC}"
    pids="$(get_managed_tunnel_pids || true)"
    if [ -z "$pids" ]; then
        echo -e "${YELLOW}⚠ Aucun tunnel géré trouvé pour $REMOTE_HOST${NC}"
        exit 0
    fi

    while IFS= read -r pid; do
        [ -n "$pid" ] || continue
        if kill "$pid" 2>/dev/null; then
            echo -e "  ${GREEN}✓${NC} PID $pid arrêté"
        else
            echo -e "  ${RED}✗${NC} Impossible d'arrêter PID $pid"
        fi
    done <<< "$pids"
    exit 0
fi

if [ -n "${1:-}" ]; then
    echo -e "${RED}✗ Option inconnue: $1${NC}"
    echo "Usage: $0 [--stop]"
    exit 1
fi

echo -e "${BLUE}🚇 Dev Tunnel Manager${NC}"
echo ""

# Resolve the server-side library from canonical shipflow install paths.
fetch_server_session_info() {
    run_remote_ssh "bash -lc '
        for lib_path in \
            \"\${SHIPFLOW_ROOT:-\$HOME/shipflow}/lib.sh\"
        do
            if [ -f \"\$lib_path\" ]; then
                source \"\$lib_path\" 2>/dev/null
                get_session_info_for_ssh 2>/dev/null
                exit 0
            fi
        done

        echo SESSION_NOT_FOUND
    '" 2>/dev/null
}

# Retrieve and display server session identity
echo -e "${BLUE}🔐 Retrieving server session identity...${NC}"
SESSION_INFO=$(fetch_server_session_info || true)

if echo "$SESSION_INFO" | grep -q "SESSION_START"; then
    # Parse session info
    SESSION_USER=$(echo "$SESSION_INFO" | grep "^USER:" | cut -d: -f2)
    SESSION_HOST=$(echo "$SESSION_INFO" | grep "^HOST:" | cut -d: -f2)
    SESSION_CODE=$(echo "$SESSION_INFO" | grep "^CODE:" | cut -d: -f2)
    HASH_ART=$(echo "$SESSION_INFO" | sed -n '/---HASH_ART_START---/,/---HASH_ART_END---/p' | grep -v "^---")

    echo -e "             ${MAGENTA}Server Session Identity${NC}"
    echo -e "${CYAN}──────────────────────────────────────────────────${NC}"

    # Display hash art
    while IFS= read -r line; do
        echo -e "              ${BLUE}$line${NC}"
    done <<< "$HASH_ART"

    echo -e "${GREEN}$(center_session_banner_text "$SESSION_USER@$SESSION_HOST")${NC}"
    echo -e "${YELLOW}$(center_session_banner_text "$SESSION_CODE")${NC}"
    echo -e "${CYAN}──────────────────────────────────────────────────${NC}"
    echo ""
    echo -e "${GREEN}✓ Verify this pattern matches the server menu${NC}"
    echo ""
elif echo "$SESSION_INFO" | grep -q "SESSION_DISABLED"; then
    echo -e "${YELLOW}⚠ Session identity is disabled on the server${NC}"
    echo ""
elif echo "$SESSION_INFO" | grep -q "SESSION_NOT_FOUND"; then
    echo -e "${YELLOW}⚠ ShipFlow not found on server (session identity unavailable)${NC}"
    echo ""
else
    echo -e "${YELLOW}⚠ Could not retrieve session identity${NC}"
    echo ""
fi

# Vérifier que autossh est installé
if ! command -v autossh &> /dev/null; then
    echo -e "${RED}✗ autossh n'est pas installé${NC}"
    echo -e "${YELLOW}  Installation: brew install autossh (macOS) ou apt install autossh (Linux)${NC}"
    exit 1
fi

# Vérifier la connexion SSH (test rapide)
# On accepte user@host ou alias SSH
if [[ "$REMOTE_HOST" != *"@"* ]]; then
    # C'est un alias, vérifier dans la config SSH
    if ! grep -q "Host $REMOTE_HOST" "$SSH_CONFIG" 2>/dev/null; then
        echo -e "${YELLOW}⚠ Configuration SSH manquante pour '$REMOTE_HOST'${NC}"
        echo -e "${YELLOW}  Ajoutez la configuration dans $SSH_CONFIG ou utilisez user@host${NC}"
    fi
fi
echo -e "${BLUE}🔌 Connexion: ${GREEN}$REMOTE_HOST${NC}"
echo ""

# Récupérer les ports actifs depuis PM2 sur le serveur distant
echo -e "${BLUE}📡 Récupération des ports actifs depuis PM2...${NC}"

PORTS=$(run_remote_ssh "$(shipflow_remote_pm2_ports_command comma)" 2>/dev/null || true)

if [ -z "$PORTS" ]; then
    echo -e "${RED}✗ Aucun port trouvé ou PM2 n'est pas accessible${NC}"
    echo -e "${YELLOW}  Vérifiez que PM2 tourne sur le serveur distant${NC}"
    exit 1
fi

# Detect port collisions before creating tunnels
declare -A PORT_MAP
COLLISION=false
IFS=',' read -ra CHECK_ARRAY <<< "$PORTS"
for port_info in "${CHECK_ARRAY[@]}"; do
    IFS=':' read -r port name <<< "$port_info"
    if ! validate_tcp_port "$port"; then
        echo -e "${RED}✗ Port PM2 invalide ignoré par sécurité: $port${NC}"
        COLLISION=true
        continue
    fi
    if [ -n "${PORT_MAP[$port]+x}" ]; then
        echo -e "${RED}⚠ COLLISION: port $port utilisé par ${PORT_MAP[$port]} ET $name${NC}"
        COLLISION=true
    fi
    PORT_MAP[$port]="$name"
done
if [ "$COLLISION" = true ]; then
    echo -e "${YELLOW}⚠ Des collisions de ports ont été détectées!${NC}"
    echo -e "${YELLOW}  Relancez les apps en conflit sur le serveur avec: env_start \"app_name\"${NC}"
    echo -e "${YELLOW}  Aucun tunnel existant n'a été modifié.${NC}"
    exit 1
fi

# Arrêter les tunnels existants
echo -e "${BLUE}🛑 Arrêt des tunnels existants...${NC}"
stop_existing_tunnels
sleep 1

# Créer les tunnels
echo -e "${GREEN}✓ Création des tunnels SSH${NC}"
echo ""

IFS=',' read -ra PORT_ARRAY <<< "$PORTS"
FAILED_TUNNELS=()
for port_info in "${PORT_ARRAY[@]}"; do
    IFS=':' read -r port name <<< "$port_info"

    if ! is_local_port_free "$port"; then
        echo -e "${RED}  ✗ localhost:${port} est déjà occupé (${name})${NC}"
        FAILED_TUNNELS+=("${port}:${name}")
        continue
    fi
    
    echo -e "${GREEN}  ✓ localhost:${port} → ${name}${NC}"
    
    # Créer le tunnel avec autossh (maintient la connexion)
    autossh_args=(
        -M 0 -f -N
        -o "ServerAliveInterval=${SHIPFLOW_SSH_KEEPALIVE_INTERVAL:-30}"
        -o "ServerAliveCountMax=${SHIPFLOW_SSH_KEEPALIVE_MAX:-3}"
        -o "ExitOnForwardFailure=yes"
        -L "${port}:localhost:${port}"
    )
    if [ -n "${SSH_IDENTITY_FILE:-}" ]; then
        autossh_args+=("-i" "$(normalize_identity_path "$SSH_IDENTITY_FILE")" "-o" "IdentitiesOnly=yes")
    fi
    if ! autossh "${autossh_args[@]}" "$REMOTE_HOST" 2>/dev/null; then
        echo -e "${RED}  ✗ Impossible de créer le tunnel localhost:${port} (${name})${NC}"
        FAILED_TUNNELS+=("${port}:${name}")
    fi
done

if [ "${#FAILED_TUNNELS[@]}" -gt 0 ]; then
    echo ""
    echo -e "${RED}✗ Certains tunnels n'ont pas pu être créés.${NC}"
    echo -e "${YELLOW}  Vérifiez les ports locaux occupés et la configuration SSH, puis relancez.${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✓ Tunnels actifs !${NC}"
echo ""
echo -e "${BLUE}📋 URLs disponibles :${NC}"

for port_info in "${PORT_ARRAY[@]}"; do
    IFS=':' read -r port name <<< "$port_info"
    echo -e "  • http://localhost:${port} ${YELLOW}(${name})${NC}"
done

echo ""
echo -e "${YELLOW}💡 Les tunnels restent actifs en arrière-plan${NC}"
echo -e "${YELLOW}   Pour les arrêter : $0 --stop${NC}"
