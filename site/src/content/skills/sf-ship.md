---
title: "sf-ship"
slug: "sf-ship"
tagline: "Commit and push quickly when the work is actually ready, instead of stretching closure into another vague step."
summary: "A shipping skill for moving finished work through the final commit-and-push path with the right amount of ceremony."
category: "Core Workflow"
audience:
  - "Founders who prefer fast closure once work is ready"
  - "Operators who want a cleaner final step after validation"
problem: "Work can get stuck in a half-finished state where the changes are ready locally but never move cleanly through the final shipping step."
outcome: "You get a more decisive transition from verified local work to committed and pushed changes."
founder_angle: "This skill matters because shipping should be a crisp move, not an endless wobble after the real work is already done."
when_to_use:
  - "When the implementation is ready to commit and push"
  - "When you want the fast shipping path instead of a long close-out ritual"
  - "After technical and behavioral validation is already done"
what_you_give:
  - "A repo with ready-to-ship changes"
  - "The current branch and git state"
what_you_get:
  - "A cleaner final shipping move"
  - "Less hesitation between done locally and done in git"
  - "A tighter release habit for small workstreams"
example_prompts:
  - "/sf-ship"
  - "/sf-ship current branch"
  - "/sf-ship after verify"
  - "/sf-ship ship release notes all-dirty"
argument_modes:
  - argument: "no special argument"
    effect: "Runs quick ship mode: lightweight checks when practical, then commit and push."
    consequence: "Stages only changes that clearly belong to the current task or the selected shipping scope."
  - argument: "skip-check"
    effect: "Skips the pre-commit checks."
    consequence: "The report must say validation was skipped; this is a force-through path, not proof the work is safe."
  - argument: "end la tache / end / fin / close task"
    effect: "Switches from quick ship to full close mode."
    consequence: "Adds the formal close-out flow before shipping, including task/changelog bookkeeping when relevant."
  - argument: "all-dirty / ship-all / tout-dirty"
    effect: "Stages the entire dirty Git state in the selected repo after the secret check."
    consequence: "Includes modified, deleted, and untracked files even when they were not touched in the current conversation."
limits:
  - "It assumes the work is already ready; it is not a substitute for review or verification"
  - "If the branch is messy or the scope is unclear, earlier workflow steps still matter"
related_skills:
  - "sf-check"
  - "sf-verify"
  - "sf-prod"
featured: false
order: 90
---
