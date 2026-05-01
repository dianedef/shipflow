---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipFlow
created: "2026-05-01"
updated: "2026-05-01"
status: reviewed
source_skill: sf-start
scope: public-site-and-content-runtime
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - site/
  - CONTENT_MAP.md
  - README.md
depends_on:
  - artifact: "CONTENT_MAP.md"
    artifact_version: "0.2.0"
    required_status: draft
supersedes: []
evidence:
  - "CONTENT_MAP.md and site directory inventory."
next_review: "2026-06-01"
next_step: "/sf-docs technical audit site"
---

# Public Site And Content Runtime

## Purpose

This doc covers the Astro public site under `site/`, public skill content, content routing, and the public/private documentation boundary. Read it before changing public docs, content pages, public skill descriptions, or anything that could publish internal technical details.

## Owned Files

| Path | Role | Edit notes |
| --- | --- | --- |
| `site/` | Astro public site | Do not publish internal-only technical docs by accident |
| `site/src/pages/**` | Public routes | Public copy must match product and GTM contracts |
| `site/src/content/skills/**` | Public skill pages | Summarize outcomes, not internal prompt bodies |
| `CONTENT_MAP.md` | Content surface and repurposing map | Update when public surfaces or routing rules change |
| `site/README.md` | Site-local setup | Update when site commands or runtime change |

## Entrypoints

- `npm --prefix site run build`: public site build.
- `site/src/pages/docs.astro`: public docs overview.
- `site/src/pages/skills/index.astro`, `site/src/pages/skills/[slug].astro`, and `site/src/content/skills/`: public skill surfaces.
- `CONTENT_MAP.md`: source of truth for content surface roles and update triggers.

## Invariants

- `docs/technical/` is internal-only in v1.
- Public site copy must not expose private implementation details, private URLs, tokens, internal logs, or operator-only instructions.
- Public claims must be backed by product, business, brand, GTM, workflow docs, or observed behavior.
- Public skill pages should not duplicate full `SKILL.md` implementation prompts.

## Failure Modes

- Adding `docs/technical/` to public routing leaks internal details.
- Public docs can drift from README/workflow doctrine if only one surface is updated.
- Skill descriptions can promise capabilities not present in internal skill contracts.
- Build output under `site/dist` and dependencies under `site/node_modules` should not be treated as source docs.

## Security Notes

- Never publish secrets, private logs, credentials, OAuth callback internals, private hostnames, or sensitive install reports.
- Keep internal/public boundaries explicit in `CONTENT_MAP.md`.
- Check generated public pages for accidental internal links when promoting documentation.

## Validation

```bash
npm --prefix site run build
rg -n "docs/technical|internal-only|secret|token|credential" site/src CONTENT_MAP.md
```

Review any sensitive-keyword matches manually; generic warnings are allowed, real secrets are not.

## Reader Checklist

- `site/` changed -> check this doc and `CONTENT_MAP.md`.
- Public docs route changed -> check README and workflow docs for consistency.
- Internal technical docs mentioned publicly -> confirm the link is not publishing internal content.

## Maintenance Rule

Update this doc when public routes, skill content, content surface roles, build commands, or internal/public documentation boundaries change.
