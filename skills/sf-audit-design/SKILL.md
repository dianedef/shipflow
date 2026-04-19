---
name: sf-audit-design
description: Professional UI/UX design audit (NN/g heuristics, WCAG 2.2, visual hierarchy) — single page, full project, or global
disable-model-invocation: true
argument-hint: [file-path | "global"] (omit for full project)
---

## Context

- Current directory: !`pwd`
- Project CLAUDE.md: !`head -100 CLAUDE.md 2>/dev/null || echo "no CLAUDE.md"`
- Brand voice: !`head -60 BRANDING.md 2>/dev/null || echo "no BRANDING.md — run /sf-init to generate"`
- Tailwind/CSS config: !`cat tailwind.config.* 2>/dev/null | head -80 || echo "no tailwind config"`
- Global styles: !`cat src/styles/global.css 2>/dev/null || cat src/assets/styles/*.css 2>/dev/null | head -100 || echo "no global styles found"`
- All pages: !`find src/pages src/app -name "*.astro" -o -name "*.tsx" -o -name "*.vue" 2>/dev/null | grep -v node_modules | sort`
- Component files: !`find src/components -name "*.astro" -o -name "*.tsx" -o -name "*.vue" 2>/dev/null | grep -v node_modules | sort`
- Legacy patterns: !`grep -rn --include="*.{js,ts,jsx,tsx,astro,vue}" -E '\balert\(|\bconfirm\(|\bprompt\(|\bdocument\.write\(' src/ 2>/dev/null | head -20 || echo "none found"`
- Deprecated HTML: !`grep -rn --include="*.{astro,vue,tsx,jsx,html}" -iE '<marquee|<blink|<center|<font ' src/ 2>/dev/null | head -20 || echo "none found"`
- Dialog vs div[role=dialog]: !`grep -rn --include="*.{astro,vue,tsx,jsx,html}" -E '<div[^>]+role=["\x27]dialog' src/ 2>/dev/null | head -10 || echo "none found"`
- Hardcoded colors: !`grep -rn --include="*.{astro,vue,tsx,jsx,css,scss}" -E '#[0-9a-fA-F]{3,6}\b|rgb\(|rgba\(' src/ 2>/dev/null | grep -v node_modules | wc -l || echo "0"`

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

## Mode detection

- **`$ARGUMENTS` is "global"** → GLOBAL MODE: audit ALL projects in the workspace.
- **`$ARGUMENTS` is a file path** → PAGE MODE: review that single page.
- **`$ARGUMENTS` is empty** → PROJECT MODE: full design audit of the entire project.

---

## GLOBAL MODE

Audit ALL UI projects in the workspace for design, UX, and accessibility issues.

1. Read `/home/claude/shipflow_data/PROJECTS.md` — check the **Domain Applicability** table. Identify projects with ✓ in the Design column.

2. Use **AskUserQuestion** to let the user choose:
   - Question: "Which projects should I audit for design & UX?"
   - `multiSelect: true`
   - One option per applicable project: label = project name, description = stack from PROJECTS.md
   - All applicable projects pre-listed as options

3. Use the **Task tool** to launch one agent per **selected** project — ALL IN A SINGLE MESSAGE (parallel). Each agent: `subagent_type: "general-purpose"`.

   Agent prompt must include:
   - `cd [path]` then read `CLAUDE.md` for project context
   - The complete **PROJECT MODE** section from this skill (all 6 phases: Design System Inventory → Outdated Patterns Scan → Page-by-Page Scan → Cross-Page Consistency → Fix → Report)
   - The **Tracking** section from this skill
   - Rule: **read-only analysis** — no code fixes, only update AUDIT_LOG.md and TASKS.md

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
   QUICK WINS ACROSS PROJECTS
     ⚡ [project] file:line — description — Why: [principle]
     ... (max 10, ordered by impact)
   Total: X critical, Y high, Z medium across N projects
   ═══════════════════════════════════════
   ```

5. Update `/home/claude/shipflow_data/AUDIT_LOG.md` (one row per project, Design column) and `/home/claude/shipflow_data/TASKS.md` (each project's `### Audit: Design` subsection).

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

#### 3. Color & Contrast
- [ ] WCAG AA contrast ratios (4.5:1 text, 3:1 large text/UI). Note: WCAG 3.0 draft uses APCA (perceptual) — check both when time allows
- [ ] Color is not the only way to convey information
- [ ] Consistent color token usage (no hardcoded hex outside design system) — prefer `oklch()` (perceptually uniform) over `hsl()`/`hex`
- [ ] Hover/tint/shade variants use `color-mix(in oklch, var(--brand) 70%, white)` rather than hand-picked hex — one token change re-derives the palette
- [ ] `color-mix()` declarations have a static fallback line above them (old browsers drop the whole rule otherwise)
- [ ] Interactive elements have visible focus/hover/active states
- [ ] Dark mode: `<meta name="color-scheme" content="light dark">` + root `color-scheme: light dark` + CSS uses `light-dark(<light>, <dark>)` — eliminates `@media (prefers-color-scheme: dark)` duplication

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
Visual Hierarchy   [A/B/C/D] — one-line summary
Typography         [A/B/C/D] — one-line summary
Color & Contrast   [A/B/C/D] — one-line summary
Responsiveness     [A/B/C/D] — one-line summary
Consistency        [A/B/C/D] — one-line summary
Accessibility      [A/B/C/D] — one-line summary
Usability (NN/g)   [A/B/C/D] — one-line summary
Modern Patterns    [A/B/C/D] — one-line summary
Modern CSS 2026    [A/B/C/D] — container queries, :has, view transitions, oklch
AI-Gen Smells      [A/B/C/D] — Tailwind conflicts, missing states, div-as-button
─────────────────────────────────────
OVERALL            [A/B/C/D]

QUICK WINS (high impact, low effort)
  ⚡ [file:line] description — Why: [principle]
  ⚡ [file:line] description — Why: [principle]
  ...

Fixed: X issues | Remaining: Y issues
```

**Quick Wins criteria**: changes that take < 5 min each, touch 1-2 lines, and fix a B-level or worse issue. Examples: darkening a hex for contrast, adding `alt` text, bumping a target size, adding `prefers-reduced-motion`. List max 5, ordered by impact.

---

## PROJECT MODE

### Workspace root detection

If the current directory has no project markers (no `package.json`, no `src/` dir, no `tailwind.config.*`) BUT contains multiple project subdirectories — you are at the **workspace root**, not inside a project.

Use **AskUserQuestion**:
- Question: "You're at the workspace root. Which project(s) should I audit for design?"
- `multiSelect: true`
- Options:
  - **All projects** — "Run design audit across every UI project" (Recommended)
  - One option per UI project from `/home/claude/shipflow_data/PROJECTS.md`: label = project name, description = stack

Then proceed to **GLOBAL MODE** with the selected projects.

### Phase 1: Design System Inventory

Read the Tailwind config, global styles, and 5-10 representative components. Document:

1. **Color palette**: List all colors actually used (Tailwind classes + custom). Flag inconsistencies (e.g., `text-gray-600` AND `text-gray-500` for similar purposes).
2. **Typography scale**: List all font sizes, weights, and line heights in use. Flag violations of the scale.
   - **Fluid typography audit**: Check if headings/hero text use `clamp()` for smooth viewport scaling. If the project uses media-query stepping (different font-size at each breakpoint), flag as improvable — `clamp(MIN, calc-value, MAX)` provides smoother scaling in one declaration. Verify clamp values use `rem` (not `px`) so user zoom/font-size preferences are preserved. The preferred (middle) value should be `rem + vw` (e.g., `0.5rem + 2.27vw`), never pure `vw`. Formula to calculate: `slope = (max-size - min-size) / (max-vw - min-vw)`, `intercept = min-size - (min-vw × slope)`, then `clamp(min-size, intercept-rem + slope×100vw, max-size)`.
3. **Spacing system**: Check if spacing is consistent (Tailwind scale) or has arbitrary values.
4. **Component patterns**: Identify repeated patterns (cards, buttons, sections). Flag inconsistencies between instances.
5. **Breakpoint usage**: Check if responsive breakpoints are consistent.

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

DESIGN SYSTEM HEALTH
  Colors:     X tokens used, Y inconsistencies
  Typography: X sizes used, Y violations
  Spacing:    [consistent / mixed / chaotic]
  Components: X patterns, Y inconsistencies

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
═══════════════════════════════════════
OVERALL                   [A/B/C/D]

QUICK WINS (high impact, low effort)
  ⚡ [file:line] description — Why: [principle]
  ⚡ [file:line] description — Why: [principle]
  ... (max 5, ordered by impact)

Fixed: X issues across Y files
Needs decision: Z items (listed below)
```

---

## Tracking (all modes)

After generating the report and applying fixes:

### Log the audit

Append a row to two files:

1. **Global `/home/claude/shipflow_data/AUDIT_LOG.md`**: append a row filling only the Design column, `—` for others.
2. **Project-local `./AUDIT_LOG.md`**: same without the Project column.

Create either file if missing.

### Update TASKS.md

1. **Local TASKS.md** (project root): add/replace an `### Audit: Design` subsection with critical (🔴), high (🟠), and medium (🟡) issues as task rows.
2. **Master `/home/claude/shipflow_data/TASKS.md`**: find the project's section, add/replace an `### Audit: Design` subsection with the same tasks. Update the Dashboard "Top Priority" if critical issues found.

---

## Important (all modes)

- Be ruthlessly honest. A-level means genuinely production-ready, not "it works".
- When the project has a design system or Tailwind config, enforce its tokens — don't introduce new arbitrary values.
- Respect the project's existing aesthetic. Improve, don't redesign.
- If the project content is in French, review in that language context (French text is ~15% longer than English).
- **All `<textarea>` elements MUST use `field-sizing: content`** — flag and fix any textarea missing this property.
- In project mode, identify **systemic** problems and fix at the source (component/config level), not per-page.
