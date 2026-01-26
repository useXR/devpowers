---
name: test-driven-development
description: Use when implementing any feature or bugfix, before writing implementation code
---

# Test-Driven Development (TDD)

Write the test first. Watch it fail. Write minimal code to pass.

**Core principle:** If you didn't watch the test fail, you don't know if it tests the right thing.

## Dispatch Agent

For implementation tasks, dispatch the `tdd-implementer` agent.

**Dispatch with:**
```
Task spec: [from task document - goal, context, files, steps, criteria]
Test plan: [from task document - Unit Test Plan section]
Project context: [test framework, file locations]
```

The agent follows Red-Green-Refactor for each test and returns implementation with passing tests.

## When to Use Agent vs Manual

| Situation | Approach |
|-----------|----------|
| Implementing task from plan | Dispatch `tdd-implementer` agent |
| Quick bug fix | Follow cycle manually (see below) |
| Exploration/spike | Write throwaway code, then delete and use TDD |

## Manual TDD Cycle

For quick fixes without full agent dispatch:

### RED
Write one failing test. Run it. Confirm it fails for the right reason.

### GREEN
Write minimal code to pass. Run tests. All green.

### REFACTOR
Clean up. Keep tests green. Don't add behavior.

## Red Flags

These mean TDD was violated - delete code and restart:
- Code before test
- Test passed immediately
- Can't explain why test failed
- "Just this once" rationalization

## Reference Materials

For detailed examples and guidance:
- `./references/examples.md` - Good vs bad tests and implementations
- `./references/why-order-matters.md` - Why test-first matters
- `./testing-anti-patterns.md` - Common testing mistakes

## Verification Checklist

Before marking complete:
- [ ] Every function has a test
- [ ] Watched each test fail first
- [ ] Wrote minimal code to pass
- [ ] All tests pass
- [ ] No warnings in output
