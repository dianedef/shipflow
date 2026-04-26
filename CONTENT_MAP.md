---
artifact: content_map
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipFlow
created: "2026-04-26"
updated: "2026-04-26"
status: draft
source_skill: manual
scope: content-map
owner: unknown
confidence: medium
risk_level: medium
content_surfaces:
  - site_docs
  - site_skill_pages
  - repo_docs
  - decision_contracts
  - semantic_clusters
security_impact: none
docs_impact: yes
evidence:
  - "README.md lists the canonical project docs"
  - "site/src/pages/docs.astro exposes the public docs overview"
  - "site/src/content/skills contains public skill content"
  - "skills/sf-repurpose/SKILL.md needs a reusable content surface map"
linked_artifacts:
  - "README.md"
  - "PRODUCT.md"
  - "GTM.md"
  - "BRANDING.md"
  - "site/src/pages/docs.astro"
depends_on:
  - artifact: "PRODUCT.md"
    artifact_version: "1.1.0"
    required_status: "reviewed"
  - artifact: "GTM.md"
    artifact_version: "1.0.0"
    required_status: "reviewed"
supersedes: []
next_review: "2026-05-26"
next_step: "/sf-repurpose"
---

# Content Map

## Purpose

`CONTENT_MAP.md` is the editorial navigation layer for ShipFlow. It maps where content lives, what each surface is for, and how build conversations or source ideas should be repurposed without rediscovering the content structure in every thread.

It is a structural context artifact, not a content calendar or backlog.

## Content Surfaces

| Surface | Canonical path | Purpose | Format | Source of truth | Update when |
|---|---|---|---|---|---|
| Public docs overview | `site/src/pages/docs.astro` | Explain ShipFlow docs, context layer, and decision contracts in public language | Astro page | `README.md`, `shipflow-spec-driven-workflow.md` | A new official artifact or documentation role is added |
| Public skill pages | `site/src/content/skills/` | Present skills as readable public workflow pages | Markdown content collection | `skills/*/SKILL.md`, product positioning docs | A skill is added, renamed, or repositioned |
| Site landing page | `site/src/pages/index.astro` | Present ShipFlow's main offer and framework story | Astro page | `BUSINESS.md`, `PRODUCT.md`, `GTM.md`, `BRANDING.md` | Product positioning or core workflow changes |
| Repo documentation | `README.md` | Canonical repo overview, onboarding, and artifact map | Markdown | Active project artifacts and code structure | Official docs, workflows, or tooling change |
| Workflow doctrine | `shipflow-spec-driven-workflow.md` | Explain ShipFlow V3 work doctrine and artifact rules | Markdown artifact | Active skills, templates, linter behavior | Workflow or artifact doctrine changes |
| Product contract | `PRODUCT.md` | Define user problem, scope, workflows, non-goals, and risks | Markdown artifact | Product decisions and repo evidence | Product scope or core workflows change |
| GTM contract | `GTM.md` | Define public promise, channels, objections, and proof | Markdown artifact | Business/product/brand docs | Public positioning or distribution assumptions change |
| Brand contract | `BRANDING.md` | Define tone, trust posture, vocabulary, and claim boundaries | Markdown artifact | Brand decisions | Voice, vocabulary, or claim posture changes |
| Technical context | `CONTEXT.md`, `CONTEXT-FUNCTION-TREE.md` | Help agents orient in the repo and procedural hotspots | Markdown artifacts | Repo structure and major scripts | Entry points, hotspots, or routing rules change |

## Semantic Architecture

| Cluster | Pillar page | Supporting pages | Target intent | Internal link rule | Status |
|---|---|---|---|---|---|
| AI-assisted execution discipline | `site/src/pages/index.astro` | `site/src/pages/docs.astro`, `site/src/content/skills/*.md` | Understand ShipFlow as a work framework | Landing page links to docs and skills; skills link back to framework story | live |
| Documentation and decision contracts | `site/src/pages/docs.astro` | `README.md`, `shipflow-spec-driven-workflow.md`, `templates/artifacts/*.md` | Learn how context and contracts stay coherent | Docs overview points to canonical repo docs and artifact roles | live |
| Skill workflow | `site/src/pages/skills.astro` | `site/src/content/skills/*.md`, `skills/*/SKILL.md` | Choose the right skill for a task | Public skill pages should match internal skill names and promises | live |
| Content repurposing | `CONTENT_MAP.md` | `skills/sf-repurpose/SKILL.md`, `templates/artifacts/content_map.md`, future public docs section | Reuse product work and source ideas as faithful content | `sf-repurpose` reads the map first and routes output to known surfaces | draft |

## Page Roles

| Page type | Job | Must include | Must not include |
|---|---|---|---|
| Landing page | Explain the offer and drive a qualified visitor to the next action | Product name, audience, core promise, proof direction, CTA | Claims unsupported by product docs or GTM |
| Docs overview | Explain artifact roles and navigation | Context layer, decision contracts, links to canonical docs | Implementation detail better suited for repo docs |
| Public skill page | Explain a workflow in human language | Use case, outcome, when to use it | Internal-only implementation prompts |
| Repo doc | Preserve operational and product truth for contributors | Scope, commands, artifacts, current workflow | Marketing-only claims without execution relevance |
| Decision contract | Govern future implementation and audits | Metadata, evidence, scope, dependencies | Loose brainstorming or backlog items |
| Pillar page | Own a broad semantic topic | Definition, use cases, links to supporting pages | Thin overview without links |
| Supporting article | Answer a focused question or use case | Specific angle, examples, link to pillar | Duplicate the pillar |
| FAQ entry | Resolve a precise objection or question | Direct answer, caveat, next step | Long essay answer |

## Repurposing Rules

- Use `CONTENT_MAP.md` before choosing where repurposed content should go.
- Treat `README.md`, `PRODUCT.md`, `BRANDING.md`, and `GTM.md` as claim boundaries for public content.
- Use `site/src/pages/docs.astro` when the repurposed idea changes how ShipFlow documentation should be understood publicly.
- Use `site/src/content/skills/` when the repurposed idea explains a reusable skill workflow.
- Use `README.md` or `shipflow-spec-driven-workflow.md` when the change affects the canonical internal doctrine.
- Use future blog/article surfaces only after the project has a declared blog path.

## Cross-Surface Update Rules

| Trigger | Check these surfaces |
|---|---|
| New official artifact | `README.md`, `shipflow-spec-driven-workflow.md`, `tools/shipflow_metadata_lint.py`, `skills/sf-docs/SKILL.md`, `site/src/pages/docs.astro`, `site/src/components/RoleMap.astro` |
| New or renamed skill | `skills/`, `site/src/content/skills/`, public skills hub, README workflow references |
| Product positioning change | `PRODUCT.md`, `GTM.md`, `BRANDING.md`, site landing page, docs overview |
| Content repurposing output | `CONTENT_MAP.md`, target content surface, evidence ledger from `sf-repurpose` |
| New semantic cluster | Pillar page, supporting pages, internal links, FAQ/support candidates |

## Open Gaps

- [ ] No dedicated blog directory is declared yet.
- [ ] No newsletter or social publishing repository surface is declared yet.
- [ ] Content repurposing has an internal skill but no public skill page yet.
