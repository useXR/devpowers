# Task 06: Compress domain-review

> **Feature:** token-efficiency | [Previous](./05-reviewing-plans.md) | [Next](./07-validation.md)

## Goal

Compress the domain-review skill from 1,093 to ~600 words. This skill already has a `references/` directory with `severity-guide.md` and `gap-finding-protocol.md`.

## Context

This skill already uses the references/ pattern extensively. Focus on keeping hard gate checking and convergence workflow inline. Most detailed content may already be externalized.

Current structure includes:
- Hard gate checking - MUST stay (procedural)
- Convergence workflow - MUST stay (core process)
- Severity guide - already in references/
- Gap-finding protocol - already in references/
- Detailed examples - can move

## Files

**Modify:**
- `skills/domain-review/SKILL.md` (compress to ~600 words)

**Already exists:**
- `skills/domain-review/references/severity-guide.md`
- `skills/domain-review/references/gap-finding-protocol.md`

**Create (if needed):**
- `skills/domain-review/references/examples.md`

## Implementation Steps

1. Audit current SKILL.md content
2. Identify verbose content that can move to references/
3. Extract examples and verbose explanations to `references/examples.md` if needed
4. **VERIFY:** Hard gate checking workflow still inline
5. **VERIFY:** Convergence workflow still inline
6. **VERIFY:** Frontmatter unchanged
7. Count words with `wc -w SKILL.md` - target ≤600
8. Test: Invoke skill, verify hard gates and convergence appear
9. Commit changes

## Acceptance Criteria

- [ ] SKILL.md word count ≤600 words
- [ ] Frontmatter (name, description) unchanged
- [ ] Hard gate checking visible in SKILL.md
- [ ] Convergence workflow visible in SKILL.md
- [ ] Reference pointers use standard format
- [ ] Skill triggers on "review tasks"

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

- [x] **Existing features tested**: Skill triggers, references load
- [x] **New dependencies assessed**: N/A
- [x] **Contracts aligned**: Existing reference pattern maintained
- [x] **Degradation handled**: N/A

---

## Unit Test Plan

**Required Coverage Categories:**

- [x] **Happy Path**: Skill loads, checks hard gates
- [x] **Error/Exception Path**: N/A
- [x] **Edge/Boundary Case**: Gap-finding reference works

---

## Behavior Definitions

| Scenario | Expected Behavior |
|----------|-------------------|
| Skill invoked | Hard gate checking appears immediately |
| Running gap-finding | Claude reads references/gap-finding-protocol.md |
| Classifying severity | Claude reads references/severity-guide.md |

---

## Spike Verification

**Spike N/A reason:** Skill already uses references/ pattern successfully.
