#!/bin/bash

# Script d'installation ShipFlow — DOIT être lancé en root (sudo ./install.sh)
# Installe les paquets système puis configure TOUS les utilisateurs

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

SHIPFLOW_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHIPFLOW_LOG_DIR="${SHIPFLOW_LOG_DIR:-$HOME/install-logs}"
SHIPFLOW_LOG_FILE="${SHIPFLOW_LOG_FILE:-$SHIPFLOW_LOG_DIR/shipflow-$(date -u +%Y%m%dT%H%M%SZ).log}"
SHIPFLOW_REPORT_DIR="${SHIPFLOW_REPORT_DIR:-$HOME/install-reports}"
SHIPFLOW_REPORT_FILE="${SHIPFLOW_REPORT_FILE:-$SHIPFLOW_REPORT_DIR/shipflow-$(date -u +%Y%m%dT%H%M%SZ).md}"
mkdir -p "$SHIPFLOW_LOG_DIR"
mkdir -p "$SHIPFLOW_REPORT_DIR"
touch "$SHIPFLOW_LOG_FILE"

shipflow_log() {
    local level="$1"
    local message="$2"
    local clean_message
    clean_message=$(printf '%s' "$message" | sed -E 's/\x1B\[[0-9;]*[a-zA-Z]//g')
    printf '%s [%s] %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$level" "$clean_message" >> "$SHIPFLOW_LOG_FILE"
}

echo -e "${CYAN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}          ${YELLOW}ShipFlow Installation${NC}             ${CYAN}║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════╝${NC}"
echo ""
shipflow_log "INFO" "ShipFlow install started"

# Fonction helper
success() {
    echo -e "${GREEN}✅${NC} $1"
    shipflow_log "INFO" "OK: $1"
}

error() {
    echo -e "${RED}❌${NC} $1"
    shipflow_log "ERROR" "FAIL: $1"
}

info() {
    echo -e "${BLUE}ℹ️${NC} $1"
    shipflow_log "INFO" "INFO: $1"
}

warning() {
    echo -e "${YELLOW}⚠️${NC} $1"
    shipflow_log "WARN" "WARN: $1"
}

warn_data_restore_before_work() {
    local user_home=""
    local user_data_dir=""

    if [ -n "${INVOKING_USER:-}" ] && [ "$INVOKING_USER" != "root" ]; then
        user_home="$(getent passwd "$INVOKING_USER" 2>/dev/null | cut -d: -f6)"
    fi

    if [ -n "$user_home" ]; then
        user_data_dir="$user_home/shipflow_data"
    else
        user_data_dir="$HOME/shipflow_data"
    fi

    echo ""
    echo -e "${YELLOW}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║  IMPORTANT : restaure tes données ShipFlow avant usage   ║${NC}"
    echo -e "${YELLOW}╚══════════════════════════════════════════════════════════╝${NC}"
    echo -e "${YELLOW}ShipFlow écrit son suivi dans :${NC} ${CYAN}$user_data_dir${NC}"
    echo -e "${YELLOW}Si tu as déjà un dépôt GitHub ou une sauvegarde de shipflow_data,${NC}"
    echo -e "${YELLOW}clone/restaure ce dossier AVANT de commencer à travailler.${NC}"
    echo -e "${YELLOW}Sinon l'install créera des fichiers de départ vides et les skills${NC}"
    echo -e "${YELLOW}peuvent écrire dedans, ce qui rend le merge avec ton historique pénible.${NC}"
    echo ""
    echo -e "Exemple : ${CYAN}git clone git@github.com:<owner>/shipflow_data.git \"$user_data_dir\"${NC}"
    echo ""
    shipflow_log "WARN" "User warned to restore existing shipflow_data from GitHub/backup before starting work. Expected data dir: $user_data_dir"

    if [ -t 0 ] && [ "${CI:-}" != "true" ] && [ "${SHIPFLOW_SKIP_DATA_RESTORE_WARNING:-0}" != "1" ]; then
        echo -e "${YELLOW}Appuie sur Entrée pour continuer, ou Ctrl+C pour restaurer tes données maintenant.${NC}"
        read -r _
        echo ""
    fi
}

SHIPFLOW_PRE_STATUS_DIR_NODE=""
SHIPFLOW_PRE_STATUS_PM2=""
SHIPFLOW_PRE_STATUS_VERCEL=""
SHIPFLOW_PRE_STATUS_CONVEX=""
SHIPFLOW_PRE_STATUS_CLERK=""
SHIPFLOW_PRE_STATUS_SUPABASE=""
SHIPFLOW_PRE_STATUS_FLOX=""
SHIPFLOW_PRE_STATUS_GH=""
SHIPFLOW_PRE_STATUS_PYTHON3=""
SHIPFLOW_PRE_STATUS_PYYAML=""
SHIPFLOW_PRE_STATUS_CADDY=""
SHIPFLOW_PRE_STATUS_GIT=""
SHIPFLOW_PRE_STATUS_JQ=""
SHIPFLOW_PRE_STATUS_FUSER=""

shipflow_capture_status() {
    command -v node >/dev/null 2>&1 && SHIPFLOW_PRE_STATUS_DIR_NODE="present" || true
    command -v pm2 >/dev/null 2>&1 && SHIPFLOW_PRE_STATUS_PM2="present" || true
    command -v vercel >/dev/null 2>&1 && SHIPFLOW_PRE_STATUS_VERCEL="present" || true
    command -v convex >/dev/null 2>&1 && SHIPFLOW_PRE_STATUS_CONVEX="present" || true
    command -v clerk >/dev/null 2>&1 && SHIPFLOW_PRE_STATUS_CLERK="present" || true
    command -v supabase >/dev/null 2>&1 && SHIPFLOW_PRE_STATUS_SUPABASE="present" || true
    command -v flox >/dev/null 2>&1 && SHIPFLOW_PRE_STATUS_FLOX="present" || true
    command -v gh >/dev/null 2>&1 && SHIPFLOW_PRE_STATUS_GH="present" || true
    command -v python3 >/dev/null 2>&1 && SHIPFLOW_PRE_STATUS_PYTHON3="present" || true
    python3 -c 'import yaml' 2>/dev/null && SHIPFLOW_PRE_STATUS_PYYAML="present" || true
    command -v caddy >/dev/null 2>&1 && SHIPFLOW_PRE_STATUS_CADDY="present" || true
    command -v git >/dev/null 2>&1 && SHIPFLOW_PRE_STATUS_GIT="present" || true
    command -v jq >/dev/null 2>&1 && SHIPFLOW_PRE_STATUS_JQ="present" || true
    command -v fuser >/dev/null 2>&1 && SHIPFLOW_PRE_STATUS_FUSER="present" || true
}

shipflow_status() {
    local pre="$1"
    local post="$2"
    if [ "$pre" = "present" ] && [ "$post" = "present" ]; then
        echo "DÉJÀ_PRÉSENT"
    elif [ "$pre" != "present" ] && [ "$post" = "present" ]; then
        echo "INSTALLÉ"
    elif [ "$pre" = "present" ] && [ "$post" != "present" ]; then
        echo "ÉCHEC"
    else
        echo "ÉCHEC"
    fi
}

# Root check — système packages need root, no silent elevation
if [ "$EUID" -ne 0 ]; then
    shipflow_log "ERROR" "ShipFlow install stopped: non-root execution by $(id -un)."
    shipflow_log "ERROR" "Root-required scope not applied: Node.js system install, global PM2/Vercel/Convex/Clerk npm prefix /usr/local, Supabase /usr/local/bin, PM2 systemd startup, Flox .deb, apt packages, GitHub CLI apt/deb, PyYAML system install, Caddy apt repo/install, /etc/dokploy/compose, and all-user ShipFlow configuration."
    echo ""
    echo -e "${RED}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║                                                          ║${NC}"
    echo -e "${RED}║   ⛔  CE SCRIPT DOIT ÊTRE LANCÉ EN ROOT !  ⛔           ║${NC}"
    echo -e "${RED}║                                                          ║${NC}"
    echo -e "${RED}║   L'installation des paquets système (Node.js, PM2,      ║${NC}"
    echo -e "${RED}║   Flox, Caddy, etc.) nécessite les droits root.          ║${NC}"
    echo -e "${RED}║                                                          ║${NC}"
    echo -e "${RED}║   Non appliqué sans root : /usr/local, /etc/dokploy,     ║${NC}"
    echo -e "${RED}║   PM2 systemd, Caddy, Flox .deb et config tous users.    ║${NC}"
    echo -e "${RED}║                                                          ║${NC}"
    echo -e "${RED}║   Relancez avec :                                        ║${NC}"
    echo -e "${RED}║     ${YELLOW}sudo ./install.sh${RED}                                    ║${NC}"
    echo -e "${RED}║                                                          ║${NC}"
    echo -e "${RED}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    exit 1
fi

info "Mode root confirmé : installation système + configuration ShipFlow multi-utilisateur"
echo -e "${BLUE}ℹ️${NC} Scope root appliqué : /usr/local, /etc/dokploy, PM2 systemd, Caddy, Flox, outils globaux"
shipflow_log "INFO" "Privilege scope: root run. Applying system/global setup plus ShipFlow user configuration."

shipflow_capture_status

# Remember who invoked sudo so we configure their account too
INVOKING_USER="${SUDO_USER:-}"

warn_data_restore_before_work

echo -e "${BLUE}🔍 Vérification des dépendances...${NC}"
echo ""

# 1. Installer Node.js (pour PM2)
if command -v node >/dev/null 2>&1; then
    NODE_VERSION=$(node --version)
    success "Node.js déjà installé: $NODE_VERSION"
else
    info "Installation de Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
    apt-get install -y nodejs
    
    if command -v node >/dev/null 2>&1; then
        success "Node.js installé: $(node --version)"
    else
        error "Échec de l'installation de Node.js"
        exit 1
    fi
fi

echo ""

# 2. Installer PM2
if command -v pm2 >/dev/null 2>&1; then
    PM2_VERSION=$(pm2 --version)
    success "PM2 déjà installé: $PM2_VERSION"
else
    info "Installation de PM2..."
    npm config set prefix /usr/local
    npm install -g pm2
    hash -r 2>/dev/null

    if command -v pm2 >/dev/null 2>&1; then
        success "PM2 installé: $(pm2 --version)"
    else
        error "Échec de l'installation de PM2"
        exit 1
    fi
fi

echo ""

# 3. Installer les CLI Node globales utiles
npm config set prefix /usr/local

if command -v vercel >/dev/null 2>&1; then
    success "Vercel CLI déjà installé: $(vercel --version 2>/dev/null | head -n1)"
else
    info "Installation de Vercel CLI..."
    npm install -g vercel
    hash -r 2>/dev/null

    if command -v vercel >/dev/null 2>&1; then
        success "Vercel CLI installé: $(vercel --version 2>/dev/null | head -n1)"
    else
        error "Échec de l'installation de Vercel CLI"
        exit 1
    fi
fi

echo ""

if command -v convex >/dev/null 2>&1; then
    success "Convex CLI déjà installé: $(convex --version 2>/dev/null | head -n1)"
else
    info "Installation de Convex CLI..."
    npm install -g convex
    hash -r 2>/dev/null

    if command -v convex >/dev/null 2>&1; then
        success "Convex CLI installé: $(convex --version 2>/dev/null | head -n1)"
    else
        error "Échec de l'installation de Convex CLI"
        exit 1
    fi
fi

echo ""

if command -v clerk >/dev/null 2>&1; then
    success "Clerk CLI déjà installé: $(clerk --version 2>/dev/null | head -n1)"
else
    info "Installation de Clerk CLI..."
    npm install -g clerk
    hash -r 2>/dev/null

    if command -v clerk >/dev/null 2>&1; then
        success "Clerk CLI installé: $(clerk --version 2>/dev/null | head -n1)"
    else
        error "Échec de l'installation de Clerk CLI"
        exit 1
    fi
fi

echo ""

# Supabase CLI — standalone binary install, because npm global install is not supported officially.
if command -v supabase >/dev/null 2>&1; then
    success "Supabase CLI déjà installé: $(supabase --version 2>/dev/null | head -n1)"
else
    info "Installation de Supabase CLI..."
    ARCH=$(uname -m)
    case "$ARCH" in
        aarch64|arm64)
            SUPABASE_ARCH="arm64"
            ;;
        x86_64|amd64)
            SUPABASE_ARCH="amd64"
            ;;
        *)
            error "Architecture non supportée pour Supabase CLI: $ARCH"
            exit 1
            ;;
    esac

    SUPABASE_TMP_DIR=$(mktemp -d)
    SUPABASE_ARCHIVE="supabase_linux_${SUPABASE_ARCH}.tar.gz"
    curl -L -o "$SUPABASE_TMP_DIR/$SUPABASE_ARCHIVE" "https://github.com/supabase/cli/releases/latest/download/$SUPABASE_ARCHIVE"
    tar -xzf "$SUPABASE_TMP_DIR/$SUPABASE_ARCHIVE" -C "$SUPABASE_TMP_DIR"
    install -m 0755 "$SUPABASE_TMP_DIR/supabase" /usr/local/bin/supabase
    rm -rf "$SUPABASE_TMP_DIR"
    hash -r 2>/dev/null

    if command -v supabase >/dev/null 2>&1; then
        success "Supabase CLI installé: $(supabase --version 2>/dev/null | head -n1)"
    else
        error "Échec de l'installation de Supabase CLI"
        exit 1
    fi
fi

echo ""

# 4. Configurer PM2 pour démarrer au boot
info "Configuration de PM2 pour démarrage automatique..."
pm2 startup systemd -u root --hp /root >/dev/null 2>&1
success "PM2 configuré pour démarrer automatiquement"

echo ""

# 5. Installer Flox
if command -v flox >/dev/null 2>&1; then
    FLOX_VERSION=$(flox --version 2>&1 | head -n1)
    success "Flox déjà installé: $FLOX_VERSION"
else
    info "Installation de Flox..."
    ARCH=$(uname -m)
    FLOX_VERSION="1.8.1"
    
    # Télécharger et installer le package Flox selon l'architecture
    cd /tmp
    if [ "$ARCH" = "aarch64" ]; then
        FLOX_DEB="flox-${FLOX_VERSION}.aarch64-linux.deb"
    else
        FLOX_DEB="flox-${FLOX_VERSION}.x86_64-linux.deb"
    fi
    
    curl -L -o "$FLOX_DEB" "https://downloads.flox.dev/by-env/stable/deb/$FLOX_DEB"
    dpkg -i "$FLOX_DEB"
    rm -f "$FLOX_DEB"
    
    if command -v flox >/dev/null 2>&1; then
        success "Flox installé: $(flox --version)"
    else
        error "Échec de l'installation de Flox"
        warning "Installation manuelle requise: https://flox.dev/docs/install-flox/"
    fi
fi

echo ""

# 6. Installer les outils système nécessaires
info "Vérification des outils système..."

TOOLS_TO_CHECK=("git" "curl" "python3" "ss" "jq" "fuser")
MISSING_TOOLS=()

for tool in "${TOOLS_TO_CHECK[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        success "$tool installé"
    else
        MISSING_TOOLS+=("$tool")
    fi
done

if [ ${#MISSING_TOOLS[@]} -gt 0 ]; then
    info "Installation des outils manquants: ${MISSING_TOOLS[*]}"
    apt-get update >/dev/null 2>&1
    for tool in "${MISSING_TOOLS[@]}"; do
        case $tool in
            "ss")
                apt-get install -y iproute2
                ;;
            "jq")
                apt-get install -y jq
                ;;
            "fuser")
                apt-get install -y psmisc
                ;;
            *)
                apt-get install -y "$tool"
                ;;
        esac
    done
    success "Outils système installés"
fi

echo ""

# 7. Vérifier/Installer GitHub CLI
if command -v gh >/dev/null 2>&1; then
    GH_VERSION=$(gh --version | head -n1)
    success "GitHub CLI déjà installé: $GH_VERSION"
else
    info "Installation de GitHub CLI..."
    # Try apt repo first, fallback to direct .deb download
    gh_installed=false
    if type -p curl >/dev/null; then
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg 2>/dev/null
        chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg 2>/dev/null
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        apt-get update -qq 2>/dev/null && apt-get install -y gh 2>/dev/null && gh_installed=true
    fi
    # Fallback: direct .deb download (handles GPG key issues)
    if [ "$gh_installed" != "true" ]; then
        info "Fallback: telechargement direct du .deb..."
        gh_arch="amd64"
        [ "$(uname -m)" = "aarch64" ] && gh_arch="arm64"
        gh_version=""
        gh_version=$(curl -s https://api.github.com/repos/cli/cli/releases/latest | jq -r '.tag_name' 2>/dev/null || echo "v2.67.0")
        curl -fsSL "https://github.com/cli/cli/releases/download/${gh_version}/gh_${gh_version#v}_linux_${gh_arch}.deb" -o /tmp/gh.deb 2>/dev/null
        dpkg -i /tmp/gh.deb 2>/dev/null || true
        rm -f /tmp/gh.deb
    fi
    
    if command -v gh >/dev/null 2>&1; then
        success "GitHub CLI installé: $(gh --version | head -n1)"
    else
        error "Échec de l'installation de GitHub CLI"
    fi
fi

echo ""

# 8. Installer PyYAML pour la gestion des fichiers compose
info "Installation de PyYAML..."
if python3 -c "import yaml" 2>/dev/null; then
    success "PyYAML déjà installé"
else
    apt-get install -y python3-pip >/dev/null 2>&1
    pip3 install pyyaml >/dev/null 2>&1
    success "PyYAML installé"
fi

echo ""

# 9. Installer Caddy (pour publication web)
if command -v caddy >/dev/null 2>&1; then
    CADDY_VERSION=$(caddy version | head -n1)
    success "Caddy déjà installé: $CADDY_VERSION"
else
    info "Installation de Caddy..."
    apt-get install -y debian-keyring debian-archive-keyring apt-transport-https curl >/dev/null 2>&1
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list > /dev/null
    apt-get update >/dev/null 2>&1
    apt-get install -y caddy >/dev/null 2>&1
    
    if command -v caddy >/dev/null 2>&1; then
        success "Caddy installé: $(caddy version | head -n1)"
    else
        error "Échec de l'installation de Caddy"
        warning "Installation manuelle requise: https://caddyserver.com/docs/install"
    fi
fi

echo ""

# 10. Créer le répertoire de configuration
DOKPLOY_DIR="/etc/dokploy/compose"
if [ ! -d "$DOKPLOY_DIR" ]; then
    info "Création du répertoire de configuration..."
    mkdir -p "$DOKPLOY_DIR"
    success "Répertoire créé: $DOKPLOY_DIR"
else
    success "Répertoire de configuration existe: $DOKPLOY_DIR"
fi

# ──────────────────────────────────────────────────────────────
# Per-user setup: Claude Code, skills, aliases, data
# Runs for root + ALL regular users in /home/
# ──────────────────────────────────────────────────────────────

SHIPFLOW_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

# StatusLine — pointer vers le script ShipFlow
configure_statusline() {
    local target_home="$1"
    local settings_file="$target_home/.claude/settings.json"
    mkdir -p "$target_home/.claude"
    if [ ! -f "$settings_file" ]; then
        echo '{}' > "$settings_file"
    fi
    if command -v jq >/dev/null 2>&1; then
        jq --arg cmd "bash $SHIPFLOW_DIR/.claude/statusline-starship.sh" \
            '.statusLine = {"type": "command", "command": $cmd}' \
            "$settings_file" > "${settings_file}.tmp" \
            && mv "${settings_file}.tmp" "$settings_file"
    fi
}

# Context7 MCP — official current library docs, installed globally for Claude Code.
configure_context7_mcp() {
    local target_home="$1"
    local settings_file="$target_home/.claude/settings.json"
    mkdir -p "$target_home/.claude"
    if [ ! -f "$settings_file" ]; then
        echo '{}' > "$settings_file"
    fi
    if command -v jq >/dev/null 2>&1; then
        jq '
            .mcpServers.context7 = {
                "command": "npx",
                "args": ["-y", "@upstash/context7-mcp@latest"]
            }
        ' "$settings_file" > "${settings_file}.tmp" \
            && mv "${settings_file}.tmp" "$settings_file"
    fi
}

# Vercel MCP — remote MCP for Vercel deployments, logs, and toolbar.
configure_vercel_mcp() {
    local target_home="$1"
    local settings_file="$target_home/.claude/settings.json"
    mkdir -p "$target_home/.claude"
    if [ ! -f "$settings_file" ]; then
        echo '{}' > "$settings_file"
    fi
    if command -v jq >/dev/null 2>&1; then
        jq '
            .mcpServers.vercel = {
                "url": "https://mcp.vercel.com"
            }
        ' "$settings_file" > "${settings_file}.tmp" \
            && mv "${settings_file}.tmp" "$settings_file"
    fi
}

# Convex MCP — stdio MCP for Convex projects and deployments.
configure_convex_mcp() {
    local target_home="$1"
    local settings_file="$target_home/.claude/settings.json"
    mkdir -p "$target_home/.claude"
    if [ ! -f "$settings_file" ]; then
        echo '{}' > "$settings_file"
    fi
    if command -v jq >/dev/null 2>&1; then
        jq '
            .mcpServers.convex = {
                "command": "npx",
                "args": ["-y", "convex@latest", "mcp", "start"]
            }
        ' "$settings_file" > "${settings_file}.tmp" \
            && mv "${settings_file}.tmp" "$settings_file"
    fi
}

# Clerk MCP — remote MCP for Clerk SDK patterns and implementation guides.
configure_clerk_mcp() {
    local target_home="$1"
    local settings_file="$target_home/.claude/settings.json"
    mkdir -p "$target_home/.claude"
    if [ ! -f "$settings_file" ]; then
        echo '{}' > "$settings_file"
    fi
    if command -v jq >/dev/null 2>&1; then
        jq '
            .mcpServers.clerk = {
                "url": "https://mcp.clerk.com/mcp"
            }
        ' "$settings_file" > "${settings_file}.tmp" \
            && mv "${settings_file}.tmp" "$settings_file"
    fi
}

# Supabase MCP — remote MCP for project state, SQL, logs, and schema-aware assistance.
configure_supabase_mcp() {
    local target_home="$1"
    local settings_file="$target_home/.claude/settings.json"
    mkdir -p "$target_home/.claude"
    if [ ! -f "$settings_file" ]; then
        echo '{}' > "$settings_file"
    fi
    if command -v jq >/dev/null 2>&1; then
        jq '
            .mcpServers.supabase = {
                "url": "https://mcp.supabase.com/mcp"
            }
        ' "$settings_file" > "${settings_file}.tmp" \
            && mv "${settings_file}.tmp" "$settings_file"
    fi
}

# DataForSEO MCP — stdio MCP for SEO data APIs. Enabled only when credentials
# are available in the install environment.
configure_dataforseo_mcp() {
    local target_home="$1"
    local settings_file="$target_home/.claude/settings.json"
    local doppler_project="${SHIPFLOW_DATAFORSEO_DOPPLER_PROJECT:-contentflow_app}"
    local doppler_config="${SHIPFLOW_DATAFORSEO_DOPPLER_CONFIG:-prd}"
    local enabled="${SHIPFLOW_ENABLE_DATAFORSEO_MCP:-0}"
    local enabled_for_jq="false"
    mkdir -p "$target_home/.claude"
    if [ ! -f "$settings_file" ]; then
        echo '{}' > "$settings_file"
    fi
    if command -v jq >/dev/null 2>&1; then
        if command -v doppler >/dev/null 2>&1; then
            [ "$enabled" = "1" ] && enabled_for_jq="true"

            jq --arg project "$doppler_project" --arg config "$doppler_config" --argjson enabled "$enabled_for_jq" '
                .mcpServers.dataforseo = {
                    "command": "doppler",
                    "args": [
                        "run",
                        "--project", $project,
                        "--config", $config,
                        "--",
                        "bash",
                        "-lc",
                        "export DATAFORSEO_USERNAME=\"${DATAFORSEO_USERNAME:-${DATAFORSEO_LOGIN:-}}\"; exec npx -y dataforseo-mcp-server"
                    ]
                }
                | .disabledMcpServers = if $enabled then
                    ((.disabledMcpServers // []) - ["dataforseo"])
                  else
                    ((.disabledMcpServers // []) + ["dataforseo"] | unique)
                  end
            ' "$settings_file" > "${settings_file}.tmp" \
                && mv "${settings_file}.tmp" "$settings_file"
        else
            jq '
            .mcpServers.dataforseo = {
                "command": "npx",
                "args": ["-y", "dataforseo-mcp-server"]
            }
            ' "$settings_file" > "${settings_file}.tmp" \
                && mv "${settings_file}.tmp" "$settings_file"

            if [ "$enabled" != "1" ] || [ -z "${DATAFORSEO_USERNAME:-${DATAFORSEO_LOGIN:-}}" ] || [ -z "${DATAFORSEO_PASSWORD:-}" ]; then
                jq '
                    .disabledMcpServers = ((.disabledMcpServers // []) + ["dataforseo"] | unique)
                ' "$settings_file" > "${settings_file}.tmp" \
                    && mv "${settings_file}.tmp" "$settings_file"
            else
                jq '
                    .disabledMcpServers = ((.disabledMcpServers // []) - ["dataforseo"])
                ' "$settings_file" > "${settings_file}.tmp" \
                    && mv "${settings_file}.tmp" "$settings_file"
            fi
        fi
    fi
}

playwright_mcp_args_json() {
    local target_home="$1"
    local arch
    local chromium_path=""

    arch="$(uname -m)"
    if [ "$arch" = "aarch64" ] || [ "$arch" = "arm64" ]; then
        chromium_path=$(find "$target_home/.cache/ms-playwright" \
            -path '*/chrome-linux/chrome' \
            -type f -perm -111 2>/dev/null | sort -Vr | head -n 1 || true)
    fi

    if [ -n "$chromium_path" ]; then
        printf '["-y","@playwright/mcp@latest","--executable-path","%s","--headless","--no-sandbox"]' "$chromium_path"
    else
        printf '["-y","@playwright/mcp@latest"]'
    fi
}

# Playwright MCP — uses the local Playwright Chromium on ARM where Chrome stable
# is not available as /opt/google/chrome/chrome.
configure_playwright_mcp() {
    local target_home="$1"
    local settings_file="$target_home/.claude/settings.json"
    local args_json

    mkdir -p "$target_home/.claude"
    if [ ! -f "$settings_file" ]; then
        echo '{}' > "$settings_file"
    fi
    if command -v jq >/dev/null 2>&1; then
        args_json="$(playwright_mcp_args_json "$target_home")"
        jq --argjson args "$args_json" '
            .mcpServers.playwright = {
                "command": "npx",
                "args": $args
            }
        ' "$settings_file" > "${settings_file}.tmp" \
            && mv "${settings_file}.tmp" "$settings_file"
    fi
}

# Codex TUI defaults — idempotent and non-destructive
configure_codex_tui() {
    local target_home="$1"
    local codex_dir="$target_home/.codex"
    local config_file="$codex_dir/config.toml"
    local tmp_file="$config_file.tmp.$$"
    local cleaned_file="$config_file.cleaned.$$"

    mkdir -p "$codex_dir"
    [ -f "$config_file" ] || touch "$config_file"

    awk '
        BEGIN {
            in_shipflow_block = 0
        }
        /^# >>> shipflow codex tui >>>$/ {
            in_shipflow_block = 1
            next
        }
        /^# <<< shipflow codex tui <<<$/ {
            in_shipflow_block = 0
            next
        }
        in_shipflow_block {
            next
        }
        {
            print
        }
    ' "$config_file" > "$cleaned_file"

    local has_status_line
    local has_terminal_title
    local has_tui_table

    has_status_line=$(awk '
        BEGIN {
            in_tui_table = 0
            found = 0
        }
        /^[[:space:]]*tui[[:space:]]*\.[[:space:]]*status_line[[:space:]]*=/ {
            found = 1
        }
        /^\[[[:space:]]*tui[[:space:]]*\][[:space:]]*$/ {
            in_tui_table = 1
            next
        }
        /^\[[^]]+\][[:space:]]*$/ {
            in_tui_table = 0
            next
        }
        in_tui_table && /^[[:space:]]*status_line[[:space:]]*=/ {
            found = 1
        }
        END {
            print found
        }
    ' "$cleaned_file")

    has_terminal_title=$(awk '
        BEGIN {
            in_tui_table = 0
            found = 0
        }
        /^[[:space:]]*tui[[:space:]]*\.[[:space:]]*terminal_title[[:space:]]*=/ {
            found = 1
        }
        /^\[[[:space:]]*tui[[:space:]]*\][[:space:]]*$/ {
            in_tui_table = 1
            next
        }
        /^\[[^]]+\][[:space:]]*$/ {
            in_tui_table = 0
            next
        }
        in_tui_table && /^[[:space:]]*terminal_title[[:space:]]*=/ {
            found = 1
        }
        END {
            print found
        }
    ' "$cleaned_file")

    has_tui_table=$(awk '
        BEGIN {
            found = 0
        }
        /^\[[[:space:]]*tui[[:space:]]*\][[:space:]]*$/ {
            found = 1
        }
        END {
            print found
        }
    ' "$cleaned_file")

    if [ "$has_status_line" -eq 0 ] || [ "$has_terminal_title" -eq 0 ]; then
        if [ "$has_tui_table" -eq 1 ]; then
            awk \
                -v add_status="$has_status_line" \
                -v add_title="$has_terminal_title" '
                BEGIN {
                    in_tui = 0
                    inserted = 0
                }
                /^\[[[:space:]]*tui[[:space:]]*\][[:space:]]*$/ {
                    in_tui = 1
                    print
                    next
                }
                in_tui && /^\[[^]]+\][[:space:]]*$/ {
                    if (inserted == 0) {
                        print "# >>> shipflow codex tui >>>"
                        if (add_status == 0) {
                            print "status_line = [\"model-with-reasoning\", \"current-dir\", \"context-used\"]"
                        }
                        if (add_title == 0) {
                            print "terminal_title = [\"spinner\", \"thread\", \"project\"]"
                        }
                        print "# <<< shipflow codex tui <<<"
                        inserted = 1
                    }
                    in_tui = 0
                    print
                    next
                }
                {
                    print
                }
                END {
                    if (in_tui == 1 && inserted == 0) {
                        print "# >>> shipflow codex tui >>>"
                        if (add_status == 0) {
                            print "status_line = [\"model-with-reasoning\", \"current-dir\", \"context-used\"]"
                        }
                        if (add_title == 0) {
                            print "terminal_title = [\"spinner\", \"thread\", \"project\"]"
                        }
                        print "# <<< shipflow codex tui <<<"
                    }
                }
            ' "$cleaned_file" > "$tmp_file"
        else
            {
                printf '# >>> shipflow codex tui >>>\n'
                if [ "$has_status_line" -eq 0 ]; then
                    printf 'tui.status_line = ["model-with-reasoning", "current-dir", "context-used"]\n'
                fi
                if [ "$has_terminal_title" -eq 0 ]; then
                    printf 'tui.terminal_title = ["spinner", "thread", "project"]\n'
                fi
                printf '# <<< shipflow codex tui <<<\n'
                printf '\n'
                cat "$cleaned_file"
            } > "$tmp_file"
        fi
    else
        cat "$cleaned_file" > "$tmp_file"
    fi

    mv "$tmp_file" "$config_file"
    rm -f "$cleaned_file"
}

configure_codex_rmcp() {
    local target_home="$1"
    local codex_dir="$target_home/.codex"
    local config_file="$codex_dir/config.toml"
    local tmp_file="$config_file.tmp.$$"
    local cleaned_file="$config_file.cleaned-rmcp.$$"

    mkdir -p "$codex_dir"
    [ -f "$config_file" ] || touch "$config_file"

    awk '
        BEGIN {
            in_shipflow_block = 0
        }
        /^# >>> shipflow codex rmcp >>>$/ {
            in_shipflow_block = 1
            next
        }
        /^# <<< shipflow codex rmcp <<<$/ {
            in_shipflow_block = 0
            next
        }
        in_shipflow_block {
            next
        }
        {
            print
        }
    ' "$config_file" > "$cleaned_file"

    local has_beta_table
    local has_rmcp

    has_beta_table=$(awk '
        BEGIN { found = 0 }
        /^\[[[:space:]]*beta[[:space:]]*\][[:space:]]*$/ { found = 1 }
        END { print found }
    ' "$cleaned_file")

    has_rmcp=$(awk '
        BEGIN {
            in_beta = 0
            found = 0
        }
        /^[[:space:]]*beta[[:space:]]*\.[[:space:]]*rmcp[[:space:]]*=/ {
            found = 1
        }
        /^\[[[:space:]]*beta[[:space:]]*\][[:space:]]*$/ {
            in_beta = 1
            next
        }
        /^\[[^]]+\][[:space:]]*$/ {
            in_beta = 0
            next
        }
        in_beta && /^[[:space:]]*rmcp[[:space:]]*=/ {
            found = 1
        }
        END { print found }
    ' "$cleaned_file")

    if [ "$has_rmcp" -eq 1 ]; then
        cat "$cleaned_file" > "$tmp_file"
    elif [ "$has_beta_table" -eq 1 ]; then
        awk '
            BEGIN {
                in_beta = 0
                inserted = 0
            }
            /^\[[[:space:]]*beta[[:space:]]*\][[:space:]]*$/ {
                in_beta = 1
                print
                next
            }
            in_beta && /^\[[^]]+\][[:space:]]*$/ {
                if (inserted == 0) {
                    print "# >>> shipflow codex rmcp >>>"
                    print "rmcp = true"
                    print "# <<< shipflow codex rmcp <<<"
                    inserted = 1
                }
                in_beta = 0
                print
                next
            }
            {
                print
            }
            END {
                if (in_beta == 1 && inserted == 0) {
                    print "# >>> shipflow codex rmcp >>>"
                    print "rmcp = true"
                    print "# <<< shipflow codex rmcp <<<"
                }
            }
        ' "$cleaned_file" > "$tmp_file"
    else
        {
            printf '# >>> shipflow codex rmcp >>>\n'
            printf '[beta]\n'
            printf 'rmcp = true\n'
            printf '# <<< shipflow codex rmcp <<<\n'
            printf '\n'
            cat "$cleaned_file"
        } > "$tmp_file"
    fi

    mv "$tmp_file" "$config_file"
    rm -f "$cleaned_file"
}

# Context7 MCP for Codex — stdio transport, enabled by default.
configure_codex_context7_mcp() {
    local target_home="$1"
    local codex_dir="$target_home/.codex"
    local config_file="$codex_dir/config.toml"
    local tmp_file="$config_file.tmp.$$"

    mkdir -p "$codex_dir"
    [ -f "$config_file" ] || touch "$config_file"

    awk '
        /^# >>> shipflow codex context7 mcp >>>$/ { skip = 1; next }
        /^# <<< shipflow codex context7 mcp <<</ { skip = 0; next }
        /^\[mcp_servers\.context7\]$/ { skip = 1; next }
        /^\[/ && $0 !~ /^\[mcp_servers\.context7\]$/ && skip == 1 { skip = 0 }
        !skip { print }
    ' "$config_file" > "$tmp_file"

    {
        printf '\n'
        printf '# >>> shipflow codex context7 mcp >>>\n'
        printf '[mcp_servers.context7]\n'
        printf 'command = "npx"\n'
        printf 'args = ["-y", "@upstash/context7-mcp@latest"]\n'
        printf 'enabled = true\n'
        printf '# <<< shipflow codex context7 mcp <<<\n'
    } >> "$tmp_file"

    mv "$tmp_file" "$config_file"
}

# Vercel MCP for Codex — remote HTTP transport, enabled by default.
configure_codex_vercel_mcp() {
    local target_home="$1"
    local codex_dir="$target_home/.codex"
    local config_file="$codex_dir/config.toml"
    local tmp_file="$config_file.tmp.$$"

    mkdir -p "$codex_dir"
    [ -f "$config_file" ] || touch "$config_file"

    awk '
        /^# >>> shipflow codex vercel mcp >>>$/ { skip = 1; next }
        /^# <<< shipflow codex vercel mcp <<</ { skip = 0; next }
        /^\[mcp_servers\.vercel\]$/ { skip = 1; next }
        /^\[/ && $0 !~ /^\[mcp_servers\.vercel\]$/ && skip == 1 { skip = 0 }
        !skip { print }
    ' "$config_file" > "$tmp_file"

    {
        printf '\n'
        printf '# >>> shipflow codex vercel mcp >>>\n'
        printf '[mcp_servers.vercel]\n'
        printf 'url = "https://mcp.vercel.com"\n'
        printf 'enabled = true\n'
        printf '# <<< shipflow codex vercel mcp <<<\n'
    } >> "$tmp_file"

    mv "$tmp_file" "$config_file"
}

# Convex MCP for Codex — stdio transport, enabled by default.
configure_codex_convex_mcp() {
    local target_home="$1"
    local codex_dir="$target_home/.codex"
    local config_file="$codex_dir/config.toml"
    local tmp_file="$config_file.tmp.$$"

    mkdir -p "$codex_dir"
    [ -f "$config_file" ] || touch "$config_file"

    awk '
        /^# >>> shipflow codex convex mcp >>>$/ { skip = 1; next }
        /^# <<< shipflow codex convex mcp <<</ { skip = 0; next }
        /^\[mcp_servers\.convex\]$/ { skip = 1; next }
        /^\[/ && $0 !~ /^\[mcp_servers\.convex\]$/ && skip == 1 { skip = 0 }
        !skip { print }
    ' "$config_file" > "$tmp_file"

    {
        printf '\n'
        printf '# >>> shipflow codex convex mcp >>>\n'
        printf '[mcp_servers.convex]\n'
        printf 'command = "npx"\n'
        printf 'args = ["-y", "convex@latest", "mcp", "start"]\n'
        printf 'enabled = true\n'
        printf '# <<< shipflow codex convex mcp <<<\n'
    } >> "$tmp_file"

    mv "$tmp_file" "$config_file"
}

# Clerk MCP for Codex — remote HTTP transport, enabled by default.
configure_codex_clerk_mcp() {
    local target_home="$1"
    local codex_dir="$target_home/.codex"
    local config_file="$codex_dir/config.toml"
    local tmp_file="$config_file.tmp.$$"

    mkdir -p "$codex_dir"
    [ -f "$config_file" ] || touch "$config_file"

    awk '
        /^# >>> shipflow codex clerk mcp >>>$/ { skip = 1; next }
        /^# <<< shipflow codex clerk mcp <<</ { skip = 0; next }
        /^\[mcp_servers\.clerk\]$/ { skip = 1; next }
        /^\[/ && $0 !~ /^\[mcp_servers\.clerk\]$/ && skip == 1 { skip = 0 }
        !skip { print }
    ' "$config_file" > "$tmp_file"

    {
        printf '\n'
        printf '# >>> shipflow codex clerk mcp >>>\n'
        printf '[mcp_servers.clerk]\n'
        printf 'url = "https://mcp.clerk.com/mcp"\n'
        printf 'enabled = true\n'
        printf '# <<< shipflow codex clerk mcp <<<\n'
    } >> "$tmp_file"

    mv "$tmp_file" "$config_file"
}

# Supabase MCP for Codex — remote HTTP transport, enabled by default.
configure_codex_supabase_mcp() {
    local target_home="$1"
    local codex_dir="$target_home/.codex"
    local config_file="$codex_dir/config.toml"
    local tmp_file="$config_file.tmp.$$"

    mkdir -p "$codex_dir"
    [ -f "$config_file" ] || touch "$config_file"

    awk '
        /^# >>> shipflow codex supabase mcp >>>$/ { skip = 1; next }
        /^# <<< shipflow codex supabase mcp <<</ { skip = 0; next }
        /^\[mcp_servers\.supabase\]$/ { skip = 1; next }
        /^\[/ && $0 !~ /^\[mcp_servers\.supabase\]$/ && skip == 1 { skip = 0 }
        !skip { print }
    ' "$config_file" > "$tmp_file"

    {
        printf '\n'
        printf '# >>> shipflow codex supabase mcp >>>\n'
        printf '[mcp_servers.supabase]\n'
        printf 'url = "https://mcp.supabase.com/mcp"\n'
        printf 'enabled = true\n'
        printf '# <<< shipflow codex supabase mcp <<<\n'
    } >> "$tmp_file"

    mv "$tmp_file" "$config_file"
}

# DataForSEO MCP for Codex — stdio transport. Kept disabled unless credentials
# are exported when ShipFlow runs the installer.
configure_codex_dataforseo_mcp() {
    local target_home="$1"
    local codex_dir="$target_home/.codex"
    local config_file="$codex_dir/config.toml"
    local tmp_file="$config_file.tmp.$$"
    local enabled="false"
    local enable_dataforseo="${SHIPFLOW_ENABLE_DATAFORSEO_MCP:-0}"
    local command="npx"
    local args='["-y", "dataforseo-mcp-server"]'
    local doppler_project="${SHIPFLOW_DATAFORSEO_DOPPLER_PROJECT:-contentflow_app}"
    local doppler_config="${SHIPFLOW_DATAFORSEO_DOPPLER_CONFIG:-prd}"

    mkdir -p "$codex_dir"
    [ -f "$config_file" ] || touch "$config_file"

    if command -v doppler >/dev/null 2>&1; then
        [ "$enable_dataforseo" = "1" ] && enabled="true"
        command="doppler"
        args="[\"run\", \"--project\", \"$doppler_project\", \"--config\", \"$doppler_config\", \"--\", \"bash\", \"-lc\", \"export DATAFORSEO_USERNAME=\\\"\${DATAFORSEO_USERNAME:-\${DATAFORSEO_LOGIN:-}}\\\"; exec npx -y dataforseo-mcp-server\"]"
    elif [ "$enable_dataforseo" = "1" ] && [ -n "${DATAFORSEO_USERNAME:-${DATAFORSEO_LOGIN:-}}" ] && [ -n "${DATAFORSEO_PASSWORD:-}" ]; then
        enabled="true"
    fi

    awk '
        /^# >>> shipflow codex dataforseo mcp >>>$/ { skip = 1; next }
        /^# <<< shipflow codex dataforseo mcp <<</ { skip = 0; next }
        /^\[mcp_servers\.dataforseo\]$/ { skip = 1; next }
        /^\[/ && $0 !~ /^\[mcp_servers\.dataforseo\]$/ && skip == 1 { skip = 0 }
        !skip { print }
    ' "$config_file" > "$tmp_file"

    {
        printf '\n'
        printf '# >>> shipflow codex dataforseo mcp >>>\n'
        printf '[mcp_servers.dataforseo]\n'
        printf 'command = "%s"\n' "$command"
        printf 'args = %s\n' "$args"
        printf 'enabled = %s\n' "$enabled"
        printf '# <<< shipflow codex dataforseo mcp <<<\n'
    } >> "$tmp_file"

    mv "$tmp_file" "$config_file"
}

# Playwright MCP for Codex — stdio transport, enabled by default.
configure_codex_playwright_mcp() {
    local target_home="$1"
    local codex_dir="$target_home/.codex"
    local config_file="$codex_dir/config.toml"
    local tmp_file="$config_file.tmp.$$"
    local args_json

    mkdir -p "$codex_dir"
    [ -f "$config_file" ] || touch "$config_file"

    awk '
        /^# >>> shipflow codex playwright mcp >>>$/ { skip = 1; next }
        /^# <<< shipflow codex playwright mcp <<</ { skip = 0; next }
        /^\[mcp_servers\.playwright(\.|\])?/ { skip = 1; next }
        /^\[/ && $0 !~ /^\[mcp_servers\.playwright(\.|\])?/ && skip == 1 { skip = 0 }
        !skip { print }
    ' "$config_file" > "$tmp_file"

    args_json="$(playwright_mcp_args_json "$target_home")"
    {
        printf '\n'
        printf '# >>> shipflow codex playwright mcp >>>\n'
        printf '[mcp_servers.playwright]\n'
        printf 'command = "npx"\n'
        printf 'args = %s\n' "$args_json"
        printf 'enabled = true\n'
        printf '\n'
        printf '[mcp_servers.playwright.tools]\n'
        printf 'browser_snapshot = {}\n'
        printf 'browser_click = {}\n'
        printf 'browser_type = {}\n'
        printf 'browser_take_screenshot = {}\n'
        printf 'browser_console_messages = {}\n'
        printf 'browser_network_requests = {}\n'
        printf 'browser_run_code = {}\n'
        printf '\n'
        printf '[mcp_servers.playwright.tools.browser_navigate]\n'
        printf 'approval_mode = "approve"\n'
        printf '\n'
        printf '[mcp_servers.playwright.tools.browser_resize]\n'
        printf 'approval_mode = "approve"\n'
        printf '# <<< shipflow codex playwright mcp <<<\n'
    } >> "$tmp_file"

    mv "$tmp_file" "$config_file"
}

# Configure skills symlinks for a user
ensure_skill_link() {
    local source_dir="$1"
    local target_path="$2"
    local resolved_target
    local backup_dir
    local normalized_source

    if [ -L "$target_path" ]; then
        resolved_target=$(readlink -f "$target_path" 2>/dev/null || true)
        normalized_source=$(readlink -f "${source_dir%/}" 2>/dev/null || true)
        if [ -n "$resolved_target" ] && [ "$resolved_target" = "$normalized_source" ]; then
            return 0
        fi
        rm -f "$target_path"
        ln -s "${source_dir%/}" "$target_path"
        return $?
    fi

    if [ -e "$target_path" ]; then
        backup_dir="$(dirname "$target_path")/.backup-$(date '+%Y%m%d-%H%M%S')"
        mkdir -p "$backup_dir"
        mv "$target_path" "$backup_dir/"
    fi

    ln -s "${source_dir%/}" "$target_path"
}

verify_skill_link() {
    local target_path="$1"
    [ -L "$target_path" ] && [ -f "$target_path/SKILL.md" ]
}

cleanup_legacy_skill_entries() {
    local skills_home="$1"
    local legacy_entry="$skills_home/references"

    if [ -L "$legacy_entry" ]; then
        rm -f "$legacy_entry"
    fi
}

configure_skills() {
    local target_home="$1"
    local expected=0
    local claude_count=0
    local codex_count=0
    local failed=0

    if [ ! -d "$SHIPFLOW_DIR/skills" ]; then
        warning "Dossier skills introuvable: $SHIPFLOW_DIR/skills"
        return 1
    fi

    mkdir -p "$target_home/.claude/skills"
    mkdir -p "$target_home/.codex/skills"
    cleanup_legacy_skill_entries "$target_home/.claude/skills"
    cleanup_legacy_skill_entries "$target_home/.codex/skills"

    for skill_dir in "$SHIPFLOW_DIR/skills"/*/; do
        local skill_name
        [ -d "$skill_dir" ] || continue
        [ -f "$skill_dir/SKILL.md" ] || continue

        expected=$((expected + 1))
        skill_name=$(basename "$skill_dir")

        if ensure_skill_link "$skill_dir" "$target_home/.claude/skills/$skill_name" \
            && verify_skill_link "$target_home/.claude/skills/$skill_name"; then
            claude_count=$((claude_count + 1))
        else
            warning "Skill Claude non lié: $skill_name -> $target_home/.claude/skills/$skill_name"
            failed=$((failed + 1))
        fi

        if ensure_skill_link "$skill_dir" "$target_home/.codex/skills/$skill_name" \
            && verify_skill_link "$target_home/.codex/skills/$skill_name"; then
            codex_count=$((codex_count + 1))
        else
            warning "Skill Codex non lié: $skill_name -> $target_home/.codex/skills/$skill_name"
            failed=$((failed + 1))
        fi
    done

    if [ "$expected" -eq 0 ]; then
        warning "Aucun skill ShipFlow valide trouvé dans $SHIPFLOW_DIR/skills"
        return 1
    fi

    if [ "$failed" -gt 0 ] || [ "$claude_count" -ne "$expected" ] || [ "$codex_count" -ne "$expected" ]; then
        warning "Skills incomplets pour $target_home: Claude $claude_count/$expected, Codex $codex_count/$expected"
        return 1
    fi

    echo -e "  ${GREEN}✅ Skills liés :${NC} $expected Claude + $expected Codex"
    return 0
}

# Configure aliases in bashrc
configure_aliases() {
    local bashrc="$1/.bashrc"
    [ -f "$bashrc" ] || touch "$bashrc"
    sed -i '/^# >>> ShipFlow AI aliases >>>$/,/^# <<< ShipFlow AI aliases <<<$/{d}' "$bashrc"
    cat >> "$bashrc" << ALIASES

# >>> ShipFlow AI aliases >>>
alias shipflow='$SHIPFLOW_DIR/shipflow.sh'
alias sf='$SHIPFLOW_DIR/shipflow.sh'
alias c='claude --dangerously-skip-permissions --permission-mode bypassPermissions'
alias co='codex'
alias cask='claude --permission-mode default'
alias coask='codex --ask-for-approval on-request --sandbox danger-full-access'
# <<< ShipFlow AI aliases <<<
ALIASES
}

configure_shipflow_environment() {
    local target_home="$1"
    local bashrc="$target_home/.bashrc"
    [ -f "$bashrc" ] || return 0

    sed -i '/^# >>> ShipFlow environment >>>$/,/^# <<< ShipFlow environment <<<$/{d}' "$bashrc"
    cat >> "$bashrc" << ENV

# >>> ShipFlow environment >>>
export SHIPFLOW_ROOT='$SHIPFLOW_DIR'
export SHIPFLOW_DATA_DIR='$target_home/shipflow_data'
# <<< ShipFlow environment <<<
ENV
}

configure_command_wrappers() {
    local shipflow_target="$SHIPFLOW_DIR/shipflow.sh"
    local bin_dir="/usr/local/bin"

    mkdir -p "$bin_dir"
    ln -sf "$shipflow_target" "$bin_dir/shipflow"
    ln -sf "$shipflow_target" "$bin_dir/sf"
    chmod +x "$bin_dir/shipflow" "$bin_dir/sf" 2>/dev/null || true

    if [ -x "$bin_dir/shipflow" ] && [ -x "$bin_dir/sf" ]; then
        echo -e "  ${GREEN}✅ Commandes système disponibles :${NC} /usr/local/bin/shipflow et /usr/local/bin/sf"
    else
        echo -e "  ${YELLOW}⚠️ Commandes /usr/local/bin/shipflow ou /usr/local/bin/sf non trouvées${NC}"
    fi
}

# Create shipflow_data for a user
configure_data() {
    local data_dir="$1/shipflow_data"
    if [ ! -d "$data_dir" ]; then
        mkdir -p "$data_dir"
        echo "# Tasks" > "$data_dir/TASKS.md"
        echo "# Audit Log" > "$data_dir/AUDIT_LOG.md"
        echo "# Projects" > "$data_dir/PROJECTS.md"
    fi
}

ensure_user_local_npm_bootstrap() {
    local user_home="$1"
    local username="$2"
    local bashrc="$user_home/.bashrc"
    local npm_dir="$user_home/.npm-global"
    [ -f "$bashrc" ] || touch "$bashrc"
    mkdir -p "$npm_dir/bin"
    chown -R "$username:$username" "$npm_dir" 2>/dev/null || true

    sed -i '/^# >>> ShipFlow npm bootstrap >>>$/,/^# <<< ShipFlow npm bootstrap <<<$/{d}' "$bashrc"
    cat >> "$bashrc" << 'BOOTSTRAP'

# >>> ShipFlow npm bootstrap >>>
export NPM_CONFIG_PREFIX="$HOME/.npm-global"
export PATH="$HOME/.npm-global/bin:$PATH"
# <<< ShipFlow npm bootstrap <<<
BOOTSTRAP
}

install_ai_agent_clis_for_user() {
    local user_home="$1"
    local username="$2"
    if [ "$username" = "root" ]; then
        return 0
    fi
    ensure_user_local_npm_bootstrap "$user_home" "$username"
    sudo -u "$username" -H bash -lc 'export NPM_CONFIG_PREFIX="$HOME/.npm-global"; export PATH="$HOME/.npm-global/bin:$PATH"; command -v claude >/dev/null 2>&1 || npm install -g @anthropic-ai/claude-code' || return 1
    sudo -u "$username" -H bash -lc 'export NPM_CONFIG_PREFIX="$HOME/.npm-global"; export PATH="$HOME/.npm-global/bin:$PATH"; command -v codex >/dev/null 2>&1 || npm install -g @openai/codex' || return 1
    return 0
}

configure_claude_autonomous_permissions() {
    local target_home="$1"
    local settings_file="$target_home/.claude/settings.json"
    mkdir -p "$target_home/.claude"
    [ -f "$settings_file" ] || echo '{}' > "$settings_file"
    jq '
      .permissions = (.permissions // {})
      | .permissions.defaultMode = "bypassPermissions"
      | .permissions.skipDangerousModePermissionPrompt = true
    ' "$settings_file" > "${settings_file}.tmp" && mv "${settings_file}.tmp" "$settings_file"
}

configure_codex_autonomous_permissions() {
    local target_home="$1"
    local codex_dir="$target_home/.codex"
    local config_file="$codex_dir/config.toml"
    local tmp_file="$config_file.tmp.$$"
    mkdir -p "$codex_dir"
    [ -f "$config_file" ] || touch "$config_file"
    awk '
      !/^[[:space:]]*approval_policy[[:space:]]*=/ && !/^[[:space:]]*sandbox_mode[[:space:]]*=/
    ' "$config_file" > "$tmp_file"
    {
      printf '\n# >>> shipflow codex autonomous >>>\n'
      printf 'approval_policy = "never"\n'
      printf 'sandbox_mode = "danger-full-access"\n'
      printf '# <<< shipflow codex autonomous <<<\n'
    } >> "$tmp_file"
    mv "$tmp_file" "$config_file"
}

is_user_eligible() {
    local username="$1"
    local home shell
    [ "$username" = "root" ] && return 1
    home="$(getent passwd "$username" | cut -d: -f6)"
    shell="$(getent passwd "$username" | cut -d: -f7)"
    [ -z "$home" ] && return 1
    [ ! -d "$home" ] && return 1
    [ ! -w "$home" ] && return 1
    case "$shell" in
        *nologin|*false) return 1 ;;
    esac
    return 0
}

collect_target_users() {
    local mode="${SHIPFLOW_INSTALL_USERS_MODE:-}"
    local list="${SHIPFLOW_INSTALL_USERS:-}"
    local user
    TARGET_USERS=()
    REJECTED_USERS=()
    mapfile -t ELIGIBLE_USERS < <(getent passwd | awk -F: '$3 >= 1000 {print $1}' | sort -u)

    if [ "$mode" = "user-list" ]; then
        for user in $list; do
            if id "$user" >/dev/null 2>&1 && is_user_eligible "$user"; then
                TARGET_USERS+=("$user")
            else
                REJECTED_USERS+=("$user")
            fi
        done
    else
        for user in "${ELIGIBLE_USERS[@]}"; do
            if is_user_eligible "$user"; then
                TARGET_USERS+=("$user")
            fi
        done
    fi
}

# Full per-user setup
setup_user() {
    local user_home="$1"
    local username="$2"
    local allow_root_autonomous="${SHIPFLOW_AI_ALLOW_ROOT_AUTONOMOUS:-0}"
    local setup_failed=0

    configure_statusline "$user_home"
    configure_context7_mcp "$user_home"
    configure_vercel_mcp "$user_home"
    configure_convex_mcp "$user_home"
    configure_clerk_mcp "$user_home"
    configure_supabase_mcp "$user_home"
    configure_dataforseo_mcp "$user_home"
    configure_playwright_mcp "$user_home"
    configure_codex_tui "$user_home"
    configure_codex_rmcp "$user_home"
    configure_codex_context7_mcp "$user_home"
    configure_codex_vercel_mcp "$user_home"
    configure_codex_convex_mcp "$user_home"
    configure_codex_clerk_mcp "$user_home"
    configure_codex_supabase_mcp "$user_home"
    configure_codex_dataforseo_mcp "$user_home"
    configure_codex_playwright_mcp "$user_home"
    if [ "$username" != "root" ]; then
        install_ai_agent_clis_for_user "$user_home" "$username" || setup_failed=1
        configure_claude_autonomous_permissions "$user_home" || setup_failed=1
        configure_codex_autonomous_permissions "$user_home" || setup_failed=1
    elif [ "$allow_root_autonomous" = "1" ]; then
        configure_claude_autonomous_permissions "$user_home" || setup_failed=1
        configure_codex_autonomous_permissions "$user_home" || setup_failed=1
    fi
    configure_skills "$user_home" || setup_failed=1
    configure_shipflow_environment "$user_home"
    configure_aliases "$user_home"
    configure_data "$user_home"

    # Fix ownership — everything we created must belong to the user
    if [ "$username" != "root" ]; then
        chown -hR "$username:$username" "$user_home/.claude" 2>/dev/null || true
        chown -hR "$username:$username" "$user_home/.codex" 2>/dev/null || true
        chown -R "$username:$username" "$user_home/shipflow_data" 2>/dev/null || true
    fi

    if [ "$setup_failed" -eq 0 ]; then
        echo -e "  ${GREEN}✅ Utilisateur configuré :${NC} $username"
    else
        echo -e "  ${YELLOW}⚠️ Utilisateur configuré avec warnings :${NC} $username"
    fi
}

echo ""
echo -e "${BLUE}👥 Configuration par utilisateur...${NC}"
configure_command_wrappers

collect_target_users
setup_user "$HOME" "root"
for username in "${TARGET_USERS[@]}"; do
    user_home="$(getent passwd "$username" | cut -d: -f6)"
    [ -n "$user_home" ] || continue
    setup_user "$user_home" "$username"
done

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${NC}          ${YELLOW}Installation terminée !${NC}              ${CYAN}║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${BLUE}📝 Prochaines étapes :${NC}"
echo ""
echo -e "1. ${YELLOW}Authentification GitHub${NC} (si pas déjà fait) :"
echo -e "   ${CYAN}gh auth login${NC}"
echo ""
echo -e "2. ${YELLOW}Lancer ShipFlow${NC} :"
echo -e "   ${CYAN}shipflow${NC}  ou  ${CYAN}sf${NC}"
echo ""

# Résumé des installations
echo -e "${BLUE}🎯 Résumé :${NC}"
echo -e "  • Node.js: $(command -v node >/dev/null 2>&1 && echo '✅' || echo '❌')"
echo -e "  • PM2: $(command -v pm2 >/dev/null 2>&1 && echo '✅' || echo '❌')"
echo -e "  • Vercel CLI: $(command -v vercel >/dev/null 2>&1 && echo '✅' || echo '❌')"
echo -e "  • Convex CLI: $(command -v convex >/dev/null 2>&1 && echo '✅' || echo '❌')"
echo -e "  • Clerk CLI: $(command -v clerk >/dev/null 2>&1 && echo '✅' || echo '❌')"
echo -e "  • Supabase CLI: $(command -v supabase >/dev/null 2>&1 && echo '✅' || echo '❌')"
echo -e "  • Flox: $(command -v flox >/dev/null 2>&1 && echo '✅' || echo '⚠️ Installation manuelle requise')"
echo -e "  • GitHub CLI: $(command -v gh >/dev/null 2>&1 && echo '✅' || echo '❌')"
echo -e "  • Caddy: $(command -v caddy >/dev/null 2>&1 && echo '✅' || echo '⚠️ Installation manuelle requise')"
echo -e "  • Python3: $(command -v python3 >/dev/null 2>&1 && echo '✅' || echo '❌')"
echo -e "  • PyYAML: $(python3 -c 'import yaml' 2>/dev/null && echo '✅' || echo '❌')"
echo -e "  • Git: $(command -v git >/dev/null 2>&1 && echo '✅' || echo '❌')"
echo -e "  • jq: $(command -v jq >/dev/null 2>&1 && echo '✅ (2-5x faster JSON)' || echo '❌')"
echo -e "  • fuser: $(command -v fuser >/dev/null 2>&1 && echo '✅ (port cleanup)' || echo '❌')"
echo ""
echo -e "${BLUE}🗂️  Logs :${NC}"
echo -e "  • Fichier: ${SHIPFLOW_LOG_FILE}"
shipflow_log "INFO" "ShipFlow install completed"

generate_install_report() {
    local status_node status_pm2 status_vercel status_convex status_clerk status_supabase status_flox status_gh status_python3 status_pyyaml status_caddy status_git status_jq status_fuser
    if command -v node >/dev/null 2>&1; then status_node="present"; else status_node=""; fi
    if command -v pm2 >/dev/null 2>&1; then status_pm2="present"; else status_pm2=""; fi
    if command -v vercel >/dev/null 2>&1; then status_vercel="present"; else status_vercel=""; fi
    if command -v convex >/dev/null 2>&1; then status_convex="present"; else status_convex=""; fi
    if command -v clerk >/dev/null 2>&1; then status_clerk="present"; else status_clerk=""; fi
    if command -v supabase >/dev/null 2>&1; then status_supabase="present"; else status_supabase=""; fi
    if command -v flox >/dev/null 2>&1; then status_flox="present"; else status_flox=""; fi
    if command -v gh >/dev/null 2>&1; then status_gh="present"; else status_gh=""; fi
    if command -v python3 >/dev/null 2>&1; then status_python3="present"; else status_python3=""; fi
    if python3 -c 'import yaml' 2>/dev/null; then status_pyyaml="present"; else status_pyyaml=""; fi
    if command -v caddy >/dev/null 2>&1; then status_caddy="present"; else status_caddy=""; fi
    if command -v git >/dev/null 2>&1; then status_git="present"; else status_git=""; fi
    if command -v jq >/dev/null 2>&1; then status_jq="present"; else status_jq=""; fi
    if command -v fuser >/dev/null 2>&1; then status_fuser="present"; else status_fuser=""; fi

    cat > "$SHIPFLOW_REPORT_FILE" << REPORT
# Rapport d'installation ShipFlow

## Run summary

- Date UTC: $(date -u +%Y-%m-%dT%H:%M:%SZ)
- Repo: ShipFlow
- Utilisateur: $(id -un)
- Commande: sudo ./install.sh
- Mode: root (system + user config)
- Version script: local
- Machine: $(hostname)
- Log brut: $SHIPFLOW_LOG_FILE
- Statut global: $(if command -v node >/dev/null 2>&1 && command -v pm2 >/dev/null 2>&1 && command -v vercel >/dev/null 2>&1; then echo "SUCCÈS"; else echo "PARTIEL"; fi)

## Packages / outils

| Élément | Résultat | Détails |
|---|---|---|
| Node.js | $(shipflow_status "$SHIPFLOW_PRE_STATUS_DIR_NODE" "$status_node") | Détection binaire |
| PM2 | $(shipflow_status "$SHIPFLOW_PRE_STATUS_PM2" "$status_pm2") | Détection binaire |
| Vercel CLI | $(shipflow_status "$SHIPFLOW_PRE_STATUS_VERCEL" "$status_vercel") | Détection binaire |
| Convex CLI | $(shipflow_status "$SHIPFLOW_PRE_STATUS_CONVEX" "$status_convex") | Détection binaire |
| Clerk CLI | $(shipflow_status "$SHIPFLOW_PRE_STATUS_CLERK" "$status_clerk") | Détection binaire |
| Supabase CLI | $(shipflow_status "$SHIPFLOW_PRE_STATUS_SUPABASE" "$status_supabase") | Détection binaire |
| Flox | $(shipflow_status "$SHIPFLOW_PRE_STATUS_FLOX" "$status_flox") | Détection binaire |
| GitHub CLI | $(shipflow_status "$SHIPFLOW_PRE_STATUS_GH" "$status_gh") | Détection binaire |
| Caddy | $(shipflow_status "$SHIPFLOW_PRE_STATUS_CADDY" "$status_caddy") | Détection binaire |
| Python3 | $(shipflow_status "$SHIPFLOW_PRE_STATUS_PYTHON3" "$status_python3") | Détection binaire |
| PyYAML | $(shipflow_status "$SHIPFLOW_PRE_STATUS_PYYAML" "$status_pyyaml") | python3 -c 'import yaml' |
| Git | $(shipflow_status "$SHIPFLOW_PRE_STATUS_GIT" "$status_git") | Détection binaire |
| jq | $(shipflow_status "$SHIPFLOW_PRE_STATUS_JQ" "$status_jq") | Détection binaire |
| fuser | $(shipflow_status "$SHIPFLOW_PRE_STATUS_FUSER" "$status_fuser") | Détection binaire |

## Outils utilisateur

| Élément | Résultat | Détails |
|---|---|---|
| claude | $(if command -v claude >/dev/null 2>&1; then echo "INSTALLÉ"; else echo "PARTIEL"; fi) | géré par ShipFlow (scope utilisateur) |
| codex | $(if command -v codex >/dev/null 2>&1; then echo "INSTALLÉ"; else echo "PARTIEL"; fi) | géré par ShipFlow (scope utilisateur) |
| tmux | NON_APPLICABLE | géré par dotfiles |
| mosh | NON_APPLICABLE | géré par dotfiles |

## Configuration

- Utilisateurs ciblés: root + ${TARGET_USERS[*]:-none}
- Cibles de config: root + comptes éligibles sélectionnés
- Compte d'invocation: ${INVOKING_USER:-root}
- Résumé santé/diagnostic:
- Actions correctives suggérées:

## Observations

- Avertissements:
- Erreurs bloquantes:
- Recommandations:
REPORT
}

generate_install_report

echo -e "${BLUE}🗒️  Rapport :${NC}"
echo -e "  • Fichier: ${SHIPFLOW_REPORT_FILE}"

success "Installation complète pour tous les utilisateurs !"
