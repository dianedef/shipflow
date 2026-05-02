#!/bin/bash

# Menu Local - Gestion des tunnels SSH vers un serveur ShipFlow
# Accès rapide aux projets distants via tunnels SSH

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=remote-helpers.sh
source "$SCRIPT_DIR/remote-helpers.sh"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Configuration file for saved connections
CONFIG_DIR="$HOME/.shipflow"
CONNECTIONS_FILE="$CONFIG_DIR/connections.conf"
CURRENT_CONNECTION_FILE="$CONFIG_DIR/current_connection"
CURRENT_IDENTITY_FILE="$CONFIG_DIR/current_identity_file"

# Initialize config directory
mkdir -p "$CONFIG_DIR" 2>/dev/null

# Load or set default connection
load_current_connection() {
    if [ -f "$CURRENT_CONNECTION_FILE" ]; then
        REMOTE_HOST=$(cat "$CURRENT_CONNECTION_FILE")
    elif [ -n "${SHIPFLOW_SSH_REMOTE_HOST:-}" ]; then
        REMOTE_HOST="$SHIPFLOW_SSH_REMOTE_HOST"
    elif grep -qE '^[[:space:]]*Host[[:space:]]+hetzner([[:space:]]|$)' "$HOME/.ssh/config" 2>/dev/null; then
        REMOTE_HOST="hetzner"
    else
        REMOTE_HOST=""
    fi

    if [ -f "$CURRENT_IDENTITY_FILE" ]; then
        SSH_IDENTITY_FILE=$(cat "$CURRENT_IDENTITY_FILE")
    else
        SSH_IDENTITY_FILE=""
    fi
}

# Save current connection
save_current_connection() {
    echo "$REMOTE_HOST" > "$CURRENT_CONNECTION_FILE"
}

save_identity_file() {
    local identity_file="$1"
    if [ -n "$identity_file" ]; then
        echo "$identity_file" > "$CURRENT_IDENTITY_FILE"
        chmod 600 "$CURRENT_IDENTITY_FILE" 2>/dev/null || true
    else
        rm -f "$CURRENT_IDENTITY_FILE"
    fi
}

# Add connection to saved list
add_saved_connection() {
    local connection="$1"
    # Create file if not exists
    touch "$CONNECTIONS_FILE"
    # Add if not already present
    if ! grep -q "^${connection}$" "$CONNECTIONS_FILE" 2>/dev/null; then
        echo "$connection" >> "$CONNECTIONS_FILE"
    fi
}

# Get saved connections
get_saved_connections() {
    if [ -f "$CONNECTIONS_FILE" ]; then
        cat "$CONNECTIONS_FILE" | sort -u
    fi
}

normalize_menu_choice() {
    local choice="${1:-}"

    choice="${choice//$'\r'/}"
    choice="${choice#"${choice%%[![:space:]]*}"}"
    choice="${choice%"${choice##*[![:space:]]}"}"
    choice=$(printf '%s' "$choice" | tr '[:upper:]' '[:lower:]')

    printf '%s' "$choice"
}

menu_letter_key() {
    local index="$1"
    local alphabet="abcdefghijklmopqrstuvwyz"
    local base=${#alphabet}
    local key=""
    local n="$index"

    while true; do
        local rem=$((n % base))
        key="${alphabet:rem:1}${key}"
        n=$((n / base - 1))
        [ "$n" -lt 0 ] && break
    done

    printf '%s' "$key"
}

read_menu_choice() {
    local target_var="$1"
    local allow_two_chars="${2:-false}"
    local value=""
    local next=""

    if [ -r /dev/tty ] && { : < /dev/tty; } 2>/dev/null; then
        read -rsn1 value < /dev/tty
        if [ "$allow_two_chars" = true ] && [[ "$value" =~ ^[[:alnum:]]$ ]]; then
            if read -rsn1 -t 0.25 next < /dev/tty 2>/dev/null && [[ "$next" =~ ^[[:alnum:]]$ ]]; then
                value="${value}${next}"
            fi
        fi
        while read -rsn1 -t 0.05 _ < /dev/tty 2>/dev/null; do :; done
    else
        read -r value
    fi

    value=$(normalize_menu_choice "$value")
    printf -v "$target_var" '%s' "$value"
}

save_and_activate_connection() {
    local target="$1"
    local identity_file="${2:-${SSH_IDENTITY_FILE:-}}"

    if ! validate_connection_target "$target"; then
        echo -e "${RED}✗ Cible invalide: $target${NC}"
        echo -e "${YELLOW}  Format attendu: user@ip, user@host, ou alias-ssh${NC}"
        return 1
    fi

    if ! validate_identity_file "$identity_file"; then
        echo -e "${RED}✗ Clé SSH invalide ou introuvable: $identity_file${NC}"
        echo -e "${YELLOW}  Laissez vide pour utiliser la configuration SSH normale.${NC}"
        return 1
    fi
    if [ -n "$identity_file" ]; then
        identity_file=$(normalize_identity_path "$identity_file")
        chmod 600 "$identity_file" 2>/dev/null || true
    fi

    echo ""
    echo -e "${BLUE}Test SSH vers $target...${NC}"
    local ssh_args=("-o" "ConnectTimeout=7" "-o" "BatchMode=yes")
    if [ -n "$identity_file" ]; then
        ssh_args+=("-i" "$identity_file" "-o" "IdentitiesOnly=yes")
    fi

    if ssh "${ssh_args[@]}" "$target" "echo ok" &>/dev/null; then
        echo -e "${GREEN}✓ Connexion réussie${NC}"
        REMOTE_HOST="$target"
        SSH_IDENTITY_FILE="$identity_file"
        save_current_connection
        save_identity_file "$identity_file"
        chmod 600 "$CURRENT_CONNECTION_FILE" 2>/dev/null || true
        add_saved_connection "$target"
        CACHED_SESSION_INFO=""
        CACHED_SESSION_TIME=0
        echo -e "${GREEN}✓ Serveur actif enregistré pour urls, tunnel et shipflow-mcp-login${NC}"
        return 0
    fi

    echo -e "${RED}✗ Connexion impossible vers $target${NC}"
    echo -e "${YELLOW}  Vérifiez l'IP, l'utilisateur SSH et la clé autorisée sur le serveur.${NC}"
    return 1
}

configure_new_server() {
    echo -e "${CYAN}══════════════════════════════════════════════════${NC}"
    echo -e "           ${YELLOW}Configurer un nouveau serveur${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}Connexion actuelle:${NC} ${GREEN}${REMOTE_HOST:-non configurée}${NC}"
    echo ""
    echo -e "${BLUE}ShipFlow va enregistrer l'adresse SSH du nouveau serveur.${NC}"
    echo -e "${BLUE}Tu peux entrer une IP, un domaine, un alias SSH, ou directement user@host.${NC}"
    echo -e "${YELLOW}Exemples:${NC} 203.0.113.10, mon-serveur.com, hetzner, ubuntu@203.0.113.10"
    echo ""
    echo -e "${YELLOW}Adresse IP ou host du nouveau serveur:${NC} \c"
    read -r server_host
    if [ -z "$server_host" ]; then
        echo -e "${RED}✗ Adresse vide${NC}"
        return 1
    fi

    local target=""
    if [[ "$server_host" == *"@"* ]]; then
        target="$server_host"
        echo -e "${BLUE}Utilisateur SSH détecté dans l'adresse: ${GREEN}${target%%@*}${NC}"
    else
        echo ""
        echo -e "${BLUE}L'utilisateur SSH est le compte Linux utilisé pour te connecter au serveur.${NC}"
        echo -e "${BLUE}Sur beaucoup de serveurs Ubuntu cloud, c'est ${GREEN}ubuntu${BLUE}. Selon l'hébergeur, ça peut aussi être ${GREEN}root${BLUE}, ${GREEN}debian${BLUE}, ${GREEN}ec2-user${BLUE}, etc.${NC}"
        echo -e "${YELLOW}Laisse vide pour utiliser la valeur par défaut : ${GREEN}ubuntu${YELLOW}.${NC}"
        echo -e "${YELLOW}Si le test échoue, réessaie avec l'utilisateur indiqué par ton hébergeur.${NC}"
        echo -e "${YELLOW}Utilisateur SSH:${NC} \c"
        read -r server_user
        server_user="${server_user:-ubuntu}"
        target="${server_user}@${server_host}"
    fi

    echo ""
    echo -e "${BLUE}La clé SSH est le fichier privé utilisé si ta connexion demande une clé spéciale.${NC}"
    echo -e "${BLUE}Exemple: ~/.ssh/id_ed25519${NC}"
    echo -e "${YELLOW}Laisse vide pour utiliser la valeur par défaut : connexion SSH normale.${NC}"
    echo -e "${YELLOW}Chemin de la clé SSH si tu l'as enregistrée dans un dossier particulier ou avec un nom spécifique:${NC} \c"
    read -r identity_file

    echo ""
    echo -e "${BLUE}Connexion qui va être testée:${NC} ${GREEN}$target${NC}"
    save_and_activate_connection "$target" "$identity_file"
}

# Menu to select/add connection
select_connection() {
    echo -e "${CYAN}══════════════════════════════════════════════════${NC}"
    echo -e "              ${YELLOW}Gestion des connexions${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}Connexion actuelle:${NC} ${GREEN}${REMOTE_HOST:-non configurée}${NC}"
    echo ""

    # Get saved connections
    local saved=$(get_saved_connections)
    local options=()
    local keys=()
    local i=1

    echo -e "${BLUE}Connexions enregistrées:${NC}"
    echo ""

    if [ -n "$saved" ]; then
        while IFS= read -r conn; do
            local key
            key=$(menu_letter_key $((i - 1)))
            if [ "$conn" = "$REMOTE_HOST" ]; then
                echo -e "  ${CYAN}$key)${NC} $conn ${GREEN}(actuel)${NC}"
            else
                echo -e "  ${CYAN}$key)${NC} $conn"
            fi
            options+=("$conn")
            keys+=("$key")
            ((i++))
        done <<< "$saved"
    else
        echo -e "  ${YELLOW}Aucune connexion enregistrée${NC}"
    fi

    echo ""
    echo -e "  ${CYAN}n)${NC} ➕ Nouvelle connexion"
    echo -e "  ${CYAN}x)${NC} ← Retour"
    echo ""
    echo -e "${YELLOW}Tape la lettre de ton choix ?${NC} \c"
    read_menu_choice choice true

    case "$choice" in
        x|q)
            return 0
            ;;
        n)
            echo ""
            echo -e "${BLUE}Format: user@host ou alias SSH${NC}"
            echo -e "${YELLOW}Exemple: ubuntu@203.0.113.10, root@192.168.1.10, myserver${NC}"
            echo ""
            echo -e "${YELLOW}Nouvelle connexion:${NC} \c"
            read -r new_conn

            if [ -n "$new_conn" ]; then
                save_and_activate_connection "$new_conn" || pause
            fi
            ;;
        *)
            local idx=-1
            for ((i=0; i<${#keys[@]}; i++)); do
                if [ "$choice" = "${keys[$i]}" ]; then
                    idx=$i
                    break
                fi
            done

            if [ "$idx" -ge 0 ]; then
                local selected="${options[$idx]}"
                save_and_activate_connection "$selected" || pause
            else
                echo -e "${RED}❌ Choix invalide${NC}"
                pause
            fi
            ;;
    esac
}

# Load connection at startup
load_current_connection

# Cached session info (to avoid repeated SSH calls)
CACHED_SESSION_INFO=""
CACHED_SESSION_TIME=0

# Function to retrieve server session info from canonical shipflow install paths
fetch_server_session_info() {
    if [ -z "$REMOTE_HOST" ]; then
        echo SESSION_NOT_CONFIGURED
        return 0
    fi

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

should_show_session_scan_loader() {
    [ -n "$REMOTE_HOST" ] || return 1
    [ "${SHIPFLOW_NO_ANIMATION:-}" != "1" ] || return 1
    [ "${TERM:-}" != "dumb" ] || return 1
    [ -w /dev/tty ] 2>/dev/null || return 1
}

render_session_scan_frame() {
    local frame="$1"
    local sweep_a sweep_b sweep_c sweep_d

    case $((frame % 4)) in
        0)
            sweep_a="          |          "
            sweep_b="          |          "
            sweep_c="----------o----------"
            sweep_d="          |          "
            ;;
        1)
            sweep_a="       /             "
            sweep_b="     /               "
            sweep_c="----o----------------"
            sweep_d="       \\             "
            ;;
        2)
            sweep_a="                     "
            sweep_b="                     "
            sweep_c="----------o----------"
            sweep_d="                     "
            ;;
        *)
            sweep_a="             \\       "
            sweep_b="               \\     "
            sweep_c="----------------o----"
            sweep_d="             /       "
            ;;
    esac

    printf "%b\n" "${CYAN}        .----------------------------.${NC}" > /dev/tty
    printf "%b\n" "${CYAN}        |${NC} ${BLUE}SONAR SSH${NC}  ${YELLOW}scan réseau${NC}       ${CYAN}|${NC}" > /dev/tty
    printf "%b\n" "${CYAN}        |${NC}      .-----------.       ${CYAN}|${NC}" > /dev/tty
    printf "%b\n" "${CYAN}        |${NC}    .( ${GREEN}${sweep_a}${NC} ).    ${CYAN}|${NC}" > /dev/tty
    printf "%b\n" "${CYAN}        |${NC}   (  ${GREEN}${sweep_b}${NC}  )   ${CYAN}|${NC}" > /dev/tty
    printf "%b\n" "${CYAN}        |${NC}   (  ${GREEN}${sweep_c}${NC}  )   ${CYAN}|${NC}" > /dev/tty
    printf "%b\n" "${CYAN}        |${NC}   (  ${GREEN}${sweep_d}${NC}  )   ${CYAN}|${NC}" > /dev/tty
    printf "%b\n" "${CYAN}        |${NC}      '-----------'       ${CYAN}|${NC}" > /dev/tty
    printf "%b\n" "${CYAN}        '----------------------------'${NC}" > /dev/tty
    printf "%b\n" "${BLUE}        Recherche de session sur ${GREEN}${REMOTE_HOST}${BLUE}...${NC}" > /dev/tty
}

clear_session_scan_loader() {
    local lines=10
    local i=0

    while [ "$i" -lt "$lines" ]; do
        printf "\033[2K\r\n" > /dev/tty
        i=$((i + 1))
    done
    printf "\033[%sA\r" "$lines" > /dev/tty
}

cleanup_session_scan_loader_state() {
    local fetch_pid="${1:-}"
    local tmp_file="${2:-}"

    [ -n "$fetch_pid" ] && kill "$fetch_pid" 2>/dev/null || true
    clear_session_scan_loader 2>/dev/null || true
    printf "\033[?25h" > /dev/tty 2>/dev/null || true
    [ -n "$tmp_file" ] && rm -f "$tmp_file"
}

fetch_server_session_info_with_loader() {
    local tmp_file=""
    local fetch_pid=""
    local frame=0
    local status=0

    tmp_file=$(mktemp "${TMPDIR:-/tmp}/shipflow-session.XXXXXX") || {
        fetch_server_session_info
        return
    }

    trap 'status=$?; cleanup_session_scan_loader_state "$fetch_pid" "$tmp_file"; exit "$status"' INT TERM

    fetch_server_session_info > "$tmp_file" &
    fetch_pid=$!

    printf "\033[?25l" > /dev/tty
    while kill -0 "$fetch_pid" 2>/dev/null; do
        printf "\033[s" > /dev/tty
        render_session_scan_frame "$frame"
        printf "\033[u" > /dev/tty
        frame=$((frame + 1))
        sleep 0.18
    done

    wait "$fetch_pid" || status=$?
    clear_session_scan_loader
    printf "\033[?25h" > /dev/tty
    trap - INT TERM

    cat "$tmp_file"
    rm -f "$tmp_file"
    return "$status"
}

# Function to retrieve server session info (with caching)
get_server_session_info() {
    local target_var="${1:-}"
    local current_time=$(date +%s)
    local cache_ttl=300  # Cache for 5 minutes

    # Return cached info if fresh
    if [ -n "$CACHED_SESSION_INFO" ] && [ $((current_time - CACHED_SESSION_TIME)) -lt $cache_ttl ]; then
        if [ -n "$target_var" ]; then
            printf -v "$target_var" '%s' "$CACHED_SESSION_INFO"
        else
            echo "$CACHED_SESSION_INFO"
        fi
        return 0
    fi

    # Retrieve session info from server
    if should_show_session_scan_loader; then
        CACHED_SESSION_INFO=$(fetch_server_session_info_with_loader)
    else
        CACHED_SESSION_INFO=$(fetch_server_session_info)
    fi

    CACHED_SESSION_TIME=$current_time
    if [ -n "$target_var" ]; then
        printf -v "$target_var" '%s' "$CACHED_SESSION_INFO"
    else
        echo "$CACHED_SESSION_INFO"
    fi
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

# Function to display server session banner
display_server_session_banner() {
    local session_info=""
    get_server_session_info session_info

    if echo "$session_info" | grep -q "SESSION_START"; then
        # Parse session info
        local session_user=$(echo "$session_info" | grep "^USER:" | cut -d: -f2)
        local session_host=$(echo "$session_info" | grep "^HOST:" | cut -d: -f2)
        local session_code=$(echo "$session_info" | grep "^CODE:" | cut -d: -f2)
        local hash_art=$(echo "$session_info" | sed -n '/---HASH_ART_START---/,/---HASH_ART_END---/p' | grep -v "^---")

        echo -e "             ${MAGENTA}Server Session Identity${NC}"
        echo -e "${CYAN}──────────────────────────────────────────────────${NC}"

        # Display hash art
        while IFS= read -r line; do
            echo -e "              ${BLUE}$line${NC}"
        done <<< "$hash_art"

        echo -e "${GREEN}$(center_session_banner_text "$session_user@$session_host")${NC}"
        echo -e "${YELLOW}$(center_session_banner_text "$session_code")${NC}"
        echo -e "${CYAN}──────────────────────────────────────────────────${NC}"
    elif echo "$session_info" | grep -q "SESSION_NOT_FOUND"; then
        echo -e "${YELLOW}⚠ Session identity unavailable (ShipFlow not found on server)${NC}"
    elif echo "$session_info" | grep -q "SESSION_NOT_CONFIGURED"; then
        echo -e "${YELLOW}⚠ Connexion distante non configurée${NC}"
    elif [ -z "$session_info" ]; then
        echo -e "${YELLOW}⚠ Could not connect to server${NC}"
    fi
}

# Fonction d'affichage avec couleurs
print_header() {
    echo -e "${CYAN}══════════════════════════════════════════════════${NC}"
    echo -e "                 ${YELLOW}ShipFlow - Local${NC}"
    echo -e "                ${BLUE}SSH Tunnel Manager${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════${NC}"

    # Display server session identity (includes user@host info)
    display_server_session_banner
}

# Fonction d'affichage du menu
show_menu() {
    echo -e "${GREEN}Choisissez une option :${NC}"
    if [ -z "$REMOTE_HOST" ]; then
        echo -e "${YELLOW}Connexion distante non configurée. Choisissez c pour ajouter le nouveau serveur.${NC}"
    fi
    echo ""
    echo -e "  ${CYAN}t)${NC} 🚇 Démarrer les tunnels SSH"
    echo -e "  ${CYAN}u)${NC} 📋 Afficher les URLs disponibles"
    echo -e "  ${CYAN}a)${NC} 🛑 Arrêter les tunnels"
    echo -e "  ${CYAN}s)${NC} 📊 Statut des tunnels"
    echo -e "  ${CYAN}r)${NC} 🔄 Redémarrer les tunnels"
    echo -e "  ${CYAN}c)${NC} 🌐 Configurer nouveau serveur"
    echo -e "  ${CYAN}m)${NC} 🔐 Login OAuth MCP (distant)"
    echo ""
    echo -e "  ${CYAN}l)${NC} 🔌 Choisir une connexion enregistrée"
    echo -e "  ${CYAN}x)${NC} ❌ Quitter"
    echo ""
}

run_mcp_login_menu() {
    local provider=""

    echo -e "${CYAN}══════════════════════════════════════════════════${NC}"
    echo -e "           ${YELLOW}Login OAuth MCP distant${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}Connexion actuelle:${NC} ${GREEN}$REMOTE_HOST${NC}"
    echo ""
    echo -e "  ${CYAN}v)${NC} vercel"
    echo -e "  ${CYAN}s)${NC} supabase"
    echo -e "  ${CYAN}a)${NC} all"
    echo -e "  ${CYAN}c)${NC} custom"
    echo -e "  ${CYAN}x)${NC} retour"
    echo ""
    echo -e "${YELLOW}Tape la lettre de ton choix ?${NC} \c"
    read_menu_choice login_choice

    case "$login_choice" in
        v) provider="vercel" ;;
        s) provider="supabase" ;;
        a) provider="all" ;;
        c)
            echo -e "${YELLOW}Nom du provider MCP:${NC} \c"
            read -r provider
            ;;
        x|q) return 0 ;;
        *)
            echo -e "${RED}❌ Choix invalide${NC}"
            return 1
            ;;
    esac

    if [ -z "$provider" ]; then
        echo -e "${RED}❌ Provider vide${NC}"
        return 1
    fi

    "$SCRIPT_DIR/mcp-login.sh" "$provider"
}

# Fonction pour obtenir les ports actifs
get_active_ports() {
    run_remote_ssh "$(shipflow_remote_pm2_ports_command lines)" 2>/dev/null
}

# Fonction pour récupérer uniquement les vrais processus de tunnel
get_tunnel_processes() {
    ps -eo pid=,args= | while IFS= read -r line; do
        case "$line" in
            *autossh*" $REMOTE_HOST"*"-L "*":localhost:"*|*ssh*" $REMOTE_HOST"*"-N "*"-L "*":localhost:"*)
                echo "$line"
                ;;
        esac
    done
}

# Fonction pour récupérer uniquement les PIDs des vrais tunnels
get_tunnel_pids() {
    get_tunnel_processes | awk '{print $1}'
}

# Fonction pour vérifier qu'un port local répond
is_local_tunnel_ready() {
    local port="$1"

    if command -v nc &> /dev/null && nc -z localhost "$port" 2>/dev/null; then
        return 0
    fi

    if command -v lsof &> /dev/null && lsof -i :"$port" &> /dev/null; then
        return 0
    fi

    curl -s --connect-timeout 1 "http://localhost:${port}" &> /dev/null
}

# Fonction pour attendre que les tunnels soient bien levés
verify_tunnels_ready() {
    local ports_data="$1"
    local max_attempts=5
    local attempt=1
    local pending="$ports_data"

    while [ $attempt -le $max_attempts ] && [ -n "$pending" ]; do
        local next_pending=""

        while IFS= read -r line; do
            [ -n "$line" ] || continue
            local port name
            port=$(echo "$line" | cut -d':' -f1)
            name=$(echo "$line" | cut -d':' -f2)

            if ! is_local_tunnel_ready "$port"; then
                next_pending="${next_pending}${line}"$'\n'
            fi
        done <<< "$pending"

        pending=$(printf "%s" "$next_pending" | sed '/^$/d')
        [ -z "$pending" ] && return 0

        sleep 1
        attempt=$((attempt + 1))
    done

    echo "$pending"
    return 1
}

# Fonction pour démarrer les tunnels
start_tunnels() {
    echo -e "${BLUE}🚇 Démarrage des tunnels SSH${NC}"
    echo ""

    if [ -z "$REMOTE_HOST" ]; then
        echo -e "${RED}✗ Aucune connexion distante configurée${NC}"
        echo -e "${YELLOW}  Choisissez l'option l pour ajouter votre nouveau serveur.${NC}"
        return 1
    fi
    
    # Vérifier autossh
    if ! command -v autossh &> /dev/null; then
        echo -e "${RED}✗ autossh n'est pas installé${NC}"
        echo -e "${YELLOW}  Installation: brew install autossh (macOS) ou apt install autossh (Linux)${NC}"
        return 1
    fi
    
    # Arrêter les tunnels existants
    echo -e "${YELLOW}🛑 Arrêt des tunnels existants...${NC}"
    pkill -f "autossh.*$REMOTE_HOST" 2>/dev/null || true
    sleep 1
    
    # Récupérer les ports
    echo -e "${BLUE}📡 Récupération des ports actifs depuis PM2...${NC}"
    PORTS=$(get_active_ports)
    
    if [ -z "$PORTS" ]; then
        echo -e "${RED}✗ Aucun port trouvé ou PM2 n'est pas accessible${NC}"
        echo -e "${YELLOW}  Vérifiez que PM2 tourne sur le serveur distant${NC}"
        return 1
    fi
    
    echo -e "${GREEN}✓ Création des tunnels SSH${NC}"
    echo ""
    
    # Créer les tunnels
    while IFS= read -r line; do
        port=$(echo "$line" | cut -d':' -f1)
        name=$(echo "$line" | cut -d':' -f2)
        
        echo -e "${GREEN}  ✓ localhost:${port} → ${name}${NC}"
        
        local autossh_args=(
            -M 0 -f -N
            -o "ServerAliveInterval=30"
            -o "ServerAliveCountMax=3"
            -o "ExitOnForwardFailure=yes"
            -L "${port}:localhost:${port}"
        )
        if [ -n "${SSH_IDENTITY_FILE:-}" ]; then
            autossh_args+=("-i" "$(normalize_identity_path "$SSH_IDENTITY_FILE")" "-o" "IdentitiesOnly=yes")
        fi
        autossh "${autossh_args[@]}" "$REMOTE_HOST" 2>/dev/null
    done <<< "$PORTS"
    
    echo ""
    echo -e "${YELLOW}⏳ Attente de l'établissement des tunnels...${NC}"
    FAILED_TUNNELS=$(verify_tunnels_ready "$PORTS")

    if [ -n "$FAILED_TUNNELS" ]; then
        echo -e "${YELLOW}⚠ Certains tunnels ne répondent pas encore :${NC}"
        while IFS= read -r line; do
            [ -n "$line" ] || continue
            port=$(echo "$line" | cut -d':' -f1)
            name=$(echo "$line" | cut -d':' -f2)
            echo -e "  ${RED}✗${NC} localhost:${port} ${YELLOW}(${name})${NC}"
        done <<< "$FAILED_TUNNELS"
        return 1
    fi

    echo -e "${GREEN}✅ Tunnels actifs !${NC}"
}

# Fonction pour afficher les URLs
show_urls() {
    echo -e "${BLUE}📋 URLs disponibles${NC}"
    echo ""
    
    PORTS=$(get_active_ports)
    
    if [ -z "$PORTS" ]; then
        echo -e "${RED}✗ Aucun port trouvé${NC}"
        return 1
    fi
    
    while IFS= read -r line; do
        port=$(echo "$line" | cut -d':' -f1)
        name=$(echo "$line" | cut -d':' -f2)
        
        # Vérifier si le port local est accessible (méthode la plus fiable)
        if command -v nc &> /dev/null && nc -z localhost "$port" 2>/dev/null; then
            echo -e "  ${GREEN}✓${NC} http://localhost:${port} ${YELLOW}(${name})${NC} ${GREEN}[actif]${NC}"
        elif command -v lsof &> /dev/null && lsof -i :${port} &> /dev/null; then
            echo -e "  ${GREEN}✓${NC} http://localhost:${port} ${YELLOW}(${name})${NC} ${GREEN}[actif]${NC}"
        elif curl -s --connect-timeout 1 http://localhost:${port} &> /dev/null; then
            echo -e "  ${GREEN}✓${NC} http://localhost:${port} ${YELLOW}(${name})${NC} ${GREEN}[actif]${NC}"
        else
            echo -e "  ${RED}✗${NC} http://localhost:${port} ${YELLOW}(${name})${NC} ${RED}[tunnel inactif]${NC}"
        fi
    done <<< "$PORTS"
}

# Fonction pour arrêter les tunnels
stop_tunnels() {
    echo -e "${BLUE}🛑 Arrêt des tunnels SSH${NC}"
    echo ""
    
    # Afficher les processus avant de les tuer
    echo -e "${YELLOW}🔍 Recherche des processus SSH...${NC}"
    
    PIDS=$(get_tunnel_pids)
    
    if [ -z "$PIDS" ]; then
        echo -e "${YELLOW}⚠ Aucun tunnel actif trouvé pour $REMOTE_HOST${NC}"
        echo ""
        echo -e "${BLUE}💡 Processus SSH en cours:${NC}"
        ps aux | grep ssh | grep -v grep | grep -v ssh-agent
    else
        echo -e "${GREEN}✓ Processus trouvés:${NC}"
        echo "$PIDS" | while read -r pid; do
            cmd=$(ps -p "$pid" -o command= 2>/dev/null)
            echo -e "  ${CYAN}PID $pid:${NC} $cmd"
        done
        
        echo ""
        echo -e "${YELLOW}🔫 Arrêt des processus...${NC}"
        
        # Tuer les processus
        echo "$PIDS" | while read -r pid; do
            if kill "$pid" 2>/dev/null; then
                echo -e "  ${GREEN}✓${NC} PID $pid arrêté"
            else
                echo -e "  ${RED}✗${NC} Impossible d'arrêter PID $pid"
            fi
        done
        
        # Attendre un peu
        sleep 1
        
        # Vérifier qu'ils sont bien arrêtés
        REMAINING=$(get_tunnel_pids)
        if [ -n "$REMAINING" ]; then
            echo ""
            echo -e "${YELLOW}⚠ Processus restants, utilisation de kill -9...${NC}"
            echo "$REMAINING" | xargs kill -9 2>/dev/null
        fi
        
        echo ""
        echo -e "${GREEN}✓ Tunnels arrêtés${NC}"
    fi
}

# Fonction pour afficher le statut
show_status() {
    echo -e "${BLUE}📊 Statut des tunnels${NC}"
    echo ""
    
    # Chercher les processus autossh OU ssh avec le remote host
    PROCESSES=$(get_tunnel_processes)
    
    if [ -z "$PROCESSES" ]; then
        echo -e "${YELLOW}⚠ Aucun tunnel actif${NC}"
        echo ""
        echo -e "${BLUE}💡 Vérification des ports en écoute:${NC}"
        if command -v lsof &> /dev/null; then
            lsof -iTCP -sTCP:LISTEN | grep "^ssh" | head -5 || echo "  Aucun port SSH trouvé"
        elif command -v netstat &> /dev/null; then
            netstat -an | grep LISTEN | grep "127.0.0.1:" | head -5 || echo "  Aucun port localhost trouvé"
        fi
    else
        echo -e "${GREEN}✓ Processus de tunnels actifs :${NC}"
        echo ""
        
        # Compter les processus
        COUNT=$(echo "$PROCESSES" | wc -l | tr -d ' ')
        echo -e "  ${GREEN}•${NC} $COUNT processus SSH/autossh vers $REMOTE_HOST"
        echo ""
        
        # Essayer d'extraire les ports
        echo -e "${BLUE}💡 Ports locaux en écoute (tunnels):${NC}"
        if command -v lsof &> /dev/null; then
            lsof -iTCP -sTCP:LISTEN -P | grep "^ssh" | awk '{print $9}' | grep -o "localhost:[0-9]*" | sort -u | while read -r addr; do
                port=$(echo "$addr" | cut -d: -f2)
                echo -e "  ${GREEN}•${NC} http://localhost:${port}"
            done
        else
            echo "$PROCESSES" | while read -r line; do
                port=$(echo "$line" | grep -oP '(?<=-L )\d+(?=:localhost)' | head -1)
                if [ -n "$port" ]; then
                    echo -e "  ${GREEN}•${NC} http://localhost:${port}"
                fi
            done
        fi
    fi
}

# Fonction de pause
pause() {
    local pause_key=""

    echo ""
    echo -e "${YELLOW}Appuyez sur une touche pour continuer...${NC}"
    read_menu_choice pause_key
}

# Fonction principale
main() {
    while true; do
        clear
        print_header
        show_menu

        echo -e "${YELLOW}Tape la lettre de ton choix ?${NC} \c"
        read_menu_choice CHOICE

        case $CHOICE in
            t)
                start_tunnels
                pause
                ;;
            u)
                show_urls
                pause
                ;;
            a)
                stop_tunnels
                pause
                ;;
            s)
                show_status
                pause
                ;;
            r)
                echo -e "${BLUE}🔄 Redémarrage des tunnels${NC}"
                echo ""
                stop_tunnels || true
                sleep 2
                if ! start_tunnels; then
                    echo ""
                    echo -e "${YELLOW}⚠ Redémarrage incomplet : vérifiez le statut des tunnels${NC}"
                fi
                pause
                ;;
            c)
                configure_new_server
                pause
                ;;
            m)
                run_mcp_login_menu
                pause
                ;;
            l)
                select_connection
                ;;
            x|q)
                echo -e "${GREEN}👋 Au revoir !${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}❌ Choix invalide${NC}"
                pause
                ;;
        esac
    done
}

# Lancer le menu
main
