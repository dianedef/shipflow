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
| ✅ | Patch global des skills pour résoudre les références et outils internes depuis le root canonique ShipFlow | ✅ done |
| ✅ | Créer `sf-test` pour guider les tests manuels, loguer `TEST_LOG.md` et ouvrir `BUGS.md` | ✅ done |
| 🟠 | Implémenter Professional Bug Management avec index compact, dossiers bug et preuves séparées | ✅ done |

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
| 🟠 | Harmoniser tous les sous-menus CLI : lettres au lieu de chiffres, `x) Cancel` unique, et comportement Cancel cohérent entre `gum` et fallback bash | 📋 todo |

---

### Audit: Code

| Pri | Task | Status |
|-----|------|--------|
| 🟠 | Harden `install.sh` supply-chain and failure handling: replace live `curl | bash`/direct downloads with pinned, verified install steps and strict failure behavior | 🔄 in progress |
| 🟠 | Split `lib.sh` hotspots around environment lifecycle, publishing, dashboard, inspector, and metadata helpers to reduce the 5,900+ line blast radius | 📋 todo |
| 🟡 | Resolve the `site` production dependency advisory for Astro (`GHSA-j687-52p2-xcff`) through a planned Astro upgrade/migration | 📋 todo |
| 🟡 | Fix `test_priority3.sh` so the PM2 jq parsing fixture passes or is explicitly skipped with an accurate reason | 📋 todo |
| ✅ | Validate DuckDNS publish inputs, encode DuckDNS update requests, harden secret writes, and remove the default public ImgBB upload key | ✅ done |
| ✅ | Restore the Astro docs page build by moving dynamic GitHub URLs into frontmatter and escaping shell-style `${...}` text | ✅ done |

## Audit Findings
<!-- Populated by /sf-audit — dated sections with Fixed: / Remaining: -->
