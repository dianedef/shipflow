# sf-test

> Turn finished work into guided manual test evidence, then capture bugs in a form the next agent can actually fix.

## What It Does

`sf-test` is the missing layer between "the agent thinks the work is ready" and "a human has tried the real user flow."

It guides the user through concrete manual test scenarios, asks for structured outcomes, and records what happened. When a test fails, the result becomes a reusable bug record instead of disappearing into chat history.

```text
sf-spec
  -> sf-ready
  -> sf-start
  -> sf-check
  -> sf-verify
  -> sf-test
  -> sf-fix when a bug is found
  -> sf-test --retest
  -> sf-ship
```

The skill is not meant to replace automated tests. It covers the human-facing and browser-facing proof that is often missing from a green build: login, onboarding, redirects, protected pages, uploads, billing flows, generation flows, and other behavior where the real path matters.

## Who It's For

- Solo founders who need to test shipped work without writing a QA plan from scratch
- Developers who want a repeatable manual test protocol after implementation
- Teams that need bugs and retests captured as project memory, not scattered conversation

## When To Use It

- after `sf-verify`, before `sf-ship`
- when the feature has a visible user workflow
- when auth, payments, onboarding, uploads, data persistence, or redirects are involved
- after a bug fix, to retest the exact failed scenario
- when the user should be guided through what to click, observe, and report

## What You Give It

- the current task, spec, or recently implemented feature
- the environment to test, such as local, preview, or production
- optionally a specific flow, bug id, or retest target

## What You Get Back

- a focused manual test campaign
- step-by-step instructions for the user
- structured result choices such as pass, error page, infinite loading, wrong redirect, missing data, or custom observation
- a `TEST_LOG.md` entry after the user reports what happened
- a `BUGS.md` entry when the reported result fails
- a clean route into `sf-fix` when the bug is actionable

## Example: Google Auth

Instead of asking "does login work?", `sf-test` should guide the actual flow:

```text
1. Open the app in a private browser window.
2. Go to /login.
3. Click "Continue with Google".
4. Select the intended Google account.
5. Wait for the app callback to complete.
6. Confirm that the app lands on the expected page.
7. Reload the page.
8. Confirm that the session persists.
9. Open a protected route directly.
10. Confirm that access still works without logging in again.
```

Then it should ask for a structured result:

```text
Result?
- Login worked and session persisted
- OAuth or callback error page
- Infinite loading
- Returned to login after Google
- Logged in but protected route failed
- Wrong account, workspace, or destination
- Other observation
```

## Why It Matters

Without this step, a bug report often looks like this:

```text
User: "It does not work, I have a blank page."
Agent: keeps the detail in temporary context.
New session: the bug is effectively gone.
```

With `sf-test`, the same signal becomes project memory:

```text
Observation -> scenario -> result -> bug id -> fix -> retest history
```

That gives future agents the reproduction steps, expected behavior, environment, and history they need to act without making the user re-explain everything.

## Proposed Artifacts

`TEST_LOG.md` should record campaigns and scenario outcomes:

```markdown
## 2026-04-26 - Google Auth

Scope: Google login through Clerk
Environment: preview
Scenario: first login and session persistence
Status: fail
Observed: Infinite loading after Google callback
Expected: Redirect to dashboard with a persisted session
Follow-up bug: BUG-2026-04-26-001
```

`BUGS.md` should record actionable defects:

```markdown
## BUG-2026-04-26-001 - Infinite loading after Google callback

Status: open
Severity: high
Source: sf-test
Feature: Google Auth
Environment: preview
Expected: session created, then dashboard redirect
Observed: callback page never resolves
Next step: /sf-fix Infinite loading after Google callback
```

## Typical Examples

```bash
/sf-test
/sf-test Google Auth
/sf-test --retest BUG-2026-04-26-001
/sf-test --prod onboarding flow
```

## Limits

`sf-test` depends on human observation for flows that cannot be safely or fully automated. It should not invent generic QA scripts detached from the spec, diff, acceptance criteria, or recent verification findings. It also must not log a pass or fail result before the user answers, unless the agent directly collected browser/tool evidence in the same run.

It records evidence; it does not prove the absence of every bug.

## Related Skills

- `sf-verify` before manual test planning
- `sf-auth-debug` when auth failure needs browser-level diagnosis
- `sf-fix` when a failed test creates an actionable bug
- `sf-ship` once checks, verification, and testing are good enough
