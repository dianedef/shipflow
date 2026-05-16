---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "shipflow"
created: "2026-05-16"
created_at: "2026-05-16 13:50:01 UTC"
updated: "2026-05-16"
updated_at: "2026-05-16 13:54:11 UTC"
status: ready
source_skill: sf-spec
source_model: "GPT-5 Codex"
scope: "skill-governance-refactor"
owner: "unknown"
user_story: "As a ShipFlow operator maintaining the skill system, I want the remaining non-lifecycle token-risk skills compacted through the established layering contract, so most specialist skills activate from concise instructions while preserving their domain guardrails."
confidence: medium
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - "skills/"
  - "skills/references/skill-instruction-layering.md"
  - "skills/references/skill-context-budget.md"
  - "skills/sf-audit/SKILL.md"
  - "skills/sf-audit-a11y/SKILL.md"
  - "skills/sf-audit-copy/SKILL.md"
  - "skills/sf-audit-gtm/SKILL.md"
  - "skills/sf-auth-debug/SKILL.md"
  - "skills/sf-enrich/SKILL.md"
  - "skills/sf-market-study/SKILL.md"
  - "skills/sf-prod/SKILL.md"
  - "skills/sf-redact/SKILL.md"
  - "tools/skill_budget_audit.py"
  - "tools/shipflow_sync_skills.sh"
depends_on:
  - artifact: "shipflow_data/workflow/specs/compact-shipflow-skill-instructions-phase-2.md"
    artifact_version: "1.0.0"
    required_status: "ready"
  - artifact: "skills/references/skill-instruction-layering.md"
    artifact_version: "0.1.0"
    required_status: "draft"
  - artifact: "skills/references/skill-context-budget.md"
    artifact_version: "0.3.0"
    required_status: "draft"
  - artifact: "skills/references/canonical-paths.md"
    artifact_version: "1.1.0"
    required_status: "active"
  - artifact: "skills/references/chantier-tracking.md"
    artifact_version: "0.5.0"
    required_status: "draft"
  - artifact: "skills/references/reporting-contract.md"
    artifact_version: "1.2.0"
    required_status: "active"
supersedes: []
evidence:
  - "After phase 2, skill budget audit reports 0 hard violations, 0 warnings, 0 SKILL.md files over 500 lines, and 11 bodies over about 5000 tokens."
  - "Remaining token-risk non-lifecycle targets: sf-audit 5721, sf-audit-a11y 5563, sf-audit-copy 7254, sf-audit-gtm 5459, sf-auth-debug 5174, sf-enrich 6035, sf-market-study 5429, sf-prod 5528, sf-redact 6526 estimated tokens."
  - "Remaining lifecycle token-risk targets sf-spec and sf-start are deferred to a dedicated phase because they own lifecycle gates; sf-start also has pre-existing dirty changes outside this chantier."
next_step: "/sf-ship Compact ShipFlow Skill Instructions Phase 3"
---

# Spec: Compact ShipFlow Skill Instructions Phase 3

## Title

Compact ShipFlow Skill Instructions Phase 3

## Status

ready

## User Story

As a ShipFlow operator maintaining the skill system, I want the remaining non-lifecycle token-risk skills compacted through the established layering contract, so most specialist skills activate from concise instructions while preserving their domain guardrails.

## Minimal Behavior Contract

When phase 3 runs, ShipFlow must compact the remaining non-lifecycle `SKILL.md` bodies over about 5000 tokens into short activation contracts and move long specialist workflows into skill-local references. Each touched skill must still expose role, canonical paths, trace category, process role, chantier potential when applicable, report contract, required references, mode detection, stop conditions, and validation. If a domain guardrail would become harder to discover after extraction, the top-level skill must keep a concise version of that guardrail and point to the detailed reference. The easiest edge case to miss is compacting source, audit, auth, production, market, or content safety rules into a reference without naming the exact load trigger in the activation body.

## Success Behavior

- Preconditions: phase 2 has shipped and the current budget audit reports 11 token-risk skills with no line-count violations.
- Trigger: a maintainer runs `/sf-start Compact ShipFlow Skill Instructions Phase 3`.
- User/operator result: all targeted non-lifecycle token-risk skills become concise enough for low-dilution activation while retaining domain-specific safety and reporting behavior.
- System effect: `sf-audit`, `sf-audit-a11y`, `sf-audit-copy`, `sf-audit-gtm`, `sf-auth-debug`, `sf-enrich`, `sf-market-study`, `sf-prod`, and `sf-redact` either leave the token-risk list or have documented exceptions.
- Proof of success: `python3 tools/skill_budget_audit.py --skills-root skills --format markdown` reports materially fewer than 11 token-risk skills, ideally only the deferred lifecycle pair `sf-spec` and `sf-start`; metadata lint passes; runtime skill sync check passes; focused `rg` checks confirm mandatory gates remain visible.

## Error Behavior

- If a skill-local reference is missing, malformed, or too broad to preserve behavior, keep the local instruction and document the exception.
- If a source skill loses `Chantier potentiel` routing, verification fails until restored.
- If `sf-auth-debug` loses auth/session/provider safety constraints, verification fails.
- If `sf-prod` loses production/deploy/log redaction or evidence rules, verification fails.
- If content/public-claim skills lose source, claim, legal, disclosure, or trust checks, verification fails.
- Must never happen: rename skills, change invocation keys, stage unrelated dirty `sf-start` changes, weaken redaction/security, or delete behavior to improve metrics.

## Problem

Phase 2 resolved every `SKILL.md` file over 500 lines, but 11 skills still exceed the approximate 5000-token progressive-disclosure risk. Two of those, `sf-spec` and `sf-start`, are lifecycle gates and should be migrated separately. The remaining 9 are specialist/source/support skills where a conservative local-reference extraction can reduce activation load without changing lifecycle semantics.

## Solution

Apply the phase 2 extraction pattern to the 9 non-lifecycle token-risk skills. Keep the top-level `SKILL.md` as the activation contract, create one skill-local workflow/checklist reference per skill when needed, and preserve domain guardrails in concise top-level language.

## Scope In

- Compact:
  - `skills/sf-audit/SKILL.md`
  - `skills/sf-audit-a11y/SKILL.md`
  - `skills/sf-audit-copy/SKILL.md`
  - `skills/sf-audit-gtm/SKILL.md`
  - `skills/sf-auth-debug/SKILL.md`
  - `skills/sf-enrich/SKILL.md`
  - `skills/sf-market-study/SKILL.md`
  - `skills/sf-prod/SKILL.md`
  - `skills/sf-redact/SKILL.md`
- Create skill-local references under each touched skill as needed.
- Preserve source-de-chantier/support/helper semantics and reporting defaults.
- Preserve auth, production, public-claim, accessibility, content, GTM, market, and redaction safety rules.
- Update this spec's run history and flow through `sf-start`, `sf-verify`, `sf-end`, and `sf-ship` when complete.

## Scope Out

- Compacting `skills/sf-spec/SKILL.md` or `skills/sf-start/SKILL.md`.
- Touching the pre-existing dirty `skills/sf-start/SKILL.md` change.
- Changing descriptions, skill names, invocation keys, or public skill promises.
- Changing runtime provider docs, external SEO/auth/production doctrine, or web APIs.
- Editing trackers unless a later full close explicitly needs it.

## Constraints

- Use `skills/references/skill-instruction-layering.md` before editing.
- Resolve ShipFlow-owned paths from `${SHIPFLOW_ROOT:-$HOME/shipflow}`.
- Top-level bodies must expose `Trace category`, `Process role`, `reporting-contract`, `canonical-paths`, and exact local references.
- Source skills must retain `Chantier potentiel`.
- Production/auth/content/public-claim/redaction guardrails must stay visible locally or in an explicitly named required reference.
- References must pass metadata lint.

## Dependencies

- Local docs and references listed in frontmatter.
- Local tools:
  - `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
  - `python3 tools/shipflow_metadata_lint.py <changed-artifacts>`
  - `tools/shipflow_sync_skills.sh --check --all`
- Fresh external docs verdict: `fresh-docs not needed` because this phase changes local Markdown instruction layout only. If implementation changes external auth/provider/production/content doctrine rather than moving it, stop and apply the documentation freshness gate first.

## Invariants

- Behavior must be equivalent after loading the named references.
- Safety, traceability, and source-faithfulness beat token reduction.
- Every moved rule must remain reachable from an explicit top-level load trigger.
- `sf-spec` and `sf-start` are deferred and must remain untouched except for pre-existing local dirty state.
- Runtime visibility must remain intact for Claude and Codex skills.

## Links & Consequences

- `sf-audit*`: audit report quality and chantier-potential routing must remain intact.
- `sf-auth-debug`: auth/session/provider debugging safety, redaction, and evidence rules must remain intact.
- `sf-prod`: deployment/runtime proof, log redaction, and production confidence rules must remain intact.
- `sf-enrich`, `sf-redact`, `sf-market-study`: public claim, research/source, business-risk, and content safety gates must remain intact.
- `skills/references/skill-context-budget.md`: no update required unless thresholds or interpretation change.

## Documentation Coherence

- Required: this spec records phase 3.
- Conditional: update `shipflow_data/technical/skill-runtime-and-lifecycle.md` only if phase 3 changes compaction doctrine beyond the phase 2 convention.
- No public README/site update required because user-facing command names and promises do not change.
- No tracker update required for quick implementation.

## Edge Cases

- A compacted source skill passes token budget but loses `Chantier potentiel` guidance.
- `sf-auth-debug` hides provider-specific safety or redaction in a reference that is not loaded for the relevant mode.
- `sf-prod` hides production proof limits or log redaction in a vague reference.
- Content skills hide copyright, public-claim, or source-evidence rules.
- `sf-audit-a11y` hides accessibility severity or user-impact checks.
- A reference becomes a large unsorted archive; acceptable only as a conservative phase 3 extraction if the top-level trigger is precise and future split is documented.

## Implementation Tasks

- [x] Task 1: Capture phase 3 baseline
  - File: `shipflow_data/workflow/specs/compact-shipflow-skill-instructions-phase-3.md`
  - Action: Record current risk counts and target list during `sf-start`.
  - User story link: Establishes measurable before/after proof.
  - Depends on: None
  - Validate with: `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
  - Notes: Baseline is 11 token-risk skills; phase 3 targets 9 non-lifecycle risks.

- [x] Task 2: Compact audit family targets
  - File: `skills/sf-audit*/SKILL.md`
  - Action: Compact `sf-audit`, `sf-audit-a11y`, `sf-audit-copy`, and `sf-audit-gtm` with skill-local references.
  - User story link: Reduces audit activation load while preserving findings-first behavior.
  - Depends on: Task 1
  - Validate with: focused `rg` checks for `Trace category`, `Process role`, `Chantier Potential`, report modes, and domain guardrails.
  - Notes: Do not over-generalize domain checklists into one shared audit mega-reference.

- [x] Task 3: Compact runtime/auth/prod targets
  - File: `skills/sf-auth-debug/SKILL.md`, `skills/sf-prod/SKILL.md`
  - Action: Move long provider/runtime proof playbooks to skill-local references.
  - User story link: Keeps operational skills concise without weakening evidence/redaction rules.
  - Depends on: Task 1
  - Validate with: focused `rg` checks for auth/session/provider, production/log/deploy, redaction, and evidence gates.
  - Notes: Fresh external docs gate remains not needed unless doctrine changes.

- [x] Task 4: Compact content/business targets
  - File: `skills/sf-enrich/SKILL.md`, `skills/sf-market-study/SKILL.md`, `skills/sf-redact/SKILL.md`
  - Action: Move long content, market, drafting, and research playbooks to skill-local references.
  - User story link: Reduces content skill load while preserving source, claim, and business-risk guardrails.
  - Depends on: Task 1
  - Validate with: focused `rg` checks for source, claims, evidence, legal/trust/disclosure, and content safety.
  - Notes: Preserve user-facing language doctrine.

- [x] Task 5: Validate and trace
  - File: `shipflow_data/workflow/specs/compact-shipflow-skill-instructions-phase-3.md`
  - Action: Run metadata lint, budget audit, runtime sync, focused coherence checks, and update run history/flow.
  - User story link: Proves the next lot improved metrics without breaking runtime visibility.
  - Depends on: Tasks 2-4
  - Validate with: all listed local tools.
  - Notes: Expected result is token risks reduced from 11 to about 2, with `sf-spec` and `sf-start` deferred.

## Acceptance Criteria

- [ ] CA 1: Given baseline has 11 token-risk skills, when phase 3 finishes, then budget audit reports materially fewer token-risk skills and no hard violations.
- [ ] CA 2: Given the 9 target skills are non-lifecycle token risks, when compacted, then each remains under the risk threshold or has a documented exception.
- [ ] CA 3: Given source skills can originate chantier potential, when compacted, then `Chantier potentiel` guidance remains visible.
- [ ] CA 4: Given auth/prod/content skills carry safety obligations, when compacted, then redaction, evidence, source, claim, and abuse guardrails remain explicit.
- [ ] CA 5: Given runtime skills changed, when validation runs, then `tools/shipflow_sync_skills.sh --check --all` reports no blocked links.
- [ ] CA 6: Given `sf-start` has unrelated dirty changes, when shipping phase 3, then those changes are not staged unless explicitly included by the user.

## Test Strategy

- Run skill budget audit before and after.
- Run metadata lint on all new references and the spec.
- Run runtime sync check for all skills.
- Run focused `rg` checks for mandatory labels and domain guardrails.
- Inspect staged diff to ensure `sf-spec` and `sf-start` are not included.

## Risks

- High: auth/prod/content guardrails are safety-sensitive and must not be hidden behind vague references.
- Medium: audit-family skills can become too generic if domain checklists are over-shared.
- Medium: token-only compaction can move complexity rather than reduce it; acceptable for this phase only when load triggers are precise.
- Low: runtime visibility should remain stable but must still be checked.

## Execution Notes

- Read first: phase 2 spec, `skill-instruction-layering.md`, `skill-context-budget.md`, and the 9 target skills.
- Use conservative extraction: keep concise activation contracts and move detailed workflows to `skills/<skill>/references/`.
- Do not touch `skills/sf-spec/SKILL.md` or `skills/sf-start/SKILL.md`.
- Use `apply_patch` or a narrowly scoped mechanical extraction; no broad repo rewrites.
- Stop if implementation would require behavior changes instead of layout extraction.

## Open Questions

None. The target set is determined by the current budget audit and excludes lifecycle skills for a dedicated later phase.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-05-16 13:50:01 UTC | sf-spec | GPT-5 Codex | Created ready phase 3 spec for remaining non-lifecycle token-risk skills | ready | /sf-start Compact ShipFlow Skill Instructions Phase 3 |
| 2026-05-16 13:54:11 UTC | sf-start | GPT-5 Codex | Compacted 9 non-lifecycle token-risk skills into activation surfaces and skill-local workflow references | implemented | /sf-verify Compact ShipFlow Skill Instructions Phase 3 |
| 2026-05-16 13:54:11 UTC | sf-verify | GPT-5 Codex | Verified budget audit, metadata lint, runtime sync, and focused skill coherence checks | verified | /sf-end Compact ShipFlow Skill Instructions Phase 3 |
| 2026-05-16 13:54:11 UTC | sf-end | GPT-5 Codex | Closed phase 3 chantier and prepared quick ship | closed | /sf-ship Compact ShipFlow Skill Instructions Phase 3 |

## Current Chantier Flow

- sf-spec: done
- sf-ready: ready
- sf-start: implemented
- sf-verify: verified
- sf-end: closed
- sf-ship: not launched
- Next step: `/sf-ship Compact ShipFlow Skill Instructions Phase 3`
