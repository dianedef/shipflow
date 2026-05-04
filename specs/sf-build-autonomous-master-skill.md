---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.3.0"
project: ShipFlow
created: "2026-04-29"
created_at: "2026-04-29 09:02:11 UTC"
updated: "2026-05-04"
updated_at: "2026-05-04 04:58:00 UTC"
status: ready
source_skill: sf-spec
source_model: "GPT-5 Codex"
scope: feature
owner: Diane
user_story: "En tant qu'utilisatrice finale ShipFlow non-développeuse, je veux lancer une seule commande sf-build avec ma story et être guidée par des questions utiles pendant qu'un workflow délégué par défaut orchestre la spec, l'implémentation, la vérification, la clôture et le ship, afin d'obtenir un résultat implémenté, vérifié, clos et poussé sans piloter manuellement chaque skill."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/sf-build/SKILL.md
  - skills/sf-init/SKILL.md
  - skills/sf-docs/SKILL.md
  - skills/sf-spec/SKILL.md
  - skills/sf-ready/SKILL.md
  - skills/sf-model/SKILL.md
  - skills/sf-start/SKILL.md
  - skills/sf-verify/SKILL.md
  - skills/sf-browser/SKILL.md
  - skills/sf-auth-debug/SKILL.md
  - skills/sf-prod/SKILL.md
  - skills/sf-test/SKILL.md
  - skills/sf-end/SKILL.md
  - skills/sf-ship/SKILL.md
  - skills/sf-help/SKILL.md
  - skills/references/chantier-tracking.md
  - skills/references/subagent-roles/technical-reader.md
  - skills/references/subagent-roles/editorial-reader.md
  - skills/references/subagent-roles/sequential-executor.md
  - skills/references/subagent-roles/wave-executor.md
  - skills/references/subagent-roles/integrator.md
  - skills/references/technical-docs-corpus.md
  - skills/references/editorial-content-corpus.md
  - docs/technical/
  - docs/technical/code-docs-map.md
  - docs/editorial/
  - CONTENT_MAP.md
  - GUIDELINES.md
  - shipflow-spec-driven-workflow.md
  - README.md
  - TASKS.md
depends_on:
  - artifact: "BUSINESS.md"
    artifact_version: "1.1.0"
    required_status: "reviewed"
  - artifact: "PRODUCT.md"
    artifact_version: "1.1.0"
    required_status: "reviewed"
  - artifact: "GUIDELINES.md"
    artifact_version: "1.3.0"
    required_status: "reviewed"
  - artifact: "BRANDING.md"
    artifact_version: "1.0.0"
    required_status: "reviewed"
  - artifact: "README.md"
    artifact_version: "0.7.1"
    required_status: "draft"
  - artifact: "shipflow-spec-driven-workflow.md"
    artifact_version: "0.12.0"
    required_status: "draft"
  - artifact: "skills/references/chantier-tracking.md"
    artifact_version: "0.4.0"
    required_status: "draft"
  - artifact: "skills/references/technical-docs-corpus.md"
    artifact_version: "1.1.0"
    required_status: "active"
  - artifact: "skills/references/editorial-content-corpus.md"
    artifact_version: "1.1.0"
    required_status: "active"
  - artifact: "docs/technical/code-docs-map.md"
    artifact_version: "1.0.0"
    required_status: "reviewed"
  - artifact: "CONTENT_MAP.md"
    artifact_version: "0.3.0"
    required_status: "draft"
supersedes: []
evidence:
  - "User decision 2026-04-29: create a user-facing master skill named sf-build."
  - "User decision 2026-04-29: sf-build must run the full flow through sf-end and sf-ship, not stop after implementation."
  - "User decision 2026-04-29: the user may be prompted multiple times, preferably via integrated prompts with prepared answers, to avoid regressions."
  - "User decision 2026-04-29: subagents are the intended default operating model so the master conversation stays high-level."
  - "Runtime and official docs constraint 2026-04-29: Codex subagents require explicit user request before spawning."
  - "User concern 2026-04-29: sf-build must not produce half-coded features or code/design regressions; it needs explicit guardrails around touching existing behavior."
  - "Repo investigation 2026-04-29: existing lifecycle skills already cover sf-spec, sf-ready, sf-start, sf-verify, sf-end, and sf-ship with chantier tracing."
  - "Repo investigation 2026-04-29: PRODUCT.md defines the user problem as lost context, weak handoffs, silent ambiguity, and incomplete verification."
  - "sf-ready 2026-04-29: previous draft was not ready because default subagents, integrated question fallback, freshness evidence, and changelog timing were underspecified."
  - "User decision 2026-04-29: ShipFlow should standardize language by layer: English internal contracts, user-facing interaction in the user's active language, with proper French accents for French."
  - "User decision 2026-04-30: invoking sf-build itself means the user authorizes and expects subagents for the current chantier; sf-build should not ask repeatedly before launching bounded subagents."
  - "User decision 2026-04-30: before sf-start, sf-build should decide whether to run sf-model so large chantiers use the right model balance for efficiency, reliability, and token cost."
  - "User decision 2026-04-30: sf-build must continue a matching existing chantier by default and create a new spec only when the user story or outcome is genuinely new."
  - "User decision 2026-04-30: sf-build should delegate file-reading, editing, and validation to one bounded subagent at a time by default; parallel subagents are allowed only when a ready spec defines non-overlapping execution batches."
  - "User decision 2026-05-01: internal subagent roles should be documented as one reference file per role, not collapsed into one shared role file."
  - "User decision 2026-05-01: the Technical Reader should use the project documentation corpus as context and should identify where technical documentation must be updated when code changes happen in separate execution workspaces."
  - "User decision 2026-05-01: technical documentation updates should happen at the end of each execution cycle or wave, before the next wave, unless explicitly marked pending final integration with a reason."
  - "User decision 2026-05-01: replace the generic Reader role with separate Technical Reader and Editorial Reader role files, with no reader.md alias and no loss of existing Reader responsibilities."
  - "sf-ready 2026-05-01: blocked on dependency metadata alignment and ShipFlow language doctrine for internal contracts."
  - "User decision 2026-05-02: sf-build must consume project-local technical and editorial governance corpora instead of relying on conversation memory or manual per-project governance chantiers."
  - "sf-ship 2026-05-02: governance corpus integration shipped; sf-init bootstraps project corpus layers, sf-docs owns technical/editorial corpus creation and audit, and sf-build consumes those layers through gates and readers."
  - "sf-ready 2026-05-02: revalidated and blocked on dependency metadata drift after README.md and shipflow-spec-driven-workflow.md version updates."
  - "sf-spec 2026-05-02: refreshed sf-build dependency metadata after README.md 0.5.0 and shipflow-spec-driven-workflow.md 0.8.0 became the active artifacts."
  - "README.md 0.7.1 and shipflow-spec-driven-workflow.md 0.12.0 keep sf-build aligned on browser evidence routing, governance corpus ownership, report modes, and business-context decision questions."
  - "sf-ready 2026-05-02: validated the reconciled spec after dependency metadata, governance corpus ownership, and browser evidence routing updates."
  - "sf-ready 2026-05-02: revalidated official OpenAI Codex docs freshness, behavior contract, language doctrine, adversarial risk, and security gates before sf-start."
  - "User decision 2026-05-04: sf-build Plan Mode questions must include precise context, the root problem, business stakes, a best-practice recommendation, and decision options suitable for a business owner rather than a technical operator."
next_step: "None"
---

# Spec: sf-build Autonomous Master Skill

## Title

sf-build Autonomous Master Skill

## Status

ready

## User Story

En tant qu'utilisatrice finale ShipFlow non-développeuse, je veux lancer une seule commande `sf-build` avec ma story et être guidée par des questions utiles pendant qu'un workflow délégué par défaut orchestre la spec, l'implémentation, la vérification, la clôture et le ship, afin d'obtenir un résultat implémenté, vérifié, clos et poussé sans piloter manuellement chaque skill.

## Minimal Behavior Contract

When the user runs `sf-build` with an intent, the skill becomes the single user-facing pilot for the current chantier: it first checks whether an active spec already covers the same promise, creates or attaches a spec, loops spec/readiness until the contract is executable, runs the Governance Corpus Gate, applies model routing before `sf-start` when the chantier is large or risky, then executes through bounded delegation. It also routes browser evidence through the official verification skills: `sf-browser` for generic non-auth page/route/preview evidence, `sf-auth-debug` for auth/session/callback/protected-route evidence, `sf-prod` for hosted deployment/runtime evidence, and `sf-test` for durable manual QA or retest logs. The Governance Corpus Gate checks project-local `docs/technical/`, `docs/technical/code-docs-map.md`, `CONTENT_MAP.md`, and applicable `docs/editorial/` state before implementation, routing to `sf-docs` bootstrap/audit or recording an explicit no-impact/no-surface reason before work continues. The default execution mode is one bounded subagent at a time for reading, editing, validation, documentation alignment, closure, and ship preparation; parallel work is allowed only when a ready spec defines ordered `Execution Batches` with non-overlapping ownership and validation per batch. Success is observable through a chantier spec with run history, a short user-facing status trail, verified implementation, correctly routed browser/manual evidence, governance corpus status, docs/content alignment or justified pending items, and a final `sf-end` plus `sf-ship` path when gates pass. Failure is observable through a concise blocking question or stop report before dangerous action. The easy edge case to miss is letting convenience override the gates: editing in the master conversation, spawning opportunistic parallel agents, creating a duplicate spec, shipping dirty files outside scope, treating shipped ShipFlow governance specs as per-project tasks, collapsing `sf-browser`, `sf-auth-debug`, `sf-prod`, and `sf-test` into one vague proof step, or moving to the next wave before technical docs and public content impact have been handled.

## Success Behavior

- Preconditions: the user provides a story, task, bug, or goal; the current repository is identifiable; lifecycle skills are available; and the user can answer material decision questions.
- Trigger: the user runs `/sf-build <story>` or `$sf-build <story>`.
- User/operator result: the master conversation stays focused on product decisions, short status, and final outcome; routine file reading, edits, validation, and technical reports are delegated to bounded subagents by default; `sf-build` does not ask again before every sequential subagent while the action remains inside the current chantier scope. When a material decision is required, especially in Plan Mode, the user receives a decision brief with the root problem, business stakes, practical options, and an honorable best-practice recommendation before the actual question.
- System effect: `sf-build` performs an `Existing Chantier Check`, attaches to a matching active spec when possible, creates a new spec only for a new promise or result, traces its run when one spec is in scope, loops `sf-spec` and `sf-ready` until ready or blocked, applies a `Governance Corpus Gate`, applies a `Model Routing Gate` before `sf-start` for high-risk or costly work, runs one bounded write-capable subagent at a time by default, uses the Technical Reader for code-docs impact, uses the Editorial Reader for public-surface and claim impact, applies technical docs and editorial updates through a write-capable executor or integrator, verifies the user story, routes browser evidence to `sf-browser`, `sf-auth-debug`, `sf-prod`, or `sf-test` according to proof type, runs `sf-end`, then calls `sf-ship` only when verification, closure, bug-risk, secret, and staging gates pass.
- Success proof: the chantier spec includes `Skill Run History` and `Current Chantier Flow`; the final user-facing report names the result, validations, browser/manual proof route when relevant, execution mode (`main-only`, `delegated sequential`, or `spec-gated parallel`), commit/push when `sf-ship` succeeds, files excluded from ship if any, and remaining proof limits if any.
- Silent success: not allowed. The user must see material decisions, high-level phase status, selected execution mode, any parallel batches, and final verdict.

## Error Behavior

- Expected failures: vague story, multiple matching specs, unavailable subagents, unavailable integrated prompt tool, rejected single-agent degradation, requested parallelism without `Execution Batches`, overlapping ownership, invalid batch dependency order, missing or stale governance corpus state, public/content surfaces without editorial governance, code areas without a technical map or explicit non-coverage reason, out-of-scope file need, uncertain permission to touch existing behavior or design, failed readiness, blocked subagent, incompatible subagent outputs, failed checks or verification, misrouted browser/manual evidence, partial changes, secrets or unrelated dirty files, blocking bug risk, and failed push.
- User/operator response: if a user answer can unblock the chantier, `sf-build` asks one framed decision question with 2 or 3 prepared options plus free-form answer support; the frame explains the root problem, the business stakes, the practical tradeoffs, and the recommended best-practice answer in non-technical language. Otherwise it reports the blocking condition and the next safe action, without claiming the work is delivered.
- System effect: no subagent is launched outside the current authorized scope; no write-capable subagents run in parallel without ready `Execution Batches`; no next wave starts while impacted technical docs or public-content updates from the current wave remain unresolved, unless every remaining item is marked `pending final integration` or `pending final copy` with reason and resolution condition; no `sf-start` runs before the spec is ready and the Governance Corpus Gate has passed, routed to `sf-docs`, or recorded explicit no-impact/no-surface status; no full `sf-end` runs before the user story is sufficiently verified; no `sf-ship` runs if checks, bug gate, secret check, staging scope, or central validation fail without explicit user approval.
- Must never happen: implement outside validated scope, create a duplicate spec for an existing chantier, modify sensitive existing behavior without a decision, do routine file edits in the master conversation when sequential delegation is available, let executors change code without Technical Reader docs impact review or Editorial Reader public-content impact review, bypass missing project-local governance corpus state, rerun ShipFlow's shipped governance specs as project bootstrap work, run concurrent write-capable subagents without ready non-overlapping batches, ask for delegation consent before every bounded sequential subagent, ignore a readiness failure, use `sf-test`, `sf-auth-debug`, or `sf-prod` as a generic substitute for non-auth browser evidence that belongs to `sf-browser`, ship a half-coded feature, hide a regression, commit unrelated dirty files, use `all-dirty` without explicit request, overwrite user changes, or produce a long technical final report for an end user.
- Silent failure: not allowed. Each blocked step must be visible as a user decision, missing proof, failed validation, or runtime constraint.

## Problem

ShipFlow's current lifecycle is rigorous but too manual for the target user. A non-developer end user must chain `sf-spec`, `sf-ready`, possibly another spec pass, then `sf-start`, `sf-verify`, `sf-test`, `sf-end`, and `sf-ship`. That exposes too much technical workflow detail and makes the user operate a system that the agent should orchestrate.

The opposite risk is just as important: hiding the process can make the agent code too quickly, alter existing behavior without consent, miss product intent, leave documentation stale, or ship regressions. The desired interface is not fewer safeguards; it is fewer technical reports and more useful questions before risky decisions.

The previous readiness passes established three core constraints: `sf-build` invocation is bounded delegation consent for the current chantier, prompts need a plain-text fallback when the integrated question tool is unavailable, and parallel subagents must remain spec-gated rather than opportunistic.

## Solution

Create a new lifecycle skill, `sf-build`, as the user-facing orchestrator for end-to-end ShipFlow work. It keeps the master conversation at the level of product decisions and high-level status, delegates file work sequentially by default, uses role-specific internal subagent contracts, gates parallelism through ready `Execution Batches`, loops spec/readiness until executable, checks the project-local governance corpus before implementation, applies model routing before implementation when needed, routes browser evidence to the right verification skill, and then runs implementation, verification, manual testing when relevant, closure, and ship only when gates pass.

## Scope In

- Create `skills/sf-build/SKILL.md` as a user-facing lifecycle skill.
- Define `sf-build` as the end-to-end orchestrator for intake, bounded runtime authorization, questions, spec, readiness, model routing, start, verify, test, end, and ship.
- Define three execution modes: `main-only` for purely conversational answers, `delegated sequential` by default for file reading/editing/validation, and `spec-gated parallel` only from ready non-overlapping `Execution Batches`.
- Treat `/sf-build <story>` or `$sf-build <story>` as explicit user request for bounded subagents in the current chantier, run sequentially by default.
- Create one role reference file per internal role under `skills/references/subagent-roles/`: `technical-reader.md`, `editorial-reader.md`, `sequential-executor.md`, `wave-executor.md`, and `integrator.md`; do not create `reader.md`.
- Define a `Governance Corpus Gate` before implementation that checks `docs/technical/`, `docs/technical/code-docs-map.md`, `CONTENT_MAP.md`, and applicable `docs/editorial/` state, then routes to `sf-docs` bootstrap/audit or records an explicit no-impact/no-surface reason before `sf-start`.
- Define the Technical Reader as a strict read-only role that loads `skills/references/technical-docs-corpus.md` and project-local `docs/technical/code-docs-map.md`, maps code to docs, identifies technical documentation impact, and produces a `Documentation Update Plan`.
- Define the Editorial Reader as a strict read-only role that loads `skills/references/editorial-content-corpus.md`, `CONTENT_MAP.md`, project-local `docs/editorial/`, business/product/brand/GTM contracts, public pages, claims, and content surfaces, then produces an `Editorial Update Plan` and a `Claim Impact Plan` when public behavior or promises are affected.
- Define the `Documentation Update Gate`: after every parallel wave or large sequential block, impacted technical docs are applied by a write-capable executor or integrator and reviewed by the Technical Reader before the next wave, unless marked `pending final integration` with reason and resolution condition.
- Define the `Editorial Update Gate`: after every wave or large sequential block that changes visible behavior, copy, public pages, public docs, pricing, support copy, skill pages, or claims, impacted public content is applied by a write-capable executor or integrator and reviewed by the Editorial Reader before closure or ship, unless marked `pending final copy` with reason and resolution condition.
- Define fallback to master/single-agent execution only when subagents are unavailable or refused, and require explicit user agreement for non-trivial file, validation, or ship work.
- Keep the master conversation focused on decisions, short status, and final report.
- Add an `Existing Chantier Check` before any spec creation.
- Add `Spec-Gated Parallelism` rules that block opportunistic parallelism and route back to spec/readiness when batches are missing or unsafe.
- Integrate a bounded `sf-spec` / `sf-ready` loop.
- Add a question protocol with prepared options and free-form answer support for vision, scope, existing behavior, design, data, security, validation, closure, staging, and ship decisions.
- Apply the ShipFlow language doctrine: internal skill instructions, role contracts, section headings, acceptance criteria, stop conditions, and validation notes are in English; questions and final reports are in the active user language, with proper accents for French.
- Add a `Model Routing Gate` before `sf-start`, mandatory for large, high-risk, multi-domain, parallel, ambiguous, token-costly, or high-cost-of-error chantiers.
- Define a `Browser Evidence Routing Gate`: use `sf-browser` for generic non-auth URL, route, preview, production page, console/network, and screenshot evidence; use `sf-auth-debug` for auth, sessions, OAuth, cookies, callbacks, organizations, tenants, protected routes, or permission failures; use `sf-prod` for hosted deployment status, Vercel/runtime logs, serverless or edge runtime evidence, and live health checks; use `sf-test` for durable manual QA plans, retests, and structured manual testing logs.
- Define a plain-text fallback when integrated prompt tooling is unavailable.
- Define gates that block `sf-start`, `sf-end`, or `sf-ship` when contract or proof is insufficient.
- Document how `sf-build` interacts with `sf-end` and `sf-ship`.
- Update `sf-help`, `shipflow-spec-driven-workflow.md`, and relevant user-facing docs.
- Add or update a local `TASKS.md` entry during implementation if the chantier is not already visible.

## Scope Out

- Do not remove or replace existing atomic lifecycle skills.
- Do not make manual `sf-spec`, `sf-ready`, `sf-start`, `sf-verify`, `sf-end`, or `sf-ship` usage impossible.
- Do not build a graphical interface.
- Do not promise that `sf-build` will never ask questions; useful questions are a core safeguard.
- Do not launch subagents outside the current scope authorized by `sf-build`.
- Do not run parallel subagents outside explicit ready `Execution Batches`.
- Do not collapse all internal role contracts into one ambiguous file or expose internal roles as user-facing commands.
- Do not perform routine file edits in the master conversation when sequential delegation is available.
- Do not degrade to master/single-agent mode without explicit user agreement when the chantier touches files, validation, or ship.
- Do not run `sf-ship` without checks or without explicit decision when ship is risky.
- Do not use `all-dirty`, `ship-all`, or equivalent without explicit request.
- Do not automatically revert user changes or unrelated files.
- Do not change existing lifecycle skill behavior except for discoverability, chantier matrix registration, or explicitly listed documentation compatibility.
- Do not turn ShipFlow into autonomous automation without product accountability from the user.
- Do not use ShipFlow's own shipped technical/editorial governance specs as per-project bootstrap tasks; future projects use `sf-init` and `sf-docs`.

## Constraints

- `sf-build` reduces technical noise in the conversation; it must not reduce rigor.
- Internal contracts must be English. User-facing questions, progress updates, and final reports must use the active user language; French user-facing text must be natural and accented.
- Sequential delegation is the normal execution mode. A simple `/sf-build <story>` or `$sf-build <story>` authorizes bounded subagents for the current chantier, one at a time by default.
- The master `sf-build` agent chooses the next subagent and mission without asking again while the action is in scope, non-destructive, and covered by the spec gates.
- Parallelism is forbidden by default. It is allowed only from ready `Execution Batches` with exclusive ownership, explicit dependencies, per-batch validation, and integration order.
- If `sf-build` wants parallelism but the spec does not prove safe batches, the next action is spec update or readiness rerun, not ad hoc spawning.
- Before creating a spec, `sf-build` must prefer continuing an existing spec that shares the same user story, expected result, linked systems, affected files/surfaces, or `Current Chantier Flow`; if multiple plausible specs remain, it asks.
- Each subagent must have a bounded mission, file or surface ownership, expected output, and no overlapping writes with another subagent.
- In sequential mode, the master integrates or validates each result before launching the next subagent.
- Each internal role must have a short, stable, independently loadable reference file.
- Technical and Editorial Readers are read-only. They diagnose impact and produce plans; executors or integrators apply changes.
- The Governance Corpus Gate runs before `sf-start`. Missing `docs/technical/`, missing `docs/technical/code-docs-map.md`, missing applicable `docs/editorial/`, or stale `CONTENT_MAP.md` must become `created`, `already existed`, `needs audit`, `skipped`, or `blocked` status before implementation proceeds.
- A code-changing chantier must have a technical map or an explicit technical no-impact/non-coverage reason.
- A public-content, visible-behavior, README, FAQ, pricing, support, public skill page, blog/article, or claim-changing chantier must have editorial governance or an explicit no editorial impact/no-surface reason.
- A wave or large execution block is not complete until impacted docs and public content are updated, reviewed, explicitly marked no-impact, or marked pending with reason and resolution condition.
- Browser proof must be routed by evidence type: generic non-auth browser inspection goes to `sf-browser`, auth/session investigation goes to `sf-auth-debug`, deployment/runtime proof goes to `sf-prod`, and durable manual QA or retest protocols go to `sf-test`.
- Questions must be asked before dangerous action.
- Prepared options must always allow a free-form answer when the options do not fit.
- If integrated prompt tooling is unavailable, the skill asks a short plain-text question and stops until the answer when the decision changes scope, security, data, validation, closure, staging, or ship.
- Changes to existing behavior, design systems, permissions, data, APIs, public content, billing, secrets, migrations, or destructive actions require an explicit decision if the ready spec has not already bounded them.
- Long internal reports must stay in specs, chantier traces, or subagent outputs; the user-facing final report stays short.
- The skill must preserve user changes, avoid invented proof, and refuse ship while blocking checks remain.

## Dependencies

- Local runtime: ShipFlow skill system, markdown specs, git, project checks, and existing `sf-end` / `sf-ship` mechanisms.
- Codex runtime: subagents are available in Codex CLI/app only when requested or authorized; for `sf-build`, command invocation is the explicit bounded delegation request for the current chantier. Subagents inherit parent sandbox and approval controls and may fail if fresh approval cannot be surfaced in non-interactive mode. Parallelism remains optional and spec-gated.
- Prompt runtime: integrated question tooling such as `AskUserQuestion` may be unavailable; `sf-build` must provide a plain-text fallback.
- Document contracts: `BUSINESS.md` 1.1.0 reviewed, `PRODUCT.md` 1.1.0 reviewed, `GUIDELINES.md` 1.3.0 reviewed, `BRANDING.md` 1.0.0 reviewed, `README.md` 0.5.0 draft, `shipflow-spec-driven-workflow.md` 0.8.0 draft, `skills/references/chantier-tracking.md` 0.1.0 draft, `skills/references/technical-docs-corpus.md` 1.1.0 active, `skills/references/editorial-content-corpus.md` 1.1.0 active, `docs/technical/code-docs-map.md` 1.0.0 reviewed, and `CONTENT_MAP.md` 0.3.0 draft.
- Draft dependency acceptance: `README.md`, `shipflow-spec-driven-workflow.md`, `CONTENT_MAP.md`, and `skills/references/chantier-tracking.md` are still draft but are active ShipFlow governance docs for this chantier; their exact versions are recorded and no dependency is marked stale.
- Fresh external docs: fresh-docs checked on 2026-05-02 against official OpenAI documentation: Codex Subagents (`https://developers.openai.com/codex/subagents`), Codex CLI subagents (`https://developers.openai.com/codex/cli/features#subagents`), Codex approvals and sandbox controls (`https://developers.openai.com/codex/agent-approvals-security#sandbox-and-approvals`), Codex network access (`https://developers.openai.com/codex/agent-approvals-security#network-access-`), and Codex config reference (`https://developers.openai.com/codex/config-reference#configtoml`). Decision: the spec may rely on bounded Codex subagents because invoking `sf-build` is the explicit delegation request for the current chantier; the skill must keep fan-out to one write-capable subagent at a time except ready `Execution Batches`, preserve parent approvals/sandbox, and avoid unbounded external access without a separate gate.

## Invariants

- Atomic lifecycle skills remain the source of truth for their discipline; `sf-build` orchestrates them instead of duplicating all of their checks.
- The spec-first flow remains durable in `specs/`.
- The master conversation stays understandable for a non-developer end user.
- Subagents are authorized by the current `sf-build` invocation only for the current chantier; they cannot expand scope or write overlapping files without explicit coordination.
- One write-capable subagent may be active at a time unless a ready spec defines safe `Execution Batches`.
- If the agent wonders whether it should parallelize but no ready spec says so, it must first update the spec or rerun readiness.
- Any change to existing behavior must be bounded by the spec or approved by the user.
- Project-local governance corpus state is an implementation gate, not optional background context.
- The shipped governance specs are historical ShipFlow doctrine; `sf-build` consumes the corpora created or maintained by `sf-init` and `sf-docs`.
- A partially implemented feature cannot be closed as delivered.
- Ship does not prove product correctness; `sf-build` must distinguish pushed from proven.
- `sf-build` should ask too many useful product questions rather than too few when an answer prevents a regression.
- User-facing questions, short updates, and final reports use the user's active language; internal instructions, stable section names, acceptance criteria, stop conditions, and validation notes use English.
- Runtime limitations must not become silent bypasses. `sf-build` must ask, degrade with consent, or block.

## Links & Consequences

- Upstream intake: `sf-explore` can remain a reflection entrypoint, but `sf-build` must also accept a direct story and run short exploration when needed.
- Core lifecycle: `sf-spec`, `sf-ready`, `sf-start`, `sf-verify`, `sf-browser`, `sf-auth-debug`, `sf-prod`, `sf-test`, `sf-end`, and `sf-ship` become orchestrated internal phases when their evidence type applies.
- Existing chantier routing: `sf-build` treats `specs/` as the durable registry and continues a matching chantier instead of creating a duplicate.
- Runtime orchestration: `sf-build` must name when it delegates, which subagent owns which files or surfaces, how outputs are integrated, and which parallel waves are allowed.
- Governance corpus orchestration: before `sf-start`, `sf-build` checks project-local technical/editorial corpus state and routes missing or stale layers through `sf-docs` rather than duplicating bootstrap logic.
- Technical documentation orchestration: the Technical Reader maps code changes to `docs/technical/`, README, guides, workflow docs, specs, and internal references; the master blocks the next wave unless updates are applied, no-impact is justified, or pending status is explicit.
- Editorial orchestration: the Editorial Reader maps visible behavior and claim changes to `CONTENT_MAP.md`, public Astro pages, public docs, FAQ, pricing, skill pages, support copy, README, and claim surfaces; closure and ship are blocked unless updates are applied, no-impact is justified, or pending final copy is explicit.
- Browser evidence orchestration: `sf-build` does not invent a browser verification workflow; it routes generic non-auth browser inspection to `sf-browser`, auth/session debugging to `sf-auth-debug`, deployment/runtime evidence to `sf-prod`, and durable manual QA/retests to `sf-test`.
- Model routing: `sf-model` remains a helper; `sf-build` may use it as a gate before `sf-start` and records the decision in its own report/trace.
- Chantier tracking: `sf-build` writes its own run trace when one unique spec exists and keeps lifecycle substeps visible.
- Task tracking: `sf-end` remains responsible for final `TASKS.md` and `CHANGELOG.md` closure updates; `sf-build` calls it at the right time instead of reimplementing that logic.
- Shipping: `sf-ship` remains responsible for commit and push; `sf-build` must pass a bounded staging scope and must not use `all-dirty` unless explicitly requested.
- Help/docs: `sf-help` and `shipflow-spec-driven-workflow.md` present `sf-build` as the recommended end-user entrypoint while preserving atomic skills for expert use and manual recovery.
- README/public docs: public documentation must explain that `sf-build` asks useful questions, orchestrates gates, and is not uncontrolled autonomy.
- Regression surface: existing code, design, docs, tests, public claims, security gates, runtime approvals, and dirty git state become explicit gates before closure or ship.

## Documentation Coherence

- `skills/sf-build/SKILL.md` must be created with frontmatter, argument hint, canonical paths, chantier tracking, lifecycle role, complete orchestration workflow, question fallback, and the rule that invocation is bounded delegation consent for the current chantier.
- `skills/sf-build/SKILL.md` must include an `Existing Chantier Check` before any launch or spec creation.
- `skills/sf-build/SKILL.md` must include `Execution Modes`: `main-only`, `delegated sequential`, and `spec-gated parallel`.
- `skills/sf-build/SKILL.md` must include a `Governance Corpus Gate` before `sf-start`, with concrete checks for `docs/technical/`, `docs/technical/code-docs-map.md`, `CONTENT_MAP.md`, applicable `docs/editorial/`, and route-to-`sf-docs` outcomes.
- `skills/sf-build/SKILL.md` must treat `sf-init` and `sf-docs` as the lifecycle owners for corpus bootstrap and audit; `sf-build` consumes their outputs and routes to them when corpus state is missing or stale instead of reimplementing scaffolding.
- `skills/sf-build/SKILL.md` must include `Spec-Gated Parallelism` rules that block opportunistic parallelism and route back to spec/readiness when batches are missing or unsafe.
- `skills/sf-build/SKILL.md` must include a `Documentation Update Gate` with `pending final integration` as a documented exception.
- `skills/sf-build/SKILL.md` must include an `Editorial Update Gate` with `no editorial impact` and `pending final copy` as documented outcomes.
- `skills/sf-build/SKILL.md` must include `Browser Evidence Routing` with explicit route rules for `sf-browser`, `sf-auth-debug`, `sf-prod`, and `sf-test`; it must not treat these skills as interchangeable proof buckets.
- `skills/references/subagent-roles/technical-reader.md` must define the `Technical Reader Agent Contract`: strict read-only behavior, `skills/references/technical-docs-corpus.md`, project-local `docs/technical/code-docs-map.md`, code-docs mapping, `Documentation Update Plan`, outputs, and no edit/stage/destructive validation permissions.
- `skills/references/subagent-roles/editorial-reader.md` must define the `Editorial Reader Agent Contract`: strict read-only behavior, `skills/references/editorial-content-corpus.md`, `CONTENT_MAP.md`, project-local `docs/editorial/`, public surfaces, Astro pages, README/public docs, claims, `Editorial Update Plan`, `Claim Impact Plan`, outputs, and no edit/stage/destructive validation permissions.
- `skills/references/subagent-roles/sequential-executor.md` must define the `Sequential Executor Contract`: one active write-capable executor by default, assigned write set, approved technical/editorial update application, stop conditions, validation expectations, and output summary.
- `skills/references/subagent-roles/wave-executor.md` must define the `Wave Executor Contract`: temporary role, only launched from ready `Execution Batches`, exclusive write set, no shared surfaces unless explicitly assigned, and integrable output.
- `skills/references/subagent-roles/integrator.md` must define the `Integrator Contract`: integrate between waves, detect conflicts, validate updates, ensure docs/content gates are satisfied, and authorize the next wave only after proof.
- `skills/sf-build/SKILL.md` must include a `Model Routing Gate` before `sf-start`.
- `skills/sf-build/SKILL.md` and all role reference files are internal contracts and must be written in English. They may include labeled user-facing examples in French when useful.
- `skills/references/chantier-tracking.md` must add `sf-build` as `Trace category: obligatoire` and `Process role: lifecycle`.
- `skills/sf-help/SKILL.md` must add `sf-build` as the primary user-facing entrypoint and explain when to use atomic skills.
- `shipflow-spec-driven-workflow.md` must add the recommended flow: `sf-build` for end users, atomic skills for expert control or manual recovery.
- `README.md` or public docs must mention that invoking `sf-build` authorizes bounded sequential delegation for the current chantier, that parallelism requires ready non-overlapping `Execution Batches`, that the skill asks useful questions for risky decisions, and that it orchestrates without drowning the user in technical detail.
- Internal role reference files must not be presented as user-facing commands.
- `TASKS.md` should include implementation tracking during `sf-start` if the chantier is not already visible.
- `CHANGELOG.md` must not be modified during spec or as a prerequisite for `sf-start`; `sf-end` aligns it after implementation and verification.
- No known guide, FAQ, onboarding, pricing page, or screenshot outside `README.md`, `sf-help`, and `shipflow-spec-driven-workflow.md` is required for this chantier.

## Edge Cases

- The user gives a vague story: `sf-build` asks guided questions and does not finalize a spec or start implementation until actor, result, scope, and exclusions are stable.
- The user asks a clarification or extension that touches an active spec: `sf-build` continues that spec by default instead of creating a new chantier.
- Multiple active specs appear close: `sf-build` asks which one to continue or whether the request is new, then waits for the answer.
- The user runs `/sf-build <story>`: the invocation is bounded delegation consent for the current chantier, so `sf-build` may launch necessary bounded sequential subagents without asking again for each one.
- The user requests a micro-fix that still requires file reading or editing: `sf-build` keeps the master clean and delegates the file work unless the answer is purely conversational.
- The project has code but no `docs/technical/code-docs-map.md`: `sf-build` routes to `/sf-docs technical` or blocks before implementation unless the current request has an explicit technical no-impact reason.
- The project has public pages, README public promises, FAQ, pricing, support copy, public skill pages, or runtime content but no `docs/editorial/`: `sf-build` routes to `/sf-docs editorial` or blocks before closure/ship unless the current request has an explicit no editorial impact reason.
- The project has no public/content surfaces: `sf-build` records `no editorial surfaces detected` and continues without fabricating a public-content corpus.
- The project has an Astro or MDX runtime content schema: the Editorial Reader preserves that schema and does not add ShipFlow metadata to runtime content unless the schema accepts it.
- An executor changes code in a separate workspace/zspace: the Technical Reader compares the planned or summarized change with the technical documentation corpus and names docs to update before `sf-end`.
- An executor changes visible behavior, a public promise, public page, or Astro content: the Editorial Reader maps impacted public surfaces and claims before closure or ship.
- A wave ends with impacted technical docs: a write-capable executor or integrator applies updates, the Technical Reader reviews them, then the Integrator may authorize the next wave.
- A wave ends with impacted public content or claims: a write-capable executor or integrator applies updates, the Editorial Reader reviews them, then closure or ship may continue.
- A doc depends on unstable behavior: the item remains in the plan as `pending final integration` or `pending final copy` with reason and resolution condition.
- A ready spec contains safe `Execution Batches`: `sf-build` may launch agents from the same batch in parallel, then integrate before the next batch.
- Work looks large enough for parallelism but the spec lacks batches: `sf-build` does not parallelize; it updates the spec or reruns readiness.
- The chantier is large, multi-domain, or costly: `sf-build` applies `sf-model` before `sf-start`.
- The chantier is small and clear: `sf-build` may record that `sf-model` is not needed and continue with the current model.
- The user refuses subagents or the runtime cannot spawn them: `sf-build` explains the degradation and asks whether to proceed single-agent, split the chantier, or stop.
- The integrated prompt tool is unavailable: `sf-build` asks a short plain-text question with numbered options and waits before dangerous action. Example user-facing French prompt: `Veux-tu modifier l'existant, ajouter un comportement séparé, ou arrêter pour cadrer une spec plus stricte ?`
- The user asks for a change that may alter existing behavior: `sf-build` asks whether to modify existing behavior, add a parallel behavior, or stop for stricter spec work.
- Readiness fails: `sf-build` runs a spec correction pass and another readiness review within an explicit iteration limit.
- The spec/ready loop fails repeatedly: `sf-build` stops with a short block and a question or recommendation instead of coding anyway.
- The change needs generic browser evidence on a public or non-auth route: `sf-build` calls `sf-browser` and records its page, console/network, screenshot, or interaction evidence instead of sending the work to `sf-test` by habit.
- The change touches login, auth callbacks, sessions, cookies, organizations, tenants, permissions, or protected routes: `sf-build` calls `sf-auth-debug` before treating the issue as generic browser evidence.
- The proof depends on a hosted deployment, Vercel status, runtime logs, serverless or edge functions, production health, or live deployment behavior: `sf-build` routes to `sf-prod` before browser/manual proof.
- The proof requires a durable human QA script, repeated retests, or structured manual scenario logging: `sf-build` routes to `sf-test` and keeps `sf-browser` evidence as supporting proof only.
- Two subagents return incompatible outputs: the master stops and integrates, asks for a decision, or launches correction; it never ships incoherent merges.
- A subagent needs approval that cannot be surfaced: `sf-build` treats the step as blocked, stops or closes the subagent, and reports the missing decision.
- Checks pass but `sf-verify` says the user story is not satisfied: no full `sf-end` or `sf-ship` without explicit risk acceptance.
- `sf-end` wants to close with partial proof: `sf-build` chooses partial closure or asks for explicit confirmation.
- `sf-ship` detects dirty files outside scope: `sf-build` asks for staging scope or stops; it does not ship everything by default.
- The user wants to ship despite incomplete validation: `sf-build` asks for explicit confirmation and labels the ship as risky.
- Subagents consult external docs: `sf-build` requires official docs, Context7, or Docs MCP evidence and keeps unbounded internet use out of scope unless separately approved.

## Implementation Tasks

- [ ] Task 1: Create the `sf-build` lifecycle skill
  - File: `skills/sf-build/SKILL.md`
  - Action: Add a new user-facing lifecycle skill with frontmatter, argument hint, canonical paths, mandatory chantier tracking, end-to-end orchestration posture, and final `Chantier` report block.
  - User story link: Gives the user one command to launch a complete chantier.
  - Depends on: None
  - Validate with: `test -f skills/sf-build/SKILL.md && rg -n "sf-build|Trace category|Process role|sf-end|sf-ship|Question Gate|subagent|delegated sequential" skills/sf-build/SKILL.md`
  - Notes: Keep `sf-build` as an orchestrator; do not copy the full logic of every atomic skill.

- [ ] Task 2: Define the question protocol and fallback
  - File: `skills/sf-build/SKILL.md`
  - Action: Add a `Question Gate` that prefers integrated prompt tooling when available, falls back to short plain-text questions with prepared options and free-form answers, and uses the active user language for questions and reports.
  - User story link: Replaces technical reports with useful user decisions without depending on one prompt UI.
  - Depends on: Task 1
  - Validate with: `rg -n "Question Gate|AskUserQuestion|plain-text|fallback|options|free-form|scope|existing behavior|design|security|ship" skills/sf-build/SKILL.md`
  - Notes: Ask product/risk questions when they reduce regression risk; do not ask technical questions the agent can resolve from local context.

- [ ] Task 3: Define default sequential delegation and spec-gated parallelism
  - File: `skills/sf-build/SKILL.md`
  - Action: Define invocation-as-bounded-delegation-consent for the current chantier, establish `delegated sequential` as the default mode, and block parallelism unless a ready spec provides safe `Execution Batches`.
  - User story link: Keeps the master conversation clean while respecting runtime authorization.
  - Depends on: Task 2
  - Validate with: `rg -n "Execution Modes|delegated sequential|Spec-Gated Parallelism|Execution Batches|invocation.*sf-build|bounded delegation|subagent|ownership|master|single-agent" skills/sf-build/SKILL.md`
  - Notes: If subagents are unavailable or refused, ask before degrading to master/single-agent for file, validation, or ship work.

- [ ] Task 3a: Create the Technical Reader contract
  - File: `skills/references/subagent-roles/technical-reader.md`
  - Action: Add a strict read-only `Technical Reader Agent Contract` with `skills/references/technical-docs-corpus.md` loading, project-local `docs/technical/code-docs-map.md` loading, code context collection, code-docs mapping, `Documentation Update Plan`, expected outputs, no-edit/no-stage restrictions, and compact report format.
  - User story link: Preserves technical context and docs impact analysis without polluting the master conversation.
  - Depends on: Task 3
  - Validate with: `test -f skills/references/subagent-roles/technical-reader.md && rg -n "Technical Reader Agent Contract|read-only|technical documentation corpus|technical-docs-corpus|docs/technical/code-docs-map|code-docs|Documentation Update Plan|no edits|dependencies|risks|write sets|report" skills/references/subagent-roles/technical-reader.md`
  - Notes: The Technical Reader may propose batches, risks, and documentation targets; it must never edit files.

- [ ] Task 3b: Create the Editorial Reader contract
  - File: `skills/references/subagent-roles/editorial-reader.md`
  - Action: Add a strict read-only `Editorial Reader Agent Contract` with `skills/references/editorial-content-corpus.md`, `CONTENT_MAP.md`, project-local `docs/editorial/`, public surfaces, Astro pages, README/public docs, claims, `Editorial Update Plan`, `Claim Impact Plan`, expected outputs, no-edit/no-stage restrictions, and compact report format.
  - User story link: Keeps public messaging, content, and claims aligned without merging analysis and execution.
  - Depends on: Task 3
  - Validate with: `test -f skills/references/subagent-roles/editorial-reader.md && rg -n "Editorial Reader Agent Contract|read-only|editorial corpus|editorial-content-corpus|CONTENT_MAP|docs/editorial|public surfaces|Astro|Editorial Update Plan|Claim Impact Plan|no edits|claims|report" skills/references/subagent-roles/editorial-reader.md`
  - Notes: The Editorial Reader may name public surfaces and claim risks; it must never edit files.

- [ ] Task 3c: Create the Sequential Executor contract
  - File: `skills/references/subagent-roles/sequential-executor.md`
  - Action: Add a `Sequential Executor Contract` for one active write-capable executor by default, assigned write set, approved docs/content update application, stop conditions, validations, and output summary.
  - User story link: Enables delegated execution without edit conflicts by default.
  - Depends on: Tasks 3a and 3b
  - Validate with: `test -f skills/references/subagent-roles/sequential-executor.md && rg -n "Sequential Executor Contract|one active|write set|assigned files|documentation update|editorial update|stop|validation|summary" skills/references/subagent-roles/sequential-executor.md`
  - Notes: This role handles normal implementation, micro-fixes, and verification corrections.

- [ ] Task 3d: Create the Wave Executor contract
  - File: `skills/references/subagent-roles/wave-executor.md`
  - Action: Add a `Wave Executor Contract` for temporary parallel executors launched only from ready `Execution Batches`, with exclusive write set, no shared surfaces unless assigned, and integrable output.
  - User story link: Allows speed on large chantiers only when parallelism is proven safe.
  - Depends on: Task 3c
  - Validate with: `test -f skills/references/subagent-roles/wave-executor.md && rg -n "Wave Executor Contract|Execution Batches|exclusive|write set|shared files|temporary|integration" skills/references/subagent-roles/wave-executor.md`
  - Notes: Shared files such as central maps, config, lockfiles, README, `TASKS.md`, and changelog stay out of waves unless explicitly assigned.

- [ ] Task 3e: Create the Integrator contract
  - File: `skills/references/subagent-roles/integrator.md`
  - Action: Add an `Integrator Contract` for reviewing subagent outputs, detecting conflicts, applying integration, ensuring technical/editorial gates are satisfied, rerunning validations, and authorizing the next wave only after proof.
  - User story link: Keeps final coherence under master responsibility and prevents incoherent merges.
  - Depends on: Task 3d
  - Validate with: `test -f skills/references/subagent-roles/integrator.md && rg -n "Integrator Contract|conflicts|merge|wave|Documentation Update Plan|Editorial Update Plan|pending final integration|pending final copy|validation|next wave|master" skills/references/subagent-roles/integrator.md`
  - Notes: This role may be embodied by the master or a sequential executor, never by a concurrent wave executor.

- [ ] Task 4: Implement the spec/readiness loop
  - File: `skills/sf-build/SKILL.md`
  - Action: Describe the `sf-spec` -> `sf-ready` -> spec correction -> readiness rerun loop, iteration limit, user-question conditions, block conditions, and `Skill Run History` preservation.
  - User story link: Removes the manual lifecycle chaining the user performs today.
  - Depends on: Task 3e
  - Validate with: `rg -n "sf-spec|sf-ready|iteration|not ready|blocked|Skill Run History|Current Chantier Flow" skills/sf-build/SKILL.md`
  - Notes: Use 3 iterations as the default limit before block or user decision.

- [ ] Task 4b: Add the Existing Chantier Check
  - File: `skills/sf-build/SKILL.md`
  - Action: Before any spec creation, search active specs, compare user story, expected result, linked systems, files/surfaces, and `Current Chantier Flow`, then choose update, new spec, or user question when ambiguous.
  - User story link: Prevents fragmentation when the user is continuing existing work.
  - Depends on: Task 4
  - Validate with: `rg -n "Existing Chantier Check|specs/|Current Chantier Flow|user story|linked systems|new chantier|existing chantier" skills/sf-build/SKILL.md`
  - Notes: Default to continuing an existing spec; create a new spec only for a new promise or autonomous result.

- [ ] Task 5: Add anti-regression gates before implementation
  - File: `skills/sf-build/SKILL.md`
  - Action: Define pre-`sf-start` gates for dirty baseline, allowed files/surfaces, existing behavior permission, design/docs impact, security/data impact, docs freshness, technical/editorial update gates, and stop conditions.
  - User story link: Prevents a simple request from becoming an unreviewed regression.
  - Depends on: Task 4b
  - Validate with: `rg -n "dirty|regression|existing behavior|design|Documentation Update Gate|Editorial Update Gate|pending final integration|pending final copy|security|fresh-docs|stop" skills/sf-build/SKILL.md`
  - Notes: Work with existing user changes; do not revert them.

- [ ] Task 5a: Add the Governance Corpus Gate
  - File: `skills/sf-build/SKILL.md`
  - Action: Add a pre-`sf-start` gate that checks `docs/technical/`, `docs/technical/code-docs-map.md`, `CONTENT_MAP.md`, applicable `docs/editorial/`, `skills/references/technical-docs-corpus.md`, and `skills/references/editorial-content-corpus.md`, then routes missing or stale layers to `sf-docs` bootstrap/audit or records explicit no-impact/no-surface status before implementation.
  - User story link: Ensures future `sf-build` work consumes project-local governance corpora instead of relying on chat memory or repeated governance chantiers.
  - Depends on: Task 5
  - Validate with: `rg -n "Governance Corpus Gate|docs/technical|docs/editorial|technical-docs-corpus|editorial-content-corpus|CONTENT_MAP|sf-docs technical|sf-docs editorial" skills/sf-build/SKILL.md`
  - Notes: The gate consumes corpus state; it must not duplicate full `sf-docs` scaffold logic.

- [ ] Task 6: Add the `sf-model` gate before `sf-start`
  - File: `skills/sf-build/SKILL.md`
  - Action: Add a `Model Routing Gate` that decides whether to run/apply `sf-model` before `sf-start` based on complexity, duration, cost of error, spec-gated parallelism, token budget, latency, and reliability needs.
  - User story link: Avoids launching major work with an unsuitable model while avoiding unnecessary optimization for small clear deltas.
  - Depends on: Task 5
  - Validate with: `rg -n "Model Routing Gate|sf-model|model routing|reasoning|token|cost|fallback|sf-start" skills/sf-build/SKILL.md`
  - Notes: `sf-model` is non-tracing helper behavior; `sf-build` summarizes the model decision in its own report/trace.

- [ ] Task 7: Integrate `sf-start`, `sf-verify`, browser evidence routing, and `sf-test`
  - File: `skills/sf-build/SKILL.md`
  - Action: Describe how implementation starts from a ready spec, how verification judges the user story, how browser evidence routes to `sf-browser`, `sf-auth-debug`, `sf-prod`, or `sf-test`, and how failures route back to correction or user decision.
  - User story link: Ensures delivered work is verified beyond code existence.
  - Depends on: Task 6
  - Validate with: `rg -n "sf-start|sf-verify|sf-browser|sf-auth-debug|sf-prod|sf-test|browser evidence|user story|verification|manual|bug" skills/sf-build/SKILL.md`
  - Notes: Use `sf-browser` for generic non-auth browser evidence, `sf-auth-debug` for auth/session evidence, `sf-prod` for deployment/runtime evidence, and `sf-test` for durable manual QA, retests, or behavior not proven by automated checks.

- [ ] Task 8: Integrate `sf-end` and `sf-ship`
  - File: `skills/sf-build/SKILL.md`
  - Action: Add closure through `sf-end`, then ship through `sf-ship`, with validation gates, bug gate, secret check, bounded staging scope, quick/full choice, and explicit risk confirmation when proof is incomplete.
  - User story link: Completes the promised path through closure and push without extra manual commands.
  - Depends on: Task 7
  - Validate with: `rg -n "sf-end|sf-ship|staging|commit|push|bug gate|secret|full|all-dirty" skills/sf-build/SKILL.md`
  - Notes: Do not use `all-dirty`, `ship-all`, or equivalent without explicit request.

- [ ] Task 9: Update chantier tracking doctrine for `sf-build`
  - File: `skills/references/chantier-tracking.md`
  - Action: Add `sf-build` to the matrix as `Trace category: obligatoire` and `Process role: lifecycle`, with its user-facing orchestrator role.
  - User story link: Keeps the new flow visible in the chantier registry.
  - Depends on: Task 1
  - Validate with: `rg -n "sf-build.*obligatoire|sf-build.*lifecycle|orchestrator" skills/references/chantier-tracking.md`
  - Notes: Do not break existing classifications.

- [ ] Task 10: Update help and workflow docs
  - File: `skills/sf-help/SKILL.md`, `shipflow-spec-driven-workflow.md`, `README.md`
  - Action: Document `sf-build` as the recommended end-user entrypoint, explain that invocation authorizes bounded sequential delegation for the current chantier, explain that parallelism requires ready `Execution Batches`, and preserve atomic skills as expert/manual-recovery mode.
  - User story link: Makes the new model discoverable without exposing all internal plumbing.
  - Depends on: Tasks 1-9
  - Validate with: `rg -n "sf-build|end-user|user-facing|delegated sequential|Execution Batches|spec-gated|subagent|sf-spec -> sf-ready|sf-end|sf-ship" skills/sf-help/SKILL.md shipflow-spec-driven-workflow.md README.md`
  - Notes: Public text must say `sf-build` asks useful questions, not that it acts without control.

- [ ] Task 11: Add local task tracking without premature changelog
  - File: `TASKS.md`
  - Action: Add or update local tracking during `sf-start` if the chantier is not already visible; do not modify `CHANGELOG.md`.
  - User story link: Keeps work visible without overclaiming delivery.
  - Depends on: Tasks 1-10
  - Validate with: `rg -n "sf-build|Autonomous Master Skill" TASKS.md`
  - Notes: `CHANGELOG.md` is updated only by `sf-end` after implementation and verification.

- [ ] Task 12: Validate final coherence
  - File: `specs/sf-build-autonomous-master-skill.md`, `skills/sf-build/SKILL.md`, `skills/references/subagent-roles/technical-reader.md`, `skills/references/subagent-roles/editorial-reader.md`, `skills/references/subagent-roles/sequential-executor.md`, `skills/references/subagent-roles/wave-executor.md`, `skills/references/subagent-roles/integrator.md`, `skills/sf-help/SKILL.md`, `skills/references/chantier-tracking.md`, `shipflow-spec-driven-workflow.md`, `README.md`
  - Action: Review the instructions as a fresh agent, verify gates are testable, verify language doctrine is respected, then rerun `/sf-ready sf-build Autonomous Master Skill`.
  - User story link: Proves the workflow can be implemented without chat history.
  - Depends on: Tasks 1-11
  - Validate with: `rg -n "invocation.*sf-build|Execution Modes|delegated sequential|Spec-Gated Parallelism|Execution Batches|Governance Corpus Gate|docs/technical|docs/editorial|technical-docs-corpus|editorial-content-corpus|CONTENT_MAP|Documentation Update Gate|Editorial Update Gate|pending final integration|pending final copy|Model Routing Gate|sf-model|Browser Evidence Routing|sf-browser|sf-auth-debug|sf-prod|sf-test|Question Gate|plain-text|sf-end|sf-ship|all-dirty|fresh-docs" skills/sf-build/SKILL.md specs/sf-build-autonomous-master-skill.md && rg -n "Technical Reader Agent Contract|Editorial Reader Agent Contract|Sequential Executor Contract|Wave Executor Contract|Integrator Contract" skills/references/subagent-roles && test ! -e skills/references/subagent-roles/reader.md`
  - Notes: If readiness still fails on a contract point, correct the spec before implementation.

## Acceptance Criteria

- [ ] AC 1: Given a user runs `/sf-build "je veux X"` with a non-trivial request, when the request enters the workflow, then `sf-build` creates or attaches a spec, loops readiness, and starts implementation only after readiness passes.
- [ ] AC 1b: Given an active spec already covers the same user story, expected result, linked systems, or affected surfaces, when `sf-build` receives a continuation request, then it updates or attaches that spec instead of creating a duplicate chantier.
- [ ] AC 1c: Given multiple active specs are plausible matches, when `sf-build` cannot choose safely, then it asks the user to select the chantier instead of guessing.
- [ ] AC 2: Given the user runs `/sf-build "je veux X"`, when the chantier involves file reading, editing, validation, or ship, then `sf-build` treats the invocation as bounded delegation consent and does not ask again before each sequential subagent.
- [ ] AC 3: Given the runtime supports subagents, when `sf-build` orchestrates non-trivial work, then it launches one bounded subagent at a time with clear ownership, integrates or validates the output, and only then launches the next subagent.
- [ ] AC 3b: Given a ready spec contains `Execution Batches` with exclusive files/surfaces, dependencies, and per-batch validations, when `sf-build` reaches a parallel batch, then it may launch the batch agents concurrently and must integrate results before the next batch.
- [ ] AC 3c: Given the ready spec lacks `Execution Batches` or write sets overlap, when `sf-build` considers parallelism, then it blocks parallelism and routes to spec update or readiness review.
- [ ] AC 3d: Given a fresh agent must fulfill an internal role, when `sf-build` launches or reuses that role, then it loads the dedicated reference file (`technical-reader`, `editorial-reader`, `sequential-executor`, `wave-executor`, or `integrator`) and does not expect a `reader.md` alias.
- [ ] AC 3e: Given an executor changes or plans to change code in a separate workspace/zspace, when the master prepares integration or closure, then the Technical Reader loads `skills/references/technical-docs-corpus.md` plus project-local `docs/technical/code-docs-map.md` and provides a `Documentation Update Plan` naming technical docs to align or justifying no technical docs impact.
- [ ] AC 3f: Given a parallel wave or large sequential block changes code, when `sf-build` wants to proceed to the next wave or `sf-end`, then impacted technical docs are applied by a write-capable executor and reviewed by the Technical Reader, or every remaining item is marked `pending final integration` with reason and resolution condition.
- [ ] AC 3g: Given a parallel wave or large sequential block changes visible behavior, copy, public page, public docs, or a claim, when `sf-build` wants closure or ship, then the Editorial Reader loads `skills/references/editorial-content-corpus.md`, `CONTENT_MAP.md`, and project-local `docs/editorial/`, then provides an `Editorial Update Plan` and, when relevant, a `Claim Impact Plan`; updates are applied and reviewed, or every remaining item is marked `pending final copy` with reason and resolution condition.
- [ ] AC 3h: Given a project-local technical corpus is missing or stale, when `sf-build` prepares implementation, then the Governance Corpus Gate routes to `/sf-docs technical`, records explicit no technical impact/non-coverage, or blocks before `sf-start`.
- [ ] AC 3i: Given public/content surfaces are relevant but editorial governance is missing or stale, when `sf-build` prepares implementation, closure, or ship, then the Governance Corpus Gate routes to `/sf-docs editorial`, records explicit no editorial impact/no-surface status, or blocks.
- [ ] AC 4: Given the runtime cannot spawn subagents or the user refuses them, when `sf-build` detects the limitation, then it asks whether to proceed single-agent, split the chantier, or stop.
- [ ] AC 4b: Given the chantier is long, high-risk, parallel, multi-domain, ambiguous, token-costly, or high-cost-of-error, when `sf-build` has a ready spec and is about to run `sf-start`, then it runs or applies `sf-model` before implementation.
- [ ] AC 4c: Given the chantier is small, clear, and local, when `sf-build` evaluates the model gate, then it may record that `sf-model` is not needed and continue with the current model.
- [ ] AC 5: Given a product, design, scope, data, security, existing-behavior, staging, or ship decision remains ambiguous, when `sf-build` reaches that point, then it asks a user-facing question with prepared options instead of inventing the answer.
- [ ] AC 5a: Given `sf-build` needs a material Plan Mode decision, when it asks the user, then the prompt includes the root problem, business stakes, 2-3 practical options, the recommended best-practice answer, and one precise decision request written for a business owner rather than a technical operator.
- [ ] AC 5b: Given the user interacts in French, when `sf-build` asks a question, gives status, or reports final results, then user-facing text is natural accented French while internal skill instructions remain English.
- [ ] AC 6: Given integrated question tooling is unavailable, when a material decision is required, then `sf-build` asks a short plain-text question with options and waits for the answer.
- [ ] AC 7: Given `sf-ready` returns `not ready`, when gaps are repairable without a user decision, then `sf-build` runs a spec correction pass and another readiness review within the iteration limit.
- [ ] AC 8: Given `sf-verify` or `sf-test` fails the user story, when `sf-build` considers closure, then it blocks full `sf-end` and `sf-ship` unless the user explicitly accepts risk.
- [ ] AC 8b: Given a change needs browser evidence for a non-auth URL, route, preview, or production page, when `sf-build` chooses the proof path, then it calls or delegates to `sf-browser` and records the evidence route.
- [ ] AC 8c: Given a change touches auth, sessions, cookies, callbacks, organizations, tenants, protected routes, or permission failures, when `sf-build` chooses the proof path, then it calls or delegates to `sf-auth-debug` instead of generic browser verification.
- [ ] AC 8d: Given proof depends on hosted deployment status, runtime logs, production health, serverless functions, edge functions, or live deployment behavior, when `sf-build` chooses the proof path, then it calls or delegates to `sf-prod` before treating browser/manual checks as sufficient.
- [ ] AC 8e: Given proof requires durable manual QA, retests, or structured manual scenario logs, when `sf-build` chooses the proof path, then it calls or delegates to `sf-test` and keeps `sf-browser` evidence as supporting proof when relevant.
- [ ] AC 9: Given dirty files outside scope exist, when `sf-build` reaches ship, then it asks for or bounds staging scope and does not ship everything by default.
- [ ] AC 10: Given the user did not explicitly request `all-dirty` or equivalent, when `sf-build` calls `sf-ship`, then it passes a staging scope limited to the current chantier.
- [ ] AC 11: Given implementation and verification are complete, when `sf-build` finishes, then it runs `sf-end`, then `sf-ship`, and the final report stays short with result, validations, execution mode, commit/push, excluded files, and proof limits.
- [ ] AC 12: Given a user reads the chantier spec, when they inspect `Skill Run History` and `Current Chantier Flow`, then they see the `sf-build` run and the main internal phases.
- [ ] AC 13: Given a fresh agent reads `skills/sf-build/SKILL.md`, when it executes the skill, then it understands gates, questions, default sequential delegation, spec-gated parallelism, stop conditions, scope limits, docs/content update gates, and validation expectations without reading chat history.

## Test Strategy

- Unit: None, because ShipFlow skills are markdown instruction artifacts without an executable unit harness today.
- Static checks: run `rg` validations for `sf-build`, `Trace category`, `Process role`, `Question Gate`, `Execution Modes`, `delegated sequential`, `Spec-Gated Parallelism`, `Execution Batches`, `Governance Corpus Gate`, `docs/technical`, `docs/editorial`, `technical-docs-corpus`, `editorial-content-corpus`, `CONTENT_MAP`, `Documentation Update Gate`, `Editorial Update Gate`, `pending final integration`, `pending final copy`, `Model Routing Gate`, `sf-model`, `Browser Evidence Routing`, `sf-browser`, `sf-auth-debug`, `sf-prod`, `sf-test`, invocation-as-delegation-consent, `plain-text`, `sf-end`, `sf-ship`, `all-dirty`, `fresh-docs`, and `Current Chantier Flow` across modified skill/docs.
- Role reference checks: verify each role file exists and contains its exact contract heading: `Technical Reader Agent Contract`, `Editorial Reader Agent Contract`, `Sequential Executor Contract`, `Wave Executor Contract`, and `Integrator Contract`; verify the technical reader includes `technical documentation corpus`, `technical-docs-corpus`, `docs/technical/code-docs-map.md`, `code-docs`, and `Documentation Update Plan`; verify the editorial reader includes `editorial corpus`, `editorial-content-corpus`, `CONTENT_MAP.md`, `docs/editorial/`, `public surfaces`, `Editorial Update Plan`, and `Claim Impact Plan`.
- Language doctrine checks: verify internal contracts, workflow rules, acceptance criteria, stop conditions, and validation notes are English; verify user-facing French examples are accented and clearly labeled as examples.
- Integration checks: run metadata/readiness checks on the new skill and docs with `rg`, then run `/sf-ready sf-build Autonomous Master Skill`.
- Manual scenario 1: simulate a vague story; verify no final spec or implementation starts before actor, result, scope, and exclusions are stable.
- Manual scenario 1b: simulate a request extending `sf-build Autonomous Master Skill`; verify `sf-build` continues the existing spec.
- Manual scenario 1c: simulate two plausible specs; verify `sf-build` asks which chantier to continue.
- Manual scenario 1d: simulate a code project without `docs/technical/code-docs-map.md`; verify `sf-build` routes to `/sf-docs technical` or blocks before `sf-start`.
- Manual scenario 1e: simulate a public/content project without `docs/editorial/`; verify `sf-build` routes to `/sf-docs editorial`, or records `no editorial impact` only when the request has no public/content consequence.
- Manual scenario 2: simulate `/sf-build "build X"`; verify invocation is treated as bounded delegation consent and sequential subagents do not require repeated consent.
- Manual scenario 2b: simulate a large parallel chantier with ready `Execution Batches`; verify `sf-model` is applied before `sf-start`, only non-overlapping agents launch in a batch, and model/execution decisions are recorded.
- Manual scenario 2c: simulate a large chantier without `Execution Batches`; verify `sf-build` does not parallelize and routes to `sf-spec`/`sf-ready`.
- Manual scenario 3: simulate unavailable integrated prompt tooling; verify the plain-text fallback question is used and action pauses.
- Manual scenario 4: simulate ready spec implementation; verify each sequential subagent has disjoint ownership and no concurrent writes occur without a batch.
- Manual scenario 4b: simulate code edits in separate workspaces/zspaces; verify the Technical Reader identifies impacted technical docs, a write-capable executor applies updates, the Technical Reader reviews them, and the next wave is blocked unless docs are updated or marked `pending final integration`.
- Manual scenario 4c: simulate visible behavior or claim edits; verify the Editorial Reader identifies public surfaces and claims, a write-capable executor applies updates before closure/ship, the Editorial Reader reviews them, and closure is blocked unless content is updated, no-impact is justified, or items are marked `pending final copy`.
- Manual scenario 4d: simulate a non-auth browser regression on a public route; verify `sf-build` routes evidence to `sf-browser` and does not replace it with `sf-test`, `sf-auth-debug`, or `sf-prod`.
- Manual scenario 4e: simulate an auth/session/callback/protected-route failure; verify `sf-build` routes evidence to `sf-auth-debug` before generic browser verification.
- Manual scenario 4f: simulate proof that depends on Vercel deployment status, runtime logs, edge/serverless behavior, or live health; verify `sf-build` routes to `sf-prod`.
- Manual scenario 4g: simulate a repeated manual QA/retest requirement; verify `sf-build` routes to `sf-test` and treats `sf-browser` output only as supporting evidence.
- Manual scenario 5: simulate failed verification; verify no full `sf-end` or `sf-ship` happens without explicit risk acceptance.
- Regression check: inspect `skills/sf-spec/SKILL.md`, `skills/sf-ready/SKILL.md`, `skills/sf-start/SKILL.md`, `skills/sf-verify/SKILL.md`, `skills/sf-browser/SKILL.md`, `skills/sf-auth-debug/SKILL.md`, `skills/sf-prod/SKILL.md`, `skills/sf-test/SKILL.md`, `skills/sf-end/SKILL.md`, and `skills/sf-ship/SKILL.md` to ensure `sf-build` orchestrates rather than contradicts them.

## Risks

- Security impact: yes, mitigated by bounded subagent scope, permissions gates, data exposure gates, secrets checks, destructive-action questions, dirty-state checks, verification, bug-risk review, staging control, and ship confirmation.
- Runtime scope risk: high if `sf-build` treats invocation consent as permission to act outside the chantier; mitigated by bounded missions, ownership, stop conditions, and separate questions for destructive, sensitive, out-of-scope, staging, or ship-risk decisions.
- Edit conflict risk: high if `sf-build` launches parallel agents opportunistically; mitigated by sequential default, ready `Execution Batches`, non-overlapping write sets, dependency ordering, and master/integrator review between waves.
- Product risk: high if `sf-build` hides too much; mitigated by asking more useful product questions while hiding only internal technical detail.
- Regression risk: high because a master skill can overstep; mitigated by scoped ownership, readiness gates, verification gates, docs/content gates, and no `all-dirty` ship by default.
- Operational risk: medium if the runtime cannot spawn subagents or surface approvals; mitigated by explicit degradation prompt, single-agent fallback only with consent, or clean stop.
- Prompt/tooling risk: medium if integrated prompt tooling is unavailable; mitigated by plain-text fallback and stop-before-dangerous-action rule.
- Documentation risk: medium if docs advertise only the atomic flow or overpromise autonomy; mitigated by updating help, workflow docs, and README with invocation-consent and question model.
- Technical docs drift risk: medium if code changes happen in isolated workspaces/zspaces and no role maps them back to documentation; mitigated by Technical Reader code-docs mapping and `Documentation Update Plan`.
- Editorial drift risk: medium if behavior changes ship while public pages, README, FAQ, skill pages, pricing, support copy, or claims still describe old behavior; mitigated by Editorial Reader public-surface mapping, `Editorial Update Plan`, and `Claim Impact Plan`.
- Fresh docs risk: low after official Codex docs check, but `sf-start` must rerun freshness if implementation uses a concrete new Codex API, config file, plugin schema, or MCP integration beyond markdown instructions.

## Execution Notes

- Read first: `skills/sf-init/SKILL.md`, `skills/sf-docs/SKILL.md`, `skills/sf-spec/SKILL.md`, `skills/sf-ready/SKILL.md`, `skills/sf-start/SKILL.md`, `skills/sf-verify/SKILL.md`, `skills/sf-browser/SKILL.md`, `skills/sf-auth-debug/SKILL.md`, `skills/sf-prod/SKILL.md`, `skills/sf-test/SKILL.md`, `skills/sf-end/SKILL.md`, `skills/sf-ship/SKILL.md`, `skills/references/chantier-tracking.md`, `skills/references/technical-docs-corpus.md`, `skills/references/editorial-content-corpus.md`, `shipflow-spec-driven-workflow.md`, `GUIDELINES.md`.
- External docs checked for this spec on 2026-05-02: `https://developers.openai.com/codex/subagents`, `https://developers.openai.com/codex/cli/features#subagents`, `https://developers.openai.com/codex/agent-approvals-security#sandbox-and-approvals`, `https://developers.openai.com/codex/agent-approvals-security#network-access-`, `https://developers.openai.com/codex/config-reference#configtoml`.
- Implement in this order: create `sf-build`; add question gate and language-aware fallback; add execution modes; create role files; add `Execution Batches` rules and no-opportunistic-parallelism stop condition; add spec/readiness loop; add Existing Chantier Check; add anti-regression gates; add Governance Corpus Gate; add model routing gate; add implementation/verify/browser-evidence/test orchestration; add end/ship integration; update chantier doctrine; update help/workflow/README; update `TASKS.md`; run readiness.
- Packages to avoid: no new runtime package or SDK unless `sf-start` proves necessity and reruns the freshness gate.
- Patterns to follow: existing skill frontmatter, canonical paths section, chantier tracking block, exact `Trace category` / `Process role` wording, standard `Chantier` final block, internal English contract language, and concise user-facing reports in the active user language.
- Abstractions to avoid: do not build a second task registry, do not duplicate all checks from lifecycle skills, do not create a hidden state machine outside markdown skill instructions, and do not create a `reader.md` alias.
- Commands to validate: `rg -n "sf-build" skills/sf-build/SKILL.md skills/sf-help/SKILL.md skills/references/chantier-tracking.md shipflow-spec-driven-workflow.md README.md`; `rg -n "Existing Chantier Check|Execution Modes|delegated sequential|Spec-Gated Parallelism|Execution Batches|Governance Corpus Gate|docs/technical|docs/editorial|technical-docs-corpus|editorial-content-corpus|CONTENT_MAP|Documentation Update Gate|Editorial Update Gate|pending final integration|pending final copy|invocation.*sf-build|Model Routing Gate|sf-model|Browser Evidence Routing|sf-browser|sf-auth-debug|sf-prod|sf-test|Question Gate|plain-text|sf-end|sf-ship|all-dirty|fresh-docs" skills/sf-build/SKILL.md`; `rg -n "Technical Reader Agent Contract|technical documentation corpus|technical-docs-corpus|docs/technical/code-docs-map|code-docs|Documentation Update Plan|Editorial Reader Agent Contract|editorial corpus|editorial-content-corpus|CONTENT_MAP|docs/editorial|Editorial Update Plan|Claim Impact Plan|Sequential Executor Contract|Wave Executor Contract|Integrator Contract" skills/references/subagent-roles`; `test ! -e skills/references/subagent-roles/reader.md`; `/sf-ready sf-build Autonomous Master Skill`.
- Stop conditions: no unique interpretation of ship behavior, disagreement with lifecycle skill contracts, missing decision about touching existing behavior, missing governance corpus status before implementation, missing `Execution Batches` for requested parallelism, overlapping ownership, inability to preserve user changes in a dirty worktree, failed verification gate, docs/content contract contradiction, stale or mismatched dependency metadata, language doctrine violation in internal contracts, browser evidence routed to the wrong official skill, or public docs that imply autonomy without user decision gates.
- Implementation boundary: do not alter existing lifecycle skill behavior unless required for discoverability, matrix registration, or explicitly listed documentation compatibility; `sf-build` should compose them first.

## Open Questions

None

Readiness note: ready after full reconciliation. The behavior contract, language doctrine, security gates, task order, governance corpus requirements, and browser evidence routing are coherent. The 2026-05-02 dependency metadata drift reported by sf-ready has been corrected: this spec now records `README.md` 0.5.0 and `shipflow-spec-driven-workflow.md` 0.8.0, consumes the shipped `sf-init`/`sf-docs` governance corpus lifecycle, and incorporates the `sf-browser` routing introduced by the active README/workflow docs.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-04-29 09:02:11 UTC | sf-spec | GPT-5 Codex | Created spec for sf-build autonomous master skill | draft | /sf-ready sf-build autonomous master skill |
| 2026-04-29 10:16:26 UTC | sf-ready | GPT-5 Codex | Reviewed readiness; blocked on runtime authorization semantics for default subagents, integrated question fallback, and freshness evidence | not ready | /sf-spec sf-build Autonomous Master Skill |
| 2026-04-29 16:12:58 UTC | sf-spec | GPT-5 Codex | Revised spec to resolve readiness gaps around subagent consent, prompt fallback, fresh Codex docs, ship staging, and changelog timing | draft | /sf-ready sf-build Autonomous Master Skill |
| 2026-04-29 16:19:01 UTC | sf-ready | GPT-5 Codex | Validated revised spec structure, user story alignment, runtime consent semantics, security gates, fresh Codex docs, task ordering, and acceptance criteria | ready | /sf-start sf-build Autonomous Master Skill |
| 2026-04-29 16:32:00 UTC | sf-docs | GPT-5 Codex | Added ShipFlow language doctrine dependency and sf-build language requirements | draft | /sf-ready sf-build Autonomous Master Skill |
| 2026-04-30 20:48:38 UTC | sf-spec | GPT-5 Codex | Revised subagent consent contract so invoking sf-build authorizes bounded subagents for the current chantier without repeated prompts | draft | /sf-ready sf-build Autonomous Master Skill |
| 2026-04-30 20:51:41 UTC | sf-spec | GPT-5 Codex | Added sf-model gate before sf-start for large, high-risk, multi-agent, ambiguous, or token-costly chantiers | draft | /sf-ready sf-build Autonomous Master Skill |
| 2026-04-30 22:18:43 UTC | sf-spec | GPT-5 Codex | Added Existing Chantier Check so sf-build continues matching active specs before creating a new chantier | draft | /sf-ready sf-build Autonomous Master Skill |
| 2026-04-30 22:23:59 UTC | sf-spec | GPT-5 Codex | Revised execution doctrine to delegated sequential by default and spec-gated parallelism only through non-overlapping Execution Batches | draft | /sf-ready sf-build Autonomous Master Skill |
| 2026-05-01 08:43:00 UTC | sf-spec | GPT-5 Codex | Added one-reference-file-per-role doctrine for reader, sequential executor, wave executor, and integrator contracts | draft | /sf-ready sf-build Autonomous Master Skill |
| 2026-05-01 08:48:42 UTC | sf-spec | GPT-5 Codex | Added Technical Reader corpus responsibility for code-docs mapping and technical Documentation Update Plan across execution workspaces | draft | /sf-ready sf-build Autonomous Master Skill |
| 2026-05-01 08:54:18 UTC | sf-spec | GPT-5 Codex | Added Documentation Update Gate at cycle/wave end with pending final integration exception | draft | /sf-ready sf-build Autonomous Master Skill |
| 2026-05-01 14:37:51 UTC | sf-spec | GPT-5 Codex | Split the generic Reader role into explicit Technical Reader and Editorial Reader role files, removed the planned reader.md alias, and preserved existing Reader responsibilities across technical and editorial plans | draft | /sf-ready sf-build Autonomous Master Skill |
| 2026-05-01 17:57:02 UTC | sf-ready | GPT-5 Codex | Reviewed readiness after Technical Reader / Editorial Reader split and gate updates; blocked on dependency metadata alignment and ShipFlow language doctrine for internal contracts | not ready | /sf-spec sf-build Autonomous Master Skill |
| 2026-05-01 18:11:46 UTC | sf-spec | GPT-5 Codex | Resolved readiness blockers by aligning dependency metadata, rewriting internal contract sections in English, preserving accented French user-facing examples, and refreshing official Codex docs evidence | draft | /sf-ready sf-build Autonomous Master Skill |
| 2026-05-01 18:18:07 UTC | sf-ready | GPT-5 Codex | Validated dependency metadata, language doctrine, behavior contract, task order, documentation gates, adversarial risks, security gates, and official Codex docs freshness | ready | /sf-start sf-build Autonomous Master Skill |
| 2026-05-02 10:38:37 UTC | sf-ready | GPT-5 Codex | Revalidated readiness after governance corpus doc updates; blocked on dependency metadata drift for README.md and shipflow-spec-driven-workflow.md | not ready | /sf-spec sf-build Autonomous Master Skill |
| 2026-05-02 10:43:55 UTC | sf-spec | GPT-5 Codex | Refreshed dependency metadata for README.md 0.5.0 and shipflow-spec-driven-workflow.md 0.8.0 after the readiness gate reported stale depends_on entries. | reviewed | /sf-ready sf-build Autonomous Master Skill |
| 2026-05-02 10:47:34 UTC | sf-spec | GPT-5 Codex | Reconciled the material behavior changes in README.md 0.5.0 and shipflow-spec-driven-workflow.md 0.8.0 by adding sf-browser routing, sf-init/sf-docs corpus ownership, and explicit browser/manual evidence gates. | reviewed | /sf-ready sf-build Autonomous Master Skill |
| 2026-05-02 10:52:35 UTC | sf-ready | GPT-5 Codex | Validated structure, metadata, user-story fit, task order, docs/governance coherence, browser evidence routing, language doctrine, adversarial risks, and security gates after reconciliation. | ready | /sf-start sf-build Autonomous Master Skill |
| 2026-05-02 11:01:15 UTC | sf-ready | GPT-5 Codex | Revalidated structure, metadata/dependency versions, user-story fit, task order, governance/browser evidence gates, language doctrine, adversarial/security risks, and official OpenAI Codex docs freshness. | ready | /sf-start sf-build Autonomous Master Skill |
| 2026-05-02 14:20:51 UTC | sf-start | GPT-5 Codex | Implemented the sf-build master skill, created missing subagent role contracts, updated chantier-tracking doctrine, and aligned sf-help/workflow/README discoverability plus task tracking. | implemented | /sf-verify sf-build Autonomous Master Skill |
| 2026-05-02 14:27:27 UTC | sf-verify | GPT-5 Codex | Verified sf-build implementation against the ready spec, checked static contract coverage, metadata, role files, chantier doctrine, docs/workflow alignment, bug gate, risk scan, and official Codex subagent docs freshness. | verified | /sf-end sf-build Autonomous Master Skill |
| 2026-05-02 14:29:15 UTC | sf-end | GPT-5 Codex | Closed the sf-build chantier after verification, updated local and master task trackers, prepared changelog entries, and left shipping to sf-ship. | closed | /sf-ship sf-build Autonomous Master Skill |
| 2026-05-02 14:33:49 UTC | sf-ship | GPT-5 Codex | Quick-shipped the sf-build master skill and related role contracts, workflow/help/README/changelog updates, and chantier trace after lightweight validation. | shipped | None |
| 2026-05-04 04:58:00 UTC | sf-build | GPT-5 Codex | Extended the existing sf-build chantier with business-context decision question framing for Plan Mode. | implemented | /sf-verify sf-build decision question framing |
| 2026-05-04 04:58:00 UTC | sf-verify | GPT-5 Codex | Verified the question framing contract against sf-build, workflow doctrine, technical lifecycle docs, and user language doctrine. | verified | /sf-end sf-build decision question framing |
| 2026-05-04 04:58:00 UTC | sf-end | GPT-5 Codex | Updated tracker and changelog bookkeeping for sf-build decision question framing. | closed | /sf-ship "Add business-context sf-build questions" |
| 2026-05-04 04:58:00 UTC | sf-ship | GPT-5 Codex | Ran scoped checks, committed, and pushed the sf-build decision question framing update. | shipped | None |

## Current Chantier Flow

- `sf-spec`: done; dependency metadata refreshed against current README.md 0.7.1 and shipflow-spec-driven-workflow.md 0.12.0, governance corpus ownership aligned to `sf-init`/`sf-docs`, browser evidence routing aligned to `sf-browser`, `sf-auth-debug`, `sf-prod`, and `sf-test`, and decision questions reframed for business operators.
- `sf-ready`: ready after full reconciliation and 2026-05-02 revalidation of dependency metadata, governance/browser evidence gates, language doctrine, adversarial/security risks, and official OpenAI Codex docs freshness.
- `sf-start`: implemented; created `skills/sf-build/SKILL.md`, added role contracts, aligned workflow/help/docs, and later added business-context decision framing for Plan Mode questions.
- `sf-verify`: verified; static contract checks, metadata lint, role contract checks, skill budget audit, bug gate review, risk scan, and focused question-framing checks passed for the implemented skill/docs scope.
- `sf-end`: closed; task trackers and changelog prepared after verification.
- `sf-ship`: shipped; quick ship after lightweight validation and bounded staging, then reshipped the Plan Mode decision-framing refinement.

Next step: None
