---
name: sf-design-from-scratch
description: "Professional design-system creation from existing UI."
argument-hint: '[project | page | route | "tokens-only" | "with-playground"]'
---

## Canonical Paths

Before resolving any ShipFlow-owned file, load `$SHIPFLOW_ROOT/skills/references/canonical-paths.md` (`$SHIPFLOW_ROOT` defaults to `$HOME/shipflow`). ShipFlow tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPFLOW_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Chantier Tracking

Trace category: `conditionnel`.
Process role: `source-de-chantier`.

Before producing the final report, load `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md` when this run is attached to a spec-first chantier. If exactly one active `specs/*.md` chantier is identified, append the current run to `Skill Run History`, update `Current Chantier Flow` when the run changes the chantier state, and include the compact `Chantier` block from `$SHIPFLOW_ROOT/skills/references/reporting-contract.md`. If no unique chantier is identified, do not write to any spec; report `Chantier: non applicable` or `Chantier: non trace` with the reason.

Because this skill can create broad follow-up work, evaluate the `Chantier potentiel` threshold from `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md`. Create or route to a spec when the design-system migration spans multiple shared surfaces, product-critical pages, or non-local component changes.

## Report Modes

Before producing the final report, load `$SHIPFLOW_ROOT/skills/references/reporting-contract.md`.

Default to `report=user`: concise, action-first, and focused on the resulting professional design system, files changed, validation, and the next real step. Use `report=agent`, `handoff`, `verbose`, or `full-report` only when another agent needs the inventory, token mapping, migration matrix, validation proof, or unresolved decisions.

## Mission

`sf-design-from-scratch` creates a complete, professional design-system source of truth from an existing UI. It is for projects that have scattered fonts, colors, sizes, spacing, and motion values but no coherent centralized token layer.

It is not a general design router and it is not only a playground generator. The core job is:

```text
existing UI evidence
  -> visual inventory
  -> complete constrained design-system architecture
  -> central source of truth
  -> bounded migration from literals to variables
  -> validation
  -> sf-design-playground and sf-audit-design-tokens follow-up
```

## Scope Gate

Accepted scope:

- creating a complete professional design-token system from an existing frontend
- centralizing fonts, colors, typography sizes, spacing, radius, motion, and theme primitives
- replacing obvious hardcoded literals with semantic variables
- aligning global CSS, Tailwind/theme config, layout shells, and representative components
- preparing or routing to `sf-design-playground` after tokens exist
- running or routing to `sf-audit-design-tokens` after creation

Rejected scope:

- acting as the future generic `sf-design` router
- inventing a full new brand identity without existing evidence or user decision
- building a production component library, Storybook, or design documentation site
- replacing specialist audits: `sf-audit-design`, `sf-audit-design-tokens`, `sf-audit-components`, `sf-audit-a11y`
- broad redesign across unrelated product flows without a ready spec
- shipping unrelated dirty files

## Entry Rules

1. Detect the project framework and styling stack: CSS variables, Tailwind, Sass, CSS modules, JS/TS theme object, Astro/Next/Vite/Svelte/Nuxt/Remix, or Flutter theme.
2. Identify existing global styles, layouts, theme files, representative pages, and representative components.
3. Inventory current fonts, font weights, colors, type sizes, spacing, radius, shadows, and motion values.
4. Decide whether the work is direct or needs spec-first:
   - direct: one bounded app, one canonical style layer, bounded migration
   - spec-first: many pages/components, mixed frameworks, public/product-critical flows, unclear brand direction, or broad component rewrites
5. If the target page/surface is unclear, ask one targeted question and continue.

## Professional Constraints

Default constraints protect professional coherence; they do not mean the system is incomplete:

| Domain | Default limit | Notes |
| --- | --- | --- |
| Fonts | max 5 font roles or loaded families | Prefer 1-2 families and semantic roles such as `--font-sans`, `--font-display`, `--font-mono`. |
| Chromatic colors | max 3 chromatic families | Do not count required neutral, surface, border, text, overlay, success, warning, danger, or info support tokens as brand color families. |
| Font sizes | max 5 size tokens | Choose them with a coherent modular ratio, not linear increments. |
| Spacing | coherent scale | Prefer a 4px or 8px base and avoid one-off values. |
| Motion | semantic durations/easings | Example: `--duration-fast`, `--duration-base`, `--ease-standard`. |

Do not exceed these constraints without a targeted user decision. When the existing UI has more values, consolidate by usage frequency, visual role, and product importance.

## Professional Completion Standard

A run is not complete just because a few variables exist. A professional design-system result must cover every core domain the project uses:

- canonical token source wired into the existing stack
- font roles and loading strategy
- modular typography scale with line-height and letter-spacing
- semantic color primitives plus surfaces, text, borders, overlays, and state colors
- spacing, radius, shadow/elevation, and motion tokens
- light/dark/system behavior when the project supports theme modes
- semantic aliases for recurring UI intents such as buttons, cards, forms, alerts, navigation, or sections when those patterns exist
- a bounded migration that proves the source of truth is actually consumed by global styles, the shell, and representative components/pages

If a broad app cannot be fully migrated in one safe run, the token system still needs to be complete across its domains; only the replacement sweep is staged.

## Typography Scale Doctrine

Do not invent font sizes one by one. Derive the kept typography tokens from a coherent modular scale:

- Start from the existing readable body size, usually around `1rem`.
- Pick one ratio that fits the product density and tone: `1.125`, `1.2`, `1.25`, `1.333`, `1.414`, `1.5`, or `1.618`.
- Keep no more than 5 size tokens by default to preserve hierarchy, even if the source UI has more literals.
- Prefer fluid tokens for headings and display text: `clamp(MIN_REM, X_REM + Y_VW, MAX_REM)` with moderate `vw` (`Y <= 3`) and a real `rem` base so browser zoom still works.
- Use [Utopia.fyi](https://utopia.fyi) or the same base-size + ratio + viewport-range math when generating a professional fluid scale.
- Bundle size, line-height, and letter-spacing decisions together; isolated font-size tokens create drift.

## Creation Flow

### Phase 1: Inventory

Read only the files needed to understand the current visual system:

- global CSS and reset files
- Tailwind/theme config when present
- root layouts and app shell
- 3-8 representative pages or screens
- 5-10 representative components
- existing brand docs such as `BRANDING.md` when present

Record:

- fonts and where they are loaded
- hardcoded colors and repeated values
- font-size and line-height clusters
- modular-scale candidates and chaotic size outliers
- spacing/radius/shadow/motion clusters
- light/dark/theme behavior
- where literals are repeated enough to centralize

### Phase 2: Token Plan

Produce a concise professional token plan before editing:

```text
Canonical token source: [file]
Fonts kept: [<=5]
Chromatic families kept: [<=3]
Font sizes kept: [<=5]
Typography ratio: [1.125 / 1.2 / 1.25 / 1.333 / 1.414 / 1.5 / 1.618]
Fluid type: [none / headings / display+headings]
Spacing base: [4px / 8px / existing]
Migration batch: [files]
Questions: [only if needed]
```

If the choice changes the brand direction, ask the user. If it only consolidates obvious duplicates, proceed.

### Phase 3: Create The Token Source

Create or update the canonical token source using the project stack:

- CSS variables in global CSS for most web projects
- Tailwind theme extension when Tailwind is the existing source of truth
- JS/TS theme object only when the project already uses one
- Flutter `ThemeData` / constants only for Flutter projects

Required token groups:

- font family roles
- color primitives and semantic aliases
- surfaces, text, borders, overlays
- typography size, line-height, and letter-spacing tokens generated from a modular scale
- spacing scale
- radius scale
- shadow/elevation tokens when used
- motion duration and easing tokens

### Phase 4: Migrate A Bounded Surface

Replace obvious hardcoded literals with variables in a bounded first batch:

- global styles
- root layout/shell
- key repeated components
- the target page or the top 1-3 representative pages

Do not attempt a whole-app sweep unless the spec is ready and the scope is explicitly bounded.

### Phase 5: Tooling Follow-Up

After tokens exist:

- run or route to `sf-design-playground` when the user wants visual editing/preview
- run or route to `sf-audit-design-tokens` for deep token coherence
- route to `sf-audit-components` if component variants drift after tokenization
- route to `sf-audit-a11y` if contrast, focus, motion, or target-size risks appear

## Unblock Rules

Do not stop silently.

- If a missing decision can unblock the work, ask the user one targeted question.
- If a specialist skill can unblock the work, route to that skill with the exact next command.
- If the project needs a durable migration plan, route to `/sf-spec <design-system title>`.
- Stop hard only for unsafe writes, unsupported framework behavior, failed validation that cannot be locally fixed, ambiguous brand direction after a question, or unrelated dirty ship scope.

## Validation

Run checks that match the project and changed surfaces.

For ShipFlow skill changes:

```bash
python3 tools/skill_budget_audit.py --skills-root skills --format markdown
"${SHIPFLOW_ROOT:-$HOME/shipflow}/tools/shipflow_sync_skills.sh" --check --skill sf-design-from-scratch
```

For web projects:

```bash
npm run build
npm run lint
```

Use available project scripts rather than inventing commands. If no script exists, report the gap.

Focused checks:

```bash
rg -n "#[0-9a-fA-F]{3,6}\\b|rgb\\(|rgba\\(|oklch\\(" src app pages components 2>/dev/null
rg -n "font-size:\\s*[0-9]|gap:\\s*[0-9]|padding:\\s*[0-9]|margin:\\s*[0-9]" src app pages components 2>/dev/null
rg -n "prefers-reduced-motion|data-theme|color-scheme|darkMode|theme" src app pages components 2>/dev/null
```

These `rg` checks are evidence, not automatic failures. A few literals can be acceptable when documented.

After creation, run or recommend:

```bash
/sf-audit-design-tokens
/sf-design-playground
```

## Security And Safety

- Never overwrite a token source without understanding existing imports and theme behavior.
- Never remove existing fonts/colors if they are required by brand or legal assets without user confirmation.
- Never weaken contrast, focus visibility, or reduced-motion behavior to satisfy token discipline.
- Never expose private URLs, sensitive operational data, screenshots with sensitive data, or internal logs in reports.
- Never ship unrelated dirty files.

## Stop Conditions

Stop and report `blocked` only when:

- no target page/surface exists and the user has not answered the targeted question
- the project framework/style stack is unsupported for safe edits
- the brand direction is ambiguous and the user has not chosen between viable directions
- broad migration needs a ready spec and none exists
- validation fails and the fix is outside the approved scope
- professional token constraints must be exceeded and the user has not approved the expansion
- unrelated dirty files would enter ship scope

Every `blocked` report must include one of:

- `Question:` the exact decision needed
- `Route:` the owner skill and command to run
- `Next:` the spec/check/fix command that unblocks progress

## Final Report

Use `report=user` by default:

```text
## Design From Scratch: [project or surface]

Result: [implemented / partial / blocked / rerouted]
Token source: [file or none]
Design system: [fonts/colors/type/spacing/radius/motion/theme summary]
Migration: [files changed or none]
Checks: [passed / failed / skipped with reason]
Follow-up: [sf-design-playground / sf-audit-design-tokens / none]

## Chantier

[spec path | non trace: reason]
Reste a faire: [only if non-empty]
Prochaine etape: [only if non-empty]
```

Use `report=agent` for token inventory, value mapping, file-by-file migration details, validation logs, and unresolved design decisions.

## Rules

- Create the design-system source of truth before creating a playground.
- Extract from the existing UI before inventing new visual direction.
- Keep the first shipped system complete across token domains and coherent enough to maintain.
- Ask targeted questions to unblock decisions; do not stop without a recovery path.
- Route to specialist design skills for audits, playground tooling, component architecture, and accessibility proof.
