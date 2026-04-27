---
title: "sf-verify"
slug: "sf-verify"
tagline: "Check whether the work really satisfies the user story, not just whether the code compiles."
summary: "A verification skill for judging readiness against behavior, completeness, risk, and the promises made by the task, then recording the chantier verdict when applicable."
category: "Core Workflow"
audience:
  - "Founders who want a stronger ship gate than lint and build"
  - "Teams that care about user-story correctness and residual risk"
problem: "Technical checks can pass while the work still misses the actual promise, leaves docs stale, or hides risky edge cases."
outcome: "You get a more honest readiness call before the changes move into closure or release."
founder_angle: "This skill matters because finished code is not the same thing as finished work. It asks whether the outcome is actually safe and complete enough to trust."
when_to_use:
  - "After implementation is done"
  - "When the task touched meaningful behavior, data, or user-facing outcomes"
  - "Before closing a task or shipping changes"
what_you_give:
  - "A completed implementation or review target"
  - "The current task contract or user story when available"
what_you_get:
  - "A behavior-aware readiness judgment"
  - "Findings around completeness, risk, and regressions"
  - "A verification result in the spec's chantier flow when a unique spec is in scope"
  - "A stronger basis for end-of-task or shipping decisions"
example_prompts:
  - "/sf-verify"
  - "/sf-verify after onboarding fix"
  - "/sf-verify current branch before ship"
limits:
  - "It raises the quality bar, but cannot prove the absence of every defect"
  - "Weak upstream specs still reduce the strength of downstream verification"
related_skills:
  - "sf-check"
  - "sf-end"
  - "sf-ship"
featured: true
order: 60
---
