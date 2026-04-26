# Supabase Auth Reference

Use this reference when a project uses Supabase Auth directly or through `@supabase/supabase-js` and `@supabase/ssr`.

Sources checked:
- https://supabase.com/docs/guides/auth
- https://supabase.com/docs/guides/auth/sessions
- https://supabase.com/docs/guides/auth/server-side
- https://supabase.com/docs/guides/auth/server-side/nextjs
- https://supabase.com/docs/guides/auth/quickstarts/nextjs
- https://supabase.com/docs/guides/auth/redirect-urls
- https://supabase.com/docs/reference/javascript/auth-getsession
- https://supabase.com/docs/guides/troubleshooting/how-do-you-troubleshoot-nextjs---supabase-auth-issues-riMCZV

Last reviewed: 2026-04-26

## When To Load This

- Login works differently between browser and server.
- OAuth, magic link, OTP, password reset, or callback redirects behave incorrectly.
- A page loops back to login even though the user seems signed in.
- SSR frameworks use cookies and `@supabase/ssr`.
- The app is logged in, but protected server reads still fail.

## Stack Signals

- Packages: `@supabase/supabase-js`, `@supabase/ssr`
- Env vars: `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY`, `NEXT_PUBLIC_SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`
- Files like `middleware.ts`, `proxy.ts`, `utils/supabase/*`, `/auth/callback`, `/auth/confirm`
- Calls such as `supabase.auth.signInWithOAuth`, `signInWithPassword`, `verifyOtp`, `exchangeCodeForSession`, `getUser`, `getSession`

## Core Rules

- Supabase Auth uses a short-lived JWT access token plus a refresh token for the session lifecycle.
- For SSR apps, use `@supabase/ssr` and separate browser/server clients wired to cookies.
- In Next.js SSR setups, middleware or proxy is responsible for refreshing expired auth tokens and writing refreshed cookies because Server Components cannot write cookies themselves.
- On the server, trust `supabase.auth.getUser()` for authorization-sensitive decisions. Do not treat `getSession()` from cookie-backed storage as authoritative.
- `SUPABASE_SERVICE_ROLE_KEY` is server-only. Never expose it to browser code, public env vars, or client bundles.
- Supabase Auth integrates with database RLS, so "login succeeded" does not prove the app can read or mutate the intended data.

## Redirect And Callback Rules

- `SITE_URL` is the default redirect destination when code does not provide `redirectTo`.
- `redirectTo` must match the project's redirect allow list.
- Preview and local environments usually need explicit additional redirect URLs. Wildcards can help for preview hosts, but production should prefer exact paths.
- Email confirmation, password reset, and magic-link flows often fail because templates or callback handlers still point at `SiteURL` when the app expects `RedirectTo`.
- OAuth failures often come from three different places: provider redirect URI, Supabase redirect allow list, or app callback route handling.

## Files And Config To Inspect

- Auth client factories for browser/server usage
- `middleware.ts` or `proxy.ts`
- Auth callback or confirmation routes
- Env files and deployment secrets
- Client components that call Supabase Auth methods
- Server actions, route handlers, or loaders that derive the current user

## Browser Evidence To Capture

- Start URL, auth trigger, provider URL, callback URL, final URL
- Visible error text on callback or confirmation pages
- Whether the callback writes a session and lands on the expected route
- Whether a refresh or protected fetch immediately fails after apparent login
- Console or network signals around `/auth/v1/*`, callback routes, and protected data fetches

## Common Failure Modes

- Missing or stale `NEXT_PUBLIC_SUPABASE_URL` or publishable/anon key.
- Browser code or public env accidentally uses the service role key.
- SSR app uses `@supabase/supabase-js` directly where `@supabase/ssr` cookie wiring is required.
- Middleware/proxy is missing, so expired cookies are never refreshed.
- Server code uses `getSession()` as proof of identity instead of `getUser()`.
- `SITE_URL` or redirect allow list still points to localhost or the wrong preview/prod domain.
- OAuth provider callback is configured, but the app callback route does not exchange or consume the code correctly.
- Magic-link or password-reset templates send users to the wrong callback URL.
- Auth appears successful, but downstream reads fail because the table or storage RLS policy does not allow that user.

## Default Debug Checklist

1. Confirm which auth flow is broken: password, magic link, OAuth, OTP, password reset, or server-side session refresh.
2. Verify env keys and ensure service-role usage is server-only.
3. Verify redirect config: `SITE_URL`, redirect allow list, app callback route, and provider redirect URI if OAuth is involved.
4. Inspect SSR cookie wiring and middleware/proxy refresh behavior.
5. Reproduce in a browser and capture the exact stop point.
6. If login succeeds but data access fails, cross-check `/home/claude/shipflow/skills/references/supabase-db.md`.
