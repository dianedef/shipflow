---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "shipflow"
created: "2026-05-16"
created_at: "2026-05-16 08:06:03 UTC"
updated: "2026-05-16"
updated_at: "2026-05-16 12:00:23 UTC"
status: ready
source_skill: sf-spec
source_model: "GPT-5 Codex"
scope: "skill-governance-refactor"
owner: "unknown"
user_story: "As a ShipFlow operator using Codex and Claude Code skills, I want ShipFlow skill instructions to be shorter, layered, and less repetitive, so agents follow the highest-priority behavior without losing critical governance guardrails."
confidence: medium
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - "skills/"
  - "skills/*/SKILL.md"
  - "skills/references/"
  - "skills/sf-docs/SKILL.md"
  - "skills/sf-audit-design/SKILL.md"
  - "skills/sf-verify/SKILL.md"
  - "tools/skill_budget_audit.py"
  - "tools/shipflow_sync_skills.sh"
  - "shipflow_data/technical/skill-runtime-and-lifecycle.md"
  - "shipflow_data/technical/code-docs-map.md"
  - "shipflow-spec-driven-workflow.md"
depends_on:
  - artifact: "docs/explorations/2026-05-16-skill-instruction-compaction.md"
    artifact_version: "1.0.0"
    required_status: "draft"
  - artifact: "shipflow_data/technical/skill-runtime-and-lifecycle.md"
    artifact_version: "1.12.8"
    required_status: "reviewed"
  - artifact: "shipflow_data/technical/guidelines.md"
    artifact_version: "1.4.0"
    required_status: "reviewed"
  - artifact: "shipflow_data/technical/code-docs-map.md"
    artifact_version: "1.1.0"
    required_status: "reviewed"
  - artifact: "skills/references/skill-context-budget.md"
    artifact_version: "0.2.0"
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
  - artifact: "shipflow-spec-driven-workflow.md"
    artifact_version: "0.17.0"
    required_status: "draft"
supersedes: []
evidence:
  - "Exploration 2026-05-16 recommended layered compaction rather than aggressive shortening."
  - "Current inventory 2026-05-16: 61 skills, 20155 total SKILL.md lines."
  - "tools/skill_budget_audit.py 2026-05-16: 0 hard description violations, 0 warnings, 29 body-size risks."
  - "tools/skill_budget_audit.py 2026-05-16: 9 SKILL.md files exceed 500 lines and 20 body token estimates exceed about 5000 tokens."
  - "Largest current skills: sf-docs 941 lines, sf-audit-design 843 lines, sf-init 718 lines, sf-audit-code 653 lines, sf-audit-copywriting 641 lines, sf-verify 571 lines, sf-help 545 lines."
  - "Repeated instruction families observed: Canonical Paths, Chantier Tracking, Report Modes, Context blocks, development mode, documentation freshness, Sentry, browser proof, and long examples/checklists."
next_step: "/sf-end Compact ShipFlow Skill Instructions"
---

# Spec: Compact ShipFlow Skill Instructions

## Title

Compact ShipFlow Skill Instructions

## Status

ready

## User Story

As a ShipFlow operator using Codex and Claude Code skills, I want ShipFlow skill instructions to be shorter, layered, and less repetitive, so agents follow the highest-priority behavior without losing critical governance guardrails.

## Minimal Behavior Contract

When a maintainer asks to compact ShipFlow skills, ShipFlow must define a layered instruction contract, move repeated or bulky doctrine from selected `SKILL.md` bodies into canonical references, and leave each touched skill with a concise activation surface that still states its role, trace category, process role, required shared references, local workflow, stop conditions, validation, and report contract. If a shared reference is missing, ambiguous, or too broad to preserve the original behavior, implementation must stop or keep the local instruction in place rather than deleting safeguards. The easiest edge case to miss is compacting away a guardrail that `sf-ready`, `sf-verify`, chantier tracing, redaction, runtime sync, or documentation-update gates rely on.

## Success Behavior

- Preconditions: the repo has 61 local skills, existing shared references under `skills/references/`, and `tools/skill_budget_audit.py` can report body-size risks.
- Trigger: a maintainer runs `/sf-start Compact ShipFlow Skill Instructions` after this spec passes `/sf-ready`.
- User/operator result: the pilot skills become easier to scan, with repeated doctrine replaced by clear shared-reference loading rules and no loss of lifecycle, reporting, security, or validation behavior.
- System effect: at least the pilot skills `sf-docs`, `sf-audit-design`, and `sf-verify` are compacted or receive documented exceptions; a shared layering reference exists; technical docs reflect the new instruction architecture; runtime skill links still resolve for the current user.
- Proof of success: `python3 tools/skill_budget_audit.py --skills-root skills --format markdown` shows zero hard violations and reduced body-size risk for the pilot set; metadata lint passes for changed artifacts; `tools/shipflow_sync_skills.sh --check --all` reports current-user runtime visibility.
- Silent success is not allowed; the implementation report must show before/after line or token-risk evidence for each pilot skill.

## Error Behavior

- Expected failures: a proposed extracted reference is missing frontmatter, a compacted skill no longer exposes `Trace category` or `Process role`, a reference cannot be resolved from `$SHIPFLOW_ROOT`, a runtime skill symlink is stale, metadata lint fails, the audit still reports unchanged pilot body risks, or behavior becomes ambiguous after removing local text.
- User/operator response: the run must report the exact file, missing contract, validation failure, and safest recovery step.
- System effect: no destructive rewrite, deletion, invocation rename, or broad policy weakening occurs; partially compacted skills either remain behaviorally equivalent or are reverted by targeted patch before verification.
- Must never happen: removing redaction rules, auth/security gates, chantier trace semantics, final-report timestamp requirements, canonical path resolution, runtime sync checks, or documentation update gates to reduce line count.
- If a pilot skill cannot be safely compacted, the implementation must document the reason and substitute the next highest body-size risk from `sf-init`, `sf-help`, `sf-audit-code`, or `sf-audit-copywriting`.

## Problem

ShipFlow already fixed frontmatter description bloat: the current budget audit reports zero hard description violations and an average description length of 70.7 characters. The remaining problem is skill body size and repeated instruction load. The local inventory has 61 skills and 20155 `SKILL.md` lines. Nine skills exceed 500 lines, and twenty skill bodies exceed the approximate 5000-token progressive-disclosure risk threshold.

Long skill bodies are not automatically wrong. They become a problem when they bury the role of the skill, duplicate shared rules across many files, or make it harder for an agent to distinguish mandatory behavior from examples and historical caveats. The likely failure mode is not only token cost; it is instruction dilution.

## Solution

Use layered compaction instead of aggressive shortening. Add a shared instruction-layering reference that defines what belongs in a `SKILL.md` body versus a shared or skill-local reference. Then compact a pilot batch of high-risk skills by replacing duplicated doctrine and long checklists with explicit reference loading rules while preserving local behavior and validation gates.

The pilot batch is:

- `skills/sf-docs/SKILL.md`
- `skills/sf-audit-design/SKILL.md`
- `skills/sf-verify/SKILL.md`

If one pilot file proves unsafe to compact in this run, substitute the next highest body-size risk from:

- `skills/sf-init/SKILL.md`
- `skills/sf-help/SKILL.md`
- `skills/sf-audit-code/SKILL.md`
- `skills/sf-audit-copywriting/SKILL.md`

## Scope In

- Create a shared instruction-layering policy for ShipFlow skills.
- Extend the existing skill budget policy to cover body-size and reference extraction, not only discovery descriptions.
- Compact a pilot batch of long skill bodies without changing skill names, user-facing invocation keys, or lifecycle semantics.
- Move bulky mode details, examples, checklists, and repeated doctrine into `skills/references/*` or skill-local `skills/<skill>/references/*` files.
- Preserve compact local stubs for `Canonical Paths`, `Chantier Tracking`, `Report Modes`, trace category, process role, stop conditions, validation, and final reporting.
- Update technical documentation and produce a Documentation Update Plan for changed skill surfaces.
- Validate runtime skill visibility for the current user after edits.

## Scope Out

- Deleting skills to reduce body size.
- Renaming skill directories or invocation keys.
- Disabling model invocation for existing skills as a shortcut.
- Rewriting every ShipFlow skill in one pass.
- Changing the public promise of a skill unless the spec is explicitly updated and re-readied.
- Changing Codex, Claude Code, or installer runtime configuration.
- Modifying unrelated CLI behavior in `shipflow.sh`, `lib.sh`, `config.sh`, or `local/`.
- Broad language migration of legacy text beyond sections touched by this chantier.

## Constraints

- Internal skill contracts must be written in English; user-facing examples and final report labels may follow the active user language.
- Every modified `skills/*/SKILL.md` must still expose `Trace category` and `Process role` where chantier tracking applies.
- Lifecycle skills must still end reports with the compact `Chantier` block from `skills/references/reporting-contract.md`.
- Shared references must resolve from `${SHIPFLOW_ROOT:-$HOME/shipflow}`, not from the current project repo.
- Skill-local references must resolve as `$SHIPFLOW_ROOT/skills/<skill-name>/references/<file>.md`.
- Do not remove a local instruction until the referenced shared file contains the equivalent rule or an explicitly narrower local replacement.
- Prefer one small reference with a clear purpose over one new mega-reference.
- Do not put examples or large matrices in the top-level skill body when a reference can carry them.
- Do not add cross-skill boilerplate to `AGENT.md`, `CLAUDE.md`, or `shipflow_data/technical/context.md`.
- Existing dirty work in unrelated files must not be reverted.

## Dependencies

- Local references and docs:
  - `docs/explorations/2026-05-16-skill-instruction-compaction.md`
  - `skills/references/skill-context-budget.md`
  - `skills/references/canonical-paths.md`
  - `skills/references/chantier-tracking.md`
  - `skills/references/reporting-contract.md`
  - `skills/references/final-report-timestamp.md`
  - `shipflow_data/technical/skill-runtime-and-lifecycle.md`
  - `shipflow_data/technical/code-docs-map.md`
  - `shipflow_data/technical/guidelines.md`
  - `shipflow-spec-driven-workflow.md`
- Local tools:
  - `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
  - `python3 tools/shipflow_metadata_lint.py <changed-artifacts>`
  - `tools/shipflow_sync_skills.sh --check --all`
- Fresh external docs verdict: `fresh-docs not needed` for this spec because the behavior is local Markdown instruction architecture. If implementation changes frontmatter discovery limits, runtime skill discovery, or provider-specific skill metadata rules, rerun the Documentation Freshness Gate against current official Codex and Claude Code skill docs before editing those contracts.

## Invariants

- A compacted skill must remain independently understandable after its required references are loaded.
- The top of each touched skill must make its role and route obvious before detailed gates.
- Shared references must reduce duplication without hiding stop conditions.
- `sf-ready` and `sf-verify` must be able to mechanically find the required section labels and chantier trace data.
- Runtime skill discovery must keep all existing invocation keys available.
- The audit tool remains advisory for body-size risks unless this spec sets a stricter pilot acceptance target.
- Security, redaction, auth, tenant, secret-handling, and destructive-action guardrails take priority over line-count reduction.

## Links & Consequences

- `skills/*/SKILL.md`: pilot files shrink and use references more heavily.
- `skills/references/`: new or updated policy files become part of the skill execution contract.
- `tools/skill_budget_audit.py`: may stay unchanged if existing output is sufficient; update only if body compaction needs clearer before/after reporting.
- `shipflow_data/technical/skill-runtime-and-lifecycle.md`: must describe layered skill instructions and any new reference.
- `shipflow_data/technical/code-docs-map.md`: update only if validation commands, code path mappings, or docs triggers change.
- `shipflow-spec-driven-workflow.md`: update only if the general workflow doctrine changes, not for pilot implementation details.
- `sf-help` and public site skill pages: no required change unless user-facing skill routing or public promises change.
- Runtime symlinks: changing skill bodies should not require repair, but current-user visibility must be checked after material skill changes.

## Documentation Coherence

- Required documentation update: `shipflow_data/technical/skill-runtime-and-lifecycle.md` must mention the skill layering contract and body-size compaction policy.
- Required documentation update: `skills/references/skill-context-budget.md` must clarify that discovery descriptions are currently compliant, while body-size risk is handled by layered references.
- Conditional documentation update: `shipflow_data/technical/code-docs-map.md` only if the map's validation or trigger language changes.
- Conditional documentation update: `shipflow-spec-driven-workflow.md` only if lifecycle doctrine changes.
- No public README or site update is required unless the implementation changes user-facing skill names, public promises, or recommended commands.
- Operational trackers (`TASKS.md`, `AUDIT_LOG.md`, `PROJECTS.md`) are not edited by this spec.

## Edge Cases

- A compacted skill loads a reference that is too broad and contains instructions irrelevant to the current mode. The skill must state the exact sections or decisions to use.
- A repeated boilerplate block is similar but not identical across skills. The integrator must preserve the stricter local nuance or move that nuance into the reference.
- A skill drops below 500 lines but loses a required phrase used by `sf-verify` coherence checks. Verification must fail until restored.
- A reference grows into a new mega-doc. The implementation should split by purpose before accepting the compaction.
- A pilot skill still exceeds 500 lines after safe extraction. Accept only if the before/after reduction is material and the remaining excess has a documented reason.
- The audit still reports many non-pilot risks. That is acceptable for this chantier if pilot risks decreased and follow-up scope is documented.
- A skill-local `references/` file shadows a project-local path. Canonical path rules must resolve the ShipFlow-owned file from `$SHIPFLOW_ROOT`.
- A future provider changes skill loading behavior. That is out of current scope unless frontmatter discovery or runtime sync rules are changed.

## Implementation Tasks

- [x] Task 1: Capture a fresh baseline and confirm the pilot set
  - File: `shipflow_data/workflow/specs/compact-shipflow-skill-instructions.md`
  - Action: During `sf-start`, append a current run-history note with the output summary from `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`; confirm the pilot set is `sf-docs`, `sf-audit-design`, and `sf-verify`, or document any substitution from the allowed fallback list.
  - User story link: Establishes measurable before/after proof for compaction.
  - Depends on: None
  - Validate with: `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
  - Notes: Do not paste the entire audit table into the spec; record the aggregate counts and pilot line/token numbers.

- [x] Task 2: Add the shared skill instruction layering reference
  - File: `skills/references/skill-instruction-layering.md`
  - Action: Create a frontmatter-compliant reference that defines the `SKILL.md` top-level contract, what must stay local, what should move to shared references, what should move to skill-local references, exception policy for >500-line skills, and required validation after compaction.
  - User story link: Gives maintainers a concrete compaction rule instead of a subjective "make it shorter" instruction.
  - Depends on: Task 1
  - Validate with: `python3 tools/shipflow_metadata_lint.py skills/references/skill-instruction-layering.md`
  - Notes: Keep this reference narrow. It must not duplicate all of `skill-context-budget.md`, `chantier-tracking.md`, or `reporting-contract.md`.

- [x] Task 3: Update the skill budget reference for body-size risk
  - File: `skills/references/skill-context-budget.md`
  - Action: Add a short section linking discovery description budget to body-size risk, referencing `skill-instruction-layering.md`, and clarifying that the current frontmatter descriptions are compliant while body-size compaction remains open.
  - User story link: Keeps description budget and body compaction in one coherent policy family.
  - Depends on: Task 2
  - Validate with: `rg -n "body-size|instruction layering|500 lines|5000" skills/references/skill-context-budget.md`
  - Notes: Do not turn this reference into the detailed compaction guide; point to the new layering reference.

- [x] Task 4: Compact `sf-docs` by extracting mode detail
  - File: `skills/sf-docs/SKILL.md`
  - Action: Replace repeated shared doctrine and bulky mode instructions with concise local gates and references. Move long mode-specific material into skill-local references such as `skills/sf-docs/references/metadata-mode.md`, `skills/sf-docs/references/technical-mode.md`, and `skills/sf-docs/references/editorial-mode.md` if those are the natural boundaries after reading the file.
  - User story link: Proves the approach on the largest current skill body.
  - Depends on: Task 3
  - Validate with: `python3 tools/skill_budget_audit.py --skills-root skills --format markdown` and `rg -n "Trace category|Process role|reporting-contract|canonical-paths|skill-instruction-layering" skills/sf-docs/SKILL.md`
  - Notes: Preserve all user-facing modes and stop conditions. Do not change `name` or `description`.

- [x] Task 5: Compact `sf-audit-design` by extracting audit checklists
  - File: `skills/sf-audit-design/SKILL.md`
  - Action: Keep the audit role, findings-first report contract, routing, and critical design guardrails in the skill body; move detailed audit matrices, example patterns, or extended checklists into `skills/sf-audit-design/references/` files with precise load instructions.
  - User story link: Reduces instruction dilution in a long specialist skill without weakening design quality.
  - Depends on: Task 3
  - Validate with: `python3 tools/skill_budget_audit.py --skills-root skills --format markdown` and `rg -n "Trace category|Process role|findings|references/" skills/sf-audit-design/SKILL.md`
  - Notes: Preserve frontend design guardrails that affect safety, accessibility, or visual verification.

- [x] Task 6: Compact `sf-verify` by extracting shared verification gates
  - File: `skills/sf-verify/SKILL.md`
  - Action: Keep the six verification dimensions, chantier trace contract, report mode, and verdict semantics local; move detailed metadata, fresh-docs, dev-mode, bug-gate, and observability checklists into shared or skill-local references with exact load conditions.
  - User story link: Keeps the ship-readiness skill easier to follow while preserving the checks that prevent false "ready to ship" verdicts.
  - Depends on: Task 3
  - Validate with: `rg -n "Trace category|Process role|Success Behavior|Error Behavior|fresh-docs|Chantier" skills/sf-verify/SKILL.md` and `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
  - Notes: Do not weaken the distinction between `sf-start: implemented` and `sf-verify: partial`.

- [x] Task 7: Update technical documentation for the new instruction architecture
  - File: `shipflow_data/technical/skill-runtime-and-lifecycle.md`
  - Action: Document the new layering reference, body-size compaction policy, pilot validation expectations, and which files are sequential integration surfaces.
  - User story link: Makes future skill work follow the same architecture instead of reintroducing local duplication.
  - Depends on: Tasks 2-6
  - Validate with: `rg -n "layer|body-size|skill-instruction-layering|500" shipflow_data/technical/skill-runtime-and-lifecycle.md`
  - Notes: If `code-docs-map.md` triggers need adjustment, update it in the same integration pass and mention why.

- [x] Task 8: Run full validation and runtime visibility checks
  - File: `tools/skill_budget_audit.py`
  - Action: Run the existing audit and required metadata/runtime checks; update tooling only if the current audit cannot prove before/after pilot risk reduction.
  - User story link: Ensures compaction improves real maintainability without breaking skill discovery.
  - Depends on: Tasks 4-7
  - Validate with:
    - `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
    - `python3 tools/shipflow_metadata_lint.py shipflow_data/workflow/specs/compact-shipflow-skill-instructions.md skills/references/skill-instruction-layering.md skills/references/skill-context-budget.md shipflow_data/technical/skill-runtime-and-lifecycle.md`
    - `tools/shipflow_sync_skills.sh --check --all`
  - Notes: If metadata lint target paths differ because additional reference files were created, include those files too.

- [x] Task 9: Record follow-up scope for remaining long skills
  - File: `shipflow_data/workflow/specs/compact-shipflow-skill-instructions.md`
  - Action: Add an implementation note or run-history row naming the remaining body-size risks after the pilot and whether they should become a second compaction chantier.
  - User story link: Prevents a partial pilot from being mistaken for full corpus completion.
  - Depends on: Task 8
  - Validate with: final audit summary and `git diff --stat`
  - Notes: Do not silently open another spec; recommend `/sf-spec` only if the remaining risks justify it.

## Acceptance Criteria

- [x] CA 1: Given a fresh checkout, when a maintainer reads `skills/references/skill-instruction-layering.md`, then they can tell exactly what belongs in `SKILL.md`, shared references, and skill-local references.
- [x] CA 2: Given the current pilot skills, when compaction is complete, then `sf-docs`, `sf-audit-design`, and `sf-verify` have either dropped below 500 lines or reduced line/body-token risk materially with a documented exception.
- [x] CA 3: Given any modified lifecycle or chantier-aware skill, when `sf-verify` checks coherence, then `Trace category`, `Process role`, `Chantier Tracking`, and reporting-contract references remain visible.
- [x] CA 4: Given a missing or broken shared reference, when a compacted skill tries to load it, then the final report identifies a ShipFlow installation or reference gap instead of pretending the behavior is verified.
- [x] CA 5: Given the pilot implementation, when `python3 tools/skill_budget_audit.py --skills-root skills --format markdown` runs, then hard violations and warnings remain zero and the pilot body-size evidence improves from the baseline.
- [x] CA 6: Given changed references and docs, when metadata lint runs on the changed artifacts, then all frontmatter-required artifacts pass or the run is blocked with exact failures.
- [x] CA 7: Given material skill changes, when `tools/shipflow_sync_skills.sh --check --all` runs, then current-user Claude/Codex skill links are reported as current or the run is blocked with the stale target path.
- [x] CA 8: Given the implementation final report, when the user reviews it, then they see before/after evidence, validation commands, docs update status, remaining long-skill risks, and the next lifecycle command.
- [x] CA 9: Given skill compaction work, when security-sensitive rules are encountered, then redaction, auth/session, tenant, destructive-action, and secret-handling guardrails are preserved locally or in a loaded reference.

## Test Strategy

- Static audit: `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`.
- Metadata lint: `python3 tools/shipflow_metadata_lint.py` on this spec, new references, updated references, and updated technical docs.
- Runtime visibility: `tools/shipflow_sync_skills.sh --check --all`.
- Focused grep checks:
  - `rg -n "Trace category|Process role" skills/sf-docs/SKILL.md skills/sf-audit-design/SKILL.md skills/sf-verify/SKILL.md`
  - `rg -n "skill-instruction-layering|reporting-contract|canonical-paths" skills/sf-docs/SKILL.md skills/sf-audit-design/SKILL.md skills/sf-verify/SKILL.md`
  - `rg -n "REDACTED_|token|cookie|private key|secret" skills/references skills/sf-docs skills/sf-audit-design skills/sf-verify` with manual review, not automatic failure for legitimate redaction placeholders.
- Diff review: verify moved content remains reachable through explicit references and no invocation keys changed.
- Documentation Update Plan: required for `skills/**`, `skills/references/**`, and `shipflow_data/technical/**` changes.

## Risks

- High risk: deleting guardrails while moving text to references can weaken every future run of a lifecycle skill.
- Medium risk: references become too fragmented and increase load friction.
- Medium risk: body-size metrics improve but actual instruction clarity does not; before/after review must inspect the first-screen activation path, not only line count.
- Medium risk: `skill-context-budget.md` is still `status: draft`; readiness should either accept that as current policy for this chantier or require a docs update before implementation.
- Low risk: frontmatter description budget regresses; existing audit already covers this.
- Security risk: compacting redaction, auth, data, tenant, or destructive-action rules can cause unsafe agent behavior; preserve these rules unless an equivalent reference is loaded conditionally.

## Execution Notes

- Spec depth: full, because the change touches multiple skills, shared references, validation, runtime visibility, and technical docs.
- Read first:
  - `docs/explorations/2026-05-16-skill-instruction-compaction.md`
  - `skills/references/skill-context-budget.md`
  - `shipflow_data/technical/skill-runtime-and-lifecycle.md`
  - `shipflow_data/technical/code-docs-map.md`
  - the current `SKILL.md` for each pilot skill
- Implementation approach:
  1. Rerun audit and capture pilot baselines.
  2. Add the shared layering reference.
  3. Update the budget reference.
  4. Compact one pilot skill at a time.
  5. Run focused checks after each pilot before moving to the next.
  6. Update technical docs after code/content movement is stable.
  7. Run final audit, metadata lint, runtime sync check, and produce a Documentation Update Plan.
- Model/topology recommendation: single main integrator for shared references and technical docs; optional bounded sequential workers for individual pilot skills only after the layering reference exists. Parallelism is allowed only if `/sf-ready` adds explicit non-overlapping execution batches.
- Stop conditions:
  - a pilot skill loses trace category or process role visibility
  - a shared reference cannot be resolved from `$SHIPFLOW_ROOT`
  - metadata lint fails on changed artifacts
  - runtime skill sync check reports stale or missing links
  - the implementation cannot show before/after body-size evidence
  - compaction requires changing an invocation key or public skill promise
- Fresh external docs: `fresh-docs not needed` for the current local Markdown refactor. Reroute to `fresh-docs checked` if provider metadata behavior becomes part of the implementation.

## sf-start Implementation Notes (2026-05-16)

- Pilot set confirmed without fallback substitution: `sf-docs`, `sf-audit-design`, `sf-verify`.
- Baseline from `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`:
  - separate risks: 29
  - bodies >500 lines: 9
  - bodies >~5000 tokens: 20
  - pilot metrics:
    - `sf-docs`: 941 lines, ~16474 body tokens
    - `sf-audit-design`: 843 lines, ~15487 body tokens
    - `sf-verify`: 571 lines, ~8786 body tokens
- Post-implementation audit:
  - separate risks: 23
  - bodies >500 lines: 6
  - bodies >~5000 tokens: 17
  - pilot metrics:
    - `sf-docs`: 97 lines, ~1202 body tokens
    - `sf-audit-design`: 87 lines, ~1079 body tokens
    - `sf-verify`: 111 lines, ~1196 body tokens
- Follow-up scope remains for long-skill second chantier candidates:
  - >500 lines: `sf-audit-code`, `sf-audit-copywriting`, `sf-audit-seo`, `sf-help`, `sf-init`, `sf-repurpose`
  - >~5000 tokens (remaining high-risk bodies): `sf-audit`, `sf-audit-a11y`, `sf-audit-code`, `sf-audit-copy`, `sf-audit-copywriting`, `sf-audit-gtm`, `sf-audit-seo`, `sf-auth-debug`, `sf-enrich`, `sf-help`, `sf-init`, `sf-market-study`, `sf-prod`, `sf-redact`, `sf-repurpose`, `sf-spec`, `sf-start`
- Recommendation: open follow-up compaction chantier via `/sf-spec Compact ShipFlow Skill Instructions Phase 2` when priority allows.

## sf-verify Verification Notes (2026-05-16)

- Verification verdict: `verified`.
- Main-thread verification corrected two pilot skill references from legacy `specs/*.md` wording to canonical `shipflow_data/workflow/specs/*.md`.
- Checks rerun after correction:
  - `python3 tools/skill_budget_audit.py --skills-root skills --format markdown` passed with 0 hard violations, 0 warnings, 23 separate body-size risks, 6 bodies over 500 lines, and 17 bodies over about 5000 tokens.
  - `python3 tools/shipflow_metadata_lint.py shipflow_data/workflow/specs/compact-shipflow-skill-instructions.md skills/references/skill-instruction-layering.md skills/references/skill-context-budget.md shipflow_data/technical/skill-runtime-and-lifecycle.md skills/sf-docs/references/core-governance.md skills/sf-docs/references/mode-playbooks.md skills/sf-audit-design/references/audit-gates.md skills/sf-audit-design/references/audit-checklists.md skills/sf-verify/references/verification-gates.md` passed.
  - `tools/shipflow_sync_skills.sh --check --all` passed with `checked=122 ok=122 blocked=0`.
  - Focused `rg` checks confirmed trace/process labels, canonical paths, reporting contract, instruction layering, and canonical chantier spec paths in pilot skills.
- Fresh external docs verdict: `fresh-docs not needed`; this chantier changed local Markdown instruction architecture only.
- Bug gate: clear for this scope; no open high/critical bug file targets this compaction chantier.

## Open Questions

None. The pilot set is explicit, with an allowed fallback list if one pilot proves unsafe during implementation.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-05-16 08:06:03 UTC | sf-spec | GPT-5 Codex | Created spec from `sf-explore` report and local skill inventory audit | draft saved | `/sf-ready Compact ShipFlow Skill Instructions` |
| 2026-05-16 11:46:32 UTC | sf-ready | GPT-5 Codex | Evaluated structure, metadata, user-story fit, adverse/security risk, docs coherence, and execution clarity | ready | `/sf-start Compact ShipFlow Skill Instructions` |
| 2026-05-16 11:55:50 UTC | sf-start | GPT-5 Codex | Implemented layered compaction for pilot skills, added shared/local references, updated technical docs, and ran required validations | implemented | `/sf-verify Compact ShipFlow Skill Instructions` |
| 2026-05-16 12:00:23 UTC | sf-verify | GPT-5 Codex | Verified implementation against user story, success/error behavior, metadata, docs coherence, language doctrine, runtime visibility, and body-size proof | verified | `/sf-end Compact ShipFlow Skill Instructions` |

## Current Chantier Flow

- sf-spec: done, draft saved at `shipflow_data/workflow/specs/compact-shipflow-skill-instructions.md`
- sf-ready: ready
- sf-start: implemented
- sf-verify: verified
- sf-end: not launched
- sf-ship: not launched
- Next command: `/sf-end Compact ShipFlow Skill Instructions`
