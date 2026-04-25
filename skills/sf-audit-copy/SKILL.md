---
name: sf-audit-copy
description: "Professional copywriting review — single page (with argument) or full project audit (no argument)"
disable-model-invocation: true
argument-hint: '[file-path | "global"] (omit for full project)'
---

## Context

- Current directory: !`pwd`
- Project CLAUDE.md: !`head -100 CLAUDE.md 2>/dev/null || echo "no CLAUDE.md"`
- Business context: !`head -60 BUSINESS.md 2>/dev/null || echo "no BUSINESS.md — run /sf-init to generate"`
- Brand voice: !`head -60 BRANDING.md 2>/dev/null || echo "no BRANDING.md — run /sf-init to generate"`
- Business metadata: !`for f in BUSINESS.md BRANDING.md GUIDELINES.md; do if [ -f "$f" ]; then printf '%s: ' "$f"; sed -n '1,40p' "$f" | grep -E '^(metadata_schema_version|artifact_version|status|updated|confidence|next_review):' | tr '\n' ' '; printf '\n'; else echo "$f: missing"; fi; done`
- Content language: !`grep -ri "lang=" src/layouts/*.astro src/app/layout.tsx 2>/dev/null | head -5 || echo "unknown"`
- All pages: !`find src/pages src/app -name "*.astro" -o -name "*.tsx" -o -name "*.vue" 2>/dev/null | grep -v node_modules | sort`
- i18n/translations: !`find src -path "*/i18n/*" -o -path "*/locales/*" -o -path "*/messages/*" 2>/dev/null | head -10 || echo "none"`
- Content collections: !`find src/content -type f 2>/dev/null | head -20 || echo "no content dir"`

## Pre-check : contexte business/marque

Avant de commencer, vérifier le contexte chargé ci-dessus. Si BUSINESS.md ou BRANDING.md est absent :

**Afficher un avertissement en tête de rapport :**
```
⚠ Contexte manquant :
- [BUSINESS.md manquant] L'audit ne peut pas vérifier l'alignement avec l'audience cible et la proposition de valeur.
- [BRANDING.md manquant] L'audit ne peut pas vérifier la cohérence de la voix de marque.

→ Lancer /sf-init pour générer ces fichiers, ou /sf-docs update pour les mettre à jour.
```

Si les fichiers existent mais semblent très courts (< 5 lignes de contenu hors titres) ou contiennent `<!-- à confirmer -->`, ajouter :
```
⚠ Contexte incomplet : BUSINESS.md/BRANDING.md contient des sections non confirmées. Les recommandations de cet audit seront plus pertinentes une fois le contexte complété.
```

Continuer l'audit dans tous les cas — ne pas bloquer. L'avertissement sert à informer, pas à empêcher.

---

## Metadata versioning doctrine

`BUSINESS.md`, `BRANDING.md`, and `GUIDELINES.md` are ShipFlow decision contracts for copy audits. Before scoring:
- Read/report `artifact_version`, `status`, `updated`, `confidence`, and `next_review` when available.
- If `artifact_version`, `status`, or `updated` is missing, add a proof gap: `business doc metadata incomplete`.
- If `status` is `draft`, `stale`, `outdated`, `deprecated`, or `confidence` is `low`, cap confidence and state that copy recommendations depend on an unreviewed business contract.
- If `next_review` is before today's absolute date, treat the document as stale unless a newer replacement is explicit.
- If value proposition, tone, ICP language, pricing copy, trust claims, or sensitive claims rely on stale or unversioned docs, do not give `A` to the affected category.
- Include a `Business metadata versions` section in every report.

Use ShipFlow versioning semantics: patch = wording clarification without decision change, minor = changed message/voice guidance inside the same strategy, major = changed ICP, positioning, pricing promise, trust posture, market, or brand strategy.

---

## Doctrine business et documentation

La copy doit être jugée comme une interface produit, pas seulement comme du texte :
- la promesse utilisateur doit rester cohérente entre landing pages, app, docs, pricing, FAQ, emails et support
- les claims sensibles (sécurité, conformité, gains, IA, automatisation, disponibilité, économies) doivent être précis et prouvables
- les microcopies doivent refléter les vrais états système : succès, échec, attente, permission refusée, paiement, retry
- quand une feature change, la copy publique et la documentation active doivent être alignées ou signalées comme dette produit

Ne pas corriger une page en embellissant une promesse que le produit ou la documentation ne démontre pas. Dans ce cas, signaler `proof gap` ou `docs mismatch`.

---

## Mode detection

- **`$ARGUMENTS` is "global"** → GLOBAL MODE: audit ALL projects in the workspace.
- **`$ARGUMENTS` is a file path** → PAGE MODE: review that single page.
- **`$ARGUMENTS` is empty** → PROJECT MODE: full copywriting audit of the entire project.

---

## GLOBAL MODE

Audit ALL web projects in the workspace for copywriting quality.

1. Read `/home/claude/shipflow_data/PROJECTS.md` — check the **Domain Applicability** table. Identify projects with ✓ in the Copy column.

2. Use **AskUserQuestion** to let the user choose:
   - Question: "Which projects should I audit for copywriting?"
   - `multiSelect: true`
   - One option per applicable project: label = project name, description = stack from PROJECTS.md
   - All applicable projects pre-listed as options

3. Use the **Task tool** to launch one agent per **selected** project — ALL IN A SINGLE MESSAGE (parallel). Each agent: `subagent_type: "general-purpose"`.

   Agent prompt must include:
   - `cd [path]` then read `CLAUDE.md` for project context
   - The absolute date, exact project path, and the copy context already surfaced by this skill (`BUSINESS.md`, `BRANDING.md`, language/i18n hints)
   - The complete **PROJECT MODE** section from this skill (all 6 phases: Voice & Tone Inventory → Messaging Hierarchy → Page-by-Page Copy Scan → Conversion Copy Check → Fix → Report)
   - The **Tracking** section from this skill
   - Rule: **read-only analysis** — no code fixes, only update AUDIT_LOG.md and TASKS.md
   - Rule: before scoring, identify the linked pages, funnel position, and downstream consequences of weak messaging or CTA choices
   - Rule: call out product promise drift, documentation mismatch, and unproven sensitive claims explicitly
   - Rule: read/report `BUSINESS.md`, `BRANDING.md`, and `GUIDELINES.md` metadata versions; flag missing, stale, low-confidence, or unversioned contracts as proof gaps before scoring
   - Rule: do not ask follow-up questions; if context is missing, state assumptions / confidence limits and continue
   - Required sub-report sections: `Scope understood`, `User story / promise`, `Business metadata versions`, `Context read`, `Linked systems & consequences`, `Docs coherence`, `Risky assumptions / proof gaps`, `Findings`, `Confidence / missing context`

4. After all agents return, compile a **cross-project copy report**:

   ```
   GLOBAL COPY AUDIT — [date]
   ═══════════════════════════════════════
   PROJECT SCORES
     [project]    [A/B/C/D]  —  summary
     ...
   CROSS-PROJECT PATTERNS
     [Systemic copy issues in 2+ projects]
   ALL ISSUES BY SEVERITY
     🔴 [project] file:line — description
     🟠 [project] file:line — description
     🟡 [project] file:line — description
   Total: X critical, Y high, Z medium across N projects
   ═══════════════════════════════════════
   ```

5. Update `/home/claude/shipflow_data/AUDIT_LOG.md` (one row per project, Copy column) and `/home/claude/shipflow_data/TASKS.md` (each project's `### Audit: Copy` subsection).

6. Ask: **"Which projects should I fix?"** — list projects with scores. Fix only approved projects, one at a time.

---

## PAGE MODE

### Step 1: Gather the page

1. Read the target file (`$ARGUMENTS`).
2. Read layout/wrapper components for shared copy (nav, footer, CTAs).
3. Read i18n/translation files if the project uses them.
4. Identify the page's role in the user journey (landing, feature, pricing, blog, docs, etc.).

### Step 2: Audit against this checklist

Score each category **A/B/C/D**. Be strict — professional copywriter standard.

#### 1. Value Proposition & Messaging
- [ ] Primary benefit is clear within 5 seconds of reading (5-second test: show hero to a cold reader; they must name the **job-to-be-done**, not the product category)
- [ ] Headline names the customer's job ("Close books in 2 days not 2 weeks"), not the tool category
- [ ] Headline answers "what's in it for me?" not "what is this?"
- [ ] Subheadline adds specificity (numbers, outcomes, timeframe)
- [ ] Copy speaks to a specific audience, not everyone
- [ ] Features are framed as benefits (not just feature lists)
- [ ] StoryBrand check: customer = hero, product = guide (not the reverse)
- [ ] Core promise is consistent with product behavior, docs, pricing, FAQ and onboarding

#### 2. Clarity & Readability
- [ ] Sentences average under 20 words, with **variance** (SD > 6 words) — robotic uniformity is an AI-content tell
- [ ] Paragraphs are 2-3 sentences max
- [ ] No jargon without context (or jargon is intentional for the audience)
- [ ] Active voice dominant (passive < 10%)
- [ ] Reading level: **FK grade 6-8 for consumer**, **8-10 for B2B technical**. Secondary: SMOG ≤ 9 (WCAG 3.0 draft alignment)
- [ ] Pages > 400 words have a plain-language summary at top (WCAG 3 pattern)
- [ ] No filler words ("very", "really", "just", "actually", "basically")

#### 3. Persuasion & Psychology
- [ ] Social proof present where claims are made (testimonials, numbers, logos)
- [ ] Urgency/scarcity used authentically (not fake countdown timers)
- [ ] Objections addressed before they arise
- [ ] Risk reversal present (guarantee, free trial, no credit card)
- [ ] Emotional trigger matches audience's primary motivation

#### 4. Calls to Action
- [ ] Primary CTA uses **action verb + specific outcome + timeframe/quantity** ("Start your 14-day trial", not "Get started" — "Start Your" variant beat "Get started" +90% in Unbounce test)
- [ ] One clear primary CTA per section (no competing CTAs)
- [ ] CTA copy matches what actually happens next
- [ ] Button text works standalone (makes sense without surrounding context)
- [ ] Secondary CTAs provide a lower-commitment alternative
- [ ] Mobile hero: headline readable without scroll; CTA above the fold on 390px viewport
- [ ] Objection block near CTA (refund policy, no-card-required, data-ownership)

#### 5. Microcopy & UX Writing
- [ ] Form labels are clear, not clever
- [ ] Error messages explain what went wrong AND how to fix it
- [ ] Success messages confirm what happened
- [ ] Empty states guide the user to take action
- [ ] Loading states set expectations
- [ ] Navigation labels are predictable (no creative menu names)
- [ ] Messages match true system state and permission model; no false success, false availability, or hidden failure

#### 6. Tone & Voice Consistency
- [ ] Tone is consistent across the page (no formal → casual switches)
- [ ] Voice matches brand personality throughout
- [ ] Humor (if used) doesn't undermine trust
- [ ] Address style is consistent (tu/vous in French, you/we in English)
- [ ] Technical level is consistent

#### 7. Grammar & Polish
- [ ] Zero spelling errors
- [ ] Zero grammar errors
- [ ] Consistent capitalization (title case vs sentence case)
- [ ] Consistent punctuation
- [ ] No broken interpolation or placeholder text (`{name}`, `Lorem ipsum`)
- [ ] No mixed smart/straight quotes (paste artifact)
- [ ] French typography: `espace insécable` before `: ; ! ? »`, guillemets français `« »` not `" "`

#### 8. AI-Voice Detection

Flag each hit — these are 2026 "AI slop" patterns that erode trust.

**EN blacklist — verbs:** delve, delve into, leverage, unlock, harness, navigate (the landscape/complexities), foster, empower, streamline, revolutionize, unleash, unveil, underscore, garner, boast.

**EN blacklist — nouns:** tapestry, landscape, realm, journey, testament, interplay, intricacies, nuances, ecosystem, wealth (of), plethora, myriad, paradigm.

**EN blacklist — adjectives:** seamless, robust, vibrant, meticulous, crucial, pivotal, comprehensive, cutting-edge, game-changing, transformative, intricate, invaluable, multifaceted, bespoke, unparalleled.

**EN blacklist — phrases:** "It's important to note", "It's worth noting", "In today's fast-paced world", "In the ever-evolving landscape of", "In the realm of", "Furthermore" / "Moreover" / "Additionally" (as sentence openers), "In conclusion", "Ultimately", "As an AI", "I hope this helps", "Let's dive in", "At the heart of", "When it comes to", "The key takeaway is", "Whether you're a…or a…", "Not only…but also".

**FR blacklist — expressions:** "il est important de noter", "il convient de souligner", "dans le monde d'aujourd'hui", "à l'ère du numérique", "au cœur de", "que vous soyez… ou…", "plongez dans", "découvrez", "élevez", "incontournable", "révolutionner" (dans le sens marketing), "dans un paysage en constante évolution", "tirez parti de", "libérez le potentiel", "sans couture" (calque), "robuste", "harmonieux", "tapisserie", "voyage" (métaphorique).

**Structural tells:**
- [ ] Em dash density < 1 per 300 words
- [ ] No rule-of-three tricolons in every paragraph
- [ ] No paragraph starting with "Furthermore/Moreover/Additionally/En outre/De plus" (max 1 per page)
- [ ] Sentence length has variance (SD > 6 words)
- [ ] No identical grammatical structure in every bullet of a list
- [ ] No "As an AI" / "I hope this helps" residue

#### 9. AI-era Trust Signals

With AI-generated content saturation, human-verifiable signals are the primary differentiator — for both human trust AND LLM citation (Google E-E-A-T + GEO reward the same markers).

- [ ] Named human author(s) with credentials on every long-form page
- [ ] Dated timestamp visible ("Published", "Last updated", "Tested in April 2026")
- [ ] First-person experience markers ("We tested X for 30 days", "In 47 customer interviews we…") — not generic "X is the best"
- [ ] Specific numbers over vague intensifiers ("reduced p95 from 820ms to 310ms" beats "dramatically faster")
- [ ] At least one verifiable external proof per key claim (case study, dated screenshot, named customer)
- [ ] Author/team bio reachable in ≤ 1 click from the page
- [ ] Schema.org `author` + `datePublished` present in source (verify in head)
- [ ] Feature claims link to docs, examples, changelog, case study, or product evidence when the claim affects buying trust

#### 10. LLM-Answer-Engine Readiness (AEO/GEO)

Based on the Princeton GEO study — these structures lift LLM citation by 30-40%.

- [ ] First 40-60 words contain a direct, quotable one-sentence answer to the page's implied question
- [ ] Fact density: one statistic or specific number per 150-200 words
- [ ] 2-3 expert quotes or named citations per 1000 words; 5-7 outbound links to authoritative domains
- [ ] H2/H3 use question-form headings where appropriate ("How does X work?", "What is Y?")
- [ ] Key claims phrased as standalone sentences (not buried in clauses) — extractable by LLM
- [ ] Schema.org `Article`, `FAQPage`, or `HowTo` in source with `author` + `datePublished`

#### 11. Conversion Copy (CRO 2025-2026)

- [ ] **Message match**: landing hero mirrors the ad/referrer promise
- [ ] **Trust sequencing**: social proof appears *before* price on pricing pages
- [ ] **Hidden-cost transparency**: no "contact us" where a price range could exist; disclose add-ons, taxes, seats
- [ ] **Conversational error pattern**: "That email doesn't look right — did you mean gmail.com?" beats "Invalid input"

### Step 3: Rewrite and fix

For each issue rated B or worse:
1. Quote the problematic copy.
2. Explain why it's weak.
3. Provide a rewritten version directly in the code.
4. For subjective tone choices, propose 2 options and ask the user.

### Step 4: Report

```
COPY REVIEW: [page name]
─────────────────────────────────────
Business metadata:
  BUSINESS.md    artifact_version=[x|missing] status=[x|missing] updated=[date|missing] confidence=[x|missing]
  BRANDING.md    artifact_version=[x|missing] status=[x|missing] updated=[date|missing] confidence=[x|missing]
  GUIDELINES.md  artifact_version=[x|missing] status=[x|missing] updated=[date|missing] confidence=[x|missing]
Value Proposition  [A/B/C/D] — one-line summary
Clarity            [A/B/C/D] — one-line summary
Persuasion         [A/B/C/D] — one-line summary
Calls to Action    [A/B/C/D] — one-line summary
Microcopy          [A/B/C/D] — one-line summary
Tone & Voice       [A/B/C/D] — one-line summary
Grammar & Polish   [A/B/C/D] — one-line summary
AI-Voice Detection [A/B/C/D] — X slop hits (list top 5)
Trust Signals      [A/B/C/D] — named author, dates, first-person proof
AEO/GEO Readiness  [A/B/C/D] — direct answer, question headings, fact density
Conversion Copy    [A/B/C/D] — message match, trust sequencing
Docs Coherence     [A/B/C/D] — docs/pricing/FAQ/onboarding aligned
─────────────────────────────────────
OVERALL            [A/B/C/D]

Rewrites applied: X | Needs decision: Y | Proof/docs gaps: Z
```

---

## PROJECT MODE

### Workspace root detection

If the current directory has no project markers (no `package.json`, no `src/` dir) BUT contains multiple project subdirectories — you are at the **workspace root**, not inside a project.

Use **AskUserQuestion**:
- Question: "You're at the workspace root. Which project(s) should I audit for copy?"
- `multiSelect: true`
- Options:
  - **All projects** — "Run copy audit across every applicable project" (Recommended)
  - One option per content project from `/home/claude/shipflow_data/PROJECTS.md`: label = project name, description = stack

Then proceed to **GLOBAL MODE** with the selected projects.

### Phase 1: Voice & Tone Inventory

Read the homepage, about page, and 3-5 key pages. Document:

1. **Brand voice profile**: Is the voice consistent? Describe it.
2. **Address style**: tu/vous (FR) or formal/informal (EN) — consistent everywhere?
3. **Terminology**: List key terms. Flag synonyms used inconsistently (e.g., "dashboard" vs "panel" vs "interface").
4. **Tone range**: Where does tone shift? Intentional or accidental?

### Phase 2: Messaging Hierarchy

Map the entire site's messaging:

1. **Homepage**: What's the primary message? Strongest possible version?
2. **Feature/product pages**: Reinforce or contradict the homepage?
3. **Blog/content**: Support core positioning?
4. **Pricing**: Value framing consistent with feature pages?
5. **About/team**: Build credibility for claims made elsewhere?

Flag messaging contradictions or gaps.

### Phase 3: Page-by-Page Copy Scan

For each page, check:
- [ ] Headline is benefit-driven
- [ ] Body copy is scannable
- [ ] CTAs use action verbs + benefit
- [ ] No filler words or corporate jargon
- [ ] No spelling/grammar errors
- [ ] No placeholder text or broken interpolation
- [ ] Microcopy is helpful

### Phase 4: Conversion Copy Check

- [ ] Landing pages have a clear single message
- [ ] Pricing page frames value before cost
- [ ] Signup/onboarding copy reduces anxiety
- [ ] Error messages are human and actionable
- [ ] Success messages reinforce value
- [ ] 404 page is helpful

### Phase 5: Fix

Rewrite and fix all issues directly in code. Prioritize:
1. **Homepage and pricing** (highest traffic/impact)
2. **CTAs across the site** (direct conversion impact)
3. **Inconsistent terminology** (fix at source: i18n files or shared constants)
4. **Grammar/spelling errors** (zero tolerance)
5. **Microcopy** (error messages, empty states, confirmations)

### Phase 6: Report

```
COPY AUDIT: [project name]
═══════════════════════════════════════

BUSINESS METADATA VERSIONS
  BUSINESS.md    artifact_version=[x|missing] status=[x|missing] updated=[date|missing] confidence=[x|missing] next_review=[date|missing]
  BRANDING.md    artifact_version=[x|missing] status=[x|missing] updated=[date|missing] confidence=[x|missing] next_review=[date|missing]
  GUIDELINES.md  artifact_version=[x|missing] status=[x|missing] updated=[date|missing] confidence=[x|missing] next_review=[date|missing]
  Proof gaps: [missing/stale/unversioned docs that affected scoring, or none]

VOICE & TONE
  Brand voice:  [description]
  Consistency:  [A/B/C/D]
  Terminology:  X inconsistencies found

MESSAGING HIERARCHY
  Core message clarity:    [A/B/C/D]
  Cross-page coherence:    [A/B/C/D]

PAGE SCORES
  /                  [A/B/C/D] — "[current headline]"
  /pricing           [A/B/C/D] — "[current headline]"
  ...

CONVERSION COPY        [A/B/C/D]
MICROCOPY              [A/B/C/D]
GRAMMAR & POLISH       [A/B/C/D]
═══════════════════════════════════════
OVERALL                [A/B/C/D]

Rewrites applied: X across Y files
Terminology standardized: Z terms
Needs decision: W items
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

1. **Global `/home/claude/shipflow_data/AUDIT_LOG.md`**: append a row filling only the Copy column, `—` for others.
2. **Project-local `./AUDIT_LOG.md`**: same without the Project column.

Create either file if missing.

### Update TASKS.md

1. **Local TASKS.md** (project root): add/replace an `### Audit: Copy` subsection with critical (🔴), high (🟠), and medium (🟡) issues as task rows.
2. **Master `/home/claude/shipflow_data/TASKS.md`**: find the project's section, add/replace an `### Audit: Copy` subsection with the same tasks.

---

## Framework Reference (2026 validated ranking)

Choose the framework that best fits the page type before rewriting:

1. **StoryBrand** (customer = hero, product = guide) — best for homepage / hero narrative. Rewrites typically cut bounce ~30%.
2. **PAS** (Problem-Agitate-Solve) — best for ads, landing pages, pain-driven funnels.
3. **JTBD headline** — best for B2B/SaaS hero + feature pages.
4. **4Cs** (Clear, Concise, Compelling, Credible) — best for microcopy and forms.
5. **AIDA** — fine for short ads/email subject lines; considered generic in 2025 for long-form.
6. **Kennedy / direct-response** (problem → agitation → solution → offer → proof → guarantee → urgency → CTA) — dominant for long-form sales pages and info products; Tugan.ai codifies the edu-tainment variant.

---

## Important (all modes)

- Detect content language automatically. Review in that language.
- For French sites: check tutoiement/vouvoiement consistency, French typographic rules (espaces insécables before : ; ! ?), avoid anglicisms when French alternatives exist.
- Preserve the author's voice — elevate, don't replace.
- Never use clichés ("leverage", "empower", "seamless", "révolutionner", "unique").
- All rewrites must fit UI constraints (button width, card height, etc.).
- Never change copy that's clearly a direct quote or testimonial.
- In project mode, build a mini style guide from findings. Standardize terminology at the source.
- **Accents français obligatoires.** Lors de toute création ou modification de contenu en français, vérifier systématiquement que TOUS les accents sont présents et corrects (é, è, ê, à, â, ù, û, ô, î, ï, ç, œ, æ). Les accents manquants sont une faute d'orthographe. Relire chaque texte produit pour s'assurer qu'aucun accent n'a été oublié — c'est une erreur très fréquente à corriger impérativement.
