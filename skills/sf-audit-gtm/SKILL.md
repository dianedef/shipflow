---
name: sf-audit-gtm
description: "Args: file-path or \"global\"; omit for full project. Professional go-to-market review — single page (with argument) or full project audit (no argument)"
disable-model-invocation: true
argument-hint: '[file-path | "global"] (omit for full project)'
---

## Canonical Paths

Before resolving any ShipFlow-owned file, load `$SHIPFLOW_ROOT/skills/references/canonical-paths.md` (`$SHIPFLOW_ROOT` defaults to `/home/claude/shipflow`). ShipFlow tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPFLOW_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Chantier Tracking

Trace category: `conditionnel`.
Process role: `source-de-chantier`.

Before producing the final report, load `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md` when this run is attached to a spec-first chantier. If exactly one active `specs/*.md` chantier is identified, append the current run to `Skill Run History`, update `Current Chantier Flow` when the run changes the chantier state, and include a final `Chantier` block. If no unique chantier is identified, do not write to any spec; report `Chantier: non applicable` or `Chantier: non trace` with the reason.

## Chantier Potential Intake

Because this skill has process role `source-de-chantier`, evaluate the standard threshold from `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md` before the final report. If the findings reveal non-trivial future work and no unique chantier owns it, do not write to an existing spec; add a `Chantier potentiel` block with `oui`, `non`, or `incertain`, a proposed title, reason, severity, scope, evidence, recommended `/sf-spec ...` command, and next step. If the work is only a direct local fix or already belongs to the current chantier, state `Chantier potentiel: non` with the concrete reason.


## Context

- Current directory: !`pwd`
- Project CLAUDE.md: !`head -100 CLAUDE.md 2>/dev/null || echo "no CLAUDE.md"`
- Business context: !`head -60 BUSINESS.md 2>/dev/null || echo "no BUSINESS.md — run /sf-init to generate"`
- Brand voice: !`head -60 BRANDING.md 2>/dev/null || echo "no BRANDING.md — run /sf-init to generate"`
- Business metadata: !`for f in BUSINESS.md BRANDING.md GUIDELINES.md; do if [ -f "$f" ]; then printf '%s: ' "$f"; sed -n '1,40p' "$f" | grep -E '^(metadata_schema_version|artifact_version|status|updated|confidence|next_review):' | tr '\n' ' '; printf '\n'; else echo "$f: missing"; fi; done`
- All pages: !`find src/pages src/app -name "*.astro" -o -name "*.tsx" -o -name "*.vue" 2>/dev/null | grep -v node_modules | sort`
- Analytics: !`grep -ri "analytics\|gtag\|plausible\|umami\|posthog\|vercel/analytics" src/ 2>/dev/null | head -10 || echo "no analytics found"`
- Auth/payment: !`grep -ri "clerk\|stripe\|lemonsqueezy\|paddle\|auth" package.json 2>/dev/null | head -5 || echo "none"`
- Environment hints: !`grep -ri "STRIPE\|CLERK\|PAYMENT\|PRICE" .env.example .env.local 2>/dev/null | head -10 || echo "none"`

## Pre-check : contexte business/marque

Avant de commencer, vérifier le contexte chargé ci-dessus. Si BUSINESS.md ou BRANDING.md est absent :

**Afficher un avertissement en tête de rapport :**
```
⚠ Contexte manquant :
- [BUSINESS.md manquant] L'audit GTM ne peut pas évaluer l'alignement produit-marché sans connaître l'audience cible et le business model.
- [BRANDING.md manquant] L'audit ne peut pas vérifier la cohérence de la promesse de marque.

→ Lancer /sf-init pour générer ces fichiers, ou /sf-docs update pour les mettre à jour.
```

Si les fichiers existent mais semblent incomplets, signaler. Continuer l'audit dans tous les cas.

---

## Metadata versioning doctrine

`BUSINESS.md`, `BRANDING.md`, and `GUIDELINES.md` are ShipFlow decision contracts when present. Before scoring:
- Read their frontmatter or first metadata block and report `artifact_version`, `status`, `updated`, `confidence`, and `next_review` when available.
- If a contract is missing `artifact_version`, `status`, or `updated`, add a proof gap: `business doc metadata incomplete`.
- If `status` is `draft`, `stale`, `outdated`, `deprecated`, or `confidence` is `low`, cap confidence and mention that GTM scoring depends on an unreviewed business contract.
- If `next_review` is before today's absolute date, treat the document as stale unless the audit finds an explicit newer replacement.
- If public pricing, positioning, ICP, funnel, onboarding, or security/compliance promises rely on stale or unversioned business docs, do not give `A` for the affected category.
- Include a `Business metadata versions` section in every report, even when the section says `missing`.

Use ShipFlow versioning semantics: patch = editorial clarification with no decision change, minor = changed decision guidance inside the same strategy, major = changed ICP, positioning, pricing model, promise, trust posture, market, or GTM strategy.

---

## Doctrine business

Évaluer la promesse business comme un contrat, pas comme une préférence marketing :
- la user story cible est claire : persona, déclencheur, résultat attendu, valeur business
- les promesses publiques sont crédibles, prouvées, et alignées avec ce que le produit livre réellement
- le parcours client est cohérent de la première page jusqu'à l'onboarding, le paiement, le support et la rétention
- les claims sensibles (sécurité, gain financier, conformité, disponibilité, automatisation, IA, résultats chiffrés) ont une preuve vérifiable ou sont signalés comme risques
- les changements produit récents sont reflétés dans les pages, docs, pricing, FAQ, onboarding, emails, mentions légales et support quand ils affectent la promesse

Si une page vend une capacité que le produit, la documentation ou le flow ne confirme pas, noter un écart de cohérence produit/documentation. Ne pas attribuer un score A à une promesse non prouvée.

---

## Mode detection

- **`$ARGUMENTS` is "global"** → GLOBAL MODE: audit ALL commercial projects in the workspace.
- **`$ARGUMENTS` is a file path** → PAGE MODE: GTM review of that single page.
- **`$ARGUMENTS` is empty** → PROJECT MODE: full go-to-market audit. Think like a CMO reviewing before launch.

---

## GLOBAL MODE

Audit ALL commercial projects in the workspace for go-to-market readiness.

1. Read `/home/claude/shipflow_data/PROJECTS.md` — check the **Domain Applicability** table. Identify projects with ✓ in the GTM column.

2. Use **AskUserQuestion** to let the user choose:
   - Question: "Which projects should I audit for go-to-market?"
   - `multiSelect: true`
   - One option per applicable project: label = project name, description = stack from PROJECTS.md
   - All applicable projects pre-listed as options

3. Use the **Task tool** to launch one agent per **selected** project — ALL IN A SINGLE MESSAGE (parallel). Each agent: `subagent_type: "general-purpose"`.

   Agent prompt must include:
   - `cd [path]` then read `CLAUDE.md` for project context
   - The absolute date, exact project path, and the GTM context already surfaced by this skill (`BUSINESS.md`, `BRANDING.md`, analytics, auth/payment hints, env hints)
   - The complete **PROJECT MODE** section from this skill (all 8 phases: Positioning Map → Conversion Funnel Map → Page-by-Page GTM → Trust Architecture → Analytics & Measurement → Launch Readiness → Fix → Report)
   - The **Tracking** section from this skill
   - Rule: **read-only analysis** — no code fixes, only update AUDIT_LOG.md and TASKS.md
   - Rule: before scoring, identify funnel links, measurement dependencies, and downstream conversion consequences
   - Rule: call out user-story drift, unproven claims, documentation mismatch, and risky business/security promises explicitly
   - Rule: read/report `BUSINESS.md`, `BRANDING.md`, and `GUIDELINES.md` metadata versions; flag missing, stale, low-confidence, or unversioned contracts as proof gaps before scoring
   - Rule: do not ask follow-up questions; if context is missing, state assumptions / confidence limits and continue
   - Required sub-report sections: `Scope understood`, `User story / promise`, `Business metadata versions`, `Context read`, `Linked systems & consequences`, `Documentation coherence`, `Risky assumptions / proof gaps`, `Findings`, `Confidence / missing context`

4. After all agents return, compile a **cross-project GTM report**:

   ```
   GLOBAL GTM AUDIT — [date]
   ═══════════════════════════════════════
   PROJECT SCORES
     [project]    [A/B/C/D]  —  summary
     ...
   CROSS-PROJECT PATTERNS
     [Systemic GTM issues in 2+ projects]
   ALL ISSUES BY SEVERITY
     🔴 [project] file:line — description
     🟠 [project] file:line — description
     🟡 [project] file:line — description
   Total: X critical, Y high, Z medium across N projects
   ═══════════════════════════════════════
   ```

5. Update `/home/claude/shipflow_data/AUDIT_LOG.md` (one row per project, GTM column) and `/home/claude/shipflow_data/TASKS.md` (each project's `### Audit: GTM` subsection).

6. Ask: **"Which projects should I fix?"** — list projects with scores. Fix only approved projects, one at a time.

---

## PAGE MODE

### Step 1: Gather the page

1. Read the target file (`$ARGUMENTS`).
2. Read the site navigation to understand where this page sits in the funnel.
3. Read the homepage/landing page to understand overall positioning.
4. Read pricing page if it exists.

### Step 2: Audit against this checklist

Score each category **A/B/C/D**. Be strict — growth/marketing professional standard.

#### 1. Positioning & Differentiation
- [ ] Immediately clear what this product/service does (5-second test)
- [ ] Unique value proposition is explicit, not implied
- [ ] Competitive differentiation is visible
- [ ] Target audience is obvious from language, imagery, examples
- [ ] Positioning is specific, not vague
- [ ] Promise matches product/docs reality, not an aspirational roadmap claim

#### 2. Conversion Architecture
- [ ] Clear single goal (one primary conversion action)
- [ ] Conversion path has minimal friction
- [ ] CTA visible without scrolling
- [ ] CTA repeated at logical intervals
- [ ] Exit intent or secondary capture exists
- [ ] Pricing is transparent

#### 3. Trust & Credibility
- [ ] Social proof is present and specific
- [ ] Testimonials include name, role, photo, or company
- [ ] Trust badges where appropriate
- [ ] Case studies or results with real data
- [ ] Professional design
- [ ] Contact information visible

#### 4. Objection Handling
- [ ] FAQ addresses top 3-5 objections
- [ ] Pricing objections handled
- [ ] "Who is this for / not for" clarity
- [ ] Setup complexity addressed
- [ ] Data/privacy concerns addressed if relevant
- [ ] Security, compliance, AI, data, or payment claims are backed by visible proof or clear docs

#### 5. Funnel Alignment
- [ ] Page matches traffic source intent
- [ ] Internal links guide deeper into funnel
- [ ] Blog/content links back to product pages
- [ ] Navigation doesn't distract from conversion goal
- [ ] Post-conversion flow exists

#### 6. Analytics & Tracking
- [ ] Analytics tool installed and loading
- [ ] Key conversion events tracked
- [ ] UTM parameters preserved
- [ ] A/B testing infrastructure exists or easy to add
- [ ] Core Web Vitals monitored

#### 7. Market Readiness
- [ ] Legal pages exist (privacy, terms, mentions légales for FR)
- [ ] Cookie consent if EU-targeted
- [ ] Accessibility meets minimum legal requirements
- [ ] Contact/support channel functional
- [ ] Mobile experience equal to desktop
- [ ] Public docs, FAQ, pricing, onboarding and support copy align with the feature promise

### Step 3: Fix

For each issue rated B or worse:
1. Explain the business impact.
2. Fix code-level issues directly.
3. For strategic decisions, provide specific recommendations.

### Step 4: Report

```
GTM REVIEW: [page name] — funnel stage: [awareness/consideration/conversion/retention]
─────────────────────────────────────
Business metadata:
  BUSINESS.md    artifact_version=[x|missing] status=[x|missing] updated=[date|missing] confidence=[x|missing]
  BRANDING.md    artifact_version=[x|missing] status=[x|missing] updated=[date|missing] confidence=[x|missing]
  GUIDELINES.md  artifact_version=[x|missing] status=[x|missing] updated=[date|missing] confidence=[x|missing]
Positioning        [A/B/C/D] — one-line summary
Conversion         [A/B/C/D] — one-line summary
Trust & Proof      [A/B/C/D] — one-line summary
Objection Handling [A/B/C/D] — one-line summary
Funnel Alignment   [A/B/C/D] — one-line summary
Analytics          [A/B/C/D] — one-line summary
Market Readiness   [A/B/C/D] — one-line summary
Docs Coherence     [A/B/C/D] — product/docs/pricing/support aligned
─────────────────────────────────────
OVERALL            [A/B/C/D]

Fixed: X issues | Strategic recommendations: Y | Proof gaps: Z
```

---

## PROJECT MODE

### Workspace root detection

If the current directory has no project markers (no `package.json`, no `src/` dir) BUT contains multiple project subdirectories — you are at the **workspace root**, not inside a project.

Use **AskUserQuestion**:
- Question: "You're at the workspace root. Which project(s) should I audit for go-to-market?"
- `multiSelect: true`
- Options:
  - **All projects** — "Run GTM audit across every commercial project" (Recommended)
  - One option per commercial project from `/home/claude/shipflow_data/PROJECTS.md`: label = project name, description = stack

Then proceed to **GLOBAL MODE** with the selected projects.

### Phase 1: Positioning Map

Read homepage, about, pricing, and key landing pages. Document:

1. **Core value proposition**: Explicit or implied?
2. **Target audience**: Specific enough?
3. **Competitive angle**: Communicated?
4. **Pricing model**: Aligned with value prop?
5. **Brand promise**: Kept throughout?

Deliver a **one-sentence positioning statement**: "[Product] helps [audience] [achieve outcome] by [unique mechanism], unlike [alternatives]."

### Phase 2: Conversion Funnel Map

Trace every conversion path:
```
Traffic Source → Landing → Consideration → Conversion → Post-Conversion
```

For each path:
- [ ] Entry point matches traffic intent
- [ ] Each step has a clear next action
- [ ] No dead ends
- [ ] Friction minimized
- [ ] Fallback capture for non-converters

### Phase 3: Page-by-Page GTM Audit

Classify each page by funnel role and audit:

**Awareness** (blog, content, landing):
- [ ] Strong hook, links to conversion pages, lead capture, shareable

**Consideration** (features, how-it-works, case studies):
- [ ] Addresses objections, relevant social proof, clear path to pricing

**Conversion** (pricing, signup, checkout):
- [ ] Price anchoring, risk reversal, minimal friction, trust signals near action

**Retention** (dashboard, settings, onboarding):
- [ ] Guides to first value moment, contextual upgrade prompts, accessible help

### Phase 4: Trust Architecture

- [ ] Testimonials: specific, credible
- [ ] Social proof: user counts, logos, media mentions
- [ ] Security signals: SSL, privacy policy
- [ ] Authority signals: team page, credentials
- [ ] Legal compliance: mentions légales (FR), privacy, CGV, cookie consent

### Phase 5: Analytics & Measurement

- [ ] Analytics on all pages
- [ ] Conversion events tracked (CTA clicks, form submissions, signups, pricing views)
- [ ] UTM parameters preserved
- [ ] Goal/conversion tracking configured

### Phase 6: Launch Readiness

- [ ] All pages load without errors
- [ ] Mobile experience complete
- [ ] Forms submit correctly
- [ ] Payment flow works (if applicable)
- [ ] Docs, pricing, FAQ, onboarding, transactional emails and support surfaces match current feature behavior
- [ ] No launch-critical promise remains unproven or contradicted by product/docs
- [ ] Email templates branded
- [ ] 404 page helpful
- [ ] Social previews look good
- [ ] Legal pages complete
- [ ] Contact channel functional

### Phase 7: Fix

Fix all issues in code. Priority:
1. **Broken conversion paths**
2. **Missing trust signals**
3. **Missing analytics tracking**
4. **Legal compliance**
5. **Funnel leaks**

### Phase 8: Report

```
GTM AUDIT: [project name]
═══════════════════════════════════════

BUSINESS METADATA VERSIONS
  BUSINESS.md    artifact_version=[x|missing] status=[x|missing] updated=[date|missing] confidence=[x|missing] next_review=[date|missing]
  BRANDING.md    artifact_version=[x|missing] status=[x|missing] updated=[date|missing] confidence=[x|missing] next_review=[date|missing]
  GUIDELINES.md  artifact_version=[x|missing] status=[x|missing] updated=[date|missing] confidence=[x|missing] next_review=[date|missing]
  Proof gaps: [missing/stale/unversioned docs that affected scoring, or none]

POSITIONING
  Value proposition:     [clear / vague / missing]
  Target audience:       [specific / generic]
  Differentiation:       [strong / weak / absent]
  One-liner: "[positioning statement]"

CONVERSION FUNNEL
  Primary path:          [description] — [A/B/C/D]
  Secondary paths:       [count] identified
  Dead ends:             [count]
  Friction:              [low / medium / high]

PAGE SCORES (by funnel role)
  Awareness
    /blog              [A/B/C/D]
  Consideration
    /features          [A/B/C/D]
  Conversion
    /pricing           [A/B/C/D]

TRUST ARCHITECTURE     [A/B/C/D]
ANALYTICS & TRACKING   [A/B/C/D]
LAUNCH READINESS       [A/B/C/D]
═══════════════════════════════════════
OVERALL                [A/B/C/D]

Fixed: X issues across Y files
Strategic recommendations: Z (detailed below)
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

1. **Global `/home/claude/shipflow_data/AUDIT_LOG.md`**: append a row filling only the GTM column, `—` for others.
2. **Project-local `./AUDIT_LOG.md`**: same without the Project column.

Create either file if missing.

### Update TASKS.md

1. **Local TASKS.md** (project root): add/replace an `### Audit: GTM` subsection with critical (🔴), high (🟠), and medium (🟡) issues as task rows.
2. **Master `/home/claude/shipflow_data/TASKS.md`**: find the project's section, add/replace an `### Audit: GTM` subsection with the same tasks.

---

## Important (all modes)

- Think like a growth lead, not a developer. Every recommendation ties to revenue or user acquisition.
- For French market: RGPD mandatory, mentions légales legally required, CGV for commercial transactions.
- Be specific with business impact estimates (use industry conversion benchmarks).
- Don't recommend building features that don't exist — optimize what's there. List "should build" items separately.
- If pre-launch, focus on launch readiness. If post-launch, focus on conversion optimization.
