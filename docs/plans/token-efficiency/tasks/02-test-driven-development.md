# Task 02: Compress test-driven-development

> **Feature:** token-efficiency | [Previous](./01-using-devpowers.md) | [Next](./03-systematic-debugging.md)

## Goal

Compress the TDD discipline skill from 1,612 to ~900 words while preserving all discipline enforcement content inline.

## Context

This is a **discipline skill** - the red flags table and rationalization counters MUST stay inline to prevent shortcuts. Only verbose explanations and examples can move to references/.

Current structure includes:
- Iron Law statement - MUST stay (discipline enforcer)
- Red-green-refactor flow - MUST stay (core process)
- Common Rationalizations table - MUST stay (discipline enforcer)
- Red Flags list - MUST stay (discipline enforcer)
- Verification Checklist - MUST stay (core process)
- "Why Order Matters" verbose explanations - can move
- Detailed examples - can move
- testing-anti-patterns.md already external - keep external

## Files

**Modify:**
- `skills/test-driven-development/SKILL.md` (compress to ~900 words)

**Create:**
- `skills/test-driven-development/references/why-order-matters.md`
- `skills/test-driven-development/references/examples.md`

**Keep external (already exists):**
- `skills/test-driven-development/testing-anti-patterns.md`

## Implementation Steps

1. Create `skills/test-driven-development/references/` directory
2. Extract "Why Order Matters" verbose content to `references/why-order-matters.md`
3. Extract detailed examples to `references/examples.md`
4. In SKILL.md, replace extracted sections with reference pointers
5. **VERIFY:** Iron Law, red flags table, rationalizations table, red-green-refactor ALL still inline
6. **VERIFY:** Frontmatter unchanged
7. Count words with `wc -w SKILL.md` - target ≤900
8. Test: Invoke skill, verify discipline content appears immediately
9. Commit changes

## Acceptance Criteria

- [ ] SKILL.md word count ≤900 words
- [ ] Frontmatter (name, description) unchanged
- [ ] Iron Law statement visible in SKILL.md (not in references)
- [ ] Red flags table visible in SKILL.md (not in references)
- [ ] Common Rationalizations table visible in SKILL.md (not in references)
- [ ] Red-green-refactor flow visible in SKILL.md
- [ ] Verification Checklist visible in SKILL.md
- [ ] Reference pointers use standard format
- [ ] Skill triggers on "implement with TDD"

## Dependencies

- Depends on: Task 01 (validates pattern)
- Blocks: Task 07 (validation)

---

## Domain Checklists

### Security Checklist

**Security Checklist Status:** N/A

**N/A Justification:** Documentation restructuring only. No code, no external data, no state changes.

### Interface Checklist

**Interface N/A reason:** No user-facing interface. Skill content is documentation.

### Data/State Checklist

**Data/State N/A reason:** No persistent state. Markdown restructuring only.

### Integration Checklist

- [x] **Existing features tested**: Skill still triggers correctly
- [x] **New dependencies assessed**: N/A
- [x] **Contracts aligned**: Reference pointer format matches standard
- [x] **Degradation handled**: N/A

---

## Unit Test Plan

**Required Coverage Categories:**

- [x] **Happy Path**: Skill loads with discipline content inline
- [x] **Error/Exception Path**: N/A - documentation
- [x] **Edge/Boundary Case**: Verify red flags table NOT moved to references

---

## Behavior Definitions

| Scenario | Expected Behavior |
|----------|-------------------|
| Skill invoked | Red flags table appears immediately (not reference) |
| Skill invoked | Iron Law statement appears immediately |
| User needs detailed examples | Claude reads references/examples.md |

---

## Spike Verification

**Spike N/A reason:** Pattern validated in Task 01.
