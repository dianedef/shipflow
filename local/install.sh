#!/bin/bash
# install.sh - Installation automatique pour machine locale

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=remote-helpers.sh
source "$SCRIPT_DIR/remote-helpers.sh"
SSH_CONFIG="$HOME/.ssh/config"
SHELL_RC="$HOME/.bashrc"

# Détecter le système d'exploitation
IS_WSL=false
IS_WINDOWS=false
IS_MACOS=false
IS_LINUX=false

if grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null; then
    IS_WSL=true
    IS_WINDOWS=true
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "win32" ]]; then
    IS_WINDOWS=true
elif [[ "$OSTYPE" == "darwin"* ]]; then
    IS_MACOS=true
else
    IS_LINUX=true
fi

# Détecter le shell (bash ou zsh)
if [ -n "$ZSH_VERSION" ]; then
    SHELL_RC="$HOME/.zshrc"
elif [ -f "$HOME/.zshrc" ] && [ -n "$SHELL" ] && [[ "$SHELL" == *"zsh"* ]]; then
    SHELL_RC="$HOME/.zshrc"
fi

echo -e "${BLUE}🚀 Installation ShipFlow - Configuration Locale${NC}"
echo ""

# Afficher le système détecté
if [ "$IS_WSL" = true ]; then
    echo -e "${GREEN}✓ Système détecté: Windows WSL${NC}"
elif [ "$IS_WINDOWS" = true ]; then
    echo -e "${YELLOW}⚠ Système détecté: Windows (Git Bash)${NC}"
    echo -e "${YELLOW}  Pour une meilleure expérience, utilisez WSL (Windows Subsystem for Linux)${NC}"
    echo ""
elif [ "$IS_MACOS" = true ]; then
    echo -e "${GREEN}✓ Système détecté: macOS${NC}"
else
    echo -e "${GREEN}✓ Système détecté: Linux${NC}"
fi
echo ""

# 1. Vérifier autossh
echo -e "${BLUE}1. Vérification des dépendances...${NC}"
if ! command -v autossh &> /dev/null; then
    echo -e "${RED}   ✗ autossh non installé${NC}"
    echo -e "${YELLOW}   Installation requise:${NC}"

    if [ "$IS_MACOS" = true ]; then
        echo -e "${YELLOW}     brew install autossh${NC}"
    elif [ "$IS_WSL" = true ]; then
        echo -e "${YELLOW}     sudo apt update && sudo apt install autossh${NC}"
    elif [ "$IS_WINDOWS" = true ]; then
        echo -e "${RED}   ⚠️  Git Bash ne supporte pas autossh nativement${NC}"
        echo -e "${YELLOW}   Solutions recommandées:${NC}"
        echo -e "${YELLOW}   1. Installer WSL: https://aka.ms/wsl${NC}"
        echo -e "${YELLOW}   2. Utiliser PowerShell avec OpenSSH (voir install_local.ps1)${NC}"
        echo -e "${YELLOW}   3. Utiliser un client SSH graphique (PuTTY, MobaXterm)${NC}"
    else
        echo -e "${YELLOW}     sudo apt update && sudo apt install autossh${NC}"
    fi
    exit 1
fi
echo -e "${GREEN}   ✓ autossh installé${NC}"

# 2. Configurer SSH
echo ""
echo -e "${BLUE}2. Configuration SSH...${NC}"

# Créer ~/.ssh si nécessaire
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

# Prefer the explicit saved ShipFlow connection. Hardcoded historical server
# aliases become stale as soon as the operator migrates to a new machine.
mkdir -p "$HOME/.shipflow"
if [ -n "${SHIPFLOW_SSH_REMOTE_HOST:-}" ]; then
    printf '%s\n' "$SHIPFLOW_SSH_REMOTE_HOST" > "$HOME/.shipflow/current_connection"
    chmod 600 "$HOME/.shipflow/current_connection"
    echo -e "${GREEN}   ✓ Connexion ShipFlow enregistrée: $SHIPFLOW_SSH_REMOTE_HOST${NC}"
elif [ -f "$HOME/.shipflow/current_connection" ]; then
    echo -e "${GREEN}   ✓ Connexion ShipFlow existante: $(cat "$HOME/.shipflow/current_connection")${NC}"
else
    echo -e "${YELLOW}   ⚠ Aucune connexion distante enregistrée${NC}"
    echo -e "${YELLOW}   Après installation, lancez 'urls' puis choisissez c) Configurer nouveau serveur.${NC}"
fi

# 3. Ajouter les alias
echo ""
echo -e "${BLUE}3. Ajout des alias shell...${NC}"

ALIAS_BLOCK="
# ShipFlow - Alias pour tunnels SSH
alias urls='$SCRIPT_DIR/local.sh'
alias tunnel='$SCRIPT_DIR/local.sh'
alias shipflow-mcp-login='$SCRIPT_DIR/mcp-login.sh'
alias shipflow-blacksmith-login='$SCRIPT_DIR/blacksmith-login.sh'
alias shipflow-turso-ssh='$SCRIPT_DIR/turso-ssh.sh'
alias turso-ssh='$SCRIPT_DIR/turso-ssh.sh'
"

if grep -q "# ShipFlow - Alias pour tunnels SSH" "$SHELL_RC" 2>/dev/null; then
    echo -e "${YELLOW}   ⚠ Alias déjà présents dans $SHELL_RC${NC}"
    if ! grep -q "alias shipflow-blacksmith-login=" "$SHELL_RC" 2>/dev/null; then
        echo "alias shipflow-blacksmith-login='$SCRIPT_DIR/blacksmith-login.sh'" >> "$SHELL_RC"
        echo -e "${GREEN}   ✓ Alias shipflow-blacksmith-login ajouté à $SHELL_RC${NC}"
    fi
    if ! grep -q "alias shipflow-turso-ssh=" "$SHELL_RC" 2>/dev/null; then
        echo "alias shipflow-turso-ssh='$SCRIPT_DIR/turso-ssh.sh'" >> "$SHELL_RC"
        echo "alias turso-ssh='$SCRIPT_DIR/turso-ssh.sh'" >> "$SHELL_RC"
        echo -e "${GREEN}   ✓ Alias shipflow-turso-ssh ajouté à $SHELL_RC${NC}"
    fi
else
    echo "$ALIAS_BLOCK" >> "$SHELL_RC"
    echo -e "${GREEN}   ✓ Alias ajoutés à $SHELL_RC${NC}"
fi

# 4. Rendre les scripts exécutables
echo ""
echo -e "${BLUE}4. Configuration des permissions...${NC}"
chmod +x "$SCRIPT_DIR/dev-tunnel.sh"
chmod +x "$SCRIPT_DIR/local.sh"
chmod +x "$SCRIPT_DIR/mcp-login.sh"
chmod +x "$SCRIPT_DIR/blacksmith-login.sh"
chmod +x "$SCRIPT_DIR/turso-ssh.sh"
echo -e "${GREEN}   ✓ Scripts exécutables${NC}"

# 5. Résumé
echo ""
echo -e "${GREEN}✅ Installation terminée !${NC}"
echo ""
echo -e "${BLUE}📋 Commandes disponibles:${NC}"
echo -e "   ${GREEN}urls${NC} ou ${GREEN}tunnel${NC}         - Ouvrir le menu de gestion des tunnels"
echo -e "   ${GREEN}shipflow-mcp-login${NC}   - Login OAuth MCP distant via tunnel éphémère"
echo -e "   ${GREEN}shipflow-blacksmith-login${NC} - Login Blacksmith distant via tunnel éphémère"
echo -e "   ${GREEN}shipflow-turso-ssh${NC} - Copie auth Turso vers le serveur + checks SQL"
echo ""
echo -e "${YELLOW}⚠  Pour activer les alias, rechargez votre shell:${NC}"
echo -e "   ${BLUE}source $SHELL_RC${NC}"
echo -e "   ${YELLOW}ou${NC} fermez et rouvrez votre terminal"
echo ""
echo -e "${BLUE}🚀 Test de connexion SSH:${NC}"
TEST_REMOTE=""
TEST_IDENTITY_FILE=""
if [ -f "$HOME/.shipflow/current_connection" ]; then
    TEST_REMOTE="$(cat "$HOME/.shipflow/current_connection")"
fi
if [ -f "$HOME/.shipflow/current_identity_file" ]; then
    TEST_IDENTITY_FILE="$(cat "$HOME/.shipflow/current_identity_file")"
fi

SSH_TEST_ARGS=(-o ConnectTimeout=5 -o BatchMode=yes)
if [ -n "$TEST_IDENTITY_FILE" ]; then
    TEST_IDENTITY_FILE="$(normalize_identity_path "$TEST_IDENTITY_FILE")"
    SSH_TEST_ARGS+=(-i "$TEST_IDENTITY_FILE" -o IdentitiesOnly=yes)
fi

if [ -n "$TEST_REMOTE" ] && ssh "${SSH_TEST_ARGS[@]}" "$TEST_REMOTE" "echo OK" &>/dev/null; then
    echo -e "${GREEN}   ✓ Connexion SSH au serveur OK${NC}"
    echo ""
    echo -e "${GREEN}   Vous pouvez maintenant lancer: ${BLUE}urls${NC}"
else
    echo -e "${YELLOW}   ⚠ Impossible de se connecter au serveur${NC}"
    echo -e "${YELLOW}   Lancez 'urls' puis choisissez c) Configurer nouveau serveur.${NC}"
fi
