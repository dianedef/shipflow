---
artifact: documentation
metadata_schema_version: "1.0"
artifact_version: "0.9.1"
project: "shipflow"
created: "2026-04-25"
updated: "2026-05-08"
status: draft
source_skill: sf-docs
scope: readme
owner: "unknown"
confidence: medium
security_impact: unknown
risk_level: low
docs_impact: yes
linked_systems:
  - shipflow.sh
  - lib.sh
  - config.sh
  - install.sh
  - skills
  - skills/sf-deploy/SKILL.md
  - skills/sf-maintain/SKILL.md
  - skills/sf-content/SKILL.md
  - skills/sf-design/SKILL.md
  - skills/sf-browser/SKILL.md
  - skills/sf-bug/SKILL.md
  - skills/shipflow/SKILL.md
  - skills/references/question-contract.md
  - site/src/content/skills/shipflow.md
  - docs/technical
  - docs/editorial
depends_on: []
supersedes: []
evidence:
  - "Added sf-browser as the generic non-auth browser verification path."
  - "Added sf-deploy as the release confidence orchestrator."
  - "Added sf-maintain as the recurring project maintenance orchestrator."
  - "Clarified sf-build business-context decision questions."
  - "Added a public and repo-level skill launch cheatsheet for master skill modes."
  - "Added docs/skill-launch-cheatsheet.md as the standalone Markdown reference."
  - "Clarified that sf-skill-build routes fuzzy skill-maintenance ideas through sf-explore before sf-spec."
  - "Added sf-content as the master content lifecycle entrypoint."
  - "Clarified sf-build delegated sequential subagent consent and separated subagents from parallelism."
  - "Added skills/references/master-delegation-semantics.md as the shared master/orchestrator delegation doctrine."
  - "Added skills/references/master-workflow-lifecycle.md as the shared lifecycle skeleton and clarified bug files as source of truth."
  - "Documented shipflow <instruction> as the recommended non-technical router before direct sf-* expert entrypoints."
  - "Documented the shared question/default contract for numbered questions and context-safe defaults."
  - "Added sf-design as the master design lifecycle entrypoint."
  - "Clarified sf-bug as a bug lifecycle executor that continues through owner skills and bounded subagents when safe."
next_step: "/sf-docs audit README.md"
---

# ShipFlow

ShipFlow is a unified framework for server delivery and AI-assisted execution discipline.

It has two layers:
- a CLI for managing project environments on a server
- a skill system for structured coding workflows, audits, documentation, and shipping

It is built for solo founders and autonomous technical builders who want to launch, publish, and maintain software simply without losing context in agent handoffs.

## What ShipFlow Does

ShipFlow is designed to solve one problem first: lost context and weak handoffs in AI-assisted product work.

It helps operators run apps on servers, but its deeper job is to reduce ambiguity and give AI agents a better execution frame. That is why ShipFlow should not be read as only a PM2-oriented server script, and not as only a methodology or prompt system for agents. It is the combination of both.

### Server environment management

- deploy and run projects under isolated Flox environments
- manage long-running processes with PM2
- assign and persist project ports
- expose apps through Caddy and DuckDNS
- support local access through SSH tunnel tooling
- run Flutter Web preview sessions in `tmux` with ShipFlow-triggered hot reload

### Structured AI workflows

- task tracking and session lifecycle
- fast current-thread recap when a session becomes hard to follow
- spec-driven implementation flow
- verification and remediation loops
- professional bug management with compact `TEST_LOG.md`, one durable Markdown bug file per bug under `bugs/`, optional/generated `BUGS.md` triage views, and redacted `test-evidence/BUG-ID/` evidence
- audits across code, design, copy, SEO, GTM, deps, perf, and translation
- documentation and research workflows

## Core Docs

- [AGENT.md](./AGENT.md) — agent entrypoint: where to look first depending on the task
- [CONTEXT.md](./CONTEXT.md) — compact operational map of the project, hotspots, invariants, and edit routing
- [CONTEXT-FUNCTION-TREE.md](./CONTEXT-FUNCTION-TREE.md) — grouped function tree for the main shell scripts
- [CONTENT_MAP.md](./CONTENT_MAP.md) — editorial map for blog, docs, landing pages, semantic clusters, and repurposing destinations
- [docs/editorial/README.md](./docs/editorial/README.md) — content governance layer for public content, claims, page intent, and Astro content schema boundaries
- [docs/technical/README.md](./docs/technical/README.md) — internal technical documentation layer for code-proximate subsystem docs
- [docs/technical/code-docs-map.md](./docs/technical/code-docs-map.md) — map from code paths to primary docs, validations, and documentation update triggers
- [docs/skill-launch-cheatsheet.md](./docs/skill-launch-cheatsheet.md) — Markdown cheatsheet for master skills, supporting skills, and argument modes
- [skills/references/master-delegation-semantics.md](./skills/references/master-delegation-semantics.md) — shared execution-topology doctrine for master/orchestrator skills
- [skills/references/master-workflow-lifecycle.md](./skills/references/master-workflow-lifecycle.md) — shared lifecycle skeleton and work item model for master/orchestrator skills
- [BUSINESS.md](./BUSINESS.md) — target audience, value proposition, business assumptions, and market framing
- [PRODUCT.md](./PRODUCT.md) — product scope, workflows, outcomes, and non-goals
- [BRANDING.md](./BRANDING.md) — tone, trust posture, vocabulary, and claims boundaries
- [GTM.md](./GTM.md) — public promise, acquisition path, proof points, objections, and funnel assumptions
- [ARCHITECTURE.md](./ARCHITECTURE.md) — system structure, boundaries, flows, and technical invariants
- [GUIDELINES.md](./GUIDELINES.md) — technical rules, preferred patterns, anti-patterns, and validation expectations
- [CLAUDE.md](./CLAUDE.md) — repository constraints and coding guidance
- [shipflow-spec-driven-workflow.md](./shipflow-spec-driven-workflow.md) — ShipFlow V3 workflow for `sf-explore`, `sf-spec`, `sf-ready`, `sf-start`, `sf-verify`, and `sf-end`
- [shipflow-metadata-migration-guide.md](./shipflow-metadata-migration-guide.md) — how to adopt ShipFlow metadata and versioning in an existing project
- [skills/references/canonical-paths.md](./skills/references/canonical-paths.md) — path resolution rules for ShipFlow-owned tools, references, templates, and project-local artifacts
- [ECOSYSTEM-AND-PORTS.md](./ECOSYSTEM-AND-PORTS.md) — persistent PM2 ecosystem files and port management
- [local/README.md](./local/README.md) — local tunnel setup
- [tools/codebase-mcp/README.md](./tools/codebase-mcp/README.md) — local MCP server for codebase context management
- [archive/README.md](./archive/README.md) — historical docs and old reports

## Installation

```bash
# Via the bootstrap dotfiles flow
curl -fsSL https://raw.githubusercontent.com/dianedef/dotfiles/main/bootstrap.sh | bash

# Or manually
cd ~/shipflow
sudo ./install.sh
```

### Install Privilege Model

ShipFlow's installer is intentionally a root-level installer. It must be run with `sudo ./install.sh` because it manages machine-wide dependencies and service configuration:

- system packages and tools such as Node.js, PM2, Flox, Caddy, GitHub CLI, `jq`, `fuser`, and `ss`
- global CLI binaries under `/usr/local`
- PM2 binary installation only; ShipFlow does not configure PM2 boot autostart by default
- `/etc/dokploy/compose`
- ShipFlow user configuration for root and detected regular users

If `./install.sh` is launched without root, it stops before making partial system changes. The log explains that the root-only scope was skipped and tells the operator to rerun with `sudo`.

The recommended server shape is:

- use `root` or `sudo` for first-time system setup
- use a regular non-root account such as `ubuntu`, `opc`, `debian`, `ec2-user`, or a manually created user for daily work
- keep user-level config, credentials, project files, Claude/Codex settings, and ShipFlow data scoped to the operational user
- start ShipFlow environments explicitly when needed instead of relying on PM2 resurrection at boot

`dotfiles` may prepare generic user tooling in `~/.local/bin`, `~/.npm-global`, and `~/.config`. ShipFlow owns the AI/code workflow layer: skills, Claude/Codex settings, MCP registrations, ShipFlow aliases, and `~/shipflow_data`.

Before the first install on a machine, restore your existing tracking data if you
already have it in GitHub or another backup:

```bash
git clone git@github.com:<owner>/shipflow_data.git ~/shipflow_data
```

ShipFlow creates starter files in `~/shipflow_data` when the folder is missing.
If you start working before restoring your real data, skills may write new
tracking entries into the empty folder and make the later merge harder.

## Codex TUI Defaults

`install.sh` configures Codex for selected eligible users (plus root baseline setup) by writing `~/.codex/config.toml` with:

```toml
tui.status_line = ["model-with-reasoning", "current-dir", "context-remaining", "five-hour-limit", "weekly-limit"]
tui.terminal_title = ["spinner", "thread", "project"]
```

It also sets `[beta] rmcp = true` in `~/.codex/config.toml`.

The install is idempotent, preserves existing user custom settings, and keeps
ShipFlow-managed config wrapped in its own markers so user edits outside those
blocks remain unchanged.

It also provisions the default MCP set used by ShipFlow:
- `context7` in `~/.claude/settings.json` and `~/.codex/config.toml`
- `vercel` in `~/.claude/settings.json` and `~/.codex/config.toml`
- `convex` in `~/.claude/settings.json` and `~/.codex/config.toml`
- `clerk` in `~/.claude/settings.json` and `~/.codex/config.toml`
- `supabase` in `~/.claude/settings.json` and `~/.codex/config.toml`
- `playwright` in `~/.claude/settings.json` and `~/.codex/config.toml`
- `dataforseo` in `~/.claude/settings.json` and `~/.codex/config.toml`

For remote Codex usage, ShipFlow local tooling also supports OAuth login flows for hosted MCP providers through an ephemeral local SSH callback tunnel:

```bash
shipflow-mcp-login vercel
shipflow-mcp-login supabase
shipflow-mcp-login all
shipflow-blacksmith-login
```

The reason is specific to remote agent work: Codex or the provider CLI runs on
the server, but the OAuth provider redirects the browser to
`127.0.0.1:<port>/callback` on the local machine. ShipFlow opens a temporary
SSH `-L` tunnel for the fresh callback port so the local browser can reach the
remote login process. This applies to hosted MCP provider logins and to
Blacksmith CLI auth.

The local menu stores the remote host, SSH user, and optional SSH key path used
by `urls`, `tunnel`, `shipflow-mcp-login`, and
`shipflow-blacksmith-login`. Leaving the key path blank means ShipFlow uses the
normal SSH config or agent. ShipFlow does not store OAuth tokens; Codex,
Blacksmith, and the provider own the token exchange. See
[local/README.md](./local/README.md) for the guided setup and troubleshooting
flow.

The server-side `sf` menu also includes `Blacksmith - CI runners and Testbox
setup`. This is a guided official-first helper for Blacksmith: it checks whether
the `blacksmith` CLI is installed, detects a local credentials file without
reading its contents, shows `T'inquiète, c'est bon, t'es connecté.` when the
local setup is ready, and prints the exact official command to run only when an
interactive install or Testbox init step is still required. For auth on a remote
server, it routes the operator to the local `urls` menu's Blacksmith login
tunnel instead of suggesting `blacksmith auth login` directly over SSH.
ShipFlow does not install the unofficial Blacksmith MCP by default and does not
patch project workflows automatically from this menu.

Notes:
- `dataforseo` is configured but disabled by default in Codex unless
  `SHIPFLOW_ENABLE_DATAFORSEO_MCP=1` and credentials are available.
- `playwright` MCP points to the local Playwright Chromium/Headless Shell
  executable when available, especially on Linux ARM64 where Google Chrome
  stable is not a valid fallback.

ShipFlow also installs the terminal tooling commonly needed to operate those integrations:
- `node` / Node.js (from NodeSource if needed)
- `pm2`
- `vercel`
- `convex`
- `clerk`
- `supabase` via the standalone CLI binary, because Supabase does not support `npm install -g supabase`
- `gh` (GitHub CLI)
- `flox`
- `caddy`
- Playwright Chromium runtime libraries for the default browser MCP
- `python3` and `PyYAML`
- core tools: `git`, `curl`, `jq`, `fuser`, `ss` (`iproute2`), `python3-pip` (if needed)

For Dart/Flutter projects, ShipFlow provisions runtime packages inside each
project Flox environment (not as a required global SDK). Defaults are
`SHIPFLOW_FLOX_DART_PACKAGES=dart` and
`SHIPFLOW_FLOX_FLUTTER_PACKAGES=flutter@3.41.5-sdk-links`, with strict token
validation on overrides. The `Advanced > Install SDK` menu stays available as
an optional global convenience.

Flutter Web can also be launched from `sf` through `Flutter Web - tmux hot
reload`. This starts `flutter run -d web-server` in a server-side `tmux`
session, records the port in `SHIPFLOW_FLUTTER_WEB_SESSIONS_FILE`, and lets
ShipFlow send Flutter's `r` or `R` controls for hot reload or hot restart. This
is a web preview path for browser testing through SSH tunnels, not native
Android/iOS rendering.

Per-user configuration includes:
- `~/.claude/skills/*` and `~/.codex/skills/*` symlinks for every ShipFlow skill
- aliases in `~/.bashrc` for `shipflow`, `sf`, autonomous `c`/`co`, and safe escape hatches `cask`/`coask`
- `~/shipflow_data/TASKS.md`, `AUDIT_LOG.md`, and `PROJECTS.md`

Skill runtime visibility can also be checked or repaired without rerunning the full installer:

```bash
tools/shipflow_sync_skills.sh --check --all
tools/shipflow_sync_skills.sh --repair --skill sf-example
```

The helper links current-user `~/.claude/skills/<name>` and `~/.codex/skills/<name>` entries to `$SHIPFLOW_ROOT/skills/<name>`. It reports missing or stale links, blocks non-symlink collisions by default, and notes that an already-running Claude or Codex session may need a reload before the repaired skill appears in the runtime list.

If your Codex version does not expose one of these items (for example `thread`), adjust interactively in Codex:

```text
/statusline
/title
```

Unlike Claude Code, Codex does not expose a custom shell-command status line renderer.

## Usage

```bash
sf
shipflow
sf u   # open Updates directly
```

Passing a top-level menu key as the only argument runs that menu action once.
Action-level confirmations still apply, including before package upgrades.
Inside menus, `x`, `Esc`, and `Backspace` go back when a Back option exists.

Typical CLI actions:
- dashboard and PM2 status
- deploy, restart, stop, remove environments
- Flutter Web tmux sessions with hot reload/hot restart
- publish apps with public HTTPS URLs
- guided Blacksmith runner/Testbox setup for project CI
- health checks and crash loop detection

## Skill Workflow

Recommended non-technical entrypoint in a skill-aware agent session:

```text
shipflow <instruction>
```

Use `shipflow <instruction>` when you want ShipFlow to choose the route. It answers pure conversational requests directly, hands non-trivial feature/code/docs work to `sf-build`, upkeep to `sf-maintain`, bugs to `sf-bug`, release/deploy/prod proof to `sf-deploy`, content to `sf-content`, skill maintenance to `sf-skill-build`, and obvious specialist audits to `sf-audit-*`. If the route is ambiguous, it asks one numbered question with why, the recommended answer, and practical options. When it routes, it hands the current thread directly to the selected skill; selected masters own their own delegated sequential execution.

Question/default rule: ShipFlow skills should not ask just because several choices exist. They proceed by default only when the answer is clear from the request and project context, low-risk, reversible, inside the accepted scope, compatible with the current technical/product/editorial context, aligned with current best practices, and verifiable in the current run. Otherwise they ask a numbered decision question with why, a responsible recommendation when one exists, and practical options.

ShipFlow is now optimized for **one-pass execution**.

That means:
- the framing skill must carry the missing context before coding starts
- a `ready` spec must be executable by a fresh agent without reading the chat history
- agent prompts should already include linked systems, downstream consequences, and explicit validation targets
- if a fresh context is needed and cannot be created automatically, the skill must ask the user to open a new thread
- “prompt and correct” is a fallback for bounded drift, not the normal operating mode

Skill launch cheatsheet:

| Need | Launch | Useful modes |
| --- | --- | --- |
| Non-technical first command | `shipflow <instruction>` | Routes pure conversation directly; routes real work to the right master or specialist skill; uses context-safe defaults and asks one numbered decision question when ambiguity changes route, risk, scope, or proof. |
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

Use `sf-bug` when you want the professional bug loop executed from a `BUG-ID`, a fresh bug report, a retest request, or a ship-risk question. It continues through narrower owner skills and bounded subagents when safe, without bypassing the bug file, retest, verification, or ship-risk gates.

Bug-first repair entrypoint:

```text
sf-fix -> (fix directly or spec-first path)
```

Auth/browser diagnostic path:

```text
sf-auth-debug -> sf-fix or sf-start -> sf-verify
```

Use `sf-auth-debug` before guessing from static code when the bug involves Clerk, OAuth, Google login, YouTube OAuth, Convex auth propagation, cookies, callbacks, protected routes, or Flutter web auth bridges. It can use Playwright where a real browser flow is accessible, and it carries local reference docs for the auth stacks ShipFlow projects use most often.

General browser verification path:

```text
sf-browser -> sf-fix, sf-test, sf-prod, sf-auth-debug, or sf-verify
```

Use `sf-browser` when you need browser evidence for a non-auth URL, route, preview, or production page: visible assertions, quick visual inspection, console/network summaries, screenshots, and page-level checks. It keeps deployment truth in `sf-prod`, auth/session diagnosis in `sf-auth-debug`, and durable manual QA logs in `sf-test`.

Fast thread recap:

```text
sf-resume -> 3-5 bullets, task statuses, close/keep-open verdict
```

Optional model-selection step:

```text
sf-model -> choose model / reasoning / fallbacks before execution
```

Direct build entrypoint for non-trivial feature/code/docs work:

```text
sf-build -> existing chantier check -> sf-spec/sf-ready loop -> sf-start -> sf-verify -> sf-end -> sf-ship
```

`sf-build` follows the shared master delegation doctrine in `skills/references/master-delegation-semantics.md`: invocation authorizes bounded delegated sequential execution for the current chantier, short natural-language confirmations continue that bounded sequential path after diagnosis by intent rather than exact keyword, and parallel agent execution requires ready non-overlapping `Execution Batches`. `sf-build` keeps user interaction focused on decisions and progress; material questions are framed as business decision briefs with the root problem, business stakes, options, and a recommended best-practice answer. It skips the question only when the best default is safe, reversible, compatible with the current project context, aligned with best practices, and verifiable.

Recommended release entrypoint after implementation:

```text
sf-deploy -> sf-check -> sf-ship -> sf-prod -> sf-browser/sf-auth-debug/sf-test -> sf-verify -> sf-changelog
```

`sf-deploy` is for release confidence, not just pushing code. It keeps technical checks, bounded shipping, deployment truth, post-deploy evidence, final verification, and optional release notes in one visible flow.

Recommended maintenance entrypoint for existing projects:

```text
sf-maintain -> triage -> sf-spec/sf-ready when needed -> delegated maintenance lanes -> sf-verify -> sf-deploy/sf-ship
```

`sf-maintain` is the master maintenance lifecycle. It reviews bug risk, dependency posture, docs/governance drift, check coverage, audit freshness, migration candidates, and security posture, then carries needed work through spec/readiness, bounded delegated execution, verification, and ship/deploy routing. Use `/sf-maintain quick` for the old read-only triage behavior.

For ShipFlow skill maintenance, use the dedicated entrypoint:

```text
sf-skill-build -> sf-explore when needed -> sf-spec -> skill contract edit/create -> runtime skill sync -> sf-skills-refresh -> skill budget audit -> sf-verify -> sf-docs/help update -> sf-ship
```

`sf-skill-build` is scoped to creating or modifying `skills/*/SKILL.md` with explicit ambiguity-reduction, public-surface, documentation, and validation gates. If the skill idea or placement is too fuzzy for one targeted question to settle, it routes to `sf-explore` before creating the durable `sf-spec` contract.

For content management, use the dedicated lifecycle entrypoint:

```text
sf-content -> CONTENT_MAP + editorial corpus -> owner content skills -> audits/docs -> validation -> sf-verify -> sf-ship
```

`sf-content` routes content work through the right owner skill: `sf-repurpose` for source-faithful reuse, `sf-redact` for long-form drafting, `sf-enrich` for existing content upgrades, `sf-audit-copy` / `sf-audit-copywriting` / `sf-audit-seo` for review, and `sf-docs` for docs and editorial governance. It blocks undeclared blog/article surfaces with `surface missing: blog` instead of inventing paths.

If the bug is local and clear, `sf-fix` fixes it directly, then verifies.
That fast path should still attach the bug to durable project memory with a `bugs/BUG-ID.md` bug file, unless the issue is an explicitly justified minor exception such as a copy-only or purely cosmetic fix. `BUGS.md`, when present, is only a compact optional/generated triage view.
If the bug is ambiguous or non-trivial, `sf-fix` routes to `sf-spec -> sf-ready -> sf-start`.

ShipFlow keeps bug records split on purpose:

- `TEST_LOG.md` stays compact and records what was tested and how it went.
- `bugs/BUG-ID.md` holds the detailed source of truth for one bug work item.
- `BUGS.md`, when present, stays compact as an optional/generated triage index that points to bug files.
- `test-evidence/BUG-ID/` holds redacted evidence when screenshots, logs, or traces are too large or sensitive to inline.

Technical documentation layer:

```text
docs/technical/code-docs-map.md -> primary subsystem doc -> Documentation Update Plan
```

Use this layer for code-changing work. It keeps technical details close to the code without bloating `AGENT.md`, `CONTEXT.md`, or public docs. `docs/technical/` is internal-only in v1.

Governance corpus lifecycle:

```text
sf-init -> sf-docs -> sf-build
```

`sf-init` bootstraps `docs/technical/`, `docs/technical/code-docs-map.md`, `CONTENT_MAP.md`, and applicable `docs/editorial/` files, or reports why a layer is skipped or blocked. `sf-docs` owns first-run bootstrap, adoption, update, and audit through `/sf-docs technical`, `/sf-docs editorial`, and `/sf-docs update`. `sf-build` consumes those project-local corpora as gates before implementation, closure, and ship; missing governance routes back to `sf-docs` instead of requiring the operator to rerun ShipFlow's shipped governance specs per project.

For expert manual control, the default non-trivial workflow is:

```text
sf-explore -> exploration_report -> sf-spec -> sf-ready -> sf-start -> sf-verify -> sf-end
```

For spec-first work, the spec is also the chantier registry. It keeps a
`Skill Run History` and a `Current Chantier Flow`, so you can open the spec and
see which lifecycle skills have run, which model was used, what result they
recorded, and what the next ShipFlow command is. `TASKS.md`, `AUDIT_LOG.md`,
and `PROJECTS.md` stay operational trackers; they do not become the per-chantier
history.

Fast path for a small, explicit fix:

```text
sf-start -> sf-verify -> sf-end
```

Bug fast path (recommended mental model):

```text
sf-fix -> sf-verify -> sf-end
```

The key rule is simple:
- reduce ambiguity before coding
- verify against the contract before closing

## Context Layer

ShipFlow now uses a dedicated context layer for fast agent onboarding.

- `AGENT.md` is the routing file: it tells an agent where to look first.
- `CONTEXT.md` is the operational map: entry points, core flows, hotspots, invariants, and where to edit what.
- `CONTEXT-FUNCTION-TREE.md` is a specialized companion for large procedural files such as `lib.sh`.
- `CONTENT_MAP.md` is the editorial map: content surfaces, page roles, semantic clusters, pillar pages, and cross-surface update rules.
- `docs/editorial/` is the editorial coherence layer: public content surfaces, claims, page intent, update gates, and Astro content schema policy.

This split is intentional. `CLAUDE.md` should hold constraints and critical rules, not the full project map. The context files exist to reduce repetitive discovery work at the start of a fresh thread without pretending to replace the code.

ShipFlow also separates decision contracts by role:

- `BUSINESS.md` for who the product is for and why it matters
- `PRODUCT.md` for what the product should do and not do
- `BRANDING.md` for how the product should sound
- `GTM.md` for how the product should be presented and distributed
- `CONTENT_MAP.md` for where content lives and how ideas should move between blog, docs, landing pages, FAQ, and semantic clusters
- `docs/editorial/` for content governance: public content impact, public claims, page intent, and runtime content schema boundaries
- `ARCHITECTURE.md` for how the system is organized
- `GUIDELINES.md` for how contributors should work inside it

## Documentation Frame

The current documentation structure is already solid on four axes:

- technical: `CLAUDE.md`, `CONTEXT.md`, `CONTEXT-FUNCTION-TREE.md`, `CONTENT_MAP.md`, `GUIDELINES.md`, and `specs/`
- workflow: `sf-spec`, `sf-ready`, `sf-start`, `sf-verify`, `sf-docs`, and versioned metadata
- product/business: `BUSINESS.md`, `BRANDING.md`, versioned docs, and `depends_on` relationships
- editorial coherence: `CONTENT_MAP.md`, `docs/editorial/`, public content, claims, page intent, and Astro content schema boundaries

The recent step forward is structural clarity:

- a clear agent entrypoint with `AGENT.md`
- a dedicated context layer with `CONTEXT.md` and specialized context companions
- a stronger metadata and lint doctrine with artifact versioning plus `tools/shipflow_metadata_lint.py`
- a public-content governance layer that keeps README, docs overview, FAQ, public skill pages, pricing copy, and claims aligned with product truth
- a cleaner separation between active docs, trackers, and runtime content

This means the framework is no longer just documented. It is organized so a fresh agent can enter, locate the right contract, and distinguish decision artifacts from operational tracking or app-rendered content.

## ShipFlow as a Professional Work Framework

ShipFlow is not just a collection of prompts or isolated skills. It is a work framework built around explicit decision contracts.

The core idea is that serious product work depends on more than code. A feature is shaped by user stories, business positioning, brand promises, security assumptions, documentation, pricing, onboarding, support, and operational constraints. ShipFlow treats these as first-class project artifacts rather than informal chat context.

### Decision contracts

ShipFlow artifacts are contracts that later skills can verify against:

- A spec is an implementation contract and chantier registry: it defines scope, invariants, linked systems, risks, acceptance criteria, documentation impact, and the skill-run history for that workstream.
- A business document is a product-decision contract: it defines the audience, value proposition, market, promise, pricing assumptions, and proof level.
- A brand document is a communication contract: it defines tone, trust posture, vocabulary, visual consistency, and claims that must not drift.
- An audit report is an evidence contract: it records what was checked, what remains uncertain, and what should happen next.
- A review or verification report is a closure contract: it distinguishes implemented, verified, assumed, partial, and unsafe-to-close work.

This is what makes ShipFlow different from ad hoc AI assistance: every stage produces or consumes structured artifacts that can be reviewed, updated, and challenged.

### Metadata and traceability

ShipFlow internal artifacts use YAML frontmatter metadata. The goal is not bureaucracy; the goal is traceability.

Common metadata fields include:

```yaml
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: "[project name]"
created: "2026-04-25"
created_at: "2026-04-25 10:30:00 UTC"
updated: "2026-04-25"
updated_at: "2026-04-25 10:30:00 UTC"
status: draft
source_skill: sf-spec
source_model: "GPT-5 Codex"
scope: feature
owner: "[user/team]"
user_story: "En tant que..., je veux..., afin de..."
confidence: medium
risk_level: medium
security_impact: unknown
docs_impact: yes
linked_systems: []
depends_on:
  - artifact: BUSINESS.md
    artifact_version: "1.0.0"
    required_status: reviewed
evidence: []
next_step: "/sf-ready [title]"
```

Specs also include a markdown `Skill Run History` table and a `Current Chantier Flow`.
Lifecycle skills (`sf-spec`, `sf-ready`, `sf-start`, `sf-verify`, `sf-end`,
`sf-ship`) write to that history when a unique spec-first chantier is in scope.
Cross-cutting skills write only when the run is attached to one clear chantier;
helper skills such as `sf-help`, `sf-model`, `sf-status`, and `sf-resume` do not
write spec history.

ShipFlow provides skill-aligned artifact templates in `templates/artifacts/` and a dependency-free linter:

- `business_context.md`
- `brand_context.md`
- `product_context.md`
- `architecture_context.md`
- `gtm_context.md`
- `content_map.md`
- `technical_guidelines.md`

```bash
SHIPFLOW_ROOT="${SHIPFLOW_ROOT:-$HOME/shipflow}"
"$SHIPFLOW_ROOT/tools/shipflow_metadata_lint.py"
```

This layer is wired into the documentation workflow, agent routing, project context, migration guidance, and lint validation. It is not passive reference material; it is part of how ShipFlow frames, executes, verifies, and documents work.

ShipFlow-owned files are resolved from `${SHIPFLOW_ROOT:-$HOME/shipflow}` even when a skill is running inside another repository. Project artifacts and source files are the only paths resolved from the current project root.

For legacy projects, use the migration playbook in [`shipflow-metadata-migration-guide.md`](./shipflow-metadata-migration-guide.md) before normalizing old docs.

By default it checks `specs/`, `docs/`, `AGENT.md`, `CONTEXT.md`, `CONTEXT-FUNCTION-TREE.md`, `CONTENT_MAP.md`, `BUSINESS.md`, `BRANDING.md`, `PRODUCT.md`, `ARCHITECTURE.md`, `GTM.md`, and `GUIDELINES.md`. Pass explicit files or folders to validate a narrower scope.

For internal ShipFlow files, this schema is mandatory for the active official artifact set. That set now includes `AGENT.md`, `CONTEXT.md`, promoted specialized context docs such as `CONTEXT-FUNCTION-TREE.md`, `CONTENT_MAP.md`, and the decision contracts `BUSINESS.md`, `PRODUCT.md`, `BRANDING.md`, `GTM.md`, `ARCHITECTURE.md`, and `GUIDELINES.md`. `CLAUDE.md` is supported as an optional active artifact when a project explicitly adopts it as the canonical repository guidance for Claude or multi-agent contributors. In that case, add ShipFlow frontmatter and include it explicitly in metadata checks. For legacy project adoption, the default migration scope is intentionally narrower: active context docs when they exist, active decision contracts when they exist, and `specs/*.md`. Historical ad hoc docs can stay out of scope until they are promoted into the active ShipFlow workflow.

Operational tracking files are intentionally excluded from the mandatory artifact schema: `TASKS.md`, `AUDIT_LOG.md`, and `PROJECTS.md` are trackers/registries, not decision contracts. Keep them fast to edit. If a task entry contains a durable decision, spec, or business rule, extract that durable content into a dedicated artifact with metadata instead of adding frontmatter to the tracker itself.

Location rule:
- `shipflow_data` is the control plane for shared tracking and registry files.
- Each project repository is the canonical home for its own `BUSINESS.md`, `BRANDING.md`, `CONTENT_MAP.md`, `GUIDELINES.md`, specs, research, and decision records.
- Do not duplicate or symlink project decision-contract documents into `shipflow_data` by default. `shipflow_data` may reference that the contracts exist, but should not host the canonical copy of per-project business or technical documentation.

Application runtime content keeps the schema required by the application. Blog posts, Astro content collections, MDX pages, and app-rendered docs must keep their framework-compatible frontmatter. ShipFlow can enrich compatible fields, but it must not break the app parser.

### Business documentation is technical documentation

ShipFlow treats `BUSINESS.md`, `BRANDING.md`, `GUIDELINES.md`, `CONTENT_MAP.md`, personas, pricing notes, positioning, and GTM documents as technical artifacts because they drive technical, product, and content-routing decisions.

If `BUSINESS.md` says the product serves solo founders, then copy, onboarding, pricing, feature scope, support, and prioritization should be evaluated against that audience. If `BRANDING.md` says trust and clarity are core values, then UI copy, error messages, claims, screenshots, and documentation must preserve that trust. If a pricing or positioning document is stale, a technically correct feature can still be strategically wrong.

Business documentation therefore needs the same discipline as code documentation:

- clear status: `draft`, `reviewed`, `stale`, `active`
- confidence level: `high`, `medium`, `low`
- evidence: interviews, user statements, analytics, market research, source URLs, or explicit assumptions
- review date and next review date
- linked artifacts: specs, audits, pages, onboarding, pricing, support docs
- artifact version and dependency references, so a spec can say which version of the business contract it was built against
- risk level when the document influences public promises, pricing, security, compliance, or user expectations

The practical rule is simple: if a document influences what the agent will build, audit, ship, or claim publicly, it must be traceable.

ShipFlow uses two version fields:

- `metadata_schema_version` tracks the shape of the ShipFlow metadata itself.
- `artifact_version` tracks the decision content of the document.

This matters when business or technical documentation changes. If a spec was written against `BUSINESS.md` version `1.0.0`, and the business document later moves to `1.1.0` because the target persona or pricing changed, the spec should be rechecked before implementation. Versioning makes drift visible instead of relying on memory.

### Proof over optimism

ShipFlow avoids treating green checks, commits, pushes, or polished copy as proof that work is done.

Skills should distinguish:

- `implemented`: code or content was changed
- `verified`: the intended outcome was checked
- `assumed`: the outcome is plausible but not proven
- `partial`: part of the promise is delivered
- `stale`: an artifact no longer matches the product

This matters for public and expensive products. Security, pricing, data handling, onboarding, docs, and support expectations can fail even when the code builds. ShipFlow makes those gaps visible before they become production risk.

### Documentation coherence

When a feature changes, ShipFlow treats documentation as part of the feature surface.

Relevant docs may include:

- README
- product docs
- API docs
- guides and examples
- FAQ
- onboarding
- pricing
- changelog
- support copy
- screenshots
- public marketing pages

Stale documentation is a product bug when it causes users or operators to misunderstand setup, security, pricing, permissions, API behavior, migration steps, destructive actions, or support expectations.

For medium and large changes, the contract is explicit:
- `sf-spec` defines scope, dependencies, invariants, links, consequences, and execution notes
- `sf-ready` rejects a spec that still depends on hidden assumptions
- `sf-start` executes from that contract instead of rediscovering intent
- `sf-start` now also selects a primary execution model and chooses execution topology before coding; master/orchestrator topology follows `skills/references/master-delegation-semantics.md`
- `sf-verify` checks the implementation and the linked systems that could regress around it

Success criterion:
- a fresh agent should be able to pick up the task in one pass

Operational rule:
- for non-trivial work, `sf-ready` and `sf-start` are the places where a fresh context may be enforced
- if multiple agents are used, write ownership and final integration responsibility must be explicit

## TASKS vs BACKLOG

Use both files on purpose:

- `TASKS.md` = active, prioritized, executable work
- `BACKLOG.md` = deferred ideas, parking lot, non-committed items

Promotion rule:
- move an item from `BACKLOG.md` to `TASKS.md` only when it is ready to be worked on now (clear enough, prioritized enough, and scoped enough)

## Repository Layout

```text
shipflow/
├── shipflow.sh
├── lib.sh
├── config.sh
├── install.sh
├── README.md
├── CLAUDE.md
├── CHANGELOG.md
├── shipflow-spec-driven-workflow.md
├── ECOSYSTEM-AND-PORTS.md
├── archive/
├── skills/
├── local/
├── research/
├── tools/
└── injectors/
```

## Main Components

- `shipflow.sh` — interactive CLI entry point
- `lib.sh` — shared shell library for ports, PM2, Flox, Caddy, validation, and tracking
- `config.sh` — central configuration
- `install.sh` — installation and machine setup
- `skills/` — ShipFlow skill library
- `local/` — local machine tunnel scripts and setup docs
- `tools/codebase-mcp/` — optional MCP server for token-efficient codebase work
- `research/` — research notes and evaluations
- `archive/` — historical plans, reports, and obsolete documents kept for reference

## Key Features

- isolated per-project environments with Flox
- PM2-managed app lifecycle
- Flutter Web interactive `tmux` preview with hot reload
- persistent `ecosystem.config.cjs` generation
- automatic port allocation and collision avoidance
- public HTTPS publishing through Caddy and DuckDNS
- local tunnel workflows
- spec-driven AI-assisted development workflows

## Tech Stack

- Flox
- PM2
- Caddy
- DuckDNS
- Bash
- SSH / autossh

## Status

The root of this repository is intentionally kept for living documentation.

Older plans, implementation summaries, and one-off reports have been moved into [`archive/`](./archive/).
