# sf-scaffold

> Generate a new file that matches the project’s existing patterns instead of inventing a new local style.

## What It Does

`sf-scaffold` creates new pages, components, layouts, API routes, content entries, hooks, or utilities by reading the current codebase first and copying its conventions.

The goal is not speed alone. The scaffold should fit the project’s naming, imports, file placement, UX quality bar, and security posture. If the request is ambiguous in a way that affects permissions, product flow, or public behavior, the skill asks targeted questions or stops with a professional safe path.

## Who It's For

- Solo founders adding new surfaces to an existing product
- Developers who want consistency without manual boilerplate work
- Teams that care about not leaking insecure defaults into scaffolds

## When To Use It

- when you need a new page, component, hook, util, or API route
- when the repo already has patterns worth following
- when you want a professional safe path instead of a fake-complete artifact

## What You Give It

- a repo with existing files to learn from
- a file type and name
- enough intent to understand who the file serves and whether it is public, internal, or privileged

## What You Get Back

- a newly created file in the right location
- structure, imports, naming, and styling aligned with nearby examples
- a short report showing what was scaffolded, what examples were used, and any documentation or security impact
- or a blocked report with the missing decisions if safe scaffolding is not possible

## Typical Examples

```bash
/sf-scaffold component UserCard
/sf-scaffold page pricing
/sf-scaffold api webhooks
```

## Limits

`sf-scaffold` does not invent project conventions. If there are no reliable examples, or if the request would require guessing auth, tenant boundaries, destructive behavior, or public promises, it should stop or generate only a professional safe shell with explicit pending decisions.

## Related Skills

- `sf-spec` before scaffolding a non-trivial feature surface
- `sf-start` when you want the scaffold implemented into a complete task
- `sf-verify` after the new file becomes part of a user-facing flow
