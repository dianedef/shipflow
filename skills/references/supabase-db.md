# Supabase Database Reference

Use this reference when the task touches Supabase Postgres schema design, RLS, data APIs, tenant isolation, or server-vs-browser data access choices.

Sources checked:
- https://supabase.com/docs/guides/database/postgres/row-level-security
- https://supabase.com/docs/guides/database/secure-data
- https://supabase.com/docs/guides/api/securing-your-api
- https://supabase.com/docs/guides/database/postgres/column-level-security
- https://supabase.com/docs/guides/auth/jwt-fields

Last reviewed: 2026-04-26

## When To Load This

- A table is queried from browser code or the auto-generated Supabase APIs.
- The task changes schema, policies, ownership, or tenant scoping.
- Auth appears correct, but reads/writes still fail.
- An agent is about to design or scaffold CRUD on top of Supabase.
- A route or server action is choosing between user-scoped access and admin/service access.

## Core Rules

- Treat any table in an exposed schema, especially `public`, as browser-reachable unless proven otherwise.
- Enable RLS on exposed tables. Without RLS, exposed data is too easy to leak. With RLS enabled, the public `anon` path sees nothing until policies exist.
- Write policies for each operation you actually need: `select`, `insert`, `update`, `delete`.
- `auth.uid()` returns `null` for unauthenticated requests. Prefer explicit checks like `auth.uid() is not null and auth.uid() = user_id`.
- Authorization claims belong in `raw_app_meta_data`, not `raw_user_meta_data`, because user metadata is mutable by the authenticated user.
- Security-definer functions should not live in exposed schemas.
- Service-role access is a privileged server path, not a shortcut for client or mixed-trust code.

## Design Guidance

- Model tenant isolation explicitly in tables and policies. "Authenticated user" alone is rarely enough in multi-tenant products.
- Keep policy logic readable and auditable. If policy joins get complex, document the trust model and test the abuse cases.
- Prefer migrations or repo-managed SQL over dashboard-only drift when the project already has a schema workflow.
- Separate "can read row" from "can mutate row"; do not assume one implies the other.

## What To Inspect

- Schema and migration files
- RLS state for touched tables
- Policies per operation
- Whether browser code, server user-context code, or service-role admin code is being used
- Any helper functions referenced from policies
- How app-level records map to `auth.users`, tenants, orgs, and storage object paths

## Common Failure Modes

- Table is in `public` but RLS was never enabled.
- RLS is enabled, but only `select` policy exists and writes fail.
- Policy uses `auth.uid() = user_id` without guarding against unauthenticated `null`.
- Authorization relies on `raw_user_meta_data`, which users can change.
- Server code accidentally uses service-role access where user-scoped access was required, hiding real policy bugs.
- Client code attempts writes that should go through a trusted server path.
- Cross-tenant access is possible because policies only check `authenticated` and not org/project ownership.
- Policy functions in exposed schemas create an unnecessary trust boundary risk.
- Policy logic works functionally but becomes slow due to repeated joins or per-row heavy checks.

## Default Checklist

1. Identify whether the path is browser user-context, server user-context, or server admin-context.
2. Verify RLS is enabled on exposed tables.
3. Verify all required operations have explicit policies.
4. Verify policy predicates match the real ownership model.
5. Check whether claims come from trusted app metadata or untrusted user metadata.
6. Re-run the user story through an adversarial lens: unauthenticated user, wrong tenant, stale session, replayed request, and over-privileged server path.
