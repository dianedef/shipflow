---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "0.3.1"
project: "shipflow"
created: "2026-04-29"
updated: "2026-05-17"
status: draft
source_skill: sf-docs
scope: skill-context-budget
owner: "unknown"
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - "skills/"
  - "skills/*/SKILL.md"
  - "Codex"
  - "Claude Code"
depends_on:
  - artifact: "GUIDELINES.md"
    artifact_version: "1.0.0"
    required_status: reviewed
supersedes: []
evidence:
  - "Codex skills documentation checked on 2026-04-29"
  - "Claude Code skills documentation checked on 2026-04-29"
  - "Local ShipFlow skill inventory measured at about 50 skills and about 12.7k initial-list characters"
  - "User decision 2026-05-01: sf-docs audit should verify skill budget compliance through a dedicated script"
  - "User decision 2026-05-01: keep skill budget reminders scoped to skill documentation and skill refresh workflows, not global agent context"
  - "2026-05-17 taxonomy audit compacted discovery descriptions to 3127 total description characters and a 51.3 average while preserving routing distinctions."
next_review: "2026-05-29"
next_step: "/sf-verify Audit And Compact Skill Taxonomy Descriptions"
---

# Skill Context Budget

## Problem

ShipFlow has enough skills that the initial skill index can exceed the context budget used by Codex and Claude Code.

This does not mean every `SKILL.md` body is loaded at startup. The startup cost comes mainly from the skill discovery index:

- skill `name`
- skill `description`
- skill file path
- Claude Code also counts `when_to_use` when present

If this index is too large, tools may shorten descriptions or omit some skills from the initial list. That can produce warnings and can make automatic skill selection less reliable.

## External Constraints

Codex:

- Codex starts with each skill's name, description, and file path.
- The initial skills list is capped at roughly 2% of the model context window, or 8,000 characters when the context window is unknown.
- If many skills are installed, Codex shortens skill descriptions first; for very large sets, some skills may be omitted and Codex can show a warning.
- The full `SKILL.md` is still read when Codex selects a skill.
- Source: https://developers.openai.com/codex/skills

Claude Code:

- Skill descriptions are loaded into context so Claude knows what is available; full skill content loads when invoked.
- The combined `description` and `when_to_use` text is capped at 1,536 characters per skill listing.
- The global skill description budget scales at 1% of the context window, with an 8,000-character fallback.
- The budget can be raised with `SLASH_COMMAND_TOOL_CHAR_BUDGET`, but ShipFlow should not depend on users doing that.
- Claude Code recommends keeping each `SKILL.md` under 500 lines and moving detailed material to references.
- After compaction, Claude Code keeps the first 5,000 tokens of each re-attached skill, with a combined 25,000-token budget.
- Source: https://code.claude.com/docs/en/skills

Claude.ai upload:

- Uploaded Claude.ai skills limit `description` to 200 characters.
- The Agent Skills specification allows longer descriptions, but Claude.ai uses the shorter upload limit.
- Source: https://claude.com/docs/skills/how-to

Agent Skills specification:

- `name`: required, 1 to 64 characters, lowercase letters, numbers, and hyphens only.
- `name`: must not start or end with a hyphen, must not contain consecutive hyphens, and must match the parent directory.
- `description`: required, 1 to 1024 characters.
- `compatibility`: optional, 1 to 500 characters if present.
- `SKILL.md`: keep under 500 lines and move detailed reference material to separate files.
- Progressive disclosure recommendation: full `SKILL.md` body under about 5000 tokens.
- Source: https://agentskills.io/specification

## ShipFlow Policy

ShipFlow should optimize for the strict shared path: Codex plus Claude Code plus possible Claude.ai reuse.

Default targets:

- `description`: one sentence maximum.
- `description`: target 80 to 120 characters.
- `description`: warning above 140 characters.
- `description`: hard ShipFlow maximum 200 characters unless there is a documented reason.
- `description`: average across installed skills should stay around 100 to 104 characters while ShipFlow has about 49 to 50 skills.
- `description`: never contain `Args:`; arguments belong in `argument-hint`.
- `name`: keep stable, short, lowercase, and hyphenated.
- `name`: maximum 64 characters and must match the skill directory name.
- `name`: must not start or end with `-`, and must not contain `--`.
- `path`: keep the canonical shape `skills/<name>/SKILL.md`; path length counts in the discovery budget.
- `when_to_use`: avoid by default; if used, `description + when_to_use` must stay under 1,536 characters.
- `compatibility`: optional; if used, keep it under 500 characters.
- `SKILL.md`: target under 500 lines and about 5000 body tokens; move long doctrine, examples, and checklists to `references/`.
- Installed skills: keep the always-enabled set small enough that `name + description + path` stays below 8,000 characters.

Descriptions must front-load trigger words because both Codex and Claude Code can shorten long descriptions.

This policy should be enforced in skill-specific workflows such as `sf-docs` and `sf-skills-refresh`, plus the executable audit. Do not add broad reminders to general agent files such as `AGENT.md`, `CONTEXT.md`, or `GUIDELINES.md`; agents working on unrelated tasks should not carry this extra decision load.

Good description pattern:

```yaml
description: "Audit documentation drift, metadata, README/API/component docs, and stale project contracts."
```

Avoid:

```yaml
description: "Args: file-path, readme, api, components, audit, update, metadata, or migrate-frontmatter. Générer, auditer et harmoniser la documentation — README, API docs, component docs, audit de cohérence, migration frontmatter, ou fichier spécifique"
```

Arguments belong in `argument-hint` and the body, not in long descriptions.

## Body-Size Risk And Layering

Description compliance and body-size compaction are linked but distinct:

- Discovery metadata (`name`, `description`, path) protects startup routing quality.
- `SKILL.md` body size protects progressive-disclosure quality during execution.

Use `skills/references/skill-instruction-layering.md` as the canonical compaction contract for what must stay local vs what should move to shared or skill-local references.

Current policy state:

- Frontmatter description policy is currently compliant in this repo baseline.
- Remaining risk is mainly body-size and instruction dilution in long skill bodies.
- Compaction must preserve guardrails (`Trace category`, `Process role`, chantier/reporting contracts, security/redaction rules, and documentation-update gates).

Practical thresholds stay:

- warning zone: `SKILL.md` over 500 lines
- progressive-disclosure risk: body estimate over about 5000 tokens

Crossing a threshold is a risk signal, not automatic deletion authority.

## Audit Command

Use the canonical audit before adding or expanding skills:

```bash
SHIPFLOW_ROOT="${SHIPFLOW_ROOT:-$HOME/shipflow}"
"$SHIPFLOW_ROOT/tools/skill_budget_audit.py" --skills-root "$SHIPFLOW_ROOT/skills"
```

Use Markdown output when embedding the result in an audit report:

```bash
SHIPFLOW_ROOT="${SHIPFLOW_ROOT:-$HOME/shipflow}"
"$SHIPFLOW_ROOT/tools/skill_budget_audit.py" --skills-root "$SHIPFLOW_ROOT/skills" --format markdown
```

If the canonical script is not available yet, use this rough estimate:

```bash
find "$HOME/shipflow/skills" -mindepth 2 -maxdepth 2 -name SKILL.md -print0 |
  xargs -0 awk '
    /^name: / {
      name=$0
      sub(/^name: /, "", name)
    }
    /^description: / {
      desc=$0
      sub(/^description: /, "", desc)
      gsub(/^"|"$/, "", desc)
      count++
      total += length(name) + length(desc) + length(FILENAME)
      if (length(desc) > 200) {
        print length(desc) "\t" FILENAME "\t" desc
      }
    }
    END {
      print "COUNT=" count
      print "APPROX_INITIAL_LIST_CHARS=" total
    }'
```

Interpretation:

- `APPROX_INITIAL_LIST_CHARS` under 8,000: acceptable baseline.
- 8,000 to 10,000: warning zone; shorten descriptions before adding more skills.
- above 10,000: remediation needed; automatic skill discovery may degrade.

## Recommended Remediation

1. Shorten descriptions over 200 characters first.
2. Move argument syntax out of descriptions into `argument-hint`.
3. Merge or disable niche skills that are rarely used.
4. Split long `SKILL.md` bodies into `references/` when the body exceeds 500 lines.
5. Add a CI or maintenance script that fails when the estimated initial index exceeds 8,000 characters.

## Current ShipFlow Note

On 2026-05-17, the local ShipFlow install measured 61 skills with 3127 total description characters, average description length 51.3, absolute discovery estimate 6805/8000, and repo-relative discovery estimate 5463/8000.

The current baseline is under the fallback discovery budget with zero hard violations, zero warnings, and zero body-size risks. Future remediation should still prefer targeted description edits and routing analysis before deleting, disabling, renaming, or merging skills.
