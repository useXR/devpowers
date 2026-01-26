# Task 04: Compress subagent-driven-development

> **Feature:** token-efficiency | [Previous](./03-systematic-debugging.md) | [Next](./05-reviewing-plans.md)

## Goal

Compress the subagent-driven-development skill from 1,499 to ~600 words by moving workflow details to references/.

## Context

This skill already has external prompt template files (`implementer-prompt.md`, `spec-reviewer-prompt.md`, `code-quality-reviewer-prompt.md`). These should be moved to `references/` for consistency. The core dispatch workflow and review process must stay inline.

Current structure includes:
- Core dispatch workflow - MUST stay
- Review workflow - MUST stay
- Prompt templates - already external, move to references/
- Detailed examples - can move
- Verbose explanations - can move

## Files

**Modify:**
- `skills/subagent-driven-development/SKILL.md` (compress to ~600 words)

**Move to references/:**
- `skills/subagent-driven-development/implementer-prompt.md` → `references/`
- `skills/subagent-driven-development/spec-reviewer-prompt.md` → `references/`
- `skills/subagent-driven-development/code-quality-reviewer-prompt.md` → `references/`

**Create:**
- `skills/subagent-driven-development/references/` directory
- `skills/subagent-driven-development/references/workflow-details.md` (if needed)

## Implementation Steps

1. Create `skills/subagent-driven-development/references/` directory
2. Move existing prompt templates to `references/`:
   - `mv implementer-prompt.md references/`
   - `mv spec-reviewer-prompt.md references/`
   - `mv code-quality-reviewer-prompt.md references/`
3. Update SKILL.md references from `./filename.md` to `./references/filename.md`
4. Extract verbose workflow explanations to `references/workflow-details.md`
5. **VERIFY:** Core dispatch workflow still inline
6. **VERIFY:** Review workflow still inline
7. **VERIFY:** Frontmatter unchanged
8. Count words with `wc -w SKILL.md` - target ≤600
9. Test: Invoke skill, verify workflow appears
10. Commit changes

## Acceptance Criteria

- [ ] SKILL.md word count ≤600 words
- [ ] Frontmatter (name, description) unchanged
- [ ] Core dispatch workflow visible in SKILL.md
- [ ] Review workflow visible in SKILL.md
- [ ] Prompt templates moved to references/
- [ ] Reference pointers updated to new paths
- [ ] Skill triggers on "execute this plan"

## Dependencies

- Depends on: Task 01 (validates pattern)
- Blocks: Task 07 (validation)

---

## Domain Checklists

### Security Checklist

**Security Checklist Status:** N/A

**N/A Justification:** Documentation restructuring only.

### Interface Checklist

**Interface N/A reason:** No user-facing interface.

### Data/State Checklist

**Data/State N/A reason:** No persistent state.

### Integration Checklist

- [x] **Existing features tested**: Skill triggers, prompt templates load
- [x] **New dependencies assessed**: N/A
- [x] **Contracts aligned**: Reference paths updated
- [x] **Degradation handled**: N/A

---

## Unit Test Plan

**Required Coverage Categories:**

- [x] **Happy Path**: Skill loads, dispatches subagents correctly
- [x] **Error/Exception Path**: N/A
- [x] **Edge/Boundary Case**: Prompt template references resolve

---

## Behavior Definitions

| Scenario | Expected Behavior |
|----------|-------------------|
| Skill invoked | Core dispatch workflow appears |
| Dispatching implementer | Claude reads references/implementer-prompt.md |
| Running code review | Claude reads references/code-quality-reviewer-prompt.md |

---

## Spike Verification

**Spike N/A reason:** Pattern validated in Task 01.
