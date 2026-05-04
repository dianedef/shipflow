---
artifact: documentation
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipFlow
created: "2026-05-04"
updated: "2026-05-04"
status: reviewed
source_skill: sf-docs
scope: skill-launch-cheatsheet
owner: unknown
confidence: high
risk_level: low
security_impact: none
docs_impact: yes
linked_systems:
  - skills/
  - site/src/pages/skill-modes.astro
  - site/src/content/skills/
  - README.md
  - shipflow-spec-driven-workflow.md
  - CONTENT_MAP.md
depends_on:
  - artifact: "shipflow-spec-driven-workflow.md"
    artifact_version: "0.13.1"
    required_status: draft
supersedes: []
evidence:
  - "Master skill contracts and public skill pages."
  - "Public launch cheatsheet in site/src/pages/skill-modes.astro."
  - "sf-skill-build routes fuzzy skill ideas through sf-explore before sf-spec."
  - "sf-content added as the master content lifecycle entrypoint."
next_step: "/sf-docs audit docs/skill-launch-cheatsheet.md"
---

# Skill Launch Cheatsheet

Use this page when you need to choose which ShipFlow skill to launch and which mode argument changes the workflow.

## Default Rule

Start with `sf-build` when the request is a real workstream: product, code, site, docs, bug, or feature work that may need spec, readiness, implementation, verification, docs alignment, closeout, and ship routing.

Use a focused skill directly when you intentionally want one owner lane: checks, docs, browser proof, auth diagnosis, manual QA, production truth, audit, dependency posture, migration, or final ship.

## Master Skills

| Need | Launch | Useful modes |
| --- | --- | --- |
| Non-trivial product, code, site, or docs work | `sf-build <story, bug, or goal>` | Plain task text is the story. Use `report=agent`, `handoff`, `verbose`, or `full-report` only for detailed handoff evidence. |
| Recurring project upkeep | `sf-maintain [mode]` | `full`/no argument, `quick`, `security`, `deps`, `docs`, `audits`, `no-ship`, `global`. |
| Release confidence after implementation | `sf-deploy [target or mode]` | no argument, `skip-check`, `--preview`, `--prod`, `no-changelog`. |
| Bug-loop routing | `sf-bug [BUG-ID, summary, or mode]` | no argument, `BUG-ID`, `--fix`, `--retest`, `--verify`, `--ship`, `--close`. |
| Content management | `sf-content [goal, source, file, or mode]` | `plan`, `repurpose`, `draft`, `enrich`, `audit`, `seo`, `editorial`, `apply`, `ship`. |
| Skill creation or maintenance | `sf-skill-build <idea or path>` | new skill idea, existing skill path, optional `sf-explore` for fuzzy placement, public page/docs/runtime validation gates. |

## Supporting Skills

| Need | Launch | Useful modes |
| --- | --- | --- |
| Manual expert lifecycle | `sf-spec -> sf-ready -> sf-start -> sf-verify -> sf-end` | Use when you intentionally want to drive each gate instead of using `sf-build`. |
| Commit and push ready work | `sf-ship [mode]` | no special argument, `skip-check`, `end la tache`/`end`/`fin`/`close task`, `all-dirty`/`ship-all`/`tout-dirty`. |
| Browser proof | `sf-browser` | Target a non-auth URL, route, preview, or production page. |
| Auth or session diagnosis | `sf-auth-debug` | Target login, OAuth, cookies, callbacks, tenants, providers, sessions, or protected routes. |
| Manual QA or retest evidence | `sf-test` | Target a guided scenario, test log, retest, or bug file update. |
| Deployment truth | `sf-prod` | Target deployment URL, build logs, runtime logs, preview/prod health, or live readiness. |
| Technical checks | `sf-check` | Target typecheck, lint, build, tests, dependency checks, or shell validation. |
| Documentation work | `sf-docs [mode or target]` | `readme`, `api`, `components`, `audit`, `update`, `metadata`, `technical`, `editorial`, or a file path. |
| Audit lane | `sf-audit*` | Choose the audit owner: code, design, copy, SEO, GTM, deps, perf, a11y, translation, components, or design tokens. |
| Design system creation | `sf-design-from-scratch [target or mode]` | Use when no coherent professional token system exists; modes include `tokens-only` and `with-playground`. |
| Dependency posture | `sf-deps` | Target dependency drift, vulnerabilities, licenses, or config. |
| Framework migration | `sf-migrate [package[@version]]` | Use a structured package target such as `astro@5`, a package name, or no argument for discovery. |
| Orientation and routing | `sf-status`, `sf-help`, `sf-model`, `sf-resume` | Use for git dashboard, workflow help, model choice, or concise context transfer. |

## Explicit Mode Switches

| Skill | Explicit modes currently documented |
| --- | --- |
| `sf-build` | `<story, bug, or goal>`; `report=agent`; `handoff`; `verbose`; `full-report` |
| `sf-maintain` | no argument/`full`; `quick`; `security`; `deps`; `docs`; `audits`; `no-ship`; `global`; detailed report modes |
| `sf-deploy` | no argument; `skip-check`; `--preview`; `--prod`; `no-changelog` |
| `sf-bug` | no argument; `BUG-ID`; free-text summary; `--fix`; `--retest`; `--verify`; `--ship`; `--close` |
| `sf-content` | no argument or content goal; `plan`; `repurpose`; `draft`; `article`; `blog`; `guide`; `enrich`; `audit`; `copy`; `copywriting`; `seo`; `editorial`; `apply`; `publish`; `ship` |
| `sf-skill-build` | new skill idea; existing skill path; `sf-explore` reroute when placement or public promise is too fuzzy |
| `sf-design-from-scratch` | no argument; target page/path; `tokens-only`; `with-playground`; detailed report modes |
| `sf-ship` | no special argument; `skip-check`; `end la tache`; `end`; `fin`; `close task`; `all-dirty`; `ship-all`; `tout-dirty` |
| `sf-audit-translate` | no special argument; file path or scope; `global`; `sync`; `apply`; `sync [path]`; `apply [path]` |

## How To Read Arguments

An argument can be one of three things:

| Argument type | Meaning | Example |
| --- | --- | --- |
| Mode keyword | A word or flag switches the workflow. | `sf-maintain quick`, `sf-deploy skip-check`, `sf-ship all-dirty` |
| Structured input | The shape of the argument selects a target. | `sf-migrate astro@5`, `sf-bug BUG-2026-05-03-001` |
| Free-form task | The argument is the actual work description. | `sf-build add a markdown skill cheatsheet` |

When in doubt, read the skill's `argument-hint` and mode-detection section. If no mode rule matches, treat the argument as a task or target description.
