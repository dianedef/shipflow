---
name: sf-enrich
description: Research the web and upgrade a blog article, product page, or entire content folder — fresh data, actionable advice, user-centric, conversion-driven
disable-model-invocation: true
argument-hint: <file-path or folder>
---

## Context

- Current directory: !`pwd`
- Project CLAUDE.md: !`head -120 CLAUDE.md 2>/dev/null || echo "no CLAUDE.md"`
- Business context: !`head -60 BUSINESS.md 2>/dev/null || echo "no BUSINESS.md — run /sf-init to generate"`
- Brand voice: !`head -60 BRANDING.md 2>/dev/null || echo "no BRANDING.md — run /sf-init to generate"`
- Content language: !`grep -ri "lang=" src/layouts/*.astro src/app/layout.tsx 2>/dev/null | head -3 || echo "detect from content"`
- Content structure: !`ls $ARGUMENTS 2>/dev/null | head -30 || echo "single file mode"`

## Pre-check : contexte business/marque

Avant de commencer, vérifier le contexte chargé ci-dessus. Si BUSINESS.md ou BRANDING.md est absent :

**Afficher un avertissement avant de commencer :**
```
⚠ Contexte manquant :
- [BUSINESS.md manquant] L'enrichissement sera générique sans connaître l'audience cible et la proposition de valeur.
- [BRANDING.md manquant] Le ton et la voix de marque ne pourront pas être respectés.

→ Lancer /sf-init pour générer ces fichiers, ou /sf-docs update pour les mettre à jour.
```

Si les fichiers existent mais semblent incomplets, signaler. Continuer dans tous les cas.

---

## Metadata et versioning

Cette skill enrichit souvent du contenu applicatif. Elle doit donc distinguer :
- **Contenu applicatif runtime** (`src/content/**`, pages MD/MDX/Astro consommées par le site) : préserver le schéma existant et ajouter uniquement des champs compatibles.
- **Artefacts ShipFlow business/content** (briefs, rapports, docs éditoriales, pages de stratégie hors runtime) : frontmatter ShipFlow obligatoire avec `metadata_schema_version`, `artifact_version` et `depends_on`.

Avant l'enrichissement, lire le frontmatter complet de `BUSINESS.md`, `BRANDING.md` et des docs éditoriales/copywriting existantes (`docs/copywriting/persona.md`, `docs/copywriting/strategie.md`) quand elles existent. Le contenu enrichi doit respecter les versions de contexte utilisées.

Champs compatibles à ajouter seulement si le schéma du projet les accepte :

```yaml
source_skill: sf-enrich
content_status: updated
confidence: medium
business_intent: "[informational|conversion|editorial]"
target_audience: "[persona]"
primary_keyword: "[keyword]"
business_context_version: "[BUSINESS.md artifact_version or unknown]"
brand_context_version: "[BRANDING.md artifact_version or unknown]"
depends_on:
  - artifact: "BUSINESS.md"
    artifact_version: "[version or unknown]"
  - artifact: "BRANDING.md"
    artifact_version: "[version or unknown]"
  - artifact: "docs/copywriting/persona.md"
    artifact_version: "[version or unknown]"
```

Si le schéma applicatif ne permet pas `depends_on` ou les champs ShipFlow, ne pas les forcer. Reporter les versions utilisées dans le rapport final sous `Context versions` et signaler les versions absentes comme `metadata gaps`.

### Bump `artifact_version`

Pour les artefacts ShipFlow enrichis :
- `MAJOR` (`1.0.0` -> `2.0.0`) : changement de thèse, audience cible, promesse, positionnement, recommandation business centrale ou angle stratégique.
- `MINOR` (`1.0.0` -> `1.1.0`) : ajout de sections importantes, nouvelles sources qui changent une recommandation, nouveau CTA stratégique, nouveau segment/persona ou mise à jour substantielle de données.
- `PATCH` (`1.0.0` -> `1.0.1`) : correction de lien, typo, source, date, exemple ou reformulation sans changement de sens.

Pour le contenu applicatif, ne bump `artifact_version` que si le champ existe déjà ou si le schéma le permet. Sinon, mettre à jour `dateModified`/`lastUpdated`/`updatedAt` selon la convention du projet et documenter les dépendances dans le rapport.

---

## Your task

Upgrade content to be genuinely useful, technically accurate, and action-driving. The reader should leave knowing more AND knowing exactly what to do next.

---

### MODE DETECTION

- If `$ARGUMENTS` is a **file**: single article/page mode.
- If `$ARGUMENTS` is a **folder**: batch mode — use **AskUserQuestion** to let the user pick which files:
  - Question: "Which files should I enrich?"
  - `multiSelect: true`
  - List all content files in the folder (`.md`, `.mdx`, `.astro`) with their title from frontmatter as description
  - Pre-select all files
- If no argument: use **AskUserQuestion** to help the user pick:
  - Question: "What content should I enrich?"
  - `multiSelect: false`
  - Scan for content directories (`src/content/`, `src/pages/`, `content/`) and list them as options
  - Include a "Specific file" option — if selected, ask for the path

---

### PHASE 1: UNDERSTAND THE CONTENT

1. Read the target file(s).
2. Identify for each piece:
   - **Topic**: What specific subject does this cover?
   - **Audience**: Who is reading this? What's their skill level? What problem are they solving?
   - **Intent**: Is the reader researching, comparing, learning, or ready to act?
   - **Current quality**: Is it thin/outdated/generic, or already solid but could be sharper?
   - **Language**: French or English? Match it exactly.
   - **Content type**: Blog post, tutorial, product page, landing page, documentation?

---

### PHASE 2: RESEARCH

For each piece of content, search the web for:

1. **Current data & stats** — Find the latest numbers, benchmarks, studies (2024-2026). Replace any outdated stats. Cite sources naturally with inline links.
2. **Technical accuracy** — Verify claims, API references, tool versions, framework features. If something has changed (new API, deprecated method, better alternative), update it.
3. **What the competition covers** — Search the same topic. Identify what the top 3 results include that this content doesn't. Fill those gaps.
4. **Real examples & case studies** — Find concrete examples, real company stories, actual results. Generic advice is forgettable; specific examples stick.
5. **Expert quotes or frameworks** — Find a relevant expert perspective, mental model, or methodology to reference (not just random quotes for decoration).
6. **Primary source preference** — prefer `.edu` / `.gov` / peer-reviewed / official docs / original GitHub repos over blog summaries. AI platforms assign highest trust to primary sources.
7. **Content decay scan** — flag any stat > 18 months old, any "recently/currently" phrasing, any reference to deprecated APIs/tools/versions in the existing content.

Use `WebSearch` and `mcp__exa__web_search_exa` for research. Search in the **same language** as the content (French topics → French queries + English queries for technical depth).

#### OpenAI freshness gate

If the target content mentions OpenAI, ChatGPT, GPT models, Codex, OpenAI API, Responses API, Assistants/Agents, function/tool calling, structured outputs, Whisper/transcription, image generation, embeddings, GPTBot, OAI-SearchBot, OpenAI pricing, or OpenAI prompt guidance:
- Use `mcp__openaiDeveloperDocs__search_openai_docs` / `fetch_openai_doc` before rewriting any OpenAI-specific claim.
- For model-selection or "latest/current/default/best model" claims, fetch `https://developers.openai.com/api/docs/guides/latest-model.md`.
- Treat OpenAI Docs MCP as authoritative for OpenAI product/API/model behavior; fallback only to official OpenAI domains and report the fallback.
- For ChatGPT citation behavior, AEO/GEO benchmarks, market adoption, SEO impact, or third-party studies, use broader web research too; do not attribute non-OpenAI claims to OpenAI docs.
- If the content contains outdated claims such as old browsing/plugin behavior, legacy model names, stale pricing, old prompt-engineering guidance, or deprecated API examples, flag it as `OpenAI freshness risk` in the report.

---

### PHASE 3: REWRITE

Apply these principles to every piece of content:

#### Be the reader's smartest friend
- Write like you're explaining to a colleague over coffee — knowledgeable but never condescending.
- Anticipate their questions. Answer them before they ask.
- Use "you" constantly. This is about them, not about us.
- Acknowledge their pain points honestly before offering solutions.

#### Make it technically credible
- Every claim backed by data, a source, or a concrete example.
- Include specific numbers: "reduces load time by 40%" not "improves performance."
- Name the tools, versions, and methods. Vague = useless.
- If something is nuanced or "it depends," say so and explain when each option applies.
- Link to official docs, studies, or authoritative sources inline (not in a footnote nobody reads).

#### Make it scannable and structured
- **Hook in the first 2 sentences**: State the problem or outcome. No throat-clearing intros.
- **Subheadings that tell a story**: A reader skimming headings should get 80% of the value.
- **Short paragraphs** (2-3 sentences max). One idea per paragraph.
- **Bullet points and numbered lists** for steps, comparisons, checklists.
- **Bold key phrases** so the scanner catches the important bits.
- **TL;DR or key takeaway** at the top for long articles (> 1500 words).

#### Push to action — every single time
- End every major section with a micro-CTA or next step.
- The conclusion is NOT a summary. It's a launchpad: "Here's what to do right now."
- Be specific: "Open your terminal and run `npx create-astro`" not "consider trying Astro."
- For business content: tie every insight to revenue, time saved, or growth.
- For technical content: tie every concept to a concrete implementation step.
- Include a **"Start here" box** or **"Quick win"** callout for readers who want immediate results.

#### Make it feel alive
- Use current examples (2024-2026, not 2020 case studies).
- Reference real tools, real companies, real numbers.
- Include before/after comparisons where applicable.
- Add context: "This matters because..." — connect the dots for the reader.
- No filler. Every sentence must earn its place. If a paragraph says "X is important," delete it and show WHY it's important.

---

### PHASE 4: ENRICH WITH EXTRAS

Where appropriate, add:

- [ ] **Quick Answer / TL;DR box** at top — 40-60 words or 3-5 bullets answering the core query directly (the passage LLMs most often extract)
- [ ] **Key Takeaways box** at end — recap for scanners who scrolled past
- [ ] **Comparison tables** — for tool/framework/approach comparisons
- [ ] **Step-by-step instructions** — numbered, with expected outcomes at each step
- [ ] **Code snippets** — working, copy-paste ready, with comments explaining the "why"
- [ ] **Callout boxes** — for warnings, pro tips, or "common mistakes"
- [ ] **Internal links** — 2-5 contextual body links per 1000 words (body links pass ~5x more equity than nav/footer). Each spoke links to its pillar + 2-3 sibling spokes. Total page links < 150.
- [ ] **Updated stats with sources** — inline links to authoritative primary sources (.edu, .gov, peer-reviewed, official docs)
- [ ] **FAQ section** — address the long-tail questions people actually search for (wrap in `FAQPage`/`QAPage` schema)
- [ ] **Estimated reading time** — in frontmatter if the framework supports it
- [ ] **Interactive element** where topic supports it: calculator (ROI, pricing, sizing), quiz, comparison slider, configurator. Data: +52.6% engagement, -18 to -32% bounce on pricing
- [ ] **Mermaid diagram** for processes, architectures, decision trees (renders natively in most markdown pipelines, version-controllable)
- [ ] **Annotated screenshot** for any UI-related claim (numbered callouts over raw screenshot)
- [ ] **"Last updated" visible in body** ("Updated April 2026" line under H1) — over a third of AI citations go to content updated in the last 3 months
- [ ] **Changelog section at end** — bullet list of substantive edits with dates ("Apr 2026: replaced Vercel pricing table, added Next.js 15 section")
- [ ] **Sources section at end** — primary references listed explicitly, parallel to inline citations

### PHASE 4.5: AI VISIBILITY LAYER

Optimize the content to be found, extracted, and cited by ChatGPT, Perplexity, Claude, Google AI Overviews. Apply to all substantial pages:

#### Structure for LLM extraction
- [ ] **First 40-60 words answer the core query** in one self-contained, quotable sentence. No warm-up intro.
- [ ] **Semantic chunking**: each H2/H3 = one atomic concept, 2-4 sentence paragraphs, ~256-512 tokens per logical block (matches how Perplexity/ChatGPT slice content)
- [ ] **Inverted pyramid per section**: lead sentence of every H2 = the answer, then elaboration
- [ ] **Question-shaped headings** where natural ("What is X?", "How does Y work?", "When should you use Z?")
- [ ] **3-5 quotable sentences per article** — standalone claims that read cleanly when extracted (no "as mentioned above", no "in this article")
- [ ] **Claim-source proximity**: every stat or fact cited in the same sentence or immediately after, not in a bibliography
- [ ] **Fact density**: one statistic or specific number per 150-200 words
- [ ] **Entity-rich language**: named tools, companies, standards, people, dates (15+ recognized entities → 4.8x citation rate)
- [ ] **OpenAI claims checked when relevant**: any ChatGPT/OpenAI/Codex/API/model statement is supported by OpenAI Docs MCP or clearly marked as broader market research.

#### E-E-A-T concrete checklist (every article)
- [ ] **Named author** with bio page (credentials, LinkedIn, years of experience on topic)
- [ ] **First-person experience signal** — at least one "When I shipped X…", "In our audit of 40 sites…", "The mistake I made…" passage (March 2026 Google core update amplified Experience over Expertise)
- [ ] **Original screenshot/chart/photo** (not stock) — insider-only visuals
- [ ] **Before/after numbers with methodology**: "reduced p95 from 820ms to 310ms using X" (not "improved performance")
- [ ] **Dated timestamps**: `datePublished` + `dateModified` in frontmatter AND visible in body
- [ ] **Limitation / caveat statement**: one sentence acknowledging when the advice doesn't apply
- [ ] **Reviewer line for YMYL topics**: "Reviewed by [name, credentials]"
- [ ] **Editorial disclosure** where relevant (affiliate, sponsored)

#### Schema.org matrix — inject the right JSON-LD per page type

| Page type | Schema to inject | Notes |
|---|---|---|
| Blog post / article | `Article` + `author` (Person with `sameAs`, `hasCredential`) + `datePublished` + `dateModified` + `publisher` | Foundational |
| Tutorial / step-by-step | `HowTo` with `HowToStep` array + images per step | Required for step extraction |
| FAQ block | `FAQPage` | Google rich-result restricted since Aug 2023 to gov/health, but ChatGPT/Perplexity/Claude still parse as primary extraction format — keep injecting |
| User-generated Q&A | `QAPage` (not FAQPage) | When a single question allows multiple answers |
| Product / tool review | `Review` + `Rating` + `itemReviewed` | |
| Voice / AI priority | `SpeakableSpecification` pointing to Quick Answer + Key Takeaways CSS selectors | 3.1x voice/AI citation boost |
| Pillar page | `Article` + `mainEntityOfPage` + explicit `about` / `mentions` entities | Helps AI build entity map |
| Comparison article | `Article` + embedded `Table` + `ItemList` | List structure extracts cleanly |

---

### PHASE 5: CONVERSION LAYER

Every piece of content should serve the business. Add naturally (not forced):

- [ ] **Contextual CTA** — related to what the reader just learned (not a random product plug)
- [ ] **Lead magnet hook** — "Want the full checklist? Get it free..." (if the site has email capture)
- [ ] **Social proof** — mention user count, client results, or testimonials where relevant
- [ ] **Next content** — link to the logical next article/page in the reader's journey
- [ ] **Author credibility** — brief mention of why this author/company knows this topic

Do NOT make content feel like a sales page. The value comes first. The CTA is a natural extension of the value.

---

### PHASE 6: QUALITY CHECK

Before finishing, verify:

- [ ] All added stats have a source link (no unattributed claims)
- [ ] All code snippets are syntactically correct and up to date
- [ ] No broken links or placeholder URLs
- [ ] Frontmatter is complete (title, description, date updated, tags, author)
- [ ] Frontmatter metadata is preserved and enriched when compatible: `dateModified`, `source_skill`, `content_status`, `confidence`, `primary_keyword`, `target_audience`, `evidence`, `docs_impact`, `business_context_version`, `brand_context_version`, `depends_on`
- [ ] Application content schema is still valid; incompatible ShipFlow metadata is reported instead of forced into frontmatter
- [ ] Meta description is rewritten to match the upgraded content
- [ ] Reading flow is smooth when read top-to-bottom
- [ ] The piece passes the "so what?" test — every section answers why the reader should care
- [ ] **JSON-LD injected** per Schema.org matrix, validated via Schema Markup Validator
- [ ] **Quick Answer block exists** and is self-contained (readable out of context)
- [ ] **`dateModified` updated** in frontmatter AND body when substantive changes made
- [ ] **At least one first-person experience passage** present
- [ ] **Changelog updated** with dated bullet
- [ ] **Content decay clean**: no year mentions > 18 months, no "recently" fossil, no deprecated tool names

---

### PHASE 7: REPORT

For single files:
```
ENRICHED: [article title]
─────────────────────────────────────
Topic:                 [subject]
Audience:              [who + intent]
Language:              [FR/EN]
Sources added:         X (from Y web searches; Z primary)
Stats updated:         X
Sections added:        [list]
CTAs added:            X
Word count:            before → after
─────────────────────────────────────
AI VISIBILITY LAYER
Quick Answer added:    [Y/N]
Schema types injected: [Article, FAQPage, ...]
Interactive elements:  [calculator, quiz, ...]
Experience signals:    X first-person passages added
Decay signals fixed:   [list]
Changelog updated:     [Y/N]
Context versions:
  BUSINESS.md:         [artifact_version or unknown/not found]
  BRANDING.md:         [artifact_version or unknown/not found]
  Persona/strategy:    [artifact_version or unknown/not found]
Metadata gaps:         [none / list]
─────────────────────────────────────
Key changes:
• [change 1]
• [change 2]
• ...
```

For folders:
```
ENRICHED: [folder] — X/Y files upgraded
═══════════════════════════════════════
  article-1.md     ✓  +X sources, +Y words
  article-2.md     ✓  +X sources, +Y words
  article-3.md     ⏭  skipped (already strong)
  ...
═══════════════════════════════════════
Total sources added:  X
Total stats updated:  X
Total CTAs added:     X
```

---

### IMPORTANT

- **Language matching is sacred.** French content stays French. English stays English. Research in both languages for depth, but write in the content's language.
- **For French sites** (webinde, siteweb---transformemavie): respect the existing editorial conventions in CLAUDE.md (tutoiement, heading format "TECHNIQUE : MÉTAPHORE", scientific sources with natural links, never delete existing content).
- **Never invent stats.** If you can't find a source, say "according to industry benchmarks" or skip it. A wrong number destroys trust.
- **Never delete the author's voice.** Enhance structure, add data, sharpen the message — but keep THEIR personality. You're a co-writer, not a replacement.
- **Batch mode prioritization:** In a folder, process high-traffic pages first (homepage, pillar content) before long-tail articles. Skip files that are already strong — say so in the report.
- **Update the frontmatter `date`** or `lastUpdated` field to today when content is significantly changed.
- **Preserve existing frontmatter schema** and add compatible metadata only when it will not break the content collection parser. If business/brand version metadata cannot be stored in frontmatter, include it in the final report.
- **Accents français obligatoires.** Lors de toute création ou modification de contenu en français, vérifier systématiquement que TOUS les accents sont présents et corrects (é, è, ê, à, â, ù, û, ô, î, ï, ç, œ, æ). Les accents manquants sont une faute d'orthographe. Relire chaque texte produit pour s'assurer qu'aucun accent n'a été oublié — c'est une erreur très fréquente à corriger impérativement.
