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
- ✅ Helpers OAuth distants : `shipflow-mcp-login`, `shipflow-blacksmith-login`
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
shipflow-blacksmith-login   # Login Blacksmith distant via tunnel OAuth
shipflow-turso-login        # Login Turso distant via tunnel/headless
shipflow-turso-ssh contentflow-prod2 # Copie auth Turso vers le serveur + checks SQL
```

### Menu interactif

Le menu offre :
- 🚇 **Démarrer les tunnels** - Détecte automatiquement les projets PM2 actifs et les sessions Flutter Web `tmux`
- 📋 **Afficher les URLs** - Liste toutes les URLs localhost disponibles
- 🛑 **Arrêter les tunnels** - Arrête tous les tunnels en cours
- 📊 **Statut** - Vérifie l'état des tunnels actifs
- 🔄 **Redémarrer** - Redémarre tous les tunnels
- 🔐 **Login OAuth MCP (distant)** - Lance `codex mcp login` sur le serveur et crée un tunnel OAuth éphémère local
- 🔨 **Login Blacksmith (distant)** - Lance `blacksmith auth login` sur le serveur et crée le tunnel OAuth éphémère local
- 🗄️ **Turso - Login et checks distants** - Lance `turso auth login` sur le serveur, vérifie ContentFlow, ou copie la session locale en fallback

Blacksmith n'est pas un MCP. Le menu l'affiche donc comme une option séparée.
Si vous tapez quand même `blacksmith` dans le sous-menu MCP custom par erreur,
ShipFlow bascule vers le tunnel Blacksmith dédié au lieu de chercher un MCP
Codex nommé `blacksmith`.

Au démarrage, le menu affiche un scan animé pendant la recherche d'identité de session distante. Pour le désactiver dans un terminal lent ou automatisé :

```bash
SHIPFLOW_NO_ANIMATION=1 urls
```

### Pourquoi le tunnel OAuth existe

Quand Codex tourne sur un serveur distant, le process `codex mcp login <provider>` écoute son callback OAuth sur le serveur. Le navigateur, lui, s'ouvre sur votre machine locale et essaie de joindre `127.0.0.1:<port>/callback`. Sans tunnel, `127.0.0.1` désigne votre machine locale, pas le serveur distant.

Blacksmith a le même problème avec `blacksmith auth login`: son callback
localhost tourne sur le serveur, tandis que le navigateur est local. Utilisez
donc `urls` puis `Login Blacksmith (distant)`, ou la commande locale
`shipflow-blacksmith-login`, au lieu de lancer `blacksmith auth login`
directement dans une session SSH distante.

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

`shipflow-blacksmith-login` n'utilise pas Codex MCP. Il réutilise seulement le
même mécanisme réseau de tunnel callback. Il vérifie que le CLI Blacksmith
existe sur le serveur, détecte seulement la présence de
`~/.blacksmith/credentials`, et ne lit jamais le token.

Blacksmith SSH Access est séparé de ce tunnel OAuth. Il sert à se connecter à
un runner Blacksmith pendant qu'un job GitHub Actions est encore actif ou retenu
par VM retention. La commande SSH se récupère dans le step `Setup runner` du
job, et seul l'utilisateur GitHub qui a déclenché le job peut se connecter.
L'option locale `Host *.vm.blacksmith.sh` dans `~/.ssh/config` est seulement un
confort pour les hôtes éphémères; elle n'installe pas le CLI Blacksmith.

### Turso sur serveur distant

Pour faire le login Turso côté serveur depuis votre navigateur local, utilisez :

```bash
shipflow-turso-login
```

Ou via le menu :

```bash
urls
# puis d) Turso - Login et checks distants
# puis l) Login Turso distant
```

Si Turso n'est disponible que dans un environnement Flox projet côté serveur :

```bash
shipflow-turso-login --project-dir /home/<user>/<projet>
```

Le helper lance `turso auth login --headless` sur le serveur, ouvre ou affiche
l'URL dans votre navigateur local, puis vous demande de revenir au terminal pour
vérifier `turso auth whoami` côté serveur. Turso ne suit pas toujours le même
modèle callback que Blacksmith/Supabase; le mode headless est le chemin remote
officiel. Un mode callback avancé reste disponible avec
`shipflow-turso-login --browser-callback`, mais ce n'est pas le défaut.

Pour transférer une session Turso CLI déjà authentifiée depuis le poste local
vers le serveur ShipFlow configuré sans refaire le login distant, utilisez :

```bash
shipflow-turso-ssh contentflow-prod2
```

Le helper copie `~/.config/turso` vers `~/.config/turso` sur le serveur via
SSH/SCP, verrouille les permissions, lance `turso auth whoami`, puis vérifie
les tables `jobs`, `CustomerPersona`, `UserSettings`, `Project` et
`UserProviderCredential` si un nom de base est fourni. Il ne lit pas et
n'affiche pas les tokens Turso.

Si Turso n'est disponible que dans un environnement Flox projet côté serveur :

```bash
shipflow-turso-ssh --project-dir /home/<user>/<projet> contentflow-prod2
```

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

Choisissez `c) Configurer nouveau serveur`, entrez une IP valide, un domaine avec un point, un alias SSH déjà défini dans `~/.ssh/config`, ou directement `user@host`, puis l'utilisateur SSH si nécessaire. Si votre clé SSH a un nom spécial, entrez aussi son chemin (`~/.ssh/ma-cle`, par exemple) ou un nom simple comme `oracle.key`. Laissez le champ vide pour utiliser la configuration SSH normale. Le menu teste la connexion et enregistre la cible pour `urls`, `tunnel` et `shipflow-mcp-login`.

Si vous êtes connecté au serveur distant et ne connaissez plus l'IP publique à utiliser, ouvrez le menu ShipFlow distant et choisissez `c) Local Setup`.

La clé SSH n'a pas besoin d'avoir un nom standard si le menu connaît son chemin ou si `~/.ssh/config` sait déjà quelle clé utiliser. Pour un nom simple sans `/`, ShipFlow cherche dans le dossier courant, dans `~/.ssh/`, puis dans votre dossier home, et sauvegarde ensuite le chemin absolu trouvé. Si vous changez de serveur, repassez par `c) Configurer nouveau serveur` plutôt que de modifier les fichiers à la main: le même enregistrement est utilisé par les tunnels d'applications et par le login OAuth MCP.

### Workflow

```bash
# Sur votre machine locale
urls              # Ouvre le menu interactif
# Choisir option 1 pour démarrer les tunnels
```

Le système :
- ✅ Détecte automatiquement tous les projets PM2 actifs et les sessions Flutter Web `tmux` sur le serveur configuré
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

### Blacksmith: callback localhost `connection refused`

N'utilisez pas `blacksmith auth login` directement dans une session SSH distante.
Depuis votre machine locale, lancez `urls`, puis choisissez `b) Login
Blacksmith (distant)`. Le menu lance Blacksmith sur le serveur, extrait le port
callback courant, ouvre le tunnel SSH temporaire, puis ouvre ou affiche l'URL
officielle Blacksmith dans votre navigateur local.

### Le script ne trouve pas de ports

Vérifiez que PM2 tourne sur le serveur, ou qu'une session Flutter Web a été lancée depuis `sf` :
```bash
ssh "$(cat ~/.shipflow/current_connection)" "pm2 list"
ssh "$(cat ~/.shipflow/current_connection)" "tmux ls"
```

Pour Flutter Web, lancez côté serveur `sf`, puis `Flutter Web - tmux hot reload`
et `Start session`. Le tunnel local lira le port enregistré si la session
`tmux` est encore active.

### Les tunnels ne se créent pas

Vérifiez la configuration SSH :
```bash
ssh "$(cat ~/.shipflow/current_connection)" "echo Connection OK"
```

Si le tunnel est créé mais que `localhost:<port>` ne répond pas, l'app distante
peut encore être en build. C'est fréquent avec un wrapper PM2 Flutter Web qui
fait `flutter pub get`, `flutter build web --release`, puis seulement ensuite
lance le serveur Node. PM2 affiche alors le process `online` avant que le port
applicatif soit prêt.

Attendez les marqueurs de fin dans les logs PM2, puis relancez les tunnels :

```bash
pm2 logs contentflow_app --lines 50
```

Marqueurs typiques :

```text
✓ Built build/web
... serving on http://localhost:3050
```

Si le menu indique qu'aucun tunnel actif n'a été trouvé et que vous voulez voir
les processus SSH bruts pour diagnostiquer, relancez-le en mode debug :

```bash
SHIPFLOW_DEBUG=1 urls
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
