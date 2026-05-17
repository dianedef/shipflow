---
artifact: audit_report
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "shipflow"
created: "2026-05-17"
updated: "2026-05-17"
status: reviewed
source_skill: sf-start
scope: "skill-taxonomy-and-discovery-descriptions"
owner: "Diane"
confidence: medium
risk_level: high
security_impact: yes
docs_impact: yes
domains: ["skills", "workflow", "documentation-governance"]
issue_counts: {"hard_blockers": 0, "future_specs": 3, "low_risk_description_edits": 56}
evidence:
  - "Generated inventory from skills/*/SKILL.md on 2026-05-17."
  - "Baseline skill budget audit: 61 skills, 0 hard violations, 0 warnings, 0 body-size risks, absolute estimate 7988/8000, repo-relative estimate 6646/8000, average description length 70.7."
  - "Local transcript /home/claude/docs_update_skill_bug.md showed sf-docs update-mode work missed a governance-layout migration gate."
  - "Local transcript /home/claude/sf-build-subagents-ex.md was inspected and contained no actionable routing signal."
  - "sf-verify 2026-05-17 checked skill budget, runtime sync, metadata, role labels, and description uniqueness."
depends_on:
  - artifact: "shipflow_data/workflow/specs/audit-and-compact-skill-taxonomy-descriptions.md"
    artifact_version: "1.0.3"
    required_status: "ready"
supersedes: []
next_step: "None"
---

# Skill Taxonomy Description Audit

## Scope Understood

This audit covers the discovery descriptions and declared chantier roles for all 61 `skills/*/SKILL.md` files. It does not delete, rename, merge, or change invocation keys.

Success means the descriptions become clearer routing triggers, not only shorter strings. High-risk consolidation remains a recommendation for separate specs.

## Baseline

- Skills: 61
- Hard violations: 0
- Warnings: 0
- Body-size risks: 0
- Description characters: 4310
- Average description length: 70.7
- Absolute discovery estimate: 7988 / 8000
- Repo-relative discovery estimate: 6646 / 8000
- Longest descriptions: 80-96 characters, already under hard limits but too close to the fallback absolute budget.

## Applied Result

- Edited descriptions: 56
- Skills kept unchanged: 5
- Description characters: 3127
- Average description length: 51.3
- Absolute discovery estimate: 6805 / 8000
- Repo-relative discovery estimate: 5463 / 8000
- Validation status at edit time: 0 hard violations, 0 warnings, 0 body-size risks.

## Family Map

- Lifecycle/master: `sf-spec`, `sf-ready`, `sf-start`, `sf-verify`, `sf-end`, `sf-ship`, `sf-build`, `sf-deploy`, `sf-maintain`, `sf-design`, `sf-content`, `sf-skill-build`.
- Audit/source: `sf-audit*`, `sf-deps`, `sf-perf`.
- Bug/proof/source: `sf-bug`, `sf-fix`, `sf-test`, `sf-browser`, `sf-auth-debug`, `sf-prod`, `sf-check`, `sf-migrate`.
- Content/docs/support: `sf-docs`, `sf-redact`, `sf-enrich`, `sf-repurpose`, `sf-changelog`, `sf-scaffold`, `sf-skills-refresh`, `sf-init`.
- Research/strategy/source: `sf-research`, `sf-market-study`, `sf-veille`.
- Pilotage: `sf-backlog`, `sf-priorities`, `sf-review`, `sf-tasks`, `continue`.
- Helper/session/router: `shipflow`, `sf-context`, `sf-model`, `sf-help`, `sf-status`, `sf-resume`, `sf-explore`, `name`, `tmux-capture-conversation`, `clean-conversation-transcript`.

## Overlap Findings

- `sf-build` vs `sf-start`: keep both. `sf-build` owns story-to-ship orchestration; `sf-start` executes a ready spec or clear local task.
- `sf-deploy` vs `sf-ship` vs `sf-prod`: keep all. `sf-deploy` orchestrates release confidence; `sf-ship` commits/pushes; `sf-prod` verifies deployed truth.
- `sf-maintain` vs `sf-bug` vs `sf-fix`: keep all. `sf-maintain` owns project maintenance; `sf-bug` owns the bug lifecycle; `sf-fix` triages and repairs failing behavior.
- `sf-test` vs `sf-browser` vs `sf-auth-debug`: keep all. `sf-test` owns manual QA and bug capture; `sf-browser` owns non-auth browser evidence; `sf-auth-debug` owns auth/session/provider proof.
- `sf-docs` vs content skills: keep all. `sf-docs` owns documentation and governance layout; `sf-redact`, `sf-enrich`, and `sf-repurpose` own content production and transformation.
- `sf-audit-copy` vs `sf-audit-copywriting`: keep both for now. `sf-audit-copy` evaluates product/interface copy; `sf-audit-copywriting` evaluates offer and persuasion.
- `sf-design`, `sf-audit-design`, `sf-design-from-scratch`, `sf-design-playground`, `sf-audit-design-tokens`, `sf-audit-components`, `sf-audit-a11y`: keep all. The descriptions must distinguish orchestration, audits, creation, and tooling.
- `sf-research`, `sf-market-study`, `sf-veille`: keep all. `sf-research` produces cited reports; `sf-market-study` answers demand/competition/monetization; `sf-veille` triages sources into actions.

## Transcript Failure Modes

- `sf-docs` failure: `/home/claude/docs_update_skill_bug.md` shows a docs update concluded after README/docs refresh while missing root legacy artifacts and mixed docs layout. Root cause: the discovery description only advertised README/API/component/metadata drift, while the actual role includes governance-layout compliance and `migrate-layout`. Decision: clarify `sf-docs` description to mention governance-layout compliance. Future hardening may need a separate spec if update-mode gate wording still allows local-only success.
- `sf-build` transcript: `/home/claude/sf-build-subagents-ex.md` contains only capture metadata and no actionable routing failure. Decision: no change.

## Decision Matrix

| Skill | Family | Trace / role | Lines / tokens | Chars | Decision | Target description |
| --- | --- | --- | ---: | ---: | --- | --- |
| `clean-conversation-transcript` | helper/session | non-applicable / helper | 143 / 1423 | 77 -> 52 | shorten | Clean tmux/Codex transcripts into readable Markdown. |
| `continue` | pilotage | conditionnel / pilotage | 194 / 2219 | 51 -> 44 | shorten | Resume paused work and report the next step. |
| `name` | helper/session | non-applicable / helper | 47 / 467 | 67 -> 35 | shorten | Name or rename the current session. |
| `sf-audit` | audit | conditionnel / source-de-chantier | 67 / 876 | 69 -> 55 | shorten | Audit product, code, design, SEO, GTM, and performance. |
| `sf-audit-a11y` | audit | conditionnel / source-de-chantier | 67 / 869 | 20 -> 20 | keep | Accessibility audit. |
| `sf-audit-code` | audit | conditionnel / source-de-chantier | 67 / 845 | 89 -> 58 | shorten | Audit code correctness, security, architecture, and tests. |
| `sf-audit-components` | audit | conditionnel / source-de-chantier | 342 / 4963 | 23 -> 23 | keep | Component system audit. |
| `sf-audit-copy` | audit | conditionnel / source-de-chantier | 67 / 870 | 68 -> 51 | shorten | Audit copy clarity, tone, conversion, and friction. |
| `sf-audit-copywriting` | audit | conditionnel / source-de-chantier | 67 / 845 | 68 -> 53 | shorten | Audit marketing copy, offer, persona, and persuasion. |
| `sf-audit-design` | audit | conditionnel / source-de-chantier | 87 / 1086 | 19 -> 19 | keep | UI/UX design audit. |
| `sf-audit-design-tokens` | audit | conditionnel / source-de-chantier | 323 / 4483 | 31 -> 26 | shorten | Design-token system audit. |
| `sf-audit-gtm` | audit | conditionnel / source-de-chantier | 67 / 877 | 90 -> 55 | shorten | Audit positioning, funnel, offer, and growth readiness. |
| `sf-audit-seo` | audit | conditionnel / source-de-chantier | 69 / 971 | 67 -> 53 | shorten | Audit SEO health, metadata, indexing, and intent fit. |
| `sf-audit-translate` | audit | conditionnel / source-de-chantier | 429 / 4790 | 85 -> 58 | shorten | Audit translation quality, i18n sync, and missing strings. |
| `sf-auth-debug` | bug/proof | conditionnel / source-de-chantier | 67 / 892 | 87 -> 52 | shorten | Debug auth, OAuth, cookies, callbacks, and sessions. |
| `sf-backlog` | pilotage | conditionnel / pilotage | 140 / 1595 | 76 -> 49 | shorten | Triage backlog ideas, deferred work, and cleanup. |
| `sf-browser` | bug/proof | conditionnel / source-de-chantier | 216 / 2480 | 74 -> 62 | shorten | Check non-auth pages with browser, console, and network proof. |
| `sf-bug` | bug/proof | conditionnel / source-de-chantier | 264 / 3721 | 89 -> 66 | shorten | Bug lifecycle for intake, dossiers, fixes, retests, and ship risk. |
| `sf-build` | lifecycle/master | obligatoire / lifecycle | 358 / 4442 | 77 -> 49 | shorten | Orchestrate story-to-ship product implementation. |
| `sf-changelog` | docs/support | conditionnel / support-de-chantier | 137 / 1436 | 73 -> 57 | shorten | Generate grouped Keep a Changelog notes from git history. |
| `sf-check` | bug/proof | conditionnel / source-de-chantier | 168 / 2675 | 73 -> 56 | shorten | Technical checks for typecheck, lint, build, and repair. |
| `sf-content` | content/docs | obligatoire / lifecycle | 271 / 3813 | 18 -> 18 | keep | Content lifecycle. |
| `sf-context` | helper/session | non-applicable / helper | 83 / 739 | 89 -> 56 | shorten | Prime task context with cached memory and focused files. |
| `sf-deploy` | lifecycle/master | obligatoire / lifecycle | 288 / 3232 | 76 -> 60 | shorten | Orchestrate release checks, ship, deploy, proof, and verify. |
| `sf-deps` | audit | conditionnel / source-de-chantier | 317 / 4106 | 66 -> 55 | shorten | Audit dependency security, drift, licenses, and config. |
| `sf-design` | lifecycle/master | obligatoire / lifecycle | 269 / 3091 | 24 -> 23 | shorten | UI/UX design lifecycle. |
| `sf-design-from-scratch` | design/support | conditionnel / source-de-chantier | 297 / 3427 | 40 -> 40 | keep | Design-system creation from existing UI. |
| `sf-design-playground` | design/support | conditionnel / support-de-chantier | 307 / 3843 | 41 -> 40 | shorten | Scaffold a live design-token playground. |
| `sf-docs` | content/docs | conditionnel / support-de-chantier | 97 / 1208 | 93 -> 58 | clarify description | Maintain docs, metadata, and governance-layout compliance. |
| `sf-end` | lifecycle/master | obligatoire / lifecycle | 181 / 2320 | 79 -> 57 | shorten | Close tasks with summaries, trackers, and changelog prep. |
| `sf-enrich` | content/docs | conditionnel / support-de-chantier | 63 / 835 | 71 -> 61 | shorten | Enrich content with research, user focus, and conversion fit. |
| `sf-explore` | helper/session | non-applicable / helper | 260 / 2554 | 80 -> 56 | shorten | Explore ideas, problems, and requirements before coding. |
| `sf-fix` | bug/proof | conditionnel / source-de-chantier | 293 / 4618 | 82 -> 58 | shorten | Triage and repair bugs, regressions, and failing behavior. |
| `sf-help` | helper/session | non-applicable / helper | 66 / 822 | 88 -> 63 | shorten | Answer ShipFlow skills, workflows, modes, and prompt questions. |
| `sf-init` | docs/support | conditionnel / support-de-chantier | 62 / 762 | 89 -> 61 | shorten | Bootstrap ShipFlow tracking, stack detection, and registries. |
| `sf-maintain` | lifecycle/master | obligatoire / lifecycle | 291 / 4216 | 89 -> 52 | shorten | Orchestrate project maintenance from triage to ship. |
| `sf-market-study` | research/strategy | conditionnel / source-de-chantier | 67 / 893 | 84 -> 57 | shorten | Research demand, competitors, keywords, and monetization. |
| `sf-migrate` | bug/proof | conditionnel / source-de-chantier | 198 / 1895 | 64 -> 55 | shorten | Plan framework upgrades and breaking-change migrations. |
| `sf-model` | helper/session | non-applicable / helper | 187 / 2236 | 66 -> 53 | shorten | Route models for ShipFlow tasks and reasoning levels. |
| `sf-perf` | audit | conditionnel / source-de-chantier | 404 / 4601 | 88 -> 63 | shorten | Audit bundles, rendering, Core Web Vitals, data, and databases. |
| `sf-priorities` | pilotage | conditionnel / pilotage | 128 / 1535 | 96 -> 53 | shorten | Prioritize work by impact, effort, blockers, and ROI. |
| `sf-prod` | bug/proof | conditionnel / source-de-chantier | 67 / 907 | 87 -> 59 | shorten | Verify production deploys, logs, health, and live behavior. |
| `sf-ready` | lifecycle/master | obligatoire / lifecycle | 319 / 4423 | 83 -> 58 | shorten | Validate spec readiness, user-story fit, and secure scope. |
| `sf-redact` | content/docs | conditionnel / support-de-chantier | 63 / 847 | 69 -> 62 | shorten | Draft long-form articles, guides, editorials, and brand voice. |
| `sf-repurpose` | content/docs | conditionnel / support-de-chantier | 67 / 918 | 91 -> 62 | shorten | Repurpose sources into docs, marketing, FAQs, or site updates. |
| `sf-research` | research/strategy | conditionnel / source-de-chantier | 157 / 1397 | 83 -> 59 | shorten | Research web and local sources into cited Markdown reports. |
| `sf-resume` | helper/session | non-applicable / helper | 146 / 1351 | 84 -> 55 | shorten | Summarize session state, task status, and next actions. |
| `sf-review` | pilotage | conditionnel / pilotage | 199 / 2516 | 60 -> 56 | shorten | Review session changes, docs, summaries, and next steps. |
| `sf-scaffold` | docs/support | conditionnel / support-de-chantier | 205 / 2910 | 85 -> 57 | shorten | Scaffold pages, components, routes, hooks, and utilities. |
| `sf-ship` | lifecycle/master | obligatoire / lifecycle | 304 / 4066 | 75 -> 59 | shorten | Ship with checks, commits, pushes, and closure when needed. |
| `sf-skill-build` | lifecycle/master | obligatoire / lifecycle | 320 / 3766 | 61 -> 58 | shorten | Maintain ShipFlow skills from spec to validation and ship. |
| `sf-skills-refresh` | docs/support | conditionnel / support-de-chantier | 164 / 2514 | 82 -> 65 | shorten | Refresh skills against current practice and conservative updates. |
| `sf-spec` | lifecycle/master | obligatoire / lifecycle | 68 / 1152 | 81 -> 59 | shorten | Write specs with user stories, contracts, risks, and plans. |
| `sf-start` | lifecycle/master | obligatoire / lifecycle | 76 / 1357 | 78 -> 57 | shorten | Execute ready specs or clear local tasks with guardrails. |
| `sf-status` | helper/session | non-applicable / helper | 122 / 1289 | 78 -> 56 | shorten | Report cross-project git status, sync state, and issues. |
| `sf-tasks` | pilotage | conditionnel / pilotage | 201 / 2705 | 82 -> 44 | shorten | Update task trackers and suggest next steps. |
| `sf-test` | bug/proof | conditionnel / source-de-chantier | 447 / 4768 | 74 -> 42 | shorten | Manual QA, retests, logs, and bug capture. |
| `sf-veille` | research/strategy | conditionnel / source-de-chantier | 274 / 3291 | 65 -> 44 | shorten | Triage business veille sources into actions. |
| `sf-verify` | lifecycle/master | obligatoire / lifecycle | 111 / 1197 | 72 -> 56 | shorten | Verify ship readiness, correctness, coherence, and risk. |
| `shipflow` | helper/router | non-applicable / helper | 171 / 2096 | 43 -> 36 | shorten | Route requests to skills or answers. |
| `tmux-capture-conversation` | helper/session | non-applicable / helper | 96 / 1295 | 81 -> 51 | shorten | Capture tmux panes to cleaned Markdown transcripts. |

## High-Risk Decisions Requiring Separate Specs

- Possible consolidation of copy audit roles (`sf-audit-copy` and `sf-audit-copywriting`) should stay out of this chantier because public promises and routing behavior would change.
- Possible consolidation inside the design family should stay out of this chantier because the current split separates orchestration, audit, token tooling, component audit, accessibility, and design-system creation.
- `sf-docs update` gate hardening may deserve a separate spec if future runs still complete local docs refreshes without escalating governance-layout migration.

## Risky Assumptions / Proof Gaps

- The inventory uses local `skills/*/SKILL.md` only; runtime usage frequency is not measured.
- The proposed descriptions intentionally keep a few longer strings where shorter wording would blur family boundaries.
- No direct Claude/Codex picker retest is possible inside this static pass; validation relies on budget audit, runtime symlink check, role-label grep, and family review.

## Recommended Next Step

Apply only the listed description edits, update internal lifecycle docs and changelog for the taxonomy/description pass, then run the budget audit, runtime sync check, metadata lint on changed artifacts, and focused role-label checks.
