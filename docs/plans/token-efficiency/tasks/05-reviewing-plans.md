# Task 05: Compress reviewing-plans

> **Feature:** token-efficiency | [Previous](./04-subagent-driven-development.md) | [Next](./06-domain-review.md)

## Goal

Compress the reviewing-plans skill from 1,157 to ~600 words. This skill already has a `references/` directory with `severity-guide.md`.

## Context

This skill already uses the references/ pattern - it has `severity-guide.md` in references/. The main SKILL.md may have additional content that can be moved. Focus on keeping convergence rules and critic dispatch workflow inline.

Current structure includes:
- Convergence rules - MUST stay (procedural)
- Critic dispatch workflow - MUST stay (core process)
- Severity guide - already in references/
- Detailed examples - can move
- Verbose explanations - can move

## Files

**Modify:**
- `skills/reviewing-plans/SKILL.md` (compress to ~600 words)

**Already exists:**
- `skills/reviewing-plans/references/severity-guide.md`

**Create (if needed):**
- `skills/reviewing-plans/references/examples.md`

## Implementation Steps

1. Audit current SKILL.md content
2. Identify verbose content that can move to references/
3. Extract examples and verbose explanations to `references/examples.md`
4. **VERIFY:** Convergence rules still inline
5. **VERIFY:** Critic dispatch workflow still inline
6. **VERIFY:** Frontmatter unchanged
7. Count words with `wc -w SKILL.md` - target ≤600
8. Test: Invoke skill, verify convergence rules and workflow appear
9. Commit changes

## Acceptance Criteria

- [ ] SKILL.md word count ≤600 words
- [ ] Frontmatter (name, description) unchanged
- [ ] Convergence rules visible in SKILL.md
- [ ] Critic dispatch workflow visible in SKILL.md
- [ ] Reference pointers use standard format
- [ ] Skill triggers on "review this plan"

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

- [x] **Existing features tested**: Skill triggers, severity guide loads
- [x] **New dependencies assessed**: N/A
- [x] **Contracts aligned**: Existing reference pattern maintained
- [x] **Degradation handled**: N/A

---

## Unit Test Plan

**Required Coverage Categories:**

- [x] **Happy Path**: Skill loads, runs critics
- [x] **Error/Exception Path**: N/A
- [x] **Edge/Boundary Case**: Severity guide reference works

---

## Behavior Definitions

| Scenario | Expected Behavior |
|----------|-------------------|
| Skill invoked | Convergence rules appear immediately |
| Classifying issue severity | Claude reads references/severity-guide.md |

---

## Spike Verification

**Spike N/A reason:** Skill already uses references/ pattern successfully.
