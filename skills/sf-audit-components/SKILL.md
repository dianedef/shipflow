---
name: sf-audit-components
description: "Args: file-path or \"global\"; omit for full project. Deep specialist audit of component architecture — atomic design inventory, duplication detection, god components, unused components, AHA rule application, variant systems adoption, headless primitives, composition vs configuration, API hygiene. Cross-platform (React/Vue/Svelte/Astro + Flutter)."
disable-model-invocation: true
argument-hint: '[file-path | "global"] (omit for full project)'
---

## Canonical Paths

Before resolving any ShipFlow-owned file, load `$SHIPFLOW_ROOT/skills/references/canonical-paths.md` (`$SHIPFLOW_ROOT` defaults to `/home/claude/shipflow`). ShipFlow tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPFLOW_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Chantier Tracking

Trace category: `conditionnel`.
Process role: `source-de-chantier`.

Before producing the final report, load `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md` when this run is attached to a spec-first chantier. If exactly one active `specs/*.md` chantier is identified, append the current run to `Skill Run History`, update `Current Chantier Flow` when the run changes the chantier state, and include a final `Chantier` block. If no unique chantier is identified, do not write to any spec; report `Chantier: non applicable` or `Chantier: non trace` with the reason.

## Chantier Potential Intake

Because this skill has process role `source-de-chantier`, evaluate the standard threshold from `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md` before the final report. If the findings reveal non-trivial future work and no unique chantier owns it, do not write to an existing spec; add a `Chantier potentiel` block with `oui`, `non`, or `incertain`, a proposed title, reason, severity, scope, evidence, recommended `/sf-spec ...` command, and next step. If the work is only a direct local fix or already belongs to the current chantier, state `Chantier potentiel: non` with the concrete reason.


## Context

- Current directory: !`pwd`
- Project CLAUDE.md: !`head -60 CLAUDE.md 2>/dev/null || echo "no CLAUDE.md"`
- package.json: !`cat package.json 2>/dev/null | head -60 || echo "no package.json (may be Flutter/native)"`
- pubspec.yaml (Flutter): !`head -40 pubspec.yaml 2>/dev/null || echo "no pubspec"`
- Component directories: !`find . -maxdepth 4 -type d \( -name "components" -o -name "ui" -o -name "widgets" -o -name "elements" \) 2>/dev/null | grep -v node_modules | head -10 || echo "no component dirs"`
- Component files count (web): !`find src/components src/ui -type f \( -name "*.tsx" -o -name "*.jsx" -o -name "*.vue" -o -name "*.svelte" -o -name "*.astro" \) 2>/dev/null | grep -v node_modules | wc -l || echo "0"`
- Widget files count (Flutter): !`find lib -type f -name "*.dart" 2>/dev/null | grep -v generated | wc -l || echo "0"`
- Variant library detection: !`grep -l --include="package.json" -E '"(class-variance-authority|cva|tailwind-variants|tv|cva-zero)"' package.json 2>/dev/null && echo "CVA/tw-variants detected" || echo "no variant library"`
- Headless library detection: !`grep -E '"(@radix-ui|@headlessui|@ariakit|react-aria|@react-aria|@ark-ui|@base-ui)"' package.json 2>/dev/null | head -10 || echo "no headless library"`
- Tailwind detected: !`ls tailwind.config.* 2>/dev/null || echo "no tailwind"`
- TypeScript detected: !`ls tsconfig.json 2>/dev/null || echo "no tsconfig"`
- Component file listing (sample): !`find src/components src/ui lib -type f \( -name "*.tsx" -o -name "*.vue" -o -name "*.dart" -o -name "*.svelte" \) 2>/dev/null | grep -v node_modules | grep -v generated | sort | head -40 || echo "none"`
- Interactive primitives written custom (web): !`grep -rln --include="*.{tsx,jsx,vue,svelte}" -iE 'role=["\x27](combobox|menu|menubar|dialog|tablist|tab|listbox|tree|grid|slider|toolbar|tooltip)' src/components src/ui 2>/dev/null | head -20 || echo "none"`
- Flutter Semantics widgets usage: !`grep -rln --include="*.dart" -E 'Semantics\(|FocusScope\(|Shortcuts\(|Actions\(' lib/ 2>/dev/null | head -10 || echo "none"`

## Pre-check

If component count (web + Flutter combined) is 0, abort with:
```
⚠ No components detected.

This skill audits EXISTING component libraries. Nothing to audit yet.
Start building components, then re-run.
```

---

## Mode detection

- **`$ARGUMENTS` is "global"** → GLOBAL MODE: audit component architecture across ALL projects
- **`$ARGUMENTS` is a file path** → FILE MODE: deep-audit that one component file
- **`$ARGUMENTS` is empty** → PROJECT MODE: full 9-phase audit

---

## PROJECT MODE

### Phase 1 — Atomic Design Inventory

Classify every component into [Brad Frost's atomic layers](https://atomicdesign.bradfrost.com/):

- **Atoms** : indivisible primitives — `Button`, `Input`, `Label`, `Icon`, `Spinner`, `Divider`, `Badge`
- **Molecules** : small groups of atoms working together — `SearchBar` (Input + Button), `FormField` (Label + Input + ErrorText), `Card` (Container + Content + Actions)
- **Organisms** : complex compositions — `Header`, `ProductGrid`, `CheckoutForm`, `SidebarNav`
- **Templates** : page-level layouts without concrete content — `ProductPageLayout`, `SettingsLayout`
- **Pages** : concrete instances (often in `pages/` or `app/` directory, not `components/`)

Produce a table:

```
LAYER          COUNT   SAMPLE FILES
Atoms          N       button.tsx, input.tsx, icon.tsx, ...
Molecules      N       search-bar.tsx, form-field.tsx, ...
Organisms      N       header.tsx, checkout-form.tsx, ...
Templates      N       product-layout.tsx, ...
Pages          N       (usually in pages/app dir, not counted here)
UNCLASSIFIED   N       files that don't fit any layer cleanly
```

**Flag** :
- **Inverted pyramid** : if organisms > molecules > atoms in count, the system is top-heavy (everything is custom-assembled, nothing reused). Healthy ratio: atoms ≥ molecules ≥ organisms.
- **Missing atoms layer** : if you see molecules/organisms but no `button.tsx`, `input.tsx`, etc., components are probably reinventing primitives inline → duplication risk.
- **Unclassified > 20%** : naming isn't clear about what each component IS → future contributors can't find the right one, duplication emerges.

### Phase 2 — Duplication Detection

Find components that do **similar things** under different names. Strategies:

1. **Name similarity** : `UserCard`, `ProfileCard`, `MemberCard` — all 3 exist? Likely duplicates.
2. **Structural similarity** : components with nearly identical JSX trees (same element types, same class patterns) but different names. Use grep to find components with same first 5-10 lines of JSX.
3. **Prop overlap** : two components with 80%+ overlapping prop names — probably the same thing with slight variants, should be unified via variant system.
4. **Copy-paste markers** : commits where one file was created shortly after another with similar content (`git log --follow` on both).

Apply the **Rule of Three** (Fowler/Pragmatic Programmer):
- Pattern appears once → inline it
- Pattern appears twice → note it, maybe extract (use your judgment)
- Pattern appears three times → abstract it into a shared component

But respect **AHA** (Avoid Hasty Abstractions, Kent C. Dodds):
- If the three instances are only superficially similar (same shape, different behavior), DON'T abstract. Duplication is cheaper than the wrong abstraction.
- "Prefer duplication over the wrong abstraction" — cite when recommending abstraction.

Report findings as:

```
DUPLICATION
  src/components/UserCard.tsx + src/components/ProfileCard.tsx
    → 85% structural overlap, same props (user, onEdit, onDelete)
    → Recommendation: unify into <PersonCard variant="user|profile" />
    → Rule: 3rd instance (MemberCard also detected) — threshold reached
```

### Phase 3 — God Components (prop explosion)

Flag any component with:
- **> 15 props** : prop explosion — the component is doing too much
- **> 300 lines** : too much logic in one file
- **Multiple responsibilities** : rendering + data fetching + state management + side effects (mixing concerns)
- **Mixed presentational + business logic** : a `Button` that also calls an analytics SDK, or a `Card` that fetches its own data — split.

For each god component, recommend:
- Split into sub-components (compound pattern)
- Extract logic into hooks/composables
- Use slot/children props instead of configuration props when possible

### Phase 4 — Unused Components

Find components that are imported nowhere. Process:
1. List every component file
2. For each, grep the codebase for `import.*ComponentName` or `<ComponentName` 
3. If no usage found outside the component's own file → orphan

Be careful:
- Barrel exports (`index.ts`) can make unused components look used. Trace actual downstream imports.
- Dynamic imports / lazy-loaded routes can hide usage. Check route configs.
- Storybook / test files count as usage only if the component is ALSO used in production code.

Report:
```
UNUSED COMPONENTS
  src/components/legacy/OldButton.tsx — 0 imports outside self — candidate for deletion
  src/components/experimental/FancyPicker.tsx — only used in stories — candidate for deletion
```

### Phase 5 — Abstraction Quality (AHA)

Look for signs of **premature or wrong abstraction**:

- **Flexibility components** : `<FlexibleCard>`, `<SuperButton>`, `<UniversalDialog>` — names with "Flexible", "Super", "Universal", "Generic" are red flags. They usually accept 20+ props to cover 3 use cases that should have been 3 components.
- **Boolean flag farms** : `<Thing isLoading isError isEmpty isDisabled isReadonly isCompact isExpanded />` — the component is a state machine disguised as a component. Either split into sub-components or use a proper state enum.
- **Leaky abstractions** : a component that exposes internal implementation via `className` overrides on every sub-part, `style` passthrough, `ref` forwarding to internals, etc. Signals the abstraction didn't fit its consumers.
- **Config object hell** : `<Chart config={{ axes: {...}, series: {...}, tooltips: {...}, legend: {...} }} />` with 100+ possible keys — compose from sub-components instead.

For each wrong abstraction, recommend:
- **Un-abstract** : inline the 3 use cases as separate components, accept duplication. Easier to read, safer to change, each can evolve independently.
- **Re-abstract differently** : compound components, headless logic + styled shell, generic primitive + domain-specific wrappers.

### Phase 6 — Variant Systems Adoption

If the project uses Tailwind (detected in context) **and** has > 20 components **and** no CVA / tailwind-variants / similar library → recommend adoption.

Why it matters:
- A `Button` with 3 variants × 3 sizes × 2 intents = 18 visual combinations
- Without CVA: either 18 separate components, or a god-component with branching JSX (`className={intent === 'primary' ? '...' : intent === 'danger' ? '...' : '...'}`)
- With CVA/tw-variants: one declarative `button` variant function, consumers call `button({ variant, size, intent })`, zero branching, variants are data.

If CVA is already used, verify :
- **Variants are exhaustive** : no runtime `if/else` for styling in components using CVA (should be declared variants)
- **Compound variants** : if `intent="danger"` + `size="sm"` needs special handling, use `compoundVariants`, not branching JSX
- **Default variants** declared : every variant has a `defaultVariants` block to avoid `undefined` at runtime

For Flutter/native: no exact CVA equivalent; the goal translates to "variants as data" — e.g., a `ButtonStyle` object with properties, not hand-picked in each `ElevatedButton(...)`.

### Phase 7 — Headless Primitives Adoption

For each interactive primitive found custom-built (see context block: custom `role=combobox|menu|dialog|...`), check if a headless library would be better:

- **[Radix UI](https://www.radix-ui.com/primitives)** (React) : battle-tested, WCAG-compliant, unstyled
- **[React Aria](https://react-spectrum.adobe.com/react-aria/)** (React) : Adobe, hooks-based, i18n built-in
- **[Ark UI](https://ark-ui.com/)** (React/Vue/Solid) : framework-agnostic, backed by Chakra
- **[Base UI](https://base-ui.com/)** (React, by MUI) : newer, opinionated
- **[Headless UI](https://headlessui.com/)** (React/Vue, by Tailwind team) : lighter scope

When to recommend migration:
- Custom combobox without `aria-activedescendant` / virtual focus → migrate
- Custom dialog without focus trap / restoration → migrate
- Custom menu without arrow-key nav / typeahead → migrate
- Custom tabs without `role=tablist` + roving tabindex → migrate

When NOT to recommend :
- The user explicitly doesn't want a dependency (check CLAUDE.md)
- Project is Flutter/native — recommend the platform equivalent instead (Flutter: material/cupertino widgets already follow platform conventions; `Focus`, `Shortcuts`, `Actions` for custom interactive widgets)

### Phase 8 — Composition vs Configuration

Flag components that should use composition (children/slots) instead of configuration (props):

- `<Card title="..." subtitle="..." imageUrl="..." actions={[...]} />` → prefer `<Card><CardHeader>...</CardHeader><CardBody>...</CardBody><CardActions>...</CardActions></Card>`
- `<Dialog titleText="..." bodyText="..." primaryButtonText="OK" onPrimaryClick={...} />` → prefer `<Dialog><Dialog.Title>...</Dialog.Title><Dialog.Body>...</Dialog.Body><Dialog.Actions>...</Dialog.Actions></Dialog>`

Signs a component should switch to composition:
- Lots of text props (`titleText`, `subtitleText`, `footerText`, `...`)
- `render*` props (`renderHeader`, `renderFooter`) to customize parts — use slots/children
- `*Props` spread props (`headerProps`, `footerProps`) to pass class/style through — use composition

Compound components pattern is the standard solution in React. Vue uses slots natively. Svelte uses snippets. Flutter uses `child` / `children` / `Widget`-as-parameter.

### Phase 9 — Component API Hygiene

Audit prop naming and contract quality:

- **Naming consistency** : `onClick` vs `handleClick` vs `onPress` — pick one convention per codebase
- **Boolean props** : `disabled`, `required`, `readonly` should be boolean. `state="disabled"` when `disabled` would do = violation.
- **Enum props** : use string unions (`variant: 'primary' | 'secondary'`) instead of strings with arbitrary values (`variant: string`)
- **Required vs optional** : don't make everything optional with defaults if the component doesn't work without them — mark them required
- **Defaults declared** : every optional prop should have an explicit default (via destructuring or `defaultProps`, or via variant library defaults)
- **TypeScript strictness** (if applicable) : no `any`, no `Record<string, any>`, props interfaces exported so consumers can extend
- **Forward refs where it matters** : atoms (buttons, inputs) should forward refs to the underlying DOM element; without this, consumers can't compose with `useRef`, animation libs, focus management
- **`className` + `style` passthrough** : atoms should allow consumers to extend styling; missing = consumers fork the component

### Cross-platform adaptations

For **Flutter** projects, map the above phases:

- **Atomic layers** : `StatelessWidget` / `StatefulWidget` classes, organized by role
- **Duplication** : look for widget copy-paste across `lib/widgets/`
- **God widgets** : widgets with `build` method > 200 lines, or > 10 constructor parameters
- **Unused widgets** : `ref.read` / import analysis, or `dart analyze` with unused imports enabled
- **Variant systems** : Flutter has no CVA — the equivalent is explicit `ButtonStyle`, `TextTheme`, `CardTheme` defined in `ThemeData`
- **Headless** : Flutter ships accessibility via `Semantics`, `FocusScope`, `Shortcuts`, `Actions` — verify interactive custom widgets use them
- **Composition** : Flutter is already composition-first (`child`, `children`). Check for prop-bag widgets that should use `child` instead.
- **API hygiene** : `const` constructors on stateless widgets, named parameters with `required`, `key` passed correctly

### Severity rules (adaptive to project size)

Same matrix as `sf-audit-design-tokens`:

| Project size | Threshold | Max severity |
|---|---|---|
| Small | < 10 components | 🟡 medium |
| Mid | 10-30 components | 🟠 high |
| Large | > 30 components | 🔴 critical |

### Final report

```
═══════════════════════════════════════
COMPONENT ARCHITECTURE AUDIT — [project]
═══════════════════════════════════════

ATOMIC DESIGN INVENTORY
  Atoms:         N
  Molecules:     N
  Organisms:     N
  Templates:     N
  Unclassified:  N

DUPLICATION                [N findings]
GOD COMPONENTS             [N findings]
UNUSED COMPONENTS          [N candidates]
WRONG ABSTRACTIONS         [N findings]
VARIANT SYSTEMS            [adopted / recommended / N/A]
HEADLESS PRIMITIVES        [adopted / partial / custom everywhere]
COMPOSITION VS CONFIG      [N findings]
API HYGIENE                [N findings]

SUBSCORES
  Atomic Layering      [A/B/C/D]
  Duplication          [A/B/C/D]
  God Components       [A/B/C/D]
  Unused Code          [A/B/C/D]
  Abstraction Quality  [A/B/C/D]
  Variant Systems      [A/B/C/D | N/A]
  Headless Adoption    [A/B/C/D | N/A]
  Composition          [A/B/C/D]
  API Hygiene          [A/B/C/D]
───────────────────────────────────────
OVERALL COMPONENTS       [A/B/C/D]

CRITICAL ISSUES (🔴)
  ...

HIGH (🟠)
  ...

QUICK WINS (⚡)
  ...

Tasks created: X in TASKS.md
═══════════════════════════════════════
```

---

## FILE MODE

Single-component audit. Apply phases 3 (god component check), 5 (abstraction quality), 8 (composition vs config), 9 (API hygiene) to that file. Phases 1, 2, 4, 6, 7 require cross-file analysis and are skipped.

---

## GLOBAL MODE

Same pattern as other audit skills: read `PROJECTS.md`, let user select projects via **AskUserQuestion**, launch parallel agents, compile cross-project report.

---

## Tracking

Shared file write protocol for `AUDIT_LOG.md` and `TASKS.md`:
- Treat the snapshots loaded at skill start as informational only.
- Right before each write, re-read the target file from disk and use that version as authoritative.
- Append or replace only the intended row or subsection; never rewrite the whole file from stale context.
- If the expected anchor moved or changed, re-read once and recompute.
- If it is still ambiguous after the second read, stop and ask the user instead of forcing the write.

- Local `AUDIT_LOG.md` : row for "Components" audit with date + score
- Local `TASKS.md` : `### Audit: Components` subsection with 🔴🟠🟡 findings
- Master `/home/claude/shipflow_data/TASKS.md` : same subsection under project

---

## Important

- **Read-only audit** — no refactors, no code changes, only report + tasks
- Called by `sf-audit-design` in deep mode, or standalone via `/sf-audit-components`
- **Cross-platform** : web frameworks (React/Vue/Svelte/Astro) + Flutter (Dart widgets) — adapt terminology per project type detected
- When recommending abstraction, always weigh against AHA : "prefer duplication over wrong abstraction" — don't push to abstract if the 3 instances aren't genuinely similar in behavior, not just shape
- Be ruthlessly honest — A-level means production-grade architecture, not "it works"
- Respect project conventions : if the codebase uses a deliberate "one file per component, no barrel exports" convention (documented in CLAUDE.md), don't flag it as wrong
