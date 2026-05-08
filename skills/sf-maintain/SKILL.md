---
name: sf-maintain
description: "Master maintenance lifecycle from triage through delegated fixes, verification, and ship."
argument-hint: [optional: quick | full | security | deps | docs | audits | global | no-ship | report=agent]
---

## Canonical Paths

Before resolving any ShipFlow-owned file, load `$SHIPFLOW_ROOT/skills/references/canonical-paths.md` (`$SHIPFLOW_ROOT` defaults to `$HOME/shipflow`). ShipFlow tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPFLOW_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Chantier Tracking

Trace category: `obligatoire`.
Process role: `lifecycle`.

Before executing, load `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md`. Search for a matching active `specs/*.md` chantier. If exactly one chantier owns the maintenance scope, append the current `sf-maintain` run to `Skill Run History`, update `Current Chantier Flow`, and include the compact `Chantier` block from `$SHIPFLOW_ROOT/skills/references/reporting-contract.md`.

If no matching chantier exists and the maintenance work is non-trivial, run or route through `sf-spec` and `sf-ready` before implementation. If the work is a narrow local fix safe without a full spec, write a short maintenance mini-contract in the final report and continue in delegated sequential mode. If multiple specs plausibly match, ask the user to select one.

## Report Modes

Before producing the final report, load `$SHIPFLOW_ROOT/skills/references/reporting-contract.md`.

Default to `report=user`: concise, lifecycle-result first, and using the compact chantier block. Use `report=agent`, `handoff`, `verbose`, or `full-report` for detailed evidence matrices or downstream handoff.

## Master Delegation

Before choosing execution topology, load `$SHIPFLOW_ROOT/skills/references/master-delegation-semantics.md`.

This skill follows that reference; local nuances below only narrow or route it. Maintenance defaults to delegated sequential for triage, repair, docs, checks, validation, integration, and ship preparation when subagents are available; parallel maintenance remains gated by ready `Execution Batches`.

## Master Workflow Lifecycle

Before resolving maintenance phases, load `$SHIPFLOW_ROOT/skills/references/master-workflow-lifecycle.md`.

Use the shared skeleton for intake, work item resolution, readiness, model/topology routing, owner-skill execution, validation, verification, and post-verify ship/deploy routing. Local sections below define maintenance lanes and owner routes only.

## Context

- Current directory: !`pwd`
- Current date: !`date '+%Y-%m-%d'`
- Project name: !`basename $(pwd)`
- Git status: !`git status --short 2>/dev/null || echo "Not a git repo"`
- ShipFlow development mode: !`rg -n "ShipFlow Development Mode|development_mode|validation_surface|ship_before_preview_test|post_ship_verification|deployment_provider" CLAUDE.md SHIPFLOW.md 2>/dev/null || echo "No project development mode documented"`
- Package manager signals: !`ls -1 package.json package-lock.json yarn.lock pnpm-lock.yaml requirements.txt Pipfile.lock pyproject.toml 2>/dev/null || echo "none"`
- Package scripts: !`node -e "const p=require('./package.json'); console.log(JSON.stringify(p.scripts||{}, null, 2))" 2>/dev/null || echo "no package.json scripts"`
- Bug files: !`find bugs -maxdepth 1 -type f -name "BUG-*.md" 2>/dev/null | sort | tail -40 || echo "No bugs directory"`
- Optional bug triage view: !`tail -80 BUGS.md 2>/dev/null || echo "No BUGS.md"`
- Recent tests: !`tail -60 TEST_LOG.md 2>/dev/null || echo "No TEST_LOG.md"`
- Local tasks: !`head -80 TASKS.md 2>/dev/null || echo "No local TASKS.md"`
- Audit log: !`tail -80 AUDIT_LOG.md 2>/dev/null || tail -80 ${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}/AUDIT_LOG.md 2>/dev/null || echo "No AUDIT_LOG.md"`
- Active specs: !`find specs -maxdepth 1 -type f -name "*.md" 2>/dev/null | sort | head -60 || echo "No specs directory"`
- Docs governance: !`ls -1 AGENT.md AGENTS.md CLAUDE.md CONTEXT.md CONTENT_MAP.md docs/technical/code-docs-map.md docs/editorial/claim-register.md SECURITY.md .env.example 2>/dev/null || echo "none"`

## Mission

`sf-maintain` is the project maintenance master skill.

It answers one operational question:

```text
What maintenance work needs to be handled, and how do we carry it through to verified, shippable completion?
```

The goal is not another report. `sf-maintain` should keep the operator out of command-stitching by piloting maintenance intake, spec/readiness when needed, bounded delegated execution, verification, and ship/deploy routing.

## Ownership Boundaries

Orchestrate existing skills; do not duplicate their internals.

- `sf-bug` owns bug lifecycle execution, bug files, retests, verification, and ship risk.
- `sf-deps` owns dependency health, vulnerabilities, supply chain, licenses, drift, and config.
- `sf-docs` owns documentation update/audit, metadata, technical corpus, editorial corpus, and stale-doc repair.
- `sf-check` owns local typecheck, lint, build, tests, and quick dependency checks.
- `sf-audit` owns broad multi-domain audits.
- `sf-audit-code` owns code, architecture, reliability, and security review.
- `sf-migrate` owns framework/package upgrade migrations and breaking-change work.
- `sf-tasks` owns tracker reconciliation and durable task updates.
- `sf-fix`, `sf-build`, and `sf-deploy` own repair, feature work, and release execution.
- `sf-spec`, `sf-ready`, `sf-start`, `sf-verify`, `sf-end`, and `sf-ship` own lifecycle gates.

`sf-maintain` may execute through these owner skills and bounded subagents. It must not silently bypass their gates, but it should not stop at recommendations when the user asked maintenance to be handled.

## Execution Modes

### `main-only`

Use only for pure conversation, explicit `quick` read-only triage, or a `global` dashboard before the user selects target projects.

### `delegated sequential` (default)

`/sf-maintain` or `$sf-maintain` is explicit bounded maintenance delegation consent for the current project. Apply the shared master delegation semantics for short approvals, mini-contracts, degradation, and subagent boundaries.

Load these role contracts from `$SHIPFLOW_ROOT/skills/references/subagent-roles/` when delegating:

- `technical-reader.md` for read-only technical documentation impact
- `editorial-reader.md` for read-only public-content and claim impact
- `sequential-executor.md` for one bounded write mission at a time
- `integrator.md` for cross-output coherence before verification and ship

### `spec-gated parallel`

Allowed only when the ready maintenance spec defines safe `Execution Batches` with:

- non-overlapping write ownership
- dependency order
- per-batch validation
- integration owner

Without explicit safe batches, parallelism is blocked.

## Mode Detection

Parse `$ARGUMENTS`:

- empty -> run the master maintenance lifecycle for the current project.
- `quick` -> read-only maintenance triage only; do not create specs, edit files, or ship.
- `full` -> run the broad maintenance lifecycle with deeper audit/check/dependency/docs lanes.
- `security` -> run the security maintenance lifecycle: bug risk, dependency vulnerability posture, secret/config hygiene, auth/permission surfaces, code-security review, remediation when safe, verification, and ship/deploy routing.
- `deps` -> run the dependency maintenance lane through `sf-deps`, remediation/migration when needed, verification, and ship routing.
- `docs` -> run the docs/governance maintenance lane through `sf-docs`, validation, verification, and ship routing.
- `audits` -> run the audit maintenance lane through `sf-audit` or narrower audit skills, then remediation lifecycle for findings that cross the implementation threshold.
- `global` -> workspace maintenance dashboard using `${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}/PROJECTS.md`, then ask which projects to inspect or execute. Do not modify multiple projects without explicit project selection.
- `no-ship` -> run through verification, then stop before `sf-ship` or `sf-deploy` with a ship-ready report.
- `report=agent`, `handoff`, `verbose`, or `full-report` -> include detailed evidence and command suggestions.

If the user asks to fix, migrate, deploy, or build a specific thing, keep `sf-maintain` as the master only when the work is part of maintenance. Otherwise route directly to the owning skill.

## Maintenance Levels

### Quick Maintenance

`quick` mode is intentionally small and read-only:

1. Read bug, task, audit, docs, dependency, and development-mode state.
2. Identify open high/critical bugs, stale bug statuses, missing bug files, or stale optional bug indexes.
3. Identify dependency signals: lockfile age if visible, package manager, high/critical audit command availability, outdated major-upgrade hints when cheap.
4. Identify docs/governance signals: missing `CLAUDE.md`/`SHIPFLOW.md` development mode, missing technical/editorial corpus when relevant, stale frontmatter next steps, missing `SECURITY.md` when the project has public/auth/payment surfaces.
5. Identify check coverage gaps: no typecheck, lint, tests, build, or meaningful runtime validation scripts.
6. Identify audit recency gaps from `AUDIT_LOG.md`.
7. Return the top 3 maintenance actions with owner skill commands or the recommended master lifecycle mode.

Do not launch audits, edits, installs, commits, or ships in `quick`.

### Master Maintenance Lifecycle

Default and `full` mode should execute the lifecycle as far as safely possible:

```text
intake
  -> triage
  -> existing chantier/spec gate
  -> sf-spec + sf-ready when non-trivial
  -> delegated sequential execution through owner skills/subagents
  -> sf-check / targeted validations
  -> Documentation Update Plan
  -> Editorial Update Plan when public surfaces or claims changed
  -> sf-verify
  -> sf-end when a chantier needs closure bookkeeping
  -> sf-deploy for release confidence or sf-ship for bounded repo/docs/tooling changes
```

Recommended owner-skill order for broad maintenance:

```text
sf-bug -> sf-deps -> sf-docs update/audit -> sf-check nofix -> sf-audit-code or sf-audit -> sf-migrate candidates -> sf-fix/sf-build -> sf-tasks -> sf-verify -> sf-deploy/sf-ship
```

Run phases sequentially when one phase can change the risk interpretation of the next. Use parallel subagents only with ready non-overlapping `Execution Batches`.

## Delegation Contracts

Use subagents for real master-skill work when the runtime supports it.

- Triage Reader: read-only; inspect bugs, deps, docs, checks, audits, migrations, security signals, specs, and project mode; return a ranked maintenance plan.
- Lane Executor: write-capable only for one assigned owner lane and write set; use `sf-deps`, `sf-docs`, `sf-fix`, `sf-build`, `sf-migrate`, or `sf-check fix` as appropriate.
- Technical Reader: read-only; produce the `Documentation Update Plan`.
- Editorial Reader: read-only; produce the `Editorial Update Plan` and `Claim Impact Plan` when public surfaces changed.
- Integrator: consolidate outputs, run focused validations, resolve doc/editorial gates, and decide whether verification can start.
- Ship Executor: run or route through `sf-deploy` when deployment proof is needed, or `sf-ship` for bounded repo/docs/tooling changes. Do not ship unrelated dirty files.

Every delegated prompt must include:

```text
project root
active spec or mini-contract
assigned mission
owned files/surfaces
forbidden files/surfaces
validation commands
report mode
stop conditions
```

### Security Maintenance

ShipFlow does not need a separate `sf-audit-security` yet. Security maintenance is covered by two existing owners:

- `sf-deps`: dependency vulnerabilities, supply chain, package drift, licenses, registry/config posture.
- `sf-audit-code`: authn/authz, tenant boundaries, trust boundaries, secrets, webhooks, destructive actions, input validation, secure failure modes, abuse resistance.

`sf-maintain security` should:

1. Check `bugs/*.md` first, then optional `BUGS.md` if present, for open high/critical security, auth, permissions, data, webhook, or secret issues.
2. Check whether the project has auth, payments, webhooks, public APIs, multi-tenant data, admin actions, or production secrets.
3. Run or route to `/sf-deps` for dependency/security posture and remediation proposals.
4. Run or route to `/sf-audit-code report=agent` when code-level security review is needed.
5. Create or continue a spec when remediation crosses the chantier threshold.
6. Execute safe remediations through bounded owner skills/subagents.
7. Verify and ship only when security, dependency, docs, and check gates allow it.
8. Report missing `SECURITY.md`, missing `.env.example`, missing development mode, or missing preview-proof policy as gaps, not as vulnerabilities by themselves.

If repeated security-only work becomes common, recommend a future `/sf-audit-security` spec. Do not create it from `sf-maintain`.

## Spec And Readiness Gate

Use a full spec when maintenance touches any of:

- production behavior, auth, permissions, data, payments, webhooks, secrets, migrations, dependencies, deployment, or rollback risk
- multiple files or multiple owner skills
- public pages, README promises, pricing, docs, claim surfaces, or governance corpus changes
- work that needs staged execution, retest, deployment proof, or user/operator confirmation

Use a mini-contract only when the fix is local, low-risk, and verifiable in the current run.

If a spec is created or continued, run `sf-ready` and do not start implementation until readiness is `ready`.

## Verification And Ship Gate

After execution:

1. Run focused owner validations and `sf-check` when applicable.
2. Produce or refresh the `Documentation Update Plan`.
3. Produce or refresh the `Editorial Update Plan` when public content or claims changed.
4. Run or route through `sf-verify`.
5. If `no-ship` is absent and verification passes, run or route through:
   - `sf-deploy` when deployment truth or browser/manual proof is required.
   - `sf-ship` when the change is bounded to repo/docs/tooling and deployment proof is not required.
6. Stop before ship if unrelated dirty files, failed checks, missing proof, open high/critical bugs, or unresolved security risks remain.

## Stop Conditions

Stop and report `blocked` when:

- the project scope is ambiguous and multiple projects could be maintained
- a requested full/global run would modify trackers, docs, dependencies, or code without explicit approval
- high/critical open bugs make "healthy" wording unsafe
- suspected secrets are present in untracked or staged files
- dependency/security tools require installation or credentials not available in the environment
- Vercel/hosted validation is required but the project development mode is missing or contradictory
- no matching spec exists for non-trivial maintenance and `sf-spec` / `sf-ready` cannot produce a ready contract
- delegated write ownership overlaps or is undefined
- requested ship scope includes unrelated dirty files

## Report Shape

User-mode report:

```text
## Maintenance: <project>

Result: <completed | verified | shipped | ship-ready | needs attention | blocked>
Execution mode: <main-only | delegated sequential | spec-gated parallel>
Lifecycle: <triage -> spec/readiness -> execution -> checks -> verify -> ship/deploy>
Checks: <passed | failed | skipped with reason>
Ship: <sf-deploy | sf-ship | no-ship | blocked with reason>

Security posture: <clear | partial | needs review | blocked> - <reason>
Proof gaps: <short list or none>
Chantier: <compact chantier block>
```

Agent mode may add:

- files and trackers read
- command evidence
- full bug/deps/docs/audit matrix
- per-domain owner skill route
- proposed task tracker entries
- delegated subagent mission summaries
- validation and ship gate matrix

## Important Rules

- Maintenance is not complete until it is verified, shipped, ship-ready with `no-ship`, or blocked at a named gate.
- Prefer "needs review" over "safe" when security evidence is partial.
- Do not invent audit freshness. Use `AUDIT_LOG.md`, `bugs/*.md`, optional `BUGS.md`, `TEST_LOG.md`, specs, and command output.
- Do not conflate `sf-migrate` and `sf-deps`: deps finds risk and drift; migrate executes breaking-change upgrade work.
- Do not treat missing `SECURITY.md` as a blocker for small local tools, but report it for public, auth, payments, webhook, or multi-user products.
- When maintenance reveals implementation work, execute it through bounded owner skills/subagents after the appropriate spec/readiness gate.
- Do not commit, push, deploy, or mark complete without the relevant `sf-ship` or `sf-deploy` gate.
