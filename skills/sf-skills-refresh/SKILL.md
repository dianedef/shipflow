---
name: sf-skills-refresh
description: "Refresh skills against current practice and conservative updates."
disable-model-invocation: true
argument-hint: '[skill-name] (omit to pick multiple)'
---

## Canonical Paths

Before resolving any ShipFlow-owned file, load `$SHIPFLOW_ROOT/skills/references/canonical-paths.md` (`$SHIPFLOW_ROOT` defaults to `$HOME/shipflow`). ShipFlow tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPFLOW_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Chantier Tracking

Trace category: `conditionnel`.
Process role: `support-de-chantier`.

Before producing the final report, load `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md` when this run is attached to a spec-first chantier. If exactly one active `specs/*.md` chantier is identified, append the current run to `Skill Run History`, update `Current Chantier Flow` when the run changes the chantier state, and include a final `Chantier` block. If no unique chantier is identified, do not write to any spec; report `Chantier: non applicable` or `Chantier: non trace` with the reason.


## Context

- Skills directory: !`ls ${SHIPFLOW_ROOT:-$HOME/shipflow}/skills/ | head -60`
- Refresh log: !`head -30 ${SHIPFLOW_ROOT:-$HOME/shipflow}/skills/REFRESH_LOG.md 2>/dev/null || echo "no log yet — will be created"`
- Today: !`date -I`

## Your task

Refresh one or more skills to match 2025-2026 state of the art. Workflow: spawn parallel research agents → apply findings as targeted edits → log the refresh.

**Never rewrite a skill from scratch.** Additive only — new checks, new phases, updated thresholds. Preserve the author's voice and existing structure.

---

## MODE DETECTION

- **`$ARGUMENTS` is a skill name** (e.g., `sf-audit-seo`): refresh that single skill.
- **`$ARGUMENTS` is empty**: use **AskUserQuestion** to let the user pick which skills to refresh.
  - Question: "Which skills should I refresh?"
  - `multiSelect: true`
  - List all `skills/sf-*` directories with a `SKILL.md` as options (label = skill name, description = first-line `description:` from the frontmatter)
  - Pre-select nothing — force explicit choice (batch refresh burns tokens)

---

## PHASE 1: UNDERSTAND EACH TARGET

For each selected skill, read its `SKILL.md` and identify:
- **Domain**: SEO, design, copy, content, perf, security, etc.
- **Current phases**: what's already covered (avoid duplication)
- **Obvious 2025+ patterns**: signals the skill was recently refreshed — adjust research accordingly
- **Likely gaps**: what could be new in the domain since ~6 months ago
- **Language doctrine gaps**: compare touched sections against `GUIDELINES.md` and `shipflow-spec-driven-workflow.md` when available. Internal skill contracts should be English; user-facing prompts and reports should use the active user/project language; French user-facing text needs proper accents; casual language mixing inside one artifact should be flagged unless it is a quoted source, quoted user prompt, legal text, external material, or stable machine-readable anchor.

---

## PHASE 2: RESEARCH (parallel agents)

Spawn one `Agent` per skill using `subagent_type: "general-purpose"`, `run_in_background: true`. **Send all agent calls in a single message** to run in parallel.

Each agent prompt MUST include:

1. `"Read ${SHIPFLOW_ROOT:-$HOME/shipflow}/skills/<skill-name>/SKILL.md first. Don't duplicate what's covered."`
2. Today's absolute date so the agent knows what "recent" means.
3. A domain-specific research brief — 8-12 concrete topics to investigate via WebSearch, specific to the skill's purpose.
4. Required output format:
   - **NEW CHECKS TO ADD** (grouped by existing phase)
   - **EXISTING CHECKS TO UPDATE** (with before/after)
   - **NEW PHASE PROPOSALS** (only if a whole area is missing)
   - **CROSS-SKILL CONSEQUENCES** (if a finding implies edits in another skill, workflow doc, or help file)
   - **Sources** (URLs consulted)
5. `"Be specific and actionable. Each check must be droppable directly into the skill as a [ ] line with a why/rationale. Under 1200 words."`
6. `"Work in one pass: do not ask follow-up questions. If evidence is mixed, state assumptions and confidence."`

### Domain-specific brief seeds

Use these as starting points, adapt to the specific skill:

- **SEO** (sf-audit-seo, sf-enrich): AEO/GEO evolution, llms.txt adoption, Core Web Vitals thresholds (INP, LCP, CLS), new schema.org types, E-E-A-T updates, robots.txt for AI crawlers (GPTBot, ClaudeBot, PerplexityBot), hreflang updates, structured data rich-result eligibility changes
- **Design / UI** (sf-audit-design): modern CSS Baseline additions, WCAG 2.2 / 3.0 draft updates, view transitions, container queries, `:has()`, `light-dark()`, OKLCH, anchor positioning / popover API, INP budget, AI-generated code smells (v0, bolt, lovable)
- **Copy / content** (sf-audit-copy, sf-audit-copywriting): AI-slop lexicon updates (EN + FR), conversion framework validation (StoryBrand, PAS, JTBD), LLM citation patterns, plain-language / WCAG 3 readability, trust signals in AI era
- **Enrichment / research** (sf-enrich, sf-research, sf-veille): new schema types, interactive content data, primary source preference, content decay detection, Mermaid/diagram-as-code adoption
- **Code / perf** (sf-audit-code, sf-perf, sf-check): new JS/TS features, framework versions and deprecations, bundler / build tool changes, new performance APIs
- **Security** (sf-audit-code security, sf-verify): OWASP Top 10 updates, CVE feed patterns, new attack vectors, dependency confusion / supply chain
- **GTM / marketing** (sf-audit-gtm, sf-market-study): analytics API changes, privacy-first tracking, new platform features, cookieless tracking
- **i18n / translation** (sf-audit-translate): ICU MessageFormat updates, locale data changes, RTL handling

If the skill doesn't fit a template, read its description and infer the brief from the actual domain.

---

## PHASE 3: APPLY FINDINGS

For each returned report:

1. Re-read the target `SKILL.md` (may have drifted since Phase 1).
2. For each **NEW CHECK TO ADD**: find the right phase/category, insert as `- [ ]` line(s) in the matching section.
3. For each **EXISTING CHECK TO UPDATE**: use `Edit` with exact old/new strings.
4. For each **NEW PHASE PROPOSAL**: evaluate. Only add if genuinely missing (not a rename of existing content). Insert between existing phases, matching numbering convention.
5. Update report template / score rubric at the bottom to include new categories.
6. If a refresh edits `description`, `argument-hint`, `agents/openai.yaml`, discovery wording, or materially changes `SKILL.md` length, read `${SHIPFLOW_ROOT:-$HOME/shipflow}/skills/references/skill-context-budget.md` and run `${SHIPFLOW_ROOT:-$HOME/shipflow}/tools/skill_budget_audit.py --skills-root "${SHIPFLOW_ROOT:-$HOME/shipflow}/skills"` before reporting.

**Rules:**
- Never delete a check that's still valid today.
- Never reword a check purely for style — only substantive updates.
- Preserve legacy structure and author tone, but apply the ShipFlow language doctrine to touched sections: write new internal contracts in English, keep user-facing prompts/examples in the active user/project language, keep stable machine-readable labels in English, and preserve quoted/source/legal/external text in its original language.
- Preserve the author's tone — additive edits only.
- If a new check replaces an outdated one (e.g., FID → INP), update in place. Don't leave both.
- When refreshing French user-facing output, fix missing accents in touched text. Treat accentless French as an error unless the text is a technical identifier, command, slug, or ASCII-only format.
- Flag inappropriate casual language mixing as a refresh finding; do not launch a broad legacy rewrite unless the user explicitly requests it.

---

## PHASE 4: LOG THE REFRESH

Append an entry to `${SHIPFLOW_ROOT:-$HOME/shipflow}/skills/REFRESH_LOG.md` (create if missing). Most recent first. Format:

```markdown
## YYYY-MM-DD — <skill-name>

**Added:**
- [phase name] one-line check title
- ...

**Updated:**
- [phase name] what changed (one line)
- ...

**New phases:**
- Phase X.Y — Title (if any)

**Sources:** N URLs consulted
```

One `##` block per skill refreshed. Don't batch multiple skills into one block.

---

## PHASE 5: REPORT

```
SKILLS REFRESHED — [date]
═══════════════════════════════════════
  sf-audit-seo       +X checks, +Y updates, Z new phases
  sf-audit-design    +X checks, +Y updates
  ...
═══════════════════════════════════════
Total: X new checks, Y updates, Z new phases across N skills
Log: skills/REFRESH_LOG.md
```

If any research agent returned findings that need human judgment (ambiguous, controversial, project-specific), list them under **NEEDS DECISION** — don't apply unilaterally.

---

## Important

- **Cadence**: designed for ~monthly runs. More frequent wastes research effort; less frequent means drift.
- **Parallel research is the whole point.** Never do searches yourself sequentially — delegate to agents.
- **Additive mindset**: a skill that accumulates every check ever written becomes unwieldy. When a check is strictly obsoleted by a newer one, update in place instead of stacking both.
- **Skill budget compliance stays scoped here**: enforce Codex/Claude Code skill budget rules during skill refreshes, not through broad reminders in unrelated agent guidelines.
- **Never touch `name:` in frontmatter.** It's the invocation key.
- **ShipFlow language doctrine**: internal contracts use English; user-facing interaction uses the active user/project language; stable machine-readable labels stay English; quoted user input, source evidence, legal text, and external material keep their original language.
- **Don't refresh `sf-skills-refresh` itself** from this skill — that's a manual edit job.
- **French accents are required** in French user-facing output: é, è, ê, à, â, ù, û, ô, î, ï, ç, œ, æ. Missing accents are spelling errors unless a technical identifier, command, slug, or ASCII-only format requires them.
