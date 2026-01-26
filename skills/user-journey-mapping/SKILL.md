---
name: user-journey-mapping
description: >
  This skill should be used when the user asks to "map user journeys",
  "document user flows", "create E2E test scenarios", "map the user experience",
  or after cross-domain review completes for features with UI components.
  Creates user journey maps that drive E2E test planning.
---

# User Journey Mapping

Create journey documents that drive E2E test planning for UI features.

## Skip Conditions

Skip if:
- Feature has no UI components (pure backend/API)
- User explicitly chooses to skip

When skipping, update STATUS.md: "User journeys mapped [skipped: no UI]"

## Dispatch Agent

For features with UI components, dispatch `journey-mapper` agent:

```
Feature path: /docs/plans/[feature]/
Task files: [list of tasks with UI components]
Feature name: [feature]
```

The agent will:
1. Identify UI components in tasks
2. Create journeys for each category (happy path, error, edge, a11y)
3. Add E2E test plans to task files
4. Update STATUS.md

## After Agent Returns

Review journey coverage:
- All UI components have journeys?
- All four categories covered?
- E2E test plans added to tasks?

Then proceed:

"User journey mapping complete. Created [N] journeys.

Ready to create worktree and start implementation?"

→ Invokes `using-git-worktrees` then `subagent-driven-development`

## Journey Categories Reference

| Category | What to Document |
|----------|------------------|
| Happy Path | Primary success scenario |
| Error States | Invalid input, failures |
| Edge Cases | Empty, max, concurrent |
| Accessibility | Keyboard, screen reader |
