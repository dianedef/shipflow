---
name: sf-test
description: Guided manual QA after implementation — prompts the user through concrete test steps, captures structured results, writes TEST_LOG.md, and opens BUGS.md entries when failures are found.
argument-hint: [optional: feature, flow, bug id, --retest BUG-ID, --prod, --preview, --local]
---

## Context

- Current directory: !`pwd`
- Current date: !`date '+%Y-%m-%d'`
- Project name: !`basename $(pwd)`
- Git branch: !`git branch --show-current 2>/dev/null || echo "unknown"`
- Git status: !`git status --short 2>/dev/null || echo "Not a git repo"`
- Git diff stat: !`git diff --stat 2>/dev/null || echo "no diff"`
- Recent commits: !`git log --oneline -8 2>/dev/null || echo "no commits"`
- Master TASKS.md: !`cat /home/claude/shipflow_data/TASKS.md 2>/dev/null | head -80 || echo "No master TASKS.md"`
- Local TASKS.md: !`cat TASKS.md 2>/dev/null | head -80 || echo "No local TASKS.md"`
- Existing test log: !`tail -80 TEST_LOG.md 2>/dev/null || echo "No TEST_LOG.md"`
- Existing bugs: !`tail -80 BUGS.md 2>/dev/null || echo "No BUGS.md"`
- Available specs: !`find docs specs -maxdepth 3 -type f -name "*.md" 2>/dev/null | sort | head -40`
- Existing docs/pages: !`find docs src content app site/src/content -maxdepth 3 -type f \( -name "*.md" -o -name "*.mdx" -o -name "*.astro" -o -name "*.tsx" \) 2>/dev/null | head -60`

## Your Task

Run a guided manual test campaign for the current work, then log the evidence.

This skill exists because technical checks and pre-ship verification can still leave one question unanswered:

```text
Did a real human try the real user flow?
```

`sf-test` must:
- identify the feature or bug flow to test
- generate concrete manual steps the user can follow
- prompt the user with structured result choices
- wait for the user's answer before claiming a result
- write a durable `TEST_LOG.md` entry
- write or update a durable `BUGS.md` entry when the result fails
- route the next step to `sf-fix`, `sf-auth-debug`, `sf-verify`, or `sf-ship`

Do not treat this skill as a generic "run tests" command. It is guided manual QA plus project memory.

## Core Rule

Never invent test results.

If you did not observe the behavior yourself with tooling and the user has not reported the result, the status is `not run`.

The normal flow is:

```text
generate protocol -> ask user to perform it -> collect answer -> log evidence -> route next step
```

If the platform supports an interactive choice tool, use it for the result prompt. If not, ask the user a concise question with numbered or bulleted choices and wait for their reply.

## Mode Detection

Parse `$ARGUMENTS`:

- empty: infer the most likely recent feature from git diff, recent commits, in-progress tasks, and specs
- free text: use it as the feature or flow to test
- `--local`: local environment test
- `--preview`: preview/staging environment test
- `--prod`: production environment test; avoid destructive or irreversible actions unless explicitly approved
- `--retest BUG-ID`: retest a known bug from `BUGS.md`
- a route or URL: use it as the starting surface when relevant
- a spec path: use that spec as the test contract

If the scope is unclear, ask one targeted question:

```text
Quel flow veux-tu tester exactement ?
```

Prefer options inferred from current context:
- recent feature
- in-progress task
- changed route/page/API
- open bug id
- "Tout le travail récent"

## Step 1 — Reconstruct the Test Contract

Build a lightweight contract before writing prompts.

Use, in this order:
- a matching ready spec if available
- the bug record when retesting
- recent git diff and commits
- in-progress task descriptions
- docs or README references only when they clarify expected user behavior

Extract:
- feature or bug name
- user story in one line
- environment: `local`, `preview`, `prod`, or `unknown`
- entry point: route, command, screen, page, or action
- expected success behavior
- expected error behavior
- risky edge case to include
- data, auth, payment, destructive, or external side-effect constraints
- evidence needed to judge pass/fail

If the expected behavior is ambiguous in a way that changes product meaning, permissions, data, money, destructive side effects, or security, stop and ask the user before testing.

## Step 2 — Choose Scenario Types

Generate only scenarios that match the feature.

Common scenario families:

- **Happy path**: the intended user flow succeeds
- **Persistence path**: reload, revisit, saved state, session, or stored data still works
- **Permission path**: protected route, owner/admin/member, logged-out behavior
- **Error path**: invalid input, missing dependency, declined auth, expired session, unavailable backend
- **Regression path**: nearby flow that might have been broken by the change
- **Retest path**: exact reproduction steps from a known bug

For auth, OAuth, callbacks, protected routes, cookies, or session persistence:
- include browser-level steps
- include reload and direct protected-route checks when relevant
- if the test fails, route to `sf-auth-debug` unless the bug is obviously unrelated to auth configuration or browser state

For production:
- keep steps read-only or reversible by default
- explicitly mark any step that creates data, sends email, triggers billing, deletes data, publishes content, or calls external services
- ask for confirmation before destructive or costly test steps

## Step 3 — Prompt the User

Give the user a compact test card.

Format:

```text
Manual test: [feature/flow]
Environment: [local/preview/prod/unknown]
Goal: [one-line expected user outcome]

Steps:
1. ...
2. ...
3. ...

Report the result:
- PASS: [success condition]
- FAIL_ERROR: [error page/message]
- FAIL_LOADING: infinite loading or blocked pending state
- FAIL_REDIRECT: wrong route, loop, or sent back to login
- FAIL_DATA: missing, stale, duplicated, or wrong data
- FAIL_PERMISSION: user can/cannot access something incorrectly
- FAIL_UI: visible UI break, inaccessible control, or confusing state
- BLOCKED: could not run the test
- OTHER: describe what happened
```

Ask for only the evidence needed:
- final URL or screen
- visible error message
- whether data/session persisted after reload
- account/role used, when relevant
- screenshot path or copied console/network error, if the user has it

Do not overwhelm the user with every possible edge case in one prompt. For a broad feature, run 2-4 scenarios sequentially.

## Step 4 — Interpret the Reply

Normalize the user's answer into:

- `pass`
- `fail`
- `blocked`
- `not run`

Also capture:
- category: `error`, `loading`, `redirect`, `data`, `permission`, `ui`, `unknown`
- observed behavior
- expected behavior
- reproduction steps actually executed
- environment
- evidence supplied
- confidence: `high`, `medium`, or `low`
- whether a bug should be opened

If the reply is vague, ask one follow-up question before logging a failure:

```text
Tu étais sur quelle URL ou quel écran au moment du blocage, et qu'est-ce qui était visible ?
```

Do not ask more than needed to make the bug actionable.

## Step 5 — Write TEST_LOG.md

Right before editing `TEST_LOG.md`, re-read it from disk if it exists.

If it does not exist, create it.

Append a new entry. Do not rewrite old entries.

Use this format:

```markdown
## YYYY-MM-DD - [Feature or Flow]

- Scope: [feature, bug id, or spec]
- Environment: [local|preview|prod|unknown]
- Tester: user
- Source: sf-test
- Status: [pass|fail|blocked|not run]
- Confidence: [high|medium|low]

### Scenario: [name]

Steps:
1. [step actually requested]
2. [step actually requested]

Expected:
- [expected behavior]

Observed:
- [user-reported result or tool-observed result]

Evidence:
- [URL, message, screenshot path, logs, "none supplied"]

Follow-up:
- [none / BUG-ID / next command]
```

Rules:
- `TEST_LOG.md` is an operational evidence tracker. Do not add ShipFlow metadata frontmatter.
- Do not mark `pass` unless the user or tooling confirmed the success condition.
- Use `blocked` when the user could not run the scenario.
- Use `not run` only when recording a planned campaign that was not executed.

## Step 6 — Write or Update BUGS.md

If the normalized result is `fail`, create or update `BUGS.md`.

Right before editing `BUGS.md`, re-read it from disk if it exists.

Bug id format:

```text
BUG-YYYY-MM-DD-001
```

Use the next available number for the day.

Append a new bug unless:
- `--retest BUG-ID` was used
- or the same open bug already exists and clearly matches the observed behavior

Use this format for new bugs:

```markdown
## BUG-YYYY-MM-DD-001 - [short title]

- Status: open
- Severity: [critical|high|medium|low]
- Source: sf-test
- Feature: [feature]
- Environment: [local|preview|prod|unknown]
- Category: [error|loading|redirect|data|permission|ui|unknown]
- First seen: YYYY-MM-DD
- Last tested: YYYY-MM-DD

### Reproduction

1. [step]
2. [step]

### Expected

- [expected behavior]

### Observed

- [observed behavior]

### Evidence

- [URL, error, screenshot path, logs, or "none supplied"]

### Retest History

- YYYY-MM-DD: failed via sf-test

### Next Step

- /sf-fix [short bug title]
```

For retests:
- update `Last tested`
- append to `Retest History`
- if pass, set `Status: fixed-pending-verify` unless the project uses a different explicit status
- if still failing, keep `Status: open`
- do not delete old bug details

Severity defaults:
- `critical`: data loss, payment, security, destructive action, privacy leak, total production outage
- `high`: login blocked, core workflow blocked, protected route broken, paid/core feature unusable
- `medium`: important workflow degraded with workaround
- `low`: cosmetic, copy, minor UI issue, non-blocking edge case

## Step 7 — Route Next Step

After logging:

- if all required scenarios pass: recommend `/sf-verify [scope]` if not already done, otherwise `/sf-ship`
- if a bug was opened: recommend `/sf-fix [bug title]`
- if auth/browser evidence is needed: recommend `/sf-auth-debug [bug title]`
- if the test was blocked by unclear expected behavior: recommend `/sf-spec [scope]` or `/sf-ready [scope]`
- if the test was blocked by environment/deploy: recommend `/sf-prod` or the project-specific deployment check

## Output Format

When first prompting the user, output only:

```text
## Manual Test: [feature]

Environment: [environment]
Goal: [goal]

Steps:
1. ...

Report the result:
- PASS: ...
- FAIL_ERROR: ...
- FAIL_LOADING: ...
- FAIL_REDIRECT: ...
- FAIL_DATA: ...
- FAIL_PERMISSION: ...
- FAIL_UI: ...
- BLOCKED: ...
- OTHER: ...
```

After the user replies and logs are written, output:

```text
## Test Logged: [feature]

Result: [pass|fail|blocked|not run]
Scenario: [name]
Evidence: [short summary]

Files updated:
- TEST_LOG.md
- BUGS.md [if applicable]

Next step:
- [exact command]
```

## Rules

- Prompt the user; do not silently skip the human test loop.
- Do not log a result before the user answers, unless browser/tool evidence was directly collected in this run.
- Do not invent URLs, accounts, screenshots, logs, or errors.
- Keep test steps concrete and executable.
- Prefer one focused scenario at a time over a huge QA checklist.
- Record operational evidence in `TEST_LOG.md` and defects in `BUGS.md`.
- Do not put YAML frontmatter in `TEST_LOG.md` or `BUGS.md`.
- Keep bug records actionable enough for `sf-fix`.
- Preserve existing log and bug history.
- Do not commit or push.
