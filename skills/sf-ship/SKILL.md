---
name: sf-ship
description: "Ship workflow for checks, commits, pushes, and optional full task closeout."
argument-hint: [optional: commit message | "end la tache" for full close | skip-check | all-dirty]
---

## Canonical Paths

Before resolving any ShipFlow-owned file, load `$SHIPFLOW_ROOT/skills/references/canonical-paths.md` (`$SHIPFLOW_ROOT` defaults to `$HOME/shipflow`). ShipFlow tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPFLOW_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Chantier Tracking

Trace category: `obligatoire`.
Process role: `lifecycle`.

Before shipping a spec-first chantier, load `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md`, then read the spec's `Skill Run History` and `Current Chantier Flow` when a unique spec exists. Append a current `sf-ship` row with result `shipped`, `not shipped`, `blocked`, or `skipped checks`, update `Current Chantier Flow`, and end the report with a compact `Chantier` block. If quick ship is not attached to one unique chantier spec, do not write to a spec; report `Chantier: non applicable` or `Chantier: non trace` with the reason.

## Report Modes

Before producing the final report, load `$SHIPFLOW_ROOT/skills/references/reporting-contract.md`.

Default to `report=user`: concise, outcome-first, and using the compact chantier block. Use `report=agent`, `handoff`, `verbose`, or `full-report` only when explicitly requested or when another agent needs detailed ship evidence.

## Context

- Current directory: !`pwd`
- Current date: !`date '+%Y-%m-%d'`
- Git status: !`git status --short 2>/dev/null || echo "Not a git repo"`
- Git diff stat: !`git diff HEAD --stat 2>/dev/null || echo ""`
- Current branch: !`git branch --show-current 2>/dev/null || echo "unknown"`
- ShipFlow development mode: !`rg -n "ShipFlow Development Mode|development_mode|validation_surface|ship_before_preview_test|post_ship_verification|deployment_provider" CLAUDE.md SHIPFLOW.md 2>/dev/null || echo "No project development mode documented"`
- Recent commits (style reference): !`git log --oneline -5 2>/dev/null || echo "no commits"`
- Master TASKS.md: !`cat ${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}/TASKS.md 2>/dev/null || cat TASKS.md 2>/dev/null || echo "No TASKS.md"`
- Existing CHANGELOG: !`head -20 CHANGELOG.md 2>/dev/null || echo "no CHANGELOG.md"`

## Your task

`sf-ship` has two modes.

Before choosing mode, read `${SHIPFLOW_ROOT:-$HOME/shipflow}/skills/references/project-development-mode.md` and inspect the project-local `## ShipFlow Development Mode` section in `CLAUDE.md` or `SHIPFLOW.md`. This does not change quick vs full shipping, but it changes the required next action after a successful push.

### Mode 1 — Quick ship (default)

Default behavior when `$ARGUMENTS` does NOT include end-of-task keywords:
- `end la tache`
- `end`
- `fin`
- `close task`

Quick mode is optimized for fast iteration:
1. Optional lightweight checks (skip if `skip-check` is present)
2. Stage
3. Commit
4. Push
5. One short report

Do NOT update TASKS.md or CHANGELOG.md in quick mode.
Do NOT claim the work is product-complete, user-story-complete, or security-validated just because it was committed and pushed.

By default, stage only changes that are clearly part of the current task/session or intentionally selected for this ship. If `$ARGUMENTS` includes `all-dirty`, ship the entire dirty Git state in the selected repo, including files not touched during the current conversation.

### Mode 2 — Full close + ship (explicit)

Only when `$ARGUMENTS` includes one of the end-of-task keywords above:
1. Summarize session
2. Update TASKS.md (master + local)
3. Update CHANGELOG.md
4. Save decisions to memory
5. Run checks (unless `skip-check`)
6. Stage, commit, push
7. One full closing report

Use this mode when the task is truly finished and should be formally closed.
Even in full mode, bookkeeping and git operations are not proof that the shipped change is functionally complete, safe, or production-ready.

---

## Step 1 — Workspace root detection

If the current directory has no `.git` directory BUT contains project subdirectories with changes, use **AskUserQuestion**:
- "Which project should I ship?"
- One option per project with uncommitted changes
- `multiSelect: false`

Then work inside that project for all remaining steps.

## Step 2 — Decide mode

Inspect `$ARGUMENTS`:
- if it contains `end la tache`, `end`, `fin`, or `close task` -> `full`
- otherwise -> `quick`

Also inspect `$ARGUMENTS` for staging scope:
- if it contains `all-dirty`, `ship-all`, or `tout-dirty` -> stage every tracked, modified, deleted, and untracked file in the selected repo after the secret check
- otherwise -> stage only the current task/session changes or ask if the staging scope is ambiguous

## Step 2.5 — Clarify shipping intent when ambiguous

If the current context suggests uncertainty about whether the work is actually ready to ship, ask a concise user question before staging. Ask only when the answer changes the closure level, release framing, or safety posture.

Typical triggers:
- the work looks partial, exploratory, or intentionally unverified
- changed files touch auth, permissions, payments, billing, secrets, tenant boundaries, destructive actions, webhooks, background jobs, migrations, or public flows
- changed files alter user-facing feature behavior while docs, README, guides, FAQ, onboarding, examples, pricing, changelog or support copy may still describe the old behavior
- checks are skipped or materially incomplete for the kind of change made
- the requested wording implies "done", "ready", or "safe" but the evidence does not support that claim

Examples:
- "Do you want a quick push for collaboration, or do you want this treated as formally closed?"
- "This touches auth/data/public flow. Should I ship with an explicit partial-risk note, or stop for clarification first?"
- "Checks are partial. Do you want a commit/push anyway, with the report stating validation is incomplete?"

## Step 3 — Safety checks before staging

Check for secrets:
- if untracked `.env`, credential, or token files are not ignored, stop and warn
- when using `all-dirty`, inspect the complete dirty file list before staging and explicitly exclude nothing unless it is a secret/safety issue; if a secret/safety issue is present, stop instead of partially staging

## Step 3.5 — Pre-ship bug risk gate (`BUGS.md` + `bugs/`)

Run a lightweight bug gate in both `quick` and `full` mode before checks/staging:
- read `BUGS.md` if present
- when a linked high-impact bug is found, open corresponding `bugs/BUG-ID.md` for confirmation
- keep this check fast; do not run a heavy audit in quick mode

Classify bug risk outcome for the ship report:
- `blocked`: at least one linked `high` or `critical` bug is still open (`open`, `needs-info`, `needs-repro`, `in-diagnosis`, `fix-attempted`)
- `partial-risk`: linked bug exists in uncertain intermediate state (for example `fixed-pending-verify`) or scope linkage is partial
- `not assessed`: no `BUGS.md`, missing `bugs/` dossiers, or scope too ambiguous for a safe claim

Rules:
- do not claim closure when bug risk is `blocked` or `partial-risk`
- for `blocked`, stop before commit unless user explicitly asks to proceed with a risk note
- quick mode must still report honest bug status, even when checks are skipped

## Step 4 — Pre-checks

If mode is `quick`:
- run lightweight checks only when practical
- skip all checks when `$ARGUMENTS` includes `skip-check`

If mode is `full`:
- run normal checks (unless `skip-check`)

Checks policy:
- if `package.json` exists: run typecheck and lint scripts if present
- do NOT run full build here by default
- if `test_*.sh` exists and shell files changed: run `bash -n` on touched shell files

Validation doctrine:
- tailor the report to the evidence actually gathered; do not imply more confidence than the checks support
- explicitly call out missing proof for user-story completion, product coherence, and security-sensitive behavior when relevant
- explicitly call out missing documentation alignment when feature behavior changed and docs were not checked
- if the change is high-risk and no meaningful validation is available, pause and ask the user instead of silently shipping under a misleading "ready" framing

If a check fails:
- stop and report failure
- suggest rerun with `skip-check` if user wants to force ship

## Step 5 — Full-mode bookkeeping (only in full mode)

Only for mode `full`:
- update master TASKS.md and local TASKS.md when relevant
- update CHANGELOG.md with meaningful grouped entries
- save useful decisions to memory
- summarize work in terms of the user story or user-facing outcome when that can be inferred from the task
- summarize documentation alignment: updated, not impacted, or remaining gap
- if closure status is still ambiguous, prefer partial/in-progress wording in TASKS or ask the user rather than forcing `done`
- treat the TASKS snapshots loaded at skill start as informational only
- right before editing any TASKS file, re-read it from disk and use that version as authoritative
- apply a minimal targeted edit to the relevant rows only; never rewrite the whole file from stale context
- if the expected row or section moved, re-read once and recompute; if it is still ambiguous, stop and ask the user

Skip this step entirely in quick mode.

## Step 6 — Stage and commit

Stage and commit.

If `$ARGUMENTS` includes `all-dirty`, `ship-all`, or `tout-dirty`, stage the entire dirty repo:
```bash
git add -A
```

Otherwise, stage only the files that belong to the current task/session, using explicit paths:
```bash
git add -- path/to/file path/to/other-file
```

When shipping changes that create, rename, or materially update `skills/*/SKILL.md`, include a pre-commit runtime visibility check in the practical check set:
```bash
${SHIPFLOW_ROOT:-$HOME/shipflow}/tools/shipflow_sync_skills.sh --check --skill <name>
```
Use `--check --all` for broad skill visibility drift. Do not duplicate symlink repair logic in `sf-ship`; route repair to the shared helper or back to the owning lifecycle skill.

Then commit:
```bash
git commit -m "[message from $ARGUMENTS or derived summary]
Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

Use a HEREDOC for commit message.

## Step 7 — Push

```bash
git push
# if no upstream: git push -u origin <branch>
```

## Step 7.5 — Post-push deployment handoff

If the push succeeds and the project development mode is `vercel-preview-push`, the immediate next action is:

```bash
/sf-prod [project name or deployment URL if known]
```

If the project development mode is `hybrid`, require the same `/sf-prod` handoff when the shipped change needs hosted validation: auth/OAuth, callbacks, webhooks, Vercel routing, edge/serverless runtime, deployment env vars, or preview/prod-only data behavior.

Do not tell the user to run manual/browser tests before `sf-prod` has confirmed the matching deployment is ready. In the report, state that the push is complete but preview validation is still pending behind `sf-prod`.

## Step 8 — One report

Report formatting rules:
- Combine push, repo state, checks, and full-mode bookkeeping into one concise status line when possible: `Pushed to origin/main. Repo clean. All checks passed ✅. Tasks/Changelog updated.`
- Use `All checks passed ✅` when every required or attempted check passed.
- Use `All checks passed except: [check], [check]` only when shipping continues despite explicitly accepted or non-blocking check gaps.
- Use `Checks skipped: [reason]` when checks are intentionally skipped.
- If push fails, replace the status line with `Push failed: [reason]. Repo [state]. [check summary].`
- In the `Chantier` block, put the spec path directly under the heading; do not prefix it with `Chantier:`.
- Use one compact `Flux:` line with status markers, for example `Flux: sf-spec ✅ -> sf-ready ✅ -> sf-start ✅ -> sf-verify ✅ -> sf-end ✅ -> sf-ship ✅🎯`.
- Omit `Trace spec`, `Verdict sf-ship`, `Reste a faire`, and `Prochaine etape` when they are redundant or empty.
- Include `Reste a faire:` only when a concrete remaining item exists.
- Include `Prochaine etape:` only when a real next command/action exists, especially required `/sf-prod` preview validation.

Quick mode report:
```text
## Shipped (Quick) — [date]

[SHORT_SHA] — "[commit message]" -> [branch]

Pushed to [remote]/[branch]. Repo [clean | dirty: reason]. [check summary].
Mode: quick (commit + push only)
Scope: [current task/session changes / all dirty repo files]
Bug risk gate: [blocked / partial-risk / not assessed / clear]
Development mode: [only when preview validation is required or status is unknown]
User story / product status: [only when partial, not assessed, or important to avoid overclaiming]
Documentation coherence: [only when changed, not assessed, or gap remains]
Security / risk note: [only when non-empty]

## Chantier

[spec path | non applicable: reason | non trace: reason]

Flux: sf-spec [status marker] -> sf-ready [status marker] -> sf-start [status marker] -> sf-verify [status marker] -> sf-end [status marker] -> sf-ship [status marker]
[Reste a faire: item, only if non-empty]
[Prochaine etape: /sf-prod [project or URL] if preview-push validation is required, only if non-empty]
```

Full mode report:
```text
## Shipped (Full) — [date]

[SHORT_SHA] — "[commit message]" -> [branch]

Pushed to [remote]/[branch]. Repo [clean | dirty: reason]. [check summary]. Tasks/Changelog updated.
Scope: [only when all-dirty or otherwise worth clarifying]
Development mode: [only when preview validation is required or status is unknown]
Bug risk gate: [blocked / partial-risk / not assessed / clear]
Session closed: [only when useful beyond the shipped title]
User story closure: [only when partial, assumed, or important]
Documentation coherence: [only when changed, not impacted in a non-obvious way, or gap remains]
Evidence limits / remaining risks: [only when non-empty]

## Chantier

[spec path | non applicable: reason | non trace: reason]

Flux: sf-spec [status marker] -> sf-ready [status marker] -> sf-start [status marker] -> sf-verify [status marker] -> sf-end [status marker] -> sf-ship [status marker]
[Reste a faire: item, only if non-empty]
[Prochaine etape: /sf-prod [project or URL] if preview-push validation is required, only if non-empty]
```

## Rules

- Quick mode is the default
- Full close flow requires explicit end-of-task keyword
- Use `all-dirty` only when the user explicitly asks to ship all dirty files, all repo changes, unrelated changes, or changes not made in the current conversation
- Do NOT force push to main/master
- Do NOT commit secrets
- If nothing to commit, say so clearly
- Keep report concise
- Do not equate commit/push, green checks, or updated tracking files with proof that the product is done or secure
- Prefer honest "shipped for iteration" wording over overstated "done" wording when validation is partial
- Prefer honest "docs not checked" wording over implying feature docs are aligned
- If the change may affect public behavior or safety posture and the status is unclear, ask before shipping
- If linked bug status is `blocked`, `partial-risk`, or `not assessed`, say it explicitly in the report.
- If project mode is `vercel-preview-push`, never make `/sf-test` the next step before `/sf-prod`.
