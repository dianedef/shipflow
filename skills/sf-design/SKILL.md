---
name: sf-design
description: "UI/UX design lifecycle."
argument-hint: <design question | audit | tokens | playground | redesign | migration | page/route>
---

## Canonical Paths

Before resolving any ShipFlow-owned file, load `$SHIPFLOW_ROOT/skills/references/canonical-paths.md` (`$SHIPFLOW_ROOT` defaults to `$HOME/shipflow`). ShipFlow tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPFLOW_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Chantier Tracking

Trace category: `obligatoire`.
Process role: `lifecycle`.

Before executing from a spec-first chantier, load `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md`, read the spec's `Skill Run History` and `Current Chantier Flow`, append a current `sf-design` row with result `implemented`, `partial`, `blocked`, or `rerouted`, update `Current Chantier Flow`, and end with the compact `Chantier` block from `$SHIPFLOW_ROOT/skills/references/reporting-contract.md`.

If no unique spec exists, do not write to a spec. For narrow read-only diagnosis, answer or route directly. For non-trivial design implementation, design-system migration, multi-page visual work, public/product-critical UI changes, or proof-sensitive redesigns, route to `/sf-spec <title>` and do not edit source files before readiness is `ready`.

## Report Modes

Before producing the final report, load `$SHIPFLOW_ROOT/skills/references/reporting-contract.md`.

Default to `report=user`: concise, route-first, and in the user's active language. Use `report=agent`, `handoff`, `verbose`, or `full-report` only when another agent needs the detailed routing matrix, audit evidence, validation commands, owned surfaces, or unresolved design decisions.

## Master Delegation

Before choosing execution topology, load `$SHIPFLOW_ROOT/skills/references/master-delegation-semantics.md`.

This skill follows the shared master delegation reference. Design file work, validation sweeps, browser proof preparation, closure, and ship preparation default to delegated sequential when subagents are available. Parallel design work requires ready non-overlapping `Execution Batches`; without batches, run sequentially or refine the spec.

## Master Workflow Lifecycle

Before resolving design lifecycle gates, load `$SHIPFLOW_ROOT/skills/references/master-workflow-lifecycle.md`.

`sf-design` is a master/orchestrator skill. It routes design work through owner skills and lifecycle gates rather than duplicating specialist internals.

## Context

- Current directory: !`pwd`
- Current date: !`date '+%Y-%m-%d'`
- Project name: !`basename $(pwd)`
- Git branch: !`git branch --show-current 2>/dev/null || echo "unknown"`
- Git status: !`git status --short 2>/dev/null || echo "not a git repo"`
- Project design docs: !`ls shipflow_data/business/branding.md shipflow_data/business/business.md shipflow_data/business/product.md shipflow_data/technical/guidelines.md BRANDING.md BUSINESS.md PRODUCT.md GUIDELINES.md 2>/dev/null || echo "no project design/business docs found"`
- Available specs: !`find specs docs -maxdepth 2 -type f -name "*.md" 2>/dev/null | sort | head -80`
- Framework hints: !`ls next.config.* nuxt.config.* astro.config.* svelte.config.* vite.config.* remix.config.* gatsby-config.* package.json 2>/dev/null || echo "no framework hints found"`
- Token files: !`find . -type f \( -name "tokens*" -o -name "theme*" -o -name "design-tokens*" -o -name "_variables*" -o -name "global.css" -o -name "globals.css" \) 2>/dev/null | grep -v node_modules | head -30 || echo "none found"`
- UI files sample: !`find src app pages components -type f \( -name "*.astro" -o -name "*.tsx" -o -name "*.jsx" -o -name "*.vue" -o -name "*.svelte" -o -name "*.css" -o -name "*.scss" \) 2>/dev/null | grep -v node_modules | sort | head -80 || echo "none found"`
- Hardcoded design values sample: !`rg -n "#[0-9a-fA-F]{3,6}\\b|rgb\\(|rgba\\(|box-shadow:|transition:|font-size:\\s*[0-9]|gap:\\s*[0-9]|padding:\\s*[0-9]|margin:\\s*[0-9]" src app pages components 2>/dev/null | head -40 || echo "none found"`

## Mission

`sf-design` is the recommended entrypoint for design-related work.

The operator should be able to ask a natural design question:

```text
/sf-design améliorer la hero
/sf-design centraliser les tokens et les appliquer partout
/sf-design vérifier si le design est pro
/sf-design créer un playground de design system
/sf-design corriger les problèmes d'accessibilité visuelle
```

The skill decides the safe path and continues through the relevant owners:

```text
intake
  -> design intent routing
  -> audit/discovery when needed
  -> spec/readiness for non-trivial changes
  -> owner-skill execution
  -> checks and browser/specialist proof
  -> sf-verify
  -> closure and ship routing
```

## Design Intent Routing

Choose the smallest safe owner. Do not ask the user to choose a specialist when the request clearly names an intent.

| Intent | Route |
| --- | --- |
| Pure design question, workflow advice, or skill-choice help | Answer directly or provide the next command |
| No coherent token layer; create a central professional design system from existing UI | `sf-design-from-scratch` |
| Live preview/edit/export design tokens | `sf-design-playground` |
| Token coherence, hardcoded values, token coverage, typography/spacing/motion/palette architecture | `sf-audit-design-tokens` |
| Broad UI/UX audit, visual hierarchy, layout, responsive quality, trust, product coherence | `sf-audit-design` |
| Component variants, duplication, component API, design-system component architecture | `sf-audit-components` |
| Accessibility, contrast, focus, keyboard, reduced motion, target size, WCAG evidence | `sf-audit-a11y` |
| Non-auth visual proof, screenshots, console/network summary for UI pages | `sf-browser` |
| Auth/protected UI visual issue where login/session/provider state matters | `sf-auth-debug` |
| Broad implementation, redesign, multi-page migration, or product-critical UI change | `sf-build` or `sf-spec -> sf-ready -> sf-start` |
| Release/deploy confidence after design implementation | `sf-deploy` |
| Final bounded commit after verified design work | `sf-ship` |

When two routes are plausible and the answer changes scope, proof, brand direction, public claim, or ship risk, load `$SHIPFLOW_ROOT/skills/references/question-contract.md` and ask one numbered decision question.

## Token Implementation Handoff

Do not treat token centralization as complete site implementation.

Always distinguish three stages:

1. Token source created or updated.
2. Pages, layouts, and components migrated to consume the token source.
3. Visual non-regression or intended visual change verified with checks and browser proof.

If a run creates tokens or a playground but migration coverage is incomplete, route the next real work explicitly:

```text
/sf-design "Migrer le site pour consommer les tokens design centralises sans changement visuel volontaire"
```

Internal lifecycle for that follow-up:

```text
sf-audit-design-tokens
-> sf-spec
-> sf-ready
-> sf-start
-> sf-check
-> sf-audit-design-tokens
-> sf-browser
-> sf-verify
-> sf-end
-> sf-ship
```

If the user only asks for the exact implementation command, recommend:

```text
/sf-build "Actualiser le site pour utiliser les variables design centralisees dans toutes les pages, sans changement visuel volontaire"
```

## Scope And Readiness Rules

Use direct routing for:

- read-only design audits
- one focused specialist action
- one narrow page/component fix that can be described as a mini-contract
- playground scaffolding when the token layer and route are clear

Require spec-first for:

- broad redesign
- multi-page or cross-component token migration
- new visual direction, palette, typography, or brand shift
- public/product-critical UI surfaces
- accessibility remediation across flows
- work that claims no visual regression across many pages
- changes that affect screenshots, public claims, onboarding, pricing, docs, or trust signals

Before implementation, the ready spec must name:

- user-facing outcome
- target pages/components/layouts
- design source of truth or brand docs
- intended visual change or explicit non-regression contract
- owner skills to run
- validation and browser proof obligations
- docs/editorial impact
- ship/deploy posture

## Owner Skill Sequencing

Typical flows:

```text
Create design system:
sf-design-from-scratch -> sf-audit-design-tokens -> sf-design-playground optional -> sf-verify

Token migration across site:
sf-audit-design-tokens -> sf-spec -> sf-ready -> sf-start -> sf-check -> sf-audit-design-tokens -> sf-browser -> sf-verify -> sf-end -> sf-ship

Visual redesign:
sf-audit-design -> sf-spec -> sf-ready -> sf-start -> sf-check -> sf-browser -> sf-audit-a11y as needed -> sf-verify -> sf-end -> sf-ship

Deep design audit:
sf-audit-design deep -> sf-spec for chosen remediation -> sf-ready -> sf-start -> proof -> sf-verify

Accessibility-first design fix:
sf-audit-a11y -> sf-spec or sf-fix depending scope -> sf-browser/sf-test proof -> sf-verify
```

For design work that changes public wording, claims, docs screenshots, page promises, or content surfaces, run the editorial/docs gates from `sf-build` or route to `sf-docs`/`sf-content` as needed before closure.

## Validation

Use project scripts and specialist checks instead of inventing proof.

Typical validation:

```bash
npm run lint
npm run build
npm test
```

Focused design evidence:

```bash
rg -n "#[0-9a-fA-F]{3,6}\\b|rgb\\(|rgba\\(|box-shadow:|transition:|font-size:\\s*[0-9]|gap:\\s*[0-9]|padding:\\s*[0-9]|margin:\\s*[0-9]" src app pages components 2>/dev/null
```

Route proof:

- `sf-check` for local technical checks
- `sf-audit-design-tokens` for token coverage/coherence
- `sf-audit-a11y` for accessibility safety
- `sf-browser` for visible non-auth page proof and screenshots
- `sf-auth-debug` when auth/session state affects the UI
- `sf-prod` or `sf-deploy` for hosted truth

## Security And Safety

- Never expose private screenshots, logs, secrets, credentials, or internal operational data in design reports.
- Never weaken contrast, focus visibility, keyboard access, target size, or reduced-motion behavior to satisfy token discipline.
- Never invent a brand identity, palette, typography, or public claim when the existing project context does not support it.
- Never treat screenshots alone as sufficient proof for accessibility.
- Never ship unrelated dirty files.

## Stop Conditions

Stop and report `blocked` when:

- the design intent is too ambiguous for one targeted routing question and needs `sf-explore`
- brand direction, visual identity, public claim, or product surface choice changes materially and the user has not decided
- broad implementation lacks a ready spec
- validation or specialist proof required by the design claim is missing
- visual non-regression is claimed but browser proof was not collected
- accessibility/focus/contrast/reduced-motion safety is uncertain after changes
- ship scope includes unrelated dirty files without explicit approval

Every blocked report must include the exact next recovery route.

## Final Report

User-mode report:

```text
## Design: [scope]

Result: [implemented / partial / blocked / rerouted]
Route: [owner skill or lifecycle]
Design proof: [checks/browser/audit evidence or missing proof]
Token implementation: [complete / partial / not applicable]
Next step: [only if real]

## Chantier

[spec path | non trace: reason]
Flux: sf-spec [marker] -> sf-ready [marker] -> sf-start [marker] -> sf-verify [marker] -> sf-end [marker] -> sf-ship [marker]
Reste a faire: [only if non-empty]
Prochaine etape: [only if non-empty]
```

Agent/handoff mode may add the routing matrix decision, owned surfaces, forbidden files, validation commands, browser proof obligations, docs/editorial plan, and unresolved decisions.

## Rules

- Be the design entrypoint; do not become the implementation of every design specialist.
- Route through owner skills and lifecycle gates.
- Prefer the smallest safe route when the request is narrow.
- Use spec-first for broad design implementation and token migration.
- Always surface the token implementation handoff when centralization exists but site consumption is incomplete.
- Verify visual claims with visible proof and specialist evidence, not only code scans.
