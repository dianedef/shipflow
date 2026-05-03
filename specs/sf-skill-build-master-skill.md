---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.1"
project: "shipflow"
created: "2026-05-02"
created_at: "2026-05-02 15:22:13 UTC"
updated: "2026-05-03"
updated_at: "2026-05-03 04:16:07 UTC"
status: ready
source_skill: sf-spec
source_model: "GPT-5 Codex"
scope: "feature"
owner: "Diane"
user_story: "As a ShipFlow maintainer creating or changing skills, I want one master skill to orchestrate the skill lifecycle from spec through SKILL.md edits, refresh, budget audit, verification, public documentation, and ship, so ShipFlow skills stay product-coherent, technically safe, discoverable, and publicly documented."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - "skills/sf-skill-build/SKILL.md"
  - "skills/*/SKILL.md"
  - "skills/sf-spec/SKILL.md"
  - "skills/sf-skills-refresh/SKILL.md"
  - "skills/sf-help/SKILL.md"
  - "skills/sf-docs/SKILL.md"
  - "skills/sf-verify/SKILL.md"
  - "skills/sf-ship/SKILL.md"
  - "skills/references/canonical-paths.md"
  - "skills/references/chantier-tracking.md"
  - "skills/references/skill-context-budget.md"
  - "tools/skill_budget_audit.py"
  - "tools/shipflow_metadata_lint.py"
  - "docs/technical/skill-runtime-and-lifecycle.md"
  - "docs/technical/code-docs-map.md"
  - "docs/technical/public-site-and-content-runtime.md"
  - "CONTENT_MAP.md"
  - "docs/editorial/"
  - "site/src/content.config.ts"
  - "site/src/content/skills/"
  - "site/src/pages/skills/index.astro"
  - "site/src/pages/skills/[slug].astro"
  - "README.md"
  - "shipflow-spec-driven-workflow.md"
depends_on:
  - artifact: "BUSINESS.md"
    artifact_version: "1.1.0"
    required_status: "reviewed"
  - artifact: "PRODUCT.md"
    artifact_version: "1.1.0"
    required_status: "reviewed"
  - artifact: "BRANDING.md"
    artifact_version: "1.0.0"
    required_status: "reviewed"
  - artifact: "GTM.md"
    artifact_version: "1.1.0"
    required_status: "reviewed"
  - artifact: "GUIDELINES.md"
    artifact_version: "1.3.0"
    required_status: "reviewed"
  - artifact: "AGENT.md"
    artifact_version: "0.4.0"
    required_status: "draft"
  - artifact: "CONTEXT.md"
    artifact_version: "0.3.0"
    required_status: "draft"
  - artifact: "README.md"
    artifact_version: "0.5.1"
    required_status: "draft"
  - artifact: "shipflow-spec-driven-workflow.md"
    artifact_version: "0.8.1"
    required_status: "draft"
  - artifact: "CONTENT_MAP.md"
    artifact_version: "0.3.0"
    required_status: "draft"
  - artifact: "skills/references/canonical-paths.md"
    artifact_version: "1.0.0"
    required_status: "active"
  - artifact: "skills/references/chantier-tracking.md"
    artifact_version: "0.1.0"
    required_status: "draft"
  - artifact: "skills/references/skill-context-budget.md"
    artifact_version: "0.2.0"
    required_status: "draft"
  - artifact: "docs/technical/skill-runtime-and-lifecycle.md"
    artifact_version: "1.3.0"
    required_status: "reviewed"
  - artifact: "docs/technical/code-docs-map.md"
    artifact_version: "1.0.0"
    required_status: "reviewed"
  - artifact: "docs/technical/public-site-and-content-runtime.md"
    artifact_version: "1.1.0"
    required_status: "reviewed"
  - artifact: "docs/editorial/README.md"
    artifact_version: "1.0.0"
    required_status: "reviewed"
supersedes: []
evidence:
  - "User request 2026-05-02: produce a spec only, not the implementation, for a master skill that creates or modifies skills."
  - "User request 2026-05-02: the lifecycle must cover sf-spec -> edit/create SKILL.md -> sf-skills-refresh -> skill budget audit -> sf-verify -> sf-docs/help update -> sf-ship."
  - "User request 2026-05-02: include public content updates, especially the site surfaces that present skills."
  - "Repo investigation 2026-05-02: skills are maintained under skills/*/SKILL.md with canonical ShipFlow path resolution from skills/references/canonical-paths.md."
  - "Repo investigation 2026-05-02: sf-skills-refresh is additive, logs refreshes, and requires skill budget audit when skill surfaces or length materially change."
  - "Repo investigation 2026-05-02: skills/references/skill-context-budget.md and tools/skill_budget_audit.py define the discovery-budget validation path."
  - "Repo investigation 2026-05-02: public skill pages are Astro content under site/src/content/skills/ and are listed by site/src/pages/skills/index.astro."
  - "Repo investigation 2026-05-02: CONTENT_MAP.md and docs/editorial/ define public skill page, claim, page intent, and Astro content schema gates."
  - "Repo investigation 2026-05-02: docs/technical/code-docs-map.md maps skills/**/SKILL.md changes to docs/technical/skill-runtime-and-lifecycle.md and skill budget validation."
next_step: "/sf-end specs/sf-skill-build-master-skill.md"
---

# Spec: sf-skill-build Master Skill

## Title

sf-skill-build Master Skill

## Status

ready

## User Story

As a ShipFlow maintainer creating or changing skills, I want one master skill to orchestrate the skill lifecycle from spec through `SKILL.md` edits, refresh, budget audit, verification, public documentation, and ship, so ShipFlow skills stay product-coherent, technically safe, discoverable, and publicly documented.

## Minimal Behavior Contract

When the user asks to create or modify a ShipFlow skill, `sf-skill-build` must become the single lifecycle pilot for that skill work: it confirms or creates the chantier spec, guides the implementation of the target `SKILL.md`, publishes current-user Claude/Codex runtime symlinks, runs `sf-skills-refresh` on the changed skill contract, runs the skill discovery budget audit, verifies behavior against the spec, updates internal help and public skill content surfaces, and only then routes to ship. Success is observable through a ready or verified chantier, a changed or newly created skill contract, current-user runtime symlinks, budget and metadata validation, public skill pages/listing coherence, and a final ship-ready report. Failure is observable through a blocked status, a concrete reason, and the next safe command. The easy edge case to miss is treating a skill as only an internal prompt: every new or materially changed skill also affects runtime visibility in Claude/Codex, discovery budget, public catalog truth, `sf-help`, workflow docs, technical docs, and possibly public claims.

## Success Behavior

- Preconditions: the user provides a skill creation or skill modification goal; the current repository is ShipFlow; the target skill name or existing skill path is explicit or inferable from the user request; and only one chantier spec is in scope.
- Trigger: the user invokes `/sf-skill-build <skill idea or skill path>` or asks explicitly to create or modify a ShipFlow skill through this lifecycle.
- User/operator result: the user gets one guided path instead of manually remembering `sf-spec`, direct file edits, refresh, budget audit, verification, docs/help updates, public site updates, and ship.
- System effect: `sf-skill-build` checks for an existing matching spec, creates or updates the spec via `sf-spec` when needed, executes only after readiness, creates or edits the target `skills/<name>/SKILL.md`, creates or verifies current-user `~/.claude/skills/<name>` and `~/.codex/skills/<name>` symlinks, runs `sf-skills-refresh <name>` or records why refresh is not appropriate, runs `tools/skill_budget_audit.py`, routes verification through `sf-verify`, produces `Documentation Update Plan` and `Editorial Update Plan` items for changed technical and public surfaces, updates `sf-help`, README/workflow docs, public skill content, and public skill listing surfaces when impacted, then routes to `sf-ship`.
- Success proof: the target `SKILL.md` exists and matches its directory name, the current-user Claude/Codex skill symlinks resolve to that skill and expose `SKILL.md`, the public skill page exists or is explicitly justified as not public, the skill budget audit passes or reports only accepted warnings, `shipflow_metadata_lint.py` passes for changed ShipFlow artifacts, `npm --prefix site run build` passes when site content changed, and `sf-verify` confirms the user story and documentation coherence.
- Silent success: not allowed. The final report must name the target skill, spec path, changed surfaces, validations, public-content decision, remaining warnings if any, and next lifecycle command.

## Error Behavior

- Expected failures: ambiguous skill name, duplicate or overlapping existing skill, missing or ambiguous chantier spec, invalid skill name/path, unclear public promise, overlong description, runtime symlink creation blocked by a non-symlink file, budget audit failure, `SKILL.md` body growth beyond policy, missing public skill page when one is required, Astro schema failure, public claim without evidence, stale `sf-help`, missing docs update plan, failed readiness, failed verification, unrelated dirty files before ship, or user refusal to approve scope.
- User/operator response: ask one targeted question when the answer changes behavior, public promise, skill name, scope, safety, or ship risk; otherwise report blocked with the exact validation or gate that failed.
- System effect: no `SKILL.md` edit happens without a spec or an explicit direct-fix contract for a narrow wording update; no public claim is strengthened without claim-register review; no site content is changed outside the Astro schema; no ship happens while skill budget, metadata, verification, or required site build checks are failing.
- Must never happen: create a duplicate skill for an already covered workflow, rename a skill invocation key without explicit approval, hide argument semantics in an overlong description, skip budget audit after adding or materially expanding a skill, publish a public skill page that promises behavior not present in `SKILL.md`, add ShipFlow governance frontmatter to `site/src/content/skills/*.md`, ship stale `sf-help` or stale public skill catalog text, or commit unrelated dirty files.
- Silent failure: not allowed. Every failed gate must produce a visible status and a recovery command.

## Problem

ShipFlow now has enough skills that creating or changing a skill is a cross-system product operation, not a local Markdown edit. A skill affects agent discovery, lifecycle doctrine, public explanations, `sf-help`, budget constraints, technical docs, editorial surfaces, and the public skills catalog.

The current building blocks exist, but the operator has to remember the full sequence manually. That makes skill work easy to under-scope: an agent can edit `SKILL.md` and forget `sf-skills-refresh`, skip discovery-budget validation, leave public skill pages stale, miss `sf-help`, or ship a public promise that no longer matches the internal contract.

## Solution

Create a new master skill, `sf-skill-build`, that orchestrates the skill-maintenance lifecycle for both new and modified ShipFlow skills. It should use the existing spec-first workflow, keep `SKILL.md` implementation scoped, refresh changed skills conservatively, enforce skill budget policy, verify the behavior contract, update internal help and public content surfaces, and route to ship only after technical and editorial gates pass.

## Scope In

- Create `skills/sf-skill-build/SKILL.md` as the master skill contract for creating and modifying ShipFlow skills.
- Define the canonical lifecycle: `sf-spec -> edit/create SKILL.md -> sf-skills-refresh -> skill budget audit -> sf-verify -> sf-docs/help update -> sf-ship`.
- Require canonical path resolution through `${SHIPFLOW_ROOT:-$HOME/shipflow}` for ShipFlow-owned skills, references, tools, and workflow docs.
- Create or verify current-user runtime symlinks for new or renamed skills: `~/.claude/skills/<name>` and `~/.codex/skills/<name>` must resolve to `${SHIPFLOW_ROOT:-$HOME/shipflow}/skills/<name>` and expose `SKILL.md`.
- Check existing active specs before creating a new chantier for the skill work.
- Validate new skill names against skill context budget rules: lowercase letters, numbers, hyphens, no leading/trailing hyphen, no `--`, maximum 64 characters, and directory name matching frontmatter `name`.
- Keep `description` compact, one sentence, trigger-focused, and within the ShipFlow budget thresholds in `skills/references/skill-context-budget.md`.
- Preserve or add `argument-hint` for arguments instead of putting argument syntax into `description`.
- Run `sf-skills-refresh` after `SKILL.md` creation or material modification, unless the change is explicitly scoped to budget-only frontmatter cleanup and refresh would add no new signal.
- Run `tools/skill_budget_audit.py --skills-root skills --format markdown` after skill creation, renaming, description changes, surface expansion, or material `SKILL.md` growth.
- Run `python3 tools/shipflow_metadata_lint.py` on changed ShipFlow artifacts and at least the chantier spec.
- Update `skills/sf-help/SKILL.md` when the new skill should be discoverable in the help matrix, role matrix, lifecycle notes, or skill-system cheatsheet.
- Update public skill surfaces when public skill discovery changes: `site/src/content/skills/<slug>.md`, `site/src/pages/skills/index.astro`, `site/src/pages/skills/[slug].astro`, and `site/src/content.config.ts` as applicable.
- Update `README.md` and `shipflow-spec-driven-workflow.md` when the skill changes official workflow doctrine, recommended entrypoints, or lifecycle routing.
- Update `CONTENT_MAP.md` and `docs/editorial/` gates when public skill promises, skill page roles, public claims, categories, or content-routing rules change.
- Use `docs/technical/code-docs-map.md` to determine technical documentation impact for `skills/**/SKILL.md`, `site/**`, `CONTENT_MAP.md`, and `specs/**`.
- Run focused public-site checks when public skill content changes, including `npm --prefix site run build` and relevant `rg` checks for schema, internal-only leaks, stale skill names, and public claim drift.
- Require `sf-verify` before closure and `sf-ship` only after verification and ship-scope checks.

## Scope Out

- Do not implement `sf-skill-build` in this spec creation run.
- Do not replace `sf-spec`, `sf-skills-refresh`, `sf-verify`, `sf-docs`, `sf-help`, or `sf-ship`; orchestrate them.
- Do not create a generic third-party skill generator outside ShipFlow's skill library.
- Do not rename existing skills unless the user explicitly approves the invocation change and all public/internal references are updated.
- Do not add broad skill-budget reminders to unrelated entrypoint docs such as `AGENT.md` or `CONTEXT.md`.
- Do not rewrite existing skill bodies from scratch during refresh; preserve the additive `sf-skills-refresh` rule.
- Do not add ShipFlow artifact metadata to Astro runtime content under `site/src/content/skills/*.md`.
- Do not invent a blog/article surface for skill announcements; current policy says `surface missing: blog`.
- Do not ship if budget, metadata, site build, readiness, verification, or public-content gates fail.

## Constraints

- Internal skill contracts, section names, stop conditions, and validation rules are written in English.
- User-facing prompts and final reports use the active user language; French user-facing text must use proper accents.
- The master skill must ask targeted questions only when the answer materially changes skill name, invocation, public promise, security posture, scope, or ship risk.
- The skill is public by default: creation or material modification requires a public skill page path unless the user explicitly approves an internal-only exception in the spec.
- Invocation rename policy is strict: if implementation proposes renaming the invocation key, the flow must block and require explicit user approval before any rename edits.
- New skill creation is high risk because it changes the agent operating surface and public catalog; default to spec-first.
- Shared files are sequential integration surfaces: `skills/sf-help/SKILL.md`, `README.md`, `shipflow-spec-driven-workflow.md`, `CONTENT_MAP.md`, `docs/editorial/**`, `docs/technical/code-docs-map.md`, `site/src/content.config.ts`, and public hub copy.
- Parallel edits to multiple skill pages are allowed only when a ready spec assigns exclusive files and no shared schema, hub, docs, map, or claim file changes in the same wave.
- `sf-skills-refresh` must remain additive and conservative; it must not rewrite a skill from scratch.
- `skill_budget_audit.py` is mandatory when a skill is added, renamed, or materially expanded.
- Public skill pages summarize outcomes and use cases; they must not duplicate internal prompt bodies.
- Runtime content fields must match `site/src/content.config.ts`.
- Public claims must stay within `BUSINESS.md`, `PRODUCT.md`, `BRANDING.md`, `GTM.md`, specs, verified behavior, and `docs/editorial/claim-register.md`.

## Dependencies

- Local skill contracts: `skills/sf-spec/SKILL.md`, `skills/sf-skills-refresh/SKILL.md`, `skills/sf-help/SKILL.md`, `skills/sf-docs/SKILL.md`, `skills/sf-verify/SKILL.md`, and `skills/sf-ship/SKILL.md`.
- Local references: `skills/references/canonical-paths.md`, `skills/references/chantier-tracking.md`, and `skills/references/skill-context-budget.md`.
- Local tools: `tools/skill_budget_audit.py` and `tools/shipflow_metadata_lint.py`.
- Local technical docs: `docs/technical/skill-runtime-and-lifecycle.md`, `docs/technical/code-docs-map.md`, and `docs/technical/public-site-and-content-runtime.md`.
- Public content governance: `CONTENT_MAP.md`, `docs/editorial/README.md`, `docs/editorial/public-surface-map.md`, `docs/editorial/page-intent-map.md`, `docs/editorial/editorial-update-gate.md`, `docs/editorial/claim-register.md`, and `docs/editorial/astro-content-schema-policy.md`.
- Public site runtime: Astro skills collection in `site/src/content.config.ts`, public skill content in `site/src/content/skills/`, hub route `site/src/pages/skills/index.astro`, detail route `site/src/pages/skills/[slug].astro`, and build command `npm --prefix site run build`.
- Product and public-claim contracts: `BUSINESS.md` 1.1.0 reviewed, `PRODUCT.md` 1.1.0 reviewed, `BRANDING.md` 1.0.0 reviewed, `GTM.md` 1.1.0 reviewed, and `GUIDELINES.md` 1.3.0 reviewed.
- Fresh external docs verdict: fresh-docs checked on 2026-05-02 for Astro runtime assumptions used by this spec. Local version discovered from `site/package-lock.json`: `astro@5.18.1`. Official docs consulted: content collections guide (`https://docs.astro.build/en/guides/content-collections/`) and build/deploy guidance (`https://docs.astro.build/en/develop-and-build/`, `https://docs.astro.build/en/guides/deploy/`). Decision impact: keep schema-first content constraints in `site/src/content.config.ts` and keep `npm --prefix site run build` as a required validation gate when public skill content or routes change.

## Invariants

- `skills/*/SKILL.md` is the internal source of truth for skill behavior.
- Current-user `~/.claude/skills/*` and `~/.codex/skills/*` symlinks are the runtime discovery surface for local Claude/Codex sessions.
- `site/src/content/skills/*.md` is the public source for rendered skill detail pages and must stay schema-compatible.
- `sf-help` must not describe a skill lifecycle that differs from the implemented skill contracts.
- A public skill page must not promise a capability absent from its internal `SKILL.md`.
- Failed gates must report a visible reason and safe recovery command, and reports must never expose secrets, tokens, credentials, or private keys.
- Adding one skill increases discovery-budget pressure; budget validation is part of the feature, not an optional cleanup.
- `sf-skills-refresh` supports the chantier but does not replace spec/readiness/verification.
- The chantier spec remains the durable history for lifecycle runs.
- Technical docs and editorial docs are gates when their mapped surfaces are affected.
- Public-site changes require build validation when practical.
- Ship scope must remain bounded to the current chantier and exclude unrelated dirty files.

## Links & Consequences

- Skill runtime consequence: new or changed skill instructions can affect future agent behavior, automatic skill selection, and lifecycle routing, but only after Claude/Codex runtime links expose the skill.
- Budget consequence: adding `sf-skill-build` increases the discovery index and can worsen Codex or Claude Code skill-list budget pressure unless descriptions stay compact.
- Public content consequence: a new skill needs a public skill page or a documented no-public-page decision, and the `/skills` hub must remain coherent.
- Documentation consequence: `sf-help`, README, workflow doctrine, technical docs, and editorial governance can drift if only `SKILL.md` changes.
- Security consequence: skills are agent instructions; unsafe wording can accidentally broaden write authority, weaken prompt hierarchy, publish private details, or make destructive operations too implicit.
- Site consequence: Astro content collection validation can fail if public skill frontmatter uses unsupported fields or invalid categories.
- Shipping consequence: `sf-ship` must stage only the skill chantier files and must not sweep unrelated dirty work into a skill maintenance commit.

## Documentation Coherence

- Internal help: update `skills/sf-help/SKILL.md` when `sf-skill-build` is added, when its role changes, or when the lifecycle notes need to show the skill-creation path.
- Workflow docs: update `shipflow-spec-driven-workflow.md` when `sf-skill-build` becomes an official recommended entrypoint or changes lifecycle doctrine.
- README: update when public onboarding, skill list, workflow examples, or official artifact maps mention the skill lifecycle.
- Technical docs: update `docs/technical/skill-runtime-and-lifecycle.md` for the new master skill role and any lifecycle or validation gates; update `docs/technical/code-docs-map.md` only if the map itself needs a new trigger, validation command, or subsystem row.
- Public skill page: create or update `site/src/content/skills/sf-skill-build.md` if the skill is public-facing; follow `site/src/content.config.ts` exactly and omit ShipFlow governance metadata.
- Public skills hub/listing: review `site/src/pages/skills/index.astro` and category copy. Update only if the new skill changes featured skills, category framing, or public explanation of skill maintenance.
- Editorial gates: use `CONTENT_MAP.md`, `docs/editorial/public-surface-map.md`, `docs/editorial/page-intent-map.md`, `docs/editorial/editorial-update-gate.md`, and `docs/editorial/claim-register.md` when public skill promises, public claims, or content-routing rules change.
- Claim safety: do not claim `sf-skill-build` guarantees safe skills, agent correctness, or fully autonomous maintenance; allowed wording is that it reduces drift through explicit gates, validation, and public-content checks.
- Blog/article surfaces: if implementation wants a launch article, report `surface missing: blog` and route to a separate surface decision.

## Edge Cases

- The target skill already exists under a different name or overlaps an existing skill such as `sf-skills-refresh`, `skill-creator`, or `sf-build`.
- The user asks for a rename, which changes invocation keys and requires reference, symlink, public page, and docs review.
- The requested skill is internal-only and should not receive a public site page; this needs an explicit no-public-page justification.
- The new public skill page requires a category that is not in `site/src/content.config.ts`; either choose an existing category or route the schema/category change through the spec.
- `sf-skills-refresh` changes the just-created skill enough that budget audit must be rerun.
- The budget audit passes hard checks but warns that aggregate discovery size remains high; report the warning and decide whether it blocks ship based on strict mode and current policy.
- A public skill page tries to include `metadata_schema_version` or other ShipFlow artifact metadata; preserve the Astro schema and put governance metadata in the spec or docs instead.
- The skill body grows beyond 500 lines; move durable doctrine into a reference file or record a follow-up if the body size is only a warning.
- Multiple agents edit shared public content or help docs concurrently; block unless the ready spec defines non-overlapping ownership.
- Verification passes internal behavior but public content still describes the old workflow; do not close until editorial coherence is complete or explicitly pending with a ship block.

## Implementation Tasks

- [x] Task 1: Confirm the target master skill contract and existing overlap
  - File: `specs/sf-skill-build-master-skill.md`
  - Action: Re-read this spec, search existing skills for overlap with `sf-build`, `sf-skills-refresh`, and system `skill-creator`, then confirm that the new ShipFlow skill name remains `sf-skill-build`.
  - User story link: Prevents duplicate or confusing skill entrypoints.
  - Depends on: None
  - Validate with: `rg -n "sf-skill-build|skill-build|skills-refresh|skill-creator|sf-build" skills specs site/src/content/skills README.md shipflow-spec-driven-workflow.md`
  - Notes: If a better name is proposed, stop for explicit user approval before renaming the target.

- [x] Task 2: Create the master skill contract
  - File: `skills/sf-skill-build/SKILL.md`
  - Action: Add a compact frontmatter `name`, one-sentence `description`, `argument-hint`, canonical path rule, chantier tracking rule, mission, lifecycle gates, stop conditions, validation commands, and final report shape.
  - User story link: Provides the single operator entrypoint for skill creation and modification.
  - Depends on: Task 1
  - Validate with: `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
  - Notes: Do not duplicate full bodies of `sf-spec`, `sf-skills-refresh`, `sf-docs`, `sf-verify`, or `sf-ship`; orchestrate them and link to their roles.

- [x] Task 3: Encode lifecycle gating in the skill body
  - File: `skills/sf-skill-build/SKILL.md`
  - Action: Define the required sequence `sf-spec -> edit/create SKILL.md -> sf-skills-refresh -> skill budget audit -> sf-verify -> sf-docs/help update -> sf-ship`, including rerun rules when refresh or docs updates change the skill contract.
  - User story link: Keeps the operator from manually remembering the safe skill-maintenance order.
  - Depends on: Task 2
  - Validate with: `rg -n "sf-spec|sf-skills-refresh|skill_budget_audit|sf-verify|sf-docs|sf-help|sf-ship" skills/sf-skill-build/SKILL.md`
  - Notes: Include stop conditions for failed readiness, failed budget audit, failed verification, failed site build, and unrelated dirty files.

- [x] Task 4: Add public skill content
  - File: `site/src/content/skills/sf-skill-build.md`
  - Action: Create a public-facing skill page with schema-compatible frontmatter, concise public promise, examples, limits, related skills, and category selection.
  - User story link: Makes the new master skill discoverable on the public skills site.
  - Depends on: Task 2
  - Validate with: `npm --prefix site run build`
  - Notes: Use the Astro skills schema only. Do not add ShipFlow artifact metadata to this runtime content file.

- [x] Task 5: Review public skills hub and listing behavior
  - File: `site/src/pages/skills/index.astro`
  - Action: Confirm the new public skill appears in the intended category and update hub copy only if the new skill materially changes how visitors should understand skill maintenance.
  - User story link: Keeps public skill discovery coherent.
  - Depends on: Task 4
  - Validate with: `rg -n "sf-skill-build|Meta & Setup|Operate & Ship|skills Catalog|Featured Skills" site/src/pages/skills/index.astro site/src/content/skills/sf-skill-build.md`
  - Notes: The hub is collection-driven, so a content file may be enough unless category copy or featured status changes.

- [x] Task 6: Update internal help
  - File: `skills/sf-help/SKILL.md`
  - Action: Add `sf-skill-build` to the relevant help tables, role matrix, and lifecycle notes so operators can find the skill creation/modification path.
  - User story link: Prevents internal help from lagging behind the new entrypoint.
  - Depends on: Tasks 2-3
  - Validate with: `rg -n "sf-skill-build|skill creation|skill modification|skill maintenance" skills/sf-help/SKILL.md`
  - Notes: Keep help concise; avoid duplicating the full master skill body.

- [x] Task 7: Update workflow and repo docs if the entrypoint becomes official
  - File: `README.md`, `shipflow-spec-driven-workflow.md`
  - Action: Add the skill-maintenance lifecycle where official workflows are listed, or record a no-impact justification if the skill remains maintainer-only and not a recommended public entrypoint.
  - User story link: Keeps official docs aligned with the new master skill.
  - Depends on: Tasks 2-6
  - Validate with: `rg -n "sf-skill-build|skill maintenance|skill creation|skills-refresh|skill budget" README.md shipflow-spec-driven-workflow.md`
  - Notes: If edited, bump artifact metadata according to `sf-docs` versioning rules.

- [x] Task 8: Update technical documentation impact
  - File: `docs/technical/skill-runtime-and-lifecycle.md`, `docs/technical/code-docs-map.md`
  - Action: Update the skill lifecycle doc for the new master skill and only update the map if validations, triggers, or path ownership rules change.
  - User story link: Keeps code-proximate docs aligned for future agents.
  - Depends on: Tasks 2-7
  - Validate with: `rg -n "sf-skill-build|skill_budget_audit|public skill pages|sf-skills-refresh" docs/technical/skill-runtime-and-lifecycle.md docs/technical/code-docs-map.md`
  - Notes: Produce a `Documentation Update Plan` before editing shared technical docs.

- [x] Task 9: Run editorial impact and update public-content governance if claims or surfaces change
  - File: `CONTENT_MAP.md`, `docs/editorial/public-surface-map.md`, `docs/editorial/page-intent-map.md`, `docs/editorial/editorial-update-gate.md`, `docs/editorial/claim-register.md`
  - Action: Produce an `Editorial Update Plan`; update these files only when the new skill changes public skill page roles, content routing, category framing, sensitive claims, or public-surface rules.
  - User story link: Keeps public skill claims and surfaces truthful.
  - Depends on: Tasks 4-8
  - Validate with: `rg -n "sf-skill-build|public skill pages|skill promises|skill budget|Editorial Update Plan|Claim Impact Plan" CONTENT_MAP.md docs/editorial`
  - Notes: If no structural editorial docs need edits, record explicit `no editorial impact` for each reviewed surface.

- [x] Task 10: Run `sf-skills-refresh` for the new or changed skill
  - File: `skills/sf-skill-build/SKILL.md`, `skills/REFRESH_LOG.md`
  - Action: Run `/sf-skills-refresh sf-skill-build` after the first skill body exists, apply only targeted additive findings, and log the refresh.
  - User story link: Ensures the new skill starts aligned with current skill-maintenance practice.
  - Depends on: Tasks 2-3
  - Validate with: `rg -n "sf-skill-build" skills/REFRESH_LOG.md skills/sf-skill-build/SKILL.md`
  - Notes: Rerun budget audit after refresh if the description, body length, or related surface changes.

- [x] Task 11: Run budget, metadata, and content validation
  - File: `skills/`, `specs/sf-skill-build-master-skill.md`, `site/`, changed docs
  - Action: Run the focused validation set for skill, spec, docs, and public site changes.
  - User story link: Proves the skill is discoverable, metadata-valid, and publicly renderable.
  - Depends on: Tasks 2-10
  - Validate with: `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`; `python3 tools/shipflow_metadata_lint.py specs/sf-skill-build-master-skill.md README.md shipflow-spec-driven-workflow.md CONTENT_MAP.md docs/technical docs/editorial`; `npm --prefix site run build`; `rg -n "docs/technical|secret|token|credential" site/src CONTENT_MAP.md`
  - Notes: Review sensitive keyword matches manually; generic policy warnings are not automatically failures.

- [x] Task 12: Verify, close docs/help coherence, and ship
  - File: `specs/sf-skill-build-master-skill.md`, changed skill/docs/site files
  - Action: Run `sf-verify` against this spec, ensure `sf-docs` and `sf-help` updates are complete or explicitly no-impact, then run `sf-ship` with bounded staging for the chantier.
  - User story link: Completes the full lifecycle promised by the master skill.
  - Depends on: Task 11
  - Validate with: `/sf-verify specs/sf-skill-build-master-skill.md`; `/sf-ship "Add sf-skill-build master skill"`
  - Notes: Do not ship unrelated dirty files. If public content remains pending final copy, block ship unless the user explicitly accepts the risk and the pending item is not a public-truth mismatch.

## Acceptance Criteria

- [ ] AC 1: Given a user asks to create a new ShipFlow skill, when `sf-skill-build` runs, then it starts or attaches to a spec before creating `skills/<name>/SKILL.md`.
- [ ] AC 2: Given a user asks to modify an existing skill, when a matching active spec exists, then `sf-skill-build` attaches to that spec instead of creating a duplicate chantier.
- [ ] AC 3: Given a new skill is created, when frontmatter is checked, then `name` matches the directory, `description` is one concise sentence, and arguments live in `argument-hint` or the body.
- [ ] AC 4: Given a skill is added, renamed, or materially expanded, when validation runs, then `tools/skill_budget_audit.py --skills-root skills --format markdown` is included and its result is reported.
- [ ] AC 5: Given `sf-skills-refresh` edits the target skill, when the refresh finishes, then the budget audit is rerun if the description, body size, or public surface changed.
- [ ] AC 6: Given the new skill is public-facing, when public content is checked, then `site/src/content/skills/<slug>.md` exists, matches `site/src/content.config.ts`, and renders through `/skills/[slug]`.
- [ ] AC 7: Given the public skill catalog is built, when `/skills` is generated, then the new skill appears in the intended category or has an explicit no-public-page decision.
- [ ] AC 8: Given public skill copy changes, when editorial gates run, then `Editorial Update Plan` and `Claim Impact Plan` are produced when needed, and unsupported claims are downgraded or blocked.
- [ ] AC 9: Given internal help is read, when `sf-help` lists skills and workflows, then it includes `sf-skill-build` or explicitly explains why it is not exposed.
- [ ] AC 10: Given official workflow docs are read, when `sf-skill-build` changes lifecycle doctrine, then README and `shipflow-spec-driven-workflow.md` are updated or explicitly marked no-impact.
- [ ] AC 11: Given technical docs are mapped, when `skills/**/SKILL.md` and `site/**` change, then `docs/technical/skill-runtime-and-lifecycle.md`, `docs/technical/public-site-and-content-runtime.md`, and `docs/technical/code-docs-map.md` are reviewed through a `Documentation Update Plan`.
- [ ] AC 12: Given validation is complete, when `sf-verify` runs, then it verifies the skill behavior contract, budget audit result, docs/help coherence, public site coherence, and ship scope.
- [ ] AC 13: Given unrelated dirty files exist, when `sf-ship` is requested, then they are excluded unless the user explicitly authorizes the broader ship scope.
- [ ] AC 14: Given any gate fails (readiness, budget, metadata, verification, site build, or ship scope), when the skill reports the failure, then it includes a concrete failure reason and a safe recovery command.
- [ ] AC 15: Given validation logs or reports are produced, when output is rendered to the user, then secrets, tokens, credentials, and private keys are never printed.
- [ ] AC 16: Given a new skill is created or a skill invocation directory changes, when validation runs, then current-user `~/.claude/skills/<name>` and `~/.codex/skills/<name>` symlinks resolve to the ShipFlow skill directory and expose `SKILL.md`, or the run blocks with a concrete reason.

## Test Strategy

- Static skill validation: run `python3 tools/skill_budget_audit.py --skills-root skills --format markdown` and consider `--strict` before ship if warnings remain.
- Runtime link validation: verify `readlink -f ~/.claude/skills/<name>` and `readlink -f ~/.codex/skills/<name>` match `${SHIPFLOW_ROOT:-$HOME/shipflow}/skills/<name>`, and verify both expose `SKILL.md`.
- Metadata validation: run `python3 tools/shipflow_metadata_lint.py` on the spec and changed ShipFlow artifacts; include `docs/technical` and `docs/editorial` when they are edited.
- Public site validation: run `npm --prefix site run build` when `site/src/content/skills/`, `site/src/content.config.ts`, or public skill routes change.
- Focused content scans: use `rg` to check stale skill names, old lifecycle wording, internal-only technical-doc links in public site content, and sensitive public-claim keywords.
- Manual review: inspect the new public skill page and `/skills` hub grouping when public content changes.
- Workflow verification: run `sf-verify` against this spec before closure, checking the behavior contract, error behavior, docs coherence, and public-content gate outcomes.
- Ship validation: run `git status --short`, inspect staged files, and use `sf-ship` only for the current chantier files.

## Risks

- Skill overlap risk: `sf-skill-build` can confuse users if it overlaps too much with `sf-build`, `sf-skills-refresh`, or system `skill-creator`. Mitigation: define it specifically as ShipFlow skill lifecycle orchestration.
- Discovery-budget risk: adding another always-available skill worsens context budget pressure. Mitigation: compact description, run budget audit, and keep detailed doctrine in the body or references.
- Public promise risk: a public page can make the skill sound more autonomous or safer than it is. Mitigation: claim-register review and explicit limits.
- Security risk: skill instructions can change how future agents edit files or interpret authority. Mitigation: explicit stop conditions, scope boundaries, and no destructive or broad writes without approval.
- Documentation drift risk: public site, `sf-help`, README, and workflow docs can diverge from `SKILL.md`. Mitigation: mandatory documentation and editorial gates.
- Runtime schema risk: public skill content can break Astro builds. Mitigation: preserve `site/src/content.config.ts` and build after content edits.
- Ship risk: unrelated dirty files may be swept into the commit. Mitigation: bounded staging and explicit `sf-ship` scope.

## Execution Notes

- Read first during implementation: `skills/sf-build/SKILL.md`, `skills/sf-skills-refresh/SKILL.md`, `skills/sf-help/SKILL.md`, `skills/references/skill-context-budget.md`, `docs/technical/skill-runtime-and-lifecycle.md`, `docs/technical/code-docs-map.md`, `CONTENT_MAP.md`, `docs/editorial/README.md`, `site/src/content.config.ts`, and representative `site/src/content/skills/*.md`.
- Preferred implementation order: create the skill contract first, run budget audit early, add public content, update help/docs, then run refresh and validations again.
- Use `apply_patch` for manual edits and preserve unrelated user changes.
- Keep shared files sequential. Do not split `sf-help`, README, workflow docs, `CONTENT_MAP.md`, editorial docs, or `site/src/content.config.ts` across concurrent write agents.
- Stop and ask if the user explicitly requests an internal-only exception, if the invocation name changes, if the public promise would be stronger than the internal contract, or if budget audit warnings remain before ship.
- Do not treat this spec as permission to edit files in the current spec-only run. Implementation starts after `/sf-ready` passes and the user launches the build flow.

## Open Questions

None.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-05-02 15:22:13 UTC | sf-spec | GPT-5 Codex | Created the initial chantier spec for the `sf-skill-build` master skill lifecycle. | draft saved | /sf-ready sf-skill-build Master Skill |
| 2026-05-02 18:03:33 UTC | sf-start | GPT-5 Codex | Attempted execution from this spec, blocked by readiness gate because `status: draft`. | rerouted | /sf-ready specs/sf-skill-build-master-skill.md |
| 2026-05-02 19:55:01 UTC | sf-ready | GPT-5 Codex | Ran readiness gate and performed adversarial/security review. | not ready | /sf-spec sf-skill-build Master Skill |
| 2026-05-02 20:07:07 UTC | sf-ready | GPT-5 Codex | Re-ran readiness after spec clarifications (public default, rename block, security/logging guarantees, freshness evidence). | ready | /sf-start specs/sf-skill-build-master-skill.md |
| 2026-05-02 20:13:20 UTC | sf-start | GPT-5 Codex | Implemented `sf-skill-build`, added public skill content, updated help/workflow/technical docs, ran refresh logging and validation gates. | implemented | /sf-verify specs/sf-skill-build-master-skill.md |
| 2026-05-02 20:22:02 UTC | sf-verify | GPT-5 Codex | Verified user-story delivery, lifecycle coherence, metadata/budget/site validations, and chantier-tracking role coherence for touched skills. | verified | /sf-end specs/sf-skill-build-master-skill.md |
| 2026-05-02 22:10:07 UTC | sf-verify | GPT-5 Codex | Re-ran verification after reservation corrections: updated dependency versions, consistency checks, and revalidation gates all passed. | verified | /sf-end specs/sf-skill-build-master-skill.md |
| 2026-05-02 22:11:44 UTC | sf-ship | GPT-5 Codex | Logged full run history and current flow updates, completed chantier-boundary stage/commit steps, and validated final scope + checks before shipping `sf-skill-build` master skill changes. | shipped | /sf-end specs/sf-skill-build-master-skill.md |
| 2026-05-03 04:16:07 UTC | sf-fix | GPT-5 Codex | Fixed missing runtime symlink coverage: linked `sf-skill-build` into current-user Claude/Codex skill directories and added symlink publication/validation gates to the master skill contract. | fix-attempted | /sf-test --retest BUG-2026-05-03-001 |

## Current Chantier Flow

- sf-spec: done, initial draft created in `specs/sf-skill-build-master-skill.md`.
- sf-ready: ready, readiness gate passed with current contract and validations.
- sf-build: not launched.
- sf-start: implemented from this ready spec.
- SKILL.md creation/edit: done (`skills/sf-skill-build/SKILL.md`).
- sf-skills-refresh: done (refresh entry recorded in `skills/REFRESH_LOG.md`).
- runtime skill links: done for `sf-skill-build` current-user Claude/Codex symlinks; now required by `sf-skill-build`.
- skill budget audit: done (pass, aggregate under threshold).
- sf-verify: verified against the ready spec and validation evidence.
- sf-docs/help update: done (help + workflow + technical/public docs aligned).
- sf-end: not launched.
- sf-ship: shipped.
- Next command: `/sf-end specs/sf-skill-build-master-skill.md`.
