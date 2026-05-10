---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipFlow
created: "2026-05-09"
created_at: "2026-05-09 21:04:33 UTC"
updated: "2026-05-10"
updated_at: "2026-05-10 08:20:19 UTC"
status: ready
source_skill: sf-spec
source_model: "GPT-5 Codex"
scope: migration
owner: Diane
user_story: "En tant qu'utilisatrice ShipFlow qui pilote plusieurs projets avec des agents, je veux que tous les documents Markdown ShipFlow d'un projet vivent sous un dossier shipflow_data versionne dans le repo du projet, afin d'arreter les fichiers eparpilles, les symlinks absolus casses et les doctrines documentaires contradictoires."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/canonical-paths.md
  - skills/sf-init/SKILL.md
  - skills/sf-docs/SKILL.md
  - skills/sf-tasks/SKILL.md
  - skills/sf-help/SKILL.md
  - skills/sf-content/SKILL.md
  - skills/sf-ship/SKILL.md
  - skills/sf-verify/SKILL.md
  - shipflow-metadata-migration-guide.md
  - tools/shipflow_metadata_lint.py
  - docs/technical/
  - CONTENT_MAP.md
  - BUSINESS.md
  - PRODUCT.md
  - BRANDING.md
  - GTM.md
  - GUIDELINES.md
  - TASKS.md
  - /home/claude/shipflow_data/
depends_on:
  - artifact: "GUIDELINES.md"
    artifact_version: "1.3.0"
    required_status: reviewed
  - artifact: "ARCHITECTURE.md"
    artifact_version: "1.0.0"
    required_status: reviewed
  - artifact: "CONTENT_MAP.md"
    artifact_version: "0.6.0"
    required_status: draft
  - artifact: "shipflow-metadata-migration-guide.md"
    artifact_version: "0.3.0"
    required_status: draft
  - artifact: "skills/references/canonical-paths.md"
    artifact_version: "1.0.0"
    required_status: active
  - artifact: "specs/shipflow-governance-corpus-bootstrap-and-sf-build-integration.md"
    artifact_version: "1.0.0"
    required_status: ready
supersedes: []
evidence:
  - "User decision 2026-05-09: current file-by-file symlink and Markdown organization is too messy and must be replaced by a project-level umbrella architecture."
  - "User direction 2026-05-09: each GitHub project should have a ShipFlow data folder at repo root with technical documentation, editorial, and business subfolders."
  - "User decision 2026-05-09: the project-local umbrella folder name is shipflow_data."
  - "User decision 2026-05-09: all project ShipFlow Markdown categories belong under the project-local shipflow_data folder, including workflow artifacts."
  - "User decision 2026-05-09: project-level folders are the only source of truth for this phase; the central shipflow_data repo and master trackers are out of scope for now."
  - "User decision 2026-05-09: if future synchronization to the central master exists, the direction is project repo -> master, not master -> project; symlink vs copy remains undecided."
  - "Local audit 2026-05-09: socialflow/TASKS.md, tubeflow_expo/TASKS.md, and tubeflow_flutter/tubeflow_lab/TASKS.md are versioned or local symlinks pointing into shipflow_data."
  - "Local audit 2026-05-09: sf-init and runtime docs now forbid project-local TASKS.md symlinks, but sf-help and sf-tasks still contain older local/master tracker language."
  - "Existing doctrine before this spec: project decision docs live in project repos, while shipflow_data is limited to trackers and registries."
  - "User clarification 2026-05-10: all skills must respect the new doctrine and redirect to the document creation/update skills when project documents do not comply."
  - "User clarification 2026-05-10: the document creation/update skills must reorganize badly organized files instead of only reporting drift."
  - "User decision 2026-05-10: root discovery files stay at repository root; AGENTS.md is a symlink to AGENT.md."
  - "User decision 2026-05-10: canonical categories are technical, editorial, business, and workflow."
  - "User decision 2026-05-10: workflow artifacts use shipflow_data/workflow/specs, bugs, audits, reviews, and verification."
  - "User decision 2026-05-10: project trackers live under the project corpus; master trackers remain in the central shipflow_data repo and are ignored for now."
  - "User decision 2026-05-10: old root locations such as BUSINESS.md and CONTENT_MAP.md should not be kept as compatibility targets; force the new doctrine."
  - "User decision 2026-05-10: migration uses git mv by default when a file moves."
  - "User decision 2026-05-10: first pilot project is dotfiles because its git worktree is clean."
next_step: "/sf-start ShipFlow Data Project Umbrella Documentation Architecture"
---

# ShipFlow Data Project Umbrella Documentation Architecture

## Title

ShipFlow Data Project Umbrella Documentation Architecture

## Status

Ready.

The project-level doctrine is locked and ready for `/sf-start`. Every project repo owns a `shipflow_data/` folder at its Git root; all project-owned ShipFlow Markdown lives under that folder; project-level folders are the source of truth for this phase. The central `shipflow_data` repo, master trackers, and any future sync mechanism are deliberately out of scope for now.

## Recorded Doctrine

- Each GitHub project gets a `shipflow_data/` folder at the repository root.
- The project-local `shipflow_data/` folder is the source of truth for that project's ShipFlow Markdown.
- All project-owned ShipFlow Markdown goes under that folder, including technical, editorial, business, workflow, specs, bugs, audits, reviews, verification reports, and project-level trackers.
- Master trackers live in the separate `shipflow_data` repository root and are meant to be an aggregate/fusion layer, but they are ignored for this architecture phase.
- Do not design this phase around the central `shipflow_data` repository. Only project-local folders are read as sources of truth.
- If a future master synchronization exists, the direction is project repo -> master. Whether that is implemented by symlink, copy, generated index, or the ShipFlow web app is intentionally undecided.
- Versioned project files must not point to `/home/ubuntu`, `/home/claude`, or any other user-specific absolute path.
- Every skill that creates, reads, updates, verifies, ships, audits, or routes project-owned ShipFlow Markdown must respect the project-local `shipflow_data/` doctrine.
- If a skill detects missing, scattered, legacy-root, duplicated, or otherwise non-compliant ShipFlow Markdown, it must not keep writing into the old structure. It must route to the document owner skill for creation, update, or reorganization.
- `sf-init` owns initial creation of the project-local `shipflow_data/` corpus for new or adopted projects.
- `sf-docs` owns document updates, audits, and reorganization/migration of mislocated ShipFlow Markdown into the canonical project-local `shipflow_data/` layout.
- Root discovery files stay at repository root: `AGENT.md`, `CLAUDE.md`, and `README.md` remain real root files unless a later project-specific reason says otherwise.
- `AGENTS.md` is a compatibility symlink to root `AGENT.md`.
- Root decision/governance files such as `BUSINESS.md`, `PRODUCT.md`, `BRANDING.md`, `GTM.md`, `CONTENT_MAP.md`, root `docs/technical/`, and root `docs/editorial/` do not remain compatibility targets after migration. The new doctrine is enforced.
- The first pilot migration is `dotfiles`, because its git worktree is clean.

## User Story

En tant qu'utilisatrice ShipFlow qui pilote plusieurs projets avec des agents, je veux que tous les documents Markdown ShipFlow d'un projet vivent sous un dossier `shipflow_data/` versionne dans le repo du projet, afin d'arreter les fichiers eparpilles, les symlinks absolus casses et les doctrines documentaires contradictoires.

## Minimal Behavior Contract

Each project repository must expose one canonical project-local `shipflow_data/` umbrella at its Git root, organized by domain, and that folder is the only source of truth for project-owned ShipFlow Markdown during this phase. If a project has legacy root-level ShipFlow Markdown files or symlinks into a central data directory, migration classifies and moves or replaces them without losing content. If a file is required at repo root by agent tooling, it becomes a compatibility entrypoint and must point readers to the canonical project-local `shipflow_data/` content without becoming a second source of truth. Any skill that finds missing or non-compliant project documentation must stop before writing more drift, then route to the document creation/update owner: `sf-init` for first bootstrap and `sf-docs` for update, audit, and reorganization. The central `shipflow_data` repository and master trackers are deliberately ignored for now; future sync, if any, flows from project repos toward the master layer and is not part of this phase.

## Success Behavior

- Given a fresh agent enters any adopted project repo, when it looks for ShipFlow documentation, then it finds `shipflow_data/` at the Git root.
- Given a project has `BUSINESS.md`, `PRODUCT.md`, `BRANDING.md`, `GTM.md`, `CONTENT_MAP.md`, `docs/technical/`, `docs/editorial/`, specs, bugs, audit reports, trackers, or decision records, when migration runs, then each ShipFlow-owned Markdown file lands under project-local `shipflow_data/` with metadata preserved.
- Given a skill creates or updates project-owned ShipFlow Markdown, when it resolves the target path, then it writes under the project umbrella unless the file is a documented root compatibility entrypoint.
- Given any skill detects project-owned ShipFlow Markdown outside the canonical `shipflow_data/` layout, when the skill is not the document owner, then it routes to `sf-docs` instead of editing the non-compliant layout.
- Given a project has no project-local `shipflow_data/` corpus yet, when initialization or adoption runs, then `sf-init` creates the baseline layout or reports why it is blocked.
- Given a project has scattered or duplicated ShipFlow Markdown, when `sf-docs` runs in update/reorganize mode, then it moves or plans moves into canonical folders with conflict handling and validation.
- Given a skill needs master or cross-project data, when this phase is active, then it does not treat the central `shipflow_data` repository as a source of truth for project documentation.
- Given a symlink is committed to Git, when it is inspected, then it is relative and repo-local only, never an absolute path to a user home or global `shipflow_data`.

## Error Behavior

- If a versioned symlink points to `/home/<user>/shipflow_data`, migration must report it as non-portable and remove or replace it before shipping.
- If the same artifact exists both at repo root and inside the new umbrella with divergent content, migration must stop and ask for the canonical copy instead of merging silently.
- If a skill still writes to root `BUSINESS.md`, root `CONTENT_MAP.md`, root `docs/technical/`, or root `TASKS.md` after the new architecture is adopted, verification fails unless that path is an approved compatibility entrypoint.
- If a skill reads project documentation from the central `shipflow_data` repo during this phase, verification reports a source-of-truth violation.
- If a non-owner skill attempts to create or update project-owned ShipFlow Markdown in a legacy root path, verification reports a doctrine violation and routes to `sf-docs`.
- If `sf-docs` finds scattered docs but cannot identify the canonical owner, destination, or safe move plan, it must stop with a migration conflict report instead of copying or merging silently.
- If `sf-init` finds an existing non-compliant corpus during adoption, it must not overwrite it; it reports the project as needing `sf-docs reorganize`.
- If the central `shipflow_data` folder contains a copied project decision document that also exists in the project umbrella, verification reports the project-local copy as canonical and the central copy as out of scope until the future sync model is defined.
- If a root discovery file cannot remain safely at root, migration leaves the original file in place and records a blocking compatibility gap.

## Problem

ShipFlow currently mixes several ownership models:

- Some project decision docs live at repo root, for example `BUSINESS.md`, `PRODUCT.md`, `BRANDING.md`, `GTM.md`, `GUIDELINES.md`, and `CONTENT_MAP.md`.
- Technical docs live under `docs/technical/`, while editorial docs can live under `docs/editorial/`, `CONTENT_MAP.md`, public content folders, or research notes.
- Chantiers live under `specs/`, bugs under `bugs/`, and trackers under `TASKS.md`, `AUDIT_LOG.md`, or `${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}`.
- Older workflows created or preserved project `TASKS.md` symlinks pointing into `shipflow_data`.
- Some docs say project decision docs should stay in project repos and should not be duplicated into `shipflow_data`; the new requested architecture keeps that project ownership and groups those docs under one project-local `shipflow_data/` umbrella.

The result is unclear ownership, file discovery cost for agents, non-portable symlinks, and skills that disagree about where Markdown should be written.

## Solution

Adopt a project-local `shipflow_data/` documentation umbrella as the canonical home for all project-owned ShipFlow Markdown. Do not design the first migration around the central `shipflow_data` repository. The central master layer can later consume, copy, index, or link project-local folders, but that future sync model is explicitly deferred.

Proposed default project structure:

```text
<project>/
├── shipflow_data/
│   ├── technical/
│   │   ├── README.md
│   │   ├── code-docs-map.md
│   │   ├── architecture.md
│   │   ├── guidelines.md
│   │   └── context.md
│   ├── editorial/
│   │   ├── README.md
│   │   ├── content-map.md
│   │   ├── seo.md
│   │   └── repurposing.md
│   ├── business/
│   │   ├── business.md
│   │   ├── product.md
│   │   ├── branding.md
│   │   └── gtm.md
│   └── workflow/
│       ├── specs/
│       ├── bugs/
│       ├── audits/
│       ├── reviews/
│       └── verification/
├── AGENT.md
├── AGENTS.md -> AGENT.md
├── CLAUDE.md
└── README.md
```

Future central structure, not in scope for this phase:

```text
${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}/
├── TASKS.md
├── AUDIT_LOG.md
├── PROJECTS.md
└── projects/
    └── <project>/
        └── [future sync target, not defined in this phase]
```

The central structure is illustrative only. It must not be implemented or used as a source of truth in this phase.

## Scope In

- Define the project-local umbrella directory and domain subfolders.
- Define which Markdown artifacts move under the umbrella and which remain root discovery exceptions.
- Define migration rules for current projects.
- Update skills that create, read, or validate ShipFlow Markdown paths.
- Add verification for hardcoded user-home paths and versioned symlinks to `shipflow_data`.
- Reconcile older tracker doctrine in `sf-help`, `sf-tasks`, `sf-init`, runtime docs, README, and the metadata migration guide.

## Scope Out

- Moving application runtime docs that are not ShipFlow-owned, such as framework docs consumed by the app, public docs pages, MDX/blog content parsed by the app, or package README files.
- Rewriting all historical research notes unless they are promoted into the active ShipFlow corpus.
- Converting operational trackers into decision artifacts with frontmatter.
- Replacing Git, GitHub, or cloud synchronization.
- Designing or implementing central `shipflow_data` repo synchronization.
- Deciding symlink vs copy vs generated index for future repo -> master synchronization.
- Migrating files before this spec reaches `ready`.

## Constraints

- Root `AGENT.md`, `CLAUDE.md`, and `README.md` remain at repo root because agents, tools, humans, and GitHub conventions expect them there.
- Root `AGENTS.md` must be a symlink to root `AGENT.md`.
- Root `BUSINESS.md`, `PRODUCT.md`, `BRANDING.md`, `GTM.md`, `CONTENT_MAP.md`, `docs/technical/`, and `docs/editorial/` are not compatibility targets after migration. Skills must use the new `shipflow_data/` paths.
- App docs, changelogs, and package docs may remain outside the umbrella when they are product-facing or ecosystem-required rather than ShipFlow governance docs.
- Versioned symlinks must never contain absolute user homes.
- Central symlinks under `${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}` are out of scope for this phase and should not be treated as project documentation truth.
- Metadata linting must support the new umbrella paths.
- Migration must preserve existing artifact metadata and history where Git moves can do so cleanly.

## Dependencies

- `skills/references/canonical-paths.md` must be updated to define project umbrella resolution.
- `shipflow-metadata-migration-guide.md` must be updated to classify old root docs and new umbrella docs.
- `tools/shipflow_metadata_lint.py` must accept the new canonical locations.
- `sf-init`, `sf-docs`, `sf-content`, `sf-tasks`, `sf-help`, `sf-verify`, `sf-ship`, and audit skills must be updated or explicitly declared no-impact.
- Owner-skill routing must be explicit: non-owner skills route non-compliant document layouts to `sf-docs`; bootstrap/adoption routes to `sf-init`; `sf-docs` performs reorganization or writes the migration plan.
- Future central synchronization may need `PROJECTS.md` or another registry to discover project folders, but that is out of scope for this phase.

Fresh external docs: not needed for this spec. This is internal ShipFlow file architecture and local Git/symlink behavior, based on repo evidence and user architecture direction.

## Invariants

- One project-owned ShipFlow document has one canonical path under project-local `shipflow_data/`.
- Project-local `shipflow_data/` folders are the only source of truth for project documentation in this phase.
- Central `shipflow_data` master files are aggregate/fusion concerns and are ignored for now.
- Project-level trackers belong with the project documentation corpus unless they are explicitly identified as master aggregate trackers.
- Master trackers are not part of this migration phase.
- Root discovery files are exceptions, not alternate sources of truth for moved governance documents.
- Hardcoded `/home/ubuntu` and `/home/claude` paths are not acceptable inside versioned symlink targets or generated templates.
- Skills must resolve paths by ownership: ShipFlow source files from `$SHIPFLOW_ROOT`; project-owned ShipFlow Markdown from the project-local `shipflow_data/`; master aggregate data only when a later phase explicitly reintroduces it.
- Non-owner skills must not normalize doctrine drift by writing to legacy paths. They must route to the owner skill.
- `sf-docs` is the owner for reorganizing existing project documentation into the project-local `shipflow_data/` corpus.
- No migration may overwrite an app-owned file without an explicit backup and conflict report.

## Links & Consequences

- `sf-init` becomes responsible for creating the project umbrella in new or adopted projects.
- `sf-docs` becomes responsible for auditing and repairing umbrella layout drift.
- `sf-docs` must gain an explicit reorganize/adopt/update behavior that can move or stage moves for badly organized ShipFlow Markdown.
- `sf-content` must treat editorial docs under `shipflow_data/editorial/` as the canonical editorial governance layer.
- `sf-tasks` must write project-level tracker data under project-local `shipflow_data/` once the project is migrated; master aggregate trackers are deferred.
- Any skill that needs a document but finds it missing or non-compliant must report the required owner route rather than inventing a local workaround.
- `sf-help` must stop documenting `~/TASKS.md` symlinks if that is no longer active on the server.
- Existing specs and docs that reference root `BUSINESS.md`, root `CONTENT_MAP.md`, or `docs/technical/` must be updated to the new canonical paths.
- Existing central `shipflow_data` docs may need a later inventory, but that inventory is not part of this phase.

## Documentation Coherence

Update or audit:

- `README.md`
- `GUIDELINES.md`
- `ARCHITECTURE.md`
- `AGENT.md`
- `CONTEXT.md`
- `shipflow-metadata-migration-guide.md`
- `skills/references/canonical-paths.md`
- `skills/sf-init/SKILL.md`
- `skills/sf-docs/SKILL.md`
- `skills/sf-tasks/SKILL.md`
- `skills/sf-help/SKILL.md`
- `skills/sf-content/SKILL.md`
- `skills/sf-ship/SKILL.md`
- `skills/sf-verify/SKILL.md`
- `docs/technical/code-docs-map.md`
- `docs/technical/skill-runtime-and-lifecycle.md`
- `docs/technical/installer-and-user-scope.md`

## Edge Cases

- A project already has a real app-owned `shipflow_data/` directory for another purpose.
- A project already has a root `docs/technical/` used by app docs, not ShipFlow governance.
- A project has `BUSINESS.md` at root and `business.md` in the proposed umbrella with divergent content.
- A skill needs to update a document for its own workflow, but the current file is still in a legacy root path.
- `sf-docs` finds two plausible target folders for the same document category.
- A migration needs to move files across case-only path changes on a case-insensitive filesystem.
- Root discovery files need to mention the new corpus without duplicating moved governance documents.
- A symlink target is relative but escapes the repo with `../..`.
- A Windows checkout cannot use symlinks reliably.
- GitHub renders a symlink as a pointer file instead of exposing the target in the expected reading flow.
- A project is not a Git repo but still runs under ShipFlow.
- A central `shipflow_data/projects/<project>` directory already contains operational tracker files but is out of scope for this phase.
- Multiple local clones of the same project exist.

## Implementation Tasks

- [ ] Task 1: Decide the canonical folder name and namespace.
  - File: `specs/shipflow-data-project-umbrella-documentation-architecture.md`
  - Action: Record `shipflow_data/` as the canonical project-local folder name and remove alternatives from the spec.
  - User story link: Avoid future ambiguous docs and symlink models.
  - Depends on: Done by user decision on 2026-05-09.
  - Validate with: Spec has no folder-name alternatives.
  - Notes: The central repo with the same name is ignored for this phase.

- [ ] Task 2: Decide the canonical top-level categories.
  - File: `specs/shipflow-data-project-umbrella-documentation-architecture.md`
  - Action: Record that all project-owned ShipFlow Markdown belongs under `shipflow_data/`, including `technical/`, `editorial/`, `business/`, and `workflow/`.
  - User story link: Agents need predictable domain routing.
  - Depends on: Done by user decision on 2026-05-09.
  - Validate with: Scope and migration matrix use the same category list.
  - Notes: `workflow/` covers specs, bugs, audits, reviews, verification, and project-level trackers.

- [ ] Task 2b: Lock root discovery exceptions.
  - File: `skills/references/canonical-paths.md`, `shipflow-metadata-migration-guide.md`
  - Action: Record that `AGENT.md`, `CLAUDE.md`, and `README.md` remain at repo root, while `AGENTS.md` is a symlink to `AGENT.md`.
  - User story link: Agent/tool discovery must keep working while governance docs move.
  - Depends on: User decision on 2026-05-10.
  - Validate with: Root discovery files are named as exceptions and not treated as duplicate governance docs.
  - Notes: Root `BUSINESS.md`, `CONTENT_MAP.md`, and similar governance docs are not exceptions.

- [ ] Task 3: Create a path migration matrix.
  - File: `shipflow-metadata-migration-guide.md`
  - Action: Map current paths to new umbrella paths, including root exceptions.
  - User story link: Migration must be deterministic across projects.
  - Depends on: Tasks 1-2.
  - Validate with: Matrix covers `BUSINESS.md`, `PRODUCT.md`, `BRANDING.md`, `GTM.md`, `CONTENT_MAP.md`, `docs/technical/`, `docs/editorial/`, `specs/`, `bugs/`, `TASKS.md`, `AUDIT_LOG.md`, `PROJECTS.md`, and root discovery exceptions.
  - Notes: Preserve case and metadata decisions explicitly.

- [ ] Task 4: Update canonical path doctrine.
  - File: `skills/references/canonical-paths.md`
  - Action: Add project umbrella resolution rules and explicitly mark central sync/link behavior as out of scope for this phase.
  - User story link: Skills must stop guessing paths from current working directory or old root files.
  - Depends on: Tasks 1-3.
  - Validate with: `rg -n "project umbrella|shipflow_data|canonical" skills/references/canonical-paths.md`.
  - Notes: Keep `$SHIPFLOW_ROOT` for ShipFlow-owned source files distinct from project umbrella docs.

- [ ] Task 5: Update project initialization and docs skills.
  - File: `skills/sf-init/SKILL.md`, `skills/sf-docs/SKILL.md`
  - Action: Create and audit the umbrella instead of scattering docs at root and under mixed folders.
  - User story link: New and adopted projects should conform without manual cleanup.
  - Depends on: Task 4.
  - Validate with: Skill text names the new canonical paths and stop conditions.
  - Notes: `sf-init` must preserve existing app-owned root docs and report migration needs.

- [ ] Task 6: Add owner-skill routing for non-compliant documentation.
  - File: `skills/references/canonical-paths.md`, relevant owner skills, and non-owner skills that read or write project docs.
  - Action: Add a rule that non-owner skills must route missing or non-compliant project documentation to `sf-init` or `sf-docs` instead of writing legacy paths.
  - User story link: Skills must enforce the architecture instead of reintroducing scattered files.
  - Depends on: Tasks 3-5.
  - Validate with: `rg -n "non-compliant|sf-docs|reorganize|shipflow_data/" skills`.
  - Notes: Route to `sf-init` for first bootstrap/adoption; route to `sf-docs` for update, audit, and reorganization.

- [ ] Task 7: Add `sf-docs` reorganization behavior.
  - File: `skills/sf-docs/SKILL.md`, `shipflow-metadata-migration-guide.md`
  - Action: Define how `sf-docs` inventories scattered Markdown, classifies ownership, moves or stages moves into project-local `shipflow_data/`, and reports conflicts.
  - User story link: The document owner skill must fix bad organization, not only report it.
  - Depends on: Tasks 3-6.
  - Validate with: `sf-docs` contract includes creation, update, audit, and reorganization paths.
  - Notes: Reorganization must preserve metadata, use minimal moves, and stop on ambiguous duplicate content.

- [ ] Task 8: Reconcile tracker doctrine.
  - File: `skills/sf-tasks/SKILL.md`, `skills/sf-help/SKILL.md`, `GUIDELINES.md`, `README.md`
  - Action: Remove or rewrite old instructions about local `TASKS.md` symlinks and `~/TASKS.md` if they are no longer canonical.
  - User story link: The tracker model should not reintroduce broken symlinks.
  - Depends on: Tasks 1-4.
  - Validate with: `rg -n "~/TASKS|local TASKS|symlink to shipflow_data" skills GUIDELINES.md README.md`.
  - Notes: Project-level trackers move under project-local `shipflow_data/workflow/`; master aggregate trackers are deferred.

- [ ] Task 9: Add a symlink and hardcoded-home audit.
  - File: `tools/` and a new or existing test file.
  - Action: Add a check that reports versioned symlinks to `/home/*/shipflow_data`, absolute symlink targets inside Git, and generated templates containing `/home/ubuntu` or `/home/claude`.
  - User story link: Prevent recurrence of the SocialFlow conflict.
  - Depends on: Tasks 1-6.
  - Validate with: Check catches current `socialflow/TASKS.md`, `tubeflow_expo/TASKS.md`, and `tubeflow_flutter/tubeflow_lab/TASKS.md` in dry-run mode.
  - Notes: Avoid destructive cleanup in the checker.

- [ ] Task 10: Plan project-by-project migration.
  - File: `specs/shipflow-data-project-umbrella-documentation-architecture.md` or a generated migration report.
  - Action: Inventory each project and classify files before moving anything.
  - User story link: Migration must not erase app docs or user changes.
  - Depends on: Tasks 1-7.
  - Validate with: Migration report lists project, current ShipFlow Markdown files, target path, action, conflict status, and validation command.
  - Notes: Pilot is `dotfiles` because its git worktree is clean.

- [ ] Task 11: Migrate pilot project.
  - File: `/home/claude/dotfiles`
  - Action: Create umbrella, move classified files with `git mv` by default, and preserve root discovery files.
  - User story link: Prove the architecture on a real repo.
  - Depends on: Task 8 and user-selected pilot `dotfiles`.
  - Validate with: Metadata lint, symlink audit, git status, and skill path smoke checks.
  - Notes: Do not pilot on `socialflow` first despite its broken symlink; user selected `dotfiles` because it is clean.

- [ ] Task 12: Roll out migration across remaining projects.
  - File: Each selected project repo.
  - Action: Apply the pilot procedure sequentially, preserving unrelated dirty changes.
  - User story link: Make the architecture consistent workspace-wide.
  - Depends on: Task 9.
  - Validate with: Workspace-wide symlink audit, metadata lint, and skill smoke checks.
  - Notes: Do not batch destructive file moves across many repos without a clean migration report.

## Acceptance Criteria

- [x] Root tool-discovery compatibility and project-level tracker placement are decided.
- [ ] New project docs have one canonical umbrella path: `<project>/shipflow_data/`.
- [ ] The central `shipflow_data` repo is not used as a project documentation source of truth in this phase.
- [ ] All relevant skills resolve project ShipFlow Markdown through the new path doctrine.
- [ ] Non-owner skills route missing or non-compliant project documentation to `sf-init` or `sf-docs` instead of writing legacy paths.
- [ ] `sf-docs` can reorganize badly organized project ShipFlow Markdown into the project-local `shipflow_data/` layout or produce a conflict report.
- [ ] Existing versioned symlinks from projects to `shipflow_data` are removed, replaced by real project docs, or explicitly exempted with reason.
- [ ] No migrated project has duplicate canonical copies of the same ShipFlow decision artifact.
- [ ] Root `AGENT.md`, `CLAUDE.md`, and `README.md` remain real root files; `AGENTS.md` is a symlink to `AGENT.md`.
- [ ] `tools/shipflow_metadata_lint.py` can validate the new paths.
- [ ] A workspace audit can report no versioned symlink to `/home/*/shipflow_data`.

## Test Strategy

- Run shell syntax checks for touched scripts: `bash -n`.
- Run metadata lint on moved or newly created Markdown artifacts.
- Run a symlink audit across all Git repos under `$HOME`.
- Run `rg -n '/home/(ubuntu|claude)/shipflow_data|~/TASKS.md|local TASKS'` against ShipFlow skills and docs after doctrine updates.
- Run `rg -n "sf-docs|sf-init|non-compliant|reorganize|shipflow_data/" skills` to confirm owner-skill routing is documented.
- Run a pilot migration dry-run before any `git mv`.
- For each migrated project, inspect `git status --short`, `git diff --stat`, and sampled reads from the project-local `shipflow_data/` folder.

## Risks

- High migration risk: moving many Markdown files can break links, specs, skill references, and agent entrypoints.
- High doctrine risk: current docs intentionally kept project decision docs in project root; the new umbrella changes that path contract.
- Medium cross-platform risk: symlinks are fragile on Windows and some Git clients.
- Medium agent-discovery risk: moving `AGENT.md`, `CLAUDE.md`, or `README.md` fully under the umbrella could break tool conventions.
- Medium operational risk: mixing trackers with decision docs can recreate the original `TASKS.md` confusion.
- Low security risk: path migration itself is not security-sensitive, but hardcoded paths may leak local usernames and stale infrastructure assumptions.

## Execution Notes

- Do not migrate files in the same run that drafts this spec.
- Treat the user's phrase "Wispr Flow data" as likely voice transcription for "ShipFlow data" until confirmed.
- Prefer project-local canonical content. Do not add central symlink behavior in this phase.
- After the 2026-05-09 user decision, treat future sync direction as project repo -> master. Do not implement project symlinks pointing to master data.
- Prefer relative symlinks only when a symlink must be versioned.
- Ignore central operational files such as master `TASKS.md`, `AUDIT_LOG.md`, and `PROJECTS.md` for this phase.
- Preserve root discovery files as real files. Do not keep root compatibility pointers for moved governance docs such as `BUSINESS.md` or `CONTENT_MAP.md`.
- Use `git mv` by default for migrations so history remains readable.
- Pilot migration starts with `/home/claude/dotfiles`.

## Open Questions

None.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-05-09 21:04:33 UTC | sf-spec | GPT-5 Codex | Created draft spec for project-local ShipFlow data umbrella and central symlink architecture. | draft | Answer open questions, then run `/sf-ready specs/shipflow-data-project-umbrella-documentation-architecture.md` |
| 2026-05-09 21:17:17 UTC | sf-spec | GPT-5 Codex | Recorded user doctrine: project-local `shipflow_data/` is the source of truth; all project-owned ShipFlow Markdown belongs there; central master repo and sync are deferred. | draft updated | Decide root compatibility and pilot, then run `/sf-ready specs/shipflow-data-project-umbrella-documentation-architecture.md` |
| 2026-05-10 03:01:15 UTC | sf-spec | GPT-5 Codex | Added skill enforcement doctrine: non-owner skills route non-compliant docs to `sf-init` or `sf-docs`; `sf-docs` owns reorganization of badly organized files. | draft updated | Decide root compatibility and pilot, then run `/sf-ready specs/shipflow-data-project-umbrella-documentation-architecture.md` |
| 2026-05-10 03:01:15 UTC | sf-spec | GPT-5 Codex | Locked root discovery files, workflow folders, project trackers, forced doctrine, git-mv migration default, and dotfiles pilot. | draft decisions locked | Run `/sf-ready specs/shipflow-data-project-umbrella-documentation-architecture.md` |
| 2026-05-10 03:53:00 UTC | sf-ready | GPT-5 Codex | Evaluated readiness gate for project-local `shipflow_data/` umbrella architecture. | not ready | Resolve `Open Questions` to `None`, then rerun `/sf-ready specs/shipflow-data-project-umbrella-documentation-architecture.md` |
| 2026-05-10 03:58:00 UTC | sf-tasks | GPT-5 Codex | Moved future project repo -> master synchronization mechanism out of readiness scope and into task tracking. | draft updated | Rerun `/sf-ready specs/shipflow-data-project-umbrella-documentation-architecture.md` |
| 2026-05-10 08:20:19 UTC | sf-ready | GPT-5 Codex | Re-evaluated readiness after closing open questions and parking future sync in task tracking. | ready | Run `/sf-start ShipFlow Data Project Umbrella Documentation Architecture` |

## Current Chantier Flow

sf-ready passed. The project-local `shipflow_data/` umbrella architecture is ready for implementation. The future project repo -> master synchronization mechanism is tracked as deferred work outside this spec. Next lifecycle step is `/sf-start ShipFlow Data Project Umbrella Documentation Architecture`.
