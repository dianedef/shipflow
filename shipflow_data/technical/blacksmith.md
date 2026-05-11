---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "0.3.1"
project: ShipFlow
created: "2026-05-10"
updated: "2026-05-11"
status: draft
source_skill: sf-docs
scope: blacksmith-ci-observability-and-apk-builds
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - Blacksmith
  - GitHub Actions
  - Android APK debug builds
  - Tauri mobile builds
  - Flutter Android builds
  - socialflow/.github/workflows/dev-builds.yml
  - voiceflowz/.github/workflows/android-build.yml
depends_on: []
supersedes: []
evidence:
  - "Official Blacksmith docs reviewed on 2026-05-10: Quickstart, Instance Types, Logs, Run History, SSH Access, Monitors, Metrics, Test Analytics, Actions cache, Sticky Disks, Static IP, Network & IP Allowlisting, Testboxes."
  - "Official Blacksmith docs rechecked on 2026-05-11: Actions cache, Logs, Run History, and Testboxes pages still support the current guidance; legacy useblacksmith cache forks are archived and upstream GitHub actions are preferred."
  - "Local SocialFlow workflow observed with Android debug APK build on blacksmith-2vcpu-ubuntu-2404."
  - "Local VoiceFlowz workflow observed with Flutter Android CI and Firestore deploy jobs on blacksmith-2vcpu-ubuntu-2404."
  - "Operator confirmed on 2026-05-10 that Blacksmith SSH Access has been authorized."
next_review: "2026-06-11"
next_step: "/sf-spec Blacksmith APK build observability"
---

# Blacksmith

## Purpose

This note keeps the durable Blacksmith knowledge we need for repeated APK builds and CI debugging. The current practical use case is simple: build Android debug APKs one to ten times per day, retrieve the artifact, and diagnose failures faster than with raw GitHub Actions logs.

Blacksmith Testboxes are not the default answer for that use case. Standard GitHub Actions workflows running on Blacksmith runners remain the simplest path for APK artifacts; Testboxes are mainly useful when coding agents need to run CI commands against local changes inside a warm remote VM.

## Current Recommendation

For our Android/Tauri/Flutter apps, prefer this order:

1. Keep a normal GitHub Actions workflow that builds the APK and uploads it with `actions/upload-artifact`.
2. Run that workflow on a Blacksmith Linux x64 runner, usually `blacksmith-2vcpu-ubuntu-2404` first.
3. Enable Blacksmith SSH Access for the organization.
4. Add a failure-only keepalive step to Android build workflows so the runner remains available for manual SSH debugging.
5. Create a Blacksmith Monitor for the Android build job, with Slack notification and VM retention when useful.
6. Use Blacksmith Logs and Run History as the first debugging surface.
7. Check Blacksmith Metrics after several runs before changing runner size.
8. Consider Testboxes only if agent-driven iteration is slow because every check needs a full push-triggered CI cycle.

## Agent Routing Contract

Agents should use this routing:

- `sf-prod` owns Blacksmith Run History, Logs, Metrics, and SSH Access escalation when a deploy or artifact build runs on `blacksmith-*`.
- `sf-deploy` must not duplicate Blacksmith internals; it routes deployment truth and CI failure diagnosis to `sf-prod`.
- `sf-check` may run local checks, but it must not run Android release builds locally on Linux ARM64.
- `sf-browser`, `sf-auth-debug`, and `sf-test` start after `sf-prod` has identified the deployment or artifact URL, unless the report explicitly marks deployment proof as partial.
- If SSH inspection is needed but the job already ended, the correct recommendation is a failure-only keepalive step or Blacksmith Monitor VM retention, not a blind runner-size change.

SSH escalation is read/diagnostic by default. Agents may inspect files, logs, disk, process, Gradle, SDK/NDK, and artifact outputs on the runner. They must not mutate production systems, rerun release actions, or copy raw environment values into reports.

## Operator Setup For SSH Access

Blacksmith SSH Access has two setup layers:

1. Organization setting: enabled by a GitHub organization admin in Blacksmith `Settings > Features > SSH Access`.
2. User access: the GitHub user who triggered the job must have an SSH key configured in GitHub.

No ShipFlow server install is required for SSH Access itself. The optional local SSH config below only avoids host-key friction with ephemeral Blacksmith VMs:

```sshconfig
Host *.vm.blacksmith.sh
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
```

To connect:

1. Trigger the GitHub Actions job yourself.
2. Open the job while it is still running.
3. Open the `Setup runner` step.
4. Copy the displayed `ssh -p ... runner@...vm.blacksmith.sh` command.
5. Run it from the local terminal that has access to your GitHub SSH key.

Copy the full command from the job. The SSH port can differ between jobs, so do not infer `-p 64000` from another runner.

If the job finishes too quickly, add a failure-only keepalive step or configure a Blacksmith Monitor with VM retention before the next run you want to inspect. Once Blacksmith has shut down a runner, the ephemeral `*.vm.blacksmith.sh` hostname may stop resolving and SSH is no longer possible.

## Known Project Examples

### SocialFlow

`socialflow/.github/workflows/dev-builds.yml` already contains an `android-debug` job that:

- runs on `blacksmith-2vcpu-ubuntu-2404`
- sets up Java, Android SDK, NDK env vars, pnpm, Node, Rust, and the Android Rust target
- runs RustSec audit, unit tests, TypeScript checks, Convex typecheck, and lint
- runs `pnpm exec tauri android init --ci`
- builds a debug APK with `pnpm exec tauri android build --ci --debug --apk -t aarch64`
- uploads APK outputs from `src-tauri/gen/android/app/build/outputs/**/*.apk`

This is the right workflow shape for daily phone testing. The Blacksmith-specific improvement is mostly observability and runner sizing, not a different APK delivery mechanism.

### VoiceFlowz

`voiceflowz/.github/workflows/android-build.yml` contains two jobs that already run on Blacksmith:

- `build` / `Analyze, Test, Build APK` runs on `blacksmith-2vcpu-ubuntu-2404`.
- `firebase` / `Deploy Firestore Rules and Indexes` runs on `blacksmith-2vcpu-ubuntu-2404`.
- The Android job uses current upstream GitHub actions: `actions/checkout@v6`, `actions/setup-java@v5`, `subosito/flutter-action@v2`, and `actions/upload-artifact@v7`.
- The Android job runs `flutter pub get`, `flutter analyze`, `flutter test`, `flutter build apk --debug`, checks `build/app/outputs/flutter-apk/app-debug.apk`, and uploads `voiceflowz-debug-apk`.
- The Android job injects Firebase client configuration and Sentry build/runtime identifiers through GitHub Secrets and Dart defines.
- The Firestore job uses GitHub OIDC with `google-github-actions/auth@v3`, installs `firebase-tools@15.17.0`, validates required secrets, and deploys Firestore rules/indexes.

VoiceFlowz is therefore already integrated with Blacksmith for the current Android APK and Firestore deploy needs. The remaining Blacksmith-specific improvements are operational:

- Add a manual failure-only keepalive step only when live SSH debugging is needed for a significant bug.
- Use Logs queries such as `repo:voiceflowz workflow:"Flutter Android CI" level:error,warn` and `repo:voiceflowz job_name:"Analyze, Test, Build APK" "Execution failed"` when debugging failed runs.
- Check Metrics before moving VoiceFlowz from `blacksmith-2vcpu-ubuntu-2404` to a larger runner.

## Useful Blacksmith Features

| Feature | Use for us | Priority |
| --- | --- | --- |
| Runners | Run Android/Tauri/Flutter builds on Linux x64 instead of local ARM64 servers | High |
| Logs | Search all Blacksmith CI logs by repo, workflow, branch, job, step, user, and severity | High |
| Run History | Compare previous runs and open logs/metrics from one place | High |
| SSH Access | Inspect a live failed runner, APK outputs, Gradle state, SDK/NDK paths, env vars, and processes | High |
| Monitors | Slack alerts, log pattern filters, and VM retention for recurring build failures | High |
| Metrics | Decide if `2vcpu` is too small or if builds are overprovisioned | High |
| Test Analytics | Structure test failures when Vitest/JUnit outputs exist | Medium |
| Actions cache | Faster dependency cache using normal GitHub cache actions with no workflow rewrite | Medium |
| Sticky Disks | Persistent large caches for Gradle, Cargo, npm, or Bazel when normal cache is not enough | Later |
| Static IP | Fixed runner egress IP for APIs/databases that require IP allowlists | Conditional |
| Testboxes | Agent-first remote test loop against local changes | Conditional |

## Logs

Blacksmith Logs are the main answer to the "access to logs" question. The documented search syntax supports property filters and substring search. Useful filters include:

- `repo:*`
- `workflow:*`
- `branch:*`
- `job_name:*`
- `step_name:*`
- `user:*`
- `level:info,warn,error,debug`
- plain text or quoted phrase search
- excluded terms with `-`

Useful Android build searches:

```text
repo:socialflow branch:master level:error,warn
repo:socialflow workflow:"Dev Builds (Android + Windows)" level:error,warn
repo:socialflow job_name:"Android debug APK (arm64)" level:error,warn
repo:socialflow step_name:"Build debug APK" "Execution failed"
repo:socialflow "OutOfMemory"
repo:socialflow "SIGKILL"
repo:socialflow "NDK"
repo:socialflow "tauri android build"
repo:voiceflowz branch:main level:error,warn
repo:voiceflowz workflow:"Flutter Android CI" level:error,warn
repo:voiceflowz job_name:"Analyze, Test, Build APK" level:error,warn
repo:voiceflowz step_name:"Build debug APK" "Execution failed"
repo:voiceflowz "SENTRY_DSN"
repo:voiceflowz "app-debug.apk"
```

Current docs describe this as a dashboard capability. No public `blacksmith logs` CLI command was found in the official pages reviewed on 2026-05-10.

## Run History

Run History is the dashboard page for searching, filtering, and debugging past CI jobs on Blacksmith runners. For APK work, use it to answer:

- Did the failure start on a specific branch or date?
- Was the failing step always `Build debug APK`, or did setup start failing first?
- Did a build get slower after dependency, SDK, or runner changes?
- Did CPU, memory, or network usage change between successful and failed runs?

Only jobs that actually ran on Blacksmith runners appear there.

## SSH Access

SSH Access is opt-in and must be enabled by a GitHub organization admin. When enabled, the runner accepts the GitHub SSH keys of the user who triggered the job. Only that triggering GitHub user can SSH into the runner.

For failed Android builds, inspect:

```bash
pwd
ls -la src-tauri/gen/android/app/build/outputs || true
find src-tauri/gen/android/app/build/outputs -type f | sort || true
ls "$ANDROID_HOME/ndk" || true
du -sh ~/.gradle ~/.cargo ~/.pnpm-store 2>/dev/null || true
ps aux | sort -nrk 3 | head -20
```

Do not paste a full `env` dump into a user report. If environment variables matter,
report only the variable names needed for the diagnosis, never secret values.

Recommended workflow step for debug-only retention:

```yaml
- name: Keep runner available after failure
  if: failure()
  run: |
    echo "Failure detected; use the Blacksmith setup step SSH command."
    sleep 1800
```

Place this near the end of the job you want to debug, after the build and artifact-upload steps. It still runs when an earlier step failed because the step condition is `failure()`. Do not add this to successful builds. It burns runner minutes and delays workflow completion.

### Manual Keepalive Pattern

Do not keep failed runners alive by default in daily workflows. A 30-minute `sleep` keeps the Blacksmith runner billable and delays completion for every failure. Use a manual keepalive only when a native Android, SDK, Gradle, signing, or environment failure cannot be diagnosed from Logs, Run History, artifact checks, and Metrics.

Preferred pattern:

```yaml
on:
  workflow_dispatch:
    inputs:
      keepalive_on_failure:
        description: "Keep the runner alive after failure for SSH debugging"
        required: false
        default: "false"
        type: choice
        options:
          - "false"
          - "true"
```

Add the retention step near the end of the specific job:

```yaml
- name: Keep runner available for SSH debugging
  if: failure() && github.event_name == 'workflow_dispatch' && inputs.keepalive_on_failure == 'true'
  run: |
    echo "Manual keepalive enabled. Use the Blacksmith Setup runner SSH command."
    sleep 1800
```

Rules:

- Default must stay `false`.
- Do not enable this for normal push or pull request runs.
- Do not combine it with Slack or VM retention unless the operator explicitly asks.
- Before using it, record the target run, failing step, and query tried in Blacksmith Logs.

## Monitors

Monitors can watch repositories, workflows, jobs, steps, and branches. They can alert on single events or consecutive events, set a cooldown, filter by log patterns, notify Slack, and optionally retain the VM for SSH debugging.

Recommended first monitor for APK builds:

- Repository: `socialflow`
- Workflow: `Dev Builds (Android + Windows)`
- Job: `Android debug APK (arm64)`
- Branch: `master` plus release branches if needed
- Condition: failure
- Cooldown: at least 60 minutes
- Severity: warning by default, critical if release testing is blocked
- Log patterns: `OutOfMemory`, `SIGKILL`, `NDK`, `Execution failed`, `Gradle`, `tauri android build`
- VM retention: enabled only for failures that require live inspection
- Notification: Slack channel used for build/test operations

VM retention is useful but not free in practice: retained time is billed as runner time. Use it for hard-to-debug failures, not for every small lint or typecheck issue.

## Metrics And Runner Sizing

Blacksmith automatically collects machine metrics for jobs on Blacksmith runners. Use this to decide whether Android builds need more resources.

Initial runner:

```yaml
runs-on: blacksmith-2vcpu-ubuntu-2404
```

Escalate to `blacksmith-4vcpu-ubuntu-2404` when metrics show sustained memory pressure, CPU saturation, or build time dominated by local compilation. Keep `2vcpu` if usage is low and failures are unrelated to resources.

Relevant x64 Ubuntu runner sizes from the official docs:

| Runner | CPU | Memory | Storage |
| --- | --- | --- | --- |
| `blacksmith-2vcpu-ubuntu-2404` | 2 vCPU | 8 GB | 80 GB |
| `blacksmith-4vcpu-ubuntu-2404` | 4 vCPU | 16 GB | 80 GB |
| `blacksmith-8vcpu-ubuntu-2404` | 8 vCPU | 32 GB | 160 GB |
| `blacksmith-16vcpu-ubuntu-2404` | 16 vCPU | 64 GB | 750 GB |

For our current APK debug loop, `2vcpu` is the conservative default; `4vcpu` is the first upgrade to test.

## Caching

Blacksmith automatically redirects official GitHub and common third-party cache actions to its colocated cache when jobs run on Blacksmith runners. That means normal workflow cache steps such as `actions/cache`, `actions/setup-node`, `actions/setup-java`, and similar actions should benefit without changing to legacy `useblacksmith/*` forks.

For APK builds, keep or add caches for:

- Gradle caches and wrapper
- pnpm store through `actions/setup-node` and pnpm setup
- Rust/Cargo caches through `swatinem/rust-cache` or existing Rust cache action
- Android SDK/NDK only if setup time is proven to be a bottleneck

Sticky Disks are a later optimization for very large caches such as Gradle, Cargo, or `node_modules`. They are beta, persist mounted disk state across jobs, can be much faster than downloading a large cache archive, and have storage billing. Do not add them first; prove cache download/install time is the bottleneck.

## Test Analytics

Blacksmith can parse common test output and JUnit XML files. Vitest is listed as supported for auto-parsing, but structured JUnit XML is still the better source when we want reliable test analytics.

Potential later improvement:

- configure Vitest to emit JUnit XML in CI
- keep the existing console reporter for local readability
- let Blacksmith detect the XML files automatically during the job

This is useful for unit tests and flaky test triage, not for retrieving APK artifacts.

## Static IP And Allowlisting

There are two separate IP topics:

- Network & IP Allowlisting: Blacksmith control-plane IPs that may need to be allowed in GitHub organizations with IP allowlists so Blacksmith can register runners.
- Static IP: paid runner egress IPs for CI jobs that need to reach external databases or APIs with IP restrictions.

Use Static IP only if a project service such as a database, API, auth provider, or deployment target blocks unknown CI IPs. It is not required for normal APK compilation.

## Testboxes

Testboxes are early beta and agent-first. They sync local changes to a Blacksmith microVM and run commands inside a real GitHub Actions job. They can access secrets, OIDC tokens, and service containers from that workflow.

Do not treat Testboxes as the main APK build path while our real workflow is "trigger CI, build APK, download artifact". Testboxes become interesting when:

- a coding agent needs repeated `pnpm test`, `pnpm typecheck`, or `tauri android build` runs without pushing every attempt
- the target environment differs from the local machine
- we need to reproduce flaky tests in multiple warm VMs
- local ARM64 restrictions make Linux x64 CI the only valid build environment

Security notes:

- Testbox auth tokens are stored under `~/.blacksmith/credentials`.
- Testbox SSH keypairs are cached under `~/.blacksmith/testboxes/{id}/`.
- File sync uses mirror semantics; deleted local files are removed remotely.
- Because the testbox can access workflow secrets, do not run unreviewed commands there casually.

## Android APK Debug Checklist

When an APK build fails:

1. Open Blacksmith Run History for the failing workflow.
2. Check the failing step and resource metrics.
3. Search logs with `repo:<repo> job_name:<android job> level:error,warn`.
4. Search focused phrases: `Execution failed`, `OutOfMemory`, `SIGKILL`, `NDK`, `Gradle`, `tauri android build`.
5. If SSH Access is enabled and the job is still running, connect from the `Setup runner` step command.
6. Inspect `src-tauri/gen/android/app/build/outputs`, Gradle logs, SDK/NDK env vars, and disk usage.
7. If failures are resource-related, run one test on `blacksmith-4vcpu-ubuntu-2404`.
8. If failures are setup-related, fix the workflow before changing runner size.
9. If artifacts built but upload failed, keep `actions/upload-artifact` as the delivery path and debug the path glob.

## Security Notes

- Do not paste raw logs containing tokens, signing keys, Doppler output, OIDC tokens, cookies, or private URLs into docs or reports.
- Keep signing and release secrets out of debug/testbox workflows unless the workflow explicitly needs them.
- Prefer debug APK workflows with minimal secrets for daily phone testing.
- VM retention and SSH expose a live CI environment; enable them intentionally and rely on GitHub org membership plus the triggering-user restriction.
- Static IP allowlisting is a security boundary. Record which external service was allowlisted and why.

## Sources

Official Blacksmith docs reviewed on 2026-05-10:

- [Quickstart](https://docs.blacksmith.sh/introduction/quickstart)
- [Instance Types](https://docs.blacksmith.sh/blacksmith-runners/overview)
- [Logs](https://docs.blacksmith.sh/blacksmith-observability/logs)
- [Run History](https://docs.blacksmith.sh/blacksmith-observability/history)
- [SSH Access](https://docs.blacksmith.sh/blacksmith-observability/ssh-access)
- [Monitors](https://docs.blacksmith.sh/blacksmith-observability/monitors)
- [Metrics](https://docs.blacksmith.sh/blacksmith-observability/metrics)
- [Test Analytics](https://docs.blacksmith.sh/blacksmith-observability/test-analytics)
- [Actions cache](https://docs.blacksmith.sh/blacksmith-caching/dependencies-actions)
- [Sticky Disks](https://docs.blacksmith.sh/blacksmith-caching/dependencies-sticky-disks)
- [Git Checkout Caching](https://docs.blacksmith.sh/blacksmith-caching/git-checkout-caching)
- [Static IP](https://docs.blacksmith.sh/blacksmith-runners/static-ip)
- [Network & IP Allowlisting](https://docs.blacksmith.sh/blacksmith-administration/network-allowlisting)
- [Testboxes](https://docs.blacksmith.sh/blacksmith-testbox/overview)
- [Testbox CLI Reference](https://docs.blacksmith.sh/blacksmith-testbox/cli)

## Validation

```bash
python3 tools/shipflow_metadata_lint.py shipflow_data/technical/blacksmith.md
```

## Reader Checklist

- Android APK build issue -> open this doc before changing runner size or cache strategy.
- CI log access question -> use the Logs, Run History, SSH Access, and Monitors sections.
- Agent asks about Testboxes -> check whether the goal is artifact delivery or agent iteration before recommending it.
- External service cannot be reached from CI -> check Static IP versus control-plane allowlisting.
- Build time is high -> inspect Metrics and cache behavior before upgrading runners.

## Maintenance Rule

Update this doc when Blacksmith changes runner tags, observability features, Testbox behavior, cache behavior, billing-sensitive features, or when one of our apps adopts a different APK build pattern.
