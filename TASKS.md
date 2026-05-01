# Tasks — ShipFlow

> **Priority:** 🔴 P0 blocker · 🟠 P1 high · 🟡 P2 normal · 🟢 P3 low · ⚪ deferred
> **Status:** 📋 todo · 🔄 in progress · ✅ done · ⛔ blocked · 💤 deferred

---

## Bootstrap universel

| Pri | Task | Status |
|-----|------|--------|
| 🔴 | Concevoir un bootstrap universel multi-OS (`Linux`, `macOS`, `WSL`, `Windows`) avec comportement explicite selon la plateforme | 📋 todo |
| 🔴 | Supprimer l'hypothèse implicite "`python3` déjà installé" hors `sudo ./install.sh` serveur et définir la stratégie officielle de provisioning runtime | 📋 todo |
| 🟠 | Ajouter un chemin d'installation local sans root quand possible pour les outils docs/metadata qui reposent sur Python | 📋 todo |
| 🟠 | Faire échouer les scripts avec un diagnostic précis et actionnable quand un runtime requis manque au lieu de dépendre d'erreurs secondaires | 📋 todo |
| 🟠 | Documenter la matrice de bootstrap par environnement : serveur Debian/Ubuntu, poste macOS, poste Linux non-root, Windows/WSL | 📋 todo |
| 🟡 | Évaluer s'il faut fournir un wrapper unique (`bootstrap` / `doctor`) pour vérifier et installer les prérequis avant usage | 📋 todo |
| 🟡 | Vérifier que `README.md`, `AGENT.md`, `CONTEXT.md` et `GUIDELINES.md` racontent le même contrat de bootstrap | 📋 todo |

---

## Documentation contracts

| Pri | Task | Status |
|-----|------|--------|
| 🟠 | Relire et shipper les docs `BUSINESS.md`, `PRODUCT.md`, `BRANDING.md`, `GTM.md`, `ARCHITECTURE.md`, `GUIDELINES.md` après la passe de durcissement en cours | 🔄 in progress |
| ✅ | Ajouter au site public ShipFlow un tutoriel marketing sur les modes des skills, une page FAQ dédiée, puis renforcer le maillage interne vers ces surfaces | ✅ done |
| 🟠 | Corriger la synchronisation finale des aliases/symlinks dans `dotfiles/install.sh` pour qu'elle s'applique aussi en mode `--only=<component>` (éviter les alias/symlinks fantômes) | ✅ done |
| 🟡 | Normaliser à terme le schéma metadata si on veut éliminer la différence `linked_systems` / `linked_artifacts` | 📋 todo |

---

## Skills

| Pri | Task | Status |
|-----|------|--------|
| 🟠 | Faire des specs le registre global des chantiers spec-first avec historique de skills | ✅ done |
| 🟠 | Ajouter la taxonomie interne des skills et les sources de chantier potentiel | ✅ done |
| 🟠 | Durable Exploration Reports for `sf-explore` | ✅ done |
| ✅ | Skill description budget compliance: audit script, descriptions compactes et checks `sf-docs`/`sf-skills-refresh` scoppés | ✅ done |
| ✅ | Patch global des skills pour résoudre les références et outils internes depuis le root canonique ShipFlow | ✅ done |
| ✅ | Créer `sf-test` pour guider les tests manuels, loguer `TEST_LOG.md` et ouvrir `BUGS.md` | ✅ done |
| 🟠 | Implémenter Professional Bug Management avec index compact, dossiers bug et preuves séparées | ✅ done |
| 🟠 | Durcir `sf-fix` pour exiger une trace bug durable même en fix direct, sauf exception mineure explicitement justifiée | ✅ done |

---

## Historical completed work

> Imported from the master tracker to keep local ShipFlow context coherent. These items are historical context, not active backlog.

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Extraction action handlers dans `lib.sh` + `shipflow.sh` réduit à 48 lignes | ✅ done |
| ✅ | Retirer ou restreindre `shipflow-inspector` et `shipflow-eruda` du layout de production | ✅ done |
| ✅ | Auditer et sécuriser `shipflow-inspector.js` (intégration upload + clé IMGBB exposée) | ✅ done |

---

## Backlog

| Pri | Task | Status |
|-----|------|--------|
| 🟠 | Harmoniser tous les sous-menus CLI : lettres au lieu de chiffres, `x) Cancel` unique, et comportement Cancel cohérent entre `gum` et fallback bash | ✅ done |

---

### Audit: Code

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Harden `local/dev-tunnel.sh` SSH target and identity validation so saved config cannot be interpreted as SSH options or malformed key paths | ✅ done |
| ✅ | Make `local/dev-tunnel.sh` session and PM2 SSH failures fail soft enough to show actionable local errors under `set -e` | ✅ done |
| ✅ | Validate PM2 ports, stop on duplicate remote ports before mutating tunnels, and check local port occupancy before `autossh` launch | ✅ done |
| ✅ | Replace broad `pkill -f "autossh.*$REMOTE_HOST"` guidance with managed tunnel PID selection and `local/dev-tunnel.sh --stop` | ✅ done |
| 🟠 | Consolidate duplicated tunnel lifecycle logic between `local/dev-tunnel.sh` and `local/local.sh` so the interactive menu inherits the same validation, collision handling, and managed stop behavior | 📋 todo |
| 🟠 | Harden `install.sh` supply-chain and failure handling: replace live `curl | bash`/direct downloads with pinned, verified install steps and strict failure behavior | 🔄 in progress |
| 🟠 | Local MCP OAuth tunnel login: commande `shipflow-mcp-login`, intégration menu local, alias install, tests de validation et docs | ✅ done |
| 🟠 | Split `lib.sh` hotspots around environment lifecycle, publishing, dashboard, inspector, and metadata helpers to reduce the 5,900+ line blast radius | 📋 todo |
| 🟡 | Resolve the `site` production dependency advisory for Astro (`GHSA-j687-52p2-xcff`) through a planned Astro upgrade/migration | 📋 todo |
| 🟡 | Fix `test_priority3.sh` so the PM2 jq parsing fixture passes or is explicitly skipped with an accurate reason | 📋 todo |
| ✅ | Validate DuckDNS publish inputs, encode DuckDNS update requests, harden secret writes, and remove the default public ImgBB upload key | ✅ done |
| ✅ | Restore the Astro docs page build by moving dynamic GitHub URLs into frontmatter and escaping shell-style `${...}` text | ✅ done |

### Audit: Perf (2026-04-29) — Score: B

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Load the public site fonts asynchronously in [site/src/layouts/BaseLayout.astro](/home/ubuntu/shipflow/site/src/layouts/BaseLayout.astro:24) so the Google Fonts stylesheet no longer blocks first paint | ✅ done |
| ✅ | Reduce compositor cost in [site/src/styles/global.css](/home/ubuntu/shipflow/site/src/styles/global.css:105) by gating blur effects behind `@supports` and lowering the blur radius on glass panels | ✅ done |
| ✅ | Defer below-the-fold layout and paint work on long static pages via `content-visibility` in [site/src/styles/global.css](/home/ubuntu/shipflow/site/src/styles/global.css:283) | ✅ done |
| ✅ | Prune heavyweight directories from [lib.sh](/home/ubuntu/shipflow/lib.sh:2233) project resolution scans and replace remote PM2 Python parsing with Node in [local/local.sh](/home/ubuntu/shipflow/local/local.sh:415) and [local/dev-tunnel.sh](/home/ubuntu/shipflow/local/dev-tunnel.sh:260) | ✅ done |
| 🟠 | Self-host the marketing site fonts or move to a local-first stack to eliminate the remaining cross-origin font dependency after the non-blocking preload patch | ✅ done |
| 🟡 | Consolidate duplicated remote PM2/tunnel parsing logic between [local/local.sh](/home/ubuntu/shipflow/local/local.sh:415) and [local/dev-tunnel.sh](/home/ubuntu/shipflow/local/dev-tunnel.sh:260) so future perf and failure-handling fixes do not drift | ✅ done |

## Audit Findings
<!-- Populated by /sf-audit — dated sections with Fixed: / Remaining: -->
