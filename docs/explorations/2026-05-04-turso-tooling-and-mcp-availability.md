---
artifact: exploration_report
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "ShipFlow"
created: "2026-05-04"
updated: "2026-05-04"
status: draft
source_skill: sf-explore
scope: "turso-tooling-and-mcp-availability"
owner: "Diane"
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - "install.sh"
  - "lib.sh"
  - "docs/technical/installer-and-user-scope.md"
  - "docs/technical/runtime-cli.md"
  - "local/"
  - "contentflow/contentflow_lab/.flox/env/manifest.toml"
evidence:
  - "Official Turso Cloud CLI docs identify the `turso` CLI, install commands, `turso auth login`, and `turso db shell <database-name> [sql]`."
  - "Official Turso Database beta docs identify the `tursodb` binary."
  - "Turso blog announces built-in MCP support through `tursodb <database.db> --mcp`."
  - "Official AgentFS docs identify `agentfs serve mcp`, but this is AgentFS, not direct Turso Cloud DB shell access."
  - "Local PATH check on 2026-05-04 found no global `turso`, `tursodb`, or `agentfs` binaries."
  - "ShipFlow and dotfiles search found no Turso install path; ShipFlow only references Turso as explicitly out of scope in the Flutter/Dart Flox provisioning spec."
  - "ContentFlow lab Flox manifest declares `turso.pkg-path = \"turso\"` and `turso-cli.pkg-path = \"turso-cli\"`; activated env exposes `turso version v1.0.19` and `tursodb` reporting `Turso 0.4.0`."
depends_on: []
supersedes: []
next_step: "/sf-spec ShipFlow Turso tooling support"
---

# Exploration Report: Turso Tooling And MCP Availability

## Starting Question

Does Turso have an MCP or CLI, and do ShipFlow or dotfiles already install it anywhere?

## Context Read

- `/home/ubuntu/shipflow/specs/flutter-dart-flox-provisioning-for-shipflow-projects.md` - Confirms Turso was deliberately excluded from the Flutter/Dart runtime provisioning chantier and should be handled by a separate audit-tooling spec if needed.
- `/home/ubuntu/contentflow/contentflow_lab/.flox/env/manifest.toml` - Confirms one project-local Flox environment already declares Turso packages.
- `/home/ubuntu/shipflow`, `/home/ubuntu/dotfiles`, user shell files, and user binary paths - Checked for global install scripts, aliases, binaries, and config references.
- `/home/ubuntu/.config/turso/settings.json` - Confirms Turso config directory exists, but only with a small settings file and no binary.

## Internet Research

- [Turso CLI Installation](https://docs.turso.tech/cli/installation) - Accessed 2026-05-04 - Official install source for the Turso Cloud CLI.
- [Turso CLI Introduction](https://docs.turso.tech/cli/introduction) - Accessed 2026-05-04 - Official command surface for Turso Cloud CLI.
- [Turso CLI Authentication](https://docs.turso.tech/cli/authentication) - Accessed 2026-05-04 - Confirms `turso auth login` and token-based CLI authentication.
- [Turso db shell](https://docs.turso.tech/cli/db/shell) - Accessed 2026-05-04 - Confirms `turso db shell <database-name> [sql]`, the command needed for live schema proof.
- [TursoDB Quickstart](https://docs.turso.tech/tursodb/quickstart) - Accessed 2026-05-04 - Official source for the newer `tursodb` embedded database binary.
- [Introducing the Turso Database MCP](https://turso.tech/blog/introducing-the-turso-database-mcp-server) - Accessed 2026-05-04 - Official Turso announcement for built-in MCP support via `tursodb --mcp`.
- [AgentFS MCP Server Integration](https://docs.turso.tech/agentfs/guides/mcp) - Accessed 2026-05-04 - Official MCP support for AgentFS, separate from Turso Cloud schema proof.
- [mcp-turso directory listing](https://mcp.directory/mcp/details/697/turso) - Accessed 2026-05-04 - Non-official third-party MCP wrapper surfaced during research; not used as authoritative evidence.

## Problem Framing

The immediate blocker came from ContentFlow schema proof: the project contract expects a live Turso schema check such as:

```bash
turso db shell contentflow-prod2 ".schema content_bodies"
```

That proof requires the Turso Cloud CLI and authenticated account state. Reading code or migration files is explicitly weaker than checking the live database, because schema drift is the thing being tested.

There is also a related but different question: should AI agents access Turso through MCP? Current official Turso MCP support is attached to `tursodb`, the embedded Turso Database binary, and is most directly useful for local database files. It does not replace the Turso Cloud CLI for `turso db shell <database-name>` proof against a hosted Turso Cloud database.

```text
Turso tooling surface

  Hosted Turso Cloud DB
        |
        v
  turso CLI
        |
        +--> auth login
        +--> db shell contentflow-prod2 ".schema ..."
        +--> db show / tokens / org / group

  Local embedded DB file
        |
        v
  tursodb
        |
        +--> SQL shell
        +--> --mcp stdio server for local DB tools

  AgentFS
        |
        v
  agentfs serve mcp
        |
        +--> filesystem/key-value MCP tools, not Turso Cloud schema proof
```

## Option Space

### Option A: Keep Turso Project-Local

- Summary: Continue using project Flox environments, like `contentflow_lab`, to provide `turso` only where a project needs it.
- Pros:
  - Least invasive to ShipFlow.
  - Matches the existing Flutter/Dart provisioning spec, which says Turso should be handled separately.
  - Keeps project-specific verification tools scoped to projects that actually use Turso.
- Cons:
  - Operators and agents must know which project directory to activate.
  - Root-level ShipFlow checks still say `turso` is missing.
  - Cross-project audits can fail if they run outside the right Flox env.

### Option B: Add ShipFlow-Managed Turso Tooling Support

- Summary: Add a small ShipFlow-owned command or provisioning path that installs or verifies Turso tooling and tells users how to authenticate.
- Pros:
  - Turns a repeated verification blocker into a supported operator path.
  - Can standardize diagnostics: not installed, installed but unauthenticated, provider missing, wrong project env.
  - Can preserve security by never storing Turso tokens and by requiring explicit auth.
- Cons:
  - Requires a spec because it touches installer/tooling ownership and external CLI auth.
  - Supply-chain and install-source policy matters if using `curl | bash`.
  - Global install may be broader than needed for projects that do not use Turso.

### Option C: Add MCP-Only Turso Support

- Summary: Configure MCP access to Turso-related tools, either official `tursodb --mcp` for local DB files or a third-party cloud wrapper.
- Pros:
  - Useful for interactive AI database exploration.
  - Official `tursodb --mcp` is built into Turso Database and exposes schema/query/mutation tools for local DB files.
- Cons:
  - Does not solve the current `turso db shell contentflow-prod2` proof by itself.
  - Third-party cloud MCP wrappers need separate trust review and secret handling.
  - MCP tools may widen data access if not read-only or scoped carefully.

## Comparison

| Criterion | Project-local Flox | ShipFlow-managed CLI | MCP-only |
| --- | --- | --- | --- |
| Solves hosted schema proof | Yes, if activated and authenticated | Yes | Not by default |
| Solves "turso not on PATH" globally | No | Yes | No |
| Matches current local evidence | Yes, `contentflow_lab` already has it | Not yet | Partially for `tursodb` only |
| Security sensitivity | Medium: local CLI auth | Medium: install and auth guidance | High if cloud DB tokens go into MCP env |
| Best first use | Current ContentFlow proof | Repeated cross-project audits | Local DB exploration |

## Emerging Recommendation

The practical split is:

1. For the immediate schema proof, use the existing `contentflow_lab` Flox env or add a documented ShipFlow helper that activates the right project env before running `turso`.
2. If Turso proof is becoming a repeated ShipFlow audit gate, create a small spec for ShipFlow Turso tooling support.
3. Do not treat MCP as the replacement for Cloud CLI schema proof. MCP may be useful later, but it is a separate capability with different risk.

Preferred next chantier, if we want ShipFlow to own this:

```text
/sf-spec ShipFlow Turso tooling support
```

The spec should decide whether ShipFlow installs `turso` globally/user-locally, provisions it per project through Flox, or only adds a diagnostic/help command that routes to project Flox envs.

## Non-Decisions

- Whether to install Turso globally through ShipFlow.
- Whether to add `turso` to ShipFlow prerequisites.
- Whether to configure any Turso MCP server for Claude/Codex.
- Whether to use a third-party MCP wrapper for hosted Turso Cloud databases.

## Rejected Paths

- Treating `tursodb --mcp` as the answer to hosted Cloud schema proof - It targets embedded/local database usage and does not directly replace `turso db shell contentflow-prod2`.
- Silently adding Turso to an unrelated Flutter/Dart provisioning chantier - That spec explicitly scopes Turso out.
- Persisting Turso auth tokens in ShipFlow docs or reports - Not needed and unsafe.

## Risks And Unknowns

- Auth state: `turso auth login` creates access-token state and the docs say reauthentication is required after one week. ShipFlow should report unauthenticated state clearly, not attempt to own token storage.
- Supply chain: official Turso CLI install docs include shell installer paths. A ShipFlow installer change should follow the existing installer supply-chain policy rather than add an unchecked `curl | bash` path casually.
- MCP data access: `tursodb --mcp` exposes query and mutation tools for the configured database. Any MCP integration must be scoped intentionally and avoid putting hosted DB tokens into broadly accessible config without review.
- Binary naming: local ContentFlow Flox exposes both `turso` and `tursodb`. ShipFlow diagnostics should distinguish them because they solve different problems.

## Redaction Review

- Reviewed: yes
- Sensitive inputs seen: no secrets were printed. Searches encountered user-local history/log paths, but this report summarizes only non-sensitive command names and file paths.
- Redactions applied: none needed
- Notes: The report does not include token values, OAuth data, private database contents, or sensitive logs.

## Decision Inputs For Spec

- User story seed: As a ShipFlow operator verifying projects that use Turso Cloud, I want ShipFlow to reliably provide or route to an authenticated Turso CLI environment, so live schema proof does not fail merely because `turso` is missing from the current PATH.
- Scope in seed:
  - Detect `turso`, `tursodb`, and `agentfs` availability separately.
  - Add a Turso tooling diagnostic/help path.
  - Decide project-local Flox activation vs user/global install.
  - Document auth setup without storing tokens.
  - Preserve ContentFlow project-local Flox evidence.
- Scope out seed:
  - Do not auto-configure third-party MCP wrappers without separate trust review.
  - Do not persist Turso tokens in ShipFlow-managed files.
  - Do not make Turso a required global prerequisite for all ShipFlow users unless the spec explicitly accepts that support cost.
- Invariants/constraints seed:
  - Hosted schema proof uses `turso db shell <database-name> [sql]` or an equivalent official Turso Cloud path.
  - `tursodb --mcp` is a local/embedded DB capability, not a substitute for hosted Cloud schema proof.
  - Any installer path must follow ShipFlow supply-chain guardrails.
- Validation seed:
  - `command -v turso`
  - `turso --version`
  - `turso auth whoami` or equivalent non-secret auth status command if available
  - Project-local: `flox activate -d /home/ubuntu/contentflow/contentflow_lab -- turso --version`
  - Targeted schema proof: `turso db shell contentflow-prod2 ".schema content_bodies"`

## Handoff

- Recommended next command: `/sf-spec ShipFlow Turso tooling support`
- Why this next step: The decision affects installer/tooling ownership, external CLI authentication, project-local vs global runtime scope, and security guidance. It should be specified before implementation.

## Exploration Run History

| Date UTC | Prompt/Focus | Action | Result | Next step |
|----------|--------------|--------|--------|-----------|
| 2026-05-04 18:44:16 UTC | Record Turso CLI/MCP and local install findings | Checked official Turso docs, local ShipFlow/dotfiles references, user PATH, and ContentFlow Flox manifest evidence | Found official `turso` CLI, official `tursodb --mcp`, AgentFS MCP, no ShipFlow/dotfiles install, and project-local ContentFlow Flox install | `/sf-spec ShipFlow Turso tooling support` if ShipFlow should own the fix |
