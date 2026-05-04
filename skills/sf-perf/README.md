# sf-perf

> Audit performance issues in a file, a project, or a full workspace and turn them into concrete fixes or next actions.

## What It Does

`sf-perf` reviews the parts of a product that usually get slow quietly: bundle weight, rendering patterns, hydration, data fetching, asset handling, and Core Web Vitals readiness. It can focus on a single file, a whole project, or multiple projects in one workspace.

For a solo founder, that means fewer vague “the app feels slow” complaints and more specific performance decisions tied to real code paths.

## Who It's For

- Founders shipping web apps or content sites alone
- Technical operators managing several projects
- Teams that want a repeatable performance review before bigger releases

## When To Use It

- when pages are getting slower or bundle size is drifting up
- before a launch or after a major feature wave
- when you want a focused performance review of one page or component

## What You Give It

- a repo or working directory
- optionally, a file path for a file-level review
- optionally, `global` for a multi-project audit

## What You Get Back

- a graded performance audit
- specific findings tied to code or architecture
- priority fixes and deeper remediation paths
- cross-project comparison when used in global mode

## Typical Examples

```bash
/sf-perf
/sf-perf global
/sf-perf src/pages/pricing.tsx
```

## Limits

- It is an audit-first skill, not an automatic full optimization engine.
- Runtime measurements can still require manual profiling or production telemetry.
- Some issues depend on infrastructure, real traffic, or browser traces that may not exist locally.

## Related Skills

- `sf-check` after fixes
- `sf-audit-design` when UX and rendering concerns overlap
- `sf-prod` to validate the deployed result
