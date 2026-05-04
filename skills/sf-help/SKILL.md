---
name: sf-help
description: "ShipFlow help for skills, tasks, audits, workflows, modes, prompts, and common commands."
disable-model-invocation: true
argument-hint: [optional: tasks, audit, workflows, prompts]
---

## Canonical Paths

Before resolving any ShipFlow-owned file, load `$SHIPFLOW_ROOT/skills/references/canonical-paths.md` (`$SHIPFLOW_ROOT` defaults to `$HOME/shipflow`). ShipFlow tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPFLOW_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Chantier Tracking

Trace category: `non-applicable`.
Process role: `helper`.

This skill does not write to chantier specs. If invoked inside a spec-first flow, do not modify `Skill Run History`; include `Chantier: non applicable` or `Chantier: non trace` in the final report when useful, with the reason and the next lifecycle command if one is obvious.


# Skill System Cheatsheet

Quick reference for the skill system, modes, and workflows.

---

## Skills at a Glance

### Task & Workflow

| Skill | Purpose | Arguments |
|-------|---------|-----------|
| `/sf-build` | Master user-facing orchestrator from story to spec, implementation, verification, closure, and ship | `<story, bug, or goal>` |
| `/sf-skill-build` | Master skill-maintenance orchestrator for creating or modifying ShipFlow skills with optional exploration and lifecycle gates | `<new skill idea | existing skill path>` |
| `/sf-maintain` | Master maintenance lifecycle from triage through delegated fixes, verification, and ship | `quick`, `full`, `security`, `global`, `no-ship` |
| `/sf-content` | Master content lifecycle for strategy, repurposing, drafting, enrichment, audits, docs, validation, and ship routing | `plan`, `repurpose`, `draft`, `enrich`, `audit`, `seo`, `editorial`, `apply`, `ship` |
| `/sf-bug` | Professional bug loop orchestrator for intake, bug files, fixes, retests, verification, and ship risk | `BUG-ID`, `--retest BUG-ID`, `--ship BUG-ID` |
| `/sf-fix` | Bug-first intake and routing (direct fix vs spec-first) | `<bug description>` |
| `/sf-auth-debug` | Browser-auth diagnosis for Clerk, Supabase Auth, OAuth, Google/YouTube, Convex, sessions, callbacks | `<bug/URL/flow>` |
| `/sf-browser` | General browser verification for public UI, visual state, console/network evidence, screenshots, and page-level assertions | `<URL or route> <objective>` |
| `/sf-test` | Guided manual QA: prompts the user through real flow tests, logs evidence, and opens bug records | `[feature]`, `--retest BUG-ID`, `--prod` |
| `/sf-model` | Choose model, reasoning level, and fast/cheap fallback before execution | `<task description>` or `<spec path>` |
| `/sf-tasks` | Track work, check off items, suggest next | `[focus area]` |
| `/sf-priorities` | Re-rank by impact/effort matrix | `impact`, `effort`, `blockers`, `high-roi` / `quick-wins` |
| `/sf-backlog` | Capture ideas, defer non-urgent | `add "idea"`, `defer`, `review`, `clean` |
| `/sf-review` | Session summary, update docs | `daily`, `weekly`, `sprint`, `release` |
| `/sf-resume` | Ultra-fast current-thread recap and close/keep-open verdict | `court`, `ultra-court` |

### Audit (8 domains)

| Skill | Purpose | Arguments |
|-------|---------|-----------|
| `/sf-audit` | Master orchestrator (all 8 domains) | `@file`, `global`, or nothing |
| `/sf-audit-code` | Architecture, security, reliability, system fit (anti-duplication) | `@file`, `global`, or nothing |
| `/sf-audit-design` | UI/UX, a11y, responsiveness | `@file`, `global`, or nothing |
| `/sf-design-from-scratch` | Build a professional tokenized design system from an existing UI | `tokens-only`, `with-playground`, `@file`, or nothing |
| `/sf-audit-copy` | Copywriting, tone, CTAs | `@file`, `global`, or nothing |
| `/sf-audit-seo` | Meta tags, structured data, links | `@file`, `global`, or nothing |
| `/sf-audit-gtm` | Go-to-market, conversion, trust | `@file`, `global`, or nothing |
| `/sf-audit-translate` | i18n completeness, consistency, missing-translation sync | `@file`, `global`, `sync`, `apply`, or nothing |
| `/sf-deps` | Dependencies: vulns, outdated, unused, licenses | `global`, or nothing |
| `/sf-perf` | Performance: bundle, CWV, rendering, data | `@file`, `global`, or nothing |

### DevOps & Shipping

| Skill | Purpose | Arguments |
|-------|---------|-----------|
| `/sf-ship` | Quick ship by default; full close+ship with explicit keyword | `"commit message"`, `end la tache`, `skip-check` |
| `/sf-check` | Typecheck + lint + build + test | `[check types]`, `fix`, `nofix` |
| `/sf-deploy` | Release orchestrator: check → ship → prod → browser/manual proof → verify | `skip-check`, `--preview`, `--prod`, `no-changelog` |
| `/sf-status` | Cross-project git dashboard | (none) |

Note: `/sf-verify` now includes guided next-step prompting when verdict is not ready (`corriger maintenant`, `repasser par spec`, `stop/reprendre`).
Note: `/sf-auth-debug` is the required diagnostic path for auth bugs that need browser evidence before implementation.
Note: `/sf-browser` is the generic browser evidence path for non-auth page assertions; use `/sf-auth-debug` for auth/session/provider issues, `/sf-prod` for deployment truth, and `/sf-test` for durable manual QA logs.
Note: `/sf-test` sits after verification and before shipping when a human needs to confirm the real user flow; it writes compact `TEST_LOG.md`, durable bug files under `bugs/`, and optional compact `BUGS.md` triage views when needed.
Note: `/sf-bug` is the recommended entrypoint when you want the whole professional bug loop routed from a `BUG-ID`, retest, closure question, or ship-risk question.
Note: `/sf-start` now reuses the `sf-model` routing matrix and can choose `single-agent` vs `multi-agent` execution with explicit file ownership and per-group model overrides.
Note: `/sf-spec` → `/sf-ready` → `/sf-start` → `/sf-verify` now share a `User Story` contract and should ask targeted user questions whenever behavior, scope, or security is still ambiguous.
Note: `/sf-build` is the recommended end-user entrypoint for non-trivial work; invocation authorizes bounded delegated sequential execution for the current chantier, while parallel execution requires ready non-overlapping `Execution Batches`.
Note: `/sf-deploy` is the recommended release entrypoint when the operator wants the whole confidence loop after implementation: checks, bounded ship, deployment truth, post-deploy evidence routing, verification, and optional changelog.
Note: `/sf-maintain` is the recommended recurring maintenance entrypoint for existing projects; by default it carries maintenance through spec/readiness when needed, bounded delegated execution, verification, and ship/deploy routing. Use `/sf-maintain quick` for read-only triage.
Note: `/sf-content` is the recommended entrypoint for content management (`CONTENT_MAP + editorial corpus -> owner content skills -> audits/docs -> validation -> sf-verify -> sf-ship`).
Note: `/sf-skill-build` is the recommended entrypoint for ShipFlow skill maintenance (`sf-explore when needed -> sf-spec -> SKILL.md -> sf-skills-refresh -> budget audit -> sf-verify -> sf-docs/help update -> sf-ship`).

### Professional Bug Loop (concise)

Flow:
1. `/sf-bug [BUG-ID or summary]` chooses the safest next command.
2. `/sf-test [scope]` detects a fail and logs a compact test pointer.
3. `bugs/BUG-ID.md` is the full bug file and source of truth (repro, expected/observed, diagnosis, Fix Attempts, Retest History, redaction state, next step).
4. `BUGS.md`, when present, is only a compact optional/generated triage row (`BUG-ID`, status, severity, last-tested, bug file path).
5. `/sf-fix BUG-ID` appends diagnosis + fix attempts; when no `BUG-ID` exists yet, `sf-fix` should usually create one rather than leaving the bug memory only in chat or git history.
6. `/sf-test --retest BUG-ID` appends Retest History in the bug file and updates status (`open` or `fixed-pending-verify`).
7. `/sf-verify` and `/sf-ship` gate optimistic closure when open high/critical bugs remain.

File roles:
- `TEST_LOG.md`: tracker of manual test runs (compact pointers only).
- `bugs/BUG-ID.md`: durable bug file and source of truth.
- `BUGS.md`: optional compact tracker/triage view of bug state.
- `test-evidence/BUG-ID/`: optional redacted heavy evidence only.

### Chantier Registry

`specs/` is the global registry for spec-first chantiers. Each chantier spec owns its `Skill Run History` and `Current Chantier Flow`; do not create a parallel chantier registry in `TASKS.md`, `AUDIT_LOG.md`, `PROJECTS.md`, or `shipflow_data`.

Internal role matrix:

| Skill file | Trace category | Process role | Source threshold |
|------------|----------------|--------------|------------------|
| `skills/name/SKILL.md` | non-applicable | helper | Never writes to specs; report non-applicable when useful. |
| `skills/continue/SKILL.md` | conditionnel | pilotage | Route to `/sf-spec` only when continuation clearly needs a durable chantier. |
| `skills/sf-audit-a11y/SKILL.md` | conditionnel | source-de-chantier | Accessibility findings become a chantier when severity, scope, remediation sequencing, or validation need exceeds a direct fix. |
| `skills/sf-audit-code/SKILL.md` | conditionnel | source-de-chantier | Code findings become a chantier for P0/P1, architectural/security risk, or multi-file remediation. |
| `skills/sf-audit-components/SKILL.md` | conditionnel | source-de-chantier | Component findings become a chantier for systemic duplication, variant drift, or cross-component remediation. |
| `skills/sf-audit-copy/SKILL.md` | conditionnel | source-de-chantier | Copy findings become a chantier for multi-page conversion, legal, trust, or positioning work. |
| `skills/sf-audit-copywriting/SKILL.md` | conditionnel | source-de-chantier | Strategic copy findings become a chantier when persuasion, offer, or funnel decisions are required. |
| `skills/sf-audit-design-tokens/SKILL.md` | conditionnel | source-de-chantier | Token findings become a chantier for design-system drift or migration across multiple surfaces. |
| `skills/sf-audit-design/SKILL.md` | conditionnel | source-de-chantier | Design findings become a chantier for multi-screen UX, a11y, or responsive remediation. |
| `skills/sf-audit-gtm/SKILL.md` | conditionnel | source-de-chantier | GTM findings become a chantier when offer, funnel, analytics, pricing, or trust changes require decisions. |
| `skills/sf-audit-seo/SKILL.md` | conditionnel | source-de-chantier | SEO findings become a chantier for indexation, schema, content architecture, or multi-page remediation. |
| `skills/sf-audit-translate/SKILL.md` | conditionnel | source-de-chantier | Translation findings become a chantier for locale strategy, broad sync, or quality gates. |
| `skills/sf-audit/SKILL.md` | conditionnel | source-de-chantier | Master audit findings become a chantier for transversal P1/P2 clusters or multi-domain remediation. |
| `skills/sf-auth-debug/SKILL.md` | conditionnel | source-de-chantier | Auth findings become a chantier for session, callback, provider, tenant, or permission risk beyond a direct fix. |
| `skills/sf-backlog/SKILL.md` | conditionnel | pilotage | Backlog ideas become a spec only on explicit user intent or clear high-risk follow-up. |
| `skills/sf-browser/SKILL.md` | conditionnel | source-de-chantier | Browser findings become a chantier for non-trivial page, deploy, runtime, security, or workflow issues beyond one direct observation. |
| `skills/sf-changelog/SKILL.md` | conditionnel | support-de-chantier | Supports release documentation; not a source by default. |
| `skills/sf-check/SKILL.md` | conditionnel | source-de-chantier | Failed checks become a chantier when failures span domains, block release, or need staged remediation. |
| `skills/sf-context/SKILL.md` | non-applicable | helper | Context discovery is read-only; not a chantier source. |
| `skills/sf-deps/SKILL.md` | conditionnel | source-de-chantier | Dependency findings become a chantier for critical/high risk, supply-chain trust, migration, or automation gaps. |
| `skills/sf-design-from-scratch/SKILL.md` | conditionnel | source-de-chantier | Design-system creation becomes a chantier when tokenization or migration spans multiple surfaces. |
| `skills/sf-design-playground/SKILL.md` | conditionnel | support-de-chantier | Supports design-token work; route only on explicit formalization request. |
| `skills/sf-docs/SKILL.md` | conditionnel | support-de-chantier | Supports docs coherence; not a source unless the user asks to frame a spec. |
| `skills/sf-end/SKILL.md` | obligatoire | lifecycle | Closes an existing chantier; not a source. |
| `skills/sf-deploy/SKILL.md` | obligatoire | lifecycle | Orchestrates the release confidence loop through checks, ship, deploy truth, post-deploy evidence, verification, and changelog routing. |
| `skills/sf-enrich/SKILL.md` | conditionnel | support-de-chantier | Supports content upgrades; route only when follow-up needs a spec. |
| `skills/sf-explore/SKILL.md` | non-applicable | helper | Exploration can recommend `/sf-spec` and may write durable `exploration_report` artifacts, but does not write chantier history. |
| `skills/sf-bug/SKILL.md` | conditionnel | source-de-chantier | Bug lifecycle orchestration becomes a chantier when status, severity, reproduction, closure, or ship risk needs a durable spec. |
| `skills/sf-content/SKILL.md` | obligatoire | lifecycle | Master content lifecycle: content map, editorial corpus, owner content skills, audits, docs, validation, and ship routing. |
| `skills/sf-fix/SKILL.md` | conditionnel | source-de-chantier | Bug triage becomes a chantier when the fix is non-local, risky, or spec-first. |
| `skills/sf-help/SKILL.md` | non-applicable | helper | Help is doctrine/read-only; never writes to specs. |
| `skills/sf-init/SKILL.md` | conditionnel | support-de-chantier | Supports project bootstrap; route to spec only when setup policy must be formalized. |
| `skills/sf-market-study/SKILL.md` | conditionnel | source-de-chantier | Market findings become a chantier when they require product, GTM, content, or implementation decisions. |
| `skills/sf-migrate/SKILL.md` | conditionnel | source-de-chantier | Migration findings become a chantier for breaking changes, staged upgrades, or rollback/validation planning. |
| `skills/sf-maintain/SKILL.md` | obligatoire | lifecycle | Master maintenance lifecycle: triage, spec/readiness, bounded delegated execution, verification, and ship/deploy routing. |
| `skills/sf-model/SKILL.md` | non-applicable | helper | Model advice does not mutate specs; report non-trace when useful. |
| `skills/sf-perf/SKILL.md` | conditionnel | source-de-chantier | Perf findings become a chantier for Core Web Vitals risk, systemic rendering/fetching issues, or multi-file remediation. |
| `skills/sf-priorities/SKILL.md` | conditionnel | pilotage | Priority work routes to `/sf-spec` only when an item needs a durable contract. |
| `skills/sf-prod/SKILL.md` | conditionnel | source-de-chantier | Production incidents become a chantier for outage, deploy, runtime, rollback, or monitoring follow-up. |
| `skills/sf-ready/SKILL.md` | obligatoire | lifecycle | Gates an existing spec; not a source. |
| `skills/sf-redact/SKILL.md` | conditionnel | support-de-chantier | Supports content production; not a source by default. |
| `skills/sf-repurpose/SKILL.md` | conditionnel | support-de-chantier | Supports repurposing; route only when work must become a spec. |
| `skills/sf-research/SKILL.md` | conditionnel | source-de-chantier | Research becomes a chantier when it produces implementation, architecture, product, or GTM decisions. |
| `skills/sf-resume/SKILL.md` | non-applicable | helper | Thread recap does not mutate specs; report non-trace when useful. |
| `skills/sf-review/SKILL.md` | conditionnel | pilotage | Review routes to `/sf-spec` only for explicit follow-up work. |
| `skills/sf-scaffold/SKILL.md` | conditionnel | support-de-chantier | Supports implementation; not a source by default. |
| `skills/sf-ship/SKILL.md` | obligatoire | lifecycle | Ships an existing chantier; not a source. |
| `skills/sf-skills-refresh/SKILL.md` | conditionnel | support-de-chantier | Supports skill maintenance; route to spec for broad policy changes only. |
| `skills/sf-spec/SKILL.md` | obligatoire | lifecycle | Creates or updates the chantier spec and initial history row. |
| `skills/sf-skill-build/SKILL.md` | obligatoire | lifecycle | Executes the skill-maintenance lifecycle for new or modified ShipFlow skills. |
| `skills/sf-start/SKILL.md` | obligatoire | lifecycle | Executes an existing chantier; not a source. |
| `skills/sf-status/SKILL.md` | non-applicable | helper | Status dashboards stay read-only for chantier specs. |
| `skills/sf-tasks/SKILL.md` | conditionnel | pilotage | Task management routes to `/sf-spec` only for durable non-trivial work. |
| `skills/sf-test/SKILL.md` | conditionnel | source-de-chantier | Test failures become a chantier for critical bugs, repeated regressions, or non-local fixes. |
| `skills/sf-veille/SKILL.md` | conditionnel | source-de-chantier | Watch items become a chantier when they require product, content, architecture, or implementation decisions. |
| `skills/sf-verify/SKILL.md` | obligatoire | lifecycle | Verifies an existing chantier and reports drift; not a source. |

Report rule: every applicable report ends with a `Chantier` block. Conditional skills that cannot identify one unique spec must not write anywhere; they report `Chantier: non applicable` or `Chantier: non trace` and name the reason. Source skills also evaluate the standard `Chantier potentiel` threshold from `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md`.

### Scaffolding & Init

| Skill | Purpose | Arguments |
|-------|---------|-----------|
| `/sf-init` | Bootstrap new project for ShipFlow | `[project-path]` |
| `/sf-scaffold` | Generate files matching project patterns | `<type> <name>` |

### Research & Documentation

| Skill | Purpose | Arguments |
|-------|---------|-----------|
| `/sf-research` | Deep web research → saved report | `<topic>` |
| `/sf-docs` | Generate/update docs from code | `@file`, `readme`, `api`, `components` |
| `/sf-enrich` | Web research + content upgrade | `@file` or `folder/` |

### Upgrades

| Skill | Purpose | Arguments |
|-------|---------|-----------|
| `/sf-migrate` | Framework upgrade assistant | `[package@version]` |
| `/sf-changelog` | Auto-generate CHANGELOG from git | `[tag]`, `[date]`, `all` |

---

## Audit Modes (3 modes)

```bash
# PAGE MODE — audit a single file
/sf-audit-seo @src/pages/index.astro

# PROJECT MODE — audit current project (default)
/sf-audit-code

# GLOBAL MODE — audit ALL applicable projects
/sf-audit global
/sf-audit-seo global
```

**Domain applicability**: Not all audits apply to all projects. Global mode reads `~/shipflow_data/PROJECTS.md` and skips inapplicable domains (e.g., no SEO for `my-robots`, no Deps for `BuildFlowz`).

**8 domains**: Code, Design, Copy, SEO, GTM, Translate, Deps, Perf.

**Scoring**: Every audit scores categories A/B/C/D, fixes issues, logs to `AUDIT_LOG.md`, creates tasks in `TASKS.md`.

---

## Interactive Prompts

Skills auto-detect context and prompt when needed:

### Workspace root detection
Run any skill from `~/` (no project markers) and it asks **"Which project(s)?"** instead of failing.

### Scope selection
| Skill | Prompt | Options |
|-------|--------|---------|
| `/sf-review` | "What time scope?" | Daily, Weekly, Sprint, Release |
| `/sf-check` | "Which checks?" | Typecheck, Lint, Build, Test, Dependencies |
| `/sf-audit` | "Which domains?" | Code, Design, Copy, SEO, GTM, Translate, Deps, Perf |
| `/sf-audit global` | "Which projects?" + "Which domains?" | Checkboxes for both |
| `/sf-init` | "Confirm domain applicability?" | Checkboxes for 8 domains |

### Guided decision prompts (new)
| Skill | When it prompts | Choices |
|-------|------------------|---------|
| `/sf-fix` | Bug scope is borderline | Direct fix / Spec-first / Diagnostic only |
| `/sf-start` | Scope triage is ambiguous | Execute direct / Spec-first / Clarify first (`/sf-explore`) |
| `/sf-end` | Completion is unclear | Full close / Partial close / Summary only |
| `/sf-status` | No view mode argument | Issues only / Dirty only / All projects |
| `/sf-context` | Context priming completed | Proceed now / Add 1 key file / Refine target |
| `/sf-spec` | Small/local change | Spec light / Spec full / Auto by risk |
| `/sf-skill-build` | Skill idea or placement is too fuzzy | Ask one targeted question / Route to `/sf-explore` / Continue to `/sf-spec` |
| `/sf-verify` | Verdict is not ready | Fix now / Return to spec / Stop and resume later |

### Clarification prompts (important)
- A skill should ask the user when the answer materially changes behavior, scope, permissions, data exposure, tenant isolation, retry/rollback policy, or external side effects.
- Do not ask broad "anything else?" questions. Ask short, decision-forcing questions anchored in the code or spec.
- Good examples:
  - "Cette action doit-elle être réservée aux admins côté serveur, ou un membre connecté suffit-il ?"
  - "En cas d'échec partiel, on retry, on garde l'état pending, ou on annule tout ?"
  - "Cette donnée peut-elle être visible entre organisations, même en lecture seule ?"

### Security-by-default
- Public or high-value products must assume hostile inputs, bypass attempts, and cross-system fallout.
- `sf-spec` must capture trust assumptions, allowed/forbidden actors, and key abuse cases when relevant.
- `sf-ready` must block specs with unresolved security-significant questions.
- `sf-start` must not pick silent defaults when ambiguity affects auth, data, money, tenant boundaries, or workflow integrity.
- `sf-verify` must explicitly call out security assumptions it cannot prove.
- `sf-fix` must reroute instead of applying a "small fix" when the bug may actually hide a contract or security decision.
- `sf-scaffold` must preserve existing product/system coherence and avoid generating unsafe public-by-default artifacts.
- `sf-check` and `sf-prod` must surface risky unknowns clearly instead of treating green checks as proof of product safety.
- `sf-audit-code` must review business-flow abuse and product coherence, not just code style and raw security smells.

### Project development mode
- Every project should document `## ShipFlow Development Mode` in `CLAUDE.md`, or `SHIPFLOW.md` when no `CLAUDE.md` exists.
- `local` means local dev servers and local browser checks are valid before shipping.
- `vercel-preview-push` means any browser/manual/preview validation of changed behavior must wait for `sf-ship` followed immediately by `sf-prod`.
- `hybrid` means local checks are valid for unit/static work, but hosted flows such as auth, OAuth callbacks, webhooks, Vercel routing, serverless/edge runtime, and deployment env vars require `sf-ship` -> `sf-prod` first.
- `sf-prod` should use Vercel MCP as the primary source for waiting on the matching deployment when Vercel preview-push is the validation surface.

### Product coherence
- A technically valid change is not enough if it weakens the product promise, creates a confusing flow, or diverges from established project patterns.
- Skills should verify coherence across user story, UI behavior, permissions, data lifecycle, failure handling, and linked systems.
- If a requested change conflicts with the existing product model, the skill should surface the conflict explicitly instead of normalizing it silently.

### Documentation coherence
- When a feature behavior changes, active docs must stay aligned: README, docs, guides, examples, FAQ, onboarding, pricing, changelog, support copy, screenshots, and public pages when relevant.
- Specs should name impacted docs or state `None, because ...`.
- Implementation and verification skills should update or flag stale docs instead of treating documentation as optional cleanup.
- Stale docs are a product risk when they affect setup, security, payments, permissions, API usage, migration, destructive actions, or support expectations.

### Artifact metadata
- ShipFlow internal artifacts must start with YAML frontmatter using the ShipFlow schema. This includes specs, reviews, research reports, audit reports, verification reports, architecture notes, decision records, and project documentation generated by ShipFlow.
- Operational trackers/registries are excluded: do not add metadata frontmatter to `TASKS.md`, `AUDIT_LOG.md`, or `PROJECTS.md`. Extract durable decisions from them into separate artifacts instead.
- Required common fields for reusable ShipFlow artifacts: `artifact`, `metadata_schema_version`, `artifact_version`, `project`, `created`, `updated`, `status`, `scope`, `owner`, `source_skill`.
- Use structured fields when relevant: `user_story`, `confidence`, `risk_level`, `security_impact`, `docs_impact`, `linked_systems`, `depends_on`, `supersedes`, `evidence`, `next_step`.
- `metadata_schema_version` versions the ShipFlow metadata format. `artifact_version` versions the document's decision content.
- Specs and implementation artifacts should record which business, brand, technical, API, or architecture artifact versions they depend on through `depends_on`.
- Version bump rules for `artifact_version`: patch = clarification/no decision change; minor = changed assumption/scope/audience/API/pricing/docs impact; major = incompatible product promise/business model/security posture/architecture direction.
- Draft or migrated artifacts start at `0.x.y`; first reviewed active contract should become `1.0.0`.
- If a dependency in `depends_on` is stale, missing, or newer than the version used by the spec, route through `/sf-docs audit` or `/sf-ready` before implementation/closure.
- Do not hide uncertainty. If proof is partial, metadata should say `confidence: medium|low`, `status: draft|partial|reviewed`, or `risk_level: medium|high`.
- Application content keeps its project schema. This includes `src/content/**`, blog posts, SEO pages, framework docs, MDX content, and any file parsed by the app runtime.
- Existing ShipFlow artifacts without metadata should be migrated to the standard schema during adoption or the next time the relevant skill touches them.
- `shipflow_data` is the control plane for trackers and registry files. Per-project business, brand, guideline, spec, research, and decision docs should live in the project repo, not in `shipflow_data`.

### Honest closure and shipping
- `sf-end`, `sf-review`, and `sf-ship` must distinguish "work tracked and summarized" from "product actually validated".
- A commit, push, changelog entry, or green lightweight check is not proof that the main user flow, security posture, or production behavior is correct.
- When closure or shipping status is ambiguous, the skill should ask a targeted question or explicitly report the remaining proof/doc gap.

### Audit and dependency posture
- `sf-audit` should orchestrate domain audits around linked systems, user outcomes, and downstream consequences, not just isolated file quality.
- `sf-deps` should treat dependency changes as product and security changes: supply chain, trust, runtime blast radius, and commercial license risk all matter.
- Business-facing audits should treat public promises as contracts: if GTM, copy, SEO, or design promises something the app/docs do not prove, the issue is material.

### One-pass rule
- A `ready` spec must let a fresh agent implement without reading the chat history.
- A `ready` spec must also make the user outcome and the security posture understandable without hidden assumptions.
- Specs now need explicit dependencies, linked systems / consequences, and execution notes.
- `sf-start` should choose a primary execution model before coding, using the shared `sf-model` routing reference.
- For non-trivial work, `sf-start` may choose `single-agent` or `multi-agent`; if `multi-agent` is chosen, write ownership and integration responsibility must be explicit.
- When a skill launches agents, the prompt should already include relevant context files and a no-follow-up rule.
- If the next step should run on fresh context and the environment cannot spawn it cleanly, the skill must ask the user to open a new thread.
- If that context cannot be made explicit, route back to `/sf-spec` or `/sf-ready` instead of coding.

### Shared tracking file protocol
- Shared files such as `~/shipflow_data/TASKS.md`, `~/shipflow_data/AUDIT_LOG.md`, `~/shipflow_data/PROJECTS.md`, and persistent workspace notes must never be edited from stale context.
- A read at skill start is informative only.
- Right before each write, the skill must re-read the target file from disk and use that version as authoritative.
- The write must be minimal and targeted to the intended row or subsection, never a whole-file rewrite.
- If the expected anchor moved, re-read once and recompute.
- If it is still ambiguous after the second read, stop and ask the user instead of forcing the write.
- Skills that only inspect these files must say they are read-only in that context.

### When prompts are skipped
Provide explicit arguments and prompts don't appear:
```bash
/sf-review weekly          # No scope prompt
/sf-audit-seo global      # No domain prompt (SEO only)
/sf-check typecheck        # No check selection prompt
```

---

## Multi-Project Tracking

### Architecture
```
~/TASKS.md              # Master tracker (symlink to shipflow_data)
~/AUDIT_LOG.md          # Audit history (symlink to shipflow_data)
~/shipflow_data/
├── TASKS.md            # Source of truth (12 projects)
├── AUDIT_LOG.md        # Cross-project audit scores
└── PROJECTS.md         # Project registry + domain matrix (8 domains)
```

### Rules
1. **Master file first**: `/sf-tasks`, `/sf-priorities`, `/sf-backlog` always update `~/TASKS.md`
2. **Local files too**: If a project has its own `TASKS.md`, update both
3. **Dashboard sync**: Update the Dashboard table when project phases change
4. **Prefix items**: Backlog entries include project name (e.g., `- tubeflow: Add dark mode`)

### TASKS vs BACKLOG convention
- `TASKS.md` = active, prioritized, executable work
- `BACKLOG.md` = deferred ideas and parking lot
- Promote from `BACKLOG.md` to `TASKS.md` only when the item is ready to be executed now

---

## Workflow Cycle

```
/sf-backlog  →  /sf-priorities  →  /sf-tasks  →  (work)  →  /sf-review
 capture               rank                    track               code        reflect
```

### Daily (5 min)
```bash
/sf-tasks                    # Morning: see what's next
# ... work ...
/sf-tasks                    # Evening: check off done items
```

### Weekly (15 min)
```bash
/sf-review weekly            # What happened this week
/sf-priorities               # Re-rank for next week
/sf-backlog review           # Promote ready items
/sf-backlog defer            # Clear non-urgent from active
```

### Sprint (30 min)
```bash
/sf-review sprint            # Comprehensive review
/sf-backlog clean            # Remove stale items
/sf-priorities impact        # Plan high-value work
```

### New project
```bash
/sf-init /path/to/project    # Bootstrap tracking
/sf-audit                    # Initial baseline audit
/sf-tasks                    # Start tracking work
```

### Ship something
```bash
/sf-ship "Feature description"  # Quick mode (default): commit + push
/sf-ship "end la tache"         # Full mode: updates tasks/changelog + commit + push
/sf-tasks                    # Mark completed, get next
```

### Choose execution model
```bash
/sf-model specs/my-spec.md      # Recommend Codex/OpenAI or Claude model + fallbacks
/sf-start specs/my-spec.md      # Reuses the same routing logic internally
```

### Fix a bug
```bash
/sf-bug BUG-2026-05-03-001      # Route the next step from bug-file status
/sf-fix "short bug description"    # Triage + direct fix or route
/sf-auth-debug "Google login returns to sign-in" # Reproduce auth flow and isolate the failure point
/sf-browser "https://example.com" "verify Example Domain is visible" # Collect non-auth browser evidence
# If local and clear -> fix now, then verify
# If ambiguous/non-trivial -> /sf-spec -> /sf-ready -> /sf-start
```

### Prepare context only
```bash
/sf-context "task description"      # Primes context, then asks what to do next
```

### Full deploy
```bash
/sf-deploy                   # Check → ship → prod → browser/manual proof → verify
# or
/sf-deploy skip-check        # Skip checks (use with caution)
/sf-deploy --preview         # Prefer preview/staging deploy proof
```

### Framework upgrade
```bash
/sf-migrate astro@5          # Research + plan + apply
/sf-check                    # Verify build
/sf-changelog                # Document the upgrade
/sf-ship                     # Commit and push
```

### Full audit
```bash
/sf-audit                    # All 8 domains, current project
/sf-audit global             # All 8 domains, all projects
/sf-audit-code               # Code only, current project
/sf-deps global              # Dependencies across all projects
/sf-perf @src/pages/index.astro  # Performance for one file
```

### Maintenance pass
```bash
/sf-maintain                 # Master maintenance lifecycle through verify and ship routing
/sf-maintain quick           # Read-only maintenance triage
/sf-maintain security        # Security maintenance lifecycle through remediation gates
```

### Content lifecycle
```bash
/sf-content                  # Route content work through map, editorial gates, owner skills, validation
/sf-content repurpose        # Turn source material into faithful docs/site/FAQ/content outputs
/sf-content audit seo        # Route public content through copy, copywriting, and SEO audits as needed
```

### Cross-project overview
```bash
/sf-status                   # Git status dashboard for all projects
```

---

## Priority Levels

| Level | Label | When to use |
|-------|-------|-------------|
| P0 | Critical | Blockers, security, high-ROI + bounded effort |
| P1 | High | Important features, medium effort |
| P2 | Medium | Standard work, nice improvements |
| P3 | Low | Nice-to-have, can wait |

---

## Audit Scoring

| Grade | Meaning |
|-------|---------|
| A | Excellent — no action needed |
| B | Good — minor improvements |
| C | Needs work — issues found and fixed |
| D | Poor — significant problems |

---

## File Reference

| File | Location | Purpose |
|------|----------|---------|
| `TASKS.md` | `~/` (master) + project dirs | Task tracking |
| `BACKLOG.md` | Project dirs | Deferred ideas |
| `AUDIT_LOG.md` | `~/` (master) + project dirs | Audit score history |
| `CHANGELOG.md` | Project dirs | Release notes |
| `REVIEW-*.md` | Project dirs | Review reports |
| `PROJECTS.md` | `~/shipflow/` | Project registry + domain matrix |

---

## Quick Answers

**Too many tasks?** → `/sf-priorities effort` then `/sf-backlog defer`

**Don't know what's next?** → `/sf-priorities blockers`

**New idea mid-work?** → `/sf-backlog add "description"`

**End of day?** → `/sf-tasks` then `/sf-review daily`

**Before deploy?** → `/sf-deploy` (runs check + ship + prod + proof routing + verify)

**Regular maintenance?** → `/sf-maintain` (triage + spec if needed + delegated fixes + verify + ship/deploy)

**Content work?** → `/sf-content` (content map + editorial gates + owner skills + validation)

**Bug has a BUG-ID?** → `/sf-bug BUG-ID` (routes fix, retest, verify, or ship risk from bug-file state)

**Audit everything?** → `/sf-audit global` (all 8 domains)

**Which projects need SEO?** → `/sf-audit-seo global` (auto-filters)

**New project?** → `/sf-init` (bootstrap tracking)

**Outdated dependencies?** → `/sf-deps` (full audit) or `/sf-check` (quick scan)

**Need to upgrade a framework?** → `/sf-migrate package@version`

**Generate docs?** → `/sf-docs readme` or `/sf-docs api`

**Research a topic?** → `/sf-research "topic"`

---

*Run `/sf-help` anytime for this reference.*
