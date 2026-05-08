# Test Log

## 2026-05-08 - PM2 orphan stop and crash-loop guard retest

- Scope: BUG-2026-05-06-001
- Environment: local
- Tester: Codex tooling
- Source: sf-test
- Status: pass
- Confidence: high
- Result summary: `env_stop` stopped a PM2-only/orphan-style app by name; isolated `batch_stop_all` stopped the temporary PM2-only app; generated ecosystem config contains crash-loop limits.
- Bug pointer: BUG-2026-05-06-001 -> bugs/BUG-2026-05-06-001.md
- Evidence pointer: local PM2 commands with temporary `shipflow_retest_*` app names; no secrets or private payloads stored
- Follow-up: completed by `/sf-verify BUG-2026-05-06-001` on 2026-05-08; no further retest required for this bug.

## 2026-05-05 - Flutter + Convex dev command retest

- Scope: BUG-2026-05-04-004
- Environment: local
- Tester: user
- Source: sf-test
- Status: pass
- Confidence: high
- Result summary: ShipFlow restart for `nococaine` detected the Flutter Web command and PM2 launched the app online on port `3002`.
- Bug pointer: BUG-2026-05-04-004 -> bugs/BUG-2026-05-04-004.md
- Evidence pointer: chat-provided restart log; no secrets or private payloads stored
- Follow-up: `/sf-verify BUG-2026-05-04-004`

## 2026-05-03 - sf-skill-build runtime visibility retest

- Scope: BUG-2026-05-03-001
- Environment: local
- Tester: user
- Source: sf-test
- Status: pass
- Confidence: high
- Result summary: Operator invoked `$sf-skill-build hi` and confirmed the skill was recognized by Codex.
- Bug pointer: BUG-2026-05-03-001 -> bugs/BUG-2026-05-03-001.md
- Evidence pointer: chat confirmation; no secrets or private runtime data stored
- Follow-up: `/sf-verify BUG-2026-05-03-001`

## 2026-05-02 - Local SSH bare identity key retest

- Scope: BUG-2026-05-02-003
- Environment: local
- Tester: user
- Source: sf-test
- Status: pass
- Confidence: high
- Result summary: Operator confirmed the ShipFlow local SSH connection now works after the bare identity filename fix.
- Bug pointer: BUG-2026-05-02-003 -> bugs/BUG-2026-05-02-003.md
- Evidence pointer: chat confirmation, no raw IP or key material stored
- Follow-up: none; verified by sf-verify on 2026-05-02
