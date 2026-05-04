# Skills Refresh Log

Chronological log of skill refreshes via `/sf-skills-refresh`. Most recent first.

---

## 2026-05-04 — sf-content

**Added:**
- New master content lifecycle contract for content map, editorial corpus, owner content skills, audits, docs, validation, and ship routing
- Explicit routing boundaries so `sf-content` orchestrates `sf-repurpose`, `sf-redact`, `sf-enrich`, `sf-audit-copy`, `sf-audit-copywriting`, `sf-audit-seo`, `sf-docs`, `sf-veille`, and `sf-market-study` without duplicating them
- Stop conditions for missing declared blog/article surfaces, unsupported sensitive claims, runtime content schema violations, validation failures, and unrelated dirty ship scope
- Public skill page and internal discoverability updates for content-management work

**Updated:**
- None (new skill created)

**New phases:**
- None

**Sources:** 0 URLs consulted (local content governance, editorial corpus, and existing content skill contracts)

## 2026-05-03 — sf-maintain

**Added:**
- New project maintenance orchestrator for bugs, dependency posture, docs drift, checks, audits, migrations, tasks, and security posture
- Explicit ownership boundaries so `sf-maintain` routes to `sf-bug`, `sf-deps`, `sf-docs`, `sf-check`, `sf-audit-code`, `sf-audit`, `sf-migrate`, and `sf-tasks` without duplicating them
- `security` mode that composes `sf-deps` and `sf-audit-code` instead of introducing a separate security audit skill
- Public skill page and internal discoverability updates for recurring maintenance work

**Updated:**
- Workflow/help docs now position `sf-maintain` as the recurring maintenance entrypoint for existing projects

**New phases:**
- None

**Sources:** 0 URLs consulted (local ShipFlow doctrine and existing maintenance/audit skill contracts)

## 2026-05-03 — sf-bug

**Added:**
- New professional bug loop orchestrator for `sf-test -> bug dossier -> sf-fix -> sf-test --retest -> sf-verify -> sf-ship`
- Explicit ownership boundaries so `sf-bug` routes without duplicating bug capture, fix, retest, browser evidence, verification, or shipping internals
- Stop conditions for missing dossiers, unsafe closure, unresolved high/critical ship risk, sensitive evidence, destructive production actions, and preview-validation gaps
- Public skill page and internal discoverability updates for the professional bug lifecycle workflow

**Updated:**
- Compact descriptions for selected existing skills so adding `sf-bug` keeps discovery budget under the hard limit

**New phases:**
- None

**Sources:** 0 URLs consulted (local Professional Bug Management doctrine and existing bug skill contracts)

## 2026-05-03 — sf-deploy

**Added:**
- New release orchestrator skill contract for `sf-check -> sf-ship -> sf-prod -> sf-browser/sf-auth-debug/sf-test -> sf-verify -> sf-changelog`
- Explicit ownership boundaries so `sf-deploy` does not duplicate `sf-ship`, `sf-prod`, browser proof, manual QA, or verification internals
- Stop conditions for ambiguous scope, failed checks, blocked ship, failed deploy, missing evidence, failed verification, stale docs, unrelated dirty files, and sensitive evidence
- Public skill page and internal discoverability updates for the release confidence workflow

**Updated:**
- None (new skill created)

**New phases:**
- None

**Sources:** 0 URLs consulted (local ShipFlow doctrine and existing release skill contracts)

## 2026-05-02 — sf-skill-build

**Added:**
- Contract sections for canonical paths, chantier tracking, scope gate, spec-first gate, implementation flow, freshness gate, security constraints, stop conditions, and final report shape
- Explicit lifecycle sequence: `sf-spec -> SKILL.md -> sf-skills-refresh -> skill budget audit -> sf-verify -> sf-docs/help update -> sf-ship`
- Validation commands for budget audit, metadata lint, and site build
- Public-by-default rule with explicit internal-only exception policy
- Invocation rename block rule requiring explicit user approval before any rename edits

**Updated:**
- None (new skill created)

**New phases:**
- None

**Sources:** 0 URLs consulted (local doctrine and spec contract execution)

## 2026-05-01 — project development mode doctrine

**Added:**
- Shared reference — `project-development-mode.md` defines local, Vercel preview-push, and hybrid validation modes
- `sf-init` — project-local `## ShipFlow Development Mode` section for `CLAUDE.md` / `SHIPFLOW.md`
- `sf-start` — execution contract now records development mode and routes preview-push validation to `sf-ship` -> `sf-prod`
- `sf-fix` — bug retest routing now respects local vs Vercel preview-push validation
- `sf-ship` — successful push now hands off to `sf-prod` when preview deployment is the validation surface
- `sf-prod` — Vercel MCP is primary for waiting on matching preview deployments in preview-push mode
- `sf-test` — preview/manual tests are blocked until changed code is shipped and `sf-prod` confirms deployment
- `sf-help` — global doctrine now explains project development modes and the preview-push sequence
- `sf-auth-debug` — auth diagnostics now respect project development mode and require `sf-ship` -> `sf-prod` before authoritative Vercel preview auth proof
- `sf-verify` — ready-to-ship verdicts now account for project development mode and required Vercel preview proof
- `sf-end` — closeout now stays partial when required preview-push validation evidence is missing
- `sf-check` — local checks now report when they are only pre-push confidence before `sf-ship` -> `sf-prod`

**Updated:**
- `sf-prod` pending rule now points to the full polling loop instead of a shorter fixed wait
- READMEs for `sf-start`, `sf-fix`, `sf-ship`, and `sf-prod` mention development-mode-aware routing
- `sf-auth-debug` README and Vercel tooling reference now distinguish local auth evidence from preview/prod-authoritative evidence
- READMEs for `sf-verify`, `sf-end`, and `sf-check` now mention development-mode-aware evidence limits

**New phases:**
- None

**Sources:** 0 URLs consulted (manual workflow doctrine update)

## 2026-04-20 — sf-audit-code

**Added:**
- FILE MODE — Category 2 (NEW): System Fit & Reuse (anti-duplication): prefer reusing existing utilities/patterns; avoid near-duplicate helpers and signature drift
- PROJECT MODE — Phase 1.5 (NEW): Consistency & Reuse (anti-duplication / convention drift): flag competing patterns (validation, error handling, logging, state) and recommend consolidation

**Updated:**
- Fix guidance: bias toward deleting duplicates and calling the canonical helper/module

---

## 2026-04-19 — sf-enrich

**Added:**
- Phase 4 — Quick Answer / TL;DR box (LLM extraction target)
- Phase 4 — Key Takeaways box, interactive elements (calculator/quiz), Mermaid diagrams, annotated screenshots, "Last updated" visible in body, Changelog section, Sources section
- Phase 4 — Internal links: 2-5 contextual body links per 1000 words, topic cluster structure
- Phase 4.5 (NEW) — AI Visibility Layer: semantic chunking 256-512 tokens, inverted pyramid per section, question-shaped headings, quotable sentences, claim-source proximity, fact density, entity-rich language
- Phase 4.5 — E-E-A-T concrete checklist: named author, first-person experience, original visuals, before/after with methodology, limitation statements, reviewer line for YMYL
- Phase 4.5 — Schema.org matrix by page type (Article, HowTo, FAQPage, QAPage, Review, SpeakableSpecification, pillar, comparison)
- Phase 2 — Primary source preference (.edu/.gov/peer-reviewed), content decay scan
- Phase 6 — JSON-LD validation, Quick Answer self-containment check, dateModified in body, decay scan

**New phases:**
- Phase 4.5 — AI Visibility Layer

**Sources:** ~20 URLs (GEO/AEO guides, schema.org, E-E-A-T March 2026, interactive content stats, topic clusters, Speakable schema)

---

## 2026-04-19 — sf-audit-copy

**Added:**
- Category 2 — sentence length variance (SD > 6 words), dual FK targets (6-8 consumer / 8-10 B2B), plain-language summary for pages > 400 words
- Category 4 — CTA "action verb + specific outcome + timeframe", mobile hero fold check, objection block near CTA
- Category 7 — smart/straight quote mixing, French typography (insécable, guillemets)
- Category 8 (NEW) — AI-Voice Detection: EN+FR blacklists (verbs, nouns, adjectives, phrases), structural tells (em-dash density, tricolons, uniform sentence length)
- Category 9 (NEW) — AI-era Trust Signals: named author, dated timestamp, first-person markers, specific numbers, verifiable proof
- Category 10 (NEW) — LLM-Answer-Engine Readiness (Princeton GEO): first 40-60 words direct answer, fact density, question-form headings, standalone claims
- Category 11 (NEW) — Conversion Copy 2025-2026: message match, trust sequencing before price, hidden-cost transparency, conversational error pattern
- Framework Reference section — StoryBrand > PAS > JTBD > 4Cs > AIDA > Kennedy direct-response ranking for 2026
- Category 1 — 5-second JTBD test, StoryBrand hero-guide check

**New phases / categories:**
- Categories 8-11 added (AI-Voice, Trust Signals, AEO/GEO, Conversion CRO)

**Sources:** ~25 URLs (Wikipedia AI writing signs, Princeton GEO study, AEO guides, CRO 2026, WCAG 3 plain language, tutoiement FR, Unbounce/Kissmetrics CTA data)

---

## 2026-04-19 — sf-audit-design

**Added:**
- Category 3 — OKLCH tokens over HSL/hex, `color-mix()` with fallbacks, `light-dark()` + `color-scheme`, WCAG 3 APCA note
- Category 6 — target size 24×24 + 8px spacing / 24px offset rule, WCAG 3 plain-language check, INP budget < 200ms
- Category 8 — `<dialog>` vs `<div role=dialog>`, `popover` vs `<dialog>`, `inert` vs `aria-hidden`, `:has()` replacing JS class toggles
- Category 9 (NEW) — Modern CSS 2026: container queries, `:has()` child-scoping, View Transitions API, subgrid, scroll-driven animations (with motion gates), CSS anchor positioning + popover, `content-visibility`
- Category 10 (NEW) — AI-Generated Code Smells: conflicting Tailwind utilities, dynamic class concatenation, div-as-button without keyboard, missing labels/alts, missing interaction states, HTML5 constraint validation first
- Phase 2 (Deprecated CSS) — hex/hsl in tokens, `@media` that should be `@container`, `<div role=dialog>`, JS-toggled parent classes
- Phase 2.5 (NEW) — Modern CSS Adoption Check
- Phase 2.6 (NEW) — AI-Generated Code Smells Scan
- Phase 3 — INP < 200ms per-page check
- Report templates — Modern CSS 2026, AI-Gen Smells categories, adoption matrix

**New phases:**
- Phase 2.5 — Modern CSS Adoption Check
- Phase 2.6 — AI-Generated Code Smells Scan

**Sources:** ~22 URLs (W3C WCAG 3 draft, MDN modern CSS, web.dev INP/container queries/content-visibility, Evil Martians OKLCH, DTCG spec, OverlayQA AI audit, LogRocket, Stack Overflow)

---

## 2026-04-19 — sf-audit-seo

**Added:**
- Phase 1 — `<meta name="author">`, `article:published_time`/`modified_time`, `hreflang` lowercase rule, separate canonicals per language
- Phase 4 — semantic completeness over keyword density, first-200-words direct answer, H2/H3 bold summary nugget, semantic chunking, Information Gain threshold, entity-rich language
- Phase 5 — AVIF-first via `<picture>`, `fetchpriority="high"` + `loading="eager"` on LCP
- Phase 7 — INP < 200ms (replaced FID), LCP < 2.5s, CLS < 0.1, Speculation Rules API
- Phase 8 (NEW) — AI Visibility (AEO/GEO): llms.txt, llms-full.txt, AI crawler allowlist, server-rendered HTML, citation-ready structure, Person/SpeakableSpecification/QAPage/HowTo/Dataset/Organization schemas, off-site signals (Wikipedia, Reddit)
- Phase 5 (Internal Linking) — topic cluster check (pillar + 2-5 spokes, sibling links, body links vs nav/footer equity)
- Context section — llms.txt presence check, AI crawler rules grep
- Report templates — AI Visibility score + AEO/GEO metrics

**New phases:**
- Phase 5.5 — AI Visibility (AEO / GEO)

**Updated:**
- Performance: FID removed, INP becomes the responsiveness metric
- Images: WebP/AVIF generalization → explicit AVIF-first
- Keyword density: downgraded to "semantic completeness + entity coverage"
- Meta description CTA: de-emphasized (AI Overviews rewrite it)

**Sources:** ~22 URLs (llmstxt.org, web.dev INP/Speculation Rules, schema.org SpeakableSpecification/QAPage, Frase/Wellows/CXL/DigitalApplied AEO-GEO guides, LinkGraph hreflang)
