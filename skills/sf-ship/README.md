# sf-ship

> Commit and push quickly by default, with an optional full closeout flow when the task is truly finished.

## What It Does

`sf-ship` handles the final git step for a work session. In quick mode, it runs lightweight checks when practical, stages changes, commits, pushes, and reports what happened. In explicit closeout mode, it also updates task tracking, changelog state, and session closure details before shipping.

The skill is designed to keep iteration fast without pretending that a successful push proves product completeness or security.

## Who It's For

- Solo founders shipping frequently
- Developers who want a consistent “commit + push” workflow
- Teams that need a distinction between “shared for iteration” and “formally closed”

## When To Use It

- when code is ready to commit and push
- when you want a fast iteration ship without bookkeeping
- when a task is actually done and you want the full closeout path

## What You Give It

- a git repo with local changes
- optionally a commit message
- optionally `skip-check`
- optionally an end-of-task keyword such as `end`, `fin`, or `close task`
- optionally `all-dirty`, `ship-all`, or `tout-dirty` when you explicitly want every dirty file in the repo included

## Arguments And Scope

By default, `sf-ship` stages only changes that clearly belong to the current task or intentionally selected shipping scope. This keeps unrelated work from being bundled into a commit by accident.

- `skip-check` skips pre-commit checks and the report must say validation was skipped.
- `end`, `fin`, `close task`, or `end la tache` switches to the full closeout flow.
- `all-dirty`, `ship-all`, or `tout-dirty` stages the whole dirty repo after the secret check, including modified, deleted, and untracked files that were not touched in the current conversation.

## What You Get Back

- a staged, committed, and pushed change
- a short shipping report with branch, commit, checks, and remaining risk framing
- in full-close mode: updated `TASKS.md` and `CHANGELOG.md`

## Typical Examples

```bash
/sf-ship fix login redirect
/sf-ship skip-check
/sf-ship end add billing retry handling
/sf-ship ship release notes all-dirty
```

## Limits

`sf-ship` is not a release certification tool. It can push unverified iteration work if you ask it to, but it should stay explicit when checks are partial, docs were not reviewed, or risky surfaces changed. It also does not replace a deeper validation pass for auth, payments, data, or public flows.

## Related Skills

- `sf-check` for fuller technical validation
- `sf-verify` for ship-readiness and risk review
- `sf-review` for session closure and next-step planning
- `sf-tasks` when tracker updates are needed without pushing code
