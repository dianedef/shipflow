---
artifact: editorial_content_context
metadata_schema_version: "1.0"
artifact_version: "1.2.0"
project: ShipFlow
created: "2026-05-01"
updated: "2026-05-04"
status: reviewed
source_skill: sf-start
scope: public-surface-map
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
content_surfaces:
  - public_site
  - repo_docs
  - public_skill_pages
  - faq_support
  - future_blog
claim_register: docs/editorial/claim-register.md
page_intent: docs/editorial/page-intent-map.md
linked_systems:
  - CONTENT_MAP.md
  - site/src/pages/
  - site/src/components/
  - site/src/content/skills/
  - README.md
depends_on:
  - artifact: "CONTENT_MAP.md"
    artifact_version: "0.5.0"
    required_status: draft
  - artifact: "PRODUCT.md"
    artifact_version: "1.1.0"
    required_status: reviewed
  - artifact: "GTM.md"
    artifact_version: "1.1.0"
    required_status: reviewed
supersedes: []
evidence:
  - "Inventory of site/src/pages, site/src/components, site/src/content/skills, README, and CONTENT_MAP.md."
  - "Skill modes tutorial repositioned as the public launch cheatsheet for master and supporting skill modes."
  - "docs/skill-launch-cheatsheet.md added as the Markdown version of the skill launch reference."
next_review: "2026-06-01"
next_step: "/sf-verify ShipFlow Editorial Content Governance Layer for AI Agents"
---

# Public Surface Map

## Purpose

This map lists ShipFlow's public content surfaces, the source contracts that bound them, and the update triggers agents must check before closing a workstream.

`CONTENT_MAP.md` remains the canonical surface map. This document adds operational detail for public-content impact analysis.

## Current Public Surfaces

| Surface | Canonical path | Public role | Source contracts | Update triggers | Validation |
| --- | --- | --- | --- | --- | --- |
| Landing page | `site/src/pages/index.astro` plus homepage components | Explain the offer and route visitors to skills, docs, pricing, FAQ, and GitHub | `BUSINESS.md`, `PRODUCT.md`, `BRANDING.md`, `GTM.md`, `README.md` | Product promise, positioning, proof, pricing hypothesis, FAQ, or framework story changes | `npm --prefix site run build`; claim register review |
| About page | `site/src/pages/about.astro` | Explain why ShipFlow exists and who it serves | `BUSINESS.md`, `PRODUCT.md`, `BRANDING.md` | Audience, mission, or proof posture changes | Build plus claim review |
| Contact page | `site/src/pages/contact.astro` | Give a lightweight contact route | `GTM.md`, `BRANDING.md` | Support, sales, or contact channel changes | Build |
| Docs overview | `site/src/pages/docs.astro` | Public map of context docs, decision contracts, and workflow docs | `README.md`, `shipflow-spec-driven-workflow.md`, `CONTENT_MAP.md`, `docs/editorial/` | New official artifact, docs role, editorial layer, technical layer, or workflow doctrine changes | Build; public/private boundary review |
| FAQ page | `site/src/pages/faq.astro` | Answer recurring public objections and support-style questions | `PRODUCT.md`, `GTM.md`, `BRANDING.md`, `README.md` | User-facing workflow, claim, pricing, support, or scope changes | Build; claim register review |
| Pricing page | `site/src/pages/pricing.astro` and `site/src/components/PricingHypothesis.astro` | Present current packaging hypothesis without implying a settled business model | `BUSINESS.md`, `GTM.md`, `BRANDING.md` | Pricing, packaging, commercial model, or proof changes | Build; pricing claim review |
| Remote MCP OAuth guide | `site/src/pages/remote-mcp-oauth-tunnel.astro` | Explain the public operator guide for local OAuth callback routing | `README.md`, `local/README.md`, `specs/local-mcp-oauth-tunnel-login.md`, `docs/technical/local-tunnels-and-mcp-login.md` | MCP login, tunnel, local callback, security, or install behavior changes | Build; sensitive detail review |
| Skill launch cheatsheet | `site/src/pages/skill-modes.astro` | Explain which master/support skill to launch and how skill arguments or mode switches change workflow behavior | `docs/skill-launch-cheatsheet.md`, `shipflow-spec-driven-workflow.md`, `skills/*/SKILL.md`, `README.md` | Skill inventory, mode semantics, argument contracts, or lifecycle flow changes | Build; skill contract review |
| Skill launch Markdown reference | `docs/skill-launch-cheatsheet.md` | Preserve the repo Markdown version of the skill launch and argument-mode reference | `shipflow-spec-driven-workflow.md`, `skills/*/SKILL.md`, `site/src/content/skills/` | Skill inventory, mode semantics, argument contracts, or lifecycle flow changes | Metadata lint; link/path review |
| Skills hub | `site/src/pages/skills/index.astro` | Present public skill catalog and category framing | `skills/*/SKILL.md`, `site/src/content/skills/`, `PRODUCT.md`, `GTM.md` | Skill added, removed, renamed, recategorized, or repositioned | Build; content collection schema validation |
| Skill detail pages | `site/src/pages/skills/[slug].astro` plus `site/src/content/skills/*.md` | Render public skill pages from the `skills` content collection | `skills/*/SKILL.md`, `site/src/content.config.ts`, `BRANDING.md` | Public skill promise, category, relation, argument mode, or schema changes | Build; `site/src/content.config.ts` check |
| Why not just prompts page | `site/src/pages/why-not-just-prompts.astro` | Explain the positioning contrast with generic prompting | `PRODUCT.md`, `GTM.md`, `BRANDING.md` | Positioning, objections, proof, or category changes | Build; claim register review |
| README | `README.md` | Repo overview, public onboarding, artifact map, and operator entrypoint | `BUSINESS.md`, `PRODUCT.md`, `GUIDELINES.md`, `CONTENT_MAP.md` | Official artifacts, setup, workflow, content governance, technical docs, or product framing changes | Metadata lint; link/path review |
| Public skill content collection | `site/src/content/skills/*.md` | Public workflow pages consumed by Astro | `skills/*/SKILL.md`, `site/src/content.config.ts`, `docs/editorial/astro-content-schema-policy.md` | Skill behavior, public promise, related skills, or content schema changes | `npm --prefix site run build` |
| Shared navigation and footer | `site/src/components/NavBar.astro`, `site/src/components/Footer.astro` | Route visitors to primary public surfaces | `CONTENT_MAP.md`, `GTM.md` | New primary page, removed surface, route rename, or CTA change | Build; route existence check |
| Shared FAQ and pricing components | `site/src/components/FaqSection.astro`, `site/src/components/PricingHypothesis.astro` | Reusable public claim surfaces on landing routes | `PRODUCT.md`, `GTM.md`, `claim-register.md` | FAQ answer, objection, pricing, or packaging changes | Build; claim register review |

## Missing Or Future Surfaces

| Surface | Status | Required behavior |
| --- | --- | --- |
| Blog/articles | Missing declared surface | Report `surface missing: blog` and route to a separate spec or explicit surface decision before writing article content |
| Newsletter/social | Missing declared repository surface | Report missing surface and do not invent a repository path |
| Support knowledge base | Not separate from FAQ today | Use FAQ or docs overview only when the current source contracts justify the answer |
| Changelog/release notes public page | Not declared as a site route | Use internal changelog workflow; do not add a public route without a spec |

## Shared-Surface Rules

- `CONTENT_MAP.md`, `docs/editorial/**`, `README.md`, `site/src/pages/docs.astro`, `site/src/pages/index.astro`, `site/src/pages/faq.astro`, `site/src/pages/pricing.astro`, shared components, navigation, footer, and `site/src/content.config.ts` are sequential integration surfaces.
- Public skill content files can be edited in parallel only when a ready spec assigns exclusive files and no shared schema, hub, nav, map, register, FAQ, docs, pricing, or landing copy changes in the same wave.
- If a public surface is affected but absent from this map, the Editorial Update Plan must report `surface missing`.

## Maintenance Rule

Update this file when a public route, public content collection, public component surface, README role, FAQ/support destination, or future blog/article surface is added, removed, renamed, or materially repositioned.
