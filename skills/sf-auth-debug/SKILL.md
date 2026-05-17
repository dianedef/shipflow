---
name: sf-auth-debug
description: "Debug auth, OAuth, cookies, callbacks, and sessions."
argument-hint: <bug auth, URL, provider, ou flow à diagnostiquer>
---

## Canonical Paths

Before resolving any ShipFlow-owned file, load `$SHIPFLOW_ROOT/skills/references/canonical-paths.md` (`$SHIPFLOW_ROOT` defaults to `$HOME/shipflow`). ShipFlow tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPFLOW_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Instruction Layering

This `SKILL.md` is the activation contract. Before editing or expanding this skill, load `$SHIPFLOW_ROOT/skills/references/skill-instruction-layering.md` and keep bulky workflow detail in skill-local references.

## Chantier Tracking

Trace category: `conditionnel`.
Process role: `source-de-chantier`.

Before producing the final report, load `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md`. If attached to one unique chantier spec, write the run trace there. If no unique chantier exists, do not write to a spec.

## Chantier Potential Intake

Because this skill has process role `source-de-chantier`, evaluate the standard threshold from `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md` before the final report. Add a `Chantier potentiel` block when findings reveal non-trivial future work and no unique chantier owns it.

## Report Modes

Before producing the final report, load `$SHIPFLOW_ROOT/skills/references/reporting-contract.md`.

Default to `report=user`: concise, findings-first for audits and failures, outcome-first for successful support runs, and in the user's active language. Use `report=agent`, `handoff`, `verbose`, or `full-report` only when detailed evidence is needed.

## Required References

Always load shared references only when their gate applies. Load skill-local references precisely by mode:

- `references/auth-debug-workflow.md`: Auth debug workflow, provider-reference routing, reproduction strategy, Playwright proof, Sentry/PM2 evidence, and report details.

## Mode Detection

Parse `$ARGUMENTS` and choose the smallest safe mode.

- INTAKE: load `references/auth-debug-workflow.md` to consume existing evidence and choose repro strategy.
- PROVIDER ROUTING: load the workflow reference, then load only the provider-specific references it selects.
- BROWSER PROOF: load `$SHIPFLOW_ROOT/skills/references/playwright-mcp-runtime.md` and relevant auth testing references before Playwright MCP calls.

## Core Execution Rules

- Preserve auth/session/callback/provider, tenant, cookie, redirect, token, secret, and redaction safety rules.
- Evaluate `Chantier potentiel` for auth/session/callback/provider/tenant risk beyond a direct local fix.
- Never log secrets, cookies, tokens, OTPs, private env values, or unredacted user auth data.

## Stop Conditions

Stop and report blocked when:

- A required reference is missing or contradicts this activation contract.
- The requested work would change behavior outside this skill's scope.
- A safety, security, documentation, source, claim, auth, production, redaction, or chantier guardrail would need to be weakened.
- The action would edit unrelated dirty files or mutate durable state without an owner-skill contract.

## Validation

Validate this skill after edits with:

- `rg -n "Trace category|Process role|Chantier Potential|auth|session|provider|Playwright|Sentry|redaction|references/" skills/sf-auth-debug/SKILL.md`
- `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
- `tools/shipflow_sync_skills.sh --check --all`
