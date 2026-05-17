---
name: continue
description: "Resume paused work and report the next step."
argument-hint: <optional focus>
---

## Canonical Paths

Before resolving ShipFlow-owned files, load `$SHIPFLOW_ROOT/skills/references/canonical-paths.md` (`$SHIPFLOW_ROOT` defaults to `$HOME/shipflow`) if present. Project files resolve from the current project root unless explicitly stated otherwise.

## Chantier Tracking

Trace category: `conditionnel`.
Process role: `pilotage`.

Before producing the final report, load `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md` when this run is attached to a spec-first chantier. If exactly one active `specs/*.md` chantier is identified, append the current run to `Skill Run History`, update `Current Chantier Flow` only when this run changes the chantier state, and include a final `Chantier` block. If no unique chantier is identified, do not write to any spec; report `Chantier: non applicable` or `Chantier: non trace` with the reason.

As a `pilotage` skill, `continue` can route toward `/sf-spec` when the next useful step clearly deserves a durable chantier, but it should not declare every continuation or backlog note as a chantier source.

## Purpose

`continue` is a cockpit skill for global conversations.

Use it when the user wants to move the current work forward without loading the whole execution path into the main conversation. The main thread stays responsible for routing, integration, user-facing status, and the final next-step recommendation. Fresh agents do bounded execution when that will reduce context drag or improve focus.

The goal is not to spawn an agent every time. The goal is to choose the next useful action and run it in the right place.

## Inputs

- If `$ARGUMENTS` is provided, treat it as the requested focus.
- If `$ARGUMENTS` is empty, infer the next useful step from the latest user request, current conversation, TASKS.md, open specs, git status, and recent tool results.
- If several unrelated next steps are plausible, choose the one most likely to unblock progress. Ask the user only when the choice changes product behavior, security, data handling, destructive operations, cost, or external side effects.

## Quick Context Check

Gather only enough context to route correctly:

- Current directory, project name, branch, and git status.
- Local `TASKS.md` and master `${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}/TASKS.md` when present.
- Relevant specs in `docs/` or `specs/` when the next step appears spec-driven.
- Obvious failing command output or latest validation result if available in the conversation.
- Existing skill instructions only when directly useful, especially `sf-start`, `sf-fix`, `sf-check`, `sf-verify`, `sf-model`, or `sf-end`.

Avoid re-reading large files or broad project trees before deciding the route.

## Routing Decision

Classify the next step:

- `answer`: the user needs a direct explanation, decision, or status update.
- `local`: the work is tiny, tightly coupled to the current thread, or immediately blocking.
- `explorer-agent`: the next step is read-only investigation, codebase mapping, diagnosis, or options analysis.
- `worker-agent`: the next step is bounded implementation, test repair, documentation update, or mechanical cleanup with a clear write scope.
- `spec-route`: the work is non-trivial or ambiguous and needs `sf-spec`, `sf-ready`, or `sf-start` rather than ad hoc execution.
- `blocked`: a required user decision or external permission is missing.

Prefer delegation when:

- a fresh context would materially help;
- the subtask is concrete and bounded;
- the main thread can continue integrating or reporting without depending on hidden assumptions;
- file ownership can be stated clearly for write tasks.

Keep the work local when:

- the next action is trivial;
- the result is needed immediately before any other progress can happen;
- the task is too coupled to the current conversation;
- delegation would duplicate work or create integration overhead greater than the task.

## Agent Choice

When spawning is appropriate:

- Use `explorer` for read-only codebase questions, diagnosis, architecture discovery, or validation of an assumption.
- Use `worker` for implementation or file changes. Give explicit ownership of files/modules and state that other agents or the main thread may also be working in the codebase.
- Use only one agent by default. Use multiple agents only when tasks are independent and write scopes are disjoint.
- Do not spawn agents just to satisfy the skill name; a local action with a clear report is valid.

### ShipFlow Skills

Before launching an agent, decide whether a ShipFlow skill should drive the work. The agent may use any installed ShipFlow skill when it fits the task; all skill documentation is available under `$SHIPFLOW_ROOT/skills`.

Common routes:

- `sf-start`: execute a defined task end-to-end.
- `sf-fix`: triage and fix a bug.
- `sf-check`: run typecheck, lint, build, and repair failures.
- `sf-verify`: verify that work is ready to ship.
- `sf-audit-*`: run focused audits for code, design, SEO, GTM, copy, a11y, components, dependencies, or performance.
- `sf-spec` / `sf-ready`: clarify or harden non-trivial work before implementation.
- `sf-model`: choose the model when routing is uncertain.

If a skill is useful, name it in the delegation prompt and tell the agent to open its `SKILL.md` first. Do not paste large skill contents into the prompt.

### Model Choice

Always think about the right model before spawning an agent. Use the smallest model that is reliable for the job, and upgrade when ambiguity, risk, or session length justifies it.

Default model menu for Codex/OpenAI agents:

- `gpt-5.5` with `high` or `xhigh`: very complicated work, high ambiguity, architecture, security, data integrity, or expensive mistakes.
- `gpt-5.4` with `medium` or `high`: complex product/code reasoning where quality matters but the task is not the hardest class.
- `gpt-5.3-codex` with `medium` or `high`: long coding agents, multi-file implementation, debugging, refactors, test repair.
- `gpt-5.4-mini` with `low` or `medium`: small clear tasks, triage, read-only exploration, cheap focused checks.
- `gpt-5.3-codex-spark` with `low` or `medium`: fast local edits, UI deltas, tight iteration loops.

If the choice is not obvious, or if the task has high ambiguity, high cost of error, long execution, security/data implications, or unclear provider/runtime constraints, use the `sf-model` skill before spawning: open `$SHIPFLOW_ROOT/skills/sf-model/SKILL.md`, then read `$SHIPFLOW_ROOT/skills/sf-model/references/model-routing.md` if instructed or needed. Otherwise inherit the current model only when that is clearly adequate.

## Delegation Prompt Template

For an `explorer`:

```text
You are an explorer agent for the current repo. Investigate only; do not edit files.

Question:
[specific question]

Context:
- Project/root: [path]
- Relevant files or specs: [short list]
- Current hypothesis or failure: [one paragraph]

Return:
- concise findings with file references
- risks or unknowns
- recommended next action
```

For a `worker`:

```text
You are a worker agent in the current repo. You are not alone in the codebase; do not revert or overwrite edits made by others. Adjust your work to coexist with concurrent changes.

Task:
[specific implementation task]

Ownership:
- You may edit: [files/modules]
- Treat as read-only: [files/modules]

Context:
- User outcome: [one paragraph]
- Relevant spec/task: [path or none]
- ShipFlow skill to use, if any: [skill name or none]
- Model chosen: [model + reasoning effort + why]
- Constraints: follow existing patterns; keep scope tight; avoid unrelated refactors

Validation:
- Run: [commands, if known]
- If blocked, report the blocker and the smallest next step

Return:
- files changed
- validation run and result
- remaining risks
- recommended next step
```

## Main Thread Responsibilities

After delegating:

- Do not redo the same work locally.
- While an agent runs, do non-overlapping useful work only if available.
- Wait only when the agent result is needed for the next critical step.
- Review the returned work before reporting it as complete.
- Run focused validation locally when changes were made and it is feasible.

## Final Report

End with a short report in French unless the user used another language:

```text
Fait:
- [what happened]

Reste:
- [remaining work or risk]

Prochaine étape:
- [one concrete next action]
```

If nothing was executed because routing found a blocker, make the blocker and the exact needed decision the next step.

## Guardrails

- Never hide uncertainty behind delegation.
- Never delegate destructive operations without explicit user approval.
- Never let a subagent decide product/security/data policy when the main thread should ask the user.
- Keep the main conversation as the source of truth for status and next-step decisions.
- Prefer one crisp next step over a broad plan.
