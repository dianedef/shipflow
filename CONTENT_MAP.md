---
artifact: content_map
metadata_schema_version: "1.0"
artifact_version: "0.6.0"
project: ShipFlow
created: "2026-04-26"
updated: "2026-05-04"
status: draft
source_skill: manual
scope: content-map
owner: unknown
confidence: medium
risk_level: medium
content_surfaces:
  - site_docs
  - site_skill_pages
  - site_skill_modes
  - repo_skill_launch_cheatsheet
  - repo_docs
  - decision_contracts
  - canonical_path_policy
  - editorial_governance
  - claim_register
  - page_intent
  - semantic_clusters
  - content_lifecycle
security_impact: none
docs_impact: yes
evidence:
  - "README.md lists the canonical project docs"
  - "site/src/pages/docs.astro exposes the public docs overview"
  - "site/src/content/skills contains public skill content"
  - "skills/sf-repurpose/SKILL.md needs a reusable content surface map"
  - "skills/references/canonical-paths.md defines ShipFlow-owned path resolution"
  - "Corrected public skill page route paths against site/src/pages/skills/ on 2026-05-01"
  - "docs/editorial/ added as the public-content governance layer for surface impact, claims, page intent, Astro schema policy, and blog/article stop conditions"
  - "site/src/pages/skill-modes.astro now owns the public launch cheatsheet for master and supporting skill modes"
  - "docs/skill-launch-cheatsheet.md added as the standalone Markdown reference for skill launch modes"
  - "sf-content added as the master content lifecycle entrypoint."
linked_artifacts:
  - "README.md"
  - "PRODUCT.md"
  - "GTM.md"
  - "BRANDING.md"
  - "docs/editorial/README.md"
  - "docs/skill-launch-cheatsheet.md"
  - "site/src/pages/docs.astro"
  - "site/src/pages/skill-modes.astro"
  - "skills/references/canonical-paths.md"
depends_on:
  - artifact: "PRODUCT.md"
    artifact_version: "1.1.0"
    required_status: "reviewed"
  - artifact: "GTM.md"
    artifact_version: "1.1.0"
    required_status: "reviewed"
supersedes: []
next_review: "2026-05-26"
next_step: "/sf-repurpose"
---

# Content Map

## Purpose

`CONTENT_MAP.md` is the editorial navigation layer for ShipFlow. It maps where content lives, what each surface is for, and how build conversations or source ideas should be repurposed without rediscovering the content structure in every thread.

It is a structural context artifact, not a content calendar or backlog.

For public-content governance details, use `docs/editorial/` after this map. That layer owns public surface impact, page intent, claim boundaries, Astro content schema policy, editorial update gates, and blog/article stop conditions.

## Content Surfaces

| Surface | Canonical path | Purpose | Format | Source of truth | Update when |
|---|---|---|---|---|---|
| Public docs overview | `site/src/pages/docs.astro` | Explain ShipFlow docs, context layer, and decision contracts in public language | Astro page | `README.md`, `shipflow-spec-driven-workflow.md` | A new official artifact or documentation role is added |
| Public skill pages | `site/src/content/skills/` | Present skills as readable public workflow pages | Markdown content collection | `skills/*/SKILL.md`, product positioning docs | A skill is added, renamed, or repositioned |
| Skill launch cheatsheet | `site/src/pages/skill-modes.astro` | Explain which master/support skill to launch and how mode arguments change workflow behavior | Astro page | `docs/skill-launch-cheatsheet.md`, `shipflow-spec-driven-workflow.md`, `README.md`, `skills/*/SKILL.md`, public skill pages | Skill inventory, master skill modes, argument contracts, or lifecycle routing changes |
| Skill launch Markdown reference | `docs/skill-launch-cheatsheet.md` | Preserve the repo Markdown version of master skills, supporting skills, and explicit mode switches | Markdown artifact | `shipflow-spec-driven-workflow.md`, `skills/*/SKILL.md`, public skill pages | Skill inventory, master skill modes, argument contracts, or lifecycle routing changes |
| Site landing page | `site/src/pages/index.astro` | Present ShipFlow's main offer and framework story | Astro page | `BUSINESS.md`, `PRODUCT.md`, `GTM.md`, `BRANDING.md` | Product positioning or core workflow changes |
| Repo documentation | `README.md` | Canonical repo overview, onboarding, and artifact map | Markdown | Active project artifacts and code structure | Official docs, workflows, or tooling change |
| Workflow doctrine | `shipflow-spec-driven-workflow.md` | Explain ShipFlow V3 work doctrine and artifact rules | Markdown artifact | Active skills, templates, linter behavior | Workflow or artifact doctrine changes |
| Canonical path policy | `skills/references/canonical-paths.md` | Define how skills resolve ShipFlow-owned tools, references, templates, and project-local artifacts | Markdown reference artifact | ShipFlow install root and skill execution behavior | A skill, tool, template, or reference path rule changes |
| Editorial governance | `docs/editorial/` | Govern public-content impact, claims, page intent, Astro runtime schema boundaries, and missing blog/article surfaces | Markdown governance artifacts | `CONTENT_MAP.md`, business/product/brand/GTM contracts, site routes, content schema | A public surface, public claim, content schema policy, or editorial gate changes |
| Editorial Reader role | `skills/references/subagent-roles/editorial-reader.md` | Diagnose public-content and claim impact without editing files | Markdown role contract | `skills/references/editorial-content-corpus.md`, `docs/editorial/` | Reader output format, public-content gate, or role boundaries change |
| Content lifecycle skill | `skills/sf-content/SKILL.md` | Orchestrate content strategy, repurposing, drafting, enrichment, audits, docs, validation, and ship routing | Skill contract | `CONTENT_MAP.md`, `docs/editorial/`, specialist content skills | Content-management lifecycle, owner-skill routing, or public content validation gates change |
| Product contract | `PRODUCT.md` | Define user problem, scope, workflows, non-goals, and risks | Markdown artifact | Product decisions and repo evidence | Product scope or core workflows change |
| GTM contract | `GTM.md` | Define public promise, channels, objections, and proof | Markdown artifact | Business/product/brand docs | Public positioning or distribution assumptions change |
| Brand contract | `BRANDING.md` | Define tone, trust posture, vocabulary, and claim boundaries | Markdown artifact | Brand decisions | Voice, vocabulary, or claim posture changes |
| Technical context | `CONTEXT.md`, `CONTEXT-FUNCTION-TREE.md` | Help agents orient in the repo and procedural hotspots | Markdown artifacts | Repo structure and major scripts | Entry points, hotspots, or routing rules change |

## Semantic Architecture

| Cluster | Pillar page | Supporting pages | Target intent | Internal link rule | Status |
|---|---|---|---|---|---|
| AI-assisted execution discipline | `site/src/pages/index.astro` | `site/src/pages/docs.astro`, `site/src/content/skills/*.md` | Understand ShipFlow as a work framework | Landing page links to docs and skills; skills link back to framework story | live |
| Documentation and decision contracts | `site/src/pages/docs.astro` | `README.md`, `shipflow-spec-driven-workflow.md`, `skills/references/canonical-paths.md`, `templates/artifacts/*.md` | Learn how context and contracts stay coherent | Docs overview points to canonical repo docs and artifact roles | live |
| Skill workflow | `site/src/pages/skills/index.astro`, `site/src/pages/skills/[slug].astro`, `site/src/pages/skill-modes.astro`, `docs/skill-launch-cheatsheet.md` | `site/src/content/skills/*.md`, `skills/*/SKILL.md` | Choose the right skill for a task | Public skill pages should match internal skill names and promises; the skill modes page and Markdown reference own launch and argument-mode routing | live |
| Remote agent operations | `site/src/pages/remote-mcp-oauth-tunnel.astro` | `site/src/pages/docs.astro`, `README.md`, `local/README.md`, `specs/local-mcp-oauth-tunnel-login.md` | Understand why remote agents need local callback routing for OAuth MCP login | Dedicated guide owns the SEO topic; docs overview points to it; repo docs point operators to the local guided setup | live |
| Content lifecycle and repurposing | `CONTENT_MAP.md`, `site/src/content/skills/sf-content.md` | `skills/sf-content/SKILL.md`, `skills/sf-repurpose/SKILL.md`, `skills/sf-redact/SKILL.md`, `skills/sf-enrich/SKILL.md`, `docs/editorial/`, future public docs section | Manage content strategy, source reuse, drafting, enrichment, audits, and ship validation without inventing undeclared surfaces | `sf-content` starts with this map and the editorial layer, then routes to specialist content skills such as `sf-repurpose` | live |
| Editorial governance | `docs/editorial/README.md` | `docs/editorial/public-surface-map.md`, `docs/editorial/page-intent-map.md`, `docs/editorial/claim-register.md`, `docs/editorial/editorial-update-gate.md`, `docs/editorial/astro-content-schema-policy.md`, `docs/editorial/blog-and-article-surface-policy.md` | Keep public pages, README, FAQ, skill pages, claims, and future articles aligned with product truth | Public-content work starts at `CONTENT_MAP.md`, then uses the editorial layer for gates and evidence | live |

## Page Roles

| Page type | Job | Must include | Must not include |
|---|---|---|---|
| Landing page | Explain the offer and drive a qualified visitor to the next action | Product name, audience, core promise, proof direction, CTA | Claims unsupported by product docs or GTM |
| Docs overview | Explain artifact roles and navigation | Context layer, decision contracts, links to canonical docs | Implementation detail better suited for repo docs |
| Public skill page | Explain a workflow in human language | Use case, outcome, when to use it | Internal-only implementation prompts |
| Skill launch cheatsheet | Explain which skill to launch and which arguments switch modes | Master skills, supporting lanes, documented mode switches | Full internal prompt contracts or exhaustive implementation detail |
| Repo doc | Preserve operational and product truth for contributors | Scope, commands, artifacts, current workflow | Marketing-only claims without execution relevance |
| Decision contract | Govern future implementation and audits | Metadata, evidence, scope, dependencies | Loose brainstorming or backlog items |
| Pillar page | Own a broad semantic topic | Definition, use cases, links to supporting pages | Thin overview without links |
| Supporting article | Answer a focused question or use case | Specific angle, examples, link to pillar | Duplicate the pillar |
| FAQ entry | Resolve a precise objection or question | Direct answer, caveat, next step | Long essay answer |

## Repurposing Rules

- Use `CONTENT_MAP.md` before choosing where repurposed content should go.
- Use `docs/editorial/` after this map when a change affects public content, page intent, public claims, Astro runtime content, or blog/article output.
- Treat `README.md`, `PRODUCT.md`, `BRANDING.md`, and `GTM.md` as claim boundaries for public content.
- Treat `docs/editorial/claim-register.md` as the register for sensitive public claims.
- Treat `docs/editorial/page-intent-map.md` as the route-level intent map for public Astro pages.
- Treat `docs/editorial/astro-content-schema-policy.md` as the rule for runtime content schema preservation.
- Use `site/src/pages/docs.astro` when the repurposed idea changes how ShipFlow documentation should be understood publicly.
- Use `site/src/content/skills/` when the repurposed idea explains a reusable skill workflow.
- Use `README.md` or `shipflow-spec-driven-workflow.md` when the change affects the canonical internal doctrine.
- Use future blog/article surfaces only after the project has a declared blog path; otherwise report `surface missing: blog`.

## Cross-Surface Update Rules

| Trigger | Check these surfaces |
|---|---|
| New official artifact | `README.md`, `shipflow-spec-driven-workflow.md`, `tools/shipflow_metadata_lint.py`, `skills/references/canonical-paths.md`, `skills/sf-docs/SKILL.md`, `site/src/pages/docs.astro`, `site/src/components/RoleMap.astro` |
| New or renamed skill | `skills/`, `site/src/content/skills/`, public skills hub, README workflow references |
| Product positioning change | `PRODUCT.md`, `GTM.md`, `BRANDING.md`, site landing page, docs overview |
| Public content, claim, FAQ, pricing, docs, README, or skill promise change | `CONTENT_MAP.md`, `docs/editorial/public-surface-map.md`, `docs/editorial/page-intent-map.md`, `docs/editorial/claim-register.md`, `docs/editorial/editorial-update-gate.md`, target public surface |
| Astro runtime content edit | `site/src/content.config.ts`, `docs/editorial/astro-content-schema-policy.md`, target content collection, public route renderer |
| Blog or article request | `docs/editorial/blog-and-article-surface-policy.md`, `CONTENT_MAP.md`, declared Astro route/content collection; if absent report `surface missing: blog` |
| Content lifecycle or repurposing output | `sf-content`, `CONTENT_MAP.md`, `docs/editorial/`, target content surface, evidence ledger from `sf-repurpose` |
| New semantic cluster | Pillar page, supporting pages, internal links, FAQ/support candidates |
| Local tunnel or remote OAuth workflow change | `README.md`, `local/README.md`, `site/src/pages/docs.astro`, `site/src/pages/remote-mcp-oauth-tunnel.astro`, `CONTENT_MAP.md`, `specs/local-mcp-oauth-tunnel-login.md` |

## Open Gaps

- [ ] No dedicated blog directory is declared yet.
- [ ] No newsletter or social publishing repository surface is declared yet.
