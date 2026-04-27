---
name: sf-ship
description: "Args: skip-check, all-dirty/ship-all/tout-dirty, end/fin/close task. Ship changes quickly by default (commit + push). Run full session-closing flow only when explicitly requested."
argument-hint: [optional: commit message | "end la tache" for full close | skip-check | all-dirty]
---

## Canonical Paths

Before resolving any ShipFlow-owned file, load `$SHIPFLOW_ROOT/skills/references/canonical-paths.md` (`$SHIPFLOW_ROOT` defaults to `/home/claude/shipflow`). ShipFlow tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPFLOW_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Chantier Tracking

Category: `obligatoire`.

Before shipping a spec-first chantier, load `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md`, then read the spec's `Skill Run History` and `Current Chantier Flow` when a unique spec exists. Append a current `sf-ship` row with result `shipped`, `not shipped`, `blocked`, or `skipped checks`, update `Current Chantier Flow`, and end the report with a `Chantier` block plus `Verdict sf-ship: ...`. If quick ship is not attached to one unique chantier spec, do not write to a spec; report `Chantier: non applicable` or `Chantier: non trace` with the reason.

## Context

- Current directory: !`pwd`
- Current date: !`date '+%Y-%m-%d'`
- Git status: !`git status --short 2>/dev/null || echo "Not a git repo"`
- Git diff stat: !`git diff HEAD --stat 2>/dev/null || echo ""`
- Current branch: !`git branch --show-current 2>/dev/null || echo "unknown"`
- Recent commits (style reference): !`git log --oneline -5 2>/dev/null || echo "no commits"`
- Master TASKS.md: !`cat /home/claude/shipflow_data/TASKS.md 2>/dev/null || cat TASKS.md 2>/dev/null || echo "No TASKS.md"`
- Existing CHANGELOG: !`head -20 CHANGELOG.md 2>/dev/null || echo "no CHANGELOG.md"`

## Your task

`sf-ship` has two modes.

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

## Step 8 — One report

Quick mode report:
```text
## Shipped (Quick) — [date]

[SHORT_SHA] — "[commit message]" -> [branch]
Checks: [passed / skipped / failed]
Mode: quick (commit + push only)
Scope: [current task/session changes / all dirty repo files]
User story / product status: [not assessed / partially validated / validated enough for this iteration]
Documentation coherence: [updated / not impacted / gap remains / not assessed]
Security / risk note: [none / partial validation / specific remaining risk]
[✓ Pushed] or [push failure]

## Chantier

Skill courante: sf-ship
Chantier: [spec path | non applicable | non trace]
Trace spec: [ecrite | non ecrite | non applicable]
Flux:
- sf-spec: [status]
- sf-ready: [status]
- sf-start: [status]
- sf-verify: [status]
- sf-end: [status]
- sf-ship: [shipped | not shipped | blocked | skipped checks]

Reste a faire:
- [item or None]

Prochaine etape:
- [explicit action | None]

Verdict sf-ship:
- [shipped | not shipped | blocked | skipped checks]
```

Full mode report:
```text
## Shipped (Full) — [date]

[SHORT_SHA] — "[commit message]" -> [branch]
Checks: [passed / skipped / failed]
Scope: [current task/session changes / all dirty repo files]
Tasks/Changelog: updated
Session closed: [completed/in-progress summary]
User story closure: [what outcome is actually complete, partially complete, or still assumed]
Documentation coherence: [updated / not impacted / gap remains]
Evidence limits / remaining risks: [brief, explicit]
[✓ Pushed] or [push failure]

## Chantier

Skill courante: sf-ship
Chantier: [spec path | non applicable | non trace]
Trace spec: [ecrite | non ecrite | non applicable]
Flux:
- sf-spec: [status]
- sf-ready: [status]
- sf-start: [status]
- sf-verify: [status]
- sf-end: [status]
- sf-ship: [shipped | not shipped | blocked | skipped checks]

Reste a faire:
- [item or None]

Prochaine etape:
- [explicit action | None]

Verdict sf-ship:
- [shipped | not shipped | blocked | skipped checks]
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
