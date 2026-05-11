---
artifact: brand_context
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: "shipflow"
created: "2026-04-26"
updated: "2026-05-11"
status: reviewed
source_skill: manual
scope: brand
owner: "unknown"
confidence: medium
risk_level: medium
brand_voice: "direct, technical, disciplined, unsentimental"
trust_posture: "earn trust through explicit tradeoffs, visible constraints, and proof rather than hype"
security_impact: unknown
docs_impact: yes
evidence:
  - "Current repository guidance consistently favors clarity, rigor, constraints, and explicit validation"
  - "The framework distinguishes implemented, verified, assumed, stale, and partial rather than optimistic framing"
linked_artifacts:
  - "shipflow_data/business/business.md"
  - "shipflow_data/business/gtm.md"
depends_on:
  - artifact: "shipflow_data/business/business.md"
    artifact_version: "1.2.0"
    required_status: "reviewed"
supersedes: []
next_review: "2026-05-26"
next_step: "/sf-docs audit shipflow_data/business/branding.md"
---

# Brand Context

## Voice

- Direct and operator-grade.
- Precise over clever.
- Confident when proven, cautious when evidence is incomplete.
- Serious about engineering quality without sounding corporate or inflated.

## Trust Posture

- ShipFlow should sound like a framework built by people who have felt the pain of ambiguity, not like a generic AI booster.
- Claims should be scoped tightly and tied to visible mechanisms: specs, readiness, verification, metadata, audits, context docs.
- Trust is earned by naming constraints, failure modes, and tradeoffs explicitly.

## Vocabulary

- Prefer: contract, context, verification, invariant, workflow, proof, routing, artifact, scope, consequence.
- Avoid: magic, autonomous genius, instant, effortless, perfect, seamless unless the constraint is truly negligible.
- Prefer “reduces ambiguity” over “solves everything”.

## Personality

- Rigorous without sounding bureaucratic.
- Technical without sounding exclusionary.
- Calm, explicit, and evidence-oriented.

## Claims Boundaries

- Allowed: ShipFlow improves clarity, structure, and repeatability of AI-assisted development work.
- Allowed: ShipFlow helps agents start with better context and verify against explicit contracts.
- Not allowed without stronger proof: guaranteed productivity gains, guaranteed correctness, guaranteed security, zero-regression shipping.
- Not allowed: marketing language that implies the framework replaces engineering judgment.

## Style Of Address

- Speak to a capable operator, not to a passive buyer.
- Prefer concrete framing over slogans.
- State tradeoffs when they matter; do not hide them behind generic reassurance.

## Visual Direction

- The product should read as operational and work-focused rather than playful or futuristic.
- Visual trust should come from structure, legibility, and specificity, not decorative hype.
- Any future site should make the product category legible quickly: disciplined AI delivery framework plus server-side environment control.
