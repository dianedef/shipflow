# Output Pack

Use this template as the default shape of the response. Expand or compress sections depending on signal strength.

```md
## Best Next Actions

- Action:
  Asset:
  Target surface:
  Source proof:
  Next step:

## Article Name Ideas

- Working name:
  Angle:
  Source proof:
  Target surface:
  Recommended next step:

## Titles For This Conversation

- Title:
  Article promise:
  Why this conversation supports it:
  Best destination:

## Existing Content Opportunities

### Internal Docs

- Surface:
  Placement idea:
  Audience learning moment:
  Source proof:
  Content move:
  Priority:
  Next step:

### Public Content

- Surface:
  Placement idea:
  Audience learning moment:
  Source proof:
  Content move:
  Priority:
  Next step:

## Owner Skill Handoffs

- Owner skill:
  Recommended command:
  Target surface:
  Source truth:
  Source proof:
  Intended content move:
  Claim constraints:
  Priority:
  Context to pass forward:

## Source Pack

## Build Summary

- Problem:
- Audience:
- What changed:
- Why it matters:
- Current status:

## Source Analysis

- Source type:
- Core idea:
- Strongest insight:
- Best reusable wording:
- Diagrams or lists worth preserving:
- Audience fit:
- What is worth repurposing:
- What to avoid echoing too closely:

## Product Documentation Notes

- User-visible behavior:
- Setup or workflow impact:
- Constraints / caveats:
- Docs to update:

## Internal Change Narrative

- Before:
- After:
- Tradeoff chosen:
- Follow-up worth tracking:

## Marketing Claims

- Safe claims:
- Claims to soften:
- Claims to avoid:

## Content Angles

- Release note:
- FAQ entry:
- Landing/page hook:
- Blog or post angle:
- Newsletter angle:
- Social/thread angle:

## Diffusion Map

- Canonical surface:
- Supporting surfaces:
- Repeated concept:
- Per-surface job:
- Surfaces intentionally skipped:

## Handoff Checklist

- Must route:
- Should route:
- Optional:
- Deferred / blocked:

## Evidence Ledger

- Claim: ...
  Status: confirmed by conversation | confirmed by code | inferred | not safe to publish
  Source: conversation | file/path | both
```

Guidance:

- `Best Next Actions` must come first and stay short enough to act on without reading the full pack.
- `Article Name Ideas` should give durable article concepts tied to existing product, docs, skill pages, FAQ, semantic clusters, or the current chantier. Default to 5 to 8 strong ideas.
- `Titles For This Conversation` is mandatory in workstream mode and should give title candidates that can directly repurpose the current conversation. Default to 5 to 8 strong titles.
- `Existing Content Opportunities` should identify where the source insight can improve existing internal docs and public content. It should explain the audience learning moment, not only name a file.
- `Owner Skill Handoffs` should route writing and improvement work to `sf-docs`, `sf-enrich`, `sf-redact`, `sf-audit-copy`, `sf-audit-copywriting`, or `sf-audit-seo`; `sf-repurpose` does not write the content itself.
- If no blog or article surface is declared, keep the ideas and titles but mark destination as `surface missing: blog`; do not invent paths.
- `Build Summary` should read like the truth source for all other sections.
- For external text sources, `Source Analysis` becomes the anchor section and `Build Summary` can be shortened or adapted.
- `Best reusable wording` should capture clear conversational phrases that can be reused verbatim or near-verbatim in docs, articles, or FAQ entries.
- `Diagrams or lists worth preserving` should identify simple explanation structures that should be moved into the target surface instead of left in chat.
- `Product Documentation Notes` should help someone update docs without re-reading the whole thread.
- `Marketing Claims` should stay tight and conservative. If only one safe claim exists, give one.
- `Content Angles` should be reusable prompts or headlines, not full articles.
- `Diffusion Map` is mandatory when the source idea is site-facing or SEO-relevant.
- `Handoff Checklist` is mandatory when the user asks to apply, create, update, or fill site/docs surfaces.
- `Evidence Ledger` is mandatory whenever the output contains public-facing claims.

Compression rules:

- If the work is internal only, keep `Marketing Claims` to one short line or `None justified`.
- If the work is tiny, collapse `Internal Change Narrative` into 2-3 bullets.
- If the user asked for one surface only, keep the other sections brief but do not remove the evidence ledger.
- If the source is a third-party paragraph or article, favor `Source Analysis`, `Marketing Claims`, and `Content Angles` over build-specific sections.
- If the user asks for ideas, names, titles, articles, blog, or outlines, expand `Best Next Actions`, `Article Name Ideas`, and `Titles For This Conversation` before any detailed source analysis.
- If the user asks where to improve existing content, expand `Existing Content Opportunities` and compress article titles.
- If the user asks to apply or write, expand `Owner Skill Handoffs` and `Handoff Checklist`; do not claim files were changed by `sf-repurpose`.
