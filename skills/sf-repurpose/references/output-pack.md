# Output Pack

Use this template as the default shape of the response. Expand or compress sections depending on signal strength.

```md
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

## Evidence Ledger

- Claim: ...
  Status: confirmed by conversation | confirmed by code | inferred | not safe to publish
  Source: conversation | file/path | both
```

Guidance:

- `Build Summary` should read like the truth source for all other sections.
- For external text sources, `Source Analysis` becomes the anchor section and `Build Summary` can be shortened or adapted.
- `Product Documentation Notes` should help someone update docs without re-reading the whole thread.
- `Marketing Claims` should stay tight and conservative. If only one safe claim exists, give one.
- `Content Angles` should be reusable prompts or headlines, not full articles.
- `Evidence Ledger` is mandatory whenever the output contains public-facing claims.

Compression rules:

- If the work is internal only, keep `Marketing Claims` to one short line or `None justified`.
- If the work is tiny, collapse `Internal Change Narrative` into 2-3 bullets.
- If the user asked for one surface only, keep the other sections brief but do not remove the evidence ledger.
- If the source is a third-party paragraph or article, favor `Source Analysis`, `Marketing Claims`, and `Content Angles` over build-specific sections.
