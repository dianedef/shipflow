---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipFlow
created: "2026-05-16"
updated: "2026-05-16"
status: draft
source_skill: sf-start
scope: sf-audit-seo-seo-audit-workflow
owner: unknown
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/sf-audit-seo/SKILL.md
  - skills/sf-audit-seo/references/seo-audit-workflow.md
depends_on:
  - artifact: "skills/references/skill-instruction-layering.md"
    artifact_version: "0.1.0"
    required_status: "draft"
supersedes: []
evidence:
  - "Extracted from skills/sf-audit-seo/SKILL.md during Compact ShipFlow Skill Instructions Phase 2."
next_review: "2026-06-16"
next_step: "/sf-verify Compact ShipFlow Skill Instructions Phase 2"
---

# Seo Audit Workflow

## Purpose

SEO modes, technical/on-page/content/schema/internal-linking/AI-visibility checklists, tracking, and report details.

This reference preserves the detailed pre-compaction instructions for `sf-audit-seo`. The top-level `SKILL.md` is now the activation contract; load this file only when the selected mode needs the detailed workflow, checklist, templates, or examples below.

## Detailed Instructions

## Canonical Paths

Before resolving any ShipFlow-owned file, load `$SHIPFLOW_ROOT/skills/references/canonical-paths.md` (`$SHIPFLOW_ROOT` defaults to `$HOME/shipflow`). ShipFlow tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPFLOW_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Chantier Tracking

Trace category: `conditionnel`.
Process role: `source-de-chantier`.

Before producing the final report, load `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md` when this run is attached to a spec-first chantier. If exactly one active `specs/*.md` chantier is identified, append the current run to `Skill Run History`, update `Current Chantier Flow` when the run changes the chantier state, and include a final `Chantier` block. If no unique chantier is identified, do not write to any spec; report `Chantier: non applicable` or `Chantier: non trace` with the reason.

## Chantier Potential Intake

Because this skill has process role `source-de-chantier`, evaluate the standard threshold from `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md` before the final report. If the findings reveal non-trivial future work and no unique chantier owns it, do not write to an existing spec; add a `Chantier potentiel` block with `oui`, `non`, or `incertain`, a proposed title, reason, severity, scope, evidence, recommended `/sf-spec ...` command, and next step. If the work is only a direct local fix or already belongs to the current chantier, state `Chantier potentiel: non` with the concrete reason.

## Report Modes

Before producing the final report, load `$SHIPFLOW_ROOT/skills/references/reporting-contract.md`.

Default to `report=user`: concise, findings-first, and focused on top issues, proof gaps, chantier potential, and the next real action. Use `report=agent`, `handoff`, `verbose`, or `full-report` for the detailed audit matrix, domain checklist output, command evidence, assumptions, confidence limits, and handoff notes.


## Governance Corpora And Output Plans

Before scoring indexed public content, rewriting SEO copy, fixing public site metadata, or recommending article/blog output, load `$SHIPFLOW_ROOT/skills/references/editorial-content-corpus.md` when `shipflow_data/editorial/content-map.md`, legacy `CONTENT_MAP.md`, `shipflow_data/editorial/`, or legacy `docs/editorial/` exists. Follow its load order for content surface routing, public page intent, claim register checks, editorial update gate, Astro runtime schema policy, and blog/article surface policy.

Before changing code, runtime content, site files, content schemas, sitemap/robots/metadata infrastructure, skill contracts, public docs, README guidance, or mapped technical documentation surfaces, load `$SHIPFLOW_ROOT/skills/references/technical-docs-corpus.md` and use `shipflow_data/technical/code-docs-map.md` (fallback legacy `docs/technical/code-docs-map.md`) to decide whether a `Documentation Update Plan` is required.

The final report must include these governance outcomes when relevant:
- `Editorial Update Plan`: required for public pages, README/public docs, public skill pages, FAQ, pricing/support copy, runtime public content, blog/article/newsletter requests, indexed claims, or public SEO copy changes. Use `no editorial impact` with a reason when there is no public-content consequence.
- `Claim Impact Plan`: required when claims touch security, privacy, compliance, AI reliability, automation, speed, savings, availability, pricing, or business outcomes.
- `Documentation Update Plan`: required when mapped code, runtime content, site files, skill contracts, or technical documentation surfaces changed; otherwise state `no documentation impact` with a reason.

## Context

- Current directory: !`pwd`
- Project CLAUDE.md: !`head -100 CLAUDE.md 2>/dev/null || echo "no CLAUDE.md"`
- Business context: !`if [ -f shipflow_data/business/business.md ]; then head -40 shipflow_data/business/business.md; else head -40 BUSINESS.md 2>/dev/null || echo "no shipflow_data/business/business.md (and no legacy BUSINESS.md) — run /sf-init or /sf-docs update"; fi`
- Business metadata: !`for pair in "shipflow_data/business/business.md BUSINESS.md" "shipflow_data/business/branding.md BRANDING.md" "shipflow_data/technical/guidelines.md GUIDELINES.md"; do set -- $pair; if [ -f "$1" ]; then f="$1"; elif [ -f "$2" ]; then f="$2"; else echo "$2: missing (no $1)"; continue; fi; printf '%s: ' "$f"; sed -n '1,40p' "$f" | grep -E '^(metadata_schema_version|artifact_version|status|updated|confidence|next_review):' | tr '\n' ' '; printf '\n'; done`
- All pages: !`find src/pages src/app -name "*.astro" -o -name "*.tsx" -o -name "*.vue" 2>/dev/null | grep -v node_modules | sort`
- Sitemap: !`cat public/sitemap*.xml 2>/dev/null | head -50 || echo "no sitemap found"`
- Robots.txt: !`cat public/robots.txt 2>/dev/null || echo "no robots.txt"`
- SEO/head component: !`find src -name "*seo*" -o -name "*head*" -o -name "*meta*" 2>/dev/null | grep -v node_modules | head -10 || echo "none found"`
- Astro config: !`cat astro.config.* 2>/dev/null | head -50 || echo "no astro config"`
- Content files count: !`find src/content -type f 2>/dev/null | wc -l || echo "0"`
- llms.txt: !`test -f public/llms.txt && echo "present" || echo "MISSING — AEO gap"`
- AI crawler rules: !`grep -iE 'GPTBot|ClaudeBot|PerplexityBot|Google-Extended|OAI-SearchBot|CCBot' public/robots.txt 2>/dev/null || echo "no explicit AI crawler rules"`

## Pre-check : contexte business

Avant de commencer, vérifier le contexte chargé ci-dessus. Si BUSINESS.md est absent :

**Afficher un avertissement en tête de rapport :**
```
⚠ Contexte manquant :
- [BUSINESS.md manquant] L'audit SEO ne peut pas évaluer la pertinence des mots-clés sans connaître l'audience cible.

→ Lancer /sf-init pour générer ce fichier, ou /sf-docs update pour le mettre à jour.
```

Si le fichier existe mais semble incomplet, signaler. Continuer l'audit dans tous les cas.

---

## Metadata versioning doctrine

`BUSINESS.md`, `BRANDING.md`, and `GUIDELINES.md` are ShipFlow decision contracts for SEO audits when they define ICP, positioning, tone, market, or editorial rules. Before scoring:
- Read/report `artifact_version`, `status`, `updated`, `confidence`, and `next_review` when available.
- If `artifact_version`, `status`, or `updated` is missing, add a proof gap: `business doc metadata incomplete`.
- If `status` is `draft`, `stale`, `outdated`, `deprecated`, or `confidence` is `low`, cap confidence and state that keyword/search-intent scoring depends on an unreviewed business contract.
- If `next_review` is before today's absolute date, treat the document as stale unless a newer replacement is explicit.
- If search intent, target persona, market language, E-E-A-T claims, compliance claims, or feature claims rely on stale or unversioned docs, do not give `A` to the affected category.
- Include a `Business metadata versions` section in every report.

Use ShipFlow versioning semantics: patch = editorial clarification without strategy change, minor = changed keyword/persona guidance inside the same market strategy, major = changed ICP, positioning, pricing promise, trust posture, market, or acquisition strategy.

If `shipflow_data/editorial/` exists (fallback legacy `docs/editorial/`), apply `Governance Corpora And Output Plans` before scoring public content, indexed claims, public docs, public skill pages, FAQ/pricing/support copy, runtime content, or article/blog output.

---

## Doctrine SEO / business / docs

Le SEO doit attirer les bons utilisateurs vers une promesse vraie :
- l'intention de recherche doit correspondre à la user story et à l'étape du parcours
- le contenu doit refléter le produit actuel, pas une ancienne feature ou une roadmap implicite
- les claims YMYL, sécurité, conformité, gains financiers, IA, santé, légaux ou productivité doivent être datés, sourcés et vérifiables
- les docs, FAQ, changelog, guides et pages produit doivent rester cohérents avec les pages indexables
- une page SEO qui contredit l'app ou la documentation crée un risque business, pas seulement SEO

Signaler explicitement les écarts `docs mismatch`, `outdated feature claim`, `unproven claim` et `wrong-intent traffic`.

### OpenAI / ChatGPT freshness gate

Quand une page ou un corpus contient des claims sur OpenAI, ChatGPT, GPT, Codex, OpenAI API, Responses API, Agents/Assistants, function/tool calling, structured outputs, Whisper/transcription, embeddings, génération d'images, GPTBot, OAI-SearchBot, pricing OpenAI ou prompt guidance :
- utiliser d'abord `mcp__openaiDeveloperDocs__search_openai_docs` / `fetch_openai_doc` pour les claims officiels OpenAI ;
- pour les claims "latest/current/default/best model", fetcher `https://developers.openai.com/api/docs/guides/latest-model.md` ;
- signaler `OpenAI freshness risk` si la page cite des modèles/prix/API obsolètes, de vieux plugins/browsing, des exemples `chat.completions` présentés comme recommandation actuelle, ou des conseils prompt non sourcés ;
- utiliser aussi une recherche web large pour les claims AEO/GEO, taux de citation, adoption marché, benchmarks SEO ou études tierces ; ne pas les présenter comme des recommandations OpenAI sauf preuve dans la doc OpenAI.

---

## Mode detection

- **`$ARGUMENTS` is "global"** → GLOBAL MODE: audit ALL projects in the workspace.
- **`$ARGUMENTS` is a file path** → PAGE MODE: SEO review of that single page.
- **`$ARGUMENTS` is empty** → PROJECT MODE: full technical + on-page SEO audit.

---

## GLOBAL MODE

Audit ALL web projects in the workspace for SEO issues.

1. Read `${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}/PROJECTS.md` — check the **Domain Applicability** table. Identify projects with ✓ in the SEO column.

2. Use **AskUserQuestion** to let the user choose:
   - Question: "Which projects should I audit for SEO?"
   - `multiSelect: true`
   - One option per applicable project: label = project name, description = stack from PROJECTS.md
   - All applicable projects pre-listed as options

3. Use the **Task tool** to launch one agent per **selected** project — ALL IN A SINGLE MESSAGE (parallel). Each agent: `subagent_type: "general-purpose"`.

   Agent prompt must include:
   - `cd [path]` then read `CLAUDE.md` for project context
   - The absolute date, exact project path, and the SEO context already surfaced by this skill (`BUSINESS.md`, sitemap, robots, llms.txt, head/meta config)
   - The complete **PROJECT MODE** section from this skill (all 7 phases: Technical SEO → On-Page Scan → Content SEO → Structured Data → Internal Linking → Fix → Report)
   - The **Tracking** section from this skill
   - Rule: **read-only analysis** — no code fixes, only update AUDIT_LOG.md and TASKS.md
   - Rule: before scoring, identify linked systems and side effects (templates, metadata injection, sitemap, robots, locale variants, AI crawler rules)
   - Rule: call out outdated feature claims, documentation mismatches, wrong-intent traffic, and unproven sensitive claims
   - Rule: read/report `BUSINESS.md`, `BRANDING.md`, and `GUIDELINES.md` metadata versions; flag missing, stale, low-confidence, or unversioned contracts as proof gaps before scoring
   - Rule: do not ask follow-up questions; if context is missing, state assumptions / confidence limits and continue
   - Required sub-report sections: `Scope understood`, `Search intent / user story`, `Business metadata versions`, `Context read`, `Linked systems & consequences`, `Docs coherence`, `Risky assumptions / proof gaps`, `Findings`, `Confidence / missing context`

4. After all agents return, compile a **cross-project SEO report**:

   ```
   GLOBAL SEO AUDIT — [date]
   ═══════════════════════════════════════
   PROJECT SCORES
     [project]    [A/B/C/D]  —  summary
     ...
   CROSS-PROJECT PATTERNS
     [Systemic SEO issues in 2+ projects]
   ALL ISSUES BY SEVERITY
     🔴 [project] file:line — description
     🟠 [project] file:line — description
     🟡 [project] file:line — description
   Total: X critical, Y high, Z medium across N projects
   ═══════════════════════════════════════
   ```

5. Update `${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}/AUDIT_LOG.md` (one row per project, SEO column) and `${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}/TASKS.md` (each project's `### Audit: SEO` subsection).

6. Ask: **"Which projects should I fix?"** — list projects with scores. Fix only approved projects, one at a time.

---

## PAGE MODE

### Step 1: Gather the page

1. Read the target file (`$ARGUMENTS`).
2. Read the layout/head component that injects meta tags.
3. Read the SEO config/defaults (BaseHead.astro, metadata.ts, or equivalent).
4. Read the sitemap config if it exists.

### Step 2: Audit against this checklist

Score each category **A/B/C/D**. Be strict — production SEO standard.

#### 1. Meta Tags & Head
- [ ] `<title>` present, 50-60 characters, includes primary keyword
- [ ] `<meta description>` present, 150-160 characters, includes CTA (note: AI Overviews often rewrite this — the opening H1 paragraph matters more now)
- [ ] `<meta robots>` allows indexing (or intentionally noindex)
- [ ] `<link rel="canonical">` present and correct (absolute URL)
- [ ] `<html lang="xx">` matches content language
- [ ] `<meta name="author">` with real person name (not "editorial team") — direct E-E-A-T signal
- [ ] `article:published_time` + `article:modified_time` on content pages (Perplexity heavily prefers content <90 days old)
- [ ] `hreflang` lowercase format (`fr-fr` not `fr-FR`), self-referencing per language, **never** canonical across languages
- [ ] No duplicate meta tags

#### 2. Open Graph & Social
- [ ] `og:title`, `og:description`, `og:image` present
- [ ] `og:image` is 1200x630px with absolute URL
- [ ] `og:type` is set (article, website, product, etc.)
- [ ] `og:url` matches canonical
- [ ] Twitter card meta present
- [ ] Social preview would look good when shared

#### 3. Heading Structure
- [ ] Exactly one `<h1>` per page
- [ ] H1 contains primary keyword naturally
- [ ] Heading hierarchy is sequential (no skips)
- [ ] Headings are descriptive, not generic
- [ ] No headings used purely for styling

#### 4. Content & Keywords
- [ ] Primary keyword appears in: title, H1, first paragraph, URL
- [ ] **Semantic completeness over keyword density** — page covers the full entity/concept, not just keyword repetition (entity coverage correlates 4.2x more with AI citation than keyword density)
- [ ] **First 200 words answer the primary query directly** — no warm-up intro (AI engines extract opening content for relevance scoring)
- [ ] **Each H2/H3 opens with a bold 1-sentence summary** (Gemini/AI Overviews extract "nuggets" from the first 40-50 words of each section)
- [ ] **Semantic chunking** — each section is one self-contained, citable concept (2-4 sentence paragraphs)
- [ ] **≥3 unique data points / original insights** per article (Information Gain — 4x AI citation rate)
- [ ] **Entity-rich language** — named tools, companies, standards, people (15+ recognized entities → 4.8x citation rate)
- [ ] Content length is competitive for keyword intent
- [ ] No duplicate content with other pages
- [ ] Content reflects current product behavior and docs; no outdated feature claims
- [ ] Search intent attracts the target persona, not low-intent curiosity traffic that cannot convert

#### 5. Images & Media
- [ ] All `<img>` have descriptive `alt` text
- [ ] **AVIF-first** — `<picture>` with AVIF source, WebP fallback, JPEG safety net (AVIF is ~50% smaller than JPEG at equal quality)
- [ ] Images have explicit `width` and `height` (prevents CLS)
- [ ] Below-fold images are lazy-loaded
- [ ] Hero/LCP image is NOT lazy-loaded (`fetchpriority="high"`, `loading="eager"`)

#### 6. Technical SEO
- [ ] URLs are clean (lowercase, hyphens)
- [ ] Page is in sitemap.xml
- [ ] Internal links use descriptive anchor text
- [ ] At least 2-3 internal links to/from this page
- [ ] No broken links
- [ ] Structured data / JSON-LD present
- [ ] Breadcrumbs present for nested pages

#### 7. Performance (SEO-impacting)
- [ ] **INP (Interaction to Next Paint) < 200ms** — replaced FID in March 2024 as Core Web Vital; 200-500ms = needs improvement, >500ms = poor. Check for long main-thread tasks, debounced input handlers
- [ ] **LCP < 2.5s**, **CLS < 0.1** (other Core Web Vitals thresholds)
- [ ] No render-blocking resources in `<head>`
- [ ] Critical CSS inlined or loaded early
- [ ] Fonts use `font-display: swap`
- [ ] No massive JS bundles for static content
- [ ] Third-party scripts are deferred
- [ ] **Speculation Rules API** — `<script type="speculationrules">` prefetch/prerender for predictable navigation (product flows, blog-to-blog). Chromium-only but free win

#### 8. AI Visibility (AEO / GEO)
- [ ] `/llms.txt` at site root (markdown summary, <5000 tokens, links to key pages)
- [ ] `/llms-full.txt` with full content in markdown (recommended for docs sites)
- [ ] `robots.txt` explicitly allows target AI crawlers: `GPTBot`, `ClaudeBot`, `PerplexityBot`, `Google-Extended`, `OAI-SearchBot`, `CCBot`
- [ ] Content is server-rendered (AI crawlers don't execute JS reliably)
- [ ] FAQ section wrapped in `QAPage` or `FAQPage` schema (+58% ChatGPT citation rate vs plain Article)
- [ ] `SpeakableSpecification` marks 1-2 summary passages (3.1x voice/AI citation boost)
- [ ] Author `Person` schema with `sameAs` (LinkedIn/Wikipedia), `hasCredential`, `knowsAbout`
- [ ] First-person experience markers in YMYL content ("I tested", "in our case study", specific outcomes/numbers)
- [ ] Primary source citations inside content (outbound links to research, gov data, official docs)
- [ ] Canonical brand name used consistently everywhere (never "Our Product" vs "ProductX" vs "the tool")
- [ ] Public docs, changelog or support references corroborate feature claims that AI engines may cite
- [ ] OpenAI/ChatGPT claims use OpenAI Docs MCP for official behavior and broader web research for third-party AEO/GEO evidence

### Step 3: Fix

For each issue rated B or worse, after the governance checks above are complete:
1. Identify the exact file and line.
2. Fix it directly in the code.
3. For content decisions (keyword choice, meta description wording), propose 2 options.

### Step 4: Report

```
SEO REVIEW: [page name] — target keyword: "[inferred keyword]"
─────────────────────────────────────
Business metadata:
  BUSINESS.md    artifact_version=[x|missing] status=[x|missing] updated=[date|missing] confidence=[x|missing]
  BRANDING.md    artifact_version=[x|missing] status=[x|missing] updated=[date|missing] confidence=[x|missing]
  GUIDELINES.md  artifact_version=[x|missing] status=[x|missing] updated=[date|missing] confidence=[x|missing]
Meta Tags & Head   [A/B/C/D] — one-line summary
Social / OG        [A/B/C/D] — one-line summary
Heading Structure  [A/B/C/D] — one-line summary
Content & Keywords [A/B/C/D] — one-line summary
Images & Media     [A/B/C/D] — one-line summary
Technical SEO      [A/B/C/D] — one-line summary
Performance        [A/B/C/D] — INP, LCP, CLS summary
AI Visibility      [A/B/C/D] — AEO/GEO readiness
Docs Coherence     [A/B/C/D] — indexed claims match docs/app/current feature set
─────────────────────────────────────
OVERALL            [A/B/C/D]

Fixed: X issues | Needs decision: Y issues | Proof/docs gaps: Z
```

---

## PROJECT MODE

### Workspace root detection

If the current directory has no project markers (no `package.json`, no `src/` dir, no `astro.config.*`) BUT contains multiple project subdirectories — you are at the **workspace root**, not inside a project.

Use **AskUserQuestion**:
- Question: "You're at the workspace root. Which project(s) should I audit for SEO?"
- `multiSelect: true`
- Options:
  - **All projects** — "Run SEO audit across every applicable project" (Recommended)
  - One option per SEO-applicable project from `${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}/PROJECTS.md`: label = project name, description = stack

Then proceed to **GLOBAL MODE** with the selected projects.

### Phase 1: Technical SEO Infrastructure

#### Crawlability & Indexation
- [ ] `robots.txt` exists and is correct
- [ ] `sitemap.xml` exists and lists all public pages
- [ ] Sitemap referenced in `robots.txt`
- [ ] Canonical URLs on all pages (absolute URLs)
- [ ] No orphan pages
- [ ] No accidental `noindex`
- [ ] 404 page exists with proper status code
- [ ] Redirects are 301 (not 302)

#### Site Architecture
- [ ] URL structure is clean, hierarchical, consistent
- [ ] Max 3 clicks from homepage to any page
- [ ] Breadcrumbs on nested pages
- [ ] Pagination uses `rel="next"` / `rel="prev"` if applicable
- [ ] Docs, guides, changelog and public feature pages are internally linked when they support indexed product claims

#### Performance (SEO-critical)
- [ ] SSG/SSR used (not client-side rendering for content — AI crawlers don't execute JS reliably)
- [ ] HTML served with proper content
- [ ] Core Web Vitals at p75: **LCP < 2.5s**, **INP < 200ms** (replaced FID in March 2024), **CLS < 0.1**
- [ ] Images optimized — AVIF-first via `<picture>` with WebP/JPEG fallbacks
- [ ] LCP image eagerly loaded (`fetchpriority="high"`, `loading="eager"`)
- [ ] No render-blocking resources
- [ ] Fonts use `font-display: swap`
- [ ] Speculation Rules API for predictable navigation paths (optional, big win)

### Phase 2: On-Page SEO — Systematic Scan

For EVERY page, check and record in a table:

| Page | Title (len) | H1 | Meta Desc (len) | OG Image | Schema | Internal Links |
|------|------------|-----|-----------------|----------|--------|---------------|

### Phase 3: Content SEO

- [ ] No duplicate titles across pages
- [ ] No duplicate meta descriptions
- [ ] No thin pages (< 300 words)
- [ ] Blog/article pages have: author, date, category
- [ ] Content collections have proper frontmatter

### Phase 4: Structured Data

- [ ] JSON-LD on relevant pages:
  - Homepage: `Organization` or `WebSite`
  - Blog posts: `Article`
  - Product/pricing: `Product` or `Offer`
  - FAQ sections: `FAQPage`
  - Breadcrumbs: `BreadcrumbList`
- [ ] JSON-LD is valid schema.org

### Phase 5: Internal Linking

Map the internal link graph:
1. Which pages have the most inbound internal links?
2. Which important pages are under-linked?
3. Are anchor texts descriptive?
4. Does navigation reinforce page hierarchy?
5. Topic cluster check: pillar pages linked from 2-5 spokes, spokes linked back to pillar + siblings. Body links pass ~5x more equity than nav/footer.

### Phase 5.5: AI Visibility (AEO / GEO)

**Goal:** ensure the site is discoverable, ingestible, and citable by ChatGPT, Perplexity, Claude, and Google AI Overviews.

#### LLM Accessibility
- [ ] `/llms.txt` at site root — markdown summary, <5000 tokens, links to key canonical pages
- [ ] `/llms-full.txt` with full content in markdown (recommended for docs/knowledge sites)
- [ ] `robots.txt` explicitly allows desired AI crawlers: `GPTBot`, `ClaudeBot`, `PerplexityBot`, `Google-Extended`, `OAI-SearchBot`, `CCBot`
- [ ] Server-rendered HTML for all indexable content (AI crawlers don't execute JS reliably)

#### Citation-Ready Content Structure
- [ ] First 200 words of every page answer its primary query directly (no warm-up intro)
- [ ] Each H2/H3 opens with a bold 1-sentence summary ("nugget extraction" target)
- [ ] Sections are semantically chunked — one concept per section, citable in isolation (2-4 sentence paragraphs, ~256-512 tokens)
- [ ] Question-form headings where topic supports it ("How does X work?", "What is Y?")
- [ ] FAQ block on every major page, wrapped in `QAPage` or `FAQPage` schema
- [ ] ≥3 unique data points / original insights per article (Information Gain)
- [ ] Named author with `Person` schema (`sameAs`, `hasCredential`, `knowsAbout`)

#### AI-Specific Structured Data
- [ ] `Person` schema for author with `sameAs` (LinkedIn/Wikipedia), `hasCredential`, `knowsAbout`
- [ ] `SpeakableSpecification` marking the article's summary passages (3.1x voice/AI citation boost)
- [ ] `QAPage`/`FAQPage` on FAQ pages (+58% ChatGPT citation rate vs plain Article)
- [ ] `HowTo` for tutorials; `Dataset` for data tables; `Review`/`Rating` for reviews
- [ ] `Organization` schema on homepage (founder, `areaServed`, `knowsAbout`)

#### Off-Site AI Signals (report-only, document gaps)
- [ ] Brand name used consistently everywhere (never "Our Product" vs "ProductX" vs "the tool")
- [ ] Flag if client lacks Wikipedia presence or Reddit discussion (GEO gap — 46.7% of Perplexity citations reference Reddit; 47.9% of ChatGPT factual citations reference Wikipedia)
- [ ] Recent publish/update date prominently visible in body (Perplexity freshness filter <90 days)
- [ ] OpenAI/ChatGPT claims are current: official claims checked with OpenAI Docs MCP; third-party citation/SEO claims backed by external research sources

### Phase 6: Fix

Fix all issues in code only after the relevant editorial and technical governance checks are complete. Priority:
1. **Missing/broken meta tags** — highest SEO impact
2. **Missing structured data** — add JSON-LD (including AI-specific types: `Person`, `SpeakableSpecification`, `QAPage`)
3. **llms.txt + AI crawler rules** — generate if missing, the biggest AEO quick win of 2026
4. **Heading hierarchy** — semantic corrections
5. **First-200-words direct answer** — rewrite intros that don't answer the query
6. **Image alt text + AVIF** — descriptive alts and modern formats
7. **Internal linking gaps** — add contextual links, topic cluster structure
8. **Sitemap/robots.txt** — ensure completeness
9. **Performance** — INP <200ms, LCP <2.5s, lazy loading, fonts, images

### Phase 7: Report

```
SEO AUDIT: [project name]
═══════════════════════════════════════

BUSINESS METADATA VERSIONS
  BUSINESS.md    artifact_version=[x|missing] status=[x|missing] updated=[date|missing] confidence=[x|missing] next_review=[date|missing]
  BRANDING.md    artifact_version=[x|missing] status=[x|missing] updated=[date|missing] confidence=[x|missing] next_review=[date|missing]
  GUIDELINES.md  artifact_version=[x|missing] status=[x|missing] updated=[date|missing] confidence=[x|missing] next_review=[date|missing]
  Proof gaps: [missing/stale/unversioned docs that affected scoring, or none]

TECHNICAL SEO
  Crawlability:      [A/B/C/D]
  Site Architecture:  [A/B/C/D]
  Performance:        [A/B/C/D]

ON-PAGE SEO (X pages scanned)
  Titles:            X/Y correct
  Meta Descriptions: X/Y correct
  H1 Tags:           X/Y correct
  OG Tags:           X/Y complete
  Alt Text:          X/Y images covered

STRUCTURED DATA
  Pages with schema: X/Y
  Types used:        [list]

INTERNAL LINKING
  Avg links/page:    X
  Orphan pages:      [list]
  Under-linked:      [list]

AI VISIBILITY (AEO/GEO)
  llms.txt:          [present / missing]
  AI crawlers:       [explicit / implicit / blocked]
  QAPage/HowTo:      X pages with AI-friendly schema
  Speakable:         X pages
  Author schema:     X/Y articles

PAGE-BY-PAGE
  /                  [A/B/C/D]
  /about             [A/B/C/D]
  ...
═══════════════════════════════════════
OVERALL              [A/B/C/D]

Fixed: X issues across Y files
Critical remaining: Z items
Governance:
  Editorial Update Plan:      [complete/no editorial impact/blocked]
  Claim Impact Plan:          [complete/not applicable/blocked]
  Documentation Update Plan:  [complete/no documentation impact/blocked]
```

---

## Tracking (all modes)

Shared file write protocol for `AUDIT_LOG.md` and `TASKS.md`:
- Treat the snapshots loaded at skill start as informational only.
- Right before each write, re-read the target file from disk and use that version as authoritative.
- Append or replace only the intended row or subsection; never rewrite the whole file from stale context.
- If the expected anchor moved or changed, re-read once and recompute.
- If it is still ambiguous after the second read, stop and ask the user instead of forcing the write.

After generating the report and applying fixes:

### Log the audit

Append a row to two files:

1. **Global `${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}/AUDIT_LOG.md`**: append a row filling only the SEO column, `—` for others.
2. **Project-local `./AUDIT_LOG.md`**: same without the Project column.

Create either file if missing.

### Update TASKS.md

1. **Local TASKS.md** (project root): add/replace an `### Audit: SEO` subsection with critical (🔴), high (🟠), and medium (🟡) issues as task rows.
2. **Master `${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}/TASKS.md`**: find the project's section, add/replace an `### Audit: SEO` subsection with the same tasks. Update the Dashboard "Top Priority" if critical issues found.

---

## Important (all modes)

- Infer the target keyword from content and URL. If unclear, ask.
- For French content: meta descriptions and titles in French, accented URL slugs OK if project is consistent.
- Never stuff keywords. Natural language always wins.
- Structured data must be valid JSON-LD with schema.org types.
- For Astro sites: leverage `@astrojs/sitemap` and `<Image>` component.
- For 100+ content page sites, focus detailed audit on templates/layouts since all pages of a type share the same SEO structure.
- **Accents français obligatoires.** Lors de toute création ou modification de contenu en français (meta descriptions, titres, alt text, données structurées), vérifier systématiquement que TOUS les accents sont présents et corrects (é, è, ê, à, â, ù, û, ô, î, ï, ç, œ, æ). Les accents manquants sont une faute d'orthographe. Relire chaque texte produit pour s'assurer qu'aucun accent n'a été oublié — c'est une erreur très fréquente à corriger impérativement.
