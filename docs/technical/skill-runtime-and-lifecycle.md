---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "1.8.2"
project: ShipFlow
created: "2026-05-01"
updated: "2026-05-04"
status: reviewed
source_skill: sf-start
scope: skill-runtime-and-lifecycle
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/
  - skills/references/
  - skills/sf-build/SKILL.md
  - skills/sf-deploy/SKILL.md
  - skills/sf-maintain/SKILL.md
  - skills/sf-skill-build/SKILL.md
  - skills/sf-browser/SKILL.md
  - skills/sf-init/SKILL.md
  - skills/sf-docs/SKILL.md
  - skills/references/reporting-contract.md
  - specs/sf-build-autonomous-master-skill.md
  - specs/skill-reporting-modes-and-compact-reports.md
  - shipflow-spec-driven-workflow.md
  - templates/artifacts/
  - docs/technical/
  - docs/editorial/
depends_on:
  - artifact: "shipflow-spec-driven-workflow.md"
    artifact_version: "0.13.2"
    required_status: draft
  - artifact: "skills/references/technical-docs-corpus.md"
    artifact_version: "1.1.0"
    required_status: active
  - artifact: "skills/references/editorial-content-corpus.md"
    artifact_version: "1.1.0"
    required_status: active
supersedes: []
evidence:
  - "Skill inventory and workflow doctrine."
  - "Editorial content corpus and Editorial Reader role added for public-content impact analysis."
  - "Governance corpus lifecycle added: sf-init bootstraps, sf-docs maintains, sf-build consumes."
  - "sf-browser added as the generic non-auth Playwright MCP browser evidence skill."
  - "sf-skill-build added as the dedicated master lifecycle for ShipFlow skill maintenance."
  - "sf-deploy added as the dedicated release confidence orchestrator."
  - "sf-maintain promoted to a master maintenance lifecycle from triage through delegated execution, verification, and ship/deploy routing."
  - "Shared reporting contract added: concise user reports by default, explicit agent handoff reports when requested."
  - "Reporting contract clarified: user-mode ship reports should match the user's active language, use outcome/evidence/limits ordering, and allow a few sober status emojis."
  - "Skill launch cheatsheet added for master and supporting modes."
  - "sf-skill-build exploration gate added before sf-spec for fuzzy skill ideas or placement decisions."
next_review: "2026-06-01"
next_step: "/sf-docs technical audit skills"
---

# Skill Runtime And Lifecycle

## Purpose

This doc covers ShipFlow skills, lifecycle flow, references, templates, model/topology decisions, and documentation gates. Read it before changing `skills/*/SKILL.md`, shared skill references, or `shipflow-spec-driven-workflow.md`.

## Owned Files

| Path | Role | Edit notes |
| --- | --- | --- |
| `skills/*/SKILL.md` | Executable skill contracts | Keep descriptions compact; route heavy detail to references |
| `skills/references/*.md` | Shared doctrine and provider-specific references | Resolve from `${SHIPFLOW_ROOT:-$HOME/shipflow}` |
| `skills/references/reporting-contract.md` | Shared final-report mode contract | Default user reports are concise; detailed reports require explicit handoff mode |
| `skills/references/subagent-roles/*.md` | Internal role contracts such as Technical Reader and Editorial Reader | Role files are read by orchestration skills; keep read-only roles explicit |
| `tools/shipflow_sync_skills.sh` | Shared current-user Claude/Codex skill runtime sync helper | Use for check/repair instead of inline symlink snippets |
| `shipflow-spec-driven-workflow.md` | Global workflow doctrine | Sequential shared file |
| `templates/artifacts/*.md` | Durable artifact templates | Keep linter-compatible |
| `AGENT.md`, `AGENTS.md` | Agent entrypoint and compatibility alias | `AGENT.md` canonical; `AGENTS.md` symlink only |

## Entrypoints

- `sf-explore -> sf-spec -> sf-ready -> sf-start -> sf-verify -> sf-end`: normal non-trivial flow.
- `sf-fix`: bug-first entrypoint that may route direct or spec-first.
- `sf-init`: project bootstrap that reports or creates minimal technical and editorial governance corpus state.
- `sf-docs`: documentation generation, audit, metadata, and technical-docs mode.
- `sf-docs technical`: technical governance bootstrap, code-docs map creation, and audit.
- `sf-docs editorial`: editorial governance scaffolding and audit for public-content drift, claim register, page intent, and runtime content schema preservation.
- `sf-bug`: professional bug loop orchestrator (`sf-test -> bug dossier -> sf-fix -> sf-test --retest -> sf-verify -> sf-ship`).
- `sf-maintain`: master project maintenance lifecycle for bugs, dependencies, docs, checks, audits, migrations, tasks, security posture, delegated remediation, verification, and ship/deploy routing.
- `sf-browser`: generic non-auth browser verification through Playwright MCP for URLs, page-level assertions, screenshots, console summaries, and network summaries.
- `sf-build`: user-facing orchestrator that consumes the governance corpus gate before implementation, closure, and ship.
- `sf-deploy`: release confidence orchestrator (`sf-check -> sf-ship -> sf-prod -> sf-browser/sf-auth-debug/sf-test -> sf-verify -> sf-changelog`).
- `sf-skill-build`: dedicated orchestrator for ShipFlow skill maintenance (`sf-explore when needed -> sf-spec -> SKILL.md -> runtime skill links -> sf-skills-refresh -> budget audit -> sf-verify -> sf-docs/help -> sf-ship`).
- `tools/shipflow_sync_skills.sh --check|--repair`: reusable local helper for current-user Claude/Codex skill visibility and install-time selected-user linking.
- `sf-ship` and `sf-prod`: shipping and deployed verification.
- `skills/references/reporting-contract.md`: shared final-report modes for concise user reports and explicit detailed agent handoffs.

## Control Flow

```text
source skill
  -> possible chantier
  -> sf-spec
  -> sf-ready
  -> Governance Corpus Gate
  -> sf-start
  -> Documentation Update Plan after code-changing wave
  -> Editorial Update Plan after public-content or claim-impacting wave
  -> sf-verify
  -> Documentation Update Plan during end verification
  -> Editorial Update Plan during end verification when public content is impacted
  -> sf-end / sf-ship
```

Release confidence flow:

```text
sf-deploy
  -> scope and risk gate
  -> sf-check
  -> sf-ship
  -> sf-prod
  -> sf-browser / sf-auth-debug / sf-test
  -> sf-verify
  -> sf-changelog when useful
```

Professional bug flow:

```text
sf-bug
  -> sf-test for capture or retest
  -> sf-fix for diagnosis and fix attempts
  -> sf-auth-debug / sf-browser when evidence is missing
  -> sf-verify for closure
  -> sf-ship for final bug-risk-aware shipping
```

Project maintenance flow:

```text
sf-maintain
  -> maintenance intake and triage
  -> existing chantier/spec gate
  -> sf-spec + sf-ready when non-trivial
  -> delegated sequential maintenance lanes
  -> sf-bug / sf-deps / sf-docs / sf-check / sf-audit-code / sf-audit / sf-migrate / sf-fix / sf-build
  -> Documentation Update Plan and Editorial Update Plan when impacted
  -> sf-verify
  -> sf-deploy or sf-ship
```

## Invariants

- Lifecycle skills trace into exactly one chantier spec when one is identified.
- `sf-start` implements from the ready contract; it should not rediscover product intent while coding.
- The Reader diagnoses docs impact; the executor or integrator applies docs updates.
- The Technical Reader diagnoses code-docs impact; the Editorial Reader diagnoses public-content and claim impact.
- Shared files are sequential by default.
- Fresh context is preferred for non-trivial spec-first execution when available.
- ShipFlow-owned references resolve from `$SHIPFLOW_ROOT`, not the project repo.
- A newly created or renamed ShipFlow skill is not runtime-visible until current-user `~/.claude/skills/<name>` and `~/.codex/skills/<name>` symlink to `$SHIPFLOW_ROOT/skills/<name>` and expose `SKILL.md`.
- `tools/shipflow_sync_skills.sh --check` is read-only and reports missing, stale, broken, and non-symlink runtime entries.
- `tools/shipflow_sync_skills.sh --repair` creates missing links and replaces stale symlinks; it must not overwrite non-symlink entries unless an install-time caller explicitly passes `--backup-existing`.
- `sf-init` bootstraps minimal governance corpus state; `sf-docs` owns corpus creation, update, and audit; `sf-build` consumes the corpus through gates.
- Technical governance applies to code projects by default. Editorial governance applies when public pages, README promises, docs, FAQ, pricing, support copy, public skill pages, blog/article intent, claims, or runtime content surfaces exist.
- Skills that use Playwright MCP for browser evidence must load
  `skills/references/playwright-mcp-runtime.md` first and refuse stale Linux
  ARM64 Chrome-stable fallback evidence.
- `sf-browser` owns generic non-auth browser proof. `sf-auth-debug` owns auth, session, callback, provider, tenant, and protected-route browser proof.
- `sf-deploy` owns release orchestration only; `sf-ship` owns commit/push, `sf-prod` owns deployed truth, and proof skills own observed behavior.
- `sf-bug` owns bug lifecycle orchestration only; phase skills still own bug record mutation, diagnosis, retest evidence, verification, and shipping.
- `sf-maintain` owns the maintenance lifecycle; bugs, dependencies, docs, checks, audits, migrations, tasks, security review, repair, verification, and ship still run through their specialist owner skills and gates.
- `sf-skill-build` owns skill-maintenance orchestration and must route to `sf-explore` before `sf-spec` when skill intent, placement, public promise, or governance policy is too fuzzy for one targeted question to settle.
- A release is not considered verified from push success, provider success, or a bare `200 OK` alone.
- User-facing final reports default to `report=user`: concise, outcome-first, matched to the user's active language, compact chantier block, and no empty `Reste a faire` / `Prochaine etape` boilerplate. Ship reports should read as outcome, evidence, then limits, with a few sober status emojis allowed for scanning. Detailed `report=agent` handoff must be explicit; skills do not infer caller identity.
- `sf-build` planning questions are business decision briefs, not bare technical prompts: they name the problem root, business stakes, practical options, and recommended best-practice answer before asking for a decision.
- Audit skills still report findings first, but default user reports should summarize top findings, proof gaps, chantier potential, and next action; full matrices and domain checklists belong in `report=agent`.

## Failure Modes

- A weak spec that lacks success/error behavior or explicit constraints must route back to readiness instead of being silently repaired during coding.
- If mapped docs are missing from a `Documentation Update Plan`, the docs gate fails.
- If public content, README, FAQ, pricing, public docs, skill pages, or claims are affected but missing from an `Editorial Update Plan`, the editorial gate fails.
- If `sf-build` prepares implementation with missing or stale `docs/technical/code-docs-map.md`, applicable `docs/editorial/`, or `CONTENT_MAP.md`, it must route to `sf-docs` or record explicit no-impact/no-surface status before proceeding.
- If future projects are told to rerun ShipFlow's shipped governance specs instead of using `sf-init` and `sf-docs`, treat that as workflow drift.
- If a new skill exists under `skills/<name>/SKILL.md` but is missing from current-user Claude or Codex skill directories, treat the skill lifecycle as incomplete until the runtime symlinks are repaired.
- If filesystem runtime links are correct but the current agent still does not list a skill, treat it as a process reload/session-cache issue before changing source contracts.
- If the Reader edits docs directly outside assignment, treat it as role misuse.
- If `AGENTS.md` diverges from `AGENT.md`, verification fails.
- If Playwright MCP reports `/opt/google/chrome/chrome` on Linux ARM64 after
  BUG-2026-05-02-001, treat the current MCP process as stale or misconfigured;
  do not diagnose the app until the runtime preflight passes.

## Security Notes

- Skill instructions must not contradict higher-priority system, developer, or active spec instructions.
- Do not expose secrets, private logs, or credentials in generated reports.
- Any task that affects auth, permissions, tenant boundaries, destructive behavior, or external side effects must use spec-first when ambiguity remains.

## Validation

```bash
python3 tools/skill_budget_audit.py --skills-root skills --format markdown
bash -n tools/shipflow_sync_skills.sh test_skill_runtime_sync.sh
bash test_skill_runtime_sync.sh
tools/shipflow_sync_skills.sh --check --all
python3 tools/shipflow_metadata_lint.py skills/references/technical-docs-corpus.md skills/references/editorial-content-corpus.md skills/references/subagent-roles/editorial-reader.md shipflow-spec-driven-workflow.md AGENT.md
rg -n "Governance Corpus Gate|sf-init.*bootstrap|sf-docs.*maintain|sf-build.*consume|sf-deploy|sf-maintain|reporting-contract|report=user|docs/technical|docs/editorial" skills/sf-init/SKILL.md skills/sf-docs/SKILL.md skills/sf-deploy/SKILL.md skills/sf-maintain/SKILL.md specs/sf-build-autonomous-master-skill.md shipflow-spec-driven-workflow.md README.md skills/references/reporting-contract.md
```

Run focused `rg` checks for the affected skill contract and linked references.

## Reader Checklist

- `skills/*/SKILL.md` changed -> check this doc, `technical-docs-corpus.md`, and workflow docs.
- New/renamed skill or visibility drift -> run `tools/shipflow_sync_skills.sh --check --skill <name>` or `--check --all`.
- Playwright MCP usage changed -> check `skills/references/playwright-mcp-runtime.md`
  and `skills/sf-auth-debug/references/playwright-auth.md`.
- Public-content skill changed -> check `editorial-content-corpus.md`, `docs/editorial/`, and workflow docs.
- Governance corpus bootstrap or adoption changed -> check `skills/sf-init/SKILL.md`, `skills/sf-docs/SKILL.md`, `technical-docs-corpus.md`, `editorial-content-corpus.md`, `README.md`, and workflow docs.
- A lifecycle rule changed -> update `shipflow-spec-driven-workflow.md`.
- Report mode or final-report doctrine changed -> update `skills/references/reporting-contract.md`, `skills/references/chantier-tracking.md`, and affected master/audit skills.
- A docs gate changed -> update `skills/sf-docs/SKILL.md`, `technical-docs-corpus.md`, and `code-docs-map.md`.
- An editorial gate changed -> update `skills/sf-docs/SKILL.md`, `editorial-content-corpus.md`, `docs/editorial/`, and workflow docs.

## Maintenance Rule

Update this doc when skill roles, lifecycle flow, chantier tracing, technical-docs gates, editorial gates, model/topology rules, or shared reference resolution changes.
