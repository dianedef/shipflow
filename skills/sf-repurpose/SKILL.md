---
name: sf-repurpose
description: "Source-faithful repurposing analysis for docs, marketing, FAQs, articles, and site updates."
argument-hint: [optional focus such as "doc", "marketing", "full", "release notes", "faq", "newsletter", "article", "site", "handoff", or a target surface]
---

## Canonical Paths

Before resolving any ShipFlow-owned file, load `$SHIPFLOW_ROOT/skills/references/canonical-paths.md` (`$SHIPFLOW_ROOT` defaults to `$HOME/shipflow`). ShipFlow tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPFLOW_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Chantier Tracking

Trace category: `conditionnel`.
Process role: `support-de-chantier`.

Before producing the final report, load `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md` when this run is attached to a spec-first chantier. If exactly one active `specs/*.md` chantier is identified, append the current run to `Skill Run History`, update `Current Chantier Flow` when the run changes the chantier state, and include a final `Chantier` block. If no unique chantier is identified, do not write to any spec; report `Chantier: non applicable` or `Chantier: non trace` with the reason.

## Read-Only Delegation

Before coordinating subagents, load `$SHIPFLOW_ROOT/skills/references/master-delegation-semantics.md`.

`sf-repurpose` is an owner skill, not a master lifecycle skill, but its existing-content placement analysis is read-heavy and can safely use read-only parallel fan-out when subagents are available.

Use parallel read-only subagents for existing-content scans when all of these are true:

- the run is in analysis or pack mode
- the mission is reading, comparing, and reporting only
- each subagent owns a non-overlapping surface set such as `Internal Docs`, `Public Content`, `Skill Pages`, `FAQ`, or `Docs Overview`
- every subagent is explicitly forbidden to edit, stage, commit, push, rewrite trackers, or mutate runtime content
- the main `sf-repurpose` context integrates the findings into `Existing Content Opportunities`, `Evidence Ledger`, and the final user report

Before any content mutation, docs update, validation, closure, or ship work, stop the read-only fan-out and produce an owner-skill handoff. `sf-repurpose` does not edit content directly.

If subagents are unavailable, continue with a sequential read scan and report that parallel read-only fan-out was unavailable.


## Context

- Current directory: !`pwd`
- Current date: !`date '+%Y-%m-%d'`
- Project name: !`basename $(pwd)`
- Git branch: !`git branch --show-current 2>/dev/null || echo "unknown"`
- Git status: !`git status --short 2>/dev/null || echo "Not a git repo"`
- Git diff stat: !`git diff --stat 2>/dev/null || echo "no diff"`
- Recent commits: !`git log --oneline -8 2>/dev/null || echo "no commits"`
- Changed files: !`git diff --name-only HEAD 2>/dev/null | head -40 || echo "no changed files"`
- CLAUDE.md: !`head -60 CLAUDE.md 2>/dev/null || echo "no CLAUDE.md"`
- BUSINESS.md: !`head -60 BUSINESS.md 2>/dev/null || echo "no BUSINESS.md"`
- BRANDING.md: !`head -60 BRANDING.md 2>/dev/null || echo "no BRANDING.md"`
- PRODUCT.md: !`head -60 PRODUCT.md 2>/dev/null || echo "no PRODUCT.md"`
- GTM.md: !`head -60 GTM.md 2>/dev/null || echo "no GTM.md"`
- GUIDELINES.md: !`head -60 GUIDELINES.md 2>/dev/null || echo "no GUIDELINES.md"`
- CONTENT_MAP.md: !`head -120 CONTENT_MAP.md 2>/dev/null || echo "no CONTENT_MAP.md"`
- Existing docs/pages: !`find docs src content app -maxdepth 2 -type f \( -name "*.md" -o -name "*.mdx" -o -name "*.tsx" -o -name "*.astro" \) 2>/dev/null | head -40 || echo "no docs/pages found"`

## Your task

Turn either:
- the current workstream
- or user-supplied source content such as a pasted paragraph, excerpt, note, or article

into a reusable content pack anchored in the source material.

This skill is for repurposing, not inventing. Start from the source the user supplied in the current turn. If no source text was supplied, fall back to the current conversation. Use code, diffs, touched files, and project docs only when the source is a build conversation and only to confirm or sharpen what the conversation already established.

If `CONTENT_MAP.md` exists, use it before recommending target surfaces. Treat it as the project's canonical map for blog paths, docs paths, landing pages, semantic clusters, pillar pages, FAQ/support surfaces, newsletters, and other content destinations. If it is missing, infer surfaces from the repo for this run and recommend creating it from `templates/artifacts/content_map.md`.

When the output is public content or changes public claims, load `$SHIPFLOW_ROOT/skills/references/editorial-content-corpus.md` after `CONTENT_MAP.md` when available. Use `docs/editorial/claim-register.md` for sensitive public claims, `docs/editorial/page-intent-map.md` for public route intent, `docs/editorial/editorial-update-gate.md` for an `Editorial Update Plan` or `Claim Impact Plan`, and `docs/editorial/blog-and-article-surface-policy.md` before recommending article output. If no declared blog surface exists, report `surface missing: blog` instead of inventing a path.

Primary outcome:
- extract the real product/technical signal from the work in progress
- separate documentation output from marketing output
- produce action-first article ideas and titles the operator can use immediately
- analyze existing internal docs and public content to find where source insights should be added
- keep every public claim inside the bounds of what the work actually supports
- keep every public claim inside the claim register and evidence boundaries when `docs/editorial/` exists
- convert justified recommendations into owner-skill handoffs when the user asks to apply them
- distribute important product concepts across multiple relevant site surfaces instead of assuming one page will be read

Use this skill when:
- a feature or fix was just designed or implemented
- the team wants docs and marketing to stay faithful to the product reality
- you found a strong paragraph, article excerpt, or source note and want to transform it into new content directions
- you want release-note, FAQ, positioning, or educational angles directly from the source work

Do not use this skill when:
- the goal is net-new copywriting from scratch with heavy web research
- the goal is a full doc audit
- the workstream has too little signal and would force invention
- the user wants code generation, implementation ideas, or architectural design from the source text

If the user clearly wants long-form content or external research, hand off to `sf-redact` or `sf-enrich` after producing the factual source pack.

## Execution contract

This skill is read-only for project content and docs.

- `analysis mode` / `pack mode`: produce a reusable content pack, placement opportunities, and owner-skill handoffs.
- `trace mode`: if exactly one active chantier is identified, it may write its run trace to that spec only.

Do not create or update content files directly. This remains true even when the user says or implies:

- "fais tout ça", "apply", "update the site", "create the article", "write it", "fill the site", "mets-le partout", "add this to docs", "ship the content"
- a target surface is named as an action, such as `article`, `FAQ`, `landing`, `docs`, `README`, or a file path

When the user asks to apply, write, update, publish, or ship, produce a handoff pack for the owner skill instead of editing. The handoff must include the target surface, source proof, recommended content move, claim constraints, and next command.

When the source is the current conversation and the user says to continue after agreeing on placement, do not write the justified surfaces. Route the work to the correct owner skill with enough context for that skill to write without rediscovering the source truth.

Keep generated prose concise. Do not draft full articles, full landing sections, or long FAQ answers in chat unless the user explicitly asks for a draft-only response. If a target file exists and the user wants action, route to the owner skill instead of writing into the file.

If the skill recommends a dedicated article, it must also decide one of:

- route the article/page to `sf-redact` because the user asked to apply the recommendation
- defer it explicitly because the repo has no declared surface or the user asked for strategy only
- ask one concise question if creating the surface would require a risky product/SEO decision that cannot be inferred

## Actionability Contract

The default user-facing output must be immediately usable. Avoid opening with a long audit-style report unless the user explicitly asks for `report=agent`, `handoff`, or detailed evidence.

In analysis/pack mode, lead with these sections in this order:

1. `Best Next Actions`
2. `Article Name Ideas`
3. `Titles For This Conversation`
4. `Existing Content Opportunities`
5. `Owner Skill Handoffs`
6. `Source Pack`
7. `Evidence Ledger`

`Best Next Actions` must contain 3 to 5 concrete actions. Each action should name the content asset, target surface, source proof, and next command or owner skill.

`Article Name Ideas` is a list of durable article concepts linked to the project's existing content, product doctrine, public pages, skill pages, docs, FAQ, semantic clusters, or current chantier. Each item must include:

- working name
- angle
- source proof
- target surface or `surface missing: blog`
- recommended next step

`Titles For This Conversation` is mandatory in workstream mode. It must give title candidates for repurposing the current conversation directly. Each title must include:

- title
- article promise
- why this conversation supports it
- best destination or `surface missing: blog`

Keep both article lists short and ranked. Default to 5 to 8 strong items per list. If the source is too thin, give fewer strong items and say why instead of padding.

Do not mix article names, titles, docs notes, marketing claims, and evidence into one long undifferentiated section. The operator should be able to pick an article idea or title without rereading the whole report.

If no blog or article surface is declared, still provide article names and titles when the source supports them, but mark destination as `surface missing: blog` and do not invent a path.

## Existing Content Placement Contract

Every analysis/pack run must include an `Existing Content Opportunities` section unless the user explicitly asks for titles only.

This section analyzes where the current source insight can improve content that already exists. It must cover two lanes:

- `Internal docs`: README, workflow docs, technical docs, editorial docs, specs, skill contracts, help docs, or other operator-facing documentation.
- `Public content`: landing pages, public docs, FAQ, public skill pages, pricing, guides, articles, tutorials, or other audience-facing surfaces.

Prefer read-only parallel fan-out for this scan when subagents are available and the surface sets do not overlap. The parallel work only gathers evidence and placement recommendations; it never edits files.

For each opportunity, include:

- surface or file
- placement idea
- audience learning moment: what the audience did not know, misunderstood, or would now understand better
- source proof from the conversation or supplied text
- content move: add section, add example, add FAQ, add comparison, add demonstration, add warning, update claim, or skip
- priority: `must write`, `should write`, `optional`, or `do not write`
- next step: `sf-docs`, `sf-enrich`, `sf-redact`, `sf-audit-copy`, `sf-audit-copywriting`, or `sf-audit-seo`

When the source contains a concrete explanation, decision, demonstration, before/after contrast, or misconception correction, treat it as a potential `Audience Learning Moment`. Prefer small high-leverage insertions over inventing a full article.

Do not only propose new content. Always ask: "Which existing surface becomes clearer if this insight is added there?"

When the user asks to apply, route every `must write` and `should write` placement to the correct owner skill unless blocked by a missing surface, unsafe claim, runtime schema constraint, or user review gate. When the user asks to stop before review, produce the placement analysis and handoff context, then stop before `sf-end` or ship.

## Conversation reuse doctrine

Some of the best content is created while explaining the work to the user. Do not discard clear conversational explanations just because they appeared in chat first.

If the conversation establishes a durable product proof, workflow rule, recurring customer objection, technical constraint, or positioning clarification, treat that as content debt until it is placed in the right repository surface. The default is not "summarize it in chat"; the default is to preserve it through `CONTENT_MAP.md` and the mapped public or technical surface.

When the conversation contains a sentence, analogy, diagram, list, or troubleshooting explanation that is clearer than a fresh rewrite:

- reuse it verbatim or near-verbatim in the target content when it is accurate and brand-safe
- preserve simple diagrams when they make the workflow easier to understand, but adapt them to the target surface
- turn concise conversational lists into documentation checklists, FAQ answers, or article sections
- keep the same language if the target surface uses that language; otherwise translate the idea, not the awkward phrasing
- avoid copying exploratory or speculative phrasing that was useful in discussion but not safe as product truth

Prefer the clearest wording over novelty. The goal is reusable product clarity, not proving that the same idea can be rewritten again.

For external documentation and marketing pages, avoid terminal blocks, fenced code blocks, or code-looking diagrams unless the content is truly a command/reference page and the code is necessary for the user to act. Prefer editorial layouts: cards, numbered steps, short callouts, prose diagrams, tables, or purpose-built visual components. A diagram that was useful in chat can be reused as structure without being rendered as a terminal.

## Site repetition doctrine

When a source idea is strategically important and public-facing, one page is not enough. Users do not read the whole site in order.

Use repetition deliberately:

- one canonical page or article owns the deep explanation
- the docs overview links to the canonical page
- the FAQ answers the recurring objection or confusion
- the landing page may mention the concept if it supports the public promise
- skill pages or tutorials mention it only when it changes how the workflow should be understood
- README/local docs preserve operational truth for contributors and operators
- `CONTENT_MAP.md` records the cluster and cross-surface update rule

Repeat the same concept with different jobs per surface. Do not duplicate the same paragraph everywhere.

For workflow-level ideas, one public page is also not enough. If the point changes how ShipFlow should operate, update the relevant internal `SKILL.md`, reference doc, README/context route, or verification/audit gate in addition to any editorial surface. Public proof and operational workflow must stay connected.

## Core doctrine

Treat the source material as evidence.

Never present:
- roadmap ideas as shipped capabilities
- internal implementation details as user benefits unless the benefit is explicit
- inferred performance/security/compliance claims as confirmed facts
- speculative positioning as product truth
- a third-party author's exact framing as if it were original project language without adaptation

Every important statement must be tagged mentally as one of:
- `confirmed by conversation`
- `confirmed by code`
- `inferred`
- `not safe to publish`

Use `not safe to publish` for any claim about:
- security, privacy, compliance, reliability, AI behavior, automation quality, savings, speed, scale, or business outcomes
- unless the conversation or code gives direct proof

## Source modes

Pick the source in this order:
- `supplied source mode` when the user pasted or quoted text in the request
- `supplied article mode` when the user summarized an article or shared a substantial excerpt
- `workstream mode` when no external source text is provided and the current conversation is the source

If the user provides only a URL and not the content itself:
- fetch it only if the user explicitly wants that
- then treat the fetched page as external source material, not as product truth

## Surface selection

Before choosing output forms, check `CONTENT_MAP.md` when present:
- prefer mapped surfaces over guessed paths
- use declared pillar pages and semantic clusters to place blog/article/FAQ ideas
- use declared cross-surface update rules to identify related docs, landing pages, or support content
- if the map says a surface is missing, report that gap instead of inventing a path
- if the map appears stale or contradicts the repo, mark the target as `needs verification`

Then check `docs/editorial/` when present:
- use the claim register before publishing sensitive claims
- use the page intent map before changing public Astro pages
- use the Astro content schema policy before editing runtime content
- use the blog surface policy before creating or recommending article output
- include an `Editorial Update Plan` when public content, page intent, claim safety, FAQ, pricing, README, or public docs are impacted

## Mode detection

Parse `$ARGUMENTS` as an optional focus override:
- `doc` → prioritize documentation outputs
- `marketing` → prioritize marketing outputs
- `full` or empty → produce both when justified
- `apply`, `site`, `full-site`, `tout`, `tout ça`, `write`, `update`, `publish` → produce owner-skill handoffs for justified updates across relevant mapped surfaces
- `release notes`, `faq`, `landing`, `readme`, `changelog` → shape the pack toward that surface
- `newsletter`, `thread`, `post`, `article`, `outline` → shape the pack toward those content forms
- any file/path/page name → bias recommendations toward that target surface

If no usable source can be inferred from the request or conversation, ask one concise question to recover the source material before continuing.

## Workflow

### Phase 1 — Reconstruct the source truth

When the source is a build conversation, extract:
- the problem being solved
- the user or operator pain point
- the chosen approach
- the alternatives or tradeoffs discussed
- the observable outcome
- any limits, caveats, or follow-up work

When the source is supplied text, extract:
- the core idea
- the central claim or thesis
- the audience implied by the text
- the useful framing, analogy, or insight
- the parts worth keeping, reframing, or discarding
- any statements that are too generic, derivative, risky, or ungrounded

Then:
- for build-conversation sources, inspect the most relevant changed files or mentioned files only as needed to validate behavior and claims
- for supplied-text sources, stay anchored to the text itself unless the user explicitly asks for outside validation
- inspect existing internal docs and public surfaces named by `CONTENT_MAP.md`, `docs/editorial/`, changed files, or the conversation to find placement opportunities

### Phase 2 — Decide which outputs are justified

Choose outputs based on signal strength, not habit.

Produce documentation output when the workstream contains:
- behavior changes
- setup, workflow, API, or UX changes
- constraints, edge cases, or operational guidance
- internal knowledge worth preserving

Produce documentation-style content from supplied text when the source contains:
- a reusable explanation
- a framework, method, or concept worth teaching
- material that can become FAQ, guide notes, or educational structure

Produce marketing output when the workstream contains:
- a clear user benefit
- a friction removed
- a meaningful simplification
- a differentiating design or workflow choice
- a strong build story worth sharing

Produce marketing output from supplied text when the source contains:
- a strong hook
- a contrarian or memorable angle
- a useful belief shift
- a message that can be adapted into brand-safe positioning

Produce both when both are well-supported.

If one side is weak:
- reduce it sharply
- or omit it entirely
- do not pad the output with generic filler

For site-facing content, classify each justified output as:

- `must write`: required to make the site/docs coherent after this work
- `should write`: strong SEO, onboarding, FAQ, or conversion surface
- `optional`: useful angle but not necessary now
- `do not write`: too speculative, duplicate, or unsupported

Classify existing-content placements the same way. Internal documentation and public publication surfaces must be evaluated separately because they have different jobs:

- internal docs preserve operator truth, workflow rules, implementation context, and future-agent handoff clarity
- public content teaches the audience, resolves objections, demonstrates value, and improves discoverability

For `must write` and `should write` items, produce owner-skill handoffs unless the surface is missing or unsafe. Optional items can be reported as follow-up.

When a `must write` or `should write` item is a workflow rule, include at least one operational target such as a `SKILL.md`, `skills/references/*.md`, README/context route, or verification/audit gate. A site page alone is not enough to preserve workflow behavior.

### Phase 2.5 — Plan the diffusion map

Before recommending writing, produce a compact internal diffusion map:

- canonical surface: the one page/article that owns the full explanation
- supporting surfaces: docs, FAQ, README, local docs, landing, skill page, or changelog
- repeated concept: the short message that should recur
- per-surface job: why each surface needs a different version
- surfaces intentionally skipped: with reason

If `CONTENT_MAP.md` exists, recommend a `sf-docs` handoff when a new recurring topic, article, pillar page, or cross-surface rule should be recorded.

If `docs/editorial/` exists, check the claim register, page intent map, Astro content schema policy, and blog surface policy before recommending public-content handoffs. Runtime content updates must be routed to owner skills with schema constraints included in the handoff.

### Phase 3 — Build the structured pack

Use the standard pack from [references/output-pack.md](references/output-pack.md).

Default user-facing sections:
- `Best Next Actions`
- `Article Name Ideas`
- `Titles For This Conversation`
- `Existing Content Opportunities`
- `Owner Skill Handoffs`
- `Source Pack`
- `Evidence Ledger`

Detailed source-pack subsections:
- `Build Summary`
- `Source Analysis`
- `Product Documentation Notes`
- `Internal Change Narrative`
- `Marketing Claims`
- `Content Angles`
- `Diffusion Map`

Adapt the pack to the request:
- for `doc`, expand doc notes and compress marketing
- for `marketing`, expand claims and angles but keep the evidence ledger strict
- for `release notes` or `changelog`, emphasize externally understandable change narrative
- for `faq` or `landing`, convert proven facts into reusable answer blocks or copy hooks
- for supplied text, replace build-specific sections with source-specific reframing where needed
- for `article`, `blog`, or `outline`, expand `Article Name Ideas` and `Titles For This Conversation` first, then keep the source pack compact
- for `docs`, `site`, `apply`, `write`, `update`, `improve`, or existing-file targets, expand `Existing Content Opportunities` and `Owner Skill Handoffs` before article ideas when placement is the primary decision

The pack is the deliverable. When the user asks for applied content, the final response should summarize the handoffs and name the owner skill that should write or audit next.

### Phase 4 — Safety pass

Before finalizing:
- remove claims that depend on unstated assumptions
- downgrade any unproven statement from fact to hypothesis
- separate internal implementation detail from user-facing value
- note docs or copy surfaces that should be updated, but are not yet updated
- avoid reproducing the source too closely; transform it into fresh structure, angles, and wording

Before finalizing, verify that every recommended `must write` and `should write` surface is either:

- routed to an owner skill with concrete context
- explicitly deferred with a concrete reason
- blocked by a missing or ambiguous content surface

## Output rules

The output must be directly reusable. Prefer short blocks over essay-style prose.

Required behavior:
- lead with article names, conversation titles, and next actions when the user asks for repurposing ideas
- include existing-content placement opportunities across internal docs and public content unless explicitly out of scope
- clearly separate documentation material from marketing material
- make uncertainty explicit
- keep language specific and concrete
- preserve the project's actual terminology from docs/code when known
- avoid hype words unless already grounded in the project's brand voice
- for third-party source text, identify what is reusable as an idea versus what should not be echoed directly
- when the user asks to apply, avoid pretending work was applied; report the owner-skill handoffs, concept placement, constraints, and any deferred surfaces

If the work is mostly internal:
- emphasize internal docs, release notes, support notes, and changelog material
- keep public-facing claims minimal

If the work is strongly user-facing:
- provide both a factual doc block and a careful marketing block

If the source is external content:
- analyze the source before proposing repurposing paths
- identify the most relevant target outputs instead of forcing the full pack
- prefer reframing, angle extraction, summaries, outlines, FAQ ideas, and content hooks over near-paraphrase

## Recommended transformations

Translate implementation work into higher-level assets carefully:

- bug fix → support note, release note, FAQ entry, "what changed" snippet
- feature addition → user-facing doc note, changelog entry, value proposition bullets, launch angles
- refactor → internal architecture note, maintainability rationale, limited external copy only if user benefit is explicit
- workflow improvement → onboarding update, operator note, productivity claim only if justified

Translate supplied source content into higher-level assets carefully:

- paragraph or insight → hooks, headline variants, post angles, FAQ prompts, section outlines
- article excerpt → summary, thesis extraction, counter-angle, newsletter note, educational reframing
- concept note → glossary entry, explainer structure, landing-page supporting argument, nurture content angle

## Owner Skill Handoffs

`sf-repurpose` must route writing, improvement, audit, and validation work to owner skills. It should not perform those actions itself.

Use this routing map:

| Destination | Owner skill |
| --- | --- |
| Internal documentation, README, workflow docs, technical docs, editorial governance docs | `sf-docs` |
| Existing public page, docs page, skill page, FAQ, or article that should be improved | `sf-enrich` |
| New long-form article, guide, editorial, newsletter draft, or article outline to write | `sf-redact` |
| Clarity, tone, CTA, page-level copy friction, or message-fit review | `sf-audit-copy` |
| Persona, offer, persuasion, conversion strategy, or marketing copy review | `sf-audit-copywriting` |
| Search intent, on-page SEO, metadata, internal linking, or discoverability review | `sf-audit-seo` |

Each handoff must include:

- owner skill and recommended command
- target surface or `surface missing: blog`
- source truth summary
- source proof and evidence status
- intended content move
- claim constraints and unsafe claims
- priority and reason
- required context files to pass forward

If a user asks for a missing `sf-copy` lane, explain that no `sf-copy` skill exists yet. Use the existing owner skills above and recommend a future `sf-skill-build sf-copy` chantier only if short-form copy writing remains a recurring gap after audits.

## Good output characteristics

Strong output from this skill:
- sounds like it comes from the product truth, not from generic marketing instinct
- or, for supplied text, sounds like an intelligent transformation of the source rather than a rewrite clone
- helps a human immediately update docs, release notes, landing copy, or support material
- is safe to publish because evidence and uncertainty are visible
- leaves the next owner skill with enough context to write without rediscovering the source truth

Weak output from this skill:
- repeats generic benefits like "faster", "more robust", "streamlined"
- over-explains internal code without translating it into user impact
- invents positioning that the workstream did not support
- recommends several content assets but gives no owner-skill handoff after the user asked to apply them
- routes one isolated page while ignoring obvious site entry points, FAQ links, or content map updates
- paraphrases a source article too closely without adding framing or adaptation value

## Handoff rules

When this skill finishes:
- if the user wants polished docs, route the best doc sections into `sf-docs`
- if the user wants public copy or long-form content, route the proven marketing sections into `sf-redact`
- if the user wants existing content improved, route the target surfaces into `sf-enrich`
- if the user needs copy quality, conversion, persuasion, SEO, or search-intent review, route to `sf-audit-copy`, `sf-audit-copywriting`, or `sf-audit-seo`
- if the user wants current stats, market context, or external validation, route into `sf-enrich`
- if the user chooses one article name or title, route to `sf-redact` with the selected promise, source proof, and surface status

The key output of this skill is the source pack those downstream tasks can trust.
