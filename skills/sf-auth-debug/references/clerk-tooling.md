# Clerk Tooling Reference

Use this reference when an auth bug involves Clerk and you need to choose between Clerk MCP, Clerk CLI, and browser automation.

Sources checked:
- https://clerk.com/docs/guides/ai/mcp/clerk-mcp-server
- https://clerk.com/docs/cli
- https://clerk.com/docs/testing/overview
- https://clerk.com/docs/testing/playwright/overview
- https://clerk.com/docs/testing/playwright/test-helpers
- https://clerk.com/docs/deployments/environments

Last reviewed: 2026-04-26

## Standard ShipFlow Setup

- Clerk MCP endpoint: `https://mcp.clerk.com/mcp`
- Codex config requires remote MCP support; ShipFlow enables `rmcp = true` in `~/.codex/config.toml`
- Clerk CLI install: `npm install -g clerk`

## Use Clerk MCP When

- The agent needs current Clerk SDK snippets or implementation patterns.
- The question is about framework wiring, route protection, organizations, auth components, or recommended Clerk usage.
- You want up-to-date examples without manually searching the docs.

## Do Not Use Clerk MCP For

- Inspecting the live auth state of a specific app instance.
- Checking whether a real session cookie exists in the browser.
- Diagnosing a broken redirect chain from browser evidence alone.
- Replacing Playwright or browser devtools for callback/session bugs.

Clerk MCP is documentation assistance, not runtime inspection.

## Use Clerk CLI When

- You need diagnostics or config operations against a real Clerk app.
- You need to authenticate a terminal session to Clerk.
- You need instance settings, env values, or API access without opening the dashboard.

Primary commands:

- `clerk auth login`
- `clerk doctor`
- `clerk env pull`
- `clerk config pull`
- `clerk config patch`
- `clerk api`
- `clerk apps list`
- `clerk init --prompt`

## Use Playwright Or Browser Evidence When

- The bug is in the real login flow, callback, redirect, middleware, cookies, or post-login navigation.
- You need proof of the exact failure step.
- OAuth behavior differs between local, preview, and production.

Prefer Playwright plus network/console evidence over speculation.

## Testing Guidance

- Prefer automated tests with `@clerk/testing` and Playwright for repeatable auth validation.
- Use Clerk Testing Tokens to bypass bot protection in test suites.
- Use Clerk test helpers where possible instead of driving every auth form manually.
- For social/OAuth providers, expect some flows to still require browser-level observation or provider test accounts.
- For the concrete testing playbook, load `references/clerk-testing.md`.

## Environment Warning

- Clerk development and production instances do not behave identically.
- Development uses a more relaxed security posture and different session architecture.
- Do not treat a dev-only success as proof that preview or production is configured correctly.

## Default Debug Policy

1. Start with Clerk MCP if the question is about how Clerk should be wired.
2. Use Clerk CLI if you need real instance diagnostics or settings.
3. Use Playwright if the bug only becomes clear in a real browser flow.
