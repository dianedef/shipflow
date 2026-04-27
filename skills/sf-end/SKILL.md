---
name: sf-end
description: "Args: optional summary or notes. End a task — summarize what was done, mark task done in TASKS.md, update CHANGELOG.md. Does NOT commit or push. Use when finishing a task but not ready to ship."
argument-hint: [optional summary or notes]
---

## Canonical Paths

Before resolving any ShipFlow-owned file, load `$SHIPFLOW_ROOT/skills/references/canonical-paths.md` (`$SHIPFLOW_ROOT` defaults to `/home/claude/shipflow`). ShipFlow tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPFLOW_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Chantier Tracking

Trace category: `obligatoire`.
Process role: `lifecycle`.

Before closing a spec-first chantier, load `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md`, then read the spec's `Skill Run History` and `Current Chantier Flow` when a unique spec exists. Append a current `sf-end` row with result `closed`, `deferred`, `blocked`, or `not applicable`, update `Current Chantier Flow`, and end the report with a `Chantier` block plus `Verdict sf-end: ...`. If no unique spec is available, do not write to a spec; report `Chantier: non applicable` or `Chantier: non trace` with the reason.

## Context

- Current directory: !`pwd`
- Current date: !`date '+%Y-%m-%d'`
- Project name: !`basename $(pwd)`
- Git branch: !`git branch --show-current 2>/dev/null || echo "unknown"`
- Git status: !`git status --short 2>/dev/null || echo "Not a git repo"`
- Git diff stat: !`git diff HEAD --stat 2>/dev/null || echo "no changes"`
- Recent commits (this session): !`git log --oneline -10 2>/dev/null || echo "no commits"`
- Master TASKS.md: !`cat /home/claude/shipflow_data/TASKS.md 2>/dev/null || echo "No master TASKS.md"`
- Local TASKS.md (if exists): !`cat TASKS.md 2>/dev/null || echo "No local TASKS.md"`
- Existing CHANGELOG: !`head -30 CHANGELOG.md 2>/dev/null || echo "no CHANGELOG.md"`

## Your task

Wrap up the current task. Summarize, update tracking files, but do NOT commit or push.
This skill closes a work session, not product truth. TASKS and CHANGELOG updates are bookkeeping, not proof that the outcome is fully correct, complete, or secure.

### Step 1 — Summarize what was done (internal)

From the conversation, identify:
- What was completed
- What was started but not finished
- Key files modified (from git diff)
- Any decisions worth noting
- The user story or user-facing outcome this work was intended to support, if inferable
- Any gap between "work performed" and "outcome proven"
- Documentation surfaces updated or possibly stale after the change

### Step 1.5 — Closure mode decision

If completion status is ambiguous, use **AskUserQuestion**:
- Question: "Quel mode de clôture veux-tu ?"
- `multiSelect: false`
- Options:
  - **Clôture complète** — "Marquer la tâche en done"
  - **Clôture partielle (recommandé si doute)** — "Garder un reliquat en in progress"
  - **Résumé seulement** — "Ne pas toucher TASKS/CHANGELOG, juste rapporter"

Ask a targeted clarification instead of assuming `done` when:
- the work is implemented but not meaningfully validated
- the user story or expected outcome is still unclear
- the work touches auth, permissions, billing, secrets, tenant boundaries, destructive actions, migrations, public flows, or other security-sensitive surfaces
- there are remaining risks, TODOs, or blockers that materially affect product coherence or safety
- docs, README, FAQ, onboarding, changelog, examples, pricing or support copy may still describe old behavior

Examples:
- "Est-ce que tu veux clôturer la tâche comme livrée fonctionnellement, ou la laisser partielle tant que le flow utilisateur n’est pas validé ?"
- "Cette passe touche la sécurité / visibilité des données. Veux-tu une clôture partielle avec risques restants explicites ?"

### Step 2 — Update TASKS.md (silent)

Using the master TASKS.md from context:
- Mark completed items: `🔄 in progress` → `✅ done` and `📋 todo` → `✅ done`
- Mark partially done items: `📋 todo` → `🔄 in progress` with a note
- Add new tasks discovered during the work
- Update master `/home/claude/shipflow_data/TASKS.md` — always
- If a local `TASKS.md` also exists, update both
- Treat the TASKS content loaded in Context as informational only.
- Immediately before editing either TASKS file, re-read it from disk and use that version as authoritative.
- Apply a minimal targeted edit to the relevant rows only; never rewrite the whole file from stale context.
- If the expected row or section moved, re-read once and recompute; if it is still ambiguous, stop and ask the user.
- If the evidence supports only partial completion, keep or move the task to `🔄 in progress` with a short note rather than forcing `✅ done`.
- Reflect product coherence and safety gaps when they materially affect closure.
- Reflect documentation coherence gaps when a user-facing feature behavior changed.
- No output at this step.

If mode is **Résumé seulement**, skip this step.

### Step 3 — Update CHANGELOG.md (silent)

- Group changes into Keep a Changelog categories: Added / Changed / Fixed / Security / Removed
- Consolidate related changes into single human-readable entries
- Prepend a new `## [date]` entry to CHANGELOG.md (or update today's entry if it exists)
- Skip trivial changes (formatting, comments)
- Keep entries evidence-based and user-facing; do not claim a feature is "done", "safe", or "production ready" unless the work actually demonstrated that.
- Include documentation alignment when it materially affects user-facing behavior.
- No output at this step.

If mode is **Résumé seulement**, skip this step.

### Step 4 — Save decisions to memory (silent)

For each significant decision or discovery from Step 1, save to memory if it will be useful in future conversations. Skip if nothing meaningful.

### Step 5 — Report

Output ONE concise report:

```
## Done — [date]

**What changed:**
- [bullet per logical change — specific, not vague]

**User story / outcome:**
- [what user-facing outcome was advanced, completed, or still unproven]

**Documentation coherence:**
- [updated / not impacted / gap remains]

**Status:**
- Completed: [item], [item]
- In progress: [item — where it stands]
- Risks / evidence limits: [explicit remaining uncertainty, especially product/security]
- Decisions saved: [decision or "none"]

**Up next:**
1. [emoji] [top priority from TASKS.md]
2. [emoji] [second priority]
3. [emoji] [third priority]

[📝 Not committed — run /sf-ship when ready to push]

## Chantier

Skill courante: sf-end
Chantier: [spec path | non applicable | non trace]
Trace spec: [ecrite | non ecrite | non applicable]
Flux:
- sf-spec: [status]
- sf-ready: [status]
- sf-start: [status]
- sf-verify: [status]
- sf-end: [closed | deferred | blocked | not applicable]
- sf-ship: [status]

Reste a faire:
- [item or None]

Prochaine etape:
- [/sf-ship | explicit action | None]

Verdict sf-end:
- [closed | deferred | blocked | not applicable]
```

### Rules

- Do NOT commit or push — that's sf-ship's job
- Do NOT output anything before Step 5 — one report only
- Keep the report under 25 lines
- If nothing was done this session, say so honestly
- Update BOTH master and local TASKS.md when both exist
- Do not let TASKS/CHANGELOG imply stronger proof than the actual validation supports
- Do not mark feature work fully closed if known docs remain stale and materially affect users/operators
- Prefer partial closure when user-story completion or security posture remains uncertain
