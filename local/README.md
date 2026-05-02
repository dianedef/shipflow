# 🏠 Configuration Machine Locale

Scripts pour accéder aux applications d'un serveur ShipFlow depuis votre machine locale via des tunnels SSH.

## 📋 Prérequis

### Installation des outils

**macOS :**
```bash
brew install autossh
```

**Linux (Debian/Ubuntu) :**
```bash
sudo apt install autossh
```

**Windows :**
Voir [README_WINDOWS.md](./README_WINDOWS.md) pour les 3 options disponibles:
- ✅ **WSL** (recommandé) - Support complet avec menu interactif
- ⚡ **PowerShell** - Simple avec OpenSSH natif
- 🔧 **Git Bash** - Environnement bash familier

## 🔧 Installation Automatique

### Installation rapide (recommandé)

**Linux / macOS / WSL:**
```bash
# Cloner le repo
git clone <votre-repo> ~/shipflow
cd ~/shipflow/local

# Lancer l'installation
./install.sh

# Optionnel: enregistrer directement le nouveau serveur
SHIPFLOW_SSH_REMOTE_HOST=ubuntu@SERVER_IP ./install.sh

# Recharger le shell
source ~/.bashrc  # ou source ~/.zshrc
```

**Windows (PowerShell):**
```powershell
# Cloner le repo
git clone <votre-repo> $env:USERPROFILE\shipflow
cd $env:USERPROFILE\shipflow\local

# Lancer l'installation
.\install_local.ps1

# Recharger le profil
. $PROFILE
```

Le script installe automatiquement :
- ✅ Connexion distante ShipFlow si `SHIPFLOW_SSH_REMOTE_HOST` est fourni
- ✅ Alias shell : `urls`, `tunnel`
- ✅ Menu interactif pour gérer les tunnels (Linux/macOS/WSL)
- ✅ Script de tunnel pour Windows PowerShell
- ✅ Permissions exécutables

### Installation manuelle (optionnelle)

Si vous préférez configurer manuellement :

1. **Configuration SSH** - Copier `ssh-config` dans `~/.ssh/config`
2. **Alias** - Ajouter dans `~/.bashrc` ou `~/.zshrc` :
   ```bash
   alias urls='~/shipflow/local/local.sh'
   ```

## 🚀 Utilisation

### Commandes disponibles

```bash
urls              # Ouvrir le menu de gestion des tunnels
tunnel            # Alias identique à urls
shipflow-mcp-login vercel   # Login OAuth MCP distant (Vercel)
shipflow-mcp-login supabase # Login OAuth MCP distant (Supabase)
shipflow-mcp-login all      # Enchaîne vercel puis supabase
```

### Menu interactif

Le menu offre :
- 🚇 **Démarrer les tunnels** - Détecte automatiquement les projets PM2 actifs
- 📋 **Afficher les URLs** - Liste toutes les URLs localhost disponibles
- 🛑 **Arrêter les tunnels** - Arrête tous les tunnels en cours
- 📊 **Statut** - Vérifie l'état des tunnels actifs
- 🔄 **Redémarrer** - Redémarre tous les tunnels
- 🔐 **Login OAuth MCP (distant)** - Lance `codex mcp login` sur le serveur et crée un tunnel OAuth éphémère local

Au démarrage, le menu affiche un scan animé pendant la recherche d'identité de session distante. Pour le désactiver dans un terminal lent ou automatisé :

```bash
SHIPFLOW_NO_ANIMATION=1 urls
```

### Pourquoi le tunnel OAuth existe

Quand Codex tourne sur un serveur distant, le process `codex mcp login <provider>` écoute son callback OAuth sur le serveur. Le navigateur, lui, s'ouvre sur votre machine locale et essaie de joindre `127.0.0.1:<port>/callback`. Sans tunnel, `127.0.0.1` désigne votre machine locale, pas le serveur distant.

Le problème n'est pas OAuth lui-même. Le problème est le routage: le navigateur local doit pouvoir rejoindre le listener de callback qui tourne sur le serveur distant.

```text
Navigateur local
  -> http://127.0.0.1:PORT/callback
  -> tunnel SSH ephemere -L PORT:127.0.0.1:PORT
  -> serveur distant
  -> codex mcp login <provider>
  -> provider OAuth officiel
```

Le port change a chaque tentative OAuth. `shipflow-mcp-login` extrait donc le port frais depuis la sortie de Codex, crée le tunnel après extraction, ouvre ou affiche l'URL OAuth, puis ferme le tunnel quand le flow se termine. Les tokens OAuth restent gérés par Codex et le provider sur le serveur distant; ShipFlow ne lit pas et ne stocke pas ces tokens.

Résumé mental:
- Codex distant lance le login.
- Le navigateur local reçoit l'autorisation.
- Le tunnel SSH relie les deux uniquement pendant le callback.
- ShipFlow nettoie le tunnel ensuite.

### Configurer ou changer de serveur

Le script utilise `~/.shipflow/current_connection`. Après une migration serveur, configurez la nouvelle cible depuis la machine locale avec le menu:

```bash
urls
```

Choisissez `c) Configurer nouveau serveur`, entrez l'adresse IP ou le host, puis l'utilisateur SSH. Si votre clé SSH a un nom spécial, entrez aussi son chemin (`~/.ssh/ma-cle`, par exemple). Laissez le champ vide pour utiliser la configuration SSH normale. Le menu teste la connexion et enregistre la cible pour `urls`, `tunnel` et `shipflow-mcp-login`.

Si vous êtes connecté au serveur distant et ne connaissez plus l'IP publique à utiliser, ouvrez le menu ShipFlow distant et choisissez `c) Local Setup`.

La clé SSH n'a pas besoin d'avoir un nom standard si le menu connaît son chemin ou si `~/.ssh/config` sait déjà quelle clé utiliser. Si vous changez de serveur, repassez par `c) Configurer nouveau serveur` plutôt que de modifier les fichiers à la main: le même enregistrement est utilisé par les tunnels d'applications et par le login OAuth MCP.

### Workflow

```bash
# Sur votre machine locale
urls              # Ouvre le menu interactif
# Choisir option 1 pour démarrer les tunnels
```

Le système :
- ✅ Détecte automatiquement tous les projets PM2 actifs sur le serveur configuré
- ✅ Récupère leurs ports
- ✅ Crée des tunnels SSH pour chaque port
- ✅ Affiche les URLs accessibles (localhost:3000, etc.)
- ✅ Maintient les tunnels actifs en arrière-plan

### Accéder aux applications

Ouvrez votre navigateur :
- `http://localhost:3000` (projet sur port 3000)
- `http://localhost:3001` (projet sur port 3001)
- etc.

## 🔄 Workflow typique

1. **Sur votre machine locale :** `./dev-tunnel.sh`
2. **SSH sur le serveur (avec mosh) :** `mosh "$(cat ~/.shipflow/current_connection)"`
3. **Démarrer les projets :** `dev-start`
4. **Dans votre navigateur :** Ouvrir `localhost:PORT`

## 🐛 Dépannage

### OAuth MCP: `connection refused` ou `connection reset`

Ce message arrive quand le callback OAuth `127.0.0.1:<port>` n'est pas routé vers le serveur distant.
Utilisez la commande locale `shipflow-mcp-login <provider>`: elle extrait automatiquement le port OAuth courant, crée le tunnel local temporaire, puis le ferme en fin de flow.

Ne réutilisez pas un port d'une tentative précédente: l'URL OAuth est périssable et le port peut changer à chaque relance. Si le script indique que SSH est inaccessible, retournez dans `urls`, choisissez `c) Configurer nouveau serveur`, vérifiez l'IP, l'utilisateur SSH et, si nécessaire, le chemin de la clé.

### Le script ne trouve pas de ports

Vérifiez que PM2 tourne sur le serveur :
```bash
ssh "$(cat ~/.shipflow/current_connection)" "pm2 list"
```

### Les tunnels ne se créent pas

Vérifiez la configuration SSH :
```bash
ssh "$(cat ~/.shipflow/current_connection)" "echo Connection OK"
```

### MCP provider absent

Si `shipflow-mcp-login vercel` ou `shipflow-mcp-login supabase` indique que le provider n'existe pas côté distant, ajoutez-le d'abord sur le serveur:

```bash
codex mcp add vercel --url https://mcp.vercel.com
codex mcp add supabase --url https://mcp.supabase.com/mcp
```

### Port déjà utilisé localement

Arrêtez le processus qui utilise le port ou modifiez la configuration PM2 sur le serveur.

## 📝 Notes

- Les tunnels restent actifs même si vous fermez le terminal
- `autossh` recrée automatiquement les tunnels en cas de déconnexion
- Les ports sont mappés 1:1 (port distant 3000 → port local 3000)
