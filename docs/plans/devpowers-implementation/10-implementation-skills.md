# Task 10: Implementation Skills Updates

> **Devpowers Implementation** | [← Lessons Learned](./09-lessons-learned.md) | [Next: Hook Automation →](./11-hook-automation.md)

---

## Context

**This task updates implementation skills to integrate with devpowers workflow.** Ensures TDD uses pre-planned tests and learnings are captured.

### Prerequisites
- **Task 6** completed (domain-review with test planning exists)

### What This Task Modifies
- `skills/subagent-driven-development/SKILL.md`
- `skills/test-driven-development/SKILL.md`

### Tasks That Depend on This
- **Task 11** (Hook Automation) - SubagentStop hook validates review

### Parallel Tasks
This task can be done in parallel with:
- **Task 7** (Cross-Domain Review)
- **Task 8** (User Journey Mapping)

---

## Files to Modify

- `skills/subagent-driven-development/SKILL.md`
- `skills/test-driven-development/SKILL.md`

---

## Steps

### Step 1: Read current subagent-driven-development skill

```bash
cat skills/subagent-driven-development/SKILL.md | head -100
```

Note the current structure to preserve existing functionality.

### Step 2: Update subagent-driven-development SKILL.md

Add these sections to `skills/subagent-driven-development/SKILL.md`:

#### Add Task Execution section:

```markdown
## Task Execution

Before implementing each task:
1. Read task document from `/docs/plans/[feature]/tasks/`
2. Check "Unit Test Plan" section for pre-planned tests
3. Check "E2E Test Plan" section for integration tests
4. Follow TDD: Write tests first, then implement
```

#### Add Learnings Capture section:

```markdown
## Learnings Capture

During implementation, when you encounter:
- Multiple iterations needed to solve something
- Documentation that didn't match reality
- A pattern that emerged across multiple places
- A workaround that was required
- Something that "should have worked" but didn't

Append to `/docs/plans/[feature]/learnings.md`:

```markdown
### [Date/Task] - Brief title
**Context:** What was being attempted
**Issue:** What went wrong or was tricky
**Resolution:** What finally worked
**Lesson:** What to remember for next time
```
```

#### Add Code Review step:

```markdown
## After Each Task

After implementing a task:
1. Run tests to verify implementation
2. Invoke code-reviewer agent for review
3. Address any findings from review
4. Commit with descriptive message
5. Update STATUS.md task status to complete
```

#### Add TDD Flow section:

```markdown
## TDD Flow

For each task:
1. Read "Unit Test Plan" from task document
2. Write the first failing test from the plan
3. Run test, confirm it fails
4. Write minimal implementation to pass
5. Run test, confirm it passes
6. Repeat for remaining tests in plan
7. Check "E2E Test Plan" and ensure coverage
```

### Step 3: Read current test-driven-development skill

```bash
cat skills/test-driven-development/SKILL.md | head -100
```

### Step 4: Update test-driven-development SKILL.md

Add these sections to `skills/test-driven-development/SKILL.md`:

#### Add Test Plan Integration section:

```markdown
## Test Plan Integration

When a task document exists with test plans:
1. Read "Unit Test Plan" section for unit tests
2. Read "E2E Test Plan" section for integration tests
3. Implement tests in the order specified
4. Do not skip planned tests
5. Add additional tests only if gaps discovered
```

#### Add Test Types section:

```markdown
## Unit Tests (from domain review)

Execute tests from "Unit Test Plan":
- Function-level tests
- Edge cases
- Error handling

These tests were planned by the testing critic during domain review.

## E2E Tests (from journey mapping)

Execute tests from "E2E Test Plan":
- User journey scenarios
- Happy paths
- Error states
- Accessibility flows

These tests were derived from user journey mapping.
```

### Step 5: Commit

```bash
git add skills/subagent-driven-development/
git add skills/test-driven-development/
git commit -m "feat: update implementation skills for devpowers workflow

- Add test plan integration to TDD skill
- Add learnings capture to subagent-driven-development
- Add code review step after each task
- Reference pre-planned tests from domain review"
```

---

## Verification Checklist

- [ ] `skills/subagent-driven-development/SKILL.md` has task execution instructions
- [ ] `skills/subagent-driven-development/SKILL.md` has learnings capture instructions
- [ ] `skills/subagent-driven-development/SKILL.md` has code review step
- [ ] `skills/test-driven-development/SKILL.md` has test plan integration
- [ ] `skills/test-driven-development/SKILL.md` distinguishes unit vs e2e tests
- [ ] Changes committed

---

## Next Steps

Proceed to **[Task 11: Hook Automation](./11-hook-automation.md)**.
