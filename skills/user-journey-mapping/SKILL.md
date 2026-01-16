---
name: user-journey-mapping
description: >
  This skill should be used when the user asks to "map user journeys",
  "document user flows", "create E2E test scenarios", "map the user experience",
  or after cross-domain review completes for features with UI components.
  Creates user journey maps that drive E2E test planning.
---

# User Journey Mapping

## When to Use

- Features with user-facing UI components
- After cross-domain-review completes
- Can be skipped for backend-only features (mark as skipped in STATUS.md)

## Skip Conditions

Skip this skill if:
- Feature has no UI components (pure backend/API)
- User explicitly chooses to skip

When skipping, update STATUS.md with: "User journeys mapped [skipped: no UI]"

## Journey Categories Checklist

For each UI component, document journeys in these categories:

1. **Happy Path** — Primary success scenario
2. **Error States** — Invalid input, server errors, network failures
3. **Edge Cases** — Empty state, max limits, concurrent access
4. **Accessibility** — Keyboard navigation, screen reader flow

Read `references/journey-categories.md` for detailed guidance.

## Journey Document Format

Create journey files in `/docs/plans/[feature]/journeys/`:

```markdown
# Journey: [Journey Name]

## Category
[Happy Path | Error State | Edge Case | Accessibility]

## Preconditions
- [State before journey starts]

## Steps
1. User [action]
2. System [response]
3. User [action]
...

## Expected Outcome
[Final state]

## E2E Test Derivation
- Test name: [descriptive name]
- Setup: [preconditions]
- Actions: [steps to automate]
- Assertions: [expected outcomes to verify]
```

## Output Structure

Creates:
```
/docs/plans/[feature]/journeys/
├── 01-happy-path-login.md
├── 02-error-invalid-credentials.md
├── 03-edge-empty-form.md
└── 04-accessibility-keyboard-nav.md
```

## E2E Test Plan Integration

After documenting journeys, update task files with E2E Test Plan section:

```markdown
## E2E Test Plan (from journey mapping)
- [ ] Happy path: User can complete login flow
- [ ] Error: Invalid credentials show error message
- [ ] Edge: Empty form shows validation errors
- [ ] A11y: User can navigate form with keyboard only
```

## Workflow

1. Identify UI components in the feature
2. For each component, apply journey categories checklist
3. Create journey documents
4. Derive E2E test scenarios from journeys
5. Update task files with E2E test plans
6. Update STATUS.md

## State Update

After journeys complete, update STATUS.md:
- Stage: user-journey-mapping (complete)
- Last Action: User journeys mapped
- Next Action: Create worktree

## E2E Test Implementation

When E2E tests are implemented during subagent-driven-development:
- Implementer subagents use **devpowers:playwright-testing** skill
- Tests are derived from journey documents in `/docs/plans/[feature]/journeys/`
- Each journey maps to one or more test cases

## Handoff

"User journey mapping complete. Created [N] journeys in `/docs/plans/[feature]/journeys/`.

E2E test plans added to task files. Ready to create worktree and start implementation?"

-> Invokes `using-git-worktrees` then `subagent-driven-development`
