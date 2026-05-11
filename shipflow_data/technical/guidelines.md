---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.4.0"
project: "shipflow"
created: "2026-04-26"
updated: "2026-05-11"
status: reviewed
source_skill: manual
scope: guidelines
owner: "unknown"
confidence: high
risk_level: medium
linked_systems:
  - "shipflow.sh"
  - "lib.sh"
  - "config.sh"
  - "local/"
  - "skills/"
  - "shipflow-spec-driven-workflow.md"
  - "templates/artifacts/"
  - "shipflow_data/technical/"
security_impact: yes
docs_impact: yes
evidence:
  - "CLAUDE.md and current repo structure define active shell, workflow, and metadata conventions"
  - "User decision 2026-04-29: standardize ShipFlow internal contracts in English and user-facing interaction in the user's active language."
  - "User decision 2026-05-11: root ShipFlow governance Markdown is not compliant; canonical project artifacts live under shipflow_data/."
depends_on: []
supersedes: []
next_review: "2026-05-26"
next_step: "/sf-docs audit shipflow_data/technical/guidelines.md"
---

# Technical Guidelines

## Scope Of This Document

This file defines stable engineering and documentation rules for working inside ShipFlow. It is not the place for product positioning, system topology walkthroughs, or public messaging.

## Stack

- Bash-first orchestration for CLI and operational flows.
- Flox for runtime isolation.
- PM2 for managed process execution.
- Caddy plus DuckDNS for public exposure.
- Markdown artifacts plus skills for workflow governance.

## Critical Rules

- Invalidate PM2 cache after PM2 state changes.
- Validate project paths before using them.
- Prefer idempotent operations over check-then-act races.
- Do not treat generated runtime config as primary source of truth.
- Keep documentation contracts versioned when they guide implementation or audits.
- Keep code-proximate technical docs aligned through `shipflow_data/technical/code-docs-map.md`.
- Follow the ShipFlow language doctrine: English for internal contracts, the user's active language for user-facing interaction.
- Keep ShipFlow governance artifacts under project-local `shipflow_data/`; root legacy governance files are migration sources only.

## Preferred Patterns

- Use focused context docs instead of overloading one mega-doc.
- Use `shipflow_data/technical/` for durable subsystem details instead of expanding `AGENT.md`, `shipflow_data/technical/context.md`, or `CLAUDE.md`.
- Use specs and verification for non-trivial work.
- Keep doc roles exclusive: route, context, business, product, GTM, architecture, brand, guidelines.
- Prefer explicit stop conditions over silent assumption repair.

## Anti-Patterns

- Silent success or silent failure in user-facing flows unless explicitly justified.
- Business or product claims without evidence.
- Metadata migration that rewrites content body unnecessarily.
- Treating root `BUSINESS.md`, `CONTEXT.md`, `CONTENT_MAP.md`, `GUIDELINES.md`, or similar ShipFlow governance files as compliant final locations.
- Using trackers as if they were decision contracts.
- Parallel edits to shared docs such as `shipflow_data/technical/code-docs-map.md`, `AGENT.md`, `shipflow_data/technical/context.md`, or workflow docs without explicit ready-spec ownership.
- Shipping code changes while mapped technical docs are known stale or missing.

## Validation Expectations

- Technical checks are necessary but not sufficient.
- User-facing success and error behavior should be observable or explicitly justified.
- Docs that affect product understanding must be checked when behavior changes.
- Mapped code changes require a `Documentation Update Plan` or an explicit no-impact justification.

## Change Routing

- Runtime orchestration changes belong first in `lib.sh`, `config.sh`, `shipflow.sh`, or `local/`.
- Workflow and artifact-governance changes belong first in `skills/`, templates, and workflow docs.
- Product, business, GTM, and brand decisions belong in their dedicated contracts before they are repeated elsewhere.
- Layout migration belongs in `sf-docs migrate-layout`; do not create new root governance files as a shortcut.

## Documentation Expectations

- `AGENT.md` routes to the right context.
- `shipflow_data/technical/context.md` maps the repo operationally.
- Specialized context docs stay narrow.
- `shipflow_data/technical/README.md` indexes subsystem technical docs.
- `shipflow_data/technical/code-docs-map.md` maps code paths to primary docs, validation, and docs update triggers.
- Every technical module doc needs owned files, entrypoints, invariants, validation, Reader checklist, and a maintenance rule.
- Business, product, GTM, brand, architecture, and guidelines docs should each keep an exclusive role in their canonical `shipflow_data/` locations.

## Technical Docs Maintenance

- `shipflow_data/technical/` is internal-only in v1.
- The Reader produces a `Documentation Update Plan` after every code-changing execution wave and again during end verification.
- The Reader diagnoses docs impact; an executor or integrator applies the docs update.
- Shared files stay sequential by default: `shipflow_data/technical/code-docs-map.md`, `AGENT.md`, `shipflow_data/technical/context.md`, `shipflow_data/technical/guidelines.md`, `shipflow-spec-driven-workflow.md`, and `tools/shipflow_metadata_lint.py`.
- Parallel technical-doc edits are allowed only when a ready spec defines disjoint file ownership.
- Technical docs may link to architecture, context, specs, and decisions, but must not copy their full content.
- Technical docs do not include per-file `last_verified_against` fields in v1.

## Language Doctrine

- ShipFlow internal contracts use English by default: `SKILL.md` instructions, workflow steps, YAML/frontmatter keys, stable section headings, acceptance criteria, stop conditions, validation notes, and technical documentation.
- User-facing interaction uses the user's active language: questions, short progress updates, final reports, and visible product copy should stay consistent with the language used by the user or configured for the project.
- French user-facing output must use proper accents and natural French. Do not write accentless French unless a technical identifier, command, slug, or ASCII-only file format requires it.
- Stable machine-readable labels stay English even inside otherwise localized content, for example `Status`, `Scope In`, `Acceptance Criteria`, `Skill Run History`, and command names such as `sf-build`.
- Do not mix languages casually inside one artifact. If an internal English document needs to show a user prompt, quote the prompt in the user's language and label it clearly.
- Legacy mixed-language artifacts do not require a broad migration. When editing a touched section, move it toward this doctrine without rewriting unrelated history.
- Preserve the original language of quoted user input, source evidence, legal text, or externally sourced material.

## Tracker Boundaries

- `${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}/TASKS.md` is the master cross-project tracker.
- `shipflow_data/workflow/TASKS.md` is the local repo tracker.
- `shipflow_data/workflow/AUDIT_LOG.md` is the local audit index/log.
- Root `TASKS.md` and `AUDIT_LOG.md` are legacy project tracker locations unless an external project tool explicitly requires them.
- A project section inside the master tracker is not the same thing as a local `shipflow_data/workflow/TASKS.md`.
- Local trackers should stay cleaner than the master tracker: active backlog first, optional historical completed context second.
- When creating a local tracker after project history already exists in the master tracker, import active work into the local backlog and move older completed items into a short historical section only if they are useful context.
