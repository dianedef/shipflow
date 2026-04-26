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
| 🟡 | Normaliser à terme le schéma metadata si on veut éliminer la différence `linked_systems` / `linked_artifacts` | 📋 todo |

---

## Backlog

| Pri | Task | Status |
|-----|------|--------|

---

## Audit Findings
<!-- Populated by /sf-audit — dated sections with Fixed: / Remaining: -->
