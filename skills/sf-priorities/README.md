# sf-priorities

> Re-rank your task backlog so the next thing you do is the one that matters most.

## What It Does

`sf-priorities` reviews open tasks and reorders them using impact, effort, blockers, dependencies, and delivery risk. It is designed for ShipFlow workspaces that track multiple projects, but it is still useful inside a single repo.

The point is not to create a perfect roadmap. The point is to stop a founder from spending a day on low-value work while the real blocker sits untouched.

## Who It's For

- Solo founders juggling several products or experiments
- Operators managing a shared `TASKS.md`
- Teams that need a clearer P0 before starting a new work session

## When To Use It

- when the backlog feels noisy or stale
- when too many tasks look equally urgent
- after a strategy change, launch, outage, or major customer signal

## What You Give It

- a ShipFlow workspace or project with tracked tasks
- optionally, a prioritization angle such as `impact`, `effort`, `blockers`, or `high-roi` / `quick-wins`
- optionally, a project name when you do not want a workspace-wide pass

## What You Get Back

- updated priority buckets
- clearer P0/P1/P2/P3 separation
- rationale for the top tasks
- a recommendation for what to start next

## Typical Examples

```bash
/sf-priorities
/sf-priorities high-roi
/sf-priorities blockers
```

## Limits

- Priority quality depends on the quality of the task list.
- It can organize work, but it cannot invent missing product strategy.
- If tasks are vague or outdated, they may need refinement before the ranking becomes reliable.

## Related Skills

- `sf-tasks` to clean up the backlog structure
- `sf-start` once the top task is chosen
- `sf-resume` for a fast thread-level status snapshot
