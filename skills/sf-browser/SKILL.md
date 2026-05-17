---
name: sf-browser
description: "Check non-auth pages with browser, console, and network proof."
argument-hint: <URL, route, environment, or visible objective>
---

## Canonical Paths

Before resolving any ShipFlow-owned file, load `$SHIPFLOW_ROOT/skills/references/canonical-paths.md` (`$SHIPFLOW_ROOT` defaults to `$HOME/shipflow`). ShipFlow tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPFLOW_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Chantier Tracking

Trace category: `conditionnel`.
Process role: `source-de-chantier`.

Before producing the final report, load `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md` when this run is attached to a spec-first chantier. If exactly one active `specs/*.md` chantier is identified, append the current run to `Skill Run History`, update `Current Chantier Flow` when the run changes the chantier state, and include a final `Chantier` block. If no unique chantier is identified, do not write to any spec; report `Chantier: non applicable` or `Chantier: non trace` with the reason.

## Chantier Potential Intake

Because this skill has process role `source-de-chantier`, evaluate the standard threshold from `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md` before the final report. If the browser evidence reveals non-trivial future work and no unique chantier owns it, do not write to an existing spec; add a `Chantier potentiel` block with `oui`, `non`, or `incertain`, a proposed title, reason, severity, scope, evidence, recommended `/sf-spec ...` command, and next step. If the finding is only informational, a narrow direct fix, or already belongs to the current chantier, state `Chantier potentiel: non` with the concrete reason.

## Purpose

`sf-browser` answers one question:

```text
What did a real browser actually see on this target for this objective?
```

Use it for one-off browser navigation, visual checks, accessibility snapshots, screenshots, console summaries, network summaries, and visible assertions on local, preview, or production surfaces.

Do not use it as the specialist for auth, manual QA, deployment discovery, production logs, or code fixes:
- Auth, OAuth, cookies, sessions, callbacks, tenants, and protected-route breaks route to `/sf-auth-debug`.
- Full manual QA campaigns, retests, `TEST_LOG.md`, bug files, and optional `BUGS.md` triage views route to `/sf-test`.
- Deployment URL discovery, Vercel status, build logs, runtime logs, and live deploy readiness route to `/sf-prod`.
- Actionable code bugs route to `/sf-fix` or `/sf-start`.

## Required References

Always load these before browser work:
- `$SHIPFLOW_ROOT/skills/references/canonical-paths.md`
- `$SHIPFLOW_ROOT/skills/references/playwright-mcp-runtime.md`

Load `references/browser-evidence.md` when the request involves console/network evidence, screenshots, production data, redaction, sensitive output, uncertain verdicts, or localized report wording.

Load `$SHIPFLOW_ROOT/skills/references/sentry-observability.md` when the browser check sees a crash, error boundary, 5xx, unhandled console exception, or visible Sentry/support event ID. Skills do not have direct Sentry dashboard access; use only visible/supplied issue or event pointers.

Read `$SHIPFLOW_ROOT/skills/references/project-development-mode.md` and inspect `CLAUDE.md` or `SHIPFLOW.md` before treating local browser proof as authoritative for changed behavior.

## Input Triage

Accept:
- full URL
- route plus derivable local or deployed base URL
- local project page
- Vercel preview or production URL
- visible assertion such as `verify that the pricing card appears`
- console or network objective
- viewport preference
- optional screenshot request

If no URL or target can be derived, ask one focused question for the target URL or route.

Route instead of continuing when:
- the objective mentions Clerk, Supabase Auth, OAuth, login, callback, cookies, session, tenant, protected route, or auth provider behavior -> `/sf-auth-debug`
- the user asks for a full manual user-flow test, durable QA log, or bug file -> `/sf-test`
- the deployment URL is unknown or unconfirmed -> `/sf-prod`
- preview-push validation is required but the change has not been shipped -> `/sf-ship`, then `/sf-prod`
- the request is broad, such as "check everything" -> ask for one observable objective or route to `/sf-test`
- the requested action can buy, delete, publish, send email, change account data, write production data, or trigger external side effects -> ask for explicit approval or route to a safe test environment

## Browser Runtime Preflight

Before the first `mcp__playwright__*` tool call, apply `$SHIPFLOW_ROOT/skills/references/playwright-mcp-runtime.md`.

Stop browser proof when:
- Playwright MCP config is stale or unsafe.
- Linux ARM64 config falls back to Google Chrome stable or `/opt/google/chrome/chrome`.
- Config is correct but the current MCP process still reports `/opt/google/chrome/chrome`.

In those cases, do not diagnose the app. Report the runtime blocker and route to `/sf-fix BUG-2026-05-02-001` or request a Codex/MCP reload as the runtime reference requires.

## Verification Flow

1. Identify target, environment, requested objective, development mode, and allowed interaction level.
2. Run Playwright MCP runtime preflight.
3. Navigate to the target.
4. Capture an accessibility snapshot first when useful.
5. Capture a screenshot only when visual evidence adds value or the user asks for it.
6. Review console messages or network requests only when relevant to the objective or when visible evidence is partial.
7. If a Sentry/support event ID is visible or supplied, correlate only that issue/event pointer and summarize it without raw payloads.
8. Avoid raw dumps. Prefer targeted, redacted summaries.
9. Decide a narrow verdict for the requested objective only.
10. Route the next step based on the evidence.

## Read-Only Default

The default policy is `read-only`.

Allowed by default:
- navigation
- viewport resize
- accessibility snapshot
- screenshot
- console summary
- network request summary
- reversible clicks such as opening menus, tabs, accordions, or local navigation

Not allowed without explicit approval:
- form submission that creates or changes data
- purchase, deletion, publish, invite, email, webhook, billing, account, or production mutation
- bypassing auth walls, provider protections, consent flows, captchas, MFA, passkeys, or anti-bot controls
- reading or reporting cookies, localStorage, sessionStorage, tokens, complete headers, raw HAR data, private payloads, or PII

## Report Contract

Report in the user's active language. Keep stable labels, commands, and machine anchors in English.

## Language Doctrine

Internal instructions, workflow rules, stable headings, stop conditions, acceptance criteria, and validation notes stay in English. User-facing observations and explanations use the user's active language; French output must be natural and accented while command names, paths, stable labels, and verdict labels remain English.

Every final report must include:
- `Target`
- `Environment`
- `Playwright MCP runtime`
- `Objective`
- `Observed`
- `Verdict`
- `Evidence`
- `Limits`
- `Next step`

Verdict labels:
- `pass`
- `fail`
- `partial`
- `blocked`
- `needs-auth`
- `needs-deploy`
- `needs-manual-test`
- `unsafe-action`

Success is never silent. Failure is never silent. If evidence is missing, name the missing proof and why it could not be collected.

## Handoff Rules

- Auth wall or auth objective -> `/sf-auth-debug [target or bug]`
- Unconfirmed deploy or missing preview URL -> `/sf-prod [project or URL]`
- Preview-push project with unshipped changes -> `/sf-ship [scope]`, then `/sf-prod [project or URL]`
- Full manual flow or durable QA evidence -> `/sf-test [scope]`
- Narrow actionable bug -> `/sf-fix [summary]`
- Non-trivial or cross-system follow-up -> `/sf-spec [title and compact context]`
- Implementation verification gap -> `/sf-verify [scope]`

## Security And Redaction

Redact secrets, cookies, tokens, credentials, private emails, account identifiers, sensitive request headers, private payloads, and production PII.

If a screenshot or snapshot may expose sensitive data, summarize the relevant visible state instead of embedding or persisting the sensitive evidence.

If a finding crosses the chantier threshold, report `Chantier potentiel` and route to `/sf-spec`. Do not write `BUGS.md`, `bugs/`, `TEST_LOG.md`, `TASKS.md`, `AUDIT_LOG.md`, or `PROJECTS.md` from this skill.

## Final Report Shape

```text
## Browser Verification: [objective]

Target: [URL]
Environment: [local / preview / production / unknown]
Playwright MCP runtime: [executable-path ... / chromium fallback / blocked stale config]
Objective: [requested assertion]
Observed: [short factual observation]
Verdict: [pass / fail / partial / blocked / needs-auth / needs-deploy / needs-manual-test / unsafe-action]
Evidence:
- [snapshot/screenshot/console/network summary]
- [Sentry issue/event summary or limit, when relevant]
Limits:
- [what was not proven]
Next step:
- [ShipFlow command or none]

## Chantier potentiel

Chantier potentiel: [oui / non / incertain]
Titre propose: [title or None]
Raison: [threshold reason]
Severite: [P0 / P1 / P2 / P3 / unknown]
Scope: [files/projects/domains/workflows affected]
Evidence:
- [browser finding or blocker]
Spec recommandee: [/sf-spec ... or None]
Prochaine etape: [next command or none]

## Chantier

Skill courante: sf-browser
Chantier: [spec path | non applicable | non trace]
Trace spec: [ecrite | non ecrite | non applicable]
Flux:
- sf-spec: [status]
- sf-ready: [status]
- sf-start: [status]
- sf-verify: [status]
- sf-end: [status]
- sf-ship: [status]

Reste a faire:
- [item or None]

Prochaine etape:
- [next command or explicit none]

Verdict sf-browser:
- [pass | fail | partial | blocked | rerouted]
```
