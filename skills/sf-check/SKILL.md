---
name: sf-check
description: Run typecheck, lint, and build for the current project, then fix any errors found
disable-model-invocation: true
argument-hint: [fix|nofix]
---

## Context

- Current directory: !`pwd`
- Package manager lockfiles: !`ls -1 package-lock.json yarn.lock pnpm-lock.yaml requirements.txt Pipfile.lock 2>/dev/null || echo "none found"`
- Package.json scripts (if any): !`cat package.json 2>/dev/null | grep -E '^\s+"(dev|build|lint|typecheck|check|test|format)"' || echo "no package.json"`
- Project CLAUDE.md (if any): !`head -80 CLAUDE.md 2>/dev/null || echo "no CLAUDE.md"`

## Your task

Run all available checks for the current project and fix errors if found.
Treat this skill as a practical confidence pass, not as proof that the product is fully correct or secure.

### Workspace root detection

If the current directory has no project markers (no `package.json`, no `requirements.txt`, no `src/` dir) BUT contains multiple project subdirectories — you are at the **workspace root**. Use **AskUserQuestion**:
- Question: "Which project(s) should I check?"
- `multiSelect: true`
- One option per project: label = project name, description = stack
- Read project list from `/home/claude/shipflow_data/PROJECTS.md`

Then run checks for each selected project sequentially.

Shared tracking files are read-only in this skill:
- `PROJECTS.md` is only used to discover projects when running from the workspace root.
- Never edit `TASKS.md`, `AUDIT_LOG.md`, or `PROJECTS.md` from `sf-check`.

### Step 0: Choose which checks to run

If `$ARGUMENTS` is empty (not "fix" or "nofix"), use **AskUserQuestion**:
- Question: "Which checks should I run?"
- `multiSelect: true`
- Options:
  - **Typecheck** — "TypeScript/Astro type validation"
  - **Lint** — "ESLint, formatting, style rules"
  - **Build** — "Full production build"
  - **Test** — "Unit/integration tests"
  - **Dependencies** — "Quick vulnerability + outdated check (run /sf-deps for full audit)"
- All options pre-selected by default

If `$ARGUMENTS` is "fix" or "nofix", run all detected checks (skip the prompt).

### Step 1: Detect project type and run checks

Based on the context above, identify the project stack and run the appropriate commands **sequentially** (each depends on the previous passing):

**TypeScript/JavaScript projects** (has package.json):
- Typecheck: `npm run typecheck` or `yarn typecheck` or `pnpm typecheck` (match the lockfile)
- Lint: `npm run lint` or equivalent (if script exists)
- Build: `npm run build` or `pnpm build` or `yarn build`

**Astro projects** (has astro in dependencies):
- `pnpm check` or `npm run check` (Astro type checking)
- `pnpm build` or `npm run build`

**Python projects** (has requirements.txt or Pipfile):
- `python -m py_compile` on changed files, or `pytest --co -q` (collect-only) to validate
- `pytest -x` (stop on first failure)

**Bash projects** (shell scripts, no package.json):
- `bash -n` syntax check on `.sh` files
- Run test scripts if they exist (`./test_*.sh`)

Before concluding that the project is "green", explicitly note any major gap in coverage:
- No tests available
- No typecheck available on a typed codebase
- No lint script on a repo that normally uses linting
- Build skipped because no build command exists
- Checks only validate syntax/compile steps, not runtime behavior or user-facing flows

If project scripts in `CLAUDE.md` or `package.json` suggest an expected check exists but it cannot be run, report that as a risky assumption instead of silently skipping it.

### Step 1b: Check dependencies (if selected) — quick scan only

> For comprehensive dependency auditing (unused deps, license compliance, type coverage, supply chain), run `/sf-deps`.

**Node.js projects** (has package.json):
- Run `npm audit --audit-level=high` / `yarn audit` / `pnpm audit` — report critical/high vulnerabilities only
- Run `npm outdated` / `yarn outdated` / `pnpm outdated` — show summary count (X patch, Y minor, Z major)

**Python projects** (has requirements.txt):
- Run `pip-audit` if available — report critical/high vulnerabilities only
- Run `pip list --outdated` — show summary count

Report a quick summary. Do NOT auto-update dependencies. Recommend `/sf-deps` for full analysis (unused, duplicates, licenses, configuration).

Do not present a clean dependency scan as a security sign-off. If dependency checks were not available, required auth to registry services, or only partial results were obtained, state that explicitly.

### Step 2: Fix errors

If `$ARGUMENTS` is "nofix", stop here and just report the errors.

Otherwise (default behavior, including when `$ARGUMENTS` is "fix" or empty):

1. Read each error message carefully.
2. Open the failing file(s) and fix the root cause.
3. Re-run the failed check to confirm the fix works.
4. Repeat until all checks pass or you've attempted 3 fix cycles.

Do not "fix" a failing check by weakening the intended guardrail unless the user explicitly asked for that tradeoff. In particular:
- Do not disable lint/type/test/build rules just to get green output
- Do not replace meaningful assertions with trivial ones
- Do not remove validation, auth, authorization, or error handling paths to silence failures
- If a passing result depends on a risky assumption, surface it in the report

### Step 3: Report

Summarize what was checked, what failed, and what was fixed. If anything still fails after 3 attempts, explain the remaining errors clearly so the user can decide what to do.

Always include a short `Risky assumptions / gaps` section when any of the following is true:
- a relevant check was unavailable or skipped
- the repo has no meaningful runtime or integration coverage
- a dependency/security check could not be completed
- the build passes but warnings suggest a likely product-quality or security issue

If nothing indicates functional validation of the main user flow, say so plainly. Example: "Checks pass, but no evidence was gathered that checkout/login/sync actually works end-to-end."

### Important

- Use the correct package manager for the project (check lockfiles).
- Do not install dependencies — if something is missing, tell the user.
- Do not modify test expectations to make tests pass. Fix the actual code.
- If the project CLAUDE.md specifies custom check commands, use those instead.
- A passing `sf-check` run means "no obvious issues in the checks that were executed", not "product is production-ready".
- When security-relevant checks fail or are missing (for example auth flows, permission boundaries, secret/config validation, dependency audit access), call that out explicitly and recommend the next skill when appropriate (`/sf-verify`, `/sf-prod`, `/sf-deps`).
