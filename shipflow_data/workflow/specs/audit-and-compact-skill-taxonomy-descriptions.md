---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.3"
project: "shipflow"
created: "2026-05-16"
created_at: "2026-05-16 14:38:00 UTC"
updated: "2026-05-17"
updated_at: "2026-05-17 13:05:12 UTC"
status: ready
source_skill: sf-spec
source_model: "GPT-5 Codex"
scope: "skill-taxonomy-and-discovery-budget"
owner: "Diane"
user_story: "As the ShipFlow operator, I want the skill taxonomy analyzed and clarified before shortening descriptions, so skill routing becomes cleaner, less noisy, less duplicated, and easier to reason about."
confidence: medium
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - "skills/*/SKILL.md"
  - "skills/references/skill-context-budget.md"
  - "skills/references/skill-instruction-layering.md"
  - "skills/references/chantier-tracking.md"
  - "shipflow_data/technical/skill-runtime-and-lifecycle.md"
  - "tools/skill_budget_audit.py"
  - "tools/shipflow_sync_skills.sh"
depends_on:
  - artifact: "skills/references/skill-context-budget.md"
    artifact_version: "0.3.1"
    required_status: "draft"
  - artifact: "skills/references/skill-instruction-layering.md"
    artifact_version: "0.1.0"
    required_status: "draft"
  - artifact: "skills/references/chantier-tracking.md"
    artifact_version: "0.5.0"
    required_status: "draft"
  - artifact: "shipflow_data/technical/skill-runtime-and-lifecycle.md"
    artifact_version: "1.14.1"
    required_status: "reviewed"
supersedes: []
evidence:
  - "Current skill budget audit after instruction compaction: 61 skills, 0 hard violations, 0 warnings, 0 body-size token risks, absolute estimate 7988/8000, repo-relative estimate 6646/8000, average description length 70.7."
  - "Current description inventory: 61 descriptions, total 4310 description characters, longest descriptions range from 80 to 96 characters."
  - "User decision 2026-05-16: description compaction must follow an analysis of duplicated roles, skill efficiency, and system logic instead of direct wording edits."
  - "Current role inventory includes lifecycle, source-de-chantier, support-de-chantier, pilotage, and helper skills, with possible overlap across audit, content, design, maintenance, build, bug, and docs families."
  - "Local transcript /home/claude/docs_update_skill_bug.md shows a real sf-docs failure mode: a docs update was treated as successful after README/docs refresh, but it missed a higher-level documentation architecture/layout gate that should have been raised as P1."
  - "Local transcript /home/claude/sf-build-subagents-ex.md was inspected and contains no comparable actionable signal beyond its capture metadata."
  - "2026-05-17 sf-start created shipflow_data/workflow/audits/skill-taxonomy-description-audit-2026-05-17.md, edited 56 discovery descriptions, and reduced absolute discovery estimate to 6805/8000 with zero warnings."
  - "2026-05-17 sf-verify validated budget, runtime sync, metadata, role visibility, description uniqueness, and dependency coherence."
  - "2026-05-17 sf-ship full close finalized the chantier and prepared the verified work for push."
next_step: "None"
---

# Spec: Audit And Compact Skill Taxonomy Descriptions

## Title

Audit And Compact Skill Taxonomy Descriptions

## Status

ready

## User Story

As the ShipFlow operator, I want the skill taxonomy analyzed and clarified before shortening descriptions, so skill routing becomes cleaner, less noisy, less duplicated, and easier to reason about.

## Minimal Behavior Contract

When this chantier runs, ShipFlow must first produce a structured analysis of the full skill inventory: real role, declared role, overlap, duplication, merge/retire/rename candidates, descriptions that hurt routing, and observed failure modes where a skill routed too low or concluded too early. Only after that analysis may the chantier propose or apply low-risk description compaction. The expected result is a clearer and more discriminating skill system, not merely a lower character count. The easiest edge case to miss is shortening descriptions while preserving a confusing taxonomy, or removing/merging a skill without checking routes, references, public docs, runtime visibility, implicit usage, and observed failure modes.

## Success Behavior

- Preconditions: previous `SKILL.md` body compaction phases are shipped and the budget audit reports 0 body-size risks.
- Trigger: the operator runs `/sf-start` on this ready spec.
- User/operator result: the operator receives a clear family map, overlap analysis, role-confusion findings, recommended decisions, and proposed descriptions.
- System effect: low-risk descriptions become shorter and more discriminating; ambiguous roles are clarified by explicit decision; no skill is deleted, renamed, or merged without a migration plan and follow-up spec.
- Proof of success: `tools/skill_budget_audit.py` shows a measurable discovery-budget reduction; final descriptions remain short one-sentence routing triggers; critical roles remain routable; `tools/shipflow_sync_skills.sh --check --all` passes; changed docs and runtime links remain coherent.

## Error Behavior

- If the analysis reveals a risky merge, deletion, or rename, do not apply it in this chantier; record the recommendation and create or propose a separate spec.
- If two shortened descriptions become less distinguishable than before, verification fails until the distinction is restored.
- If a description loses its essential trigger words, verification fails.
- If a role clarification would weaken chantier tracking, source-de-chantier escalation, security, docs migration, or production/auth gates, stop and keep the existing behavior.
- If a delete/rename/fusion would break docs, public links, Claude/Codex runtime visibility, or references, stop and reopen scope.
- Must never happen: deleting a skill, changing a `name:`, renaming a skill directory, breaking an invocation, or changing a public route without an explicit migration spec.

## Problem

The previous chantier reduced instruction dilution by compacting long `SKILL.md` bodies. A different problem remains: the skill discovery inventory still contains many long or enumerative descriptions, and several skill-role boundaries look less clear now that the product model is better understood. A purely stylistic description edit would save characters, but it would not resolve duplicated responsibility or routing confusion.

A local user transcript confirms the risk with `sf-docs`: one run updated README/docs and passed local checks, but missed a higher-level Plot/ShipFlow documentation-layout noncompliance. That failure suggests some descriptions, roles, gates, or success criteria may push a skill to treat a task as a local refresh when it should audit, escalate, or recommend a migration-layout chantier.

## Solution

Run taxonomy analysis before broad editing. Classify all 61 skills by family, compare declared role to expected role, detect overlap, produce a decision matrix, then apply only low-risk description compactions in this chantier. High-risk changes such as merging, deleting, or renaming skills must remain recommendations or move to dedicated specs.

The analysis must include local failure-mode evidence from user-provided transcripts. For each relevant failure mode, identify whether the root issue is a broad description, wrong role, hidden gate, wrong master/specialist selection, missing stop condition, or success criterion set too low.

## Scope In

- Audit every `description:` in `skills/*/SKILL.md`.
- Audit declared role coherence: `lifecycle`, `source-de-chantier`, `support-de-chantier`, `pilotage`, and `helper`.
- Classify skill families:
  - lifecycle/master: `sf-build`, `sf-maintain`, `sf-design`, `sf-content`, `sf-deploy`, `sf-skill-build`
  - audit: `sf-audit*`, `sf-perf`, `sf-deps`, `sf-check`
  - bug/proof: `sf-bug`, `sf-fix`, `sf-test`, `sf-browser`, `sf-auth-debug`, `sf-prod`
  - content/docs: `sf-docs`, `sf-redact`, `sf-enrich`, `sf-repurpose`, `sf-research`, `sf-veille`, `sf-market-study`
  - pilotage/helper: `shipflow`, `continue`, `sf-context`, `sf-model`, `sf-help`, `sf-status`, `sf-resume`, `sf-tasks`, `sf-backlog`, `sf-priorities`, `sf-review`, `name`
- Produce a concise target description for each skill or family.
- Use local bad-execution examples as routing and gate test cases.
- Apply only low-risk description compactions and local role-clarity edits that do not change invocation or behavior.
- Document no-change decisions and future chantier candidates.
- Update internal technical docs and changelog if roles, categories, or description policy change.

## Scope Out

- Deleting a skill in this chantier.
- Renaming skill directories or `name:` fields.
- Merging skills or changing invocation keys.
- Changing detailed skill workflows, except for minimal gate wording required to preserve a low-risk description or clarify an already-declared role.
- Repeating the completed `SKILL.md` body compaction.
- Fixing the separate CLI menu navigation bug.

## Constraints

- Descriptions must be one short sentence, front-load trigger words, and avoid list-like catchalls.
- Descriptions must remain discriminating enough for automatic Codex/Claude routing.
- Preserve Agent Skills schema compatibility: stable `name`, present `description`, no `Args:` in descriptions.
- Character reduction is a secondary metric; routing clarity is the primary metric.
- Any deletion, merge, rename, invocation change, or role-policy change requires explicit decision and usually a separate spec.
- Chantiers roles (`Trace category`, `Process role`) must not change without justification, verification, and documentation updates.
- Internal contracts, execution notes, stable section headings, acceptance criteria, and validation rules must stay in English. User-facing final reports may remain in the user's active language.

## Dependencies

- `skills/references/skill-context-budget.md`: discovery-budget thresholds and description policy.
- `skills/references/skill-instruction-layering.md`: separation between activation contract and references.
- `skills/references/chantier-tracking.md`: current role/category matrix and source-de-chantier threshold.
- `shipflow_data/technical/skill-runtime-and-lifecycle.md`: technical context for skill families, entrypoints, and runtime visibility.
- Fresh external docs verdict: `fresh-docs not needed` for initial analysis because this chantier edits local ShipFlow artifacts. If implementation changes policy based on current Codex, Claude Code, Claude.ai, or Agent Skills external constraints beyond local references, check the current official docs before modifying policy.

## Invariants

- Lifecycle skills remain visibly routable and distinct from support/helper skills.
- Source-de-chantier skills retain chantier-potential escalation.
- Support/helper skills must not become ambiguous with lifecycle skills.
- Descriptions help skill selection; they do not summarize full workflows.
- References and runtime docs remain coherent with real roles.
- A skill that can detect architecture noncompliance must expose that gate early enough to avoid local-only success.
- No runtime visibility is broken for Claude or Codex skill installations.

## Links & Consequences

- `shipflow` depends on clear descriptions and role boundaries for routing.
- Claude/Codex runtime discovery depends on description budget and discriminating triggers.
- Public and internal documentation may reference skill names and promises; future merges/deletions require docs impact review.
- `sf-docs`, `sf-skill-build`, `shipflow`, and master lifecycle skills are likely consumers of any taxonomy clarification.
- This chantier may create follow-up specs for consolidation, but it must not silently execute consolidation.

## Documentation Coherence

- Update `CHANGELOG.md` when descriptions, role wording, or policy docs change.
- Update `shipflow_data/technical/skill-runtime-and-lifecycle.md` if taxonomy, families, routing rules, or role boundaries change.
- Update `skills/references/skill-context-budget.md` if description length targets or discovery-budget policy change.
- Update `skills/references/chantier-tracking.md` only if process roles or trace categories actually change.
- No public README/site update is required for internal description compaction alone. Public docs become in scope only if skill promises, names, or user-visible command guidance change.

## Edge Cases

- Two compacted descriptions become near synonyms, for example `sf-fix` vs `sf-bug` or `sf-test` vs `sf-browser`.
- A master skill and a support skill share the same trigger words and disturb routing.
- A description becomes too abstract to be selected.
- A candidate retire/merge skill has references, docs, habits, or implicit usage that the inventory missed.
- Audit specialists look too granular, but each still provides useful precision.
- A lower character count hides increased semantic confusion.
- `sf-docs` concludes `completed` after a local docs update when the correct result should be blocked audit, layout migration, or chantier potential.
- The analysis labels a role as confusing but does not say whether to keep the role, rewrite the description, change the gate, or create a future spec.

## Implementation Tasks

- [x] Generate a complete inventory of skills with `name`, description, description length, trace category, process role, line count, body token estimate, and proposed family.
- [x] Produce a decision matrix with one row per skill: `keep`, `shorten`, `clarify description`, `clarify role`, `merge candidate`, `retire candidate`, or `future spec`.
- [x] Analyze `/home/claude/docs_update_skill_bug.md` as a routing/gate failure mode for `sf-docs` and documentation-governance skills.
- [x] Record `/home/claude/sf-build-subagents-ex.md` as inspected and non-actionable unless new content appears before execution.
- [x] Identify overlapping skill pairs/families and state the recommended boundary for each.
- [x] Propose target descriptions with before/after character counts and trigger-word justification.
- [x] Apply only low-risk edits: shorter descriptions and local clarity wording that do not change invocation, workflow, or durable role semantics.
- [x] Create a list of high-risk decisions requiring separate user approval/specs for deletion, merge, rename, or role-policy changes.
- [x] Update internal docs/changelog when applied changes require it.
- [x] Run `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`.
- [x] Run `tools/shipflow_sync_skills.sh --check --all`.
- [x] Run targeted checks proving descriptions remain unique enough and chantier roles remain visible.

## Acceptance Criteria

- [x] A readable taxonomy analysis exists in the spec, a report, or a chantier-linked artifact.
- [x] Local transcript failure modes are classified and translated into routing, role, gate, or no-change requirements when relevant.
- [x] Every skill has an explicit decision: `keep`, `shorten`, `clarify`, `merge candidate`, `retire candidate`, or `future spec`.
- [x] Modified descriptions are shorter without losing essential trigger words.
- [x] Final descriptions remain distinguishable within their families.
- [x] Total description characters decrease measurably, with an indicative average target of `45-55` characters only if the analysis proves that target is safe.
- [x] `skill_budget_audit.py` remains at 0 hard violations, 0 warnings, and 0 body-size risks.
- [x] `shipflow_sync_skills.sh --check --all` passes.
- [x] No skill is deleted, renamed, or merged without a separate spec.

## Test Strategy

- Run the budget audit before and after edits and compare total description characters, average description length, absolute estimate, repo-relative estimate, and counts above 80/70/60/50 characters.
- Review the final descriptions by family and manually check whether each skill remains selectable from its trigger words.
- Re-run the `sf-docs update` vs `sf-docs migrate-layout/audit` transcript scenario as an adversarial routing case and confirm the final wording/gates make escalation more likely.
- Run focused `rg` checks on any touched `SKILL.md` files to confirm `Trace category`, `Process role`, report mode, and required references remain visible.
- Run `python3 tools/shipflow_metadata_lint.py` on any changed specs or docs with ShipFlow frontmatter.
- Run `tools/shipflow_sync_skills.sh --check --all` after edits.

## Risks

- Over-shortening descriptions can degrade automatic skill selection.
- Historical skill names may carry user expectations not visible in descriptions.
- Some overlap is intentional: master vs specialist, lifecycle vs support, source vs proof.
- Poorly scoped consolidation can break user habits, docs, or runtime links.
- Changing only descriptions may not fix a failure mode if the real defect is a hidden gate or weak stop condition.

## Execution Notes

- Read first:
  - `skills/references/skill-context-budget.md`
  - `skills/references/skill-instruction-layering.md`
  - `skills/references/chantier-tracking.md`
  - `shipflow_data/technical/skill-runtime-and-lifecycle.md`
  - `/home/claude/docs_update_skill_bug.md`
- Generate the inventory mechanically from `skills/*/SKILL.md`; do not hand-build it from memory.
- Treat deletion, merge, rename, invocation-key change, and trace/process-role change as out of scope unless the result is only a documented recommendation.
- Keep shared files sequential: `skills/references/chantier-tracking.md`, `skills/references/skill-context-budget.md`, `shipflow_data/technical/skill-runtime-and-lifecycle.md`, and `CHANGELOG.md`.
- Before editing descriptions, write or stage the taxonomy findings in a durable artifact, either this spec, a linked report under `shipflow_data/workflow/audits/`, or a clearly named local working artifact that is committed with the chantier.
- Stop and route back to the user if the analysis recommends deleting, merging, or renaming skills before description edits can be made safely.
- Stop and route back to `/sf-ready` if new evidence implies a role-policy change rather than a wording change.
- Validation commands:
  - `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
  - `tools/shipflow_sync_skills.sh --check --all`
  - `python3 tools/shipflow_metadata_lint.py <changed-frontmatter-artifacts>`
  - focused `rg` checks for changed skill descriptions and role labels

## Open Questions

None.

## Skill Run History

| Timestamp | Skill | Model | Action | Result | Next |
|---|---|---|---|---|---|
| 2026-05-16 14:38:00 UTC | sf-spec | GPT-5 Codex | Created taxonomy-first skill description compaction spec | draft | /sf-ready shipflow_data/workflow/specs/audit-and-compact-skill-taxonomy-descriptions.md |
| 2026-05-16 14:46:00 UTC | sf-spec | GPT-5 Codex | Integrated local transcript evidence about docs skill failure modes into the spec | draft | /sf-ready shipflow_data/workflow/specs/audit-and-compact-skill-taxonomy-descriptions.md |
| 2026-05-16 14:52:00 UTC | sf-ready | GPT-5 Codex | Evaluated readiness and found required structure and language-doctrine gaps | not ready | /sf-spec refine audit-and-compact-skill-taxonomy-descriptions readiness gaps |
| 2026-05-16 15:02:00 UTC | sf-spec | GPT-5 Codex | Rewrote the spec in English, added Test Strategy, Execution Notes, and Open Questions, and tightened low-risk change boundaries | draft | /sf-ready shipflow_data/workflow/specs/audit-and-compact-skill-taxonomy-descriptions.md |
| 2026-05-17 00:00:00 UTC | sf-ready | GPT-5 Codex | Verified structure, metadata, user-story alignment, execution notes, language doctrine, adversarial gates, and security scope | ready | /sf-start Audit And Compact Skill Taxonomy Descriptions |
| 2026-05-17 12:29:44 UTC | sf-start | GPT-5 Codex | Audited 61-skill taxonomy, created audit artifact, compacted 56 descriptions, and updated lifecycle docs/changelog | implemented | /sf-verify Audit And Compact Skill Taxonomy Descriptions |
| 2026-05-17 12:44:32 UTC | sf-verify | GPT-5 Codex | Verified skill taxonomy descriptions, runtime visibility, metadata, chantier roles, and dependency coherence; fixed stale dependency metadata | verified | /sf-end Audit And Compact Skill Taxonomy Descriptions |
| 2026-05-17 13:05:12 UTC | sf-end | GPT-5 Codex | Closed the verified taxonomy-description chantier and confirmed changelog/task bookkeeping | closed | /sf-ship end |
| 2026-05-17 13:05:12 UTC | sf-ship | GPT-5 Codex | Full close and ship: prepared checked taxonomy-description changes for commit and push | shipped | None |

## Current Chantier Flow

- sf-explore: completed
- sf-spec: ready
- sf-ready: ready
- sf-start: implemented
- sf-verify: verified
- sf-end: closed
- sf-ship: shipped
- Next step: None
