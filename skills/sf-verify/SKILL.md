---
name: sf-verify
description: "Verify ship readiness, correctness, coherence, and risk."
argument-hint: [optional: tâche ou scope à vérifier]
---

## Canonical Paths

Before resolving any ShipFlow-owned file, load `$SHIPFLOW_ROOT/skills/references/canonical-paths.md` (`$SHIPFLOW_ROOT` defaults to `$HOME/shipflow`). ShipFlow tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPFLOW_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Instruction Layering

Load `$SHIPFLOW_ROOT/skills/references/skill-instruction-layering.md` before execution. This skill keeps local verdict semantics and six verification dimensions, while detailed gate playbooks are loaded from references.

## Chantier Tracking

Trace category: `obligatoire`.
Process role: `lifecycle`.

Before verifying a spec-first chantier, load `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md`, then read the spec's `Skill Run History` and `Current Chantier Flow` when a unique spec exists. Append a current `sf-verify` row with result `verified`, `not verified`, `partial`, or `blocked`, update `Current Chantier Flow`, and end the report with the compact `Chantier` block from `$SHIPFLOW_ROOT/skills/references/reporting-contract.md`. If no unique spec is available, do not write to a spec; report `Chantier: non applicable` or `Chantier: non trace` with the reason.

Verification semantics:

- `partial`: implementation appears complete but required proof is missing (manual QA, preview/prod proof, browser/auth proof, Sentry pointer, device-only validation).
- Never downgrade completed `sf-start` implementation semantics only because verification evidence is incomplete.
- Keep the distinction explicit: `sf-start: implemented` vs `sf-verify: partial`.

## Report Modes

Before producing the final report, load `$SHIPFLOW_ROOT/skills/references/reporting-contract.md`.

Default to `report=user`: concise, findings-first when verification fails, compact chantier block.
Use `report=agent` for handoff, blocked runs, or explicit verbose request.

## Context

- Current directory: !`pwd`
- Current date: !`date '+%Y-%m-%d'`
- Project name: !`basename $(pwd)`
- Git branch: !`git branch --show-current 2>/dev/null || echo "unknown"`
- Git diff stat: !`git diff HEAD --stat 2>/dev/null || echo "no changes"`
- Recent commits: !`git log --oneline -10 2>/dev/null || echo "no commits"`

## Verification Contract

Verify ship-readiness across six dimensions:

1. User story outcome
2. Completeness
3. Correctness
4. Coherence
5. Dependencies
6. Risks

Mandatory explicit checks:

- `Success Behavior` pass/partial/fail/not demonstrated
- `Error Behavior` pass/partial/fail/not demonstrated
- `Bug Gate` (clear/partial-risk/blocks ship/not assessed)
- project development mode and validation surface
- fresh external docs verdict (`fresh-docs checked|not needed|gap|conflict`)
- documentation coherence verdict
- language doctrine verdict for ShipFlow artifacts

## Required References

Always load:

1. `$SHIPFLOW_ROOT/skills/sf-verify/references/verification-gates.md`
2. `$SHIPFLOW_ROOT/skills/references/project-development-mode.md`
3. `$SHIPFLOW_ROOT/skills/references/documentation-freshness-gate.md`

Load on demand:

- `$SHIPFLOW_ROOT/skills/references/sentry-observability.md` when runtime failures/observability/deployed behavior are in scope.
- `/sf-auth-debug` evidence for auth/session/callback/protected-route proof.
- `/sf-browser` evidence for non-auth browser proof.

## Skill Coherence Check (when scope touches ShipFlow skills)

When verified changes include `skills/*/SKILL.md`:

- each changed skill must expose `Trace category` and `Process role`
- changed `source-de-chantier` skills must still contain chantier-potential guidance
- changed helper skills must not present themselves as chantier sources
- if runtime-discoverable skills changed, run `tools/shipflow_sync_skills.sh --check --skill <name>` or `--check --all`

## Tracker Rule

`sf-verify` can patch code/docs when contract is stable, but shared trackers are read-only in this skill:

- do not edit `TASKS.md`, `AUDIT_LOG.md`, `PROJECTS.md` from `sf-verify`
- do not treat tracker frontmatter absence as defect

## Stop Conditions

Report `not verified` or `blocked` when:

- no reliable scope/work-item contract can be identified
- high/critical bug in scope is still open
- required validation surface is missing for `vercel-preview-push`/`hybrid` scope
- critical security/data/workflow risk is unproven or failing

## Validation

Run focused checks based on scope and diff:

```bash
rg -n "Trace category|Process role|Success Behavior|Error Behavior|fresh-docs|Chantier" skills/sf-verify/SKILL.md
python3 tools/skill_budget_audit.py --skills-root skills --format markdown
```
