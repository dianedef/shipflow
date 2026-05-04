---
name: sf-audit-design
description: "UI/UX design audit."
disable-model-invocation: true
argument-hint: '[file-path | "global" | "deep"] (omit for full project standard audit)'
---

## Canonical Paths

Before resolving any ShipFlow-owned file, load `$SHIPFLOW_ROOT/skills/references/canonical-paths.md` (`$SHIPFLOW_ROOT` defaults to `$HOME/shipflow`). ShipFlow tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPFLOW_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Chantier Tracking

Trace category: `conditionnel`.
Process role: `source-de-chantier`.

Before producing the final report, load `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md` when this run is attached to a spec-first chantier. If exactly one active `specs/*.md` chantier is identified, append the current run to `Skill Run History`, update `Current Chantier Flow` when the run changes the chantier state, and include a final `Chantier` block. If no unique chantier is identified, do not write to any spec; report `Chantier: non applicable` or `Chantier: non trace` with the reason.

## Chantier Potential Intake

Because this skill has process role `source-de-chantier`, evaluate the standard threshold from `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md` before the final report. If the findings reveal non-trivial future work and no unique chantier owns it, do not write to an existing spec; add a `Chantier potentiel` block with `oui`, `non`, or `incertain`, a proposed title, reason, severity, scope, evidence, recommended `/sf-spec ...` command, and next step. If the work is only a direct local fix or already belongs to the current chantier, state `Chantier potentiel: non` with the concrete reason.

## Report Modes

Before producing the final report, load `$SHIPFLOW_ROOT/skills/references/reporting-contract.md`.

Default to `report=user`: concise, findings-first, and focused on top issues, proof gaps, chantier potential, and the next real action. Use `report=agent`, `handoff`, `verbose`, or `full-report` for the detailed audit matrix, domain checklist output, command evidence, assumptions, confidence limits, and handoff notes.


## Context

- Current directory: !`pwd`
- Project CLAUDE.md: !`head -100 CLAUDE.md 2>/dev/null || echo "no CLAUDE.md"`
- Brand voice: !`head -60 BRANDING.md 2>/dev/null || echo "no BRANDING.md — run /sf-init to generate"`
- Business metadata files present: !`ls BUSINESS.md BRANDING.md GUIDELINES.md 2>/dev/null || echo "none found"`
- Business metadata fields: !`grep -HE '^(metadata_schema_version|artifact_version|status|updated|confidence|next_review):' BUSINESS.md BRANDING.md GUIDELINES.md 2>/dev/null || echo "no metadata fields found"`
- Tailwind/CSS config: !`cat tailwind.config.* 2>/dev/null | head -80 || echo "no tailwind config"`
- Global styles: !`cat src/styles/global.css 2>/dev/null || cat src/assets/styles/*.css 2>/dev/null | head -100 || echo "no global styles found"`
- All pages: !`find src/pages src/app -name "*.astro" -o -name "*.tsx" -o -name "*.vue" 2>/dev/null | grep -v node_modules | sort`
- Component files: !`find src/components -name "*.astro" -o -name "*.tsx" -o -name "*.vue" 2>/dev/null | grep -v node_modules | sort`
- Legacy patterns: !`grep -rn --include="*.{js,ts,jsx,tsx,astro,vue}" -E '\balert\(|\bconfirm\(|\bprompt\(|\bdocument\.write\(' src/ 2>/dev/null | head -20 || echo "none found"`
- Deprecated HTML: !`grep -rn --include="*.{astro,vue,tsx,jsx,html}" -iE '<marquee|<blink|<center|<font ' src/ 2>/dev/null | head -20 || echo "none found"`
- Dialog vs div[role=dialog]: !`grep -rn --include="*.{astro,vue,tsx,jsx,html}" -E '<div[^>]+role=["\x27]dialog' src/ 2>/dev/null | head -10 || echo "none found"`
- Hardcoded colors: !`grep -rn --include="*.{astro,vue,tsx,jsx,css,scss}" -E '#[0-9a-fA-F]{3,6}\b|rgb\(|rgba\(' src/ 2>/dev/null | grep -v node_modules | wc -l || echo "0"`
- Theme files: !`find src -type f \( -name "theme*" -o -name "*Theme*" -o -name "tokens*" -o -name "design-tokens*" -o -name "palette*" \) 2>/dev/null | grep -v node_modules | head -20 || echo "none found"`
- Theme mode preference: !`grep -rn --include="*.{ts,tsx,js,jsx,vue,astro,svelte,dart,kt,swift}" -E 'ThemeMode|prefers-color-scheme|color-scheme|themeMode|theme_mode|darkMode|dark_mode' src/ lib/ 2>/dev/null | grep -v node_modules | head -10 || echo "none found"`
- CSS custom properties for tokens: !`grep -rh --include="*.{css,scss}" -E '^\s*--(fs|fz|font-size|space|spacing|gap|color|c|bg|surface|duration|easing|ease|motion)-' src/ 2>/dev/null | sort -u | head -40 || echo "none found"`
- Literal font-sizes outside tokens: !`grep -rn --include="*.{css,scss,vue,astro,tsx,jsx}" -E 'font-size:\s*[0-9]' src/ 2>/dev/null | grep -v 'var(--' | grep -v node_modules | wc -l || echo "0"`
- Literal spacings outside tokens: !`grep -rn --include="*.{css,scss}" -E '(margin|padding|gap|top|right|bottom|left):\s*[0-9]+(\.[0-9]+)?(px|rem|em)' src/ 2>/dev/null | grep -v 'var(--' | grep -v node_modules | wc -l || echo "0"`
- Motion / transitions: !`grep -rn --include="*.{css,scss}" -E '(transition|animation):\s*' src/ 2>/dev/null | grep -v 'var(--' | grep -v node_modules | wc -l || echo "0"`
- Reduced-motion support: !`grep -rn --include="*.{css,scss,ts,tsx,js,jsx,vue,astro,svelte}" -E 'prefers-reduced-motion' src/ 2>/dev/null | grep -v node_modules | wc -l || echo "0"`
- Design playground page: !`find src -type d \( -name "design-system" -o -name "styleguide" -o -name "tokens-debug" -o -name "theme-debug" \) 2>/dev/null | grep -v node_modules | head -5 || echo "none found"`
- Auth detected (for theme sync rule): !`grep -rln --include="*.{ts,tsx,js,jsx}" -E "(next-auth|@clerk/|better-auth|@auth/|lucia|@supabase/auth|firebase/auth|getServerSession|useSession|useUser|currentUser)" src/ app/ pages/ 2>/dev/null | grep -v node_modules | head -3 || echo "none — theme sync to server not required"`

## Pre-check : contexte marque

Avant de commencer, vérifier le contexte chargé ci-dessus. Si BRANDING.md est absent :

**Afficher un avertissement en tête de rapport :**
```
⚠ Contexte manquant :
- [BRANDING.md manquant] L'audit design ne peut pas vérifier la cohérence visuelle avec l'identité de marque.

→ Lancer /sf-init pour générer ce fichier, ou /sf-docs update pour le mettre à jour.
```

Si le fichier existe mais semble incomplet, signaler. Continuer l'audit dans tous les cas.

---

## Metadata versioning doctrine

`BUSINESS.md`, `BRANDING.md`, and `GUIDELINES.md` are ShipFlow decision contracts for design audits when they define visual identity, audience expectations, trust posture, product promise, or interface guidelines. Before scoring:
- Read/report `artifact_version`, `status`, `updated`, `confidence`, and `next_review` when available.
- If `artifact_version`, `status`, or `updated` is missing, add a proof gap: `business doc metadata incomplete`.
- If `status` is `draft`, `stale`, `outdated`, `deprecated`, or `confidence` is `low`, cap confidence and state that design scoring depends on an unreviewed decision contract.
- If `next_review` is before today's absolute date, treat the document as stale unless a newer replacement is explicit.
- If visual identity, theme mode, CTA hierarchy, UI trust signals, accessibility posture, onboarding, or screenshots rely on stale or unversioned docs, do not give `A` to the affected category.
- Include a `Business metadata versions` section in every report.

Use ShipFlow versioning semantics: patch = visual wording/example clarification without decision change, minor = changed brand/UI guidance inside the same strategy, major = changed ICP, positioning, trust posture, accessibility policy, market, or brand strategy.

---

## Doctrine design / produit / docs

Le design doit servir une promesse utilisateur cohérente :
- les écrans doivent soutenir une user story identifiable : acteur, action, résultat, état de succès
- les états UI doivent refléter les vrais états système : chargement, vide, erreur, permission refusée, paiement, retry, succès partiel
- la hiérarchie visuelle, les CTA et la navigation doivent rester cohérents avec le funnel, l'onboarding et les docs
- les claims visibles dans l'interface (sécurité, automatisation, disponibilité, IA, gain de temps) doivent être cohérents avec la documentation et les limites produit
- quand une feature change, l'interface, la documentation, les exemples et les captures doivent rester alignés

Signaler les écarts de `product coherence`, `docs mismatch`, `misleading UI state` et `unproven interface claim` comme des risques produit.

---

## Mode detection

- **`$ARGUMENTS` is "deep"** → DEEP MODE: orchestrate 3 specialist agents in parallel (design tokens, components, a11y) for a pro-grade audit on a large project.
- **`$ARGUMENTS` is "global"** → GLOBAL MODE: audit ALL projects in the workspace (standard audit per project).
- **`$ARGUMENTS` is a file path** → PAGE MODE: review that single page.
- **`$ARGUMENTS` is empty** → PROJECT MODE (standard): full design audit of the entire project using the checklist below.

**Standard vs Deep**: standard mode (default) is self-sufficient — one skill, one report, professional checklist covering the 13 categories below. Deep mode spawns dedicated specialist skills via the Agent tool, each one focusing exclusively on its domain (no attention dilution). Use deep when the project is large (> ~30 component files) or when you need audit-grade proof on each design token / component architecture / WCAG 2.2 concern.

---

## DEEP MODE

Orchestrator that delegates to three specialist sub-skills, each running as a parallel subagent. Use this when a single skill's attention would be diluted across too many distinct checklists.

### Step 1: Launch the three specialists in parallel

In **one single message**, use the **Agent tool** three times (one call per specialist). All three agents run in parallel. Each agent is `subagent_type: "general-purpose"` and receives:

- The current working directory (project path)
- A prompt that instructs it to **read and execute** the corresponding specialist SKILL.md in read-only mode
- A reminder to return a **structured sub-report** with subscores, issue counts, and priority improvements — no code fixes

**The three specialists**:

1. **`sf-audit-design-tokens`** — audits the 4 design token systems (theme + typography + spacing + motion) with coverage matrix per mode, modular ratio analysis, dependency graph, DTCG compliance, historical drift. Subscores: `Theme Architecture`, `Typography Tokens`, `Spacing Tokens`, `Motion Tokens`, `Universal Palette Socle`.

2. **`sf-audit-components`** — audits component architecture: atomic design inventory, duplication detection, god components (>15 props), unused components, abstraction quality (AHA rule), variant systems adoption (CVA, tailwind-variants), headless primitives adoption (Radix, React Aria), composition vs configuration, API hygiene.

3. **`sf-audit-a11y`** — full WCAG 2.2 audit (A/AA/AAA), keyboard navigation patterns per W3C APG, focus management (trap, roving tabindex, virtual focus), ARIA patterns per component, aria-live regions, screen reader announcements, focus appearance (2.4.11), target size (2.5.8), dragging alternatives (2.5.7), consistent help (3.2.6).

Agent prompt template (adapt per specialist):

```
You are auditing the project at: [project path]

Read and execute the specialist skill at:
${SHIPFLOW_ROOT:-$HOME/shipflow}/skills/sf-audit-[tokens|components|a11y]/SKILL.md

Read the project context first:
- `CLAUDE.md`
- `BUSINESS.md`, `BRANDING.md`, and `GUIDELINES.md` metadata if present
- the theme/token/motion/auth hints surfaced by this skill when relevant

Before scoring, identify linked systems and downstream consequences.
Evaluate product coherence and documentation alignment when UI states or feature promises changed.
Read/report business metadata versions and flag missing, stale, low-confidence, or unversioned contracts as proof gaps.
Do not ask follow-up questions. If context is missing, state assumptions and confidence limits.

Run the full skill read-only (no code fixes). Return a structured sub-report with:
- Global score for this domain (A/B/C/D)
- Subscores per phase/category
- Issue counts by severity (🔴 critical / 🟠 high / 🟡 medium)
- Top 5 priority improvements for this domain (file:line + fix + Why)
- Linked systems / consequences to watch
- Product/docs coherence gaps
- Business metadata versions
- Confidence / missing context
- Raw findings list (file:line + description + severity + Why)

Do not update AUDIT_LOG.md or TASKS.md — the orchestrator will do that.
Do not edit any source files.
```

### Step 2: Compile the unified report

After all three agents return, compile one consolidated deep-audit report:

```
DEEP DESIGN AUDIT: [project name]
═══════════════════════════════════════
Mode: DEEP (3 specialists, parallel) — [date]

GLOBAL SCORES
  Design Tokens      [A/B/C/D] — from sf-audit-design-tokens
  Components         [A/B/C/D] — from sf-audit-components
  Accessibility      [A/B/C/D] — from sf-audit-a11y
═══════════════════════════════════════
OVERALL              [A/B/C/D]  ← worst of the three (pro-grade standard)

─────────────────────────────────────
DESIGN TOKEN SYSTEMS (from sf-audit-design-tokens)
  Theme Architecture     [A/B/C/D]
  Typography Tokens      [A/B/C/D]
  Spacing Tokens         [A/B/C/D]
  Motion Tokens          [A/B/C/D]
  Universal Palette Socle [A/B/C/D]
  Issues: X 🔴 | Y 🟠 | Z 🟡
─────────────────────────────────────
COMPONENT ARCHITECTURE (from sf-audit-components)
  Atomic Design Inventory   [A/B/C/D]
  Duplication               [A/B/C/D]
  Abstraction Quality (AHA) [A/B/C/D]
  Variant Systems Adoption  [A/B/C/D]
  Headless Primitives       [A/B/C/D]
  API Hygiene               [A/B/C/D]
  Issues: X 🔴 | Y 🟠 | Z 🟡
─────────────────────────────────────
ACCESSIBILITY (from sf-audit-a11y)
  WCAG 2.2 (A/AA)        [A/B/C/D]
  Keyboard Navigation    [A/B/C/D]
  Focus Management       [A/B/C/D]
  ARIA Patterns          [A/B/C/D]
  aria-live Regions      [A/B/C/D]
  Focus Appearance       [A/B/C/D]
  Target Size            [A/B/C/D]
  Issues: X 🔴 | Y 🟠 | Z 🟡
─────────────────────────────────────

CONSOLIDATED PRIORITY IMPROVEMENTS (top 10 across all three domains, ordered by impact)
  ⚡ [domain] [file:line] description — Why: [principle]
  ...

ALL CRITICAL ISSUES (🔴)
  [domain] [file:line] description — Why: [principle]
  ...

Total: X 🔴 critical, Y 🟠 high, Z 🟡 medium across 3 domains
═══════════════════════════════════════
```

**Overall rule for deep mode**: overall score is the **worst** of the three (pro-grade standard — a project isn't "A" in design if its a11y is "C"). In standard mode, overall is an average; in deep mode, it's the worst.

### Step 3: Update tracking files

- **Local `./AUDIT_LOG.md`**: append one row with mode = `deep`, three sub-scores, overall = worst.
- **Global `${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}/AUDIT_LOG.md`**: same, Design column = overall, mark mode as deep in notes column.
- **Local `TASKS.md`**: replace `### Audit: Design` subsection with three sub-subsections (`#### Tokens`, `#### Components`, `#### A11y`) — one task per critical / high / medium issue per domain.
- **Master `${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}/TASKS.md`**: same structure under the project section.

### Step 4: Offer fix

After the unified report, ask the user: **"Which domain should I fix first — tokens, components, or a11y?"** Fix one domain at a time, re-running the relevant specialist after each batch to re-score. Do not attempt to fix all three in one pass — the context would explode.

---

## GLOBAL MODE

Audit ALL UI projects in the workspace for design, UX, and accessibility issues.

1. Read `${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}/PROJECTS.md` — check the **Domain Applicability** table. Identify projects with ✓ in the Design column.

2. Use **AskUserQuestion** to let the user choose:
   - Question: "Which projects should I audit for design & UX?"
   - `multiSelect: true`
   - One option per applicable project: label = project name, description = stack from PROJECTS.md
   - All applicable projects pre-listed as options

3. Use the **Task tool** to launch one agent per **selected** project — ALL IN A SINGLE MESSAGE (parallel). Each agent: `subagent_type: "general-purpose"`.

   Agent prompt must include:
   - `cd [path]` then read `CLAUDE.md` for project context
   - The absolute date, exact project path, and the design context already surfaced by this skill (`BRANDING.md`, theme/token files, reduced-motion support, auth/theme sync hints)
   - The complete **PROJECT MODE** section from this skill (all 6 phases: Design System Inventory → Outdated Patterns Scan → Page-by-Page Scan → Cross-Page Consistency → Fix → Report)
   - The **Tracking** section from this skill
   - Rule: **read-only analysis** — no code fixes, only update AUDIT_LOG.md and TASKS.md
   - Rule: before scoring, identify linked systems and side effects (tokens, components, themes, responsive contexts, accessibility, auth-linked preferences)
   - Rule: call out product-flow incoherence, misleading UI states, documentation mismatch, and unproven interface claims
   - Rule: read/report `BUSINESS.md`, `BRANDING.md`, and `GUIDELINES.md` metadata versions; flag missing, stale, low-confidence, or unversioned contracts as proof gaps before scoring
   - Rule: do not ask follow-up questions; if context is missing, state assumptions / confidence limits and continue
   - Required sub-report sections: `Scope understood`, `User story / interface promise`, `Business metadata versions`, `Context read`, `Linked systems & consequences`, `Product/docs coherence`, `Risky assumptions / proof gaps`, `Findings`, `Confidence / missing context`

4. After all agents return, compile a **cross-project design report**:

   ```
   GLOBAL DESIGN AUDIT — [date]
   ═══════════════════════════════════════
   PROJECT SCORES
     [project]    [A/B/C/D]  —  summary
     ...
   CROSS-PROJECT PATTERNS
     [Systemic design issues in 2+ projects]
   ALL ISSUES BY SEVERITY
     🔴 [project] file:line — description — Why: [principle]
     🟠 [project] file:line — description — Why: [principle]
     🟡 [project] file:line — description — Why: [principle]
   PRIORITY IMPROVEMENTS ACROSS PROJECTS
     ⚡ [project] file:line — description — Why: [principle]
     ... (max 10, ordered by impact)
   Total: X critical, Y high, Z medium across N projects
   ═══════════════════════════════════════
   ```

5. Update `${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}/AUDIT_LOG.md` (one row per project, Design column) and `${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}/TASKS.md` (each project's `### Audit: Design` subsection).

6. Ask: **"Which projects should I fix?"** — list projects with scores. Fix only approved projects, one at a time.

---

## PAGE MODE

### Step 1: Gather the page

1. Read the target file (`$ARGUMENTS`).
2. Read its layout/wrapper component if it imports one.
3. Read any component files it imports (follow the imports).
4. Read the relevant CSS/Tailwind classes used.

### Step 2: Audit against this checklist

Score each category **A/B/C/D** (A = excellent, D = critical issues). Be strict — professional standard.

#### 1. Visual Hierarchy & Layout
- [ ] Clear primary action / CTA above the fold
- [ ] Logical reading flow (F-pattern or Z-pattern)
- [ ] Proper whitespace rhythm — consistent spacing scale (not arbitrary px values)
- [ ] Content sections have clear visual separation
- [ ] No orphaned headings, dangling text, or layout widows
- [ ] Primary action and visual priority match the user story and funnel stage
- [ ] UI does not visually promise unavailable, unproven, or undocumented behavior

#### 2. Typography
- [ ] Heading hierarchy is semantic (h1 > h2 > h3, no skipped levels)
- [ ] Body text is 16px+ with line-height >= 1.5
- [ ] Max line width ~65-75 characters (measure/prose constraint)
- [ ] Font pairing is intentional (max 2-3 families)
- [ ] No font-size under 14px except legal/fine print
- [ ] **Fluid typography**: text scales smoothly between viewports using `clamp()` instead of abrupt media-query breakpoints. Formula: `clamp(MIN, PREFERRED, MAX)` where PREFERRED is a `rem + vw` expression (e.g., `clamp(1rem, 0.5rem + 2vw, 2rem)`). Key rules:
  - Use `rem` (not `px`) in clamp values so the font respects user browser zoom/font-size preferences (accessibility)
  - The preferred value should combine a `rem` base + `vw` slope — pure `vw` ignores user settings
  - MIN must be ≤ MAX (clamp fails silently otherwise)
  - Apply to headings and hero text at minimum; body text benefits too
  - Flag any media-query that only changes `font-size` — likely replaceable with a single `clamp()` declaration

##### Typography design token system (centralization)
- [ ] **No literal `font-size` values in components**: every `font-size` resolves to a token (`var(--fs-*)`, `theme.fontSize.*`, `Theme.of(context).textTheme.*`). Literal `font-size: 1.2rem` in a component file = violation. Acceptable exceptions: HTML email templates (mail clients require inline `px`), `em` units relative to parent (icons in text). Flag count: literal font-sizes outside tokens (see context block).
- [ ] **Token bundle**: each typography token bundles `font-size` + `line-height` + `letter-spacing` (either as a single object/mixin or a triple of co-named CSS variables `--fs-base`, `--lh-base`, `--ls-base`). Isolated `font-size` tokens without paired line-height force per-component overrides → drift.
- [ ] **Naming strategy adapted to project size**:
  - Small projects (< ~30 component files, content sites, single-product) → **t-shirt naming** acceptable (`xs`, `sm`, `base`, `lg`, `xl`, `2xl`, `3xl`, `hero`). Simple, low cognitive load.
  - Larger projects (SaaS, multi-product, design-system shared across apps) → **semantic naming required** (`body`, `body-sm`, `caption`, `heading-1`, `heading-2`, `display`). Survives refactors and onboards new contributors faster.
  - Mixed naming in the same project = violation. Pick one and stick to it.
- [ ] **Modular ratio for the scale**: the size progression should follow a coherent ratio (1.125 minor second, 1.2 minor third, 1.25 major third, 1.333 perfect fourth, 1.414 augmented fourth, 1.5 perfect fifth, 1.618 golden). If 8 tokens have ratios `1.1×`, `1.4×`, `1.2×` between consecutive levels — that's chaos, not a scale. **Recommend [Utopia.fyi](https://utopia.fyi) for pro projects** to generate the scale from a base size + ratio + viewport range.
- [ ] **`vw` component caveat in `clamp()`**: the `vw` portion must stay **moderate** (≤ ~3vw) and always added to a solid `rem` base. A clamp like `clamp(1rem, 4vw, 2rem)` (vw-dominant, no rem in preferred) breaks WCAG 1.4.4 Resize Text — at 200% browser zoom, the user's font-size preference is ignored because `vw` is computed from viewport, not from user font scale. Pattern to enforce: `clamp(MIN_REM, X_REM + Y_VW, MAX_REM)` with `Y ≤ 3`.
- [ ] **Iteration on tokens, not components**: if you find yourself debating font-size in a component file, the answer is "go change the token, not the component". Components reference tokens; tokens are the only place sizes are decided.

#### 3. Color & Contrast
- [ ] WCAG AA contrast ratios (4.5:1 text, 3:1 large text/UI). Note: WCAG 3.0 draft uses APCA (perceptual) — check both when time allows
- [ ] Color is not the only way to convey information
- [ ] Consistent color token usage (no hardcoded hex outside design system) — prefer `oklch()` (perceptually uniform) over `hsl()`/`hex`
- [ ] Hover/tint/shade variants use `color-mix(in oklch, var(--brand) 70%, white)` rather than hand-picked hex — one token change re-derives the palette
- [ ] `color-mix()` declarations have a static fallback line above them (old browsers drop the whole rule otherwise)
- [ ] Interactive elements have visible focus/hover/active states
- [ ] Dark mode: `<meta name="color-scheme" content="light dark">` + root `color-scheme: light dark` + CSS uses `light-dark(<light>, <dark>)` — eliminates `@media (prefers-color-scheme: dark)` duplication

##### Semantic palette (universal socle)
- [ ] **Universal semantic socle present**: every project must expose at minimum `success`, `warning`, `danger`, `info`, `neutral` (intent-based names, not hue-based). Each one declined into the variants the project actually uses (`*-bg`, `*-fg`, `*-border`, `*-subtle` typically). These are the floor — domain-specific intents (`approve`, `reject`, `pending`, `archived`, etc.) are added **on top** for the project's vocabulary.
- [ ] **Surface tokens present**: `surface-base`, `surface-raised`, `surface-overlay`, `surface-sunken` (or equivalent). Surfaces ≠ background colors — they encode elevation/role, not a hex value.
- [ ] **No hue-based color names in components**: `Color(0xFF...)`, `Colors.white`, `Colors.orange`, `text-blue-500`, `bg-red-100` in business components = violation. Names by **intent** (`text-danger`, `bg-surface-raised`), never by **hue**. Brand colors are an acceptable exception (`brand-primary`) but should still be named by role, not by what color they happen to be.
- [ ] **One source of truth per role**: if both `--color-error` and `--color-danger` exist for the same intent, that's drift — pick one and migrate.
- [ ] **Each semantic token has a value per theme mode**: a `success` token defined only for light mode breaks dark mode. Audit all semantic tokens across all theme modes.

#### 4. Responsiveness
- [ ] Mobile-first or gracefully responsive (no horizontal scroll)
- [ ] Touch targets >= 44x44px on mobile
- [ ] Images/media have proper aspect ratio handling
- [ ] Navigation works on small screens
- [ ] No content hidden or broken between 320px-1440px

#### 5. Component Consistency
- [ ] Buttons follow a single pattern (size, radius, padding)
- [ ] Cards/containers have consistent elevation/border treatment
- [ ] Icons are same set and consistent size
- [ ] Spacing uses design system tokens, not arbitrary values
- [ ] States are covered: empty, loading, error, populated

#### 6. Accessibility (WCAG 2.2)
- [ ] All images have meaningful alt text (or alt="" for decorative)
- [ ] Form inputs have visible labels (not just placeholders)
- [ ] Keyboard navigation works (tab order, focus visible)
- [ ] ARIA roles where needed (modals, menus, tabs)
- [ ] Skip navigation link present if applicable
- [ ] Animations respect `prefers-reduced-motion`
- [ ] **Focus Appearance (2.4.11)**: Focus indicator is at least 2px solid, contrasts 3:1 against adjacent colors — no `outline: none` without replacement
- [ ] **Target Size Minimum (2.5.8)**: All interactive targets are at least 24×24px CSS with ≥8px spacing between adjacent targets (or 24px offset to neighbors) — 44×44px recommended on touch. Inline text links exempt. Icon buttons use padding (not fixed width) to hit 24×24 (e.g., 16px icon + 4px padding all sides)
- [ ] **Dragging Movements (2.5.7)**: Any drag-to-operate control also has a non-dragging alternative (buttons, click-to-place)
- [ ] **Consistent Help (3.2.6)**: Help/support mechanisms (contact, FAQ, chat) appear in the same relative position across pages
- [ ] **WCAG 3.0 readiness**: plain-language check on instructions/errors — reading level ≤ 9th grade unless context forbids. WCAG 3.0 draft (March 2026) promotes plain language from AAA to foundational
- [ ] **INP budget**: interaction handlers complete in <200ms at p75. Flag heavy `useEffect`-on-click, sync work in `onClick`. INP replaced FID as Core Web Vital March 2024
- [ ] **Click target propagation**: Containers with a single action child (icon button, hamburger menu, link) should make the whole container clickable — add `onClick`/`role="button"`/`tabIndex={0}`/`onKeyDown` to parent, `cursor-pointer` + hover state for feedback, `e.stopPropagation()` on secondary actions. Skip if: multiple competing actions, destructive action (precise click = safety), drag surface, or form controls (use `<label>` instead)

#### 7. Usability — NN/g Heuristics
- [ ] **Visibility of system status**: Loading indicators, progress bars, success/error feedback after actions
- [ ] **Match between system and real world**: Labels, icons, and flows use the user's language, not dev jargon
- [ ] **User control & freedom**: Undo/back available, no dead ends, easy to dismiss modals/overlays
- [ ] **Consistency & standards**: Same action = same result everywhere, platform conventions respected
- [ ] **Error prevention**: Destructive actions need confirmation, form inputs constrain invalid values
- [ ] **Recognition rather than recall**: Options visible (not memorized), context preserved across steps
- [ ] **Flexibility & efficiency**: Power-user shortcuts don't break novice flow (keyboard nav, autofocus)
- [ ] **Aesthetic & minimalist design**: No irrelevant info competing with primary content, clean signal-to-noise
- [ ] **Help users recover from errors**: Error messages are specific, suggest a fix, and don't blame the user
- [ ] **Help & documentation**: Tooltips, inline help, or docs link available where actions are non-obvious

#### 8. No Outdated Patterns
- [ ] No `alert()`, `confirm()`, or `prompt()` browser dialogs — use toast/modal components
- [ ] No `document.write()` — never acceptable
- [ ] No deprecated HTML (`<marquee>`, `<blink>`, `<center>`, `<font>`)
- [ ] No inline `onclick="..."` handlers — use framework event handling
- [ ] No jQuery when using a modern framework
- [ ] No `innerHTML` for user-facing content (XSS risk)
- [ ] Modals use `<dialog>` + `showModal()` — NOT `<div role="dialog">` (native focus trap, Esc, backdrop, top-layer for free)
- [ ] Lightweight menus/tooltips/disclosures use HTML `popover` attribute — NOT `<dialog>` (popovers have no `aria-modal`)
- [ ] Custom overlays apply `inert` to siblings, NOT `aria-hidden` (aria-hidden on focusable subtree = WCAG fail)
- [ ] No JS-toggled parent classes to style by child state (`.card.has-image`) — use `:has()` (`.card:has(img)`) — 95%+ support in 2026

#### 9. Modern CSS (2026 baseline)
- [ ] Components appearing in multiple layout contexts use `@container` with `container-type: inline-size` on wrapper — NOT `@media` (media queries respond to viewport, not actual component space)
- [ ] Avoid `container-type: size` (height queries) except on fixed-dimension dashboards (expensive — ~10-15ms layout cost per pass at scale)
- [ ] `:has()` selectors are child-scoped (`:has(> img)` not `:has(img)`) — bare descendant `:has()` forces full subtree walks on every mutation
- [ ] Cross-document navigation uses `@view-transition { navigation: auto }` + `view-transition-name` on hero elements (Baseline Oct 2025 — free smooth MPA transitions)
- [ ] All `::view-transition-*` animations wrapped in `@media (prefers-reduced-motion: no-preference)`
- [ ] Sibling card grids with cross-card alignment use `grid-template-rows: subgrid` on the card (fixes "buttons at different heights")
- [ ] Scroll-driven animations (`animation-timeline: scroll()` / `view()`) gated by `@media (prefers-reduced-motion: no-preference)` AND only animate `transform`/`opacity` (compositor-only)
- [ ] Tooltips/dropdowns use CSS `anchor-name`/`position-anchor` + `popover` attribute — NOT Floating UI/Popper (Baseline 2026, ~91% traffic)
- [ ] Long lists and off-screen sections use `content-visibility: auto` + `contain-intrinsic-size: auto <px>` (30-50% faster initial render)

#### 10. AI-Generated Code Smells
Flag these patterns — v0, bolt, lovable, Figma Make produce ~160 issues/app on average, 90%+ have a11y failures:
- [ ] No conflicting Tailwind utilities on same element (`grid flex`, `w-full w-64`, `p-2 p-6`) — AI pattern: adds classes without removing old ones
- [ ] No dynamic Tailwind class concatenation (`` `text-${color}-500` ``) — JIT scans plain text; concatenated classes get purged
- [ ] No hardcoded hex/rgb inside components — use design tokens
- [ ] `<div onClick>` always has `role="button"` + `tabIndex={0}` + `onKeyDown` (Enter/Space) — top a11y failure in AI-generated apps
- [ ] All images have `alt`; all form inputs have `<label>` (not placeholder-only)
- [ ] All interaction states present: `:focus-visible`, `:disabled`, loading, error, empty
- [ ] Forms use HTML5 constraint validation (`required`, `pattern`, `type="email"`) before custom JS validation

#### 11. Theme System Architecture
The design tokens above (color, typography, spacing, motion) only pay off if there is a **theme system** that can swap them at runtime. Audit the architecture, not just the values.

- [ ] **Three modes minimum**: `light`, `dark`, and `system` (follows OS preference). The system mode is the default for new users — explicit choice overrides it. Single-mode projects (dark-only, light-only) are acceptable **only** with a documented justification in `BRANDING.md` (e.g., "terminal product, dark-only by brand"). Absence of justification = violation.
- [ ] **Centralized preference module**: a single source of truth (`theme_preference.{ts,dart,kt,...}`) that exposes the current mode, normalizes incoming values (any unknown value → `system`, never crash), and emits change events. Scattered `localStorage.getItem('theme')` reads across components = violation.
- [ ] **Persistence**: the preference is persisted in platform-native local storage (`localStorage`, `SharedPreferences`, `UserDefaults`, `chrome.storage`).
- [ ] **Server sync if auth present**: if the project has authentication (see context block — auth detection), the theme preference must also be synced to the user's server-side settings, so the choice follows the user across devices. Local-only persistence with auth = violation. **No auth = local persistence is sufficient.**
- [ ] **Loaded before first render**: the theme is resolved and applied **before** the first paint, no flash of wrong theme (FOUC). Web: inline `<script>` in `<head>` reads localStorage and sets `data-theme` on `<html>` before stylesheets compute. SSR: read cookie or header. Native: read preference synchronously in app bootstrap.
- [ ] **`prefers-color-scheme` honored at first render** for new users with no stored preference (fallback before they choose).
- [ ] **User-facing selector in settings UI**: a dedicated section (`Appearance`, `Apparence`, `Display`) exposing `Light / Dark / System` choice. Hidden behind a debug menu = violation; this is a user-level preference, not a developer toggle.
- [ ] **Each token has a value per mode**: every color/surface/elevation token used in the app is defined for **every** declared mode. A token defined only for light → undefined behavior in dark = violation.
- [ ] **No mode-specific code branches in components**: components reference tokens, never `if (isDark) ...` to swap colors. Branching belongs in the token layer, not in business code.

#### 12. Spacing System
- [ ] **Centralized spacing scale**: all margins, paddings, gaps, and positioning offsets resolve to tokens (`var(--space-*)`, `theme.spacing.*`, `EdgeInsets.fromLTRB(theme.spacing.lg, ...)`). Literal `padding: 12px` in components = violation. Acceptable exceptions: `0`, `1px` borders, hairlines.
- [ ] **Coherent ratio**: the spacing scale follows a recognizable progression (most common: 4px base → 4, 8, 12, 16, 24, 32, 48, 64, 96; or 8px base → 8, 16, 24, 32, 48, 64, 96, 128; or modular `1.5×`). Random ratios (`5px`, `13px`, `27px`) = violation.
- [ ] **Naming strategy adapted to project size** (same rule as typography):
  - Small projects → t-shirt naming (`xs`, `sm`, `md`, `lg`, `xl`, `2xl`, `3xl`)
  - Larger projects → semantic naming (`gutter`, `stack-tight`, `stack-loose`, `inset-card`, `section`)
  - Mixed naming = violation
- [ ] **Fluid spacing for layout-level tokens**: section padding, container insets, hero whitespace benefit from `clamp()` (same accessibility rules as typography: `rem`-based, moderate `vw`). Component-level spacing (button padding, icon gap) stays static — fluid spacing inside components creates visual instability.
- [ ] **No magic numbers in component padding/margin**: if you write `padding: 14px`, the question is "why not the nearest token?". Either the scale needs a new token, or the component needs to use an existing one. Never invent one-off values.

#### 13. Motion System
- [ ] **Centralized durations & easings**: all `transition-duration`, `animation-duration`, and easing curves resolve to tokens (`var(--duration-fast)`, `var(--ease-out-quart)`). Literal `transition: 200ms ease` in a component = violation.
- [ ] **Semantic naming**: motion tokens are named by intent, not by value. ✅ `duration-instant` (50ms), `duration-fast` (150ms), `duration-base` (250ms), `duration-slow` (400ms), `duration-deliberate` (600ms). ❌ `duration-200ms`, `ms-md`. Same logic as colors: name the role, not the literal.
- [ ] **Easing tokens**: at minimum `ease-out-standard` (entrances), `ease-in-standard` (exits), `ease-in-out-standard` (move/morph). Avoid CSS keywords (`ease`, `ease-in-out`) — they're reserved for prototypes; production needs explicit cubic-béziers.
- [ ] **`prefers-reduced-motion` honored systematically**: every non-trivial animation/transition is wrapped in `@media (prefers-reduced-motion: no-preference)` or short-circuited at the source (a `motion()` helper that returns `0ms` when the user opts out). Decorative parallax, scroll-driven animations, autoplay carousels → must respect the OS preference. Required animations (loading spinners, focus outlines) can stay but should be minimal.
- [ ] **Compositor-only properties for performance**: animations target `transform`, `opacity`, `filter` only. Animating `width`, `height`, `top`, `left`, `margin` triggers layout on every frame — flag as performance violation.
- [ ] **Motion intent matters**: each animation answers "what is the user being told?". Feedback (button press), guidance (modal entrance), confirmation (success toast). Decorative motion without intent = noise → flag.

### Step 3: Fix what you can

For each issue rated B or worse:
1. Explain the problem with the specific line/component.
2. **"Why it matters"** — cite the UX principle or standard behind the issue (e.g., "WCAG 2.5.8 target size", "NN/g #1 visibility of system status", "Fitts's law"). One sentence, not a lecture.
3. Fix it directly in the code.
4. If a fix requires a design decision (e.g., color choice), propose 2 options and ask the user.

### Step 4: Report

```
DESIGN REVIEW: [page name]
─────────────────────────────────────
Business metadata:
  BUSINESS.md    artifact_version=[x|missing] status=[x|missing] updated=[date|missing] confidence=[x|missing]
  BRANDING.md    artifact_version=[x|missing] status=[x|missing] updated=[date|missing] confidence=[x|missing]
  GUIDELINES.md  artifact_version=[x|missing] status=[x|missing] updated=[date|missing] confidence=[x|missing]
Visual Hierarchy   [A/B/C/D] — one-line summary
Typography         [A/B/C/D] — one-line summary (incl. design token system)
Color & Contrast   [A/B/C/D] — one-line summary (incl. semantic palette)
Responsiveness     [A/B/C/D] — one-line summary
Consistency        [A/B/C/D] — one-line summary
Accessibility      [A/B/C/D] — one-line summary
Usability (NN/g)   [A/B/C/D] — one-line summary
Modern Patterns    [A/B/C/D] — one-line summary
Modern CSS 2026    [A/B/C/D] — container queries, :has, view transitions, oklch
AI-Gen Smells      [A/B/C/D] — Tailwind conflicts, missing states, div-as-button
─────────────────────────────────────
DESIGN TOKEN SYSTEM
Theme Architecture [A/B/C/D] — modes, persistence, sync, settings UI
Spacing System     [A/B/C/D] — centralization, scale coherence, naming
Motion System      [A/B/C/D] — tokens, prefers-reduced-motion, perf
─────────────────────────────────────
OVERALL            [A/B/C/D]

PRIORITY IMPROVEMENTS (high impact, bounded effort)
  ⚡ [file:line] description — Why: [principle]
  ⚡ [file:line] description — Why: [principle]
  ...

Fixed: X issues | Remaining: Y issues
```

**Priority improvement criteria**: bounded changes that fix a B-level or worse issue without requiring a full redesign. Examples: darkening a hex for contrast, adding `alt` text, bumping a target size, adding `prefers-reduced-motion`. List max 5, ordered by impact.

---

## PROJECT MODE

### Workspace root detection

If the current directory has no project markers (no `package.json`, no `src/` dir, no `tailwind.config.*`) BUT contains multiple project subdirectories — you are at the **workspace root**, not inside a project.

Use **AskUserQuestion**:
- Question: "You're at the workspace root. Which project(s) should I audit for design?"
- `multiSelect: true`
- Options:
  - **All projects** — "Run design audit across every UI project" (Recommended)
  - One option per UI project from `${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}/PROJECTS.md`: label = project name, description = stack

Then proceed to **GLOBAL MODE** with the selected projects.

### Phase 1: Design System Inventory

Read the global styles, framework config (Tailwind, theme files), and 5-10 representative components. Document the **four design token systems** and report their state:

1. **Color & semantic palette**:
   - List all colors actually used (Tailwind classes + custom + raw hex/rgb/hsl/oklch).
   - Flag inconsistencies (e.g., `text-gray-600` AND `text-gray-500` for similar purposes).
   - **Verify the universal semantic socle is present**: `success`, `warning`, `danger`, `info`, `neutral` (or equivalent). Missing = violation.
   - **Verify surface tokens are present**: `surface-base`, `surface-raised`, `surface-overlay`, `surface-sunken` (or equivalent).
   - Flag any hue-based names in component code (`bg-blue-500`, `Color(0xFFFF0000)`, `text-orange-600` in business components).
   - Verify each semantic token has a value for **every** declared theme mode (light + dark + any custom).

2. **Theme system architecture**:
   - Identify the theme preference module (look at context block "Theme files" + "Theme mode preference").
   - Verify the three modes: `light`, `dark`, `system`. Single-mode = OK only if `BRANDING.md` documents the choice.
   - Verify normalization (unknown values fall back to `system`, never crash).
   - Verify persistence layer (localStorage / SharedPreferences / UserDefaults).
   - Verify server sync if auth detected (see context block "Auth detected").
   - Verify FOUC prevention (theme resolved before first paint — inline script in `<head>`, SSR cookie, or native sync bootstrap).
   - Verify the user-facing selector exists in settings UI (Light / Dark / System).

3. **Typography design token system**:
   - List all font sizes, weights, and line heights in use. Flag violations of the scale.
   - **Centralization**: report the count of literal `font-size` values in components vs token references (see context block).
   - **Naming strategy**: detect t-shirt vs semantic. Recommend semantic if project has > ~30 component files or is multi-product.
   - **Token bundle**: check that each typography token bundles `font-size` + `line-height` + `letter-spacing`. Isolated `font-size` tokens = violation.
   - **Modular ratio**: compute the ratios between consecutive tokens. If chaotic (e.g., `1.1×`, `1.4×`, `1.2×`), recommend regenerating with [Utopia.fyi](https://utopia.fyi) — base + ratio + viewport range produce a coherent scale.
   - **Fluid typography audit**: check if headings/hero text use `clamp()` for smooth viewport scaling. Verify clamp values use `rem` (not `px`), and the preferred value combines `rem + vw` (with `vw` ≤ ~3vw, never dominant). Formula: `slope = (max-size - min-size) / (max-vw - min-vw)`, `intercept = min-size - (min-vw × slope)`, then `clamp(min-size, intercept-rem + slope×100vw, max-size)`.

4. **Spacing design token system**:
   - List all spacing values used. Detect literal `padding`/`margin`/`gap` in component files (see context block).
   - **Coherent ratio**: report the scale (4px-base, 8px-base, modular). Flag random values.
   - **Naming strategy**: t-shirt for small projects, semantic (`gutter`, `stack-tight`, `inset-card`) for larger ones. Mixed = violation.
   - **Fluid spacing**: check if layout-level tokens (sections, hero) use `clamp()`. Component-level spacing should stay static.

5. **Motion design token system**:
   - List all `transition`/`animation` declarations (see context block).
   - **Centralization**: report the count of literal durations/easings vs token references.
   - **Semantic naming**: tokens named by intent (`duration-fast`, `ease-out-standard`), not by value (`duration-200ms`).
   - **`prefers-reduced-motion`**: check support count (see context block). Should be present in every non-trivial animation block.
   - **Compositor-only**: flag any animation targeting `width`, `height`, `top`, `left`, `margin` (layout-triggering).

6. **Component patterns**: Identify repeated patterns (cards, buttons, sections). Flag inconsistencies between instances.
7. **Breakpoint usage**: Check if responsive breakpoints are consistent.

### Phase 2: Outdated Patterns Scan

Search the entire codebase for legacy/outdated patterns:

**JavaScript browser dialogs**:
- [ ] `alert(` — replace with toast/notification component
- [ ] `confirm(` — replace with modal dialog component
- [ ] `prompt(` — replace with form input/modal
- [ ] `document.write(` — never acceptable

**Outdated UI patterns**:
- [ ] `<marquee>`, `<blink>`, `<center>`, `<font>` tags
- [ ] `<table>` used for layout (tables only for tabular data)
- [ ] Inline `onclick="..."` handlers
- [ ] `<iframe>` for layout purposes (embeds like YouTube/maps are fine)

**Deprecated CSS patterns**:
- [ ] `!important` overuse (more than 2-3 instances is a red flag)
- [ ] Vendor prefixes without autoprefixer
- [ ] Fixed pixel font sizes below `14px` for body text
- [ ] `float` used for primary layout (use flexbox/grid)
- [ ] Media-query font-size stepping — multiple `@media` blocks that only change `font-size` at breakpoints. Replace with `clamp(MIN, PREFERRED, MAX)` for smooth scaling. Use `rem`-based values (not `px`) to respect user zoom preferences
- [ ] `clamp()` with `px` units — flag `clamp(Xpx, ...)` patterns; should use `rem` so font scales with user browser settings
- [ ] `clamp()` with pure `vw` preferred value — e.g., `clamp(1rem, 4vw, 2rem)` ignores user font-size; preferred value must combine `rem + vw` (e.g., `0.5rem + 2vw`)
- [ ] `hex`/`hsl` in tokens where `oklch()` would be better (perceptual uniformity)
- [ ] `@media` queries responding to viewport where `@container` would respond to actual component space
- [ ] `<div role="dialog">` where native `<dialog>` would work
- [ ] JS-toggled parent classes for child-state styling (replaceable by `:has()`)

**Legacy JS patterns**:
- [ ] jQuery when using a modern framework
- [ ] `innerHTML` for user-facing content
- [ ] `setTimeout`/`setInterval` for UI state

**Undersized click targets & action propagation**:

Look for containers where a small child element (icon button, hamburger, link, toggle) is the sole interactive element but the parent is not clickable. Flag when: container has descriptive content + exactly one primary action + container is NOT already interactive. Fix: propagate action to parent with `onClick`, `role="button"`, `tabIndex={0}`, `cursor-pointer` + hover state. Do NOT propagate when: multiple competing actions, destructive action, drag surface, or form controls.

### Phase 2.5: Modern CSS Adoption Check

Scan the codebase for modern CSS opportunities:

- [ ] **Container queries**: do multi-context components (cards, sidebars) use `@container`? If not, flag — they'll break in nested layouts
- [ ] **`:has()` adoption**: any `useEffect` toggling parent classes based on child state that could be replaced by `:has()`?
- [ ] **View Transitions**: is the project on a framework supporting cross-document transitions (Astro, Next 15+)? Is `@view-transition { navigation: auto }` enabled?
- [ ] **OKLCH tokens**: are design tokens in `oklch()`? If `hsl()` or `hex`, flag (perceptual uniformity benefit)
- [ ] **`light-dark()` + `color-scheme`**: is dark mode implemented via `light-dark()` or via duplicated `@media (prefers-color-scheme: dark)` blocks?
- [ ] **Native `<dialog>` + `popover`**: are modals using `<dialog>` or `<div role="dialog">`? Are tooltips/menus using Floating UI or native `popover`?
- [ ] **Subgrid**: any sibling card grids with alignment issues? Subgrid fixes them
- [ ] **`content-visibility`**: long lists, footers, off-screen sections — candidates for `content-visibility: auto`
- [ ] **Design Tokens DTCG format**: if the project has a token file, does it use DTCG (`$value`, `$type`, `$description`)? W3C DTCG reached first stable version Oct 2025

### Phase 2.6: AI-Generated Code Smells Scan

If the project was built with v0, bolt, lovable, Figma Make, or heavy LLM assistance (check git log for AI attribution or rapid generation bursts), scan specifically for:

- [ ] Conflicting Tailwind utilities on same element (grep: `class=".*\bw-\w+\b.*\bw-\w+\b"` etc.)
- [ ] Dynamic Tailwind class concatenation (`` `text-${x}-500` ``)
- [ ] Interactive `<div onClick>` without `role="button"`/`tabIndex`/`onKeyDown`
- [ ] Form inputs with placeholder but no `<label>`
- [ ] Images with no `alt`
- [ ] Missing `:focus-visible`, `:disabled`, loading/error/empty states
- [ ] Hardcoded hex/rgb instead of design tokens
- [ ] Components that render correctly at reference viewport but break at mobile or wide screens

### Phase 2.7: Design Token System Audit

Consolidated audit of the **four design token systems** (theme, typography, spacing, motion). They share the same logic — centralization, semantic naming, single source of truth — so they're audited together. Strictness is **adaptive to project size** (5c rule): small projects still receive professional findings, but the severity reflects blast radius; larger projects get harder blocking findings.

#### Theme System
- [ ] Three modes (`light`, `dark`, `system`) declared and reachable from settings UI. Single-mode requires `BRANDING.md` justification.
- [ ] Centralized preference module exists, normalizes unknown values to `system`, exposes change events.
- [ ] Persisted to platform-native local storage.
- [ ] If auth detected (see context block) → preference also synced to server-side user settings.
- [ ] Theme resolved before first paint (no FOUC). Web: inline script in `<head>`. SSR: cookie/header. Native: sync bootstrap.
- [ ] `prefers-color-scheme` honored at first render for new users with no stored preference.
- [ ] Every token used in the app is defined for **every** mode.
- [ ] Zero `if (isDark)` branches in component code (mode-switching logic belongs in the token layer).

#### Typography Tokens
- [ ] Zero literal `font-size` in components (count from context block; threshold = adaptive to project size).
- [ ] Each token bundles `font-size` + `line-height` + `letter-spacing` (object or co-named CSS variables).
- [ ] Naming strategy is **consistent** across the project: t-shirt OR semantic, not mixed. Recommend semantic if project has > ~30 component files or is multi-product.
- [ ] Scale follows a coherent modular ratio (1.125, 1.2, 1.25, 1.333, 1.414, 1.5, 1.618). If chaotic, recommend regeneration with [Utopia.fyi](https://utopia.fyi).
- [ ] Fluid `clamp()` used for headings and hero text. Format: `clamp(MIN_REM, X_REM + Y_VW, MAX_REM)` with `Y ≤ 3`. Pure-`vw` preferred values = WCAG 1.4.4 violation (Resize Text fails at 200% zoom).

#### Spacing Tokens
- [ ] Zero literal margin/padding/gap in components (count from context block; threshold = adaptive to project size). Acceptable exceptions: `0`, `1px` borders.
- [ ] Coherent scale (4px-base, 8px-base, modular). No magic numbers (`13px`, `27px`).
- [ ] Naming strategy is **consistent**: t-shirt for small projects, semantic (`gutter`, `stack-tight`, `inset-card`, `section`) for larger. Mixed = violation.
- [ ] Layout-level spacing (sections, hero, container insets) uses `clamp()` for fluid behavior. Component-level spacing stays static.

#### Motion Tokens
- [ ] Zero literal `transition`/`animation` durations or easings in components (count from context block).
- [ ] Tokens named by intent (`duration-fast`, `ease-out-standard`), not by value.
- [ ] Easing tokens use explicit cubic-béziers, not CSS keywords (`ease`, `ease-in-out`).
- [ ] `prefers-reduced-motion` support count > 0 (see context block). Every non-trivial animation respects it. Decorative motion (parallax, autoplay carousels, scroll-driven) must opt out under reduced motion.
- [ ] Animations target `transform`, `opacity`, `filter` only. Animating `width`, `height`, `top`, `left`, `margin` triggers layout = perf violation.
- [ ] Each animation has an intent (feedback, guidance, confirmation). Decorative motion without intent = noise.

#### Severity rules (adaptive to project size — 5c)
- **Small project** (< ~10 component files, content site, single product) → token findings are generally prioritized as 🟡 medium unless user impact or brand trust is directly harmed. Keep the quality bar, adjust priority to blast radius.
- **Mid project** (~10-30 component files) → token findings are generally prioritized as 🟠 high. The system is starting to leak; centralize before it grows.
- **Large project** (> ~30 component files, SaaS, multi-product) → token violations are 🔴 critical. At this scale, drift compounds fast.

#### Priority recommendation
If the project has any design token system worth auditing **and** no design playground page detected (see context block "Design playground page"), append this to priority improvements:
```
⚡ No design system playground detected — run /sf-design-playground to scaffold a live design token preview page.
   Why: visualizing all tokens in one place + live editing is the fastest way to iterate on the design system without opening 30 files.
```

### Phase 3: Page-by-Page Scan

For each page, check:
- [ ] Visual hierarchy
- [ ] Design system consistency
- [ ] Responsive behavior
- [ ] Accessibility (contrast, alt text, focus states, ARIA, WCAG 2.2 criteria)
- [ ] Usability — NN/g heuristics (system status, error recovery, recognition vs recall, etc.)
- [ ] Click targets
- [ ] States: loading, empty, error
- [ ] No layout shifts
- [ ] INP < 200ms on interactions (p75)

For each finding, include a **"Why it matters"** line citing the relevant UX principle or standard.

### Phase 4: Cross-Page Consistency

- [ ] Header/footer identical across pages
- [ ] Navigation active states work correctly
- [ ] Consistent card/list treatment across content types
- [ ] Consistent spacing between sections
- [ ] Favicon, apple-touch-icon, and theme-color present

### Phase 5: Fix

Fix all issues directly in code. Prioritize:
1. **Accessibility violations** (legal risk + user impact)
2. **Design system inconsistencies** (fix in components, not per-page)
3. **Responsive breakages** (mobile-first)
4. **Missing states** (loading/error/empty)

### Phase 6: Report

```
DESIGN AUDIT: [project name]
═══════════════════════════════════════

BUSINESS METADATA VERSIONS
  BUSINESS.md    artifact_version=[x|missing] status=[x|missing] updated=[date|missing] confidence=[x|missing] next_review=[date|missing]
  BRANDING.md    artifact_version=[x|missing] status=[x|missing] updated=[date|missing] confidence=[x|missing] next_review=[date|missing]
  GUIDELINES.md  artifact_version=[x|missing] status=[x|missing] updated=[date|missing] confidence=[x|missing] next_review=[date|missing]
  Proof gaps: [missing/stale/unversioned docs that affected scoring, or none]

DESIGN SYSTEM HEALTH
  Colors:     X tokens used, Y inconsistencies
  Typography: X sizes used, Y violations
  Spacing:    [consistent / mixed / chaotic]
  Components: X patterns, Y inconsistencies

DESIGN TOKEN SYSTEM
  Theme architecture:
    Modes:           [light + dark + system / single — justified / single — UNJUSTIFIED]
    Preference:      [centralized + normalized / scattered / missing]
    Persistence:     [present / missing]
    Server sync:     [yes — auth detected / N/A — no auth / MISSING — auth present but no sync]
    FOUC prevention: [yes / no — flash of wrong theme]
    Settings UI:     [present / missing]
  Typography tokens:
    Centralization:  X literal font-sizes outside tokens (target: 0)
    Naming:          [t-shirt / semantic / MIXED]
    Bundle:          [size+lh+ls bundled / font-size only]
    Scale ratio:     [coherent (1.X×) / chaotic — recommend Utopia.fyi]
    Fluid clamp():   [adopted / partial / absent / vw-dominant — WCAG risk]
  Spacing tokens:
    Centralization:  X literal margin/padding outside tokens
    Naming:          [t-shirt / semantic / MIXED]
    Scale ratio:     [4px-base / 8px-base / modular / chaotic]
    Fluid layout:    [adopted / static-only]
  Motion tokens:
    Centralization:  X literal transition/animation outside tokens
    Naming:          [semantic / by-value / MIXED]
    Reduced motion:  X declarations (target: every non-trivial animation)
    Compositor-only: [yes / NO — animates layout properties]
  Universal palette socle:
    Semantic intents: [success/warning/danger/info/neutral all present / X missing]
    Surface tokens:   [base/raised/overlay/sunken / X missing]
    Hue-based names in components: X violations
  Design playground page: [present / ABSENT — recommend /sf-design-playground]

OUTDATED PATTERNS
  Browser dialogs:  X found
  Legacy HTML:      X found
  Deprecated CSS:   X found
  Legacy JS:        X found
  Click targets:    X containers with undersized single-action children
  div[role=dialog]: X (should be native <dialog>)

MODERN CSS ADOPTION
  Container queries: [adopted / partial / absent]
  :has() usage:      [adopted / partial / absent]
  View Transitions:  [enabled / disabled]
  OKLCH tokens:      [yes / no — uses hex/hsl]
  light-dark():      [yes / no — uses duplicated media queries]
  Native dialog:     X modals / Y with role=dialog
  Popover API:       [yes / no — uses Floating UI]

AI-GEN CODE SMELLS (if applicable)
  Tailwind conflicts:  X
  Dynamic classes:     X
  div-as-button:       X
  Missing labels/alts: X
  Missing states:      X

PAGE SCORES
  /                  [A/B/C/D]
  /about             [A/B/C/D]
  ...

CROSS-PAGE CONSISTENCY    [A/B/C/D]
ACCESSIBILITY (WCAG 2.2)  [A/B/C/D]
USABILITY (NN/g)          [A/B/C/D]
RESPONSIVENESS            [A/B/C/D]
MODERN CSS 2026           [A/B/C/D]
AI-GEN CODE HEALTH        [A/B/C/D] (if applicable)
THEME ARCHITECTURE        [A/B/C/D]
TYPOGRAPHY TOKENS         [A/B/C/D]
SPACING TOKENS            [A/B/C/D]
MOTION TOKENS             [A/B/C/D]
═══════════════════════════════════════
OVERALL                   [A/B/C/D]

PRIORITY IMPROVEMENTS (high impact, bounded effort)
  ⚡ [file:line] description — Why: [principle]
  ⚡ [file:line] description — Why: [principle]
  ... (max 5, ordered by impact)
  ⚡ Run /sf-design-playground to scaffold a live design token preview page
     (auto-included if no design playground detected and project has any design token system)

Fixed: X issues across Y files
Needs decision: Z items (listed below)
```

---

## Tracking (all modes)

Shared file write protocol for `AUDIT_LOG.md` and `TASKS.md`:
- Treat the snapshots loaded at skill start as informational only.
- Right before each write, re-read the target file from disk and use that version as authoritative.
- Append or replace only the intended row or subsection; never rewrite the whole file from stale context.
- If the expected anchor moved or changed, re-read once and recompute.
- If it is still ambiguous after the second read, stop and ask the user instead of forcing the write.

After generating the report and applying fixes:

### Log the audit

Append a row to two files:

1. **Global `${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}/AUDIT_LOG.md`**: append a row filling only the Design column, `—` for others.
2. **Project-local `./AUDIT_LOG.md`**: same without the Project column.

Create either file if missing.

### Update TASKS.md

1. **Local TASKS.md** (project root): add/replace an `### Audit: Design` subsection with critical (🔴), high (🟠), and medium (🟡) issues as task rows.
2. **Master `${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}/TASKS.md`**: find the project's section, add/replace an `### Audit: Design` subsection with the same tasks. Update the Dashboard "Top Priority" if critical issues found.

---

## Important (all modes)

- Be ruthlessly honest. A-level means genuinely production-ready, not "it works".
- When the project has a design system or Tailwind config, enforce its tokens — don't introduce new arbitrary values.
- Respect the project's existing aesthetic. Improve, don't redesign.
- If the project content is in French, review in that language context (French text is ~15% longer than English).
- **All `<textarea>` elements MUST use `field-sizing: content`** — flag and fix any textarea missing this property.
- In project mode, identify **systemic** problems and fix at the source (component/config level), not per-page.
