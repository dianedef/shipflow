---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.2.0"
project: ShipFlow
created: "2026-05-11"
updated: "2026-05-11"
status: active
source_skill: sf-skills-refresh
scope: sentry-observability
owner: unknown
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/sf-prod/SKILL.md
  - skills/sf-deploy/SKILL.md
  - skills/sf-auth-debug/SKILL.md
  - skills/sf-browser/SKILL.md
  - skills/sf-test/SKILL.md
  - skills/sf-bug/SKILL.md
  - skills/sf-fix/SKILL.md
  - skills/sf-start/SKILL.md
  - skills/sf-verify/SKILL.md
  - skills/sf-audit-code/SKILL.md
  - skills/sf-perf/SKILL.md
depends_on: []
supersedes: []
evidence:
  - "User doctrine update 2026-05-11: ShipFlow projects now use Sentry everywhere."
  - "User doctrine clarification 2026-05-11: Sentry is not necessary on static sites; it becomes necessary when authentication is introduced."
  - "User operational note 2026-05-11: skills never see Sentry dashboard directly; local PM2 logs and Doppler env presence are available evidence sources."
  - "User clarification 2026-05-11: skills will never have direct Sentry dashboard access."
  - "VoiceFlowz check 2026-05-11: sentry_flutter 9.20.0 is installed, SENTRY_DSN is injected by Blacksmith Android CI, and runtime diagnostics expose Sentry state."
  - "Sentry Flutter docs 2026-05-11: current setup guidance includes early init, optional tracing/profiling/logs/session replay, verification event snippets, navigation observers, and debug symbol/source map guidance."
  - "Blacksmith docs 2026-05-11: Blacksmith runners transparently accelerate official cache actions and provide searchable CI logs for workflow/run/branch/job/step filters."
next_review: "2026-06-11"
next_step: "/sf-verify Sentry observability doctrine"
---

# Sentry Observability

Use this reference when a project bug, deploy, manual test, browser check, auth diagnosis, verification, audit, or performance review depends on runtime behavior.

## Default Assumption

ShipFlow runtime projects are expected to have Sentry instrumentation unless the project explicitly documents an exception.

Sentry is not expected by default on static marketing, documentation, blog, or content sites when they have no authentication, account state, protected routes, checkout/payment flow, server-handled forms, or other user-specific runtime workflow. Do not add Sentry to static sites only to satisfy the runtime observability posture; rely on build/deploy checks, host logs, browser checks, and SEO/content validation.

Sentry becomes expected as soon as a site introduces authentication or user-specific runtime behavior. Auth, account, payment, protected content, server-side form handling, webhooks, jobs, or tenant-specific flows should not use the static-site exception.

Skills never have direct Sentry dashboard access. Do not attempt to open or query the dashboard as part of the skill contract.

Use Sentry only through evidence that is visible in the app, logs, error boundaries, support screens, pasted by the operator, or otherwise already present in the working context. If no Sentry issue/event pointer is available, use local PM2 logs and redacted Doppler environment checks as supporting runtime evidence instead of pretending Sentry was checked.

For Flutter apps, treat Sentry as useful only when both layers are true:

- The SDK is initialized early enough to capture Flutter/native runtime failures.
- The build, CI, or app diagnostics prove the expected DSN, environment, release, and dist/build identifiers are present without exposing secret values.

## When To Load This

- The app throws, crashes, renders an error boundary, or returns a 5xx.
- A browser console or network check shows an unhandled exception.
- A deploy is green but runtime health, auth, protected flows, jobs, webhooks, or user actions fail.
- A manual test fails and the user sees a Sentry event ID, support ID, error boundary, or crash report.
- A bug file, fix attempt, release check, or verification needs runtime evidence.
- An audit reviews error handling, reliability, telemetry, or performance overhead.

## Evidence To Prefer

- Sentry issue URL or issue ID when supplied by the operator or visible in app/log output.
- Event ID shown by the app, copied from an error boundary, support screen, or logs.
- Release, commit SHA, environment, transaction, trace, replay, or suspect commit when available.
- First seen / last seen timestamps and affected users count when relevant and safe.
- Stack frame file/function/module after redacting private data.
- A concise event summary, not a raw payload dump.
- Local PM2 process/log evidence because direct Sentry dashboard access is not available to skills.
- Doppler secret presence/config status when environment variables may explain the failure, without printing secret values.
- For Flutter/mobile apps: `pubspec.lock` SDK version, `SentryFlutter.init` options, Dart defines, app diagnostics screen output, and CI evidence that `SENTRY_DSN` was present and masked.
- For GitHub Actions on Blacksmith: run ID, job name, runner label, step failure, artifact existence, and searchable log filters such as `branch:main level:error,warn` when the operator can access Blacksmith logs.

## Local PM2 And Doppler Fallback

Use this when Sentry is expected but no Sentry issue/event pointer is available, or when the runtime is a ShipFlow/PM2-managed server app.

Safe PM2 commands:

```bash
pm2 list
pm2 logs contentflow_lab --lines 80 --nostream
tail -f ~/.pm2/logs/contentflow-lab-out.log
tail -f ~/.pm2/logs/contentflow-lab-error.log
```

Adapt the PM2 app name and log file names to the project when they differ. Prefer bounded, non-streaming logs for reports; use `tail -f` only for active live diagnosis, then summarize the relevant lines.

Doppler rules:

- Check that required env keys are present, scoped to the expected project/config/environment, and loaded by the running process.
- Report key names, config scope, and presence/absence only.
- Never print Doppler secret values, raw `doppler secrets`, raw `env`, or command output that includes secret values.
- If a value shape matters, report a redacted shape such as `present`, `missing`, `empty`, `looks like URL`, or `wrong environment`, not the value.

## Flutter App Checklist

Use this checklist for Flutter apps before recommending more Sentry work:

- Confirm `sentry_flutter` is current enough for the target platform. VoiceFlowz is already on `9.20.0`; do not recommend a migration just because an older docs page shows a lower package detail.
- Confirm initialization happens before `runApp` and does not break local development when `SENTRY_DSN` is missing.
- Confirm `sendDefaultPii=false` for privacy-sensitive apps unless the user explicitly accepts the data tradeoff.
- Confirm screenshots, view hierarchy, session replay, and user feedback screenshots are disabled or deliberately configured when the app handles voice, keyboard, clipboard, auth, private text, or user-owned files.
- Confirm the app records release/environment/build identifiers from CI, for example commit SHA, branch/ref, run ID, `SENTRY_ENVIRONMENT`, `release`, and `dist`.
- Confirm local error handlers preserve visible failures and do not swallow exceptions just because Sentry is installed.
- Add route/navigation correlation when the app has meaningful screens. For `MaterialApp.router`/`GoRouter`, prefer a Sentry navigator observer or router-compatible integration if the local router supports it.
- Add a deliberate verification event only in a controlled debug/test build, then remove or guard it. Do not ship a permanent button or startup crash test.
- If release builds use `--obfuscate`, `--split-debug-info`, native symbols, or web source maps, require a symbol/source-map upload plan before relying on Sentry stack traces.

## Feature Defaults

Use conservative defaults for privacy-sensitive ShipFlow apps:

| Feature | Default | Enable when |
|---------|---------|-------------|
| Error monitoring | yes | DSN and environment are configured. |
| Breadcrumbs | yes, redacted | Messages are sanitized and do not include user text, transcripts, tokens, prompts, clipboard contents, or private URLs. |
| Navigation tracking | yes | Route names are stable and do not include private IDs or user text. |
| Tracing | cautious | There is a concrete performance question; start with low sampling outside debug. |
| Profiling | cautious | Native/mobile performance diagnosis needs it and overhead is acceptable. |
| Logs | cautious | `enableLogs` is paired with redaction/filtering and log volume control. |
| Screenshots/view hierarchy | no | The UI is known not to contain sensitive content, or explicit redaction/masking exists. |
| Session replay | no | Product/privacy review approves it and masking is proven on target screens. |
| User feedback screenshots | no | The support flow has explicit consent and redaction. |

For VoiceFlowz-like apps, keep screenshots/view hierarchy/session replay off by default because keyboard, voice, clipboard, auth, and private text surfaces are high-risk.

## Static Sites

Sentry is not expected for static marketing, documentation, blog, or content sites whose runtime is limited to static pages and non-critical client-side enhancement.

This static-site rule is valid when all of these are true:

- No authentication or account state.
- No protected or personalized routes.
- No checkout, payment, webhook, queue, or background job surface.
- No server-handled form submission or user-specific data mutation.
- No critical client-side workflow where a user's action can fail independently of the build/deploy pipeline.

When this applies, document in the project guidance or README that Sentry is not expected for the static site, and state that Sentry should be revisited if authentication or user-specific runtime behavior is added.

When any of those conditions stops being true, treat Sentry as required and follow the relevant browser, server, or app checklist instead of continuing to rely on the static-site rule.

## Correlation Rules

- When a Sentry pointer is supplied or visible, match it to the same environment being tested: `local`, `preview`, `production`, or project-specific equivalent.
- When a Sentry pointer is supplied or visible, match it to the deployed release or commit SHA when `sf-prod`, `sf-deploy`, `sf-ship`, or `sf-verify` depends on hosted evidence.
- Match PM2 logs and Doppler config to the same app name, cwd, branch, environment, and deployment surface being diagnosed.
- For mobile builds produced by GitHub Actions/Blacksmith, match the Sentry release/dist to the workflow `GITHUB_SHA`, `GITHUB_REF_NAME`, and `GITHUB_RUN_ID` when the app uses those values as Dart defines.
- For preview-push projects, do not use old production issues as proof about the current preview unless the release/environment link is explicit.
- For auth, payment, data, webhook, job, or tenant failures, prefer server-side Sentry events over browser-only symptoms when both exist.
- Do not report "no matching Sentry event" unless an operator-provided or visible Sentry pointer/window was actually checked from available context. Otherwise report `Sentry: no direct dashboard access; PM2/Doppler checked`.

## Privacy And Redaction

- Never paste raw Sentry event payloads, breadcrumbs, request bodies, headers, cookies, tokens, auth codes, session data, private emails, PII, or private URLs into reports or bug files.
- Summarize sensitive fields and use placeholders such as `[REDACTED_TOKEN]`, `[REDACTED_EMAIL]`, or `[REDACTED_PRIVATE_URL]`.
- Do not expose full user lists, IP addresses, or session replay content in user reports. Use counts or redacted summaries.
- If a screenshot, replay, or breadcrumb contains sensitive data, reference it by Sentry issue/event ID only and state that redaction was applied.

## Skill Reporting Rules

- Include Sentry evidence under `Evidence`, `Logs`, `Observability`, or `Limits` depending on the skill report shape.
- If Sentry was expected but no issue/event pointer was available, say `Sentry: no direct dashboard access; no event pointer supplied`.
- If a supplied/visible pointer was checked and no match was possible, say `Sentry: pointer not correlated to [environment/release/window]`.
- If a supplied/visible pointer is relevant, say `Sentry: [issue/event id]`, environment, release/commit if known, and one-line impact.
- If PM2/Doppler evidence was used instead, say `Sentry: no direct dashboard access; PM2/Doppler checked` and name the bounded evidence.
- If Sentry is not expected because the target is a static site, say `Sentry: not expected for static site; no auth or user-specific runtime workflow`.
- For Flutter apps, report Sentry state from app-visible diagnostics or build config when available: configured/initialized, environment, release, dist, and whether CI injected a masked `SENTRY_DSN`.
- For Blacksmith-hosted CI, include the GitHub Actions run ID and a precise log query hint when it helps the operator investigate, for example `branch:main level:error,warn workflow:"Flutter Android CI"`.
- Do not let Sentry replace the owner skill proof: browser evidence still belongs to `sf-browser` / `sf-auth-debug`, deploy truth to `sf-prod`, manual QA to `sf-test`, and closure to `sf-verify`.

## Performance Notes

- Sentry browser tracing, profiling, session replay, source maps, and breadcrumbs can affect bundle size, network usage, privacy posture, and INP/LCP if configured carelessly.
- Audit sampling rates, replay masks, source map upload exposure, and disabled debug logging when performance or privacy is in scope.
- Sentry instrumentation should preserve user/operator visibility of failures; do not swallow exceptions only to report them.
- Do not enable `tracesSampleRate = 1.0`, `profilesSampleRate = 1.0`, broad logs, or session replay in production by copying quick-start docs. Treat those examples as setup/verification defaults, then lower or disable them for production.
- For mobile apps, measure APK/AAB size and startup/performance overhead after enabling native crash reporting, tracing, profiling, logs, or replay.
