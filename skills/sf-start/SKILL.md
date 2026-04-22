---
name: sf-start
description: Execute a task end-to-end from kickoff to implementation. Use spec-first guardrails when the scope is non-trivial.
argument-hint: <task description or TASKS.md item>
---

## Context

- Current directory: !`pwd`
- Current date: !`date '+%Y-%m-%d'`
- Project name: !`basename $(pwd)`
- Git branch: !`git branch --show-current 2>/dev/null || echo "unknown"`
- Git status: !`git status --short 2>/dev/null || echo "Not a git repo"`
- Master TASKS.md: !`cat /home/claude/shipflow_data/TASKS.md 2>/dev/null || echo "No master TASKS.md"`
- Local TASKS.md (if exists): !`cat TASKS.md 2>/dev/null || echo "No local TASKS.md"`
- Available specs: !`find docs specs -maxdepth 2 -type f -name "*.md" 2>/dev/null | sort | head -40`

## Your task

`sf-start` is an execution skill. It should implement, not only plan.

Routing rule:
- **Small/local/clear** task: execute directly
- **Non-trivial or ambiguous** task: require a ready spec before implementation

### Step 1 — Identify the task

If `$ARGUMENTS` is provided, use it as the task description.

If `$ARGUMENTS` is empty, look at TASKS.md from context and use **AskUserQuestion**:
- Question: "Quelle tâche veux-tu commencer ?"
- `multiSelect: false`
- Options: top 5-7 uncompleted tasks from TASKS.md (highest priority first), each with its priority emoji as prefix
- Add a final option: "Autre — je décris ma tâche"

### Step 2 — Scope triage

Classify as `direct` or `spec-first`.

Signals for `spec-first`:
- multiple files or subsystems
- unclear expected behavior
- auth/data/migration/API contract implications
- likely edge cases or cross-domain impact

If `spec-first` and no matching `Status: ready` spec exists:
- stop execution
- route to:
  1. `/sf-spec [task]`
  2. `/sf-ready [task/spec]`
  3. `/sf-start [task]`

### Step 3 — Load context and track task (silent)

- Read only the 3-5 most relevant files
- Include associated tests or entry points
- Update task tracking to `🔄 in progress` in master TASKS.md
- Update local TASKS.md too when present

### Step 4 — Implement

Execute the changes directly.

Implementation constraints:
- follow existing project conventions
- keep the change inside the declared task scope
- avoid speculative refactors unrelated to the task
- if scope expands materially, stop and reroute to spec-first

### Step 5 — Quick validation

Run focused validation relevant to the modified area:
- targeted tests if available
- quick lint/type check for touched modules when practical
- syntax check for touched shell scripts if relevant

If checks fail, report clearly and include next repair action.

### Step 6 — Report

Output one concise execution report:

```text
## Started and Implemented: [task name]

Mode: [direct / spec-first]
Spec: [path or "none"]

Files changed:
- [file] — [what changed]

Validation:
- [check] -> [pass/fail]

Next step:
- /sf-verify [task]
```

### Rules

- Implement by default (do not stop at planning)
- Do NOT commit or push
- Do NOT update CHANGELOG.md (handled by end/ship flow)
- For non-trivial tasks, block without a `ready` spec
- If request and spec conflict, surface the conflict before coding
