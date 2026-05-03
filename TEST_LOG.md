# Test Log

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
