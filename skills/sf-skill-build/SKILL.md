---
name: sf-skill-build
description: "Maintain ShipFlow skills from spec to validation and ship."
argument-hint: <new skill idea | existing skill path>
---

## Canonical Paths

Before resolving any ShipFlow-owned file, load `$SHIPFLOW_ROOT/skills/references/canonical-paths.md` (`$SHIPFLOW_ROOT` defaults to `$HOME/shipflow`). ShipFlow tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPFLOW_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Chantier Tracking

Trace category: `obligatoire`.
Process role: `lifecycle`.

Before executing from a spec-first chantier, load `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md`, read the spec's `Skill Run History` and `Current Chantier Flow`, append a current `sf-skill-build` row with result `implemented`, `partial`, `blocked`, or `rerouted`, update `Current Chantier Flow`, and end with the compact `Chantier` block from `$SHIPFLOW_ROOT/skills/references/reporting-contract.md`.

If no unique spec is identified, do not write to any spec. Route to `/sf-explore <idea>` when the skill idea is too fuzzy to frame a ready spec; otherwise route to `/sf-spec <title>`.

## Report Modes

Before producing the final report, load `$SHIPFLOW_ROOT/skills/references/reporting-contract.md`.

Default to `report=user`: concise, outcome-first, and using the compact chantier block. The detailed report template below is for `report=agent`, blocked runs, or explicit handoff.

## Master Delegation

Before choosing execution topology, load `$SHIPFLOW_ROOT/skills/references/master-delegation-semantics.md`.

This skill follows that reference; local nuances below only narrow or route it. Skill contract edits, refresh, validation, docs/help updates, public skill-page coherence, and ship preparation default to delegated sequential when subagents are available; parallel skill work requires ready `Execution Batches`.

## Master Workflow Lifecycle

Before resolving skill-maintenance phases, load `$SHIPFLOW_ROOT/skills/references/master-workflow-lifecycle.md`.

Use the shared skeleton for intake, skill-maintenance work item resolution, readiness, model/topology routing, owner-skill execution, validation, verification, and post-verify docs/help plus ship routing. Local sections below define skill placement, runtime visibility, and public-surface gates only.

## Context

- Current directory: !`pwd`
- Current date: !`date '+%Y-%m-%d'`
- Project name: !`basename $(pwd)`
- Git branch: !`git branch --show-current 2>/dev/null || echo "unknown"`
- Git status: !`git status --short 2>/dev/null || echo "Not a git repo"`
- Existing ShipFlow skills: !`find ${SHIPFLOW_ROOT:-$HOME/shipflow}/skills -mindepth 2 -maxdepth 2 -name SKILL.md | sed 's#^.*/skills/##;s#/SKILL.md##' | sort | head -120`
- Available specs: !`find docs specs -maxdepth 2 -type f -name "*.md" 2>/dev/null | sort | head -120`

## Mission

`sf-skill-build` is the lifecycle pilot for skill maintenance.

It must orchestrate this sequence for one target skill:

`sf-explore when needed -> sf-spec -> edit/create SKILL.md -> sf-skills-refresh -> skill budget audit -> sf-verify -> sf-docs/help update -> sf-ship`

The goal is not writing a skill body fast. The goal is shipping a coherent skill contract that remains discoverable, validated, and aligned across internal and public surfaces.

## Scope Gate

This skill is for ShipFlow skill maintenance only.

- Accepted scope: `skills/*/SKILL.md`, related docs/help/public skill content, and validation/reporting for that same chantier.
- Rejected scope: generic third-party skill generation, unscoped global refactors, or unrelated repo maintenance.

If the target overlaps existing skill responsibilities, stop and ask for explicit user confirmation before creating a duplicate behavior surface.

## Entry Rules

1. Resolve target skill name from argument.
2. Validate name policy before any file creation:
   - lowercase letters, numbers, and hyphens only
   - no leading/trailing hyphen
   - no `--`
   - max 64 chars
3. Search existing skills for overlap (`sf-build`, `sf-skills-refresh`, `skill-creator`, and close neighbors).
4. If overlap is material, ask one targeted question before proceeding.

## Exploration Gate

Before routing to `sf-spec`, decide whether the input is clear enough to produce a durable skill-maintenance contract.

Route to `/sf-explore <idea>` before `/sf-spec` when any of these remain true after a quick overlap scan and, if useful, one targeted question:

- the requested skill behavior is still fuzzy, aspirational, or missing a concrete operator trigger
- placement could reasonably be an existing skill mode, a new domain skill, or a new master skill and the evidence does not decide it
- the change would introduce or alter a public skill promise, lifecycle doctrine, or governance policy that is not yet understood
- there are multiple viable designs whose tradeoffs affect validation gates, docs/public-surface impact, or runtime discoverability

`sf-explore` is read-only for chantier specs. If it writes an `exploration_report`, treat that report as primary intake context for the later `sf-spec`. Do not edit `SKILL.md` until exploration has either resolved the ambiguity or explicitly recommended stopping.

## Skill Placement Gate

Before creating a new skill, decide whether the requested behavior belongs in an existing skill, a new domain skill, or a new master skill.

Prefer extending an existing skill when:

- the request is a new mode, report shape, validation gate, provider branch, or wording improvement for an existing workflow
- the same user trigger, lifecycle phase, artifact, or public promise is already owned by a skill
- the change would create a second entrypoint for the same operator intent

Create a new domain skill only when it has:

- a distinct user trigger and outcome
- a bounded owner domain not already covered by an existing skill
- its own durable artifacts, validations, evidence routing, or stop conditions
- a public skill page/use case that would not be clearer as an existing skill mode

Create a new master skill only when it orchestrates multiple existing skills or lifecycle phases, owns a durable sequence of gates, and should become a recommended entrypoint. A master skill must route to atomic skills instead of duplicating their internals.

If placement remains ambiguous, ask one targeted question before writing files when the answer is likely to settle the decision. If the ambiguity is broader than one decision, reroute to `/sf-explore <idea>` before `/sf-spec`. Recommend integration into an existing skill first unless the evidence clearly justifies a new entrypoint. Record the placement decision in the chantier spec.

## Spec-First Contract

Apply the shared readiness rules from `$SHIPFLOW_ROOT/skills/references/master-workflow-lifecycle.md`.

For non-trivial work, spec-first is mandatory.

1. If the request is too fuzzy for a spec, route to `/sf-explore <idea>` first.
2. If no matching chantier spec exists and exploration is not needed, route to `/sf-spec <title>`.
3. Run `/sf-ready <spec>` and block until status is `ready`.
4. Do not edit `SKILL.md` while readiness is `draft`, `reviewed`, or `not ready`.
5. Use one unique spec only; if multiple specs match, stop and ask the user to select one.

## Implementation Flow

### Step 1 — Build or update the skill contract

- Create or edit `skills/<name>/SKILL.md`.
- Keep internal contracts in English.
- Keep `description` to one concise sentence and keep arguments in `argument-hint`.
- Encode explicit lifecycle gates, stop conditions, and validation commands.
- For any skill that produces a final report, load `$SHIPFLOW_ROOT/skills/references/reporting-contract.md` and support concise `report=user` by default plus explicit `report=agent`/`handoff` detail mode. Do not duplicate shared reporting bricks such as the verdict timestamp inside individual skills.
- Do not duplicate full internals of `sf-spec`, `sf-skills-refresh`, `sf-verify`, `sf-docs`, `sf-help`, or `sf-ship`; orchestrate them.

### Step 2 — Enforce lifecycle gates in the skill body

The skill body must enforce:

- `sf-explore` before `sf-spec` when skill intent, placement, or public promise is too ambiguous for a durable spec
- `sf-spec` and `sf-ready` before non-trivial edits
- `sf-skills-refresh <name>` after material skill changes
- `tools/skill_budget_audit.py --skills-root skills --format markdown` after add/rename/expansion
- `sf-verify` before closure
- `sf-ship` only after verification and bounded ship scope

### Step 2.5 — Publish runtime skill links

After creating a new skill or changing a skill invocation directory, make the current operator runtimes discover it.

- If `agents/openai.yaml` exists, set `interface.display_name` to the exact skill invocation key, for example `sf-maintain`, not a title-cased label such as `SF Maintain`. The `$` skill picker should expose the same name the operator can type.
- Source: `${SHIPFLOW_ROOT:-$HOME/shipflow}/skills/<name>`
- Targets: `$HOME/.claude/skills/<name>` and `$HOME/.codex/skills/<name>`
- If a target is missing or is a stale symlink, create or repair it through the shared helper.
- If a target exists and is not a symlink, the helper blocks by default; stop and report the blocked path.
- If install-wide eligible users must also receive the skill, route to `install.sh`; current-user Claude/Codex links are still mandatory before verification.
- A successful filesystem sync may still require a new or reloaded Claude/Codex session before the skill appears in the runtime skill list.

Use this pattern with the resolved skill name:

```bash
SHIPFLOW_ROOT="${SHIPFLOW_ROOT:-$HOME/shipflow}"
skill_name="<name>"
"$SHIPFLOW_ROOT/tools/shipflow_sync_skills.sh" --repair --skill "$skill_name"
"$SHIPFLOW_ROOT/tools/shipflow_sync_skills.sh" --check --skill "$skill_name"
```

### Step 3 — Run refresh

Run `/sf-skills-refresh <name>` and apply only additive findings. Do not rewrite the skill from scratch.

### Step 4 — Run validation

Run all required checks for changed surfaces:

```bash
python3 tools/skill_budget_audit.py --skills-root skills --format markdown
python3 tools/shipflow_metadata_lint.py specs/<spec>.md README.md shipflow-spec-driven-workflow.md shipflow_data/editorial/content-map.md shipflow_data/technical shipflow_data/editorial
npm --prefix site run build
```

Also run focused `rg` checks for stale names, claim drift, and sensitive leaks when public content changed.

Verify current-user runtime links before verification:

```bash
"${SHIPFLOW_ROOT:-$HOME/shipflow}/tools/shipflow_sync_skills.sh" --check --skill "<name>"
```

### Step 5 — Update internal and public coherence

- Update `skills/sf-help/SKILL.md` when discoverability or lifecycle routing changed.
- Update `README.md` and `shipflow-spec-driven-workflow.md` when official workflow doctrine changed.
- Update `shipflow_data/technical/skill-runtime-and-lifecycle.md` and `shipflow_data/technical/code-docs-map.md` (fallback legacy `docs/technical/*`) when mapped technical behavior changed.
- Update `site/src/content/skills/<slug>.md` when the skill is public.

Public policy:

- Public by default for new/materially changed skill workflows.
- Internal-only exception requires explicit user approval in the active spec.
- Do not add ShipFlow governance frontmatter to `site/src/content/skills/*.md`.

### Step 6 — Documentation and editorial gates

Before closure, produce both statuses:

- `Documentation Update Plan`: `complete` / `no impact` / `blocked`
- `Editorial Update Plan`: `complete` / `no editorial impact` / `blocked`

### Step 7 — Verify and route

- Run `/sf-verify <spec>`.
- If verify fails, stop and return corrective next step.
- If verify passes, route to `/sf-ship "<message>"`.

## Fresh Docs Gate

When the change depends on external framework/runtime behavior (Astro schema, build/runtime behavior, SDK/provider policy), run the Documentation Freshness Gate from `$SHIPFLOW_ROOT/skills/references/documentation-freshness-gate.md`.

Record one explicit verdict:

- `fresh-docs checked`
- `fresh-docs not needed`
- `fresh-docs gap`
- `fresh-docs conflict`

If `gap` or `conflict` affects behavior/safety/scope, stop and reroute.

## Security and Abuse Constraints

Treat this skill as high-risk governance work.

- Never rename an invocation key without explicit user approval.
- Never ship with unrelated dirty files unless user explicitly authorizes wider scope.
- Never print secrets, tokens, credentials, or private keys in reports.
- Never strengthen public claims beyond verified behavior and claim register limits.
- Never bypass required gates through "local-only confidence" language.

## Stop Conditions

Stop and report `blocked` when:

- readiness is not `ready`
- skill name is invalid
- target spec is ambiguous
- exploration is required but the user asks to skip ambiguity reduction
- budget audit fails hard or unresolved warnings are policy-blocking
- metadata lint fails on changed artifacts
- required site build fails for changed public content
- current-user Claude/Codex runtime symlinks are missing, stale, or blocked by non-symlink files
- verification fails
- ship scope includes unrelated dirty files without explicit approval

## Final Report

```text
## Skill Build: [skill name]

Mode: [new skill / modify existing skill]
Spec: [path]
Result: [implemented / partial / blocked / rerouted]

Lifecycle gates:
- sf-explore -> [not needed/rerouted/completed]
- sf-spec -> [status]
- sf-ready -> [status]
- SKILL.md edit/create -> [status]
- sf-skills-refresh -> [status]
- runtime skill links -> [status]
- skill budget audit -> [pass/fail]
- sf-verify -> [status]
- sf-docs/help update -> [status]
- sf-ship route -> [status]

Validation:
- [check] -> [pass/fail]

Documentation:
- Documentation Update Plan -> [complete/no impact/blocked]
- Editorial Update Plan -> [complete/no editorial impact/blocked]

Fresh external docs:
- [checked/not needed/gap/conflict] — [dependency/version/source]

Security:
- [key control] -> [pass/fail]

Next step:
- [/sf-verify <spec> | /sf-ship <message> | corrective command]

## Chantier

Skill courante: sf-skill-build
Chantier: [spec path | non trace]
Trace spec: [ecrite | non ecrite]
Flux:
- sf-spec: [status]
- sf-ready: [status]
- sf-start: [status]
- sf-verify: [status]
- sf-end: [status]
- sf-ship: [status]

Reste a faire:
- [item or None]

Prochaine etape:
- [command]

Verdict sf-skill-build:
- [implemented | partial | blocked | rerouted]
```

## Rules

- Implement the lifecycle, not only the markdown edit.
- Do not commit or push.
- Follow the shared master delegation reference for delegated sequential defaults and spec/batch-gated parallelism.
- Ask only targeted questions when the answer changes behavior, security, naming, scope, or public promise.
- Route to `sf-explore` before `sf-spec` when skill intent or placement is too fuzzy for one targeted question to settle.
- Prefer `blocked` over guessing when ambiguity changes contract semantics.
