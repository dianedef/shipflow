# Skills Refresh Log

Chronological log of skill refreshes via `/sf-skills-refresh`. Most recent first.

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
