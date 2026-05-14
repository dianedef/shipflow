# ShipFlow Model Routing

OpenAI latest-model guidance checked against official OpenAI docs on 2026-05-14.
Claude Code aliases checked against official Anthropic Claude Code model configuration docs on 2026-04-26.

This reference must stay short. If a question depends on "latest", exact availability, default model, pricing, or a recent change, revalidate against official provider docs before answering.

## Freshness sources

- OpenAI: use `mcp__openaiDeveloperDocs__fetch_openai_doc` for `https://developers.openai.com/api/docs/guides/latest-model.md` before making latest/current/default model claims.
- Claude Code: prefer aliases from Anthropic docs (`opusplan`, `opus`, `sonnet`, `sonnet[1m]`, `haiku`) instead of dated slugs unless the user asks for a full model name.
- Never invent pricing, model availability, context windows, or provider-specific parameters.

## Codex/OpenAI map

- `gpt-5.5`
  - premium current model for complex, ambiguous, cross-project, tool-heavy, product-spec-to-plan, and high-error-cost work
  - default OpenAI choice for transverse audits, automatic task prioritization, prompt/docs migrations, business-risk synthesis, model-policy updates, and coherent tracker/project-fiche updates
  - starts well at `medium` reasoning; use `high` or `xhigh` only when the task justifies latency/cost
- `gpt-5.4`
  - premium balanced option when `gpt-5.5` is likely overkill or cost control matters
  - good fit for bounded architecture and important tradeoffs
- `gpt-5.4-mini`
  - speed/cost/quality entry point for small and medium tasks
  - good for triage, exploration, sub-tasks, and repeated iterations
- `gpt-5.3-codex`
  - default Codex/OpenAI choice for long implementation, refactors, hard debugging, multi-file coding, and terminal-heavy agentic work
- `gpt-5.3-codex-spark`
  - fastest local iteration path, especially for UI deltas or tightly scoped edits
- `gpt-5.2`
  - previous generation; avoid by default except continuity or explicit user preference

## Codex/OpenAI routing matrix

| Situation | Primary | Reasoning | Fast fallback | Cheap fallback |
| --- | --- | --- | --- | --- |
| Ambiguous spec, architecture, high error cost | `gpt-5.5` | `high` | `gpt-5.4` | `gpt-5.4-mini` |
| Transverse audit, task prioritization, prompt/docs migration, business-risk synthesis | `gpt-5.5` | `medium` or `high` | `gpt-5.4` | `gpt-5.4-mini` |
| Bounded premium architecture or tradeoff | `gpt-5.4` | `medium` or `high` | `gpt-5.4-mini` | `gpt-5.4-mini` |
| Long implementation, multi-file implementation, refactor, hard bug | `gpt-5.3-codex` | `medium` or `high` | `gpt-5.3-codex-spark` | `gpt-5.4-mini` |
| Small feature, local fix, triage | `gpt-5.4-mini` | `low` or `medium` | `gpt-5.3-codex-spark` | `gpt-5.4-mini` |
| Targeted UI iteration | `gpt-5.3-codex-spark` | `low` or `medium` | `gpt-5.4-mini` | `gpt-5.4-mini` |
| Long terminal-heavy agentic loop | `gpt-5.3-codex` | `medium` | `gpt-5.5` | `gpt-5.4-mini` |

## Claude Code map

- `opusplan`
  - hybrid alias: Opus during Plan Mode, Sonnet during execution
  - best default for difficult work that benefits from explicit planning before implementation
- `opus`
  - strongest Claude Code alias for complex reasoning, architecture, adversarial review, and high-error-cost decisions
- `sonnet`
  - balanced default for daily coding, implementation, debugging, and most ShipFlow execution loops
- `sonnet[1m]`
  - Sonnet with extended context for very long sessions or large codebase context
  - use only when context length is the main constraint
- `haiku`
  - fast and efficient alias for simple tasks, triage, classification, and cheap side work

## Claude Code routing matrix

| Situation | Primary | Behavior | Fast fallback | Cheap fallback |
| --- | --- | --- | --- | --- |
| Plan-heavy architecture or ambiguous spec | `opusplan` | Opus for planning, Sonnet for execution | `sonnet` | `haiku` |
| High-risk reasoning, review, security, product arbitration | `opus` | maximum reasoning quality | `opusplan` | `sonnet` |
| Daily multi-file coding or debugging | `sonnet` | balanced execution | `haiku` for side tasks | `haiku` |
| Very long Claude Code session/context | `sonnet[1m]` | extended context Sonnet | `sonnet` | `haiku` |
| Small local fix, triage, classification | `haiku` | fastest/cheapest | `sonnet` | `haiku` |

## Default heuristics

- If the task is simple, local, and reversible, use the runtime's fast model: `gpt-5.4-mini`/`gpt-5.3-codex-spark` in Codex, `haiku` or `sonnet` in Claude Code.
- If the task is long implementation or implementation-heavy, prefer `gpt-5.3-codex` in Codex and `sonnet` in Claude Code.
- If the task is ambiguous, cross-project, governance-heavy, or high-error-cost, prefer `gpt-5.5` in Codex and `opusplan` or `opus` in Claude Code.
- If the user already ran `sf-spec` and `sf-ready`, the clearer contract usually reduces the need for the largest model.
- If two choices are close, choose by latency, cost, agentic execution fit, and how costly a wrong decision would be.

## Runtime application rule

- The main conversation can recommend a better model, route through `sf-model`, or tell the operator which model to use next; it must not claim that it can always switch its own active runtime model mid-thread.
- When subagents are available and the orchestration tool accepts model overrides, delegated missions should include the selected model and reasoning effort explicitly.
- When the runtime cannot apply a model override, report the recommendation as advisory and continue only if the degraded mode is safe for the work item.
