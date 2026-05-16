---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipFlow
created: "2026-05-16"
updated: "2026-05-16"
status: draft
source_skill: sf-start
scope: sf-audit-design-checklists
owner: unknown
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/sf-audit-design/SKILL.md
depends_on:
  - artifact: "skills/sf-audit-design/references/audit-gates.md"
    artifact_version: "0.1.0"
    required_status: "draft"
supersedes: []
evidence:
  - "Extracted from sf-audit-design SKILL.md during compact-skill pilot."
next_review: "2026-06-16"
next_step: "/sf-verify Compact ShipFlow Skill Instructions"
---

# sf-audit-design Checklists

## Scoring

Use strict `A/B/C/D` grading with explicit evidence.

- `A`: production-ready quality
- `B`: solid but notable gaps
- `C`: significant issues with clear user impact
- `D`: critical failures or unsafe UX/accessibility

## Core Audit Domains

1. Visual hierarchy and layout
2. Typography and typographic token system
3. Color, contrast, semantic palette
4. Responsiveness and touch ergonomics
5. Component consistency and state coverage
6. Accessibility (WCAG 2.2)
7. Usability (NN/g heuristics)
8. Outdated patterns
9. Modern CSS baseline adoption
10. AI-generated code smells
11. Theme system architecture
12. Spacing token system
13. Motion token system

## Domain Highlights (Mandatory)

### Typography / Spacing / Motion Tokens

- Prefer tokenized values over component literals.
- Require coherent naming strategy (t-shirt vs semantic, not mixed).
- Flag chaotic scales and suggest consolidated token design.
- Check `clamp()` usage quality where fluid sizing is expected.
- Require `prefers-reduced-motion` support for non-trivial motion.

### Color And Theme

- Verify WCAG AA minimum contrast.
- Verify semantic palette intents (`success`, `warning`, `danger`, `info`, `neutral`) and surface roles.
- Flag hue-based component naming as system drift.
- Verify theme architecture (`light/dark/system`), persistence, first-paint correctness, and settings-level selector.
- If auth exists, require server sync for theme preference.

### Accessibility

- Focus appearance and keyboard navigability.
- Target size minimum and spacing for interactive controls.
- Meaningful labels/alts and recoverable error states.
- Reduced-motion compliance.
- Avoid aria misuse and inaccessible custom controls.

### Modern Platform Patterns

Prefer modern built-ins when reasonable:

- native `<dialog>` for modal flows
- `popover` for lightweight overlays
- container queries for multi-context components
- careful `:has()` usage
- view transitions gated by reduced-motion preferences
- compositor-friendly animations

### AI-Generated Smells

Flag common generator regressions:

- conflicting utilities
- dynamic utility concatenation that breaks static extraction
- clickable divs without keyboard semantics
- missing focus/disabled/loading/error states
- missing form labels or image `alt`

## Phase Skeletons

### Page Mode

1. Gather target page + wrappers + imports.
2. Score all domains.
3. Provide bounded fixes/recommendations with `Why it matters`.
4. Report top improvements (max 5).

### Project Mode

1. Design-system inventory.
2. Outdated pattern scan.
3. Page-by-page scan.
4. Cross-page consistency check.
5. Prioritize high-impact bounded remediations.
6. Produce consolidated report + update tracking.

### Global Mode

Same checklist per project, then cross-project synthesis.

### Deep Mode

Delegate tokens/components/a11y specialists in parallel, then consolidate.

## Severity Guidance

- `critical` for accessibility blockers, misleading high-risk UX states, major trust or security-adjacent UI misrepresentation, or severe systemic token drift in larger systems.
- `high` for broad consistency/responsiveness/usability failures with repeated user impact.
- `medium` for bounded quality gaps with lower blast radius.

## Required Reporting Fields

- business metadata versions
- scores by domain
- severe findings with file:line evidence
- top improvements with principle-backed rationale
- confidence and missing context

## Hard Guardrails

- Do not hide critical findings to keep reports short.
- Do not claim score confidence when branding/product contracts are stale or missing.
- Do not run broad redesign work under a narrow audit scope without user consent.
