---
name: sf-migrate
description: "Args: package@version optional. Framework upgrade assistant — research migration guide, scan for breaking changes, apply with backup branch"
disable-model-invocation: true
argument-hint: '[package@version] (e.g., "astro@5")'
---

## Canonical Paths

Before resolving any ShipFlow-owned file, load `$SHIPFLOW_ROOT/skills/references/canonical-paths.md` (`$SHIPFLOW_ROOT` defaults to `/home/claude/shipflow`). ShipFlow tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPFLOW_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Chantier Tracking

Trace category: `conditionnel`.
Process role: `source-de-chantier`.

Before producing the final report, load `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md` when this run is attached to a spec-first chantier. If exactly one active `specs/*.md` chantier is identified, append the current run to `Skill Run History`, update `Current Chantier Flow` when the run changes the chantier state, and include a final `Chantier` block. If no unique chantier is identified, do not write to any spec; report `Chantier: non applicable` or `Chantier: non trace` with the reason.

## Chantier Potential Intake

Because this skill has process role `source-de-chantier`, evaluate the standard threshold from `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md` before the final report. If the findings reveal non-trivial future work and no unique chantier owns it, do not write to an existing spec; add a `Chantier potentiel` block with `oui`, `non`, or `incertain`, a proposed title, reason, severity, scope, evidence, recommended `/sf-spec ...` command, and next step. If the work is only a direct local fix or already belongs to the current chantier, state `Chantier potentiel: non` with the concrete reason.


## Context

- Current directory: !`pwd`
- Project CLAUDE.md: !`head -80 CLAUDE.md 2>/dev/null || echo "no CLAUDE.md"`
- Package.json: !`cat package.json 2>/dev/null | head -60 || echo "no package.json"`
- Current versions: !`cat package.json 2>/dev/null | grep -E '"(astro|next|react|vue|svelte|expo|convex|clerk)"' | head -10 || echo "unknown"`
- Node version: !`node -v 2>/dev/null; cat .nvmrc .node-version 2>/dev/null || echo "not pinned"`
- Git status: !`git status --short 2>/dev/null | head -5 || echo "no git"`
- Current branch: !`git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown"`

## Mode detection

- **`$ARGUMENTS` is `package@version`** → Migrate that specific package to that version.
- **`$ARGUMENTS` is a package name** (no version) → Detect latest version and confirm.
- **`$ARGUMENTS` is empty** → Run `npm outdated` / `pip list --outdated`, show major upgrades, let user choose.

---

## Flow

### Step 1: Determine target

If `$ARGUMENTS` is empty:
1. Run `npm outdated` / `yarn outdated` / `pnpm outdated` or `pip list --outdated`
2. Filter for major version bumps only
3. Use **AskUserQuestion**:
   - Question: "Which package should I migrate?"
   - `multiSelect: false`
   - Options: one per major outdated package, label = "package current → latest", description = last major release date

If `$ARGUMENTS` is a package name without version:
- Look up the latest version and confirm with the user.

### Step 2: Research migration guide

Use multiple sources to find the official migration guide:

1. **Context7**: `resolve-library-id` → `query-docs` for "migration guide" or "upgrade guide"
2. **WebFetch**: Official docs migration page (e.g., `https://docs.astro.build/en/guides/upgrade-to/v5/`)
3. **Exa/WebSearch**: Community migration experiences, known issues, workarounds
4. **GitHub**: Changelog, release notes, breaking changes list

Compile a list of ALL breaking changes with:
- What changed
- Old pattern → new pattern
- Required action (code change, config change, dependency update)

### Step 3: Scan codebase for affected patterns

For each breaking change, search the codebase:

```bash
# Example: if API changed from `getStaticPaths` to `getStaticProps`
grep -rn "getStaticPaths" --include="*.ts" --include="*.tsx" --include="*.astro"
```

Build a **Migration Matrix**:

```
MIGRATION MATRIX: [package] [current] → [target]
═══════════════════════════════════════════════════
| File                    | Lines  | Change             | Effort | Auto? |
|-------------------------|--------|--------------------|--------|-------|
| src/pages/[slug].astro  | 12, 45 | getStaticPaths API | Low    | ✓     |
| astro.config.mjs        | 3-8    | Config format      | Low    | ✓     |
| src/components/Nav.tsx   | 22     | Deprecated prop    | Medium | ✗     |
...

Total: X files affected, Y auto-fixable, Z manual
═══════════════════════════════════════════════════
```

### Step 4: Propose migration plan

Present the plan to the user:

```
MIGRATION PLAN: [package] [current] → [target]
═══════════════════════════════════════════════════
1. Prerequisites
   - [any required Node version changes]
   - [any peer dependency updates needed first]

2. Auto-fixable changes ([count] files)
   - [list of changes that can be applied automatically]

3. Manual changes ([count] files)
   - [list of changes requiring human decision]

4. Configuration changes
   - [config file updates]

5. Verification
   - Run /sf-check to verify build
   - Test critical paths
═══════════════════════════════════════════════════
```

### Step 5: Get user approval

Use **AskUserQuestion**:
- Question: "How should I proceed with the migration?"
- Options:
  - **All at once** — "Apply all changes, then verify" (Recommended for small migrations)
  - **Phase by phase** — "Apply each phase, verify between steps"
  - **Just the plan** — "Save the plan, don't apply changes yet"
  - **Cancel** — "Don't migrate"

### Step 6: Create backup branch

**ALWAYS** create a backup branch before any changes:

```bash
git checkout -b migrate/[package]-[version]-backup
git checkout -    # Go back to original branch
```

Or if there are uncommitted changes:
```bash
git stash
git checkout -b migrate/[package]-[version]-backup
git checkout -
git stash pop
```

### Step 7: Apply migration

Apply changes in order:
1. Update the package version in package.json
2. Run install (`npm install` / `pnpm install` / `yarn install`)
3. Apply auto-fixable code changes
4. Apply config changes
5. Present manual changes for user review

### Step 8: Verify

Run `/sf-check` logic:
1. Typecheck
2. Lint
3. Build

If any check fails:
- Show the error
- Attempt to fix (up to 3 cycles)
- If still failing: offer to revert to backup branch

### Step 9: Report

```
MIGRATION COMPLETE: [package] [current] → [target]
═══════════════════════════════════════════════════
Backup branch:    migrate/[package]-[version]-backup
Files modified:   [count]
Auto-fixed:       [count]
Manual changes:   [count]
Build status:     [✓/✗]
═══════════════════════════════════════════════════
Next steps:
  /sf-check      — Full verification
  /sf-changelog  — Document the upgrade
  /sf-ship       — Commit and push
```

---

## Important

- **ALWAYS create a backup branch** before any changes. This is non-negotiable.
- **Never upgrade multiple majors at once.** If React is on v17, go to v18 first, then v19.
- **Stop if build breaks.** Don't push forward with a broken build.
- **Use Context7 as primary source** for migration guides — it has the most up-to-date docs.
- After migration, suggest `/sf-changelog` to document the upgrade.
- For monorepos (tubeflow): migrate all workspaces together to maintain version alignment.
- Check peer dependency compatibility before upgrading.
- If the migration guide mentions codemods, try them first (`npx @next/codemod`, etc.).
