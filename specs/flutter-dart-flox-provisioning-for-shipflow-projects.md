---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "shipflow"
created: "2026-05-02"
created_at: "2026-05-02 11:53:16 UTC"
updated: "2026-05-02"
updated_at: "2026-05-02 13:48:16 UTC"
status: ready
source_skill: sf-spec
source_model: "GPT-5 Codex"
scope: "runtime-provisioning"
owner: "unknown"
user_story: "As a ShipFlow operator auditing and running Flutter projects, I want ShipFlow to provision Flutter and Dart runtimes through each project's Flox environment, so audits, launches, and verification commands do not fail just because Flutter is absent from the global PATH."
risk_level: "medium"
confidence: "high"
security_impact: "yes"
docs_impact: "yes"
linked_systems:
  - "lib.sh"
  - "config.sh"
  - "install.sh"
  - "README.md"
  - "docs/technical/runtime-cli.md"
  - "docs/technical/installer-and-user-scope.md"
  - "docs/technical/code-docs-map.md"
  - "Flutter/Dart projects with pubspec.yaml"
  - "Flox project environments"
depends_on:
  - artifact: "BUSINESS.md"
    artifact_version: "1.1.0"
    required_status: "reviewed"
  - artifact: "PRODUCT.md"
    artifact_version: "1.1.0"
    required_status: "reviewed"
  - artifact: "GUIDELINES.md"
    artifact_version: "1.3.0"
    required_status: "reviewed"
  - artifact: "ARCHITECTURE.md"
    artifact_version: "1.0.0"
    required_status: "reviewed"
  - artifact: "README.md"
    artifact_version: "0.5.0"
    required_status: "draft"
  - artifact: "docs/technical/runtime-cli.md"
    artifact_version: "1.0.0"
    required_status: "reviewed"
  - artifact: "docs/technical/installer-and-user-scope.md"
    artifact_version: "1.0.0"
    required_status: "reviewed"
  - artifact: "docs/technical/code-docs-map.md"
    artifact_version: "1.0.0"
    required_status: "reviewed"
supersedes: []
evidence:
  - "Local PATH check: command -v flutter and command -v dart returned no global binary; command -v flox returned /usr/bin/flox."
  - "Local Flox check: /home/ubuntu/voiceflowz has flutter.pkg-path = \"flutter\" and flox activate -- flutter --version returns Flutter 3.41.5 / Dart 3.11.3."
  - "Current Flutter projects found under /home/ubuntu: contentflow_app, shipflow_app, tubeflow_app, voiceflowz."
  - "contentflow_app and shipflow_app have .flox manifests but no flutter or dart runtime entry; tubeflow_app has no .flox manifest; voiceflowz has flutter configured."
  - "lib.sh detects pubspec.yaml and classifies Flutter projects, but init_flox_env currently warns when global flutter is absent instead of installing Flutter into Flox."
  - "Flox official docs say flox install is transactional, supports -d for a target environment, allows package@version constraints, and stores package descriptors in manifest [install] entries."
  - "Local Flox 1.8.1 smoke: duplicate install of hello into a temp env exited successfully with a warning that package id hello was already installed."
  - "User decision 2026-05-02: follow the recommended strict package override policy; runtime package overrides accept only simple Flox package tokens and reject paths, flake installables, quotes, and shell metacharacters."
  - "sf-ready 2026-05-02 found one remaining validation gap: option-like package tokens beginning with '-' must be rejected before invoking flox install."
next_step: "/sf-start Flutter Dart Flox Provisioning for ShipFlow Projects"
---

# Spec: Flutter Dart Flox Provisioning for ShipFlow Projects

## Title

Flutter Dart Flox Provisioning for ShipFlow Projects

## Status

ready

## User Story

As a ShipFlow operator auditing and running Flutter projects, I want ShipFlow to provision Flutter and Dart runtimes through each project's Flox environment, so audits, launches, and verification commands do not fail just because Flutter is absent from the global PATH.

## Minimal Behavior Contract

When ShipFlow detects a Dart or Flutter project through `pubspec.yaml`, starting or preparing that project must ensure the required runtime is present in the project's Flox environment before any `dart`, `flutter`, audit, or PM2 launch command is treated as valid. If the Flox environment is missing, ShipFlow creates it and installs the configured runtime packages; if the environment already exists but lacks the runtime, ShipFlow repairs it idempotently. On failure, ShipFlow must stop with an actionable diagnostic naming the project path, detected project kind, package string attempted, and the operator command to retry or override. The easy edge case to miss is an existing `.flox` directory that was created earlier but contains no Flutter package: returning early from `init_flox_env` must not continue to leave that project broken.

## Success Behavior

- Preconditions: `flox` is installed, a project has `pubspec.yaml`, and the project is detected as `flutter` or plain `dart`.
- Trigger: an operator starts the project through ShipFlow, or runs the new focused runtime-provisioning path during implementation validation.
- User/operator result: the operator sees that ShipFlow installed or verified the Dart/Flutter runtime for that project; `flox activate -- flutter --version` works for Flutter projects and `flox activate -- dart --version` works for Dart projects.
- System effect: the project `.flox/env/manifest.toml` contains the configured runtime package entry after provisioning, and PM2 launch commands can rely on `flox activate` rather than a global Flutter installation.
- Success proof: a temporary Flutter fixture or one current local Flutter project can run `flox activate -- flutter --version`, and static shell checks pass for touched scripts.
- Silent success: allowed only for idempotent no-op package installs where a later explicit version check proves the runtime is available.

## Error Behavior

- Expected failures: `flox` missing, `flox init` failure, unsafe configured package token, package unavailable in the current Flox catalog, network/download failure, unsupported architecture, corrupted `.flox`, or a project with `pubspec.yaml` but no usable Flutter web target.
- User/operator response: ShipFlow prints a direct error with the detected kind, target directory, package string, and a retry hint such as `flox install -d <project> <package>` or the relevant `SHIPFLOW_FLOX_*_PACKAGES` override.
- System effect: startup must stop before PM2 writes a misleading online process or before audit commands report secondary `flutter: command not found` errors.
- Must never happen: ShipFlow must not tell the operator to install Flutter globally as the primary fix for a project Flox environment that it can repair itself.
- Must never happen: a failed package install must not be hidden behind `tail -1`, `|| true`, or a warning that lets the runtime command proceed.
- Must never happen: runtime package overrides must not be executed through `eval`, shell interpolation, local paths, Nix flake installables, store paths, option-like tokens beginning with `-`, or unvalidated package strings.
- Silent failure: not allowed.

## Problem

ShipFlow already uses Flox as the runtime isolation layer, and it already detects Flutter projects from `pubspec.yaml`. But the Flutter branch in `init_flox_env` only checks the global `PATH`; when `flutter` is absent globally, it prints a warning and points to `sf -> Install SDK`. That path solves the current machine, not the durable per-project environment.

The local workspace shows the mismatch clearly:

- `/home/ubuntu/voiceflowz` has Flutter in Flox and `flox activate -- flutter --version` works.
- `/home/ubuntu/contentflow/contentflow_app` has `.flox` but no Flutter runtime.
- `/home/ubuntu/shipflow_app` has `.flox` but no Flutter runtime.
- `/home/ubuntu/tubeflow_flutter/tubeflow_app` has no `.flox` manifest.
- Global `flutter` and `dart` are absent.

The operational consequence is that code audits, `flutter analyze`, `flutter test`, and Flutter web launch checks get blocked by local tooling rather than by app defects. With several Flutter projects now active, the correct fix is to make ShipFlow's Flox provisioning path own Flutter and Dart runtimes.

## Solution

Add a focused runtime-provisioning layer for Flox projects and make it idempotent for both new and existing `.flox` environments. The implementation should:

- add explicit configurable Flox package defaults for Dart and Flutter in `config.sh`;
- install Dart or Flutter packages into the project Flox env with `flox install -d "$project_dir" ...`;
- call the same ensure logic when `.flox` already exists, not only after `flox init`;
- keep global `/opt/flutter` installation as an optional operator convenience, not the default repair path;
- improve diagnostics so the operator can distinguish "Flox missing", "package install failed", "runtime not available after install", and "app has no web target";
- update README and technical docs to record the per-project Flox strategy.

For the current local projects, the implementation should validate the repair path on a disposable fixture or one explicit project path chosen by the implementer. It must not modify unrelated app code.

## Scope In

- Add `SHIPFLOW_FLOX_DART_PACKAGES` and `SHIPFLOW_FLOX_FLUTTER_PACKAGES` defaults in `config.sh`.
- Default Flutter package string should be a stable Flox package known to work locally, currently `flutter@3.41.5-sdk-links`, unless readiness or implementation evidence explicitly updates the default.
- Add or refactor a helper in `lib.sh` that ensures language-specific packages are installed in a target Flox env.
- Make `init_flox_env` repair existing `.flox` envs for detected project type before returning success.
- Make Flutter projects install configured Flutter package(s) in Flox instead of only warning about missing global Flutter.
- Preserve the plain Dart path by using configured Dart packages for `dart` projects.
- Validate configured Dart/Flutter Flox package overrides before installation; accept only simple whitespace-separated Flox package tokens such as `dart`, `flutter@3.41.5-sdk-links`, or `python312Packages.pytest`, and reject paths, Nix flake installables, store paths, option-like tokens that begin with `-`, quotes, shell metacharacters, command substitutions, and empty tokens.
- Improve operator diagnostics for runtime provisioning failures.
- Update `README.md`, `docs/technical/runtime-cli.md`, and `docs/technical/installer-and-user-scope.md` to state that Flutter/Dart project runtimes are provisioned per project through Flox.
- Update `CONTEXT-FUNCTION-TREE.md` only if function boundaries or key flow names change.
- Add focused tests or shell smoke checks for project kind detection and runtime package ensure behavior.
- Record in the final implementation report which current local Flutter projects remain unmodified, repaired, or validated.

## Scope Out

- Do not make Flutter a required global ShipFlow prerequisite.
- Do not install Flutter globally from `sudo ./install.sh` by default.
- Do not remove the existing `Install SDK` menu; it remains an optional global convenience.
- Do not auto-install `pytest`, `pip-audit`, or `turso` in this chantier. They are project-specific verification tools and should be handled by a separate audit-tooling spec if needed.
- Do not change Flutter app source code, dependencies, `pubspec.yaml`, or `pubspec.lock` files in app repositories.
- Do not upgrade Flox itself from the installer in this chantier, even though the official current install docs show a newer Flox release than the local `install.sh` pin.
- Do not introduce a broad package manager abstraction or rewrite the environment lifecycle.

## Constraints

- Keep changes focused around `config.sh`, `lib.sh`, install/operator docs, and focused tests.
- Use existing Bash style, logging helpers, `warning`, `error`, `info`, and idempotent operation patterns.
- Prefer `flox install -d "$project_dir" ...` so the target project is explicit and the helper does not depend on process cwd.
- Do not parse Flox TOML with fragile grep as the source of truth when the CLI can provide an idempotent install path; grep proof is acceptable only in tests or diagnostics.
- Do not swallow package-install failures for required runtimes.
- Keep `detect_dev_command` compatible with PM2 wrapping commands in `flox activate`.
- Keep generated `ecosystem.config.cjs` behavior unchanged except where runtime availability affects the command before launch.
- Keep root-level installer behavior explicit and non-destructive.
- Treat `SHIPFLOW_FLOX_DART_PACKAGES` and `SHIPFLOW_FLOX_FLUTTER_PACKAGES` as untrusted configuration input: parse them as whitespace-separated tokens, reject anything outside a simple token allowlist such as `^[A-Za-z0-9][A-Za-z0-9._+-]*(@[A-Za-z0-9][A-Za-z0-9._+-]*)?$`, reject option-like tokens whose package or version part starts with `-`, and never use `eval`.
- ShipFlow language doctrine applies: internal contracts, section headings, env vars, validation notes, and technical docs stay English; touched user/operator CLI messages stay in the active project language, which is French for the current runtime CLI, with natural accents. Commands, package ids, paths, and env vars remain literal.

## Dependencies

- Local runtime:
  - Bash
  - Flox local version observed: `1.8.1`
  - Flox catalog currently exposes `flutter@3.41.6-sdk-links`, `flutter@3.41.5-sdk-links`, and related historical versions.
  - Local proven package: `flutter@3.41.5-sdk-links` in `/home/ubuntu/voiceflowz`.
- Official fresh docs:
  - `fresh-docs checked`
  - Context7 source: `/websites/flox_dev` official Flox docs
  - Flox `flox install` docs: https://flox.dev/docs/reference/command-reference/flox-install
  - Flox `manifest.toml` docs: https://flox.dev/docs/reference/command-reference/manifest
  - Flox install docs: https://flox.dev/docs/install-flox/install/
- Relevant current Flox rules from docs:
  - `flox install` accepts `<package>@<version>`.
  - `flox install -d <path>` targets a specific environment directory.
  - package installation is transactional and atomically updates the environment on success.
  - manifest `[install]` entries store package descriptors with `pkg-path` and optional version.
- Local Flox behavior:
  - Local Flox 1.8.1 supports `flox install -d <path> <package>@<version>` according to `flox install --help`.
  - Local `flox install --help` shows leading-dash arguments are parsed as command options, so operator-configured package tokens must not be allowed to begin with `-`.
  - Duplicate install of a simple package in a temp env exits successfully with a warning that the package id is already installed; the implementation must still verify runtime availability after install instead of relying only on duplicate-install semantics.
- Local code contracts:
  - `lib.sh::detect_pubspec_kind`
  - `lib.sh::detect_project_type`
  - `lib.sh::init_flox_env`
  - `lib.sh::detect_dev_command`
  - `config.sh` Flox package defaults
  - `install.sh` optional global SDK path

## Invariants

- Flox remains the official runtime isolation layer for managed projects.
- A Flutter project's primary runtime should come from project Flox, not global `/opt/flutter`.
- Global Flutter installation remains optional and must not be required for audits or project launch if Flox can provide Flutter.
- Missing required runtime packages must fail early and visibly.
- PM2 cache and port allocation behavior must not change.
- Project path validation and absolute path requirements remain unchanged.
- Documentation must not imply that `sudo ./install.sh` always installs Flutter globally.
- Runtime package override variables are not trusted code or trusted paths; only simple Flox package tokens are allowed.
- Touched CLI diagnostics remain French user-facing text while technical contracts and documentation sections remain English.

## Links & Consequences

- Upstream:
  - ShipFlow operator invokes `sf`, `env_start`, or audit workflows.
  - Project manifests (`pubspec.yaml`) determine Dart vs Flutter.
  - Flox catalog supplies packages.
- Downstream:
  - PM2 launch command relies on `flox activate`.
  - Flutter audit commands such as `flutter analyze` and `flutter test` can run inside the project env.
  - Existing projects with blank `.flox` manifests get repaired on next ShipFlow provisioning path.
- Regression surface:
  - Node, Python, Rust, and Go provisioning must continue to work.
  - Existing `.flox` projects must not be skipped if missing required language runtime packages.
  - The optional global SDK menu must still work for operators who want `/opt/flutter`.
- Operational consequence:
  - First run on a Flutter project may take longer while Flox installs Flutter.
  - Offline or unavailable Flox catalog states now produce a hard runtime provisioning error instead of a later secondary command-not-found error.

## Documentation Coherence

- Update `README.md` server environment or install sections to say Flutter/Dart runtimes are project Flox packages, and global Flutter SDK install is optional.
- Update `docs/technical/runtime-cli.md` to document the new ensure flow for existing `.flox` envs.
- Update `docs/technical/installer-and-user-scope.md` to clarify that `install.sh` does not install Flutter globally by default and why.
- Update `CONTEXT-FUNCTION-TREE.md` if a new helper becomes a meaningful entry in the environment lifecycle.
- Do not update `CHANGELOG.md`; closeout or ship workflow owns changelog.

## Edge Cases

- Existing `.flox` env with no Flutter entry: must be repaired.
- Existing `.flox` env with a different Flutter version: `flox install` may keep both, update, or no-op depending on install ID; implementation must avoid destructive uninstall and report the observed result.
- `pubspec.yaml` includes `flutter:` but no `web/` directory: runtime provisioning may succeed, but `detect_dev_command` should still fail with the existing no-web-target message.
- Flox package unavailable on architecture: fail with package string and architecture context if practical.
- Global Flutter exists but project Flox lacks Flutter: project Flox should still be ensured, because PM2 launches through `flox activate`.
- Flox exists but network is down: fail before PM2 launch and make the retry path explicit.
- Multiple Flutter projects share no global SDK: each project gets its own manifest entry through Flox.
- Unsafe runtime package override such as a local path, flake installable, option-like token beginning with `-`, quote, semicolon, pipe, `$()`, backtick, or empty token: fail before invoking `flox install`, explain the accepted token shape, and do not start PM2.

## Implementation Tasks

- [ ] Task 1: Add configurable Dart and Flutter Flox package defaults.
  - File: `config.sh`
  - Action: Add `SHIPFLOW_FLOX_DART_PACKAGES` and `SHIPFLOW_FLOX_FLUTTER_PACKAGES` near existing Flox package defaults. Use `dart` for Dart and `flutter@3.41.5-sdk-links` for Flutter unless readiness changes the version with evidence.
  - User story link: Gives ShipFlow a durable runtime contract instead of relying on global PATH.
  - Depends on: none
  - Validate with: `bash -n config.sh`; `source config.sh && printf '%s\n' "$SHIPFLOW_FLOX_FLUTTER_PACKAGES"`
  - Notes: Keep package strings overrideable by environment variables, but override values must be validated before use.

- [ ] Task 2: Add an idempotent helper to ensure Flox runtime packages for a project.
  - File: `lib.sh`
  - Action: Create a helper such as `ensure_flox_runtime_packages(project_dir, lang, pm)` that chooses package strings from config, validates each token with a strict simple-token allowlist, and runs `flox install -d "$project_dir" ...` for required runtimes.
  - User story link: Makes new and existing Flox environments self-healing for Flutter/Dart runtime availability.
  - Depends on: Task 1
  - Validate with: `bash -n lib.sh`; focused shell smoke with a temporary Flox env if practical; negative checks with `SHIPFLOW_FLOX_FLUTTER_PACKAGES='flutter;touch /tmp/bad'` and `SHIPFLOW_FLOX_FLUTTER_PACKAGES='--help'` must fail before `flox install`.
  - Notes: Required runtime package install failures must return non-zero. Use arrays or careful word splitting consistent with existing package-list config. Do not use `eval`; reject local paths, Nix flake installables, store paths, option-like tokens beginning with `-`, quotes, shell metacharacters, command substitutions, and empty tokens.

- [ ] Task 3: Call the runtime ensure helper for both new and existing `.flox` environments.
  - File: `lib.sh`
  - Action: Refactor `init_flox_env` so it detects project type before the early `.flox` return, calls the ensure helper even when `.flox` already exists, and removes the Flutter branch that only warns about missing global Flutter.
  - User story link: Fixes the observed broken case where `.flox` exists but Flutter is absent.
  - Depends on: Task 2
  - Validate with: a temp project containing Flutter-style `pubspec.yaml` and an existing empty `.flox`, then verify `flox activate -- flutter --version` or inspect `flox list -d`.
  - Notes: Preserve existing dependency install behavior for Node and Python; if broader language ensure changes are made, keep them explicit and tested.

- [ ] Task 4: Improve runtime diagnostics around Flutter/Dart provisioning.
  - File: `lib.sh`
  - Action: Replace the current "install via Advanced > Install SDK" primary warning with errors or info that explain project Flox provisioning, package string, retry command, and optional global SDK fallback.
  - User story link: Operators should see the real fix instead of secondary `flutter: command not found` failures.
  - Depends on: Task 3
  - Validate with: forced failure scenario using an unavailable package and a separate unsafe-token override in a temp env, verifying the message includes project path, detected kind, package string when safe to print, and retry or override guidance.
  - Notes: The optional global SDK menu can still be mentioned as secondary convenience, not required fix. Visible CLI diagnostics touched by this task should remain French with accents, matching current runtime UI.

- [ ] Task 5: Add focused tests or shell smoke checks for pubspec runtime provisioning.
  - File: `test_priority3.sh` or a new focused shell test file
  - Action: Add coverage for Flutter project detection, Dart project detection, config variables, package-token validation, and helper existence. If live Flox install is too heavy for default tests, make the live install smoke manual or guarded.
  - User story link: Prevents regression to a warning-only Flutter branch.
  - Depends on: Task 3
  - Validate with: `./test_priority3.sh` or the new focused test command.
  - Notes: Avoid requiring network-heavy Flutter downloads in the default fast test unless the environment explicitly opts in.

- [ ] Task 6: Update runtime and installer documentation.
  - File: `README.md`
  - Action: Document that Flutter/Dart project runtimes are provisioned through project Flox envs; global Flutter install remains optional.
  - User story link: Sets the right operator expectation before audits and project launch.
  - Depends on: Task 4
  - Validate with: `rg -n "Flutter|Dart|Flox|Install SDK|project Flox" README.md`
  - Notes: Keep public wording precise and do not claim all audit tools are globally installed.

- [ ] Task 7: Update technical docs mapped to touched code.
  - File: `docs/technical/runtime-cli.md`
  - Action: Add the Flutter/Dart provisioning flow and the existing `.flox` repair invariant.
  - User story link: Fresh agents can understand the runtime contract without reading this conversation.
  - Depends on: Task 4
  - Validate with: `python3 tools/shipflow_metadata_lint.py docs/technical/runtime-cli.md`
  - Notes: Update `CONTEXT-FUNCTION-TREE.md` too if function topology changes materially.

- [ ] Task 8: Update installer scope docs.
  - File: `docs/technical/installer-and-user-scope.md`
  - Action: Clarify that root install provisions Flox itself, while Flutter/Dart are per-project Flox packages unless the operator chooses optional global SDK install.
  - User story link: Prevents operators from expecting `sudo ./install.sh` to install every project runtime globally.
  - Depends on: Task 6
  - Validate with: `python3 tools/shipflow_metadata_lint.py docs/technical/installer-and-user-scope.md`
  - Notes: Do not add global Flutter to installer by default.

- [ ] Task 9: Run local remediation or validation against current Flutter projects.
  - File: no source file unless the implementer chooses an explicit current project `.flox` manifest to repair
  - Action: After code changes, validate the new behavior against a temp fixture and optionally run the repair path on `/home/ubuntu/contentflow/contentflow_app`, `/home/ubuntu/shipflow_app`, or `/home/ubuntu/tubeflow_flutter/tubeflow_app` if it is safe and explicit in the implementation report.
  - User story link: Proves the original audit blocker is resolved in practice.
  - Depends on: Tasks 1-4
  - Validate with: `flox activate -- flutter --version` from a repaired Flutter project or temp fixture.
  - Notes: Do not edit app source code or dependency lockfiles.

## Acceptance Criteria

- [ ] CA 1: Given a Flutter project with no `.flox`, when ShipFlow initializes it, then the resulting project env contains the configured Flutter package and `flox activate -- flutter --version` succeeds.
- [ ] CA 2: Given a Flutter project with an existing `.flox` that lacks Flutter, when ShipFlow prepares or starts it, then ShipFlow installs or verifies Flutter in that env instead of returning early.
- [ ] CA 3: Given a plain Dart project, when ShipFlow initializes or repairs the env, then the configured Dart package is installed and `flox activate -- dart --version` succeeds.
- [ ] CA 4: Given global `flutter` is absent but project Flox can provide Flutter, when the operator starts the project, then ShipFlow does not instruct global Flutter installation as the primary fix.
- [ ] CA 5: Given the configured Flutter package is invalid or unavailable, when provisioning runs, then ShipFlow stops before PM2 launch and prints project path, detected kind, package string, and retry or override guidance.
- [ ] CA 6: Given a Flutter project has no `web/` directory or custom PM2/build script, when runtime provisioning succeeds, then ShipFlow still reports the existing no-web-target error instead of masking it as a runtime failure.
- [ ] CA 7: Given README and technical docs are read by a fresh agent, when they look for Flutter/Dart strategy, then they understand per-project Flox provisioning and optional global SDK installation.
- [ ] CA 8: Given the touched shell files are checked, when `bash -n` runs on them, then no syntax error is reported.
- [ ] CA 9: Given docs metadata lint runs on touched technical docs, when validation completes, then no metadata error is reported.
- [ ] CA 10: Given `SHIPFLOW_FLOX_FLUTTER_PACKAGES` contains a path, flake installable, option-like token beginning with `-` such as `--help`, quote, shell metacharacter, command substitution, or empty token, when provisioning runs, then ShipFlow rejects the override before invoking `flox install`, prints an actionable French diagnostic, and does not start PM2.
- [ ] CA 11: Given touched user-facing CLI diagnostics are displayed, when an operator reads them, then the visible prose remains natural French while commands, env vars, package ids, and paths remain literal.

## Test Strategy

- Static:
  - `bash -n config.sh lib.sh install.sh`
  - `python3 tools/shipflow_metadata_lint.py docs/technical/runtime-cli.md docs/technical/installer-and-user-scope.md`
  - `rg -n "SHIPFLOW_FLOX_DART_PACKAGES|SHIPFLOW_FLOX_FLUTTER_PACKAGES|ensure_flox_runtime|flutter@|Install SDK|flox install -d" config.sh lib.sh README.md docs/technical`
- Focused shell:
  - Source `config.sh` and `lib.sh`, create temp projects with `pubspec.yaml`, and test `detect_pubspec_kind` / `detect_project_type`.
  - Use a disposable `.flox` env for live provisioning only when network and disk budget allow.
- Live validation:
  - In a safe Flutter project or temp fixture, run `flox activate -- flutter --version`.
  - If validating a current project, prefer `contentflow_app` or `shipflow_app` because they already have `.flox` but lack Flutter; report exactly which one was touched.
- Negative validation:
  - Temporarily set `SHIPFLOW_FLOX_FLUTTER_PACKAGES=definitely-not-a-real-package` in a temp project and verify failure is visible and actionable.
  - Temporarily set `SHIPFLOW_FLOX_FLUTTER_PACKAGES='flutter;touch /tmp/shipflow-bad'` in a temp project and verify the unsafe token is rejected before `flox install`, without creating the marker file.
  - Temporarily set `SHIPFLOW_FLOX_FLUTTER_PACKAGES='--help'` and `SHIPFLOW_FLOX_FLUTTER_PACKAGES='-v'` in a temp project and verify both option-like tokens are rejected before `flox install`.
- Language validation:
  - Review touched CLI strings for natural French user-facing prose and literal English technical identifiers.
- Not required:
  - Full Flutter app tests across every project.
  - Global Flutter install.
  - `pytest`, `pip-audit`, or `turso` installation.

## Risks

- Flox package install is network-heavy and may be slow for Flutter. Mitigation: keep default fast tests mocked or guarded; make live provisioning a focused validation, not a mandatory unit test.
- Local Flox version is `1.8.1` while current official docs show newer Flox install guidance. Mitigation: use CLI-compatible `flox install -d` behavior verified locally; do not upgrade Flox in this chantier.
- Installing a configured package into an existing `.flox` env could expose package conflicts. Mitigation: Flox install is transactional; report failure and leave env unmodified on build failure.
- Choosing a pinned Flutter package can become stale. Mitigation: keep the package string configurable and document how to override it.
- Existing projects may already have project-specific runtime choices. Mitigation: avoid destructive uninstall or manifest rewrites; use idempotent install and report observed state.
- Security impact: yes. Mitigation: treat Flox package overrides as untrusted input; accept only simple package tokens that start with an alphanumeric character; reject paths, flake installables, store paths, option-like leading-dash tokens, quotes, shell metacharacters, command substitutions, and empty tokens; use quoted arrays or equivalent safe shell handling; do not use `eval`; target only the validated project directory; log package ids and project paths but do not dump environment values or secrets.
- Supply-chain impact: yes, bounded by Flox catalog and operator-configured package ids. Mitigation: default to the locally proven Flutter package, keep official Flox behavior documented, fail visibly on catalog/package errors, and do not install arbitrary local packages through this path.
- Availability impact: Flutter install can be slow or network-heavy. Mitigation: keep fast tests guarded and make runtime provisioning fail before PM2 launch with retry guidance when network or catalog access fails.

## Execution Notes

- Read first:
  - `CLAUDE.md`
  - `CONTEXT.md`
  - `docs/technical/code-docs-map.md`
  - `docs/technical/runtime-cli.md`
  - `docs/technical/installer-and-user-scope.md`
  - `config.sh`
  - `lib.sh` around `check_prerequisites`, `install_sdk_menu`, `detect_pubspec_kind`, `detect_project_type`, `init_flox_env`, and `detect_dev_command`
  - `install.sh` around Flox and system tool installation only if docs or optional global SDK behavior changes
- Implementation approach:
  1. Add config variables.
  2. Add helper for explicit target env package install.
  3. Refactor `init_flox_env` so existing `.flox` envs are ensured before success.
  4. Improve diagnostics and remove warning-only Flutter behavior.
  5. Add focused tests/smokes.
  6. Update docs.
  7. Validate with static checks, then one live Flox/Flutter proof if practical.
- Packages to use:
  - Flox package strings from config only.
  - Default Flutter package currently `flutter@3.41.5-sdk-links`.
  - Override tokens must match the simple Flox package-token policy, for example `dart`, `flutter@3.41.5-sdk-links`, or `python312Packages.pytest`. The accepted shape is `^[A-Za-z0-9][A-Za-z0-9._+-]*(@[A-Za-z0-9][A-Za-z0-9._+-]*)?$`; tokens such as `--help`, `-v`, and `-i` are invalid even though they contain no shell metacharacters.
- Packages to avoid:
  - Do not add a new dependency parser or TOML parser.
  - Do not add npm, Python, or Dart package dependencies to ShipFlow for this change.
  - Do not support local paths, Nix flake installables, store paths, option-like leading-dash tokens, quotes, shell metacharacters, command substitutions, or arbitrary shell fragments in runtime package overrides.
- Security approach:
  - Validate package override tokens before constructing the `flox install` command.
  - Reject package tokens before command construction if the whole token or the part after `@` starts with `-`; do not rely on `flox install` to distinguish package ids from CLI options.
  - Build command arguments without `eval`; prefer arrays or a small validated token list.
  - If validation fails, print a French diagnostic that explains the allowed form and stops before `flox install`.
- Language approach:
  - Keep user/operator CLI messages in French, because the current runtime CLI messages around `init_flox_env` and SDK installation are French.
  - Keep technical docs, stable section headings, env vars, commands, and package ids in English/literal form.
- Stop conditions:
  - Stop and reroute if Flox 1.8.1 cannot support `flox install -d` with package version constraints.
  - Stop and reroute if the implementation would require global Flutter installation to satisfy the core user story.
  - Stop and ask before mutating app project source files or `pubspec.lock`.
  - Stop and route to a separate spec if `pytest`, `pip-audit`, or `turso` auto-provisioning becomes necessary.

## Open Questions

None

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-05-02 11:53:16 UTC | sf-spec | GPT-5 Codex | Created a spec for durable Flutter/Dart runtime provisioning through project Flox environments, based on local audit blockers and current Flox docs. | draft saved | /sf-ready Flutter Dart Flox Provisioning for ShipFlow Projects |
| 2026-05-02 12:33:17 UTC | sf-ready | GPT-5 Codex | Evaluated readiness against the spec-driven Definition of Ready, local Flox evidence, language doctrine, fresh Flox docs, adversarial workflow risks, and proportional security review. | not ready | /sf-spec Flutter Dart Flox Provisioning for ShipFlow Projects |
| 2026-05-02 12:38:44 UTC | sf-spec | GPT-5 Codex | Updated the spec after readiness review and user decision to follow the strict package override recommendation, adding security mitigations, language doctrine, corrected Flox evidence, and closed open questions. | draft updated | /sf-ready Flutter Dart Flox Provisioning for ShipFlow Projects |
| 2026-05-02 12:46:37 UTC | sf-ready | GPT-5 Codex | Re-evaluated readiness after the sf-spec update and found one remaining package-token validation gap: option-like tokens beginning with `-` are not explicitly rejected by the spec's allowlist. | not ready | /sf-spec Flutter Dart Flox Provisioning for ShipFlow Projects |
| 2026-05-02 12:50:06 UTC | sf-spec | GPT-5 Codex | Updated the package-token contract to reject option-like leading-dash tokens before `flox install`, added negative validation cases, and routed the chantier back to readiness. | draft updated | /sf-ready Flutter Dart Flox Provisioning for ShipFlow Projects |
| 2026-05-02 13:12:47 UTC | sf-ready | GPT-5 Codex | Re-evaluated the updated spec against structure, user-story alignment, execution readiness, language doctrine, fresh Flox docs, adversarial workflow risks, and security guardrails. | ready | /sf-start Flutter Dart Flox Provisioning for ShipFlow Projects |
| 2026-05-02 13:33:32 UTC | sf-start | GPT-5 Codex | Implemented Flutter/Dart project Flox runtime provisioning with strict override validation, existing `.flox` repair path, focused runtime tests, and runtime/installer docs updates. | implemented | /sf-verify Flutter Dart Flox Provisioning for ShipFlow Projects |
| 2026-05-02 13:41:27 UTC | sf-verify | GPT-5 Codex | Verified implementation against the ready spec, corrected stable gaps in override preservation and global SDK fallback commands, ran static checks, focused tests, metadata lint, fresh Flox docs check, and live temp `.flox` Flutter repair validation. | verified | /sf-end Flutter Dart Flox Provisioning for ShipFlow Projects |
| 2026-05-02 13:48:16 UTC | sf-ship | GPT-5 Codex | Closed the task in trackers/changelog, ran full-mode checks, committed the Flutter/Dart Flox provisioning scope, and pushed it to `main`. | shipped | none |

## Current Chantier Flow

- sf-spec: done
- sf-ready: ready
- sf-start: implemented
- sf-verify: verified
- sf-end: closed via sf-ship full mode
- sf-ship: shipped

Next command:

```text
none
```
