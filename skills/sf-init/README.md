# sf-init

> Turn an existing project into a ShipFlow-managed project with context files, task tracking, and workspace registration.

## What It Does

`sf-init` bootstraps a project for the ShipFlow workflow. It detects the stack, generates a project-specific `CLAUDE.md`, creates a real `TASKS.md` tracker, registers the project in the shared workspace registry, and can scaffold initial business and brand context files.

For a solo founder, this is the setup step that makes future work faster and more coherent. Instead of starting every session from scratch, the project gets an operating layer: conventions, priorities, and context documents close to the code.

## Who It's For

- Solo founders adopting ShipFlow on a new or existing repo
- Operators managing several active projects
- Developers who want project-specific context before serious work begins

## When To Use It

- when a repo is not yet set up for ShipFlow
- when you want consistent tracking across several products
- when a project lacks a `CLAUDE.md`, task tracker, or business context
- when onboarding an older codebase into a more disciplined workflow

## What You Give It

- the current project directory
- or an explicit project path
- optionally answers about the project’s purpose and brand tone

## What You Get Back

- a generated `CLAUDE.md`
- a populated `TASKS.md` tracker and project registration
- initial context documents such as `BUSINESS.md` and `BRANDING.md`
- a stronger operating base for the rest of the ShipFlow skills

## Typical Examples

```bash
/sf-init
/sf-init /path/to/project
```

## Limits

`sf-init` creates the operating scaffolding, not the product itself. The first pass may still contain draft assumptions that need human confirmation, especially in business and brand documents.

## Related Skills

- `sf-docs` to refine generated project documentation
- `sf-help` to understand the workflow after setup
- `sf-start` once the project is ready for implementation work
