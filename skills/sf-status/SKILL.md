---
name: sf-status
description: "Args: optional: all | issues | dirty. Quick cross-project git dashboard — branches, uncommitted changes, sync status, last commits, with selectable view mode"
disable-model-invocation: true
argument-hint: [optional: all | issues | dirty]
---

## Canonical Paths

Before resolving any ShipFlow-owned file, load `$SHIPFLOW_ROOT/skills/references/canonical-paths.md` (`$SHIPFLOW_ROOT` defaults to `/home/claude/shipflow`). ShipFlow tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPFLOW_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Chantier Tracking

Category: `non-applicable`.

This skill does not write to chantier specs. If invoked inside a spec-first flow, do not modify `Skill Run History`; include `Chantier: non applicable` or `Chantier: non trace` in the final report when useful, with the reason and the next lifecycle command if one is obvious.


## Context

- Current directory: !`pwd`
- PROJECTS.md: !`cat /home/claude/shipflow_data/PROJECTS.md 2>/dev/null | head -20`

## Flow

### Step 0: Choose view mode

If `$ARGUMENTS` is empty, use **AskUserQuestion**:
- Question: "Quelle vue du dashboard veux-tu ?"
- `multiSelect: false`
- Options:
  - **Issues only (recommandé)** — "Affiche seulement les projets avec attention requise"
  - **Dirty only** — "Affiche seulement les projets avec changements locaux"
  - **All projects** — "Affiche tout le portefeuille"

If `$ARGUMENTS` is provided, map:
- `issues` -> issues only
- `dirty` -> dirty only
- any other value -> all projects

### Step 1: Read project registry

Read `/home/claude/shipflow_data/PROJECTS.md` to get the list of all projects with their paths. Also include ShipFlow itself (`/home/claude/shipflow`).

### Step 2: Gather git status for each project

For each project path, run these git commands (skip if path doesn't exist or isn't a git repo):

```bash
git -C [path] rev-parse --abbrev-ref HEAD 2>/dev/null    # Current branch
git -C [path] status --porcelain 2>/dev/null | wc -l     # Uncommitted changes count
git -C [path] rev-list --count @{upstream}..HEAD 2>/dev/null  # Commits ahead
git -C [path] rev-list --count HEAD..@{upstream} 2>/dev/null  # Commits behind
git -C [path] log -1 --format="%ar — %s" 2>/dev/null     # Last commit
git -C [path] stash list 2>/dev/null | wc -l              # Stashed changes
```

Run all projects in parallel using the **Task tool** with multiple agents, or sequentially with Bash if fast enough (<10s total).

### Step 3: Compile dashboard

```
══════════════════════════════════════════════════════════════════════
GIT STATUS DASHBOARD — [date]
══════════════════════════════════════════════════════════════════════

| Project          | Branch   | Uncommitted | Ahead | Behind | Last Commit           |
|------------------|----------|-------------|-------|--------|-----------------------|
| my-robots        | main     | 0           | 0     | 0      | 2d ago — Add SEO crew |
| tubeflow         | feat/ui  | 3           | 2     | 0      | 1h ago — Fix layout   |
| GoCharbon        | main     | 0           | 0     | 5      | 3d ago — New post     |
| ...              |          |             |       |        |                       |
| ShipFlow         | main     | 1           | 1     | 0      | 10m ago — Update tasks|

──────────────────────────────────────────────────────────────────────
```

Apply selected filter before rendering:
- **issues only**: show projects with uncommitted, ahead/behind, no remote, detached HEAD, or stash > 0
- **dirty only**: show projects with uncommitted > 0
- **all projects**: show all valid repos

### Step 4: Highlight issues

```
NEEDS ATTENTION
  ⚠️  tubeflow — 3 uncommitted changes on feat/ui
  ⚠️  GoCharbon — 5 commits behind remote
  ⚠️  ShipFlow — 1 uncommitted change (TASKS.md?)

QUICK ACTIONS
  → tubeflow: /sf-ship to commit and push
  → GoCharbon: git -C /home/claude/GoCharbon pull
```

Only show NEEDS ATTENTION if there are issues. Issues to flag:
- Uncommitted changes (>0)
- Behind remote (>0)
- Ahead of remote (>0, may need push)
- Detached HEAD
- No remote configured
- Stashed changes (>0)

---

## Important

- **READ-ONLY** — never modify any files or run git commands that change state.
- `PROJECTS.md` is read-only here; never edit shared tracking files from `sf-status`.
- Include ShipFlow repo itself in the dashboard.
- Skip projects whose paths don't exist on disk.
- Skip SocialFlowz if it has no git repo.
- Target execution time: under 10 seconds total.
- If a project has no remote tracking branch, show "no remote" instead of ahead/behind counts.
