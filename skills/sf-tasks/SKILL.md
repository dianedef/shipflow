---
name: sf-tasks
description: "Task tracker update for completed work, remaining items, and suggested next steps."
disable-model-invocation: false
argument-hint: [optional focus area or task type]
---

## Canonical Paths

Before resolving any ShipFlow-owned file, load `$SHIPFLOW_ROOT/skills/references/canonical-paths.md` (`$SHIPFLOW_ROOT` defaults to `$HOME/shipflow`). ShipFlow tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPFLOW_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Chantier Tracking

Trace category: `conditionnel`.
Process role: `pilotage`.

Before producing the final report, load `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md` when this run is attached to a spec-first chantier. If exactly one active `specs/*.md` chantier is identified, append the current run to `Skill Run History`, update `Current Chantier Flow` when the run changes the chantier state, and include a final `Chantier` block. If no unique chantier is identified, do not write to any spec; report `Chantier: non applicable` or `Chantier: non trace` with the reason.


## Context

- Current directory: !`pwd`
- **Master TASKS.md** (multi-project dashboard): !`cat ${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}/TASKS.md 2>/dev/null || echo "No master TASKS.md"`
- Local TASKS.md (if exists): !`cat TASKS.md 2>/dev/null || echo "No local TASKS.md"`
- Recent git status: !`git status --short 2>/dev/null || echo "Not a git repository"`
- Current branch: !`git branch --show-current 2>/dev/null || echo "N/A"`
- Project CLAUDE.md (if exists): !`head -30 CLAUDE.md 2>/dev/null || echo "No CLAUDE.md found"`
- Workspace CLAUDE.md: !`head -20 $HOME/CLAUDE.md 2>/dev/null || echo "N/A"`

## Multi-project tracking system

**CRITICAL**: This workspace tracks 12 projects from a single master file at `${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}/TASKS.md`.

- `TASKS.md` is an operational tracker, not a ShipFlow decision artifact. Do not add YAML frontmatter or metadata schema fields to `TASKS.md`.
- If a task contains a durable decision, spec, business rule, research conclusion, or product contract, keep the task entry concise and extract the durable content into a separate metadata-bearing artifact via `/sf-docs`, `/sf-spec`, `/sf-research`, or the relevant skill.
- **Always update `${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}/TASKS.md`** (the master tracker) — this is the single source of truth
- If working inside a sub-project (e.g., `$HOME/winflowz/`), update BOTH the local TASKS.md AND the master TASKS.md
- The master file has a Dashboard table, per-project task sections, cross-project concerns, and a backlog
- When checking off tasks in the master file, also update the Dashboard status column if the project phase changed

## Shared tracking file write protocol

- Treat the TASKS snapshots loaded at skill start as informational only.
- Right before editing the master or local TASKS file, re-read the target from disk and use that version as authoritative.
- Apply the smallest possible patch to the relevant dashboard row, project section, or backlog block; never rewrite the whole file from stale context.
- If the expected anchor moved or changed, re-read once and recompute.
- If it is still ambiguous after the second read, stop and ask the user instead of forcing the write.
- If the file is still missing after that authoritative re-read, create it from the canonical format.

## Tracker synchronization rules

- Distinguish clearly between:
  - the master tracker (`${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}/TASKS.md`)
  - a project section inside the master tracker
  - the local `TASKS.md` file inside the current repo
- The master tracker is the cross-project coordination source, not a direct substitute for a local `TASKS.md`.
- The local `TASKS.md` should represent the active project backlog and may include a small `Historical completed work` section when older project work exists only in the master tracker.
- Completed historical entries from the master tracker must not be copied into the local active backlog.
- If a local `TASKS.md` is created after project work already exists in the master tracker, first audit the existing project entries in the master tracker, then split them into:
  - active backlog
  - historical completed context
- Do not claim that a tracker "did not exist" without specifying whether you mean:
  - the master tracker
  - the project section in the master tracker
  - the local `TASKS.md` file

## Your task

Intelligently manage the TASKS.md file by:
1. Checking off completed tasks
2. Adding remaining tasks to be done
3. Suggesting the next priority action
4. **Keeping the master `${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}/TASKS.md` in sync**

### Workspace root detection

If the current directory has no project markers (not inside a specific project) — you are at the **workspace root**. Use **AskUserQuestion**:
- Question: "Which project(s) should I update tasks for?"
- `multiSelect: true`
- Options:
  - **All projects** — "Review and update tasks across the full workspace" (Recommended)
  - One option per project: label = project name, description = number of open tasks in master TASKS.md

### Steps

1. **Analyze current state**:
   - Read TASKS.md if it exists (shown in context above)
   - Check the git status and file changes to identify what's been done
   - Look for project-specific patterns in CLAUDE.md to understand the project structure

2. **Identify completed tasks**:
   - Review unchecked tasks in TASKS.md
   - Cross-reference with actual project state (files, git commits, running processes)
   - Mark tasks as complete by changing `- [ ]` to `- [x]` for done items
   - Add completion timestamps where helpful

3. **Identify remaining tasks**:
   - Based on the project context and any arguments provided by the user (`$ARGUMENTS`)
   - Consider common next steps: tests, documentation, deployment, refactoring
   - Think about the project lifecycle: setup → development → testing → deployment → maintenance
   - Look for TODOs in code, pending PRs, failing tests, or incomplete features

4. **Update TASKS.md**:
   - **Always check if TASKS.md exists first.** If it does not exist, create it using the canonical ShipFlow format below — do NOT create a bare-minimum file.
   - If project work already exists in the master tracker for this repo, import only the still-active items into the local active backlog. Historical `done` items may be copied into a short context section, but never into the active backlog.
   - If TASKS.md doesn't exist, create it with this exact structure (adapt section titles to the detected project):
     ```markdown
     # Tasks — [Project Name]

     > **Priority:** 🔴 P0 blocker · 🟠 P1 high · 🟡 P2 normal · 🟢 P3 low · ⚪ deferred
     > **Status:** 📋 todo · 🔄 in progress · ✅ done · ⛔ blocked · 💤 deferred

     ---

     ## [Section — e.g. Setup / Core Features / Infrastructure]

     | Pri | Task | Status |
     |-----|------|--------|
     | 🔴 | [First blocking task identified from project state] | 📋 todo |
     | 🟠 | [High priority task] | 📋 todo |
     | 🟡 | [Normal priority task] | 📋 todo |

     ---

     ## Historical completed work

     > Optional. Use only when older project work already exists in the master tracker and would otherwise be lost locally.

     | Pri | Task | Status |
     |-----|------|--------|
     | ✅ | [Previously completed project task imported from master tracker] | ✅ done |

     ---

     ## Backlog

     | Pri | Task | Status |
     |-----|------|--------|
     | 🟢 | [Future improvement] | 💤 deferred |

     ---

     ## Audit Findings
     <!-- Populated by /sf-audit — dated sections with Fixed: / Remaining: -->
     ```
   - When **audit findings** are added to TASKS.md (by `/sf-audit` or manually), they follow this format:
     ```markdown
     ### Audit: [Domain] (YYYY-MM-DD)

     **Fixed:**
     - [x] Description of what was resolved

     **Remaining:**
     - [ ] 🔴 Critical issue still open
     - [ ] 🟠 High-priority issue
     - [ ] 🟡 Normal issue
     ```
   - If TASKS.md exists, update it:
     - Check off completed items (change `📋 todo` → `✅ done` in Status column, or `- [ ]` → `- [x]`)
     - Add new tasks under appropriate sections using the table format
     - Preserve existing audit sections — never remove dated `### Audit:` blocks
     - Keep priority icons consistent: 🔴 🟠 🟡 🟢 ⚪

5. **Update CHANGELOG.md**:
   - Look for a `CHANGELOG.md` in the current project directory
   - If it doesn't exist, create it with a standard Keep a Changelog structure
   - Add an entry under `## [Unreleased]` (or today's date if releasing) for every task marked done in this session
   - Group entries by type: `### Added`, `### Changed`, `### Fixed`
   - Keep entries concise and user-facing (what changed, not how)
   - Example format:
     ```markdown
     ## [Unreleased]
     ### Added
     - Page /quiz dédiée fullscreen (FR + EN) avec redirection de tous les CTAs
     - Minimum 2 semaines imposé avant toute réservation (validation Zod + Calendar)
     ### Changed
     - BookingForm : typography et spacing réduits pour tenir sur un écran sans scroll
     ```

6. **Suggest next steps**:
   - Analyze the remaining tasks
   - Recommend the highest priority item based on:
     - Blockers (tasks that unblock other work)
     - Dependencies (what needs to happen first)
     - High-ROI bounded-effort opportunities
     - User's argument/focus area if provided
   - Explain why this task should be next (1-2 sentences)

### Important

- **Always update the master `${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}/TASKS.md`** — even when working in a sub-project directory
- If a local project TASKS.md also exists (e.g., `winflowz/TASKS.md`), update both: local for detail, master for dashboard
- Use the Edit tool to update existing TASKS.md or Write tool to create a new one
- Be intelligent about what's "done" - check actual evidence, don't just guess
- Keep task descriptions clear and actionable
- Use sections to organize tasks logically
- The suggestion should be specific and immediately actionable
- If the user provided arguments, use them to focus on specific task types or areas
- Preserve any manual notes or custom sections the user has added
- Add context/notes when a task is more complex than it appears
- Update the master Dashboard table's "Status" and "Top Priority" columns when significant changes occur
