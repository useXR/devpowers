---
name: playwright-testing
description: >
  This skill should be used when the user asks to "write e2e tests",
  "implement tests from journeys", "set up Playwright", "test the user flows",
  or when implementing test tasks. Generates tests from user journey maps
  for comprehensive coverage.
version: 1.0.0
forked_from: playwright-skill:playwright-skill v1.0.0
---

# Playwright Testing (devpowers fork)

**Fork notes:** Customized from playwright-skill plugin. Key changes:
- Journey map integration for test derivation
- Master document integration
- Learnings capture when tests reveal unexpected behavior

## Devpowers Integration

**Reads from:**
- `/docs/plans/[feature]/journeys/` — User journey maps
- `/docs/master/lessons-learned/testing.md` — Past testing learnings
- Task documents with "E2E Test Plan" section

**Writes to:**
- `learnings.md` — When tests reveal unexpected behavior

## Key Behaviors

- Generates tests FROM user journey maps (not ad-hoc)
- Covers error states, edge cases, accessibility per journey categories
- Validates against journey map completeness

## Test Derivation Process

1. Read journey map for component
2. For each journey:
   - Create test case with descriptive name
   - Implement steps from journey
   - Add assertions for expected outcomes
3. Verify all journeys have corresponding tests

## After Testing

Append to learnings.md when:
- Tests reveal unexpected application behavior
- New edge cases discovered
- Testing patterns prove useful

## Changelog

### v1.0.0 (devpowers)
- Added journey map integration
- Added master document integration
- Added learnings capture
