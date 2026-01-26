# Task 6: Testing & Verification

> **Feature:** tool-efficiency | [Previous](./05-project-setup.md)

## Goal

Test the complete tool-efficiency feature on sample projects (TypeScript, Python, Rust) and verify Haiku routing works.

## Context

This task validates that all components work together: universal git agents, stack-specific agents, dora integration, and hook merging.

## Files

**Create:**
- None (testing only)

**Test locations:**
- Fresh TypeScript project
- Fresh Python project
- Fresh Rust project (if available)

## Implementation Steps

1. **Test Universal Git Agents:**
   - Start new session in devpowers repo
   - Invoke git-status agent (should use Haiku)
   - Verify output shows repo status
   - Invoke git-sync agent
   - Invoke git-push agent (on a branch with unpushed commits)

2. **Test TypeScript Project Setup:**
   - Create minimal TS project: `npm init -y && npm i -D typescript jest`
   - Run project-setup skill
   - Verify:
     - `.dora/` created with config.json
     - `.claude/skills/dora/SKILL.md` exists (symlink or copy)
     - `.claude/agents/test.md` created with `npm test`
     - `.claude/settings.local.json` has dora hooks
   - Invoke test agent - verify Haiku handles it

3. **Test Python Project Setup:**
   - Create minimal Python project with pytest
   - Run project-setup skill
   - Verify:
     - Dora initialized (if scip-python available)
     - `.claude/agents/test.md` created with `pytest`
     - LSP advisory shown if pyright missing

4. **Verify Haiku Routing:**
   - Check that agents created have `model: haiku`
   - Invoke a stack-specific agent
   - Verify response indicates Haiku handled it (lighter response, faster)

5. **Test Edge Cases:**
   - Project with no test script - verify test.md agent skipped
   - Project with existing settings.local.json - verify hooks merged
   - Missing dora - verify advisory shown, setup continues

## Acceptance Criteria

- [ ] Universal git agents work and report correctly
- [ ] TypeScript project setup creates all expected files
- [ ] Python project setup creates all expected files
- [ ] Agents have `model: haiku` in frontmatter
- [ ] Hook merging preserves existing hooks
- [ ] Missing tools show advisory, don't crash

## Dependencies

- Depends on: Task 5 (all previous work)
- Blocks: None (final task)

---

## Domain Checklists

### Security Checklist

**Security Checklist Status:** N/A

**If N/A, verify all conditions:**
- [x] Task touches no external data paths (testing only)
- [x] Task produces no user/system output (verification only)
- [x] Task modifies no persistent state (test projects are disposable)
- [x] Task adds no new dependencies

**N/A Justification:** This is a testing/verification task on disposable test projects.

### Interface Checklist

**Interface N/A reason:** Testing task, not implementing interface.

### Data/State Checklist

**Data/State N/A reason:** Testing task on disposable projects.

### Integration Checklist

- [x] **Existing features tested**: Full integration of all tasks
- [x] **New dependencies assessed**: N/A - no new deps in testing
- [x] **Contracts aligned**: Verifying contracts defined in previous tasks
- [x] **Degradation handled**: Testing degradation scenarios explicitly

---

## Unit Test Plan

**Required Coverage Categories:**

- [x] **Happy Path**: Full setup on TypeScript project - all components work
- [x] **Error/Exception Path**: Setup with missing dora - advisory shown, continues
- [x] **Edge/Boundary Case**: Setup with existing hooks - merged correctly

## E2E/Integration Test Plan

This IS the E2E test task.

---

## Behavior Definitions

| Scenario | Expected Behavior |
|----------|-------------------|
| Agent invocation | Response should be concise (Haiku-style) |
| dora index on session start | Index runs in background, doesn't block |
| Multiple project-setup runs | Idempotent - doesn't duplicate hooks or agents |

---

## Spike Verification

**Spike N/A reason:** Testing existing implementation, no new patterns.
