---
name: sf-audit-design-tokens
description: "Args: file-path or \"global\"; omit for full project. Deep specialist audit of the 4 design token systems (theme + typography + spacing + motion) — token coverage matrix per mode, modular ratio analysis, dependency graph, historical drift, DTCG compliance. Called by sf-audit-design in deep mode, or run standalone."
disable-model-invocation: true
argument-hint: '[file-path | "global"] (omit for full project)'
---

## Canonical Paths

Before resolving any ShipFlow-owned file, load `$SHIPFLOW_ROOT/skills/references/canonical-paths.md` (`$SHIPFLOW_ROOT` defaults to `/home/claude/shipflow`). ShipFlow tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPFLOW_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Chantier Tracking

Category: `conditionnel`.

Before producing the final report, load `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md` when this run is attached to a spec-first chantier. If exactly one active `specs/*.md` chantier is identified, append the current run to `Skill Run History`, update `Current Chantier Flow` when the run changes the chantier state, and include a final `Chantier` block. If no unique chantier is identified, do not write to any spec; report `Chantier: non applicable` or `Chantier: non trace` with the reason.


## Context

- Current directory: !`pwd`
- Project CLAUDE.md: !`head -60 CLAUDE.md 2>/dev/null || echo "no CLAUDE.md"`
- Brand voice: !`head -40 BRANDING.md 2>/dev/null || echo "no BRANDING.md"`
- Tailwind config: !`cat tailwind.config.* 2>/dev/null | head -100 || echo "no tailwind config"`
- Global styles: !`cat src/styles/global.css src/styles/globals.css src/assets/styles/global.css 2>/dev/null | head -150 || echo "no global styles"`
- Token files detected: !`find . -type f \( -name "tokens*" -o -name "theme*" -o -name "*Theme*" -o -name "design-tokens*" -o -name "palette*" -o -name "_variables*" \) 2>/dev/null | grep -v node_modules | head -20 || echo "none"`
- CSS custom properties (sample): !`grep -rh --include="*.{css,scss}" -E '^\s*--[a-z-]+:' src/ 2>/dev/null | sort -u | head -80 || echo "none found"`
- Literal font-sizes outside tokens: !`grep -rn --include="*.{css,scss,vue,astro,tsx,jsx}" -E 'font-size:\s*[0-9]' src/ 2>/dev/null | grep -v 'var(--' | grep -v node_modules | wc -l || echo "0"`
- Literal spacings outside tokens: !`grep -rn --include="*.{css,scss}" -E '(margin|padding|gap):\s*[0-9]+(\.[0-9]+)?(px|rem|em)' src/ 2>/dev/null | grep -v 'var(--' | grep -v node_modules | wc -l || echo "0"`
- Literal motion outside tokens: !`grep -rn --include="*.{css,scss}" -E '(transition|animation):\s*' src/ 2>/dev/null | grep -v 'var(--' | grep -v node_modules | wc -l || echo "0"`
- Hardcoded colors in components: !`grep -rn --include="*.{astro,vue,tsx,jsx,svelte,dart}" -E '#[0-9a-fA-F]{3,6}\b|rgb\(|rgba\(|oklch\(|Color\(0x' src/ lib/ 2>/dev/null | grep -v node_modules | wc -l || echo "0"`
- Theme mode detection: !`grep -rn --include="*.{ts,tsx,js,jsx,vue,astro,svelte,dart}" -E 'ThemeMode|prefers-color-scheme|color-scheme|themeMode|darkMode' src/ lib/ 2>/dev/null | grep -v node_modules | head -10 || echo "none found"`
- Reduced-motion support count: !`grep -rn --include="*.{css,scss,ts,tsx,js,jsx,vue,astro,svelte}" -E 'prefers-reduced-motion' src/ 2>/dev/null | grep -v node_modules | wc -l || echo "0"`
- Auth detected (theme sync rule): !`grep -rln --include="*.{ts,tsx,js,jsx}" -E "(next-auth|@clerk/|better-auth|@auth/|lucia|@supabase/auth|firebase/auth|getServerSession|useSession|useUser|currentUser)" src/ app/ pages/ 2>/dev/null | grep -v node_modules | head -3 || echo "none — server sync not required"`
- DTCG tokens file: !`find . -type f -name "tokens.json" -o -name "*.tokens.json" 2>/dev/null | grep -v node_modules | head -5 || echo "none"`
- Component files count: !`find src/components src/ui lib/widgets -type f \( -name "*.tsx" -o -name "*.vue" -o -name "*.astro" -o -name "*.svelte" -o -name "*.dart" \) 2>/dev/null | grep -v node_modules | wc -l || echo "0"`
- Git log on token files (drift analysis): !`find . -type f \( -name "tokens*" -o -name "theme*" \) 2>/dev/null | grep -v node_modules | head -3 | xargs -I {} git log --oneline -10 -- {} 2>/dev/null | head -30 || echo "no git history"`

## Pre-check

If no token files detected **and** no CSS custom properties found → the project has no design token system. Abort with:

```
⚠ No design token system detected.

This skill audits EXISTING design token systems. The project appears to use
literal values throughout (hardcoded hex, font-sizes, spacings).

Next steps:
  1. Run /sf-audit-design (light mode) to get the first-pass recommendations
  2. Run /sf-design-playground once a minimal system exists
  3. Re-run /sf-audit-design-tokens for the deep audit
```

---

## Mode detection

- **`$ARGUMENTS` is "global"** → GLOBAL MODE: audit token systems across ALL projects
- **`$ARGUMENTS` is a file path** → FILE MODE: audit the token file(s) at that path
- **`$ARGUMENTS` is empty** → PROJECT MODE: full deep audit

---

## PROJECT MODE

Run all 7 phases sequentially. Each phase produces a sub-score (A/B/C/D) and contributes to the final report.

### Phase 1 — Inventory of the 4 design token systems

Read the token source files (detected in context block) and build a structured inventory:

```
COLOR PALETTE
  Source(s): [list of files]
  Format: [css-vars | tailwind | js-object | DTCG json | hybrid]
  Token count: N
  Universal semantic socle:
    success:  [present (light+dark) / missing in dark / missing entirely]
    warning:  [...]
    danger:   [...]
    info:     [...]
    neutral:  [...]
  Surface tokens:
    surface-base:    [present / missing]
    surface-raised:  [...]
    surface-overlay: [...]
    surface-sunken:  [...]
  Domain-specific intents: [list project-specific tokens beyond the socle]
  Hue-based names in components: N violations (list first 10 files)

TYPOGRAPHY
  Source(s): [files]
  Format: [css-vars | theme object | Flutter TextTheme | hybrid]
  Token count: N
  Naming strategy: [t-shirt | semantic | MIXED — violation]
  Token bundle:
    font-size + line-height + letter-spacing co-located: [yes / partial / no]
  Fluid clamp() usage: [all headings / partial / none]
  Literal font-sizes outside tokens: N (adaptive severity — see Phase 7)

SPACING
  Source(s): [files]
  Format: [css-vars | tailwind scale | theme object | hybrid]
  Token count: N
  Naming strategy: [t-shirt | semantic | MIXED]
  Base unit: [4px | 8px | modular ratio | chaotic]
  Fluid spacing (layout-level): [adopted / static-only]
  Literal spacing outside tokens: N

MOTION
  Source(s): [files]
  Format: [css-vars | tailwind | theme object | hybrid]
  Duration tokens: N  (naming: [semantic | by-value | MIXED])
  Easing tokens: N    (explicit cubic-bezier / CSS keywords)
  Reduced-motion declarations: N (see context block)
  Literal transition/animation outside tokens: N
```

Output this inventory verbatim at the top of the report. Every subsequent phase adds findings.

### Phase 2 — Token coverage matrix (per mode)

For each color/surface token, verify that it is defined for **every** declared theme mode (light, dark, any custom mode like high-contrast).

Generate a matrix:

```
                    light    dark    high-contrast
--color-success     ✓        ✓       ✓
--color-warning     ✓        ✓       ✗  ← UNDEFINED
--surface-raised    ✓        ✗       ✓  ← UNDEFINED in dark
```

Any ✗ = 🟠 high severity (theme breaks silently in that mode). Count total gaps and report.

### Phase 3 — Modular ratio analysis (typography + spacing)

For typography and spacing scales, extract numeric values and compute the ratio between consecutive tokens:

```
TYPOGRAPHY SCALE
--fs-xs    = 0.875rem   ratio → sm: 1.143×
--fs-sm    = 1.000rem   ratio → base: 1.125×
--fs-base  = 1.125rem   ratio → lg: 1.111×
--fs-lg    = 1.250rem   ratio → xl: 1.200×
--fs-xl    = 1.500rem   ratio → 2xl: 1.333×
--fs-2xl   = 2.000rem
```

**Coherence assessment**:
- All ratios within ±0.05 of one canonical value (e.g., 1.125 minor second, 1.2 minor third, 1.25 major third, 1.333 perfect fourth, 1.5 perfect fifth) → **coherent** ✓
- Ratios vary by more than ±0.1 across the scale → **chaotic** ✗ — recommend regenerating with [Utopia.fyi](https://utopia.fyi) using base size + ratio + viewport range
- Partial coherence (3+ tokens follow a ratio, 1-2 outliers) → **inconsistent** ⚠ — flag the outliers

Same analysis for spacing (4px base: 4, 8, 12, 16, 24, 32, 48, 64 — each ratio ~1.5× or 1.33×).

### Phase 4 — Dependency graph

Build a dependency graph of tokens referencing tokens:

```
--color-button-bg: var(--color-brand)
    → --color-brand: oklch(0.6 0.18 250)
--color-button-hover: color-mix(in oklch, var(--color-brand) 90%, black)
    → --color-brand (same as above)
```

Report:
- **Orphan tokens** : defined but referenced nowhere in components or other tokens → candidates for deletion
- **Cycles** : token A references token B which references token A → infinite loop or fallback hell
- **Deep chains** : token references > 3 levels deep → indirection overhead, hard to debug
- **Duplicate intent** : two tokens with different names resolving to the same value → consolidate (e.g., `--color-error` and `--color-danger` both = `oklch(0.55 0.2 25)`)

### Phase 5 — Historical drift (git analysis)

Run `git log --follow --oneline -50 -- <token-files>` and `git log -p -20 -- <token-files>`. Look for:

- **Recent ad-hoc additions** : commits in last 30 days that add tokens without clear justification (no accompanying component change or discussion)
- **Author dispersion** : if 5+ different authors have added tokens in the last 3 months without a clear owner, the system is drifting (no steward)
- **"fix:" commits on tokens** : multiple `fix:` commits on token files = unstable foundation, the system is being reactively patched instead of deliberately designed
- **Token churn** : same token renamed/moved multiple times = naming wasn't locked in → flag for consolidation

Output a brief timeline of the last 10 changes with assessment.

### Phase 6 — DTCG compliance

If the project has a `tokens.json` or similar (see context block), verify compliance with [W3C DTCG spec](https://www.designtokens.org/tr/drafts/format/) (first stable version Oct 2025):

- [ ] Each token has `$value` (mandatory)
- [ ] Each token has `$type` (`color`, `dimension`, `fontFamily`, `fontWeight`, `duration`, `cubicBezier`, etc.)
- [ ] `$description` present for non-trivial tokens
- [ ] Aliases use `{group.subgroup.token}` syntax (curly braces), not `$ref` (old draft)
- [ ] Grouping is semantic (`color.semantic.success` > `color.blue.500`)
- [ ] Modes declared via `$extensions` or dedicated `$schema` version

Projects without DTCG file : skip phase, note in report ("not applicable — no DTCG file").

### Phase 7 — Theme system architecture (deep)

Deep version of the `sf-audit-design #11 Theme System Architecture` checklist, with **measured verifications** instead of yes/no questions:

- [ ] **Modes available** : enumerate by reading the theme preference module. Confirm normalization (read the code, verify unknown values fallback to `system`, not crash)
- [ ] **Persistence verified** : trace from UI selector → preference store. Confirm read-back on reload works (read the code path).
- [ ] **Server sync if auth** : if auth is detected (see context block), grep for `updateUserPreferences`, `settings.theme`, or equivalent. If absent → 🔴 critical (preference doesn't follow the user across devices).
- [ ] **FOUC prevention measured** : check the HTML `<head>` or SSR layout for an inline script that sets `data-theme` before CSS loads. Absent on a client-rendered app = 🟠 high (visible flash for dark-mode users on every reload).
- [ ] **`prefers-color-scheme` honored** : trace first-render path for users with no stored preference. Must read `window.matchMedia('(prefers-color-scheme: dark)')` or equivalent.
- [ ] **Settings UI** : grep for the theme selector component. Must be discoverable (in a primary settings page, not behind a debug flag).
- [ ] **No `if (isDark)` branches in components** : grep `isDark\|isLight\|theme\s*===\s*['\"]dark` in component files. Every hit = violation (mode-switching logic belongs in tokens, not business code).
- [ ] **Single-mode projects** : if only one mode declared, check for `BRANDING.md` justification. Absent = violation.

### Severity rules (adaptive to project size)

Based on the component files count from the context block:

| Project size | Threshold | Max severity for token violations |
|---|---|---|
| Small | < 10 | 🟡 medium (quick-wins) |
| Mid | 10-30 | 🟠 high |
| Large | > 30 | 🔴 critical |

Apply this to all findings. A missing semantic socle in a 5-file demo project = quick-win, not critical. Same missing socle in a 50-file SaaS = critical.

### Final report

```
═══════════════════════════════════════
DESIGN TOKENS AUDIT — [project name]
═══════════════════════════════════════

INVENTORY
  [full inventory block from Phase 1]

SUBSCORES
  Theme Architecture       [A/B/C/D]
  Typography Tokens        [A/B/C/D]
  Spacing Tokens           [A/B/C/D]
  Motion Tokens            [A/B/C/D]
  Universal Palette Socle  [A/B/C/D]
  Ratio Coherence          [A/B/C/D]
  Dependency Health        [A/B/C/D]
  Historical Drift         [A/B/C/D]
  DTCG Compliance          [A/B/C/D | N/A]
───────────────────────────────────────
OVERALL DESIGN TOKENS      [A/B/C/D]

CRITICAL ISSUES (🔴)
  file:line — description — Why: [principle]

HIGH SEVERITY (🟠)
  file:line — description — Why: [principle]

QUICK WINS (⚡)
  file:line — description — Why: [principle]
  ⚡ (if no playground detected) Run /sf-design-playground to scaffold a live token preview page.

Fixed: 0 (this audit is read-only)
Tasks created: X in TASKS.md
═══════════════════════════════════════
```

---

## FILE MODE

If `$ARGUMENTS` is a file path, audit only that token file. Run:
- Phase 1 (limited to that file's tokens)
- Phase 3 (ratio analysis on that file)
- Phase 6 (DTCG compliance if applicable)

Skip Phase 2 (coverage matrix requires all modes), Phase 4 (dep graph requires cross-file), Phase 5 (git log still applies), Phase 7 (theme architecture is project-wide).

---

## GLOBAL MODE

Same pattern as `sf-audit-design` GLOBAL MODE:
1. Read `/home/claude/shipflow_data/PROJECTS.md` Domain Applicability table — identify projects with Design ✓
2. Use **AskUserQuestion** to let the user select projects
3. Launch one agent per selected project via the Task tool, all in a single message (parallel)
4. Each agent: `subagent_type: "general-purpose"`, runs this skill's PROJECT MODE, returns the structured report
5. Compile a cross-project design tokens report with aggregated findings

---

## Tracking (all modes)

Shared file write protocol for `AUDIT_LOG.md` and `TASKS.md`:
- Treat the snapshots loaded at skill start as informational only.
- Right before each write, re-read the target file from disk and use that version as authoritative.
- Append or replace only the intended row or subsection; never rewrite the whole file from stale context.
- If the expected anchor moved or changed, re-read once and recompute.
- If it is still ambiguous after the second read, stop and ask the user instead of forcing the write.

After generating the report:

1. **Project-local `AUDIT_LOG.md`** : append a row for "Design Tokens" audit with date + overall score + critical count
2. **Local `TASKS.md`** : add/replace a `### Audit: Design Tokens` subsection with 🔴🟠🟡 issues as task rows
3. **Master `/home/claude/shipflow_data/TASKS.md`** : find the project's section, add same subsection, update Dashboard Top Priority if 🔴 issues found

---

## Important

- **Read-only audit** : no code fixes, no file rewrites, only report + tasks
- This skill is **called by `sf-audit-design` in deep mode** but can also run standalone via `/sf-audit-design-tokens`
- Cross-platform : web (CSS custom properties, Tailwind, theme objects) + Flutter (`ThemeData`, `TextTheme`, `ColorScheme`) + native (any centralized token approach)
- When auditing a Flutter project: map the concepts (`ThemeData` = theme mode, `TextTheme` = typography tokens, spacing via `EdgeInsets` constants, motion via `Duration`/`Curves` constants) — the audit logic is the same, only the vocabulary differs
- Term to use throughout the report: **"design tokens"**, never just "tokens" (avoid LLM/AI ambiguity)
- Be ruthlessly honest — this is a pro audit, not a pep talk
