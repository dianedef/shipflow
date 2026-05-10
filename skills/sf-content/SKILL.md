---
name: sf-content
description: "Content lifecycle."
argument-hint: '[goal | source | file | mode: plan, repurpose, draft, enrich, audit, seo, editorial, apply, ship]'
---

## Canonical Paths

Before resolving any ShipFlow-owned file, load `$SHIPFLOW_ROOT/skills/references/canonical-paths.md` (`$SHIPFLOW_ROOT` defaults to `$HOME/shipflow`). ShipFlow tools, shared references, skill-local `references/*`, templates, workflow docs, internal scripts, and public skill content must resolve from `$SHIPFLOW_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Chantier Tracking

Trace category: `obligatoire`.
Process role: `lifecycle`.

Before executing from a spec-first chantier, load `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md`, read the spec's `Skill Run History` and `Current Chantier Flow`, append a current `sf-content` row with result `implemented`, `partial`, `blocked`, or `rerouted`, update `Current Chantier Flow`, and end with the compact `Chantier` block from `$SHIPFLOW_ROOT/skills/references/reporting-contract.md`.

If no unique chantier spec is identified, do not write to any spec. Route to `/sf-explore <content idea>` when the content intent, surface, source, or public promise is too fuzzy to frame a ready spec. Route to `/sf-spec <content lifecycle title>` when the work is non-trivial, multi-surface, claim-sensitive, or requires a new content surface.

## Report Modes

Before producing the final report, load `$SHIPFLOW_ROOT/skills/references/reporting-contract.md`.

Default to `report=user`: concise, outcome-first, and using the compact chantier block. Use `report=agent`, `handoff`, `verbose`, or `full-report` only when another agent needs file lists, validation matrices, source evidence, or unresolved gate state.

## Master Delegation

Before choosing execution topology, load `$SHIPFLOW_ROOT/skills/references/master-delegation-semantics.md`.

This skill follows that reference; local nuances below only narrow or route it. Content lifecycle work defaults to delegated sequential when reading, drafting, editing, validating, applying public-content updates, or preparing ship. Parallel content work is allowed only from ready `Execution Batches` with non-overlapping surfaces.

## Master Workflow Lifecycle

Before resolving content phases, load `$SHIPFLOW_ROOT/skills/references/master-workflow-lifecycle.md`.

Use the shared skeleton for intake, content work item resolution, readiness, model/topology routing, owner-skill execution, validation, verification, and post-verify ship routing. Local sections below define content surfaces, owner routes, and public-claim gates only.

## Mission

`sf-content` is the master lifecycle for content management. It decides which content lane should run, applies governance gates, and carries content work toward validation and ship routing.

It orchestrates existing owner skills:

```text
sf-veille / sf-research / sf-market-study
  -> CONTENT_MAP + editorial corpus
  -> sf-explore or sf-spec when needed
  -> sf-repurpose / sf-redact / sf-enrich
  -> sf-audit-copy / sf-audit-copywriting / sf-audit-seo
  -> sf-docs
  -> site/build/browser evidence when public
  -> sf-verify
  -> sf-ship when scope is bounded
```

The goal is not to write all content inside this master skill. The goal is to keep intent, surfaces, evidence, claims, specialist ownership, validation, and shipping coherent.

## Scope Gate

Accepted scope:

- content strategy routing
- source-faithful repurposing lifecycle
- long-form drafting lifecycle
- existing-content enrichment lifecycle
- copy, copywriting, SEO, and docs audit routing
- public site, README, FAQ, public docs, public skill pages, future article/blog governance
- content validation and ship routing

Rejected scope:

- generic writing without source, audience, or surface
- inventing undeclared blog, newsletter, CMS, RSS, social, or support paths
- replacing `sf-repurpose`, `sf-redact`, `sf-enrich`, `sf-audit-copy`, `sf-audit-copywriting`, `sf-audit-seo`, `sf-docs`, `sf-veille`, or `sf-market-study`
- publishing unsupported sensitive claims
- changing runtime content schemas without a dedicated spec
- committing or pushing unrelated dirty files

## Entry Rules

1. Resolve the input as one or more of: content goal, source, target surface, file path, mode keyword, or ship request.
2. Load `shipflow_data/editorial/content-map.md` if present, otherwise fallback to `CONTENT_MAP.md`.
3. Load `$SHIPFLOW_ROOT/skills/references/editorial-content-corpus.md` when the work touches public content, README public promises, docs, FAQ, pricing, support copy, public skill pages, blog/article intent, claims, or runtime content.
4. Check `shipflow_data/editorial/claim-register.md` (or `docs/editorial/claim-register.md`), `shipflow_data/editorial/page-intent-map.md` (or `docs/editorial/page-intent-map.md`), `shipflow_data/editorial/editorial-update-gate.md` (or `docs/editorial/editorial-update-gate.md`), and `shipflow_data/editorial/astro-content-schema-policy.md` (or `docs/editorial/astro-content-schema-policy.md`) when present.
5. If no source, goal, or target can be inferred, ask one targeted question. Do not draft generic content from nothing.

## Mode Detection

- `plan`, `strategy`, `calendar`, `content plan`: produce a routed content plan; use `sf-spec` when it becomes multi-surface or durable.
- `repurpose`, `source`, `conversation`, `faq`, `release notes`, `site update`: route to `sf-repurpose`.
- `draft`, `write`, `article`, `blog`, `guide`, `editorial`: route to `sf-redact` after blog/article surface and claim gates.
- `enrich`, `refresh`, `update @file`, `improve`: route to `sf-enrich`.
- `audit`, `copy`, `copywriting`, `seo`: route to `sf-audit-copy`, `sf-audit-copywriting`, and/or `sf-audit-seo`.
- `docs`, `readme`, `editorial`, `content governance`: route to `sf-docs`, usually `sf-docs editorial` for governance.
- `veille`, URLs, pasted external trend/source content: route to `sf-veille`, `sf-research`, or `sf-market-study` before content production.
- `apply`, `publish`, `ship`: verify the content changes, run required validations, then route to `sf-verify` and `sf-ship` only when scope is bounded.

If several modes match, choose the earliest missing lifecycle phase:

```text
source unclear -> veille/research/explore
surface unclear -> CONTENT_MAP/editorial gate/spec
source ready -> repurpose
draft needed -> redact
existing content needs improvement -> enrich
quality unknown -> audit
public docs/governance impacted -> docs
changes applied -> verify/ship
```

## Spec Gate

Apply the shared readiness rules from `$SHIPFLOW_ROOT/skills/references/master-workflow-lifecycle.md`.

Use spec-first when any of these are true:

- multiple public surfaces are affected
- a new content surface, route, collection, newsletter, social repository, or blog path is needed
- sensitive public claims are added, strengthened, or repositioned
- content strategy, SEO architecture, funnel narrative, pricing copy, or support copy changes materially
- parallel content work would touch shared maps, public pages, shared components, `site/src/content.config.ts`, README, FAQ, docs overview, pricing, or claim register
- the work needs validation or ship routing beyond one direct local edit

Route to `/sf-explore <idea>` before `/sf-spec` when content intent, audience, source truth, or surface placement is too fuzzy for one targeted question to settle.

## Content Governance Gate

For public or potentially public content:

1. Read `shipflow_data/editorial/content-map.md` when present, else `CONTENT_MAP.md`.
2. Read `$SHIPFLOW_ROOT/skills/references/editorial-content-corpus.md` when available.
3. Check `shipflow_data/editorial/public-surface-map.md` (or `docs/editorial/public-surface-map.md`) and `shipflow_data/editorial/page-intent-map.md` (or `docs/editorial/page-intent-map.md`) before changing public pages.
4. Check `shipflow_data/editorial/claim-register.md` (or `docs/editorial/claim-register.md`) before publishing sensitive claims.
5. Check `shipflow_data/editorial/blog-and-article-surface-policy.md` (or `docs/editorial/blog-and-article-surface-policy.md`) before article or blog output.
6. Check `shipflow_data/editorial/astro-content-schema-policy.md` (or `docs/editorial/astro-content-schema-policy.md`) before editing runtime content.
7. Produce an `Editorial Update Plan` from `shipflow_data/editorial/editorial-update-gate.md` (or `docs/editorial/editorial-update-gate.md`) when public content, page intent, README, FAQ, pricing, public docs, public skill pages, or claims are impacted.
8. Produce a `Claim Impact Plan` when sensitive claims are impacted.

If no declared blog/article surface exists, report `surface missing: blog` and stop before path creation.

## Owner Skill Routing

Route by owner, not convenience:

| Need | Owner |
| --- | --- |
| External URL/source triage | `sf-veille` |
| Deep research report | `sf-research` |
| Market/keyword/competitor demand study | `sf-market-study` |
| Source-faithful content pack or applied repurposing | `sf-repurpose` |
| Original long-form article, guide, or editorial draft | `sf-redact` |
| Upgrade existing content with research and better structure | `sf-enrich` |
| Clarity, tone, CTA, and page-level copy audit | `sf-audit-copy` |
| Persona, offer, persuasion, and conversion audit | `sf-audit-copywriting` |
| Technical/on-page SEO and search intent audit | `sf-audit-seo` |
| README/docs/content governance update | `sf-docs` |
| Implementation of non-trivial site/content changes | `sf-build` or `sf-start` from a ready spec |
| Public browser proof | `sf-browser` |
| Verification | `sf-verify` |
| Ship | `sf-ship` |

When calling or simulating downstream owner skills, pass `report=agent` only when the master flow needs detailed evidence. Preserve concise user reporting by default.

## Validation

Run the checks that match changed surfaces.

For ShipFlow skill or workflow changes:

```bash
python3 tools/skill_budget_audit.py --skills-root skills --format markdown
"${SHIPFLOW_ROOT:-$HOME/shipflow}/tools/shipflow_sync_skills.sh" --check --skill sf-content
```

For ShipFlow docs/specs/content-map artifacts:

```bash
python3 tools/shipflow_metadata_lint.py specs README.md shipflow-spec-driven-workflow.md shipflow_data/editorial/content-map.md shipflow_data/business/business.md shipflow_data/business/product.md shipflow_data/business/branding.md shipflow_data/business/gtm.md shipflow_data/technical/context.md docs/technical docs/editorial docs/skill-launch-cheatsheet.md
```

For public site or runtime content:

```bash
npm --prefix site run build
```

For public-claim and leak scans:

```bash
rg -n "secret|token|credential|private key|BEGIN .*KEY" README.md shipflow_data/editorial/content-map.md CONTENT_MAP.md docs site/src skills
rg -n "surface missing: blog|Editorial Update Plan|Claim Impact Plan|Astro content schema|claim register" shipflow_data/editorial/content-map.md CONTENT_MAP.md docs/editorial shipflow_data/editorial skills site/src/content/skills
```

Use `sf-browser` when public visual or route behavior needs observed browser evidence. Use `sf-prod` only for deployed truth and `sf-auth-debug` only for auth/session flows.

## Fresh Docs Gate

When a content task depends on current external framework/runtime/provider behavior, run the Documentation Freshness Gate from `$SHIPFLOW_ROOT/skills/references/documentation-freshness-gate.md`.

Record one explicit verdict:

- `fresh-docs checked`
- `fresh-docs not needed`
- `fresh-docs gap`
- `fresh-docs conflict`

For OpenAI, SDK, framework, SEO/AEO, crawler, analytics, or platform claims, use the relevant official docs or owner skill freshness rules before publishing current claims.

## Security and Abuse Constraints

- Treat public claims as product promises.
- Never publish secrets, private URLs, internal logs, tokens, credentials, private keys, or sensitive operational details.
- Never present roadmap or speculative content as shipped behavior.
- Never strengthen security, privacy, compliance, AI reliability, automation quality, speed, savings, availability, pricing, or business outcome claims without evidence.
- Never add ShipFlow governance frontmatter to runtime content unless the schema accepts it.
- Never ship with unrelated dirty files unless the user explicitly authorizes wider scope.
- Never create content paths outside the declared surfaces without a spec or explicit surface decision.

## Stop Conditions

Stop and report `blocked` when:

- no source, goal, or surface can be inferred and the user has not answered a targeted question
- a blog/article/newsletter/social/support surface is requested but undeclared
- content strategy or public claims require a spec and readiness is not `ready`
- an owner skill should handle the work and bypassing it would duplicate specialist responsibility
- the claim register marks a claim `blocked`, `needs proof`, or `claim mismatch`
- runtime content schema would be violated
- public site build fails
- metadata lint fails on changed artifacts
- skill budget audit fails hard for skill changes
- runtime skill links are missing, stale, or blocked by non-symlink files
- verification fails
- ship scope includes unrelated dirty files without explicit approval

## Final Report

Use `report=user` by default:

```text
## Content Lifecycle: [goal or surface]

Result: [implemented / partial / blocked / rerouted]
Route: [owner skills used or next owner skill]
Checks: [passed / failed / skipped with reason]
Editorial: [complete / no editorial impact / blocked]
Fresh external docs: [checked / not needed / gap / conflict]
Next step: [only when real]

## Chantier

[spec path | non trace: reason]

Flux: sf-spec [marker] -> sf-ready [marker] -> sf-start [marker] -> sf-verify [marker] -> sf-end [marker] -> sf-ship [marker]
Reste a faire: [only if non-empty]
Prochaine etape: [only if non-empty]
```

Use `report=agent` for handoff details: file list, source evidence, owner-skill reports, validation matrix, unresolved claim risks, and exact next command.

## Rules

- Orchestrate; do not duplicate specialist internals.
- Keep content source truth separate from public claims.
- Prefer declared surfaces over invented paths.
- Ask only targeted questions when the answer changes mode, surface, scope, security, claims, or ship posture.
- Use spec-first for non-trivial or public-claim-sensitive content work.
- Follow the shared master delegation reference for delegated sequential defaults and spec/batch-gated parallelism.
- Preserve runtime schemas.
- Validate before ship routing.
