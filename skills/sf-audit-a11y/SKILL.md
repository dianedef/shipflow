---
name: sf-audit-a11y
description: "Accessibility audit for WCAG, ARIA, keyboard flow, focus, live regions, and semantics."
disable-model-invocation: true
argument-hint: '[file-path | "global"] (omit for full project)'
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
- Project CLAUDE.md: !`head -60 CLAUDE.md 2>/dev/null || echo "no CLAUDE.md"`
- Language of content: !`grep -iE "language|langue|lang" CLAUDE.md 2>/dev/null | head -5 || echo "assume English unless French content detected"`
- Package hints: !`cat package.json 2>/dev/null | grep -E '"(react|vue|svelte|astro|next|nuxt|@radix|react-aria|ariakit|@ark-ui|@base-ui|axe-core)"' || echo "none"`
- Flutter detected: !`ls pubspec.yaml 2>/dev/null || echo "no"`
- Interactive components custom-built: !`grep -rln --include="*.{tsx,jsx,vue,svelte,astro}" -iE 'role=["\x27](combobox|menu|menubar|dialog|alertdialog|tablist|tab|listbox|tree|treegrid|grid|slider|spinbutton|toolbar|tooltip|switch|checkbox|radio)' src/ 2>/dev/null | head -20 || echo "none"`
- Custom dialogs: !`grep -rln --include="*.{tsx,jsx,vue,svelte,astro,html}" -iE '<div[^>]+role=["\x27]dialog' src/ 2>/dev/null | head -20 || echo "none"`
- Native dialogs: !`grep -rln --include="*.{tsx,jsx,vue,svelte,astro,html}" -E '<dialog\s|<dialog>' src/ 2>/dev/null | head -20 || echo "none"`
- aria-live regions: !`grep -rn --include="*.{tsx,jsx,vue,svelte,astro,html}" -E 'aria-live=' src/ 2>/dev/null | head -10 || echo "none"`
- aria-label / aria-labelledby / aria-describedby usage: !`grep -rn --include="*.{tsx,jsx,vue,svelte,astro,html}" -E 'aria-(label|labelledby|describedby)=' src/ 2>/dev/null | wc -l || echo "0"`
- tabIndex usage: !`grep -rn --include="*.{tsx,jsx,vue,svelte,astro}" -E 'tabIndex=|tabindex=' src/ 2>/dev/null | wc -l || echo "0"`
- onKeyDown handlers (custom keyboard nav): !`grep -rn --include="*.{tsx,jsx,vue,svelte}" -E 'onKeyDown|@keydown' src/ 2>/dev/null | wc -l || echo "0"`
- focus-visible styling: !`grep -rn --include="*.{css,scss,tsx,jsx,vue,svelte,astro}" -E ':focus-visible|focus-visible:' src/ 2>/dev/null | wc -l || echo "0"`
- outline: none without replacement: !`grep -rn --include="*.{css,scss}" -E 'outline:\s*(none|0)' src/ 2>/dev/null | head -10 || echo "none"`
- prefers-reduced-motion: !`grep -rn --include="*.{css,scss,tsx,jsx,vue,svelte,astro}" -E 'prefers-reduced-motion' src/ 2>/dev/null | wc -l || echo "0"`
- Flutter Semantics usage: !`grep -rln --include="*.dart" -E 'Semantics\(|FocusScope|Shortcuts\(|Actions\(|ExcludeSemantics|MergeSemantics' lib/ 2>/dev/null | head -10 || echo "none"`
- Images without alt (sample): !`grep -rn --include="*.{tsx,jsx,vue,svelte,astro,html}" -E '<img\s+[^>]*src=' src/ 2>/dev/null | grep -v 'alt=' | head -10 || echo "none"`
- Form inputs without associated label: !`grep -rn --include="*.{tsx,jsx,vue,svelte,astro,html}" -E '<input\s' src/ 2>/dev/null | wc -l || echo "0"`

---

## Mode detection

- **`$ARGUMENTS` is "global"** → GLOBAL MODE: audit a11y across ALL projects
- **`$ARGUMENTS` is a file path** → FILE MODE: deep-audit that one file
- **`$ARGUMENTS` is empty** → PROJECT MODE: full 10-phase audit

---

## PROJECT MODE

### Phase 1 — WCAG 2.2 complete scan

Audit against **all** WCAG 2.2 success criteria (Level A + AA, note AAA where applicable). Not a surface check — each criterion verified specifically.

**Perceivable (1.x)**
- [ ] **1.1.1 Non-text Content** : every `<img>` has meaningful `alt`, decorative uses `alt=""`, SVGs have `<title>` or `aria-label`
- [ ] **1.2.1–1.2.5** : media has captions, transcripts, audio descriptions where applicable
- [ ] **1.3.1 Info & Relationships** : semantic HTML (`<nav>`, `<main>`, `<article>`, `<section>`), headings hierarchy, list semantics, table headers, form labels
- [ ] **1.3.2 Meaningful Sequence** : reading order matches DOM order (check absolute/fixed positioning edge cases)
- [ ] **1.3.3 Sensory Characteristics** : instructions don't rely only on shape, color, size, sound, or position
- [ ] **1.3.4 Orientation** : no forced portrait/landscape
- [ ] **1.3.5 Identify Input Purpose** : `autocomplete` attribute on common inputs (name, email, tel, etc.)
- [ ] **1.4.1 Use of Color** : color is never the only way to convey info (error states have icon + text, not just red)
- [ ] **1.4.3 Contrast (Minimum)** : 4.5:1 text, 3:1 large text/UI components. Run APCA check when possible for WCAG 3 readiness.
- [ ] **1.4.4 Resize Text** : works at 200% zoom without loss of content/function. `clamp()` uses `rem`-based values (pure `vw` breaks this).
- [ ] **1.4.5 Images of Text** : no text rendered as image (use actual text with CSS)
- [ ] **1.4.10 Reflow** : no horizontal scroll at 320px viewport (except tables, maps, code)
- [ ] **1.4.11 Non-text Contrast** : UI components and graphical objects have 3:1 contrast against neighboring colors
- [ ] **1.4.12 Text Spacing** : content adapts when users override line-height, letter-spacing, word-spacing, paragraph-spacing
- [ ] **1.4.13 Content on Hover/Focus** : tooltips/popovers are dismissible (Esc), hoverable (can move mouse to them), persistent

**Operable (2.x)**
- [ ] **2.1.1 Keyboard** : every interaction reachable via keyboard
- [ ] **2.1.2 No Keyboard Trap** : Tab cycle leaves every element except intentional focus traps (dialogs)
- [ ] **2.1.4 Character Key Shortcuts** : single-key shortcuts can be turned off, remapped, or only active on focus
- [ ] **2.4.1 Bypass Blocks** : skip-nav link to main content
- [ ] **2.4.2 Page Titled** : `<title>` unique and descriptive per page
- [ ] **2.4.3 Focus Order** : logical tab order matches visual order
- [ ] **2.4.4 Link Purpose (in context)** : link text meaningful when read alone or with its nearest heading
- [ ] **2.4.6 Headings and Labels** : descriptive, not just "Section 1"
- [ ] **2.4.7 Focus Visible** : visible focus indicator on every focusable element
- [ ] **2.4.11 Focus Appearance** (2.2 — AA) : focus indicator ≥ 2px solid, 3:1 contrast against adjacent colors. No `outline: none` without replacement.
- [ ] **2.5.1 Pointer Gestures** : no path-based gestures required (pinch, multi-finger swipe) without single-pointer alternative
- [ ] **2.5.2 Pointer Cancellation** : clicks activate on up-event, not down-event (lets users cancel by dragging off)
- [ ] **2.5.3 Label in Name** : accessible name starts with visible label text (critical for voice control)
- [ ] **2.5.4 Motion Actuation** : motion-triggered actions (shake, tilt) have alternative
- [ ] **2.5.7 Dragging Movements** (2.2 — AA) : any drag has a non-drag alternative (buttons, click-to-place)
- [ ] **2.5.8 Target Size (Minimum)** (2.2 — AA) : interactive targets ≥ 24×24 CSS px with ≥ 8px spacing (or 24px offset). Inline links exempt. 44×44 recommended for touch.

**Understandable (3.x)**
- [ ] **3.1.1 Language of Page** : `<html lang="...">` present and correct
- [ ] **3.1.2 Language of Parts** : `lang` attribute on inline passages in other languages
- [ ] **3.2.1 On Focus** : focus alone doesn't change context (navigate, submit, open dialog)
- [ ] **3.2.2 On Input** : input alone doesn't change context — changes require explicit user action (button press)
- [ ] **3.2.6 Consistent Help** (2.2 — A) : help mechanisms (contact, FAQ, chat) appear in consistent relative order across pages
- [ ] **3.3.1 Error Identification** : errors identified in text (not just color), associated with the input via `aria-describedby`
- [ ] **3.3.2 Labels or Instructions** : every input has a visible label (not just placeholder)
- [ ] **3.3.3 Error Suggestion** : errors suggest a fix when possible
- [ ] **3.3.7 Redundant Entry** (2.2 — A) : don't ask the user to re-enter info already provided in the session
- [ ] **3.3.8 Accessible Authentication (Minimum)** (2.2 — AA) : no cognitive puzzle required for auth (no unaided text-transcribing, memory-based CAPTCHAs)

**Robust (4.x)**
- [ ] **4.1.2 Name, Role, Value** : every custom component has accessible name + correct role + current state exposed
- [ ] **4.1.3 Status Messages** : status updates use `role="status"`, `role="alert"`, or `aria-live` regions (announced without focus change)

For each failing criterion, report: file:line — description — criterion ID — severity.

### Phase 2 — Keyboard navigation patterns (W3C APG)

For each interactive component type detected (see context block), verify keyboard nav per [W3C ARIA Authoring Practices](https://www.w3.org/WAI/ARIA/apg/):

- **Button**: Enter + Space activate
- **Link**: Enter activates
- **Checkbox/Switch**: Space toggles
- **Radio group**: Tab enters the group (focused item), Arrow keys move between options, selection follows focus (or Space to select if not)
- **Menu / Menubar**:
  - Enter/Space/Down Arrow opens menu
  - Arrow Up/Down moves between items
  - Arrow Right opens submenu
  - Arrow Left closes submenu
  - Escape closes menu, returns focus to trigger
  - Home/End jump to first/last item
  - Typeahead (type a letter → focus moves to first item starting with it)
- **Tabs (tablist)**:
  - Tab enters the tablist (focused tab)
  - Arrow Left/Right moves between tabs
  - Home/End jump to first/last tab
  - Tab exits to tab panel
  - Selection follows focus (for automatic activation) OR Enter/Space to activate (manual activation)
- **Combobox**:
  - Focus stays on input
  - Arrow Down opens listbox, focus moves via `aria-activedescendant` (virtual focus)
  - Arrow Up/Down navigate options
  - Enter selects, Escape closes
- **Dialog/Modal**:
  - Focus moves to first focusable element on open (or a specific initial focus)
  - Tab cycles within dialog (focus trap)
  - Escape closes, focus returns to trigger
- **Listbox**:
  - Arrow Up/Down move
  - Home/End jump
  - Space toggles selection (multi-select)
  - Shift+Arrow extends selection
- **Tree**:
  - Arrow Up/Down move between nodes
  - Arrow Right expand / move to first child
  - Arrow Left collapse / move to parent
- **Slider**:
  - Arrow Left/Right or Up/Down adjust by step
  - Home/End go to min/max
  - Page Up/Down adjust by larger step
- **Toolbar**:
  - Tab enters (focused item)
  - Arrow keys move within
  - Tab exits

For each detected custom interactive component, list which patterns are implemented and which are missing. Missing = violation.

### Phase 3 — Focus management

Verify focus strategies per component type:

**Focus trap** (required for modal dialogs):
- Focus doesn't escape the modal via Tab or Shift+Tab
- Clicking outside (if allowed to close) returns focus to trigger
- Escape closes + focus returns to trigger
- Initial focus goes to a sensible element (not always first focusable — sometimes the primary action, sometimes the first input)

**Roving tabindex** (required for menus, tabs, toolbars, radiogroups):
- Only one element in the group has `tabindex="0"` at a time
- Others have `tabindex="-1"`
- Arrow keys move the `tabindex="0"` to the new active element
- Tab enters/exits the group as a whole (not each item)

**Virtual focus / `aria-activedescendant`** (required for combobox, grid):
- DOM focus stays on a single container (input, grid)
- `aria-activedescendant` points to the currently "focused" child
- Arrow keys update `aria-activedescendant` (not DOM focus)

**Focus restoration**:
- After a modal closes, focus returns to the element that opened it
- After navigating away and back, focus returns to a sensible anchor (or preserved with `router.scrollRestoration`)

For each custom component using a focus strategy, verify the implementation matches. For Flutter, equivalent concepts: `FocusNode`, `FocusScope`, `Focus`, `FocusTraversalGroup`.

### Phase 4 — ARIA patterns per component

For each interactive custom component, verify its ARIA attributes match the [W3C APG pattern](https://www.w3.org/WAI/ARIA/apg/patterns/):

**Combobox** (example full check):
- [ ] `role="combobox"` on the input
- [ ] `aria-expanded` reflects listbox open state
- [ ] `aria-controls` points to listbox ID
- [ ] `aria-activedescendant` points to current active option (when open)
- [ ] `aria-haspopup` set to "listbox" or "grid" etc.
- [ ] Listbox has `role="listbox"`, options have `role="option"`, `aria-selected` reflects selection

Apply same depth to: menu, menubar, dialog, alertdialog, tabs, listbox, grid, tree, treegrid, slider, spinbutton, toolbar, tooltip, switch, disclosure, accordion, carousel, feed.

Link to spec for each pattern to help the user fix properly.

### Phase 5 — aria-live regions

For dynamic content updates (toasts, form validation, loading states):
- [ ] Status updates use `aria-live="polite"` (most cases) or `role="status"` (semantic equivalent)
- [ ] Error messages use `aria-live="assertive"` or `role="alert"` (interrupts)
- [ ] `aria-live` region is present on page load (not injected when the message arrives — screen readers only announce changes in pre-existing regions)
- [ ] No double-announce : don't combine `aria-live` with `role="alert"` (alert implies live)
- [ ] Regions are visually hidden if not decorative (`sr-only` class or `clip-path`)

### Phase 6 — Screen reader announcements

For each custom interactive component, verify the accessible name is constructed correctly :
- **Accessible name sources** (in priority order per W3C): `aria-labelledby` > `aria-label` > nested text content > `title`
- **Accessible description**: `aria-describedby` > `title`
- **State announcements**: `aria-pressed`, `aria-checked`, `aria-expanded`, `aria-selected`, `aria-disabled`, `aria-current`

Test mentally: "if a screen reader reads this, what does the user hear?"
- A button labeled "Edit user Alice" via `aria-labelledby="user-row-alice"` → SR says "Edit user Alice, button"
- A combobox with no label → SR says "edit text" (no context) → VIOLATION

Flag every interactive component where the announcement would be ambiguous, missing state, or use the wrong priority.

### Phase 7 — Focus appearance (WCAG 2.4.11)

Verify focus styles everywhere (see context block: count of `focus-visible` usage and `outline: none` without replacement):

- [ ] Every interactive element has a visible focus indicator
- [ ] Indicator is ≥ 2px solid (or equivalent area)
- [ ] 3:1 contrast against the adjacent background colors (both light and dark modes)
- [ ] Never `outline: none` without a replacement (border, ring, box-shadow)
- [ ] `:focus-visible` used instead of `:focus` where appropriate (mouse users don't see focus on click, keyboard users do)
- [ ] Focus indicator survives zoom to 200% (not clipped by `overflow: hidden`)

### Phase 8 — Target size (WCAG 2.5.8)

- [ ] All interactive targets are ≥ 24×24 CSS px with ≥ 8px spacing between adjacent targets (or 24px offset to neighbors)
- [ ] Inline text links exempt
- [ ] Icon buttons use padding (not fixed width) to reach 24×24 (e.g., 16px icon + 4px padding all sides)
- [ ] Touch screens: 44×44 recommended. Flag if primary mobile targets < 44px.

### Phase 9 — Dragging alternatives (WCAG 2.5.7)

- [ ] Every drag-to-operate control (reorder, slider-via-drag, drag-to-resize, drag-to-connect) has a non-drag alternative
- [ ] Reorder lists: add up/down arrow buttons beside each item
- [ ] Sliders: arrow keys adjust (already required by keyboard patterns)
- [ ] Draggable canvas: buttons or click-to-place alternative

### Phase 10 — Consistent help (WCAG 3.2.6)

- [ ] Help mechanisms (contact link, help chat, FAQ link, self-service tools) appear in the same relative position across pages
- [ ] If help is in the footer, it's in the footer on every page
- [ ] If there's a help icon in the header, it's there on every page (not hidden behind a menu on some)

### Cross-platform — Flutter

Map to Flutter equivalents when auditing a Flutter project:

- **Semantics** : every custom interactive widget wraps in `Semantics()` with `label`, `button`, `hint`, `value`, state flags (`enabled`, `selected`, `checked`, `toggled`)
- **ExcludeSemantics** : hide decorative widgets from SR (icons that duplicate text, etc.)
- **MergeSemantics** : combine multiple semantic nodes into one announcement (for compound widgets)
- **Focus / FocusScope / FocusNode** : manage focus explicitly for custom interactive widgets
- **Shortcuts + Actions** : keyboard shortcut registration (equivalent to ARIA Authoring Practices key bindings)
- **DefaultFocusTraversal** : control tab order (analogous to DOM order)
- **Built-in widgets** (ElevatedButton, IconButton, TextField, etc.) are already accessible — custom `GestureDetector`-based widgets usually are NOT without explicit `Semantics`

Flag Flutter projects where custom interactive widgets (built with `GestureDetector` or `InkWell`) are missing `Semantics`.

### Severity rules

A11y violations are **generally higher severity** than token or component violations because they block real users:

- **🔴 Critical** : any WCAG A or AA failure that blocks keyboard users or screen reader users entirely (e.g., custom combobox with no roles, dialog with no focus trap, inputs without labels)
- **🟠 High** : degraded experience (missing focus indicator, poor SR announcement, missing aria-live for important updates, target size < 24px)
- **🟡 Medium** : polish issues (aria-describedby would improve clarity, focus appearance could be stronger, etc.)

### Final report

```
═══════════════════════════════════════
ACCESSIBILITY AUDIT — [project]
═══════════════════════════════════════

WCAG 2.2 COMPLIANCE
  Level A failures:    N
  Level AA failures:   N
  Level AAA notes:     N

KEYBOARD NAVIGATION       [A/B/C/D]
FOCUS MANAGEMENT          [A/B/C/D]
ARIA PATTERNS             [A/B/C/D]
ARIA-LIVE REGIONS         [A/B/C/D]
SCREEN READER NAMES       [A/B/C/D]
FOCUS APPEARANCE          [A/B/C/D]
TARGET SIZE               [A/B/C/D]
DRAGGING ALTERNATIVES     [A/B/C/D]
CONSISTENT HELP           [A/B/C/D]
───────────────────────────────────────
OVERALL A11Y              [A/B/C/D]

CRITICAL BLOCKERS (🔴)
  file:line — description — WCAG 2.2 ID — How to fix

HIGH (🟠)
  ...

QUICK WINS (⚡)
  ...

Tasks created: X in TASKS.md
═══════════════════════════════════════
```

---

## FILE MODE

Audit a single file. Apply phases 2, 3, 4, 6, 7, 8 to the component in that file. Skip phases requiring project-wide context (1 is still useful for that file's criteria, 5 and 10 need cross-file).

---

## GLOBAL MODE

Standard pattern: read PROJECTS.md, AskUserQuestion for selection, parallel agents, compile cross-project a11y report.

---

## Tracking

Shared file write protocol for `AUDIT_LOG.md` and `TASKS.md`:
- Treat the snapshots loaded at skill start as informational only.
- Right before each write, re-read the target file from disk and use that version as authoritative.
- Append or replace only the intended row or subsection; never rewrite the whole file from stale context.
- If the expected anchor moved or changed, re-read once and recompute.
- If it is still ambiguous after the second read, stop and ask the user instead of forcing the write.

- Local `AUDIT_LOG.md` : row for "A11y" audit with date + score + critical count
- Local `TASKS.md` : `### Audit: A11y` subsection (🔴 items bubble up to top of TASKS.md since they block real users)
- Master `${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}/TASKS.md` : same subsection under project

---

## Important

- **Read-only audit** — don't fix, only document. A11y fixes often require UX decisions.
- Called by `sf-audit-design` in deep mode, or standalone via `/sf-audit-a11y`
- **A11y violations block real users** — be appropriately strict. Missing alt text isn't a B-level polish issue, it's a C or D-level exclusion.
- **Cross-platform** : web (ARIA, DOM) + Flutter (Semantics, Focus, Shortcuts). Native iOS/Android out of scope unless explicitly targeted.
- **Authoritative references** : cite WCAG 2.2 criterion IDs, W3C APG patterns, and MDN where applicable — lets the user go deep when needed
- The goal is **Radix / React Aria level accessibility in custom components** — use those libraries' patterns as the gold standard to measure against, even if the user isn't using them
- **Skill refresh**: WCAG 3.0 is still in draft (March 2026). Mention APCA contrast for forward-looking projects but don't fail WCAG 2.2 audits on it.
- Be ruthlessly honest : "mostly accessible" is not accessible. Either it works for a keyboard-only user / screen reader user, or it doesn't.
