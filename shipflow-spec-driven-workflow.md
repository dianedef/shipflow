---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "0.17.0"
project: ShipFlow
created: "2026-04-22"
updated: "2026-05-11"
status: draft
source_skill: sf-docs
scope: spec-driven-workflow
owner: unknown
confidence: medium
risk_level: medium
security_impact: unknown
docs_impact: yes
linked_systems:
  - skills/
  - skills/shipflow/SKILL.md
  - skills/sf-deploy/SKILL.md
  - skills/sf-maintain/SKILL.md
  - skills/sf-content/SKILL.md
  - skills/sf-design/SKILL.md
  - skills/sf-browser/SKILL.md
  - skills/sf-bug/SKILL.md
  - skills/references/entrypoint-routing.md
  - templates/artifacts/
  - tools/shipflow_metadata_lint.py
  - skills/references/canonical-paths.md
  - shipflow_data/technical/
  - shipflow_data/editorial/
  - skills/references/editorial-content-corpus.md
  - skills/references/reporting-contract.md
  - skills/references/master-workflow-lifecycle.md
  - skills/references/question-contract.md
depends_on: []
supersedes: []
evidence:
  - "Document title and body define ShipFlow V3 workflow doctrine and artifact metadata rules"
  - "Updated on 2026-04-26 to clarify the documentation frame, context layer, metadata doctrine, and artifact boundaries"
  - "Updated on 2026-04-26 to add the content architecture and repurposing artifact"
  - "Updated on 2026-04-27 to define canonical ShipFlow path resolution for tools and references"
  - "Updated on 2026-04-29 to formalize the ShipFlow language doctrine: English internal contracts, user-facing interaction in the user's active language."
  - "Updated on 2026-05-01 to add the internal technical documentation layer and Documentation Update Plan gate."
  - "Updated on 2026-05-01 to add editorial content governance, public claim safety, Astro runtime-content schema boundaries, and the Editorial Update Gate."
  - "Updated on 2026-05-02 to define the governance corpus lifecycle: sf-init bootstraps, sf-docs maintains, sf-build consumes."
  - "Updated on 2026-05-02 to add sf-browser as the generic non-auth browser evidence path."
  - "Updated on 2026-05-03 to add sf-deploy as the release confidence orchestrator."
  - "Updated on 2026-05-03 to add sf-maintain as the recurring project maintenance orchestrator."
  - "Updated on 2026-05-03 to add shared report modes: concise user reports by default and explicit detailed agent handoff reports."
  - "Updated on 2026-05-04 to clarify user-mode report polish: active-language labels, outcome/evidence/limits ordering, and sober status emojis."
  - "Updated on 2026-05-04 to require business-context decision questions for sf-build planning."
  - "Updated on 2026-05-04 to add a skill launch cheatsheet for master and supporting modes."
  - "Updated on 2026-05-04 to route fuzzy skill-maintenance ideas through sf-explore before sf-spec."
  - "Updated on 2026-05-04 to add sf-content as the master content lifecycle entrypoint."
  - "Updated on 2026-05-04 to clarify sf-build delegated sequential subagent consent and separate subagents from parallelism."
  - "Updated on 2026-05-04 to extract shared master delegation semantics to skills/references/master-delegation-semantics.md."
  - "Updated on 2026-05-04 to extract the shared master workflow lifecycle and clarify that bugs/*.md files are bug source of truth while BUGS.md is optional/generated triage."
  - "Updated on 2026-05-04 to document shipflow <instruction> as the primary non-technical router with direct main-thread handoff to selected skills."
  - "Updated on 2026-05-05 to document shared question/default doctrine across skills."
  - "Updated on 2026-05-06 to add sf-design as the master design lifecycle entrypoint."
  - "Updated on 2026-05-08 to clarify sf-bug as a bug lifecycle executor that continues through owner skills and bounded subagents when safe."
  - "Updated on 2026-05-11 to add competitive intelligence and affiliate program registries as project-local business artifacts."
  - "Updated on 2026-05-11 to make project governance artifacts canonical under shipflow_data/, including workflow specs."
next_review: "unknown"
next_step: "/sf-docs audit shipflow-spec-driven-workflow.md"
---

# ShipFlow V3: Spec-Driven Workflow

## Summary

ShipFlow V3 shifts iteration upstream.

The current documentation frame is already solid on three axes:

- technical: `CLAUDE.md`, `shipflow_data/technical/context.md`, `shipflow_data/technical/context-function-tree.md`, `shipflow_data/editorial/content-map.md`, `shipflow_data/technical/guidelines.md`, and `shipflow_data/workflow/specs/`
- workflow: `sf-spec`, `sf-ready`, `sf-start`, `sf-verify`, `sf-docs`, and versioned metadata
- product/business: `shipflow_data/business/business.md`, `shipflow_data/business/branding.md`, versioned docs, and `depends_on` relationships
- editorial coherence: `shipflow_data/editorial/content-map.md`, `shipflow_data/editorial/`, public content, claims, page intent, and Astro content schema policy

The recent progress is structural rather than cosmetic:

- a clear agent entrypoint
- a dedicated context layer
- a metadata and lint doctrine
- a public-content governance layer for claims, page intent, editorial gates, and runtime content schema boundaries
- a cleaner separation between active docs, trackers, and runtime content

Default operating stance:
- complete the context before execution
- make the contract implementable by a fresh agent
- avoid “prompt and correct” loops as the normal path
- treat late clarification as a bounded exception, not the workflow itself

Skill launch cheatsheet:

| Need | Launch | Useful modes |
| --- | --- | --- |
| Non-technical first command | `shipflow <instruction>` | Routes pure conversational answers directly; routes real work to the right master or specialist skill; asks one numbered question when ambiguous. |
| Non-trivial product, code, site, or docs work | `sf-build <story, bug, or goal>` | Plain task text is the story; use `report=agent`, `handoff`, `verbose`, or `full-report` only for detailed handoff evidence. |
| Recurring project upkeep | `sf-maintain [mode]` | `full`/no argument, `quick`, `security`, `deps`, `docs`, `audits`, `no-ship`, `global`. |
| Release confidence after implementation | `sf-deploy [target or mode]` | no argument, `skip-check`, `--preview`, `--prod`, `no-changelog`. |
| Bug-loop lifecycle | `sf-bug [BUG-ID, summary, or mode]` | no argument, `BUG-ID`, `--fix`, `--retest`, `--verify`, `--ship`, `--close`. |
| Content management | `sf-content [goal, source, file, or mode]` | `plan`, `repurpose`, `draft`, `enrich`, `audit`, `seo`, `editorial`, `apply`, `ship`. |
| Skill creation or maintenance | `sf-skill-build <idea or path>` | new skill idea, existing skill path, optional `sf-explore` for fuzzy placement, public page/docs/runtime validation gates. |
| Design lifecycle | `sf-design <design question or goal>` | Master design entrypoint for UI/UX, tokens, playgrounds, component/a11y audits, implementation, browser proof, verification, and ship routing. |
| Design system creation | `sf-design-from-scratch [target or mode]` | Build a complete professional token system from an existing UI; use `tokens-only` or `with-playground`. |
| Manual expert lifecycle | `sf-spec -> sf-ready -> sf-start -> sf-verify -> sf-end` | Use when you intentionally want to drive each gate instead of using `sf-build`. |
| Commit and push ready work | `sf-ship [mode]` | no special argument, `skip-check`, `end la tache`/`end`/`fin`/`close task`, `all-dirty`/`ship-all`/`tout-dirty`. |
| Browser, auth, manual QA, or live deployment proof | `sf-browser`, `sf-auth-debug`, `sf-test`, `sf-prod` | Pick by proof type: non-auth browser evidence, auth/session diagnosis, durable manual QA, or deployment truth. |

Bug loop entrypoint:

```text
sf-bug -> sf-test -> bug file -> sf-fix -> sf-test --retest -> sf-verify -> sf-ship
```

Use `sf-bug` when the operator wants one bug lifecycle executor for a new report, a `BUG-ID`, a retest, a closure question, or a ship-risk question. It continues through existing owner skills and bounded subagents when safe rather than mutating bug records or code in the master thread itself.

Bug repair entrypoint:

```text
sf-fix -> fix directly or route to spec-first path
```

General browser evidence entrypoint:

```text
sf-browser -> sf-fix / sf-test / sf-prod / sf-auth-debug / sf-verify
```

Use `sf-browser` for non-auth page-level browser proof: visible assertions, quick visual checks, accessibility snapshots, screenshots, console summaries, and network summaries.

Optional model-selection entrypoint before execution:

```text
sf-model -> choose model / reasoning / fallbacks before sf-start
```

Primary non-technical router entrypoint:

```text
shipflow <instruction> -> direct answer or direct handoff to selected skill
```

`shipflow <instruction>` is the recommended first command when the operator does not want to choose a skill. It answers pure conversational requests in the main thread. It hands non-trivial feature, code, and docs work to `sf-build`; maintenance to `sf-maintain`; bug-loop work to `sf-bug`; release, deploy, or production proof to `sf-deploy`; content work to `sf-content`; skill maintenance to `sf-skill-build`; and obvious specialist audits to `sf-audit-*`. Ambiguous requests get one numbered clarifying question with why, recommended answer, and practical options.

The router uses direct main-thread handoff to the selected skill. It does not run a master skill inside a subagent, and it does not duplicate the selected skill's lifecycle. Once selected, each master owns its own delegated sequential execution and proof gates.

Direct build entrypoint for non-trivial work:

```text
sf-build -> existing chantier check -> sf-spec/sf-ready loop -> sf-start -> sf-verify -> sf-end -> sf-ship
```

`sf-build` keeps the user conversation focused on decisions and status while following the shared master lifecycle reference in `skills/references/master-workflow-lifecycle.md` and the delegation reference in `skills/references/master-delegation-semantics.md`: delegated sequential is the default for file and validation work, short natural-language confirmations after diagnosis or proposal continue the current chantier with one bounded subagent by intent rather than exact keyword, and parallel execution is allowed only when a ready spec defines non-overlapping `Execution Batches`.

Recommended release entrypoint after implementation:

```text
sf-deploy -> sf-check -> sf-ship -> sf-prod -> sf-browser/sf-auth-debug/sf-test -> sf-verify -> sf-changelog
```

`sf-deploy` is the release confidence orchestrator. It does not replace `sf-ship`, `sf-prod`, or proof skills; it keeps their gates in order and prevents push/build/health status from being treated as complete release proof.

Recommended maintenance entrypoint for existing projects:

```text
sf-maintain -> triage -> sf-spec/sf-ready when needed -> delegated maintenance lanes -> sf-verify -> sf-deploy/sf-ship
```

`sf-maintain` is the master maintenance lifecycle. Its default mode executes maintenance as far as safely possible: bug risk, dependency risk, docs drift, checks, audits, migrations, tasks, and security posture flow through owner skills, bounded subagents, verification, and ship/deploy routing. Use `quick` when the operator only wants the old read-only triage.

Recommended entrypoint for ShipFlow skill maintenance:

```text
sf-skill-build -> sf-explore when needed -> sf-spec -> skill contract edit/create -> sf-skills-refresh -> skill budget audit -> sf-verify -> sf-docs/help update -> sf-ship
```

`sf-skill-build` is scoped to skill lifecycle work and enforces ambiguity reduction, public-surface, docs/help, and validation gates before ship routing. When the skill idea or placement is too fuzzy for one targeted question to settle, it routes to `sf-explore` before creating the durable `sf-spec` contract.

Recommended content lifecycle entrypoint:

```text
sf-content -> CONTENT_MAP + editorial corpus -> owner content skills -> audits/docs -> validation -> sf-verify -> sf-ship
```

`sf-content` is the master content-management orchestrator. It does not replace `sf-repurpose`, `sf-redact`, `sf-enrich`, `sf-audit-copy`, `sf-audit-copywriting`, `sf-audit-seo`, `sf-docs`, `sf-veille`, or `sf-market-study`; it chooses and sequences them while enforcing public-surface, claim, runtime schema, validation, and missing-surface gates.

For expert manual control, the default non-trivial flow remains:

```text
sf-explore -> exploration_report -> sf-spec -> sf-ready -> sf-start -> sf-verify -> sf-end
```

For small, explicit, local fixes, the fast path remains:

```text
sf-start -> sf-verify -> sf-end
```

The goal is not to remove iteration. The goal is to move ambiguity reduction before coding, then let verification close the loop when implementation or spec drift appears without turning the workflow into iterative prompt repair.

## Technical Documentation Layer

ShipFlow maintains an internal code-proximate technical documentation layer under `shipflow_data/technical/`.

- `shipflow_data/technical/README.md` indexes subsystem technical docs.
- `shipflow_data/technical/code-docs-map.md` maps code paths to primary technical docs, secondary docs, required validation, and docs update triggers.
- `templates/artifacts/technical_module_context.md` is the standard template for subsystem docs.
- `skills/references/technical-docs-corpus.md` tells skills how to load the layer without polluting context.

This layer does not replace `shipflow_data/technical/architecture.md`, `shipflow_data/technical/context.md`, `shipflow_data/technical/guidelines.md`, specs, or decision records. It gives agents the closest durable technical context for a code area.

### Documentation Update Gate

After every code-changing execution wave, the Reader must produce a `Documentation Update Plan` from `shipflow_data/technical/code-docs-map.md`. End verification must produce or re-check the plan again.

```markdown
## Documentation Update Plan

- Code changed: `path/or/pattern`
- Subsystem: `name`
- Primary technical doc: `shipflow_data/technical/example.md`
- Secondary docs: `...`
- Required action: `none | review | update | create`
- Priority: `low | medium | high`
- Reason: `why this doc is impacted`
- Owner role: `executor | integrator`
- Parallel-safe: `yes | no`
- Notes: `constraints or blockers`
```

The Reader diagnoses impact; an executor or integrator applies updates. A mapped code change must either update the impacted technical doc or record a no-impact justification. There is no stale-doc shipping exception for mapped technical docs.

Shared files are sequential integration files by default: `shipflow_data/technical/code-docs-map.md`, `AGENT.md`, `shipflow_data/technical/context.md`, `shipflow_data/technical/guidelines.md`, `shipflow-spec-driven-workflow.md`, and `tools/shipflow_metadata_lint.py`. Parallel documentation work is allowed only when a ready spec defines disjoint file ownership.

`AGENT.md` remains the canonical agent entrypoint. `AGENTS.md`, when present, is a compatibility symlink to `AGENT.md`, not a second maintained Markdown source. `shipflow_data/technical/` remains internal-only in v1 and must not be published to the public site.

## Editorial Content Governance Layer

ShipFlow maintains a public-content governance layer under `shipflow_data/editorial/`.

- `shipflow_data/editorial/content-map.md` remains the canonical content routing map.
- `shipflow_data/editorial/README.md` indexes public-content governance docs.
- `shipflow_data/editorial/public-surface-map.md` maps public pages, README, FAQ, docs overview, public skill pages, and future content surfaces.
- `shipflow_data/editorial/page-intent-map.md` records route intent, CTA, source contracts, and shared-file risk.
- `shipflow_data/editorial/claim-register.md` bounds public claims about security, privacy, compliance, AI reliability, automation, speed, savings, availability, pricing, and business outcomes.
- `shipflow_data/editorial/editorial-update-gate.md` defines the `Editorial Update Plan`, `Claim Impact Plan`, `no editorial impact`, and `pending final copy` statuses.
- `shipflow_data/editorial/astro-content-schema-policy.md` protects Astro content schema and runtime content boundaries.
- `shipflow_data/editorial/blog-and-article-surface-policy.md` requires agents to report `surface missing: blog` when no blog/article surface is declared.

When a wave changes visible behavior, public content, README guidance, public docs, FAQ, pricing, support copy, public skill promises, or claims, the Editorial Reader produces an `Editorial Update Plan`. Sensitive claims also get a `Claim Impact Plan`.

The Editorial Reader is read-only. It diagnoses public-content impact; an executor or integrator applies updates. Shared editorial files stay sequential unless a ready spec assigns exclusive write ownership.

## Governance Corpus Lifecycle

Future projects should not rerun ShipFlow's shipped technical or editorial governance specs as manual per-project chantiers. Those specs are source doctrine. The normal project workflow uses lightweight project-local corpora:

- `sf-init` bootstraps `shipflow_data/technical/`, `shipflow_data/technical/code-docs-map.md`, `shipflow_data/editorial/content-map.md`, and applicable `shipflow_data/editorial/` files, or reports `skipped`, `needs audit`, or `blocked` with a recovery command.
- `sf-docs` owns ongoing corpus creation, first-run bootstrap, update, and audit. Use `/sf-docs technical`, `/sf-docs editorial`, or `/sf-docs update` to adopt missing governance layers in existing projects.
- `sf-build` consumes the corpora through a Governance Corpus Gate before implementation and before closure/ship when public-content impact is relevant. Missing or stale corpus state routes to `sf-docs` or blocks instead of relying on chat memory.

Technical governance applies to code projects by default. Editorial governance applies when public pages, README promises, docs, FAQ, pricing, support copy, public skill pages, blog/article intent, claims, or runtime content surfaces exist. If a layer is not applicable, the workflow records the reason instead of silently skipping it.

## Core Principles

- `sf-explore` is for ambiguity reduction, not implementation.
- `sf-explore` may write an `exploration_report` durable artifact when exploration is substantial or explicitly requested, but it does not write chantier spec history.
- `sf-spec` produces an implementation contract, not loose notes.
- `sf-ready` enforces a real Definition of Ready before non-trivial execution.
- `shipflow <instruction>` is the primary non-technical router; it hands off directly in the main thread to the selected skill and asks one numbered question when the route is ambiguous.
- `sf-build` is the master orchestrator for end users and should prefer bounded delegated sequential execution over manual command chaining.
- Master/orchestrator skills must load `skills/references/master-workflow-lifecycle.md` for the shared skeleton: intake, work item resolution, readiness, model/topology routing, owner execution, validation, verification, post-verify closure, and ship/deploy routing.
- Master/orchestrator skills must load `skills/references/master-delegation-semantics.md` before choosing execution topology. The reference defines delegation, subagents, short approvals, degradation, and spec/batch-gated parallelism.
- User-facing questions follow `skills/references/question-contract.md`: ask only when the answer changes route, scope, risk, proof, closure, ship posture, public claims, or technical/product/editorial direction.
- `sf-build` planning questions should be decision briefs for business operators: explain the root problem, business stakes, practical options, and the best-practice recommendation before asking for the decision.
- `sf-maintain` is the master orchestrator for recurring project maintenance and should prefer bounded delegated sequential execution over command recommendations.
- `sf-content` is the master orchestrator for content management and should route to specialist content, docs, audit, research, validation, and ship skills rather than duplicating their internals.
- `sf-skill-build` is the master orchestrator for ShipFlow skill maintenance and should route fuzzy ideas through `sf-explore` before `sf-spec`, then keep skill contract, refresh, budget, docs/help, and public skill surfaces coherent.
- `sf-start` begins execution from a ready contract instead of rediscovering intent, and now decides both model routing and execution topology before coding.
- `sf-verify` checks against the spec first, then quality and risks, and can now remediate limited gaps.
- `sf-end` closes the task against the delivered scope, not only against the diff.
- agent handoffs should be one-pass: complete context up front, no hidden dependency on chat history, explicit linked systems and consequences.
- business, brand, and documentation artifacts are decision contracts, not passive notes.
- every reusable ShipFlow artifact should be traceable through metadata, evidence, status, risk, and next step.

## Report Modes

ShipFlow skills default to concise user-facing final reports. The default mode is `report=user`: outcome first, active user language for labels and explanations, compact check summary, compact chantier flow, no empty `Reste a faire` or `Prochaine etape`, and no redundant verdict lines when the heading already carries the result. Ship reports should read as outcome, evidence, then limits. A few sober status emojis are allowed when they improve scanning; do not decorate every line.

Detailed reports are explicit. Use `report=agent`, `handoff`, `verbose`, or `full-report` when an orchestrator or downstream agent needs file lists, validation matrices, evidence trails, phase details, or handoff context. Skills must not infer caller identity from runtime state; master skills pass a handoff flag when they need detailed downstream evidence.

Audit skills keep findings first. In user mode, they summarize top findings, proof gaps, chantier potential, and the next real action. Full audit matrices and domain checklist outputs belong in agent/handoff mode unless the user explicitly asks for the long report.

## Specs As Chantier Registry

`shipflow_data/workflow/specs/` is the global registry for spec-first chantiers. A chantier spec is not only an implementation contract; it also keeps the durable run history for the skills that acted on that chantier.

Each chantier spec should expose:

- `source_model` in frontmatter when `sf-spec` creates or materially updates the spec
- `Skill Run History` with `Date UTC`, `Skill`, `Model`, `Action`, `Result`, and `Next step`
- `Current Chantier Flow` for the readable status of `sf-spec`, `sf-ready`, `sf-start`, `sf-verify`, `sf-end`, and `sf-ship`

Skill application categories:

- `obligatoire`: `sf-spec`, `sf-ready`, `sf-build`, `sf-maintain`, `sf-deploy`, `sf-start`, `sf-verify`, `sf-end`, and `sf-ship` trace their current run when exactly one chantier spec is in scope.
- `conditionnel`: audits, docs, checks, fixes, deps, perf, migrations, scaffold, content, research, test, prod, backlog, priorities, tasks, changelog, review, and veille skills trace only when the run is explicitly attached to one unique chantier spec.
- `non-applicable`: help, context, model selection, exploration, status, resume, session naming, and the `shipflow <instruction>` router do not write to specs; if invoked inside a chantier flow, they report `Chantier: non applicable` or `Chantier: non trace` when useful. The selected lifecycle skill owns any chantier trace after handoff.

That trace category is separate from the internal process role:

- `lifecycle`: creates, readies, starts, verifies, ends, or ships an existing chantier.
- `source-de-chantier`: audits, diagnostics, checks, tests, prod verification, migrations, fixes, research, market study, or veille can reveal work that deserves a new spec.
- `support-de-chantier`: docs, content, scaffolding, changelog, design playground, skill refresh, or init work supports a chantier but should not normally originate one.
- `pilotage`: backlog, tasks, priorities, review, and continuation manage the flow and route to spec when the user or evidence requires it.
- `helper`: context, model choice, help, status, resume, exploration, and naming stay read-only for chantier writes.

The upstream intake flow is:

```text
source skill -> Chantier potentiel -> sf-spec -> sf-ready -> sf-start -> sf-verify -> sf-end/sf-ship
```

When a source skill finds non-trivial future work without one unique chantier, it must not write into a guessed spec. It should add a `Chantier potentiel` block with `oui`, `non`, or `incertain`, proposed title, reason, severity, scope, evidence, and a recommended `/sf-spec ...` command. `sf-spec` then consumes that block and turns it into the durable chantier contract.

No skill should create a separate chantier registry in `TASKS.md`, `AUDIT_LOG.md`, `PROJECTS.md`, or `shipflow_data`. If a spec cannot be identified or multiple specs match, the skill must stop or report non-trace instead of guessing.

## Artifact Doctrine

ShipFlow separates application content from ShipFlow work artifacts.

Application content is content parsed or rendered by the project runtime: `src/content/**`, MDX blog posts, framework content collections, public SEO pages, and app-specific documentation schemas. Those files must keep the schema required by the application.

ShipFlow work artifacts are produced to run and govern the work. They include:

- agent entrypoint docs
- project context docs
- business, product, brand, GTM, architecture, and technical guideline docs
- specs
- readiness reports
- verification reports
- audit reports
- review reports
- research reports
- exploration reports
- architecture notes
- decision records
- API/component docs generated by ShipFlow
- project business and brand documentation

ShipFlow artifacts use a standard YAML frontmatter schema. This makes them searchable, auditable, and safe to pass between skills.

That artifact doctrine also sharpens the boundary between three categories:

- active decision docs that govern implementation and audits
- trackers and registries that stay lightweight and operational
- runtime content that must preserve the application schema

Operational tracking files are not ShipFlow decision artifacts and do not require metadata frontmatter:

- `TASKS.md` tracks active work and backlog items.
- `AUDIT_LOG.md` tracks audit history.
- `PROJECTS.md` tracks project registry and domain applicability.

Do not migrate those files just to satisfy the artifact schema. If they contain durable decisions, extract those decisions into separate versioned artifacts and leave the tracker readable.

Location rule:

- `shipflow_data` is the control plane for cross-project tracking (`TASKS.md`, `AUDIT_LOG.md`, `PROJECTS.md`).
- The master tracker is not a direct substitute for a local project `TASKS.md`.
- Always distinguish between:
  - the master tracker
  - a project section inside the master tracker
  - the local `TASKS.md` file in a repo
- If a local `TASKS.md` is created after work already exists in the master tracker, split old entries into:
  - active backlog
  - historical completed context
- Do not copy completed historical entries from the master tracker into the local active backlog.
- Per-project decision artifacts belong in the project repository that they govern.
- `shipflow_data/business/business.md`, `shipflow_data/business/branding.md`, `shipflow_data/editorial/content-map.md`, `shipflow_data/technical/guidelines.md`, project competitor/inspiration registries, affiliate/referral/partner registries, specs, research, and decision records should be edited and versioned in the repo they affect, not duplicated into an external master data directory.
- If `shipflow_data` needs visibility, add a reference or inventory entry, not a second canonical copy.

Skill-aligned artifact templates live in `templates/artifacts/`. They should encode the structures expected by the active skills (`sf-spec`, `sf-ready`, `sf-verify`, `sf-review`, `sf-research`) instead of replacing those conventions. The current templates cover:

- `context`
- `spec`
- `business_context`
- `brand_context`
- `product_context`
- `competitive_intelligence`
- `affiliate_program_registry`
- `architecture_context`
- `gtm_context`
- `technical_guidelines`
- `technical_module_context`
- `audit_report`
- `verification_report`
- `readiness_report`
- `review_report`
- `research_report`
- `exploration_report`
- `decision_record`
- `content_map`

Validate metadata with:

```bash
SHIPFLOW_ROOT="${SHIPFLOW_ROOT:-$HOME/shipflow}"
"$SHIPFLOW_ROOT/tools/shipflow_metadata_lint.py"
```

The linter is intentionally dependency-free. It checks the default ShipFlow artifact locations (`docs/`, `shipflow_data/`, `AGENT.md`, plus legacy root artifact names as migration violations) and can also receive explicit files or folders. Root legacy files such as `BUSINESS.md`, `CONTEXT.md`, `CONTENT_MAP.md`, or `GUIDELINES.md` are not compliant final locations in project repos.

When a skill runs from a project repository, ShipFlow-owned docs, tools, references, templates, and skill-local `references/*` still resolve from `${SHIPFLOW_ROOT:-$HOME/shipflow}`. Only project artifacts and source files resolve from the current project root.

This decision-contract layer is wired into the active ShipFlow workflow: agent routing (`AGENT.md`), project orientation (`shipflow_data/technical/context.md`), documentation doctrine (`README.md`, this file, `shipflow-metadata-migration-guide.md`), the `sf-docs` skill, and `tools/shipflow_metadata_lint.py`.

## Language Doctrine

ShipFlow uses a two-layer language model:

- Internal contract language: English. Use English for skill instructions, workflow rules, YAML/frontmatter keys, stable section headings, acceptance criteria, stop conditions, validation notes, and technical decision documentation.
- User-facing language: the user's active language. Use that language for questions, short progress updates, final reports, onboarding copy, and product-visible text. If the user writes in French, answer in natural French with proper accents.

The rule is not "one language everywhere"; it is "one language per layer." A skill can be internally documented in English while still asking:

```text
Veux-tu modifier l'existant ou ajouter un comportement séparé ?
```

Stable machine-readable anchors stay English even in localized artifacts: `Status`, `Scope In`, `Scope Out`, `Acceptance Criteria`, `Test Strategy`, `Skill Run History`, `Current Chantier Flow`, and command names such as `sf-build`.

Do not rewrite old mixed-language artifacts only for language cleanup. Apply the doctrine to new artifacts and to touched sections when the change is already in scope.

For existing projects with legacy docs, follow [`shipflow-metadata-migration-guide.md`](./shipflow-metadata-migration-guide.md) and prefer additive frontmatter migration before deeper document rewrites.

For legacy migration, the official default scope is active context docs and decision contracts when they exist at root (`CONTEXT.md`, `CONTEXT-FUNCTION-TREE.md`, `BUSINESS.md`, `PRODUCT.md`, `BRANDING.md`, `GTM.md`, `ARCHITECTURE.md`, `CONTENT_MAP.md`, `GUIDELINES.md`) plus root `specs/*.md`, but only as migration sources. The final location is the project-local `shipflow_data/` tree. Do not expand the migration endlessly to every old markdown file unless that file is part of the active ShipFlow documentation set.

## Agent Context Layer

ShipFlow now separates agent context into three levels:

ShipFlow documentation is not meant to be encyclopedic. It is meant to be complete for fast agent navigation:

- point of entry
- operational context
- function tree for large scripts
- routing toward business, product, GTM, architecture, and guidelines
- recognition by `sf-docs` and by the metadata linter

- `CLAUDE.md`: repo constraints, critical rules, and coding guidance
- `AGENT.md`: routing doc that tells a fresh agent where to look first
- `shipflow_data/technical/context.md`: compact operational map of the project

Specialized context docs can extend this layer when a repo contains a large procedural or architectural hotspot. `shipflow_data/technical/context-function-tree.md` is the reference example: it exists because a fresh agent cannot efficiently infer the structure of a large shell file like `lib.sh` from memory alone.

`shipflow_data/editorial/content-map.md` extends the context layer for content-heavy projects. It maps blog surfaces, docs, landing pages, FAQs, semantic clusters, pillar pages, and cross-surface update rules so content skills can route output without rediscovering the repository structure in every thread.

`shipflow_data/editorial/` extends that map with content governance: public content impact, claim register, page intent, editorial update gates, Astro content schema policy, and blog/article surface stop conditions.

This layer exists to reduce repeated discovery work in fresh threads. It is not a substitute for reading code. If a context doc and the code disagree, the code wins and the context doc should be updated.

## Decision Contract Layer

ShipFlow also separates decision contracts by role to avoid turning one document into a catch-all:

- `shipflow_data/business/business.md` defines audience, business model assumptions, value proposition, and market frame.
- `shipflow_data/business/product.md` defines product scope, workflows, outcomes, and non-goals.
- `shipflow_data/business/branding.md` defines voice, trust posture, vocabulary, and claims boundaries.
- `shipflow_data/business/gtm.md` defines public promise, acquisition channels, proof points, objections, and funnel assumptions.
- `shipflow_data/editorial/content-map.md` defines content surfaces, semantic clusters, pillar pages, and repurposing destinations.
- `shipflow_data/editorial/` defines public-content governance, claims, page intent, and runtime content schema boundaries.
- `shipflow_data/technical/architecture.md` defines system organization, flows, boundaries, and structural invariants.
- `shipflow_data/technical/guidelines.md` defines engineering and documentation rules for contributors.

These contracts should reference each other through `depends_on` instead of being merged into one broad strategy file.

In practice, this clarifies the product surface:

- `shipflow_data/business/business.md` = for whom / what value / what model
- `shipflow_data/business/product.md` = what / workflows / non-goals
- `shipflow_data/business/branding.md` = how we speak
- `shipflow_data/business/gtm.md` = how we present and distribute it
- `shipflow_data/editorial/content-map.md` = where content lives / how ideas move across surfaces
- `shipflow_data/editorial/` = content governance / claims / page intent / Astro content
- `shipflow_data/technical/architecture.md` = how it is organized
- `shipflow_data/technical/guidelines.md` = how we work inside it

Documentation role map:

- `README.md` -> public overview and repo onboarding
- `AGENT.md` -> fast agent routing
- `shipflow_data/technical/context.md` -> operational map of the system
- `shipflow_data/technical/context-function-tree.md` -> structural index for large procedural files
- `shipflow_data/editorial/content-map.md` -> editorial map for blog, docs, landing pages, semantic clusters, and repurposing destinations
- `shipflow_data/editorial/` -> content governance for public content, claims, page intent, editorial update gates, and Astro runtime-content schema boundaries
- `CLAUDE.md` -> critical repository constraints and rules
- `shipflow-spec-driven-workflow.md` -> ShipFlow work doctrine
- `shipflow-metadata-migration-guide.md` -> frontmatter migration procedure
- `shipflow_data/business/business.md` -> business/product contract: for whom, what problem, what value, what model
- `shipflow_data/business/branding.md` -> brand contract: tone, posture, vocabulary, claims
- `shipflow_data/business/gtm.md` -> public promise and sales contract: offer, funnel, objections, proof, channels, KPIs
- `shipflow_data/editorial/content-map.md` -> content architecture contract: surfaces, page roles, semantic clusters, pillar pages, and update rules
- `docs/editorial/` -> editorial governance contract: public surfaces, claim register, page intent, content gates, and runtime schema policy
- `shipflow_data/technical/guidelines.md` -> technical constraints and conventions
- `shipflow_data/business/product.md` -> operational product contract
- `shipflow_data/technical/architecture.md` -> system view and structuring invariants
- `shipflow_data/workflow/specs/` -> local execution of a change

Each document has an explicit and exclusive role to avoid duplication, stale context, and conflicting contracts.

Minimum metadata:

```yaml
---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: "[project name]"
created: "2026-04-25"
updated: "2026-04-25"
status: draft
source_skill: sf-spec
scope: feature
owner: "[user/team]"
confidence: medium
risk_level: medium
security_impact: unknown
docs_impact: yes
linked_systems: []
depends_on: []
supersedes: []
evidence: []
next_step: "/sf-ready [title]"
---
```

Artifact-specific metadata can extend this:

- specs add `user_story`
- business docs add `target_audience`, `value_proposition`, `business_model`, `market`
- audits add `domains`, `issue_counts`, `confidence`
- reviews add `period`, `verified_outcomes`, `assumptions`
- research reports add `source_count`, `primary_sources`, `recommendation`

Two versions serve different purposes:

- `metadata_schema_version` tracks the ShipFlow metadata contract. Increment it only when the metadata shape or required fields change.
- `artifact_version` tracks the document's decision content. Increment it when the contract changes meaningfully.

Recommended `artifact_version` convention:

- `0.x.y` for drafts or inferred/migrated artifacts
- `1.0.0` for the first reviewed/active version
- patch bump for clarifications that do not change decisions
- minor bump for changed assumptions, audience, scope, API behavior, pricing, or docs impact
- major bump for a new product promise, business model, security posture, architecture direction, or incompatible decision contract

Concrete examples:

- `1.0.0 -> 1.0.1`: typo fixes, clearer wording, added source link, same decision.
- `1.0.0 -> 1.1.0`: target audience refined, pricing assumption changed, API example updated, onboarding promise clarified, new docs impact.
- `1.1.0 -> 2.0.0`: business model changes from content to SaaS, ICP changes from consumers to B2B teams, security posture changes from local-only to multi-tenant public app, architecture direction changes incompatibly.

Status and version work together:

- `status: draft` can use `0.x.y`.
- `status: reviewed` or `active` should use `>= 1.0.0`.
- `status: stale` means the artifact may still be historically useful but should not be used as an unreviewed dependency for new implementation.
- `status: superseded` should set `superseded_by`.

Specs should record the artifact versions they depend on:

```yaml
depends_on:
  - artifact: shipflow_data/business/business.md
    artifact_version: "1.2.0"
    required_status: reviewed
  - artifact: shipflow_data/business/branding.md
    artifact_version: "1.0.0"
    required_status: reviewed
  - artifact: docs/API.md
    artifact_version: "0.4.0"
    required_status: draft
```

If a dependent artifact becomes stale, the spec is not automatically invalid, but it must be re-evaluated before implementation or closure.

The metadata must not pretend certainty. If an artifact is inferred from old files or weak context, use `confidence: low`, `status: draft`, `risk_level: medium|high`, or explicit `unknown` values.

## Business Docs as Decision Contracts

ShipFlow treats business documentation as technical documentation because agents use it to make technical choices.

`shipflow_data/business/business.md`, `shipflow_data/business/branding.md`, `shipflow_data/technical/guidelines.md`, personas, market studies, pricing notes, positioning docs, and GTM docs influence:

- what user story a feature should serve
- what copy and UX should promise
- what risks should block shipping
- what price and trust level the product must justify
- what docs, onboarding, and support surfaces must stay coherent
- what audits should consider acceptable or misleading

This means business docs need the same discipline as technical specs:

- metadata frontmatter
- explicit status and confidence
- evidence and assumptions
- review dates
- linked artifacts
- risk level
- owner
- next step

Business documentation should never be treated as generic context if it drives implementation or audit decisions.

Example:

```yaml
---
artifact: business_context
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "[project name]"
created: "2026-04-25"
updated: "2026-04-25"
status: reviewed
source_skill: sf-docs
scope: business
owner: "[user/team]"
confidence: medium
risk_level: medium
business_model: saas
target_audience: "solo founders shipping paid public products"
value_proposition: "Ship safer product iterations through spec-driven AI workflows"
market: "FR/EN indie SaaS and agentic development"
security_impact: yes
docs_impact: yes
evidence:
  - "user interview notes"
  - "current product positioning"
linked_artifacts:
  - "shipflow_data/business/branding.md"
  - "shipflow-spec-driven-workflow.md"
depends_on: []
supersedes: []
next_review: "2026-05-25"
next_step: "/sf-docs audit"
---
```

## Documentation Coherence

Feature work is not complete if the user-facing behavior changed but the documentation still describes the old behavior.

When a feature changes, skills should consider these surfaces:

- README
- docs
- API docs
- component docs
- examples
- FAQ
- onboarding
- pricing
- changelog
- support copy
- screenshots
- public marketing pages

Documentation drift is a product risk when it affects:

- setup
- auth
- permissions
- payments
- security
- privacy
- API usage
- migrations
- destructive actions
- support expectations

This is why specs include `docs_impact`, why `sf-start` checks documentation coherence during implementation, and why `sf-verify` can flag stale docs as a blocking issue.

## Adoption and Migration

Older ShipFlow artifacts may not have the standard frontmatter. During adoption, `sf-docs audit` and `sf-docs update` should migrate them.

Migration rules:

- preserve the body
- add the ShipFlow metadata frontmatter
- infer only what is obvious from file name, title, date, and content
- use `unknown` for unproven fields
- use `confidence: low` when metadata is reconstructed
- do not convert application runtime content to the ShipFlow schema
- do not overwrite app-specific frontmatter needed by a framework

This lets existing work become traceable without pretending it was originally produced under the new standard.

## Professional Bug Management

ShipFlow uses a bug-file-first record model so tests, triage, and evidence stay readable across sessions:

- `TEST_LOG.md` is the compact campaign log.
- `bugs/BUG-ID.md` is the detailed Markdown source of truth for one bug work item.
- `BUGS.md`, when present, is only a compact optional/generated triage index that points to bug files.
- `test-evidence/BUG-ID/` stores redacted supporting evidence when material is too large or too sensitive for inline markdown.

The standard bug loop is:

```text
sf-bug -> sf-test -> bug file -> sf-fix -> sf-test --retest -> sf-verify -> sf-ship
```

Each stage has a narrow job:

- `sf-bug` reads bug state and continues the next safe lifecycle action through owner skills or bounded subagents without bypassing lifecycle gates.
- `sf-test` captures the failure, opens or updates the bug file, and may refresh the optional compact index.
- `sf-fix` reads the bug file and appends diagnosis and fix attempts.
- `sf-test --retest BUG-ID` appends the retest history and updates the bug state.
- `sf-verify` checks whether the remaining bug state still blocks release.
- `sf-ship` consumes the final bug state when deciding whether the ship is clean, partial-risk, or blocked.

The direct-fix path does not bypass this memory layer. If `sf-fix` is the first skill to touch an actionable bug, it should create or reuse a `BUG-ID` and create `bugs/BUG-ID.md` before ending the run. It may also update `BUGS.md` when that optional index exists or is generated for triage. The only normal exceptions are narrow copy-only, cosmetic-only, or duplicate cases, and the final report should name the exception explicitly.

Canonical bug states stay explicit:

- `open`
- `needs-info`
- `needs-repro`
- `in-diagnosis`
- `fix-attempted`
- `fixed-pending-verify`
- `closed`
- `closed-without-retest`
- `duplicate`
- `wontfix`

Closure rules are conservative:

- `closed` requires a passing retest.
- `closed-without-retest` requires a visible reason and residual risk note.
- `needs-info` and `needs-repro` mean the bug is still unresolved, not done.
- `duplicate` and `wontfix` must point to a concrete canonical bug or decision.

Evidence rules are strict:

- keep `TEST_LOG.md` and optional `BUGS.md` compact
- keep large logs, HAR, screenshots, dumps, and traces out of the index files
- redact secrets, cookies, tokens, private emails, request headers, and production PII before persisting evidence
- store larger redacted material under `test-evidence/BUG-ID/`
- never paste raw sensitive evidence inline when a path reference is enough

## Workflow by Stage

### 0. `sf-fix` (bug intake)

Use `sf-fix` when your intent is "fix a bug" rather than "start a session."

It performs a short triage and routes the bug:
- local and clear -> direct fix now
- ambiguous or non-trivial -> spec-first path

Typical routed outcomes:
- direct: `sf-fix -> sf-verify -> sf-end`
- spec-first: `sf-spec -> sf-ready -> sf-start -> sf-verify -> sf-end`

When `sf-test` finds a failure first, the bug should already exist as a bug file under `bugs/`. `sf-fix` should read that bug file instead of rebuilding context from chat history.

When `sf-fix` is the first skill to touch a bug, it should usually create that bug file itself instead of leaving the correction documented only in chat history or git diff. `BUGS.md` can be updated as an optional triage view. Only narrow minor exceptions such as copy-only or purely cosmetic fixes may skip bug-file creation, and that exception should be stated explicitly in the final report.

When the bug is auth or browser-session related, run `sf-auth-debug` before coding from theory. It consumes the bug report or spec, reproduces with Playwright where possible, and isolates failures across Clerk, OAuth, Google login, YouTube OAuth, Convex auth propagation, cookies, callbacks, protected routes, and Flutter web auth bridges. Its output should route back into `sf-fix`, `sf-start`, or `sf-verify` with evidence rather than guesses.

When the issue needs browser evidence but is not auth-specific, use `sf-browser` for the reproduction or observation. It collects the narrow browser proof, preserves read-only defaults, and routes actionable bugs back to `sf-fix` or non-trivial follow-up to `sf-spec`.

### 1. `sf-explore`

Use `sf-explore` when the problem is still fuzzy:
- feature idea not fully shaped
- risky refactor
- bug with unclear root cause
- cross-cutting behavior change

Expected outcome:
- clearer problem framing
- surfaced constraints
- identified unknowns
- decision to either stop, keep exploring, or move to `sf-spec`
- optional durable `exploration_report` when exploration is substantial or when the user explicitly requests a trace

### 2. `sf-spec`

Use `sf-spec` to create the implementation contract for non-trivial work.

The spec is expected to be autonomous and structured. It must include:
- `Title`
- `Status`
- `Problem`
- `Solution`
- `Scope In`
- `Scope Out`
- `Constraints`
- `Dependencies`
- `Invariants`
- `Links & Consequences`
- `Edge Cases`
- `Implementation Tasks`
- `Acceptance Criteria`
- `Test Strategy`
- `Risks`
- `Execution Notes`
- `Open Questions`

Status lifecycle:
- `draft`
- `reviewed`
- `ready`
- `implemented`
- `closed`

Rules:
- no unresolved filler markers
- no blocking open questions
- every implementation task must name a file and an action
- every implementation task should also name its validation and dependency ordering
- linked systems, consumers, and downstream consequences must be explicit
- no hidden dependency on conversation history
- tasks must be ordered by dependency

`sf-spec` is the canonical entry point for initial framing. It should be the default for medium+ work.

### 3. `sf-ready`

Use `sf-ready` as the guardrail before first implementation on non-trivial work.

It verifies that the spec is actually executable:
- structure is complete
- ambiguity is low enough
- task ordering is coherent
- linked systems and side effects are explicit
- acceptance criteria are testable
- execution notes are sufficient for a fresh agent
- open questions are resolved

If the spec passes, `sf-ready` promotes it to `Status: ready`.

`sf-ready` is also the right place to decide whether execution should continue on fresh context:
- if the environment can spawn a clean fresh subagent, it may do so
- otherwise it should explicitly ask the user to open a new thread before `/sf-start`

If not, it returns a concrete `not ready` verdict and pushes the work back toward spec refinement.

### 4. `sf-start`

`sf-start` is the execution kickoff, not a discovery phase.

Behavior:
- accepts direct execution for small, explicit, local fixes
- requires a `ready` spec for non-trivial work
- blocks if the spec is missing, incomplete, or contradictory
- derives an execution contract (target files, invariants, linked systems, validations, stop conditions) before coding
- reads the shared `sf-model` routing reference before coding
- chooses a primary execution model and reasoning effort before implementation
- may assign per-group model overrides when the execution is materially non-trivial
- chooses execution topology before launching work, using `skills/references/master-delegation-semantics.md` for master/orchestrator delegation when applicable
- loads only the execution-relevant files and the linked systems that must be revalidated
- prefers fresh context for spec-first execution when that reduces residual ambiguity
- routes non-auth browser proof to `sf-browser` and auth/session/protected-flow proof to `sf-auth-debug`

The key rule:
- if the work is ambiguous or multi-file, `sf-start` should not invent the missing intent

Topology rule:
- use delegated sequential by default for master/orchestrator file work when subagents are available
- use master/single-agent degradation only when allowed by `skills/references/master-delegation-semantics.md`
- use parallel subagents only with ready `Execution Batches`

### 5. Implementation (inside `sf-start`)

Once `sf-start` begins execution, the implementation should follow the spec contract:
- same scope
- same ordering assumptions
- same acceptance criteria
- same constraints and invariants
- same linked systems and consequence checks

If the implementation reveals a small missing delta, the loop does not automatically restart from scratch.
If it reveals a new side effect outside the contract, that is a reroute signal, not an invitation to improvise.

### 6. `sf-verify`

`sf-verify` is now both a verifier and a controlled remediation orchestrator.

It verifies in this order:
1. spec compliance
2. traceability from spec to code/tests
3. linked systems and downstream consequences
4. code quality, dependencies, and risks
5. workflow next step

It classifies the primary cause into one of these buckets:
- `specified but not implemented`
- `spec incomplete or ambiguous`
- `implemented but not specified`
- `technical failure only`
- `missing contract`
- `complete and ready`

Then it decides what to do.

#### When `sf-verify` remediates directly

If the spec is sound and the gap is only implementation:
- it can complete the missing work
- rerun the relevant checks
- mark traceability entries as `fixed during verify`

If the delta becomes too large, it should stop and route back to `sf-start`.

#### When `sf-verify` updates the spec

If the implementation exposed a small framing hole:
- it can apply a bounded mini-spec correction
- translate the answers into a mini spec delta
- update the existing spec first
- then resume implementation and re-verify

This is not a replacement for `sf-spec`.
It is a local repair path for late-discovered, bounded ambiguity.
It should not become the normal way work gets clarified.

#### When `sf-verify` reroutes

Typical routing outcomes:
- `specified but not implemented` -> remediate now, or `/sf-start` if the delta is too large
- `spec incomplete or ambiguous` -> mini-spec correction, then continue; if global drift, return to `/sf-spec`
- `implemented but not specified` -> clarify whether to keep or remove the extra behavior, then update spec or code
- `technical failure only` -> fix technical breakage and rerun verify
- `complete and ready` -> `/sf-end`

Every `sf-verify` report should end with:
- `Primary cause`
- `Action taken`
- `Next step`
- `Reason`

### 7. `sf-end`

`sf-end` closes the task against the spec and the delivered behavior.

It should:
- mark completed tasks as done
- keep partial work explicit
- record drift from the spec when it happened
- move the spec to `implemented` or `closed`
- prepare the next priorities cleanly

## Decision Rules

Use this rule of thumb:

- bug lifecycle orchestration -> `sf-bug`
- recurring project maintenance -> `sf-maintain`
- content management -> `sf-content`
- general design request, UI/UX work, redesign, token migration, or visual proof -> `sf-design`
- design system from scattered UI values when the operator already knows that exact target -> `sf-design-from-scratch`
- bug repair intake -> `sf-fix`
- unclear problem -> `sf-explore`
- non-trivial scoped work -> `sf-spec`
- spec candidate before first implementation -> `sf-ready`
- ready execution kickoff -> `sf-start`
- verify and possibly close the loop -> `sf-verify`
- wrap up delivered work -> `sf-end`

## Prompted Decisions

Several skills now prompt explicit choices when the next action is ambiguous:

- `sf-fix`: direct fix vs spec-first vs diagnostic only
- `sf-start`: execute direct vs spec-first vs clarify first (`sf-explore`)
- `sf-spec`: light spec vs full spec vs auto-by-risk
- `sf-context`: proceed now vs add one key file vs refine target
- `sf-verify`: fix now vs return to spec vs stop and resume later
- `sf-end`: full close vs partial close vs summary only
- `sf-status`: issues-only vs dirty-only vs all-project view

This keeps momentum while avoiding silent assumptions in decision-heavy moments.

`sf-model` is optional but useful when you want to choose manually before execution.
`sf-start` should still reuse the same routing matrix internally, so manual and automatic choices stay aligned.

## One-Pass Agent Handoff

When a skill launches agents, the prompt should already contain:
- the exact scope and absolute date
- the relevant context files already surfaced by the parent skill
- the linked systems / consumers / downstream consequences to think about
- a no-follow-up rule: missing context becomes an explicit assumption, not a clarification round
- a structured output that includes confidence and missing context

The success criterion is strict:
- a fresh agent should be able to execute or audit from the prompt alone
- if that is not true, the parent skill is still underspecified
- if a fresh context is needed for the next step and the environment cannot create it directly, the skill should explicitly ask the user to open a new thread

In practice, this matters most for:
- `sf-ready` -> deciding whether the next step should restart cleanly
- `sf-start` -> executing non-trivial work from a clean contract instead of accumulated chat state

Shortcut rules:

- if the issue is already specified and simply unfinished, do not rewrite the whole spec
- if the issue reveals real contract ambiguity, update the spec before more code
- if the missing delta is local and obvious, `sf-verify` may absorb it
- if the missing delta changes architecture or scope, go back to `sf-spec`

## Example Flows

### Small local bug fix

```text
sf-fix -> sf-verify -> sf-end
```

### New feature with ambiguity

```text
sf-explore -> exploration_report -> sf-spec -> sf-ready -> sf-start -> sf-verify -> sf-end
```

### Feature mostly implemented but incomplete

```text
sf-spec -> sf-ready -> sf-start -> sf-verify
                                           |
                                           v
                          remediate missing specified work
                                           |
                                           v
                                        sf-end
```

### Feature reveals missing edge case late

```text
sf-spec -> sf-ready -> sf-start -> sf-verify
                                           |
                                           v
                         exceptional mini-spec delta + remediation
                                           |
                                           v
                                        sf-end
```

## What Changed from Earlier Flow

Earlier, the workflow tended to rediscover intent during `sf-start` or after failed implementation.

ShipFlow V3 changes that:
- `sf-start` is no longer the place where the problem gets clarified
- `sf-spec` is stricter and contract-oriented
- `sf-ready` is a real gate, not a nice-to-have
- `sf-verify` no longer stops at diagnosis; it can classify, clarify, remediate, and reroute
- the default target is one-pass execution from a complete contract, not prompt-and-correct after the fact
- the system now has an explicit path for incomplete implementation without automatically restarting the full cycle

## Practical Guidance

If a feature is reported as incomplete:
- use `sf-start` again only when the spec is still valid and the missing work is already specified
- use `sf-spec` again when the contract itself is insufficient
- let `sf-verify` absorb the delta when the missing work is local and safe to repair in-place

If you need several clarification rounds after implementation already started, assume the contract was too weak and route back upstream.

The important distinction is not "is the feature incomplete?"

The real distinction is:
- incomplete implementation
- incomplete contract
- implementation/spec drift

That distinction now drives the workflow.

## Questions

### Si je veux ameliorer ou elargir une feature existante, quelle skill utiliser ?

Use this decision rule:

- `sf-explore` if the change is still fuzzy (intent, scope, or expected behavior not clear)
- `sf-start` if the work is clear and already executable
- `sf-fix` if your entrypoint is "adjust/correct this existing feature" and you want automatic routing

Practical shortcut:

- if you hesitate between `sf-explore` and `sf-start`, begin with `sf-fix`
- `sf-fix` handles quick direct execution for local changes and routes to spec-first when the scope is non-trivial

### J'ai un bug: est-ce que je dois lancer `sf-verify` en premier ?

No. Start with `sf-fix`.

- `sf-fix` = intake + triage + direct execution when local/clear
- `sf-verify` = post-implementation validation and remediation loop

Recommended bug flow:

```text
sf-fix -> sf-verify -> sf-end
```

If the bug is non-trivial, `sf-fix` routes to:

```text
sf-spec -> sf-ready -> sf-start -> sf-verify -> sf-end
```

### Quand faire une revue adversariale de la spec ?

Apply this rule:

- if at least one signal is true, run an adversarial review

Signals:
- more than one file is impacted
- more than one domain is impacted (for example UI + API, backend + data)
- non-trivial business behavior
- security/data/auth/perf/migration/API contract impact
- likely edge cases
- vague wording in spec without testable criteria

Light review is acceptable only for local, obvious, single-file fixes.

### Faut-il renommer `TASKS` en `BACKLOG` ?

No. Keep both with distinct roles.

- `TASKS.md` = active, prioritized, executable now
- `BACKLOG.md` = deferred ideas and parking lot

Promotion rule:
- move an item from backlog to tasks only when it is clear enough and prioritized for execution now
