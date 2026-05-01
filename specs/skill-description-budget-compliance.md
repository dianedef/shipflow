---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "shipflow"
created: "2026-04-30"
created_at: "2026-04-30 22:58:17 UTC"
updated: "2026-05-01"
updated_at: "2026-05-01 13:18:50 UTC"
status: ready
source_skill: sf-spec
source_model: "GPT-5 Codex"
scope: audit-fix
owner: "Diane"
user_story: "As a ShipFlow user running many Codex and Claude Code skills, I want every current skill to use a compact one-sentence discovery description and valid name/path metadata, so skill discovery stays reliable and does not trigger context-budget warnings."
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - "skills/"
  - "skills/*/SKILL.md"
  - "skills/references/skill-context-budget.md"
  - "GUIDELINES.md"
  - "ARCHITECTURE.md"
  - "tools/"
  - "Codex"
  - "Claude Code"
depends_on:
  - artifact: "GUIDELINES.md"
    artifact_version: "1.2.0"
    required_status: reviewed
  - artifact: "ARCHITECTURE.md"
    artifact_version: "1.0.0"
    required_status: reviewed
  - artifact: "skills/references/skill-context-budget.md"
    artifact_version: "0.2.0"
    required_status: draft
supersedes: []
evidence:
  - "User request 2026-04-30: create a spec to enforce one-sentence skill descriptions and verify all current skills at once."
  - "Codex docs 2026-04-30: initial skill list includes name, description, and file path, capped at roughly 2% of context or 8,000 characters when context is unknown."
  - "Claude Code docs 2026-04-30: description helps automatic loading; combined description and when_to_use is truncated at 1,536 characters; full skill content loads only when invoked."
  - "Claude.ai docs 2026-04-30: skill name uses lowercase letters, numbers, and hyphens, max 64 chars, and must match directory name; uploaded descriptions are limited to 200 characters."
  - "Local inventory 2026-04-30: 49 current SKILL.md files, 22 frontmatter descriptions over 200 characters, 0 name/directory issues, about 12.6k estimated name+description+path characters."
  - "Local inventory 2026-04-30: path plus name overhead leaves about 5.1k characters for descriptions under an 8k budget, about 104 characters average per skill."
  - "Local inventory 2026-04-30: 5 SKILL.md files exceed 500 lines."
  - "Implementation 2026-05-01: created tools/skill_budget_audit.py and wired sf-docs audit for skill-related docs work."
  - "User request 2026-05-01: confirm all official skill limits and ensure validation exists for them."
  - "sf-ready 2026-05-01: rechecked official Codex, Claude Code, Claude.ai, and Agent Skills documentation before readiness verdict."
  - "User decision 2026-05-01: keep skill budget compliance scoped to skill documentation and skill refresh workflows, not broad agent context."
next_step: "/sf-ship Skill Description Budget Compliance"
---

# Spec: Skill Description Budget Compliance

## Title

Skill Description Budget Compliance

## Status

ready

## User Story

As a ShipFlow user running many Codex and Claude Code skills, I want every current skill to use a compact one-sentence discovery description and valid name/path metadata, so skill discovery stays reliable and does not trigger context-budget warnings.

## Minimal Behavior Contract

When ShipFlow maintains or adds skills, the system must be able to audit all current `skills/*/SKILL.md` files in one command, report whether every skill has a valid `name`, valid directory/path shape, and one-sentence `description`, then guide a batch rewrite that reduces the aggregate startup discovery index below the safe 8,000-character baseline. If the audit finds a violation, it must identify the exact skill and field, explain the budget impact, and block a "done" verdict until the description, name/path metadata, or documented exception is fixed. The easy edge case to miss is that a description under 200 characters can still be too verbose if the average across 49 skills exceeds about 104 characters or if trigger keywords are pushed after truncation.

## Success Behavior

- Preconditions: ShipFlow has existing skills in `skills/*/SKILL.md`, a reference policy in `skills/references/skill-context-budget.md`, and metadata conventions in `GUIDELINES.md`.
- Trigger: a maintainer runs the new skill budget audit command or starts the implementation chantier for this spec.
- User/operator result: the report lists all compliant skills, all violations, aggregate index size, average description length, name/path status, and recommended batches for remediation.
- System effect: skill frontmatter descriptions become one sentence, concise, trigger-focused, and below the ShipFlow hard maximum; argument details move to `argument-hint` or the skill body.
- Success proof: the audit exits cleanly, shows zero hard violations, and estimates `name + description + path` under 8,000 characters for the current skill set.
- Silent success: not allowed; the final verification must print the aggregate budget and per-category counts.

## Error Behavior

- Expected failures: malformed frontmatter, missing `name`, missing `description`, description over one sentence, description over 200 characters, vague trigger words, name not matching directory, name over 64 characters, invalid name characters, path too deep or unnecessarily long, aggregate budget still over 8,000 characters.
- User/operator response: the audit report must show each failing path, field, current value length, reason, and suggested remediation category.
- System effect: no skill body should be rewritten by the audit itself; edits happen in explicit implementation tasks or assigned worker batches.
- Must never happen: broad body rewrites, skill deletion to hide budget pressure, renaming public skill commands without explicit approval, dropping trigger keywords to satisfy character count, or sending one agent the whole skill corpus with vague instructions.
- Silent failure: not allowed; if a parser cannot confidently read frontmatter, that skill is a hard violation until reviewed manually.

## Problem

ShipFlow currently has many always-available skills. Codex and Claude Code do not load every skill body at startup, but they do load a discovery index. Codex explicitly counts each skill's name, description, and file path in the initial list. Claude Code uses the description to decide automatic loading and also has truncation behavior for description-related metadata. Long descriptions therefore consume shared startup budget and can cause warnings, truncation, omitted skills, or weak automatic matching.

The local ShipFlow inventory already exceeds the fallback budget: 49 current `SKILL.md` files produce about 12.6k estimated initial-list characters, with 22 frontmatter descriptions over 200 characters. The first fix should be description compaction and automated validation, not deleting skills.

## Solution

Define a strict ShipFlow skill metadata contract, implement a deterministic whole-tree audit command, then rewrite current skill frontmatter descriptions in small disjoint batches. The contract requires one sentence maximum in `description`, a target average near 100 characters, a hard 200-character maximum, valid `name` and directory alignment, and explicit path budget awareness. Future implementation should use worker agents only after the audit script exists, with each worker owning a small list of files and no shared write surface.

## Scope In

- Formalize one-sentence `description` rules for ShipFlow skills.
- Formalize `name` constraints: lowercase letters, numbers, hyphens, maximum 64 characters, and match the containing skill directory.
- Formalize path constraints: keep skills at `skills/<short-skill-name>/SKILL.md`, avoid unnecessary nesting, and treat path length as part of the discovery budget.
- Update `skills/references/skill-context-budget.md` with the stricter policy.
- Add or update a deterministic audit tool that verifies every current skill in one run.
- Generate an audit report that supports safe batch assignment to worker agents.
- Rewrite existing skill descriptions to satisfy the contract.
- Preserve existing skill names unless a hard name/path violation exists and the user approves the rename.
- Validate aggregate budget after all edits.

## Scope Out

- Deleting skills to reduce budget.
- Disabling rarely used skills without a separate user decision.
- Renaming public skill commands purely for style.
- Rewriting full `SKILL.md` bodies except when moving argument text out of descriptions requires a small local adjustment.
- Refactoring long `SKILL.md` bodies over 500 lines in the first pass, except reporting them as follow-up.
- Changing Claude/Codex runtime configuration such as `SLASH_COMMAND_TOOL_CHAR_BUDGET`.
- Modifying unrelated specs, trackers, or project docs outside the files listed in this spec.

## Constraints

- `description` is a routing signal, not documentation.
- `description` must be one sentence maximum.
- `description` should target 80 to 120 characters for the current 49-skill set; 140 is a warning threshold, and 200 is a hard maximum.
- The average description length should stay at or below 100 to 104 characters while the skill count remains near 49.
- Do not include `Args:` in descriptions.
- Do not place argument syntax in `description`; use `argument-hint` and the skill body.
- `description + when_to_use` must stay under the Claude Code listing cap of 1,536 characters.
- `compatibility`, if present, must stay under 500 characters.
- Front-load natural trigger words because both Codex and Claude Code can shorten descriptions.
- Avoid multi-line YAML descriptions.
- Keep `name` stable unless invalid, because names are user-facing invocations.
- `name` must not start or end with `-`, and must not contain `--`.
- Keep path changes rare, because paths may be referenced by docs, plugins, symlinks, or shell helpers.
- Worker agents must receive bounded file ownership and must not edit files outside their assigned batch.

## Dependencies

- Local docs: `skills/references/skill-context-budget.md`, `GUIDELINES.md`, `ARCHITECTURE.md`.
- Local skills: every `skills/*/SKILL.md`.
- Local tooling: `tools/`, especially the existing pattern of `tools/shipflow_metadata_lint.py`.
- External docs checked 2026-05-01:
  - Codex skills: https://developers.openai.com/codex/skills
  - Claude Code skills: https://code.claude.com/docs/en/skills
  - Claude.ai skill creation: https://claude.com/docs/skills/how-to
  - Agent Skills specification: https://agentskills.io/specification
- Fresh external docs verdict: fresh-docs checked.

## Invariants

- The audit source of truth is the actual frontmatter in each `skills/*/SKILL.md`.
- The full skill body remains available by progressive disclosure when a skill is invoked.
- The discovery index must remain compact enough for Codex and Claude Code to select the right skill.
- Skill trigger accuracy matters more than aesthetic wording.
- A concise but ambiguous description is a failure.
- A clear but overlong description is also a failure.
- Manual-only or dangerous skills may use `disable-model-invocation: true`, but that should be a deliberate policy decision, not a budget workaround hidden inside this remediation.

## Links & Consequences

- Codex consequence: over-budget skill lists can be shortened or partially omitted, making implicit `$skill` matching less reliable.
- Claude Code consequence: descriptions can be shortened to fit the character budget, which can remove trigger keywords.
- Claude.ai consequence: any skill intended for upload must keep `description` under 200 characters and valid name/directory rules.
- ShipFlow workflow consequence: future skill creation must run the audit before being considered done.
- Agent execution consequence: after the audit tool exists, agents can be assigned disjoint batches without loading every skill into every agent.
- Documentation consequence: `sf-help`, `skill-context-budget.md`, and any future skill creation guidance should point to the same contract.

## Documentation Coherence

- Update `skills/references/skill-context-budget.md` to add the one-sentence rule, average budget target, name/path constraints, and batch remediation policy.
- Do not add broad skill-budget reminders to `AGENT.md`, `CONTEXT.md`, or `GUIDELINES.md`; keep the durable rule in `skill-context-budget.md`, `sf-docs`, `sf-skills-refresh`, and the audit script.
- Add audit command usage to the reference doc, not to every skill.
- Mention the remediation in `CHANGELOG.md` only during `/sf-end` or `/sf-ship`, not inside this spec.
- Do not modify operational trackers as part of this spec.

## Edge Cases

- A description has one period but contains two independent clauses joined by semicolon: allowed only if it still reads as one sentence and remains clear.
- A description has no punctuation: allowed if it is clear, one sentence, and within length limits.
- A description is under 200 characters but starts with generic words like "Manage", "Help", or "Use when": warn if trigger words are weak.
- A skill has `disable-model-invocation: true`: still validate name, path, description shape, and length unless the future audit explicitly excludes it with a documented reason.
- A skill has a body line that starts with `description:` outside frontmatter: the audit must ignore it.
- A skill directory has a long absolute prefix because of the user's machine path: do not try to solve that by renaming core skills; calculate both absolute and repo-relative estimates if useful.
- Two workers propose conflicting wording for related audit skills: the integrator should normalize the family after batches return.
- The aggregate remains above 8,000 after all hard violations are fixed: move from 80-120 target to a stricter average target or consider a separate decision about disabling niche skills.

## Implementation Tasks

- [x] Task 1: Update the skill budget reference contract
  - File: `skills/references/skill-context-budget.md`
  - Action: Add the one-sentence description rule, target 80-120 characters, warning above 140, hard fail above 200, average target around 100-104 for the current 49-skill set, and explicit `name`/path constraints.
  - User story link: Establishes the durable rule every future skill must follow.
  - Depends on: None
  - Validate with: `rg -n "one sentence|80 to 120|name|path|104|200" skills/references/skill-context-budget.md`
  - Notes: Keep the reference concise; detailed examples can live in a small section only.

- [x] Task 2: Create the whole-tree audit tool
  - File: `tools/skill_budget_audit.py`
  - Action: Implement a deterministic audit using standard-library parsing of frontmatter for every `skills/*/SKILL.md`.
  - User story link: Allows verifying all current skills at once instead of manually inspecting 49 files.
  - Depends on: Task 1
  - Validate with: `tools/skill_budget_audit.py --skills-root skills`
  - Notes: It must ignore `description:` outside frontmatter, print aggregate absolute and repo-relative estimates when possible, and exit non-zero on hard violations.

- [x] Task 3: Define audit output for agent batching
  - File: `tools/skill_budget_audit.py`
  - Action: Add output columns or a `--format markdown` mode with path, name, description length, sentence count, violation category, and suggested batch.
  - User story link: Prevents overloading worker agents with the full skill corpus.
  - Depends on: Task 2
  - Validate with: `tools/skill_budget_audit.py --skills-root skills --format markdown`
  - Notes: Batches should be disjoint and small, around 6 to 10 skills per worker.

- [x] Task 4: Run the baseline audit and save the result
  - File: `specs/skill-description-budget-compliance.md`
  - Action: Append the exact baseline command and summary to `Skill Run History` or an implementation note during `sf-start`.
  - User story link: Gives workers a measured starting point and a shared target.
  - Depends on: Task 3
  - Validate with: `tools/skill_budget_audit.py --skills-root skills --format markdown`
  - Notes: Do not paste large per-skill output into the spec unless needed; prefer a compact summary and artifact path if a report file is created.

- [x] Task 5: Wire skill budget audit into sf-docs
  - File: `skills/sf-docs/SKILL.md`
  - Action: Add `SKILL BUDGET COMPLIANCE` to audit reports and require `sf-docs audit` / silent update audits to run `tools/skill_budget_audit.py` only when the docs request touches skills, skill discovery, or Codex/Claude Code skill compliance.
  - User story link: Makes future documentation audits catch skill discovery budget regressions.
  - Depends on: Tasks 2-4
  - Validate with: `rg -n "skill_budget_audit|SKILL BUDGET COMPLIANCE" skills/sf-docs/SKILL.md`
  - Notes: `sf-docs` orchestrates the check; the Python script owns deterministic validation.

- [x] Task 6: Rewrite high-risk descriptions first
  - File: `skills/continue/SKILL.md`, `skills/sf-audit-components/SKILL.md`, `skills/sf-audit/SKILL.md`, `skills/sf-audit-code/SKILL.md`, `skills/sf-design-playground/SKILL.md`, `skills/sf-auth-debug/SKILL.md`, `skills/sf-ready/SKILL.md`, `skills/sf-audit-design-tokens/SKILL.md`, `skills/sf-resume/SKILL.md`, `skills/sf-docs/SKILL.md`, `skills/sf-spec/SKILL.md`, `skills/sf-audit-copywriting/SKILL.md`, `skills/sf-audit-design/SKILL.md`, `skills/sf-test/SKILL.md`, `skills/sf-audit-a11y/SKILL.md`, `skills/sf-context/SKILL.md`, `skills/sf-repurpose/SKILL.md`, `skills/sf-redact/SKILL.md`, `skills/sf-skills-refresh/SKILL.md`, `skills/sf-veille/SKILL.md`, `skills/sf-verify/SKILL.md`, `skills/sf-model/SKILL.md`
  - Action: Replace each over-200-character description with one concise sentence and keep arguments in `argument-hint`.
  - User story link: Removes the largest budget violations.
  - Depends on: Task 4
  - Validate with: `tools/skill_budget_audit.py --skills-root skills`
  - Notes: Split this task across worker batches; each worker owns only assigned files and does not edit shared docs or tools.

- [x] Task 7: Rewrite remaining weak or multi-sentence descriptions
  - File: `skills/*/SKILL.md`
  - Action: Use the audit report to update descriptions that pass the hard length limit but still include `Args:`, multiple sentences, weak trigger terms, or unnecessary detail.
  - User story link: Keeps automatic skill matching accurate after compaction.
  - Depends on: Task 6
  - Validate with: `tools/skill_budget_audit.py --skills-root skills --strict`
  - Notes: Preserve specialized trigger keywords, especially for audit, prod, auth, docs, spec, and ship workflows.

- [x] Task 8: Check `name` and path compliance
  - File: `skills/*/SKILL.md`
  - Action: Verify every `name` matches its directory, uses only lowercase letters/numbers/hyphens, is at most 64 characters, and has no unnecessary nested path.
  - User story link: Ensures name and path metadata do not waste budget or break invocation.
  - Depends on: Task 2
  - Validate with: `tools/skill_budget_audit.py --skills-root skills --check-names --check-paths`
  - Notes: Current inventory shows no name/directory issues, so expected result is verification, not renaming.

- [x] Task 9: Report long SKILL.md bodies as follow-up
  - File: `skills/sf-audit-design/SKILL.md`, `skills/sf-audit-code/SKILL.md`, `skills/sf-docs/SKILL.md`, `skills/sf-audit-copywriting/SKILL.md`, `skills/sf-init/SKILL.md`
  - Action: Report that these files exceed 500 lines and recommend a separate reference-splitting chantier if needed.
  - User story link: Keeps the current chantier focused on discovery budget while preserving Claude Code body-size guidance.
  - Depends on: Task 2
  - Validate with: `find skills -mindepth 2 -maxdepth 2 -name SKILL.md -print0 | xargs -0 wc -l | awk '$1>500{print}'`
  - Notes: Do not refactor these bodies in this chantier unless description work is complete and risk remains low.

- [x] Task 10: Final aggregate validation
  - File: `tools/skill_budget_audit.py`, `skills/*/SKILL.md`
  - Action: Run the audit after all batches are integrated and verify zero hard violations, aggregate under 8,000 characters, and average description length within target.
  - User story link: Proves the warning condition has been addressed.
  - Depends on: Tasks 6-8
  - Validate with: `tools/skill_budget_audit.py --skills-root skills --strict`
  - Notes: If the aggregate remains high, do not declare success; tighten descriptions or open a separate decision about disabling niche skills.

- [x] Task 11: Update implementation history and docs closeout
  - File: `specs/skill-description-budget-compliance.md`, optional `CHANGELOG.md`
  - Action: Record the audit result and changed file count in `Skill Run History`; leave changelog updates for `/sf-end` or `/sf-ship`.
  - User story link: Keeps the chantier trace durable.
  - Depends on: Task 10
  - Validate with: `rg -n "Skill Run History|skill budget|description" specs/skill-description-budget-compliance.md`
  - Notes: Do not edit `TASKS.md`, `AUDIT_LOG.md`, or `PROJECTS.md` from this spec flow.

## Acceptance Criteria

- [ ] CA 1: Given the current ShipFlow skills directory, when `tools/skill_budget_audit.py --skills-root skills --strict` runs, then every `SKILL.md` frontmatter description is one sentence maximum.
- [ ] CA 2: Given the current ShipFlow skills directory, when the audit runs, then no frontmatter description contains `Args:` or uses argument syntax as routing text.
- [ ] CA 3: Given the current ShipFlow skills directory, when the audit runs, then no description exceeds 200 characters and descriptions above 140 are reported as warnings.
- [ ] CA 4: Given the current 49-skill set, when the audit estimates the discovery index, then `name + description + path` is below 8,000 characters or the command exits non-zero with remediation guidance.
- [ ] CA 5: Given any current skill, when the audit checks names, then the skill `name` matches the directory, uses lowercase letters/numbers/hyphens only, and is at most 64 characters.
- [ ] CA 6: Given any current skill, when the audit checks paths, then the path follows `skills/<skill-name>/SKILL.md` and path budget contribution is included in the aggregate estimate.
- [ ] CA 7: Given worker batches are used, when agents edit descriptions, then each worker modifies only its assigned `SKILL.md` files and does not touch shared docs or tools.
- [ ] CA 8: Given a skill description is compacted, when the skill is reviewed, then its trigger keywords still identify the workflow more clearly than generic verbs like "manage" or "help".
- [ ] CA 9: Given all edits are complete, when the final report is produced, then it lists count of skills checked, hard violations, warnings, aggregate characters, average description length, and any follow-up for long skill bodies.
- [ ] CA 10: Given `sf-docs audit` or `sf-docs update` touches skills, skill discovery, or Codex/Claude Code skill compliance, when `$SHIPFLOW_ROOT/tools/skill_budget_audit.py` exists, then the audit report includes `SKILL BUDGET COMPLIANCE` and the script result.
- [ ] CA 11: Given a `SKILL.md` body exceeds 500 lines, when the audit runs, then it is reported as a separate risk and does not block initial discovery compliance by itself.
- [ ] CA 12: Given a skill has `when_to_use`, when the audit runs, then `description + when_to_use` is verified below 1,536 characters.
- [ ] CA 13: Given a skill has `compatibility`, when the audit runs, then it is verified below 500 characters.
- [ ] CA 14: Given a skill name starts/ends with `-` or contains `--`, when the audit runs, then it fails name validation.
- [ ] CA 15: Given a skill body is estimated above 5000 tokens, when the audit runs, then it is reported as a separate progressive-disclosure risk.
- [ ] CA 16: Given the Agent Skills specification allows `description` up to 1024 characters, when the audit runs, then the standard limit is validated even though ShipFlow's 200-character portability limit is stricter.

## Test Strategy

- Unit-like check: run `tools/skill_budget_audit.py --skills-root skills --strict` and verify exit code.
- Parser check: include a fixture or local sanity case where `description:` appears outside frontmatter and is ignored.
- Regression check: run `rg -n '^description: .*Args:' skills/*/SKILL.md`.
- Name check: run the audit name validation and confirm zero mismatches.
- Path check: run the audit path validation and confirm no unnecessary nesting.
- Manual review: sample each skill family after compaction to ensure descriptions remain discriminative.
- Metadata check: run `/home/ubuntu/shipflow/tools/shipflow_metadata_lint.py specs/skill-description-budget-compliance.md skills/references/skill-context-budget.md GUIDELINES.md` if those files are touched.

## Risks

- Overcompression could make descriptions too vague and reduce automatic invocation quality.
- Renaming skills would break user muscle memory and references; avoid unless invalid.
- Agents could duplicate or conflict if they edit overlapping files; use disjoint ownership.
- A strict average budget can become stale if the number of installed skills changes; the audit must compute the current target dynamically.
- External tool behavior can change; keep the source links and re-check docs before changing the policy.
- Long `SKILL.md` bodies remain a separate context risk after invocation and compaction; report but do not overload this chantier.

## Security Review

Security impact: none, because this chantier only reads and rewrites local ShipFlow skill metadata and documentation, does not handle auth, tenant data, payments, uploads, secrets, or external write APIs, and the audit script prints metadata summaries rather than full skill bodies.

Implementation safety constraints:

- Do not paste full `SKILL.md` bodies into agent prompts; send only assigned paths and the compact policy.
- Do not run the audit on secret folders or arbitrary user data; keep `--skills-root` scoped to ShipFlow skills.
- Do not delete, rename, or disable skills as a hidden budget workaround.
- Do not hardcode tokens, API keys, credentials, or private deployment data in any skill description, reference, script, or report.

## Execution Notes

- Read first: `skills/references/skill-context-budget.md`, `GUIDELINES.md`, `ARCHITECTURE.md`, and this spec.
- Implement first: the audit script, because it creates a shared truth and prevents agent guesswork.
- After the audit exists, assign workers by disjoint batches of 6 to 10 `SKILL.md` files, grouped by family when possible: audit skills, lifecycle skills, ops/debug skills, content/docs skills, helper/pilotage skills.
- Each worker prompt should include the policy summary and assigned paths only, not the whole skill tree.
- Shared-write ownership: one local integrator owns `tools/skill_budget_audit.py`, `skills/references/skill-context-budget.md`, and the spec history; workers own only assigned `SKILL.md` files.
- Do not use agents for the immediate blocking task of creating or validating the audit script if the next step depends on that script.
- Stop condition: if the audit parser cannot parse frontmatter reliably, pause description edits and fix the parser first.
- Stop condition: if any proposed rename is needed, stop and ask for explicit approval.
- Fresh-docs checked: Codex, Claude Code, and Claude.ai docs were checked on 2026-04-30.

## Open Questions

None for the spec. The user has already decided to formalize the constraint and likely shorten descriptions; implementation should proceed through `/sf-ready` before editing current skills.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-04-30 22:58:17 UTC | sf-spec | GPT-5 Codex | Created spec for skill description budget compliance and all-skill audit remediation | Draft saved | /sf-ready Skill Description Budget Compliance |
| 2026-05-01 05:14:15 UTC | sf-docs | GPT-5 Codex | Added skill budget audit script, wired sf-docs audit, and ran baseline | Baseline found 49 skills, 94 hard violations, 27 warnings, 12604 absolute estimate | Rewrite skill descriptions in disjoint batches |
| 2026-05-01 05:25:04 UTC | sf-spec | GPT-5 Codex | Updated spec to explicitly track sf-docs audit wiring as a completed implementation task | Spec stays draft with remaining description rewrite tasks | /sf-ready Skill Description Budget Compliance |
| 2026-05-01 05:27:41 UTC | manual alignment | GPT-5 Codex | Aligned audit wording with final checklist: no `Args:` anywhere and warning only above 140 chars | Script and spec constraints updated | Re-run skill budget audit |
| 2026-05-01 05:31:00 UTC | manual alignment | GPT-5 Codex | Split `SKILL.md` body-size findings into separate risks instead of blocking warnings | Script and acceptance criteria updated | Re-run strict audit after description rewrites |
| 2026-05-01 05:35:56 UTC | manual alignment | GPT-5 Codex | Added missing official validations for `when_to_use`, `compatibility`, name hyphen rules, and body token risk | Script, reference, and acceptance criteria updated | Re-run skill budget audit |
| 2026-05-01 06:04:53 UTC | sf-spec | GPT-5 Codex | Updated spec to explicitly cite Agent Skills specification and standard `description <= 1024` validation | Existing chantier remains draft with validation coverage clarified | /sf-ready Skill Description Budget Compliance |
| 2026-05-01 06:16:32 UTC | sf-ship | GPT-5 Codex | Shipped quick commit for sf-prod log collection, sf-docs skill-budget audit wiring, reference docs, spec, and audit tool | Shipped with known remaining description remediation tasks | /sf-ready Skill Description Budget Compliance |
| 2026-05-01 06:23:35 UTC | sf-ready | GPT-5 Codex | Evaluated readiness, rechecked official external docs, and recorded explicit security review | Ready for remaining description remediation implementation | /sf-start Skill Description Budget Compliance |
| 2026-05-01 06:37:27 UTC | sf-start | GPT-5 Codex | Compacted 49 skill descriptions and ran strict budget validation | Implemented: 0 hard violations, 0 warnings, 7230 absolute estimate, 88.4 average description length; long bodies remain separate risks | /sf-verify Skill Description Budget Compliance |
| 2026-05-01 12:37:19 UTC | sf-docs | GPT-5 Codex | Scoped skill budget compliance to skill docs and skill refresh workflows, and kept broad agent context files out of the rule | Verified: no global reminders in README/AGENT/CONTEXT/GUIDELINES; strict audit still passes | /sf-verify Skill Description Budget Compliance |
| 2026-05-01 13:04:56 UTC | sf-verify | GPT-5 Codex | Verified skill budget compliance against the ready spec, official docs, audit tooling, metadata, and chantier tracking rules | Verified: strict audit passes with 49 skills, 0 hard violations, 0 warnings, 7230 absolute estimate, 88.4 average description length; only separate long-body risks remain | /sf-end Skill Description Budget Compliance |
| 2026-05-01 13:18:50 UTC | sf-end | GPT-5 Codex | Closed the skill description budget compliance chantier and recorded tracker/changelog closeout | Closed: audit-backed discovery budget compliance is verified; remaining long skill bodies are separate follow-up risk | /sf-ship Skill Description Budget Compliance |

## Current Chantier Flow

- sf-spec: done, spec saved in `specs/skill-description-budget-compliance.md`
- sf-ready: ready
- sf-start: implemented
- sf-verify: verified
- sf-end: closed
- sf-ship: shipped quick commit for audit tooling and documentation; final closeout not shipped

Next command:

```bash
/sf-ship Skill Description Budget Compliance
```
