---
name: sf-docs
description: "Documentation generation and audit for README, API docs, component docs, metadata, and drift."
disable-model-invocation: true
argument-hint: [file-path | "readme" | "api" | "components" | "audit" | "update" | "metadata" | "migrate-frontmatter" | "migrate-layout" | "technical" | "technical audit" | "editorial" | "editorial audit"]
---

## Canonical Paths

Before resolving any ShipFlow-owned file, load `$SHIPFLOW_ROOT/skills/references/canonical-paths.md` (`$SHIPFLOW_ROOT` defaults to `$HOME/shipflow`). ShipFlow tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPFLOW_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Instruction Layering

Load `$SHIPFLOW_ROOT/skills/references/skill-instruction-layering.md` before execution. This skill keeps only activation and gate logic locally; detailed doctrine and large mode playbooks are loaded from references.

## Chantier Tracking

Trace category: `conditionnel`.
Process role: `support-de-chantier`.

Before producing the final report, load `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md` when this run is attached to a spec-first chantier. If exactly one active `shipflow_data/workflow/specs/*.md` chantier is identified, append the current run to `Skill Run History`, update `Current Chantier Flow` when the run changes the chantier state, and include a final `Chantier` block. If no unique chantier is identified, do not write to any spec; report `Chantier: non applicable` or `Chantier: non trace` with the reason.

## Report Modes

Before producing the final report, load `$SHIPFLOW_ROOT/skills/references/reporting-contract.md`.

Default to `report=user`: concise and outcome-first.
Use `report=agent` for blocked runs, handoff, or explicit verbose request.

## Context

- Current directory: !`pwd`
- Project CLAUDE.md: !`head -80 CLAUDE.md 2>/dev/null || echo "no CLAUDE.md"`
- Existing README: !`head -20 README.md 2>/dev/null || echo "no README.md"`
- Project structure sample: !`find . -maxdepth 3 -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" -o -name "*.astro" -o -name "*.vue" -o -name "*.py" \) 2>/dev/null | grep -v node_modules | grep -v .git | grep -v dist | sort | head -40`

## Mode Detection

- file path -> `FILE MODE`
- `readme` -> `README MODE`
- `api` -> `API MODE`
- `components` -> `COMPONENTS MODE`
- `audit` -> `AUDIT MODE`
- `update` -> `UPDATE MODE`
- `metadata` or `migrate-frontmatter` -> `METADATA MODE`
- `migrate-layout` or `layout` -> `LAYOUT MIGRATION MODE`
- `technical`, `technical audit`, `docs/technical` -> `TECHNICAL DOCS MODE`
- `editorial`, `editorial audit`, `docs/editorial` -> `EDITORIAL GOVERNANCE MODE`
- empty args -> `AUTO MODE`

## Required References

Always load:

1. `$SHIPFLOW_ROOT/skills/sf-docs/references/core-governance.md`
2. `$SHIPFLOW_ROOT/skills/sf-docs/references/mode-playbooks.md`

Load on demand:

- `$SHIPFLOW_ROOT/skills/references/technical-docs-corpus.md` when mode is technical or update touches technical governance.
- `$SHIPFLOW_ROOT/skills/references/editorial-content-corpus.md` when mode is editorial or update touches public-content surfaces.
- `$SHIPFLOW_ROOT/skills/references/skill-context-budget.md` only when scope touches `skills/`, skill discovery metadata, or Codex/Claude skill compliance.
- `$SHIPFLOW_ROOT/shipflow-metadata-migration-guide.md` when mode is metadata/migrate-frontmatter.

## Execution Contract

- Keep internal contracts in English; user-facing output stays in the active user/project language.
- Preserve redaction/security rules: never expose secrets, cookies, tokens, private keys, or private logs.
- Preserve documentation-update gates: changed behavior must have docs alignment proof or explicit `not impacted because ...`.
- Preserve canonical ShipFlow paths and metadata schema rules.
- `TEST_LOG.md`, `BUGS.md`, `PROJECTS.md`, and canonical workflow trackers are operational trackers, not frontmatter-required decision artifacts.

## Stop Conditions

Stop and report `blocked` when:

- required ShipFlow-owned reference is missing and no safe fallback exists
- requested migration would overwrite canonical docs without explicit merge decision
- metadata lint fails on changed artifacts and cannot be corrected safely
- governance conflicts cannot be resolved (for example `AGENTS.md` not a symlink to `AGENT.md`)

## Validation

Run focused checks for touched surfaces:

```bash
python3 tools/shipflow_metadata_lint.py <changed-artifacts>
rg -n "Maintenance Rule|Validation|Owned Files|Entrypoints" shipflow_data/technical templates/artifacts/technical_module_context.md
rg -n "Editorial Update Plan|Claim Impact Plan|pending final copy|surface missing|Astro content schema" shipflow_data/editorial docs/editorial
test ! -e AGENTS.md || { test -L AGENTS.md && test "$(readlink AGENTS.md)" = "AGENT.md"; }
```

When the scope touches skill discovery or skill docs policy:

```bash
python3 tools/skill_budget_audit.py --skills-root skills --format markdown
```
