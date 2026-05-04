# sf-audit-design

> Audit UI/UX professionnel — 4 modes (page / projet light / deep / global), orchestrateur de 3 specialists en deep mode.

## Le problème

Les audits design classiques cochent des cases superficielles. Ils ratent l'essentiel : est-ce que le **système** derrière l'interface tient la route ? Les design tokens sont-ils centralisés ? Les composants sont-ils réellement réutilisables ? L'accessibilité atteint-elle le niveau WCAG 2.2 AA complet, ou seulement les bases ?

Quand un projet devient gros, un audit monolithique dilue l'attention sur trop de checklists à la fois, ce qui baisse la rigueur de chaque check. `sf-audit-design` résout ça avec **deux modes** adaptés à la taille du projet.

## Les 4 modes

| Mode | Déclenchement | Durée estimée | Usage |
|------|---------------|---------------|-------|
| **Page** | `/sf-audit-design src/pages/home.astro` | ~5 min | Revue d'une page précise |
| **Project (light)** | `/sf-audit-design` (sans argument) | ~15-20 min | Audit de surface sur tout le projet, self-sufficient |
| **Deep** | `/sf-audit-design deep` | ~30-45 min | Audit pro-grade sur projet large : 3 specialists en parallèle |
| **Global** | `/sf-audit-design global` | variable | Tous les projets UI du workspace d'un coup |

### Light vs Deep : quand choisir quoi ?

- **Light** par défaut. Suffit pour la plupart des revues, contenu + SaaS < 30 composants.
- **Deep** quand : projet > 30 composants, audit avant un freeze, onboarding d'un nouveau designer, ou besoin de rigueur par domaine sans compromis.

Deep orchestre 3 specialists via Agent tool (parallèle) :

```
sf-audit-design (deep)
    ├─ sf-audit-design-tokens   ← design tokens (theme + typo + spacing + motion)
    ├─ sf-audit-components      ← architecture composants
    └─ sf-audit-a11y            ← WCAG 2.2 complet + patterns ARIA
```

Chaque specialist retourne un sub-report ; l'orchestrateur compile un report unifié.

## La checklist light (13 catégories)

1. **Visual Hierarchy & Layout** — CTA, flow, whitespace
2. **Typography** — hiérarchie, `clamp()` fluide, système de tokens typo, ratio modulaire (Utopia.fyi)
3. **Color & Contrast** — WCAG AA, `oklch`, `light-dark()`, socle sémantique universel (`success`/`warning`/`danger`/`info`/`neutral`)
4. **Responsiveness** — mobile-first, touch targets ≥ 44×44
5. **Component Consistency** — patterns uniformes, states couverts
6. **Accessibility (WCAG 2.2)** — alt, focus visible, target size 2.5.8, dragging 2.5.7, consistent help 3.2.6
7. **Usability — NN/g Heuristics** — les 10 heuristiques de Nielsen
8. **No Outdated Patterns** — `alert()`, `<marquee>`, jQuery, `<div role="dialog">` à la place de `<dialog>`
9. **Modern CSS (2026 baseline)** — `@container`, `:has()`, view transitions, `anchor-name`, subgrid
10. **AI-Generated Code Smells** — conflits Tailwind, classes dynamiques, `div` cliquable sans role
11. **Theme System Architecture** — 3 modes (light/dark/system), persistence, sync serveur si auth, FOUC prevention
12. **Spacing System** — scale cohérente, naming adaptatif, fluid layout
13. **Motion System** — tokens sémantiques, `prefers-reduced-motion`, compositor-only

## Format du report

```
DESIGN REVIEW: [page name]
─────────────────────────────────────
Visual Hierarchy   [A/B/C/D]
Typography         [A/B/C/D]
Color & Contrast   [A/B/C/D]
Responsiveness     [A/B/C/D]
Consistency        [A/B/C/D]
Accessibility      [A/B/C/D]
Usability (NN/g)   [A/B/C/D]
Modern Patterns    [A/B/C/D]
Modern CSS 2026    [A/B/C/D]
AI-Gen Smells      [A/B/C/D]
─────────────────────────────────────
DESIGN TOKEN SYSTEM
Theme Architecture [A/B/C/D]
Spacing System     [A/B/C/D]
Motion System      [A/B/C/D]
─────────────────────────────────────
OVERALL            [A/B/C/D]

PRIORITY IMPROVEMENTS (high impact, bounded effort)
  ⚡ [file:line] description — Why: [principle]
```

En **deep mode**, le report est étendu avec les 3 sous-scores globaux (Design Tokens / Components / Accessibility) et l'OVERALL est le **pire des trois** (standard pro-grade : un projet n'est pas « A » en design si son a11y est « C »).

## Principes de l'audit

- **Read-only par défaut** : l'audit liste les manquements dans `TASKS.md`, il ne refactore pas automatiquement. L'utilisateur garde le contrôle.
- **Sévérité adaptative à la taille du projet** : small projects → findings généralement priorisés 🟡 sauf impact utilisateur ou confiance de marque, mid → 🟠, large → 🔴. Le niveau d'exigence reste professionnel; seule la priorité suit le blast radius.
- **Tracking systématique** : chaque audit logué dans `AUDIT_LOG.md` (local + global) et `TASKS.md` (sous-section `### Audit: Design`).
- **Sources citées** : chaque finding inclut une ligne « Why it matters » avec le principe (WCAG 2.5.8, NN/g #1, Fitts's law, etc.).

## Dépendances

- **En amont** : `sf-audit` (top-level) peut appeler `sf-audit-design` en mode standard sur plusieurs projets en parallèle.
- **En aval (deep mode)** : spawn 3 agents via Agent tool sur `sf-audit-design-tokens`, `sf-audit-components`, `sf-audit-a11y`.
- **Associée (non appelée)** : `sf-design-playground` — générateur de page de preview des design tokens. L'audit recommande de la lancer si aucune playground n'est détectée.

## Cross-platform

- **Web** : React, Vue, Svelte, Astro, Next.js, Nuxt, Remix, SvelteKit
- **Mobile** : Flutter (`ThemeData`, `TextTheme`, `ColorScheme`, `Semantics`)
- **Hybride** : Expo, Tauri, Capacitor

## Exemples

```bash
# Audit light du projet courant
/sf-audit-design

# Audit d'une page
/sf-audit-design src/pages/pricing.astro

# Audit pro-grade (3 specialists en parallèle)
/sf-audit-design deep

# Audit cross-projet (workspace ShipFlow)
/sf-audit-design global
```
