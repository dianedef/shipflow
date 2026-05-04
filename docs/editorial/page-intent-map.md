---
artifact: editorial_content_context
metadata_schema_version: "1.0"
artifact_version: "1.1.1"
project: ShipFlow
created: "2026-05-01"
updated: "2026-05-04"
status: reviewed
source_skill: sf-start
scope: page-intent-map
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
content_surfaces:
  - public_site
  - public_skill_pages
  - faq_support
claim_register: docs/editorial/claim-register.md
page_intent: docs/editorial/page-intent-map.md
linked_systems:
  - site/src/pages/
  - site/src/components/
  - site/src/content/skills/
depends_on:
  - artifact: "BUSINESS.md"
    artifact_version: "1.1.0"
    required_status: reviewed
  - artifact: "PRODUCT.md"
    artifact_version: "1.1.0"
    required_status: reviewed
  - artifact: "BRANDING.md"
    artifact_version: "1.0.0"
    required_status: reviewed
  - artifact: "GTM.md"
    artifact_version: "1.1.0"
    required_status: reviewed
supersedes: []
evidence:
  - "Inventory of current Astro pages and shared public components."
  - "Skill modes route expanded into a launch cheatsheet for master and supporting skill modes."
  - "docs/skill-launch-cheatsheet.md added as the Markdown reference behind the public skill modes route."
next_review: "2026-06-01"
next_step: "/sf-verify ShipFlow Editorial Content Governance Layer for AI Agents"
---

# Page Intent Map

## Purpose

This map states the job of each public Astro page so agents can update copy without changing the page's role by accident.

## Route Intent

| Route | File | Audience | Job | Primary CTA | Source of truth | Update trigger | Shared-file risk |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `/` | `site/src/pages/index.astro` plus homepage components | Solo founders and autonomous technical builders evaluating ShipFlow | Explain the unified framework: server delivery plus agent execution discipline | Skills hub, docs, pricing, GitHub | `BUSINESS.md`, `PRODUCT.md`, `GTM.md`, `BRANDING.md` | Offer, audience, workflow, proof, pricing, FAQ, or claim changes | High: homepage components are reused and claim-heavy |
| `/about` | `site/src/pages/about.astro` | Visitors asking why the product exists | Ground the mission and trust posture | Docs or GitHub | `BUSINESS.md`, `PRODUCT.md`, `BRANDING.md` | Mission, audience, positioning, proof posture | Medium |
| `/contact` | `site/src/pages/contact.astro` | Visitors who want a direct next step | Give a simple contact path without inventing support promises | Contact method or GitHub | `GTM.md`, `BRANDING.md` | Sales/support channel changes | Low |
| `/docs` | `site/src/pages/docs.astro` | Public evaluators and operators orienting in docs | Explain context docs, decision contracts, public skills, and governance without exposing internal-only detail | Skills hub and GitHub docs | `README.md`, `shipflow-spec-driven-workflow.md`, `CONTENT_MAP.md`, `docs/editorial/README.md` | New artifact, content governance, technical docs layer, workflow doctrine, or docs routing changes | High: public/private boundary |
| `/faq` | `site/src/pages/faq.astro` | Visitors with recurring objections or scope questions | Answer common questions directly and safely | Skill modes, docs | `PRODUCT.md`, `GTM.md`, `BRANDING.md`, `README.md` | New objection, product scope change, pricing/support claim, skill behavior change | High: compact claims can drift |
| `/pricing` | `site/src/pages/pricing.astro` | Visitors evaluating commercial fit | Present pricing as a current hypothesis, not a settled model | Docs, BUSINESS.md | `BUSINESS.md`, `GTM.md`, `BRANDING.md` | Business model, packaging, paid offer, proof, or pricing claim changes | High: pricing claims are sensitive |
| `/remote-mcp-oauth-tunnel` | `site/src/pages/remote-mcp-oauth-tunnel.astro` | Operators dealing with remote Codex and local OAuth callbacks | Explain why local callback routing needs a temporary SSH path | Local guide and repo docs | `local/README.md`, `README.md`, `specs/local-mcp-oauth-tunnel-login.md`, `docs/technical/local-tunnels-and-mcp-login.md` | Tunnel behavior, OAuth callback, local install, security boundary, or MCP docs changes | High: security/privacy wording |
| `/skill-modes` | `site/src/pages/skill-modes.astro` | Operators choosing skill entrypoints or confused by skill arguments | Explain which master/support skill to launch and how plain task arguments differ from mode switches | Skills hub, relevant skill pages | `docs/skill-launch-cheatsheet.md`, `shipflow-spec-driven-workflow.md`, `skills/*/SKILL.md`, `README.md` | Skill inventory, argument modes, mode detection, lifecycle routing | Medium |
| `/skills` | `site/src/pages/skills/index.astro` | Visitors choosing a workflow move | Present the public skill catalog by category and use case | Skill detail pages | `site/src/content/skills/*.md`, `skills/*/SKILL.md`, `PRODUCT.md` | Skill inventory, category, featured status, public promise | High: generated from content collection |
| `/skills/[slug]` | `site/src/pages/skills/[slug].astro` | Visitors evaluating one skill | Render one public skill promise and related workflow context | Skills hub, GitHub skills | `site/src/content/skills/*.md`, `skills/*/SKILL.md`, `site/src/content.config.ts` | Skill behavior, public description, argument modes, related skills, schema changes | High: route depends on `getCollection` and `getStaticPaths` |
| `/why-not-just-prompts` | `site/src/pages/why-not-just-prompts.astro` | Visitors comparing ShipFlow to stronger prompting | Explain why context, contracts, and verification are the product wedge | Docs or skills | `PRODUCT.md`, `GTM.md`, `BRANDING.md` | Positioning, objection handling, proof language | Medium |

## Component Intent

| Component | File | Job | Update trigger |
| --- | --- | --- | --- |
| Navigation | `site/src/components/NavBar.astro` | Route visitors to primary public surfaces | New primary public route, removed route, or CTA change |
| Footer | `site/src/components/Footer.astro` | Repeat the compact product promise and stable links | Positioning or primary route change |
| FAQ section | `site/src/components/FaqSection.astro` | Homepage objection handling | Product, workflow, scope, or claim change |
| Pricing hypothesis | `site/src/components/PricingHypothesis.astro` | Homepage commercial hypothesis | Business model or pricing language change |
| Docs CTA | `site/src/components/DocsCta.astro` | Drive from homepage to docs | Docs surface or artifact role change |
| Role map | `site/src/components/RoleMap.astro` | Explain workflow roles in public language | Lifecycle, reader, executor, integrator, or skill-role change |

## Page Intent Rules

- Do not make a public page the source of truth for product behavior. Public pages reflect reviewed contracts and verified behavior.
- Do not promote internal-only technical docs as public content. A public page may mention that the layer exists, but it must not publish internal operational detail.
- Do not strengthen pricing, security, privacy, compliance, AI reliability, automation, speed, savings, availability, or business outcome claims without claim-register evidence.
- If a page intent changes materially, update this file and `CONTENT_MAP.md`.

## Maintenance Rule

Update this file when a public route, shared public component, CTA, source contract, or page job changes.
