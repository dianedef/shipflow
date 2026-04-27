---
artifact: bug_record
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: "[project name]"
created: "YYYY-MM-DD"
updated: "YYYY-MM-DD"
status: draft
source_skill: "[sf-test|sf-fix|sf-verify|sf-auth-debug|manual]"
scope: "bug"
owner: "[owner]"
bug_id: "BUG-YYYY-MM-DD-NNN"
title: "[short bug title]"
bug_status: "open"
severity: "medium"
reported_by: "[skill or operator]"
first_observed: "YYYY-MM-DD"
last_observed: "YYYY-MM-DD"
environment: "unknown"
reproducibility: "unknown"
redaction_status: "not-reviewed"
related_bugs: []
related_artifacts: []
confidence: medium
risk_level: medium
security_impact: yes
docs_impact: unknown
evidence: []
depends_on: []
supersedes: []
next_step: "/sf-fix BUG-YYYY-MM-DD-NNN"
---

# Bug Record: BUG-YYYY-MM-DD-NNN

## Summary

- Title: [short bug title]
- Current status: `open`
- Severity: `medium`
- Owner: [owner or unassigned]
- Next command: `/sf-fix BUG-YYYY-MM-DD-NNN`

## Reproduction

- Preconditions:
  - [state, account, feature flags, dataset, or environment requirement]
- Steps:
  1. [step 1]
  2. [step 2]
  3. [step 3]

## Expected Behavior

- [what should happen]

## Observed Behavior

- [what actually happened]

## Evidence

- [relative path, command output excerpt, screenshot path, test log pointer, or external reference]
- Keep large artifacts under `test-evidence/BUG-YYYY-MM-DD-NNN/`.
- Never inline raw secrets, tokens, cookies, private payloads, private emails, raw headers, HAR dumps, or production personal data.

## Diagnosis Notes

| Date UTC | Skill | Author | Hypothesis | Findings | Outcome |
|----------|-------|--------|------------|----------|---------|
| YYYY-MM-DD HH:MM:SS UTC | [sf-fix|sf-test|sf-verify|manual] | [name] | [hypothesis] | [what was checked] | [supported/rejected/inconclusive] |

## Fix Attempts

| Date UTC | Skill | Author | Changes | Validation | Result | Next Step |
|----------|-------|--------|---------|------------|--------|-----------|
| YYYY-MM-DD HH:MM:SS UTC | sf-fix | [name] | [files changed or none] | [command or reason not run] | [failed|partial|passed] | [retest command] |

## Retest History

| Date UTC | Skill | Retest Command | Environment | Result | Notes |
|----------|-------|----------------|-------------|--------|-------|
| YYYY-MM-DD HH:MM:SS UTC | sf-test | [command] | [env] | [failed|partial|passed|not-run] | [pointer to evidence] |

## Related Bugs / Artifacts

- Related bugs:
  - [BUG-ID with relation, for example duplicate-of, blocks, related]
- Related artifacts:
  - [spec, verification report, or decision record path]

## Lifecycle Notes

Canonical bug lifecycle statuses:

- `open`
- `needs-info`
- `needs-repro`
- `in-diagnosis`
- `fix-attempted`
- `fixed-pending-verify`
- `closed`
- `closed-without-retest`
- `duplicate`
- `wontfix`

Status transitions must stay explicit in this dossier and in `BUGS.md`.

## Redaction Status

- Current redaction status: `[not-reviewed|redacted|not-required|rejected]`
- Redaction notes:
  - [what was redacted, what was omitted, and why]

## Closure Criteria

- `closed` requires at least one passing retest entry linked to the fix attempt.
- `closed-without-retest` requires an explicit reason plus residual risk.
- `duplicate` requires a linked canonical bug ID.
- `wontfix` requires a visible scope or product decision.

## Next Step

[Concrete command and owner, for example `/sf-test --retest BUG-YYYY-MM-DD-NNN`]
