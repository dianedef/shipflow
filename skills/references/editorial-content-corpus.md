---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.3.0"
project: ShipFlow
created: "2026-05-01"
updated: "2026-05-11"
status: active
source_skill: sf-start
scope: editorial-content-corpus
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - shipflow_data/editorial/content-map.md
  - shipflow_data/editorial/
  - shipflow_data/business/business.md
  - shipflow_data/business/product.md
  - shipflow_data/business/branding.md
  - shipflow_data/business/gtm.md
  - site/src/pages/
  - site/src/content/
  - skills/sf-repurpose/SKILL.md
  - skills/sf-audit-copy/SKILL.md
depends_on:
  - artifact: "shipflow_data/editorial/README.md"
    artifact_version: "1.0.0"
    required_status: reviewed
  - artifact: "shipflow_data/editorial/content-map.md"
    artifact_version: "0.7.0"
    required_status: draft
supersedes: []
evidence:
  - "Ready spec requires a compact loading reference for editorial and content agents."
  - "sf-docs first-run bootstrap and update adoption now treat missing editorial governance as recoverable bootstrap state when public surfaces exist."
next_review: "2026-06-01"
next_step: "/sf-docs audit editorial"
---

# Editorial Content Corpus

## Purpose

This reference tells content, copy, docs, and Editorial Reader agents how to load ShipFlow public-content context without re-reading the whole repo.

## Load Order

1. Read `shipflow_data/editorial/content-map.md` first. It is the canonical public content routing map. Root `CONTENT_MAP.md` is a migration source only.
2. Read `shipflow_data/editorial/README.md` for the editorial governance index when present; if it is missing on a public/content project, report an editorial governance bootstrap trigger and route to `/sf-docs editorial`. Legacy `docs/editorial/` is a migration source only.
3. Read `shipflow_data/editorial/public-surface-map.md` for public surfaces and update triggers.
4. Read `shipflow_data/editorial/page-intent-map.md` for page jobs, CTAs, source contracts, and shared-file risk.
5. Read `shipflow_data/editorial/claim-register.md` when public claims touch security, privacy, compliance, AI reliability, automation, speed, savings, availability, pricing, or business outcomes.
6. Read `shipflow_data/editorial/editorial-update-gate.md` to produce an `Editorial Update Plan` or `Claim Impact Plan`.
7. Read `shipflow_data/editorial/astro-content-schema-policy.md` before editing `site/src/content/**`.
8. Read `shipflow_data/editorial/blog-and-article-surface-policy.md` before recommending blog or article output.

## Contract Sources

Use these contracts to bound public copy:

- `shipflow_data/business/business.md`: audience, value proposition, market, business model uncertainty.
- `shipflow_data/business/product.md`: user problem, desired outcomes, workflow scope, non-goals.
- `shipflow_data/business/branding.md`: voice, trust posture, vocabulary, and claim boundaries.
- `shipflow_data/business/gtm.md`: public promise, channels, objections, proof limits, and conversion path.
- `shipflow_data/technical/guidelines.md`: internal language doctrine and documentation rules.
- `shipflow_data/business/project-competitors-and-inspirations.md`: optional competitors, alternatives, inspiration, and anti-pattern registry.
- `shipflow_data/business/affiliate-programs.md`: optional affiliate, referral, partner, sponsorship, and disclosure registry.
- Ready specs and verified implementation behavior when the public claim depends on a recent change.

## Public Surface Sources

Use these files to inspect the actual public site:

- `site/src/pages/`
- `site/src/components/`
- `site/src/content.config.ts`
- `site/src/content/skills/`
- `site/package.json`
- `site/package-lock.json`

Astro runtime content must preserve the schema declared in `site/src/content.config.ts`. Report ShipFlow context versions in the plan or final report when the runtime content schema does not accept governance metadata.

## Skill Consumers

These skills should use this corpus before changing or judging public content:

- `skills/sf-docs/SKILL.md`
- `skills/sf-repurpose/SKILL.md`
- `skills/sf-audit-copy/SKILL.md`
- `skills/sf-redact/SKILL.md`
- `skills/sf-enrich/SKILL.md`

## Output Expectations

- Missing `shipflow_data/editorial/README.md` on a public/content project: treat it as a first-run bootstrap trigger.
- Existing project adoption: `sf-docs update` reports editorial governance as `created`, `already existed`, `needs audit`, `skipped - no editorial surfaces detected`, or `blocked`.
- Public-content impact: produce an `Editorial Update Plan`.
- Sensitive public claims: produce a `Claim Impact Plan`.
- No public impact: state `no editorial impact` with a reason.
- Missing blog or article path: report `surface missing: blog`.
- Runtime schema conflict: preserve the schema and report the incompatibility.

## Maintenance Rule

Update this reference when editorial governance docs, public surface maps, claim plan formats, Astro content policy, or content-writing skill consumers change.
