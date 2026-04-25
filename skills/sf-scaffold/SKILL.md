---
name: sf-scaffold
description: Generate new files matching existing project patterns — pages, components, layouts, API routes, hooks, utils
disable-model-invocation: true
argument-hint: <type> <name> (e.g., "page about", "component UserCard")
---

## Context

- Current directory: !`pwd`
- Project CLAUDE.md: !`head -80 CLAUDE.md 2>/dev/null || echo "no CLAUDE.md"`
- Package.json: !`cat package.json 2>/dev/null | head -40 || echo "no package.json"`
- Project structure: !`find . -maxdepth 3 -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" -o -name "*.astro" -o -name "*.vue" -o -name "*.py" -o -name "*.sh" \) 2>/dev/null | grep -v node_modules | grep -v .git | grep -v dist | sort | head -40`

## Mode detection

Parse `$ARGUMENTS` for type and name:
- `page about` → type: page, name: about
- `component UserCard` → type: component, name: UserCard
- `api users` → type: api, name: users
- Empty → use AskUserQuestion

---

## Supported types

| Type | Description | Typical location |
|------|-------------|-----------------|
| `page` | Route/page file | `src/pages/`, `app/`, `pages/` |
| `component` | UI component | `src/components/`, `components/` |
| `layout` | Layout wrapper | `src/layouts/`, `app/layout` |
| `api` | API route/endpoint | `src/pages/api/`, `app/api/`, `convex/` |
| `content` | Content/blog post | `src/content/`, `content/` |
| `hook` | Custom hook | `src/hooks/`, `hooks/` |
| `util` | Utility function | `src/utils/`, `src/lib/`, `utils/` |

## Flow

### Step 1: Parse arguments

If `$ARGUMENTS` is empty, use **AskUserQuestion**:
- Q1: "What type of file should I scaffold?"
  - Options: page, component, layout, api, content, hook, util
- Q2: "What name?" (free text — user types via "Other")

Then capture the minimum product intent before generating anything:
- what user-facing outcome this file serves
- who the actor is
- whether the artifact is public-facing, internal, admin-only, or system-only
- whether it reads/writes sensitive data, performs privileged actions, calls external services, or changes an existing user flow
- whether it requires docs, README, examples, FAQ, onboarding, pricing, changelog or support copy to stay coherent

If any of those points is unclear and could materially change behavior, scope, product coherence, or security, stop and ask targeted questions instead of scaffolding immediately.

Use targeted prompts, not generic ones. Prefer questions that force an implementable decision, for example:
- "Is this page public, authenticated, or admin-only?"
- "Should this API route only read data, or can it also create/update/delete?"
- "Can users from another org/project ever access this resource?"
- "Is this meant to fit an existing flow, or is it the first step of a new flow?"
- "If the backend check fails, should the UI hide the action, disable it, or show an explicit error state?"

Do not invent answers when ambiguity affects:
- auth or authorization
- tenant/org/project boundaries
- data visibility, retention, export, or logging
- destructive or billable actions
- public navigation, SEO, analytics, or conversion flows
- success/error states that shape the product experience
- docs or support surfaces that would mislead users if left unchanged

### Step 2: Find existing examples

Find 2-3 existing files of the same type in the project:

```bash
# For pages:
find src/pages -maxdepth 2 -type f | head -3
# For components:
find src/components -maxdepth 2 -type f | head -3
# etc.
```

Read each example file completely.

Also read the nearest files that define the surrounding flow, not only files of the same type. Examples:
- for a `page`: nearby layout, route group, navigation entry, metadata, loading/error states
- for a `component`: parent screen/section, design primitives, tests, stories if present
- for an `api`: auth middleware, validators, service layer, neighboring endpoints, contract tests
- for `content`: sibling entries, schema/config, listing page, SEO fields

If the request appears to create a new public-facing surface, read enough nearby files to answer:
- how this product currently names and groups similar flows
- what level of polish/structure is expected
- where auth, validation, analytics, SEO, and error handling are usually enforced

### Step 3: Analyze patterns

From the examples, extract:
- **File extension**: `.astro`, `.tsx`, `.vue`, `.py`, etc.
- **Naming convention**: PascalCase, kebab-case, camelCase
- **Import style**: relative vs alias (`@/`), named vs default
- **Component structure**: function vs arrow, export style
- **Styling approach**: Tailwind classes, CSS modules, scoped styles
- **TypeScript patterns**: interface vs type, Props naming, generics
- **Frontmatter**: Astro frontmatter patterns, metadata
- **Framework patterns**: `getStaticPaths`, `loader`, `useQuery`, etc.

Also analyze product and risk coherence:
- **User story fit**: what user/job this file appears to serve
- **Flow placement**: entrypoint, next step, cancellation path, empty/loading/error states
- **Terminology**: product naming already used in UI/content/routes/docs
- **Quality bar**: baseline for copy clarity, accessibility, validation, feedback states, loading states, responsiveness
- **Security model**: where auth/authz, input validation, server enforcement, tenant scoping, and audit-sensitive behavior are handled
- **Documentation model**: where similar features are documented, linked, exampled, onboarded, or explained to support users

If the requested scaffold would conflict with existing terminology, route structure, component API shape, trust boundary patterns, or active documentation, stop and surface the conflict before generating.

### Step 4: Generate new file

Create the new file matching EXACTLY the patterns found:
- Same file extension
- Same naming convention
- Same import style and structure
- Same export pattern
- Same styling approach
- Placeholder content that matches the pattern

Additional generation rules:
- Preserve product coherence before speed. The scaffold must fit the surrounding user flow, naming, and quality bar.
- Preserve documentation coherence. If the scaffold introduces or changes feature behavior, create/update the matching doc surface only when the existing pattern is clear; otherwise report the doc gap.
- Default to the safest existing pattern, not the loosest one.
- For public-facing pages/components/content, include the states needed to avoid a broken or misleading experience: loading, empty, error, success, and permission-denied states when relevant.
- For API routes or server-facing code, do not scaffold privileged mutations, cross-tenant access, secret handling, webhook trust, or file processing unless the required security behavior is explicit from the project patterns or clarified by the user.
- Never rely on UI visibility alone as a control. If an action needs authorization, scaffold the server-side enforcement pattern used by the project, or stop and ask.
- Never scaffold raw acceptance of untrusted input when the project uses validation/sanitization/allowlists elsewhere.
- Never scaffold public artifacts with placeholder claims that could misrepresent pricing, security, compliance, availability, or product capabilities.
- If no safe and coherent version can be inferred, refuse to generate and list the blocking questions.

For ambiguous requests, prefer a minimal safe shell over a fake-complete artifact:
- `page`: route shell with explicit TODO markers for approved copy and behavior, plus safe empty/error structure
- `component`: presentational shell with typed props and no invented business logic
- `api`: read-only or stubbed handler returning `501 Not Implemented` until auth/authz/validation decisions are confirmed
- `content`: draft entry clearly marked as draft, following schema without invented promises

### Step 5: Report

```
SCAFFOLDED: [type] — [name]
─────────────────────────────
File:     [created file path]
Based on: [example files used]
Patterns: [key patterns matched]
─────────────────────────────
```

If scaffolding is blocked, report instead:

```text
NOT SCAFFOLDED: [type] — [name]
Reason: [behavior/scope/security/product coherence ambiguity]
Questions:
- [targeted decision needed]
- [targeted decision needed]
Safe path:
- [minimal next step or file shell that would be acceptable]
```

---

## Important

- **Never invent patterns.** Always derive from existing files in the project.
- **Consistency > creativity.** The generated file should look like it was written by the same developer.
- **User story > local convenience.** If a scaffold fits the code style but weakens the product flow or obscures the user outcome, it is not acceptable.
- **Ask when behavior matters.** Use targeted user prompts whenever uncertainty changes the actor, trigger, permissions, scope, or expected outcome.
- **Security by default.** Refuse to scaffold insecure defaults for public-facing, privileged, data-bearing, or externally exposed surfaces.
- **Coherence by default.** Refuse to introduce route names, copy, component APIs, or flow states that conflict with the surrounding product language and quality level.
- **Docs by default.** For feature scaffolds, identify whether docs/examples/onboarding/support should be updated or explicitly report `Documentation impact: none, because ...`.
- If no examples of the requested type exist, tell the user and ask how to proceed.
- For Astro projects: detect whether to use `.astro`, `.tsx`, or `.vue` based on existing patterns.
- For content files: use the project's content schema (Content Collections, MDX frontmatter).
- Name the file following the project's existing naming convention (don't impose a different one).
- Place the file in the correct directory based on where existing files of that type live.
- For requests touching auth, permissions, tenant boundaries, billing, uploads, admin, webhooks, external integrations, or public marketing surfaces, explicitly state the inferred risk level in the report:
  - `Security impact: none, because ...`
  - `Security impact: yes, scaffold limited by ...`
