---
name: shipflow
description: "Primary router to skills or direct answers."
argument-hint: <instruction>
---

## Canonical Paths

Before resolving any ShipFlow-owned file, load `$SHIPFLOW_ROOT/skills/references/canonical-paths.md` (`$SHIPFLOW_ROOT` defaults to `$HOME/shipflow`). ShipFlow tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPFLOW_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Chantier Tracking

Trace category: `non-applicable`.
Process role: `helper`.

`shipflow` does not write to chantier specs, bug files, release scopes, content surfaces, commits, or deployment state. The selected owner skill owns durable state and chantier tracing after handoff. If invoked inside a spec-first flow, do not modify `Skill Run History`; include `Chantier: non applicable` or `Chantier: non trace` only when useful, with the selected route and reason.

## Report Modes

Before producing a final report, load `$SHIPFLOW_ROOT/skills/references/reporting-contract.md`.

Default to `report=user`: concise, route-first, and in the user's active language. Use detailed report modes only when the user explicitly asks for handoff evidence or when routing is blocked.

## Delegation And Topology

Before deciding execution topology, load `$SHIPFLOW_ROOT/skills/references/master-delegation-semantics.md`.

`shipflow` is a primary router, not a master lifecycle executor. Its default topology is `main-thread routing`:

- answer directly in the main conversation when no file work, validation, closure, ship, deployment, or durable artifact is needed
- hand off directly in the main conversation to the selected skill contract when work belongs to an existing skill
- ask one numbered routing question when multiple routes are plausible and the answer changes behavior, risk, data, permissions, public claims, staging, closure, or ship posture

Do not launch a selected master skill inside a subagent. In particular, do not run `sf-build`, `sf-maintain`, `sf-bug`, `sf-deploy`, `sf-content`, or `sf-skill-build` as a nested subagent from `shipflow`. After direct handoff, the selected master skill owns its own delegated sequential execution through the shared delegation reference.

Use a read-only routing scout only when all of these are true:

- cheap local inspection is needed to choose between owner skills
- the scout is forbidden to edit, stage, commit, push, deploy, or mutate trackers
- the scout does not invoke a master skill or launch further subagents
- the result is only a route recommendation for the main-thread handoff

## Shared Routing Reference

Before classifying a non-trivial instruction, load `$SHIPFLOW_ROOT/skills/references/entrypoint-routing.md`.

Use that reference as the canonical routing matrix. Do not duplicate specialist internals here.

## Mission

`shipflow` is the primary natural-language entrypoint for non-technical operators.

It answers one question:

```text
What should ShipFlow do with this instruction, and which existing skill should own it?
```

The goal is not to create a new mega-master. The goal is to keep the operator from memorizing the skill taxonomy while preserving the gates, delegation rules, evidence rules, and ship rules owned by existing skills.

## Mode Detection

Parse `$ARGUMENTS` as the operator instruction.

- Empty argument: give a compact orientation answer and ask for the instruction to route.
- `help`, `aide`, `commands`, `skills`, or route-selection questions: answer directly or route to `sf-help` only if the user wants the full help surface.
- Explicit skill name: hand off to that skill unless the request reveals a safer owner.
- Natural-language instruction: classify using the routing matrix below.

## Routing Matrix

Choose exactly one route unless the user explicitly asks for a dashboard or comparison.

| Intent | Route |
| --- | --- |
| Pure question, explanation, or advice with no file work | Answer directly |
| Non-trivial feature, code, site, docs, product, or workflow work | `sf-build <instruction>` |
| Recurring maintenance, security upkeep, dependencies, docs drift, checks, audit freshness, migrations, or project hygiene | `sf-maintain <mode or instruction>` |
| Bug report, `BUG-ID`, retest, closure, fix state, or bug ship-risk question | `sf-bug <instruction>` |
| Release confidence, preview/prod deploy, deployed truth, runtime logs, production health, post-deploy proof | `sf-deploy <instruction>` |
| Content strategy, repurposing, drafting, enrichment, SEO/copy audit, editorial governance, apply/publish content | `sf-content <instruction>` |
| Create, modify, rename, document, refresh, or validate ShipFlow skills | `sf-skill-build <instruction>` |
| One obvious audit domain only | relevant `sf-audit-* <instruction>` or `sf-audit <instruction>` |
| One obvious owner lane only, such as checks, docs, browser proof, auth diagnosis, manual QA, dependency posture, migration, or final ship | focused owner skill |
| Ambiguous between two or more material routes | Ask one concise numbered routing question |

## Direct Handoff Contract

When a route is clear:

1. Name the selected skill and why in one short sentence when useful.
2. Continue in the same conversation under the selected skill's contract.
3. Load the selected skill's required references before executing it.
4. Pass the original user instruction as the target argument.
5. Preserve the selected skill's report mode defaults unless the user asked for a detailed handoff.

Do not stop at "run `/skill ...`" when the user asked ShipFlow to handle the work and the route is safe. A command recommendation is acceptable only for pure orientation, unsupported runtime handoff, or a blocked state.

## Question Gate

Before asking a user-facing routing question, load `$SHIPFLOW_ROOT/skills/references/question-contract.md`.

Ask only when the answer changes the route or safety posture. Ask one concise routing question with why the route matters and numbered options. Include a recommended route only when one option is clearly safe from the current instruction and project context.

Good routing questions are short and practical:

```text
1. Route type
Why: the next step uses different evidence and files depending on whether this is an existing bug or a new product improvement.
Recommended: 1. Product improvement - use this when the request describes a new behavior rather than an observed regression.

Options:
1. Product improvement - hand off to `sf-build`.
2. Existing bug - hand off to `sf-bug`.

Reply with the number, or name another route.
```

Do not ask broad "anything else?" questions.

## Stop Conditions

Stop and report `blocked` when:

- no route can be chosen without a material product, data, security, permission, deployment, or ship decision
- the selected skill contract is missing or unreadable
- runtime subagents are required by the selected master skill but unavailable and the user has not accepted degradation
- the user requests nested master-skill-in-subagent execution
- the instruction asks for destructive, production, payment, auth, tenant, secret, or broad dirty-file action without explicit approval
- the route would bypass an owner skill's evidence, verification, closure, or ship gate

## Final Report

For direct answers:

```text
Result: [answer]
Route: direct answer
Chantier: non applicable
```

For handoff:

```text
Route: [selected skill]
Reason: [short reason]
Execution: direct main-thread handoff; selected skill owns any delegated sequential execution
```

Then continue with the selected skill's final-report contract.

For blocked routing:

```text
Route: blocked
Reason: [short reason]
Decision needed:
1. [numbered routing question]
Chantier: non applicable
```

## Rules

- Keep this skill thin.
- Do not duplicate internals of owner skills.
- Do not mutate files before the selected owner skill takes over.
- Do not launch selected master skills inside subagents.
- Do not treat direct handoff as parallelism.
- Do not create specs, bug files, commits, deployments, or public-content changes directly from this router.
- Match user-facing language to the user's active language.
