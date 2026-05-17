---
name: sf-review
description: "Review session changes, docs, summaries, and next steps."
disable-model-invocation: false
argument-hint: [optional: daily, weekly, sprint, release]
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
- Recent commits (last 10): !`git log --oneline --date=short --pretty=format:"%h %ad %s" -10 2>/dev/null || echo "Not a git repo"`
- Files changed recently: !`git diff --name-status HEAD~5..HEAD 2>/dev/null || echo "N/A"`
- Current branch: !`git branch --show-current 2>/dev/null`
- Git status: !`git status --short 2>/dev/null`
- CHANGELOG.md (last 30 lines): !`tail -30 CHANGELOG.md 2>/dev/null || echo "No CHANGELOG.md"`
- Workspace CLAUDE.md: !`head -20 $HOME/CLAUDE.md 2>/dev/null || echo "N/A"`

## Multi-project tracking system

**CRITICAL**: This workspace tracks 12 projects from a single master file at `${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}/TASKS.md`.

- **Always update `${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}/TASKS.md`** as part of the review — check off completed tasks, update the Dashboard table, and refresh the "Last updated" date
- When reviewing from a sub-project directory, also consider the master-level cross-project concerns
- The review summary should reference which project(s) were worked on and how the master Dashboard changed
- When planning next session, suggest tasks from the master file's highest-priority items across all projects

## Shared tracking file write protocol

- Treat the TASKS snapshots loaded at skill start as informational only.
- Right before editing the master or local TASKS file, re-read the target from disk and use that version as authoritative.
- Apply a minimal targeted edit to the relevant dashboard rows and project sections; never rewrite the whole file from stale context.
- If the expected anchor moved or changed, re-read once and recompute.
- If it is still ambiguous after the second read, stop and ask the user instead of forcing the write.

## Your task

Conduct a comprehensive review of recent work and prepare for the next session.
This is a review and closure aid, not a truth machine. Commits, changed files, updated docs, and changelog entries are evidence of activity; they are not by themselves proof that the product outcome is complete, coherent, or secure.

### Workspace root detection

If the current directory has no `.git` directory (not a git repo) BUT contains multiple project subdirectories — you are at the **workspace root**. Use **AskUserQuestion**:
- Question: "Which project(s) should I review?"
- `multiSelect: true`
- One option per project: label = project name, description = recent commit count (run `git -C [path] log --oneline --since="7 days" 2>/dev/null | wc -l` for each)
- Only list projects with recent activity

### Steps

1. **Determine review scope** — if `$ARGUMENTS` is empty, use **AskUserQuestion**:
   - Question: "What time scope for this review?"
   - `multiSelect: false`
   - Options:
     - **Daily** — "Last 24 hours of work"
     - **Weekly** — "Last 7 days of commits" (Recommended)
     - **Sprint** — "Since last sprint start (~2 weeks)"
     - **Release** — "All changes since last release"

   If `$ARGUMENTS` is provided (daily/weekly/sprint/release), skip the prompt and use it directly.

2. **Analyze what was accomplished**:
   - Review completed tasks in TASKS.md
   - Examine git commits for actual changes
   - Identify files modified (from git diff)
   - Note any deployed changes or releases
   - Reconstruct the intended user story or user-facing outcome when possible
   - Distinguish clearly between `implemented`, `verified`, and `assumed`
   - Identify docs, README, guides, FAQ, onboarding, examples, pricing, changelog or support surfaces changed or made stale

3. **Assess work quality**:
   - Are there tests for new features?
   - Is documentation updated?
   - Are there any quick fixes that need proper solutions?
   - Any technical debt introduced?
   - Security or performance concerns?
   - Does the work preserve product coherence with the surrounding flow, terminology, permissions model, and expected user journey?
   - Does the documentation preserve the same feature behavior, limits, setup steps and promises as the code?
   - Are there evidence gaps where the review should explicitly avoid claiming `done` or `safe`?

4. **Update CHANGELOG.md**:
   - Add new section for this review period if needed
   - Use semantic versioning or date-based sections
   - Categorize changes:
     ```markdown
     ## [Version/Date]

     ### Added
     - New features

     ### Changed
     - Updates to existing features

     ### Fixed
     - Bug fixes

     ### Security
     - Security updates

     ### Deprecated
     - Features marked for removal
     ```
   - Keep entries user-focused (what changed, why it matters)
   - Keep entries evidence-based; do not overstate readiness, safety, or completeness

5. **Generate work summary**:
   - **User Story / Outcome**: What user-facing promise this work aimed to advance
   - **Completed**: What was finished (with evidence)
   - **In Progress**: What's partially done
   - **Blocked**: What's stuck and why
   - **Learned**: Key insights or discoveries
   - **Security / Product Risks**: Remaining risks, abuse cases, or coherence gaps
   - **Documentation Coherence**: Docs updated, not impacted, or stale
   - **Metrics**: Commits, files changed, tests added, etc.

6. **Plan next session**:
   - Review remaining tasks in TASKS.md
   - Identify what should be prioritized next
   - Note any blockers that need addressing
   - Suggest 1-3 tasks for immediate focus
   - Flag anything that needs discussion/decisions

7. **Update TASKS.md**:
   - Archive completed tasks to a "Recently Completed" section
   - Add completion dates
   - Move old completed tasks to CHANGELOG or separate archive
   - Ensure In Progress and Todo sections are current
   - When evidence is partial, keep items in progress with a precise note instead of marking them done prematurely

### Clarification prompts

Ask a concise user question before concluding the review when the answer materially changes the closure or risk framing. Typical triggers:
- the review period includes work that was merged or deployed but not functionally verified
- it is unclear whether the intended outcome was internal tooling, a partial iteration, or a user-facing completion
- security-sensitive changes were made and the available evidence is too thin to classify them confidently
- user-facing behavior changed but docs/support/pricing/onboarding were not checked or updated
- the review summary would otherwise imply stronger closure than the evidence supports

Examples:
- "Do you want this review to frame the work as iteration progress, or as feature closure?"
- "This looks shipped but not fully validated on the user flow. Should I keep the summary explicit about partial verification?"
- "There are security-sensitive changes with thin evidence. Do you want them called out as open risks in the review?"
- "The feature behavior changed but docs were not clearly updated. Should I keep that as an open task?"

8. **Create review report**:
   - Save to `REVIEW-[DATE].md` in project root or docs folder
   - Start the report with YAML frontmatter:
     ```yaml
     ---
     artifact: review
     project: "[project name]"
     created: "[YYYY-MM-DD]"
     updated: "[YYYY-MM-DD]"
     status: "[draft|reviewed|partial]"
     source_skill: sf-review
     scope: "[daily|weekly|sprint|release]"
     user_story: "[main outcome if inferable]"
     confidence: "[high|medium|low]"
     risk_level: "[low|medium|high]"
     security_impact: "[none|yes|unknown]"
     docs_impact: "[none|yes|unknown]"
     evidence: []
     next_step: "[recommended command]"
     ---
     ```
   - Include all sections above
   - Add links to relevant commits, PRs, issues
   - Make it readable for stakeholders (team, future you)

### Important

- **Always update the master `${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}/TASKS.md`** — check off completed tasks, update Dashboard statuses, refresh "Last updated" date
- Be honest about progress - if less was done than planned, say why
- Focus on outcomes, not just activity
- Keep outcome claims tied to evidence; distinguish shipped, reviewed, verified, and assumed
- Highlight wins and learnings
- Use metrics to show progress (# of tests, coverage, performance improvements)
- Flag technical debt clearly
- Flag product coherence gaps and security risks clearly
- Flag documentation coherence gaps clearly when feature behavior changed
- Make next steps actionable and specific
- Keep review concise but comprehensive
- Update CHANGELOG.md for user-facing changes only
- Archive old completed tasks to keep TASKS.md manageable
- Suggest process improvements if patterns emerge (e.g., always missing tests)
- When planning next session, pull top priorities from the master Dashboard across all 12 projects
