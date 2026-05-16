---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "shipflow"
created: "2026-05-16"
created_at: "2026-05-16 12:17:29 UTC"
updated: "2026-05-16"
updated_at: "2026-05-16 13:38:44 UTC"
status: ready
source_skill: sf-spec
source_model: "GPT-5 Codex"
scope: "skill-governance-refactor"
owner: "unknown"
user_story: "As a ShipFlow operator maintaining the skill system, I want the remaining oversized skills compacted through the established layering contract, so agents get concise activation instructions without losing specialist guardrails."
confidence: medium
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - "skills/"
  - "skills/*/SKILL.md"
  - "skills/references/"
  - "skills/references/skill-instruction-layering.md"
  - "skills/references/skill-context-budget.md"
  - "skills/sf-init/SKILL.md"
  - "skills/sf-help/SKILL.md"
  - "skills/sf-audit-code/SKILL.md"
  - "skills/sf-audit-copywriting/SKILL.md"
  - "skills/sf-audit-seo/SKILL.md"
  - "skills/sf-repurpose/SKILL.md"
  - "tools/skill_budget_audit.py"
  - "tools/shipflow_sync_skills.sh"
  - "shipflow_data/technical/skill-runtime-and-lifecycle.md"
depends_on:
  - artifact: "shipflow_data/workflow/specs/compact-shipflow-skill-instructions.md"
    artifact_version: "1.0.0"
    required_status: "ready"
  - artifact: "docs/explorations/2026-05-16-skill-instruction-compaction.md"
    artifact_version: "1.0.0"
    required_status: "draft"
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
  - artifact: "shipflow_data/technical/skill-runtime-and-lifecycle.md"
    artifact_version: "1.13.0"
    required_status: "reviewed"
supersedes: []
evidence:
  - "Phase 1 compacted sf-docs, sf-audit-design, and sf-verify from body-size risks into concise activation surfaces with skill-local references."
  - "2026-05-16 budget audit after phase 1: 61 skills, 0 hard violations, 0 warnings, 23 separate risks."
  - "2026-05-16 budget audit after phase 1: absolute listing estimate 7988 / 8000, repo-relative estimate 6646 / 8000, average description length 70.7."
  - "2026-05-16 budget audit after phase 1: 6 SKILL.md files still exceed 500 lines and 17 bodies exceed about 5000 tokens."
  - "Remaining >500-line skills: sf-init 718 lines, sf-audit-code 653 lines, sf-audit-copywriting 641 lines, sf-help 545 lines, sf-repurpose 523 lines, sf-audit-seo 507 lines."
  - "The user asked why only sf-audit-design appeared visibly changed and then confirmed proceeding with sf-spec for the next compaction pass."
next_step: "/sf-ship Compact ShipFlow Skill Instructions Phase 2"
---

# Spec: Compact ShipFlow Skill Instructions Phase 2

## Title

Compact ShipFlow Skill Instructions Phase 2

## Status

ready

## User Story

As a ShipFlow operator maintaining the skill system, I want the remaining oversized skills compacted through the established layering contract, so agents get concise activation instructions without losing specialist guardrails.

## Minimal Behavior Contract

When a maintainer launches phase 2 compaction, ShipFlow must use the phase 1 layering pattern to reduce every remaining `SKILL.md` body above 500 lines into a concise activation surface, while moving long templates, catalogs, matrices, examples, and mode playbooks into shared or skill-local references. A compacted skill must still make its role, trace category, process role, canonical path loader, report contract, required references, stop conditions, and validation rules visible in the top-level body. If any extraction would weaken security, audit, chantier, documentation, or source-faithfulness behavior, the implementation must keep the stricter local instruction and document the exception. The easiest edge case to miss is making the skill shorter but hiding a required route or guardrail inside a reference that the skill no longer explicitly loads.

## Success Behavior

- Preconditions: phase 1 compaction artifacts exist, `skills/references/skill-instruction-layering.md` defines the layering contract, and `python3 tools/skill_budget_audit.py --skills-root skills --format markdown` can report current size risks.
- Trigger: a maintainer runs `/sf-start Compact ShipFlow Skill Instructions Phase 2` after `/sf-ready` marks this spec ready.
- User/operator result: the six skills still above 500 lines become easier to scan and no longer look inconsistent with the phase 1 pattern.
- System effect: `sf-init`, `sf-help`, `sf-audit-code`, `sf-audit-copywriting`, `sf-audit-seo`, and `sf-repurpose` either fall below 500 lines or have documented exceptions with safe substitutions or follow-up scope.
- Proof of success: budget audit shows fewer `Skill bodies >500 lines` than the current baseline of 6; metadata lint passes for all changed frontmatter artifacts; `tools/shipflow_sync_skills.sh --check --all` reports current-user runtime visibility; focused `rg` checks prove each touched skill still exposes canonical paths, chantier/reporting contracts when applicable, and its required references.
- Silent success is not allowed; the implementation report must include before/after line and token-risk counts for every touched skill.

## Error Behavior

- If a skill-local reference is missing, malformed, or too broad, implementation must stop for that skill and keep the local instructions intact.
- If a compacted source skill no longer evaluates `Chantier potentiel`, verification must fail and the missing gate must be restored.
- If `sf-init` loses generated artifact templates or bootstrap sequencing during extraction, implementation must fail before runtime sync because project initialization behavior is user-visible.
- If `sf-repurpose` loses source-faithfulness, copyright, claim, or output-placement rules, implementation must fail because it could produce unsafe public content guidance.
- If an audit skill loses security, abuse, or reporting guardrails, implementation must fail and restore or move the exact guardrail into an explicitly loaded reference.
- Must never happen: renaming a skill, changing invocation keys, deleting skills to reduce metrics, weakening redaction or secret-handling rules, or editing unrelated dirty files.

## Problem

Phase 1 proved that the layered compaction approach works, but it only covered `sf-docs`, `sf-audit-design`, and `sf-verify`. The current budget audit still reports 6 `SKILL.md` files over 500 lines and 17 bodies over about 5000 tokens. This creates an inconsistent maintenance state: some skills now have clear activation surfaces, while other high-use skills still mix routing, boilerplate, templates, examples, scorecards, and workflow doctrine in one long file.

The user-visible confusion is already present: `sf-audit-design` looked like the only skill changed because its compaction was highly visible. Phase 2 should make the same pattern systematic across the remaining line-count outliers rather than leaving a one-off migration.

## Solution

Compact the six remaining skills above 500 lines using the phase 1 policy:

- keep top-level `SKILL.md` bodies as activation contracts
- move long specialist detail into `skills/<skill>/references/*.md`
- reuse shared references for common chantier, reporting, path, documentation, delegation, editorial, and technical-docs doctrine
- preserve stricter local instructions when reference extraction would reduce safety
- measure before and after with the existing skill budget audit

This phase is intentionally line-count targeted. Skills that are under 500 lines but still over about 5000 tokens remain out of scope unless a phase 2 extraction naturally removes shared duplication without expanding risk.

## Scope In

- Compact these six current >500-line skills:
  - `skills/sf-init/SKILL.md`
  - `skills/sf-help/SKILL.md`
  - `skills/sf-audit-code/SKILL.md`
  - `skills/sf-audit-copywriting/SKILL.md`
  - `skills/sf-audit-seo/SKILL.md`
  - `skills/sf-repurpose/SKILL.md`
- Create skill-local references under the touched skills as needed.
- Move bulky generated templates, catalogs, scorecards, domain matrices, examples, and mode playbooks out of top-level skill bodies.
- Keep or add explicit reference-loading instructions in each compacted skill.
- Preserve trace category, process role, chantier potential, reporting mode, canonical path, technical-docs, editorial, security, and source-faithfulness gates.
- Update `shipflow_data/technical/skill-runtime-and-lifecycle.md` if phase 2 adds new recurring reference patterns or clarifies the phased compaction policy.
- Record before/after metrics in this spec's `Skill Run History` during implementation.

## Scope Out

- Compacting all 17 token-risk skills in one pass.
- Compacting lifecycle skills `sf-spec`, `sf-start`, `sf-ready`, `sf-end`, or `sf-ship` in this phase.
- Refactoring `tools/skill_budget_audit.py` unless current output cannot support before/after reporting.
- Renaming skill directories, `name:` fields, descriptions, invocation keys, or public commands.
- Changing project bootstrap behavior, audit findings semantics, SEO doctrine, repurposing output promises, or help routing behavior.
- Editing unrelated existing dirty changes, including pre-existing edits in `skills/sf-start/SKILL.md`.
- Moving all shared doctrine into `AGENT.md`, `CLAUDE.md`, or `shipflow_data/technical/context.md`.

## Constraints

- Use `skills/references/skill-instruction-layering.md` as the placement contract before editing any skill.
- Resolve ShipFlow-owned files from `${SHIPFLOW_ROOT:-$HOME/shipflow}`.
- Each touched top-level skill must still expose its role and operational gates without requiring a reader to guess which reference to load.
- Source skills must retain explicit `Chantier potentiel` evaluation.
- Support skills must retain their "do not originate chantier unless explicitly formalized" behavior.
- Audit skills must remain findings-first and preserve severity, proof-gap, security, and abuse-case handling.
- `sf-init` must preserve absolute-path validation expectations, governance corpus bootstrap behavior, and generated artifact semantics.
- `sf-repurpose` must preserve source-faithfulness, copyright, claim-register, editorial surface, and output-placement constraints.
- References must have compliant ShipFlow frontmatter and narrow purpose. Avoid one mega-reference per skill when two smaller files make routing clearer.

## Dependencies

- Prior phase:
  - `shipflow_data/workflow/specs/compact-shipflow-skill-instructions.md`
  - `docs/explorations/2026-05-16-skill-instruction-compaction.md`
  - `skills/references/skill-instruction-layering.md`
  - `skills/references/skill-context-budget.md`
- Shared references:
  - `skills/references/canonical-paths.md`
  - `skills/references/chantier-tracking.md`
  - `skills/references/reporting-contract.md`
  - `skills/references/final-report-timestamp.md`
  - `skills/references/technical-docs-corpus.md`
  - `skills/references/editorial-content-corpus.md`
  - `skills/references/master-delegation-semantics.md`
  - `skills/references/project-development-mode.md`
- Skill-local references already present:
  - `skills/sf-repurpose/references/output-pack.md`
- Local tools:
  - `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
  - `python3 tools/shipflow_metadata_lint.py <changed-artifacts>`
  - `tools/shipflow_sync_skills.sh --check --all`
- Fresh external docs verdict: `fresh-docs not needed` for this spec because it changes local Markdown instruction architecture only. If implementation changes provider-specific skill metadata rules, runtime discovery assumptions, or external SEO/Search/OpenAI guidance, apply the documentation freshness gate before editing those contracts.

## Invariants

- A compacted skill must be behaviorally equivalent after loading the references it names.
- Line-count reduction is subordinate to safety, traceability, and source-faithfulness.
- Every moved rule must remain discoverable through an explicit top-level load instruction.
- Existing skill descriptions remain compliant and should not be broadened to compensate for shorter bodies.
- Runtime skill discovery must continue to expose all existing skills for the current user.
- The spec registry remains `shipflow_data/workflow/specs/`; do not create root `specs/` artifacts.
- Operational trackers are not edited by `sf-spec` or this compaction implementation.

## Links & Consequences

- `skills/sf-init/SKILL.md`: high user-facing risk because bootstrap templates and governance corpus setup must remain exact.
- `skills/sf-help/SKILL.md`: likely gains the most from extracting catalog tables and workflow cheat sheets; it should reference existing `chantier-tracking.md` role matrix instead of duplicating it.
- `skills/sf-audit-code/SKILL.md`: security and architecture guardrails must remain explicit; detailed phase checklists can move to local references.
- `skills/sf-audit-copywriting/SKILL.md`: persuasion frameworks and scoring matrices can move to local references while preserving conversion, compliance, and trust criteria.
- `skills/sf-audit-seo/SKILL.md`: technical SEO, content SEO, schema, AI visibility, and tracking sections can move to local references while preserving freshness and documentation corpus gates.
- `skills/sf-repurpose/SKILL.md`: source reconstruction, output selection, diffusion mapping, and owner-handoff detail can move to local references; source-faithfulness must stay local and explicit.
- `shipflow_data/technical/skill-runtime-and-lifecycle.md`: update if phase 2 establishes stable local-reference naming patterns or compaction phases.
- Runtime symlinks: no repair should be needed, but check is mandatory after skill edits.

## Documentation Coherence

- Required: this spec is the durable chantier record for phase 2.
- Required during implementation: update this spec's `Skill Run History` and `Current Chantier Flow`.
- Conditional: update `shipflow_data/technical/skill-runtime-and-lifecycle.md` if implementation adds recurring reference conventions or changes the documented compaction policy.
- Conditional: update `skills/references/skill-context-budget.md` only if thresholds, interpretation, or validation commands change.
- No public README/site update is required because skill names and user-facing commands do not change.
- No `TASKS.md`, `AUDIT_LOG.md`, or `PROJECTS.md` edit is required from this spec.

## Edge Cases

- `sf-help` contains a duplicated chantier role matrix; moving it blindly could hide useful quick answers. The compact skill should point to `chantier-tracking.md` for canonical roles and keep only user-facing routing summaries.
- `sf-init` includes literal templates that may look like removable examples but are generated output contracts. Move them only if the top-level skill clearly names which template reference to load.
- `sf-audit-code`, `sf-audit-copywriting`, and `sf-audit-seo` have similar audit skeletons but different domains. Do not over-generalize them into one shared audit mega-reference.
- `sf-repurpose` already has `references/output-pack.md`; phase 2 should reuse it instead of duplicating the output pack in a new file.
- Some skills may remain over about 5000 tokens after dropping below 500 lines. That is acceptable for phase 2 if the line-count outliers are resolved and token-only risks are listed for phase 3.
- A compacted skill may pass budget audit but fail behaviorally because the reference load order is ambiguous. Focused `rg` and manual verification must check load order and stop conditions, not only size.

## Implementation Tasks

- [x] Task 1: Capture phase 2 baseline metrics
  - File: `shipflow_data/workflow/specs/compact-shipflow-skill-instructions-phase-2.md`
  - Action: During `sf-start`, append current audit counts and per-target line/token estimates before editing.
  - User story link: Gives objective before/after proof for the remaining oversized skills.
  - Depends on: None
  - Validate with: `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
  - Notes: Record only summary counts and target skill metrics, not the full audit table.

- [x] Task 2: Compact `sf-init` with bootstrap references
  - File: `skills/sf-init/SKILL.md`
  - Action: Keep bootstrap role, mode detection, project setup sequence, governance corpus gate, validation, and final report rules local; move long generated templates, MCP setup details, and corpus bootstrap detail into `skills/sf-init/references/*.md`.
  - User story link: Reduces a major body-size outlier without changing project initialization behavior.
  - Depends on: Task 1
  - Validate with: `rg -n "Trace category|Process role|canonical-paths|project-development-mode|governance|report" skills/sf-init/SKILL.md`
  - Notes: Preserve all generated artifact semantics and absolute-path expectations.

- [x] Task 3: Compact `sf-help` with catalog references
  - File: `skills/sf-help/SKILL.md`
  - Action: Keep quick routing, top skill categories, prompt examples, and no-trace behavior local; move long skill catalog, workflow cycle, scoring, file reference, and quick-answer material into `skills/sf-help/references/*.md`.
  - User story link: Makes help easier to use while preserving discovery coverage.
  - Depends on: Task 1
  - Validate with: `rg -n "Trace category|Process role|Chantier Registry|Skills at a Glance|Quick Answers|references/" skills/sf-help/SKILL.md`
  - Notes: Prefer linking to `skills/references/chantier-tracking.md` over duplicating the full role matrix.

- [x] Task 4: Compact `sf-audit-code` with audit references
  - File: `skills/sf-audit-code/SKILL.md`
  - Action: Keep source-de-chantier behavior, findings-first report mode, mode detection, fix/report contract, and security stop conditions local; move long phase checklists and detailed audit criteria into `skills/sf-audit-code/references/*.md`.
  - User story link: Preserves code-audit quality while reducing instruction dilution.
  - Depends on: Task 1
  - Validate with: `rg -n "Chantier Potential|Report Modes|GLOBAL MODE|FILE MODE|PROJECT MODE|security|findings" skills/sf-audit-code/SKILL.md`
  - Notes: Security, permission, data integrity, and architecture guardrails must remain visible in the top-level skill or an explicitly loaded reference.

- [x] Task 5: Compact `sf-audit-copywriting` with persuasion references
  - File: `skills/sf-audit-copywriting/SKILL.md`
  - Action: Keep audit purpose, report mode, chantier potential, mode selection, and core conversion/trust gates local; move long frameworks, scoring matrices, examples, and domain-specific checklists into `skills/sf-audit-copywriting/references/*.md`.
  - User story link: Keeps specialist copywriting judgment without forcing the agent to parse every framework on activation.
  - Depends on: Task 1
  - Validate with: `rg -n "Trace category|Process role|Chantier Potential|Report Modes|score|conversion|trust" skills/sf-audit-copywriting/SKILL.md`
  - Notes: Do not weaken legal/compliance, trust, or claim-evidence checks.

- [x] Task 6: Compact `sf-audit-seo` with SEO references
  - File: `skills/sf-audit-seo/SKILL.md`
  - Action: Keep canonical/reporting/chantier gates, freshness triggers, governance corpus loading, mode detection, and report requirements local; move detailed technical SEO, on-page, structured data, internal linking, AI visibility, tracking, and checklist detail into `skills/sf-audit-seo/references/*.md`.
  - User story link: Keeps SEO audit routing clear while preserving specialist coverage.
  - Depends on: Task 1
  - Validate with: `rg -n "Governance Corpora|OpenAI|ChatGPT|Chantier Potential|Report Modes|structured data|AI Visibility" skills/sf-audit-seo/SKILL.md`
  - Notes: If implementation changes external SEO/Search/OpenAI doctrine, run the Documentation Freshness Gate first.

- [x] Task 7: Compact `sf-repurpose` with source and output references
  - File: `skills/sf-repurpose/SKILL.md`
  - Action: Keep source-faithfulness, read-only delegation, execution contract, mode detection, safety pass, output rules, and handoff gates local; move source-mode detail, transformation catalog, diffusion map, and long output construction rules into skill-local references while reusing `skills/sf-repurpose/references/output-pack.md`.
  - User story link: Reduces a large support skill while preserving safe content transformation.
  - Depends on: Task 1
  - Validate with: `rg -n "Read-Only Delegation|Execution contract|source|copyright|claim|output-pack|Owner Skill Handoffs" skills/sf-repurpose/SKILL.md`
  - Notes: Do not weaken source attribution, claim-register, editorial surface, or article-surface policy.

- [x] Task 8: Validate metadata for new and changed references
  - File: `skills/**/references/*.md`
  - Action: Run metadata lint on every new reference and any changed reference/doc with frontmatter.
  - User story link: Keeps extracted instruction files traceable and readable by governance tooling.
  - Depends on: Tasks 2-7
  - Validate with: `python3 tools/shipflow_metadata_lint.py <changed-artifacts>`
  - Notes: Include this spec if its run history is updated during implementation.

- [x] Task 9: Run budget, runtime, and coherence checks
  - File: `skills/`
  - Action: Run the budget audit, runtime skill sync check, and focused `rg` checks for required labels and reference paths in each touched skill.
  - User story link: Proves compaction improved size metrics without breaking skill discovery or lifecycle gates.
  - Depends on: Tasks 2-8
  - Validate with: `python3 tools/skill_budget_audit.py --skills-root skills --format markdown` and `tools/shipflow_sync_skills.sh --check --all`
  - Notes: Expected minimum success is fewer than 6 `Skill bodies >500 lines`.

- [x] Task 10: Update phase 2 documentation notes if needed
  - File: `shipflow_data/technical/skill-runtime-and-lifecycle.md`
  - Action: Add a short note only if phase 2 creates stable naming conventions or new recurring reference patterns not already documented by phase 1.
  - User story link: Keeps technical docs aligned with the instruction architecture maintainers now see in the repo.
  - Depends on: Tasks 2-9
  - Validate with: `rg -n "Instruction Layering|phase|skill-local|references" shipflow_data/technical/skill-runtime-and-lifecycle.md`
  - Notes: Do not rewrite unrelated lifecycle doctrine.

## Acceptance Criteria

- [ ] CA 1: Given the current baseline has 6 skills above 500 lines, when phase 2 finishes, then the budget audit reports fewer than 6 skills above 500 lines.
- [ ] CA 2: Given each target skill has a trace category and process role, when it is compacted, then those labels remain visible in the top-level `SKILL.md`.
- [ ] CA 3: Given a target skill uses chantier reporting, when it produces a final report, then its top-level body still directs it to load the reporting and chantier references.
- [ ] CA 4: Given `sf-help` currently duplicates role matrix content, when compacted, then canonical role doctrine is loaded from `skills/references/chantier-tracking.md` or an explicitly named reference instead of a stale duplicate.
- [ ] CA 5: Given `sf-init` creates project governance artifacts, when compacted, then generated templates and bootstrap sequence remain available through explicitly loaded skill-local references.
- [ ] CA 6: Given `sf-audit-code` can surface security and data risks, when compacted, then security, permission, architecture, reliability, and fix/report gates are still present locally or in explicitly loaded references.
- [ ] CA 7: Given `sf-audit-copywriting` evaluates public claims and conversion trust, when compacted, then claim evidence, compliance, trust, and conversion criteria remain testable.
- [ ] CA 8: Given `sf-audit-seo` can depend on external search or OpenAI behavior, when compaction changes only local instruction layout, then the spec records `fresh-docs not needed`; if doctrine changes, the freshness gate is run first.
- [ ] CA 9: Given `sf-repurpose` transforms source material, when compacted, then source-faithfulness, copyright, claim-register, editorial surface, and output-placement constraints remain explicit.
- [ ] CA 10: Given new references are created, when metadata lint runs, then every changed frontmatter artifact passes.
- [ ] CA 11: Given runtime skills are symlinked or mirrored for the current user, when compaction finishes, then `tools/shipflow_sync_skills.sh --check --all` reports no blocked runtime visibility.
- [ ] CA 12: Given unrelated files may already be dirty, when implementation finishes, then the diff contains only this chantier's changes plus pre-existing unrelated dirty state untouched.

## Test Strategy

- Run `python3 tools/skill_budget_audit.py --skills-root skills --format markdown` before and after implementation.
- Run `python3 tools/shipflow_metadata_lint.py` on this spec, new skill-local references, and any changed technical/shared reference docs.
- Run `tools/shipflow_sync_skills.sh --check --all` after skill edits.
- Run focused `rg` checks on each touched `SKILL.md` for:
  - `Trace category`
  - `Process role`
  - `canonical-paths`
  - `reporting-contract`
  - `chantier-tracking` or justified non-applicable trace behavior
  - required skill-local reference names
- Manually inspect diffs for each target skill to confirm moved text is still reachable through explicit references.

## Risks

- High: `sf-init` can silently lose bootstrap semantics if templates are moved without precise loading instructions.
- High: audit skills can lose security or severity nuance if checklists are over-compressed.
- High: `sf-repurpose` can lose source-faithfulness safeguards if safety rules are treated as examples.
- Medium: new references can become too large and recreate the instruction-dilution problem one level down.
- Medium: `sf-help` can drift if it keeps copied role tables instead of linking to canonical references.
- Low: runtime skill visibility should not change, but must still be checked because skill files are material runtime artifacts.

## Execution Notes

- Read first:
  - `skills/references/skill-instruction-layering.md`
  - `skills/references/skill-context-budget.md`
  - `shipflow_data/workflow/specs/compact-shipflow-skill-instructions.md`
  - the six target `SKILL.md` files
- Implementation order:
  - capture fresh budget baseline
  - compact `sf-help` or `sf-init` first to validate phase 2 style on a non-audit skill
  - compact audit skills one by one to avoid mixing domain guardrails
  - compact `sf-repurpose` after checking existing `output-pack.md`
  - run metadata, budget, runtime, and focused coherence checks
- Use `apply_patch` for manual edits.
- Do not use broad automated rewrites across all skills.
- Stop and reroute to user review if a target skill requires behavior changes rather than pure layout extraction.
- Stop and document an exception if a skill cannot drop below 500 lines without hiding a guardrail.

## Open Questions

None for this spec. The phase 2 target set is determined by the fresh post-phase-1 budget audit: all six remaining `SKILL.md` files above 500 lines.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-05-16 12:17:29 UTC | sf-spec | GPT-5 Codex | Created phase 2 compaction spec from post-phase-1 audit baseline and user confirmation | Draft spec saved | /sf-ready Compact ShipFlow Skill Instructions Phase 2 |
| 2026-05-16 12:46:20 UTC | sf-ready | GPT-5 Codex | Evaluated structure, metadata, user-story alignment, execution clarity, adversarial risk, security posture, language doctrine, and documentation coherence | ready | /sf-start Compact ShipFlow Skill Instructions Phase 2 |
| 2026-05-16 13:19:43 UTC | sf-start | GPT-5 Codex | Compacted six remaining >500-line skills into activation surfaces and extracted detailed workflows into skill-local references | implemented | /sf-verify Compact ShipFlow Skill Instructions Phase 2 |
| 2026-05-16 13:20:19 UTC | sf-verify | GPT-5 Codex | Verified budget audit, metadata lint, runtime sync, focused skill coherence checks, language doctrine, fresh-docs verdict, and documentation coherence | verified | /sf-end Compact ShipFlow Skill Instructions Phase 2 |
| 2026-05-16 13:20:54 UTC | sf-end | GPT-5 Codex | Closed phase 2 chantier, updated changelog, and preserved next lifecycle step for shipping | closed | /sf-ship Compact ShipFlow Skill Instructions Phase 2 |
| 2026-05-16 13:38:44 UTC | sf-ship | GPT-5 Codex | Ran pre-ship checks, staged compaction chantier changes, committed, and prepared push | shipped | none |

## Current Chantier Flow

- sf-spec: done
- sf-ready: ready
- sf-start: implemented
- sf-verify: verified
- sf-end: closed
- sf-ship: shipped
- Next step: none
