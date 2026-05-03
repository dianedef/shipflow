---
name: sf-audit
description: "Master audit across product, code, design, SEO, GTM, and performance."
disable-model-invocation: true
argument-hint: '[file-path | "global"] (omit for full project)'
---

## Canonical Paths

Before resolving any ShipFlow-owned file, load `$SHIPFLOW_ROOT/skills/references/canonical-paths.md` (`$SHIPFLOW_ROOT` defaults to `$HOME/shipflow`). ShipFlow tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPFLOW_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Chantier Tracking

Trace category: `conditionnel`.
Process role: `source-de-chantier`.

Before producing the final report, load `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md` when this run is attached to a spec-first chantier. If exactly one active `specs/*.md` chantier is identified, append the current run to `Skill Run History`, update `Current Chantier Flow` when the run changes the chantier state, and include a final `Chantier` block. If no unique chantier is identified, do not write to any spec; report `Chantier: non applicable` or `Chantier: non trace` with the reason.

## Chantier Potential Intake

Because this skill has process role `source-de-chantier`, evaluate the standard threshold from `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md` before the final report. If the findings reveal non-trivial future work and no unique chantier owns it, do not write to an existing spec; add a `Chantier potentiel` block with `oui`, `non`, or `incertain`, a proposed title, reason, severity, scope, evidence, recommended `/sf-spec ...` command, and next step. If the work is only a direct local fix or already belongs to the current chantier, state `Chantier potentiel: non` with the concrete reason.


## Doctrine

- The master audit evaluates whether the product still delivers its intended user story coherently across domains, not just whether isolated checks pass.
- Treat workflow integrity, security posture, and product coherence as first-class audit concerns.
- Treat documentation coherence as first-class when feature behavior, public promises, setup, API usage or support expectations changed.
- Treat ShipFlow business metadata versions as evidence. `BUSINESS.md`, `BRANDING.md`, and `GUIDELINES.md` are decision contracts; stale, missing, low-confidence, or unversioned contracts must reduce confidence and appear as proof gaps.
- Prefer honest reporting over tidy grades. If proof is partial, say so explicitly and keep confidence bounded.
- Keep orchestration practical: parallelize aggressively, but never invent certainty for skipped or weakly evidenced domains.

## Context

- Current directory: !`pwd`
- Project CLAUDE.md: !`head -50 CLAUDE.md 2>/dev/null || echo "no CLAUDE.md"`
- Business metadata: !`for f in BUSINESS.md BRANDING.md GUIDELINES.md; do if [ -f "$f" ]; then printf '%s: ' "$f"; sed -n '1,40p' "$f" | grep -E '^(metadata_schema_version|artifact_version|status|updated|confidence|next_review):' | tr '\n' ' '; printf '\n'; else echo "$f: missing"; fi; done`
- Project structure: !`find src -maxdepth 2 -type d 2>/dev/null | grep -v node_modules | head -20 || echo "no src dir"`
- i18n present: !`find src -path "*/i18n/*" -o -path "*/locales/*" 2>/dev/null | head -3 || echo "no i18n"`
- Package.json scripts: !`cat package.json 2>/dev/null | grep -E '^\s+"(dev|build|lint|typecheck|check)"' || echo "no package.json"`

## Mode detection

- **`$ARGUMENTS` is "global"** → GLOBAL MODE: full audit of ALL projects across ALL applicable domains.
- **`$ARGUMENTS` is a file path** → FILE MODE: audit that single file across all domains.
- **`$ARGUMENTS` is empty** → PROJECT MODE: full audit of the entire project.

---

## GLOBAL MODE

Full audit of ALL projects across ALL applicable domains — the most comprehensive audit.

### Step 1: Build the audit plan

Read `${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}/PROJECTS.md`. Use the **Domain Applicability** table to determine which domains apply to each project.

### Step 2: Let the user choose

Use **AskUserQuestion** with TWO questions in a single call:

- **Q1** — "Which projects should I audit?"
  - `multiSelect: true`
  - One option per project: label = project name, description = stack from PROJECTS.md
  - All projects pre-listed

- **Q2** — "Which domains should I run?"
  - `multiSelect: true`
  - Options: Code, Design, Copy, SEO, GTM, Translate, Deps, Perf
  - Description for each: one-line summary of what it checks

Only launch (project × domain) pairs where: user selected the project AND user selected the domain AND the domain applies to that project per PROJECTS.md.

### Step 3: Read domain checklists

Read each selected domain skill to get their PROJECT MODE checklists:
- `$HOME/.codex/skills/sf-audit-code/SKILL.md`
- `$HOME/.codex/skills/sf-audit-design/SKILL.md`
- `$HOME/.codex/skills/sf-audit-copy/SKILL.md`
- `$HOME/.codex/skills/sf-audit-seo/SKILL.md`
- `$HOME/.codex/skills/sf-audit-gtm/SKILL.md`
- `$HOME/.codex/skills/sf-audit-translate/SKILL.md`
- `$HOME/.codex/skills/sf-deps/SKILL.md`
- `$HOME/.codex/skills/sf-perf/SKILL.md`

### Step 4: Launch ALL agents

Use the **Task tool** to launch one agent per **(project × domain)** pair — ALL IN A SINGLE MESSAGE for maximum parallelism.

Example: if 9 projects need Design audit and 5 need GTM, that's 14 agents for those two domains. Launch everything at once.

Each agent: `subagent_type: "general-purpose"`. Each agent prompt MUST include:
1. `cd [project-path]` then read the project's `CLAUDE.md`
2. The complete **PROJECT MODE** section from the corresponding domain skill
3. The **Tracking** section from that domain skill
4. Rule: **read-only analysis** — no code fixes, only update AUDIT_LOG.md and TASKS.md
5. Today's absolute date and the exact project path / scope under review
6. Instruction: identify linked systems, consumers, and downstream consequences before scoring anything
7. Instruction: do not ask follow-up questions; if context is missing, state assumptions / confidence limits and continue
8. Instruction: call out user-story drift, product incoherence, workflow bypass, and security proof gaps explicitly
9. Instruction: call out documentation mismatch, stale feature claims, and public promises unsupported by app/docs
10. Instruction: read/report `BUSINESS.md`, `BRANDING.md`, and `GUIDELINES.md` metadata versions where relevant; stale, missing, low-confidence, or unversioned business contracts must appear in `Risky assumptions / proof gaps` and reduce confidence before scoring

### Step 5: Cross-project master report

Once all agents complete:

```
══════════════════════════════════════════════════════
GLOBAL MASTER AUDIT — [date]
══════════════════════════════════════════════════════

PROJECT × DOMAIN MATRIX
              Code  Design  Copy  SEO  GTM  Trans  Deps  Perf  Overall
my-robots      [B]    —      —     —    —     —    [A]   [B]    [B]
tubeflow       [A]   [B]    [B]   [C]  [B]   —    [B]   [B]    [B]
GoCharbon      [B]   [A]    [B]   [B]  [C]   —    [A]   [A]    [B]
...

──────────────────────────────────────────────────────
CROSS-PROJECT PATTERNS
  [Systemic issues across multiple projects]

USER STORY / PRODUCT COHERENCE PATTERNS
  [Repeated promise drift, misleading UX, inconsistent flow decisions, trust-boundary confusion]

SECURITY / SUPPLY CHAIN PATTERNS
  [Shared auth/authz weaknesses, unsafe dependency posture, weak defaults, repeated proof gaps]

ALL ISSUES BY SEVERITY
  🔴 [project] [domain] file:line — description
  🟠 [project] [domain] file:line — description
  🟡 [project] [domain] file:line — description

RISKY ASSUMPTIONS / PROOF GAPS
  - [project] [domain] — what was not demonstrated and why it matters

Total: X critical, Y high, Z medium
       across N projects and M domain audits (up to 8 domains)
══════════════════════════════════════════════════════
```

### Step 6: Update global tracking

1. **Global `${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}/AUDIT_LOG.md`** — one row per project with all domain scores.
2. **Master `${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}/TASKS.md`** — update each project's audit subsections.

### Step 7: Ask about fixes

> **Global audit complete across N projects. X critical, Y high, Z medium issues total. Which projects should I fix?**

List projects ranked by overall score (worst first). Fix approved projects one at a time, domain by domain.

---

## Your task

You are the **audit orchestrator**. You do NOT perform the audits yourself. You launch **parallel agents** and then consolidate results.

### Step 0: Workspace root detection

If the current directory has no project markers (no `package.json`, no `requirements.txt`, no `src/` dir, no `lib.sh`) BUT contains multiple project subdirectories — you are at the **workspace root**, not inside a project.

Use **AskUserQuestion**:
- Question: "You're at the workspace root. Which project(s) should I audit?"
- `multiSelect: true`
- Options:
  - **All projects** — "Run global audit across every project" (Recommended)
  - One option per project from `${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}/PROJECTS.md`: label = project name, description = stack

Then proceed to **GLOBAL MODE** with the selected projects (or all if "All projects" was chosen).

### Step 1: Determine scope and applicable domains

Detect which domains apply to this project:

- **Code** — always applicable
- **Design** — if the project has a UI (web or mobile)
- **Copy** — if the project has user-facing content
- **SEO** — if it's a web project with public pages
- **GTM** — only if commercial intent (pricing, signup, analytics)
- **Translate** — only if multiple locales (i18n files, locale dirs, bilingual content)
- **Deps** — always applicable (except projects with no package manager, e.g., BuildFlowz)
- **Perf** — always applicable

Then use **AskUserQuestion** to let the user confirm:
- Question: "Which domains should I audit for this project?"
- `multiSelect: true`
- List all 8 domains as options. For each: label = domain name, description = what it checks
- Mark inapplicable domains with "(not detected)" in the description so the user can still opt in

If the product intent is still ambiguous after reading `CLAUDE.md` and the repo context, ask one short clarification before launching agents:
- who the main actor is
- what outcome the product promises
- whether the surface is public, internal, or admin-only

Only launch agents for selected domains.

### Step 2: Launch parallel agents

Use the **Task tool** to launch one agent per domain, ALL IN A SINGLE MESSAGE (parallel execution). Each agent should be `subagent_type: "general-purpose"`.

For each agent, provide this prompt structure:

```
You are performing a [DOMAIN] audit of [scope: file path OR full project] in the project at [current directory].

[Paste the FULL audit checklist for that domain from the corresponding skill — FILE MODE/PAGE MODE section if a file argument was given, PROJECT MODE section if no argument]

Project CLAUDE.md context:
[Include the CLAUDE.md content from this skill's context]

IMPORTANT:
- Do NOT fix anything. This is a READ-ONLY analysis pass.
- Do NOT ask follow-up questions. If context is missing, state assumptions and keep going.
- Before scoring, identify linked systems, consumers, and likely downstream consequences.
- Evaluate user-story fit and product coherence, not just local correctness.
- Evaluate documentation coherence when the audited surface makes or depends on product claims.
- Read/report business decision-contract metadata when relevant: `BUSINESS.md`, `BRANDING.md`, `GUIDELINES.md` with `artifact_version`, `status`, `updated`, `confidence`, and `next_review`.
- Treat missing `artifact_version`, missing `status`, stale `next_review`, `status: draft|stale|outdated|deprecated`, or `confidence: low` as proof gaps that limit scores and confidence.
- Call out workflow bypass, stale-state, partial-failure, permission, trust-boundary, and security concerns when relevant.
- Score every category A/B/C/D.
- For each issue found, note: file path, line number, what's wrong, severity (critical/high/medium/low), and your proposed fix.
- Include these sections before the score table: Scope understood, User story / promised outcome, Business metadata versions, Context read, Linked systems & consequences, Documentation coherence, Risky assumptions / proof gaps, Confidence / missing context.
- End with the full report table as specified in the checklist.
```

**Critical rules for agent prompts:**
- Copy the FULL checklist from the corresponding audit skill — don't summarize or skip sections.
- Agents must NOT edit files — analysis only. Fixes happen in Step 4.
- Include the project CLAUDE.md so agents understand project conventions.

### Step 3: Consolidate reports

Once all agents return, compile a **master report**:

```
---
artifact: audit_report
project: "[project name or global]"
created: "[YYYY-MM-DD]"
updated: "[YYYY-MM-DD]"
status: reviewed
source_skill: sf-audit
scope: "[file|project|global]"
confidence: "[high|medium|low]"
risk_level: "[low|medium|high]"
security_impact: "[none|yes|unknown]"
docs_impact: "[none|yes|unknown]"
business_metadata_versions:
  BUSINESS.md: "[artifact_version/status/confidence or missing]"
  BRANDING.md: "[artifact_version/status/confidence or missing]"
  GUIDELINES.md: "[artifact_version/status/confidence or missing]"
domains: [code, design, copy, seo, gtm, translate, deps, perf]
issue_counts:
  critical: 0
  high: 0
  medium: 0
evidence: []
next_step: "[recommended command]"
---

══════════════════════════════════════════════════════
MASTER AUDIT: [project name or file name]
══════════════════════════════════════════════════════

DOMAIN SCORES
  Code           [A/B/C/D]  —  one-line summary
  Design         [A/B/C/D]  —  one-line summary
  Copy           [A/B/C/D]  —  one-line summary
  SEO            [A/B/C/D]  —  one-line summary
  GTM            [A/B/C/D]  —  one-line summary  (or "skipped — [reason]")
  Translate      [A/B/C/D]  —  one-line summary  (or "skipped — [reason]")
  Deps           [A/B/C/D]  —  one-line summary  (or "skipped — no package manager")
  Perf           [A/B/C/D]  —  one-line summary

OVERALL          [A/B/C/D]

USER STORY / PRODUCT COHERENCE
  Verdict        [holding / drifting / unclear]
  Summary        [is the implemented product still delivering the promised outcome coherently?]

SECURITY / WORKFLOW INTEGRITY
  Verdict        [sound / risky / unclear]
  Summary        [major authz, abuse-case, supply-chain, or trust-boundary concerns]

BUSINESS METADATA VERSIONS
  BUSINESS.md    artifact_version=[x|missing] status=[x|missing] updated=[date|missing] confidence=[x|missing] next_review=[date|missing]
  BRANDING.md    artifact_version=[x|missing] status=[x|missing] updated=[date|missing] confidence=[x|missing] next_review=[date|missing]
  GUIDELINES.md  artifact_version=[x|missing] status=[x|missing] updated=[date|missing] confidence=[x|missing] next_review=[date|missing]
  Proof gaps      [missing/stale/unversioned contracts that affected scoring, or none]

──────────────────────────────────────────────────────
CRITICAL ISSUES (fix immediately)
  1. [domain] file:line — description
  2. ...

HIGH ISSUES (fix soon)
  1. [domain] file:line — description
  2. ...

MEDIUM ISSUES (improve when possible)
  1. [domain] file:line — description
  2. ...

RISKY ASSUMPTIONS / GAPS
  1. [domain] what was not proved, and what this limits
  2. ...
──────────────────────────────────────────────────────
Total issues: X critical, Y high, Z medium
══════════════════════════════════════════════════════
```

Then print each domain's full detailed report below the master summary.

Rules for consolidation:
- Do not assign an `A` to a domain if the report says evidence was partial on a user-critical or security-critical path.
- If multiple domains disagree on the same flow, call out the inconsistency explicitly instead of averaging it away.
- If a domain was skipped, failed, or could not demonstrate enough evidence, record that as a proof gap, not as a silent omission.

### Shared file write protocol

Before editing `${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}/AUDIT_LOG.md`, project-local `AUDIT_LOG.md`, or either `TASKS.md` file:
- Treat the snapshots loaded earlier in the skill as informational only.
- Right before each write, re-read the target file from disk and use that version as authoritative.
- Append or replace only the intended row or subsection; never rewrite the whole file from stale context.
- If the expected anchor moved or changed, re-read once and recompute.
- If it is still ambiguous after the second read, stop and ask the user instead of forcing the write.

### Step 4: Log the audit

Update **two** audit logs. Never delete previous rows — this is the history.

**1. Global `${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}/AUDIT_LOG.md`** — cross-project dashboard:

```markdown
# Audit Log

> Quick view of all audit runs across all projects. See project-local `AUDIT_LOG.md` for details.

| Date       | Project          | Scope        | Code | Design | Copy | SEO | GTM | Translate | Deps | Perf | Overall | Issues     |
|------------|------------------|--------------|------|--------|------|-----|-----|-----------|------|------|---------|------------|
| 2026-02-21 | plaisirsurprise  | full project | B    | C      | B    | D   | B   | C         | B    | B    | C       | 3/8/12     |
| 2026-02-21 | GoCharbon        | full project | A    | B      | B    | C   | —   | B         | A    | A    | B       | 0/3/7      |
| 2026-03-05 | plaisirsurprise  | index.astro  | A    | B      | B    | B   | B   | B         | —    | B    | B       | 0/2/4      |
```

**2. Project-local `./AUDIT_LOG.md`** — same format but only for this project (no Project column):

```markdown
# Audit Log — [project name]

| Date       | Scope        | Code | Design | Copy | SEO | GTM | Translate | Deps | Perf | Overall | Issues     |
|------------|--------------|------|--------|------|-----|-----|-----------|------|------|---------|------------|
| 2026-02-21 | full project | B    | C      | B    | D   | B   | C         | B    | B    | C       | 3/8/12     |
```

- Issues column format: `critical/high/medium`.
- Use `—` for skipped domains.
- Append a new row per run. This is an append-only log.

### Step 5: Update TASKS.md

Add audit findings as tasks. Two files to update:

**1. Project-local TASKS.md** (e.g., `./TASKS.md` in the current project):
- Create it if it doesn't exist.
- Add an `## Audit Findings` section (or update it if it already exists — replace old findings with fresh ones).
- List all issues (critical, high, and medium) as tasks:

```markdown
## Audit Findings
> Last audit: 2026-02-21 — Overall: [C]

| Pri | Task | Domain | Status |
|-----|------|--------|--------|
| 🔴 | Fix XSS in user comment rendering (src/components/Comments.tsx:42) | Code | 📋 todo |
| 🔴 | Add missing meta descriptions on 8 pages | SEO | 📋 todo |
| 🟠 | Standardize button styles across 12 components | Design | 📋 todo |
| 🟠 | Rewrite homepage headline — benefit-driven | Copy | 📋 todo |
| 🟡 | Add alt text to 5 decorative images | SEO | 📋 todo |
| 🟡 | French typographic spaces before colons | Translate | 📋 todo |
```

- Use 🔴 for critical, 🟠 for high, 🟡 for medium.
- If a previous `## Audit Findings` section exists, replace it entirely with fresh findings (don't accumulate stale issues).

**2. Master `${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}/TASKS.md`**:
- Find the section for the current project.
- Add or update an `### Audit` subsection with a summary line and all issues as tasks.
- Update the Dashboard table's "Top Priority" column if audit found critical issues (they take precedence).

### Step 6: Apply fixes

After presenting the consolidated report and updating tracking files, ask the user:

> **Found X critical, Y high, Z medium issues. How do you want to proceed?**
> 1. Fix all (critical + high + medium)
> 2. Fix critical and high only
> 3. Fix critical only
> 4. Don't fix anything — just keep the report

Then apply fixes sequentially (NOT in parallel — fixes may touch the same files). Priority order:
1. Critical security issues
2. Critical bugs
3. High severity across all domains
4. Medium severity across all domains

When fixing, group changes by file to avoid conflicts. If two domains flag the same file, apply all fixes to that file at once.

### Important

- The value of this skill is PARALLELISM. Always launch agents in a single message so they run concurrently. Never run them one by one.
- Keep agent prompts self-contained — each agent should work independently without needing context from other agents.
- If a domain agent fails or times out, report it and continue with the others.
- Don't re-audit what agents already audited. Trust their analysis, consolidate, and fix.
- Never say `looks good overall` when core user flows, security posture, or dependency/supply-chain risk were not actually demonstrated.
- Prioritize issues that break the promised user outcome, create dangerous ambiguity, or permit abuse/bypass over cosmetic concerns.
- For FILE MODE: some domain checklists may partially apply (e.g., GTM checks don't make sense for a utility function). Agents should skip irrelevant checks and note "N/A" in their report.
