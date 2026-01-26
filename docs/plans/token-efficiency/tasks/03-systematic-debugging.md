# Task 03: Compress systematic-debugging

> **Feature:** token-efficiency | [Previous](./02-test-driven-development.md) | [Next](./04-subagent-driven-development.md)

## Goal

Compress the debugging discipline skill from 1,504 to ~800 words while preserving discipline enforcement content inline.

## Context

This is a **discipline skill** - core process and discipline enforcers MUST stay inline. This skill already has external files (`root-cause-tracing.md`, `defense-in-depth.md`, `condition-based-waiting.md`) that should be moved to `references/` for consistency.

Current structure includes:
- Iron Law / core principle - MUST stay
- Four-phase debugging process - MUST stay
- Red flags / discipline content - MUST stay
- Verbose technique explanations - can move
- Existing external files - move to references/

## Files

**Modify:**
- `skills/systematic-debugging/SKILL.md` (compress to ~800 words)

**Move to references/:**
- `skills/systematic-debugging/root-cause-tracing.md` → `references/root-cause-tracing.md`
- `skills/systematic-debugging/defense-in-depth.md` → `references/defense-in-depth.md`
- `skills/systematic-debugging/condition-based-waiting.md` → `references/condition-based-waiting.md`

**Create:**
- `skills/systematic-debugging/references/` directory

## Implementation Steps

1. Create `skills/systematic-debugging/references/` directory
2. Move existing external files to `references/`:
   - `mv root-cause-tracing.md references/`
   - `mv defense-in-depth.md references/`
   - `mv condition-based-waiting.md references/`
3. Update SKILL.md references from `./filename.md` to `./references/filename.md`
4. Extract verbose explanations to references if needed
5. **VERIFY:** Core debugging process, Iron Law, red flags ALL still inline
6. **VERIFY:** Frontmatter unchanged
7. Count words with `wc -w SKILL.md` - target ≤800
8. Test: Invoke skill, verify discipline content appears immediately
9. Commit changes

## Acceptance Criteria

- [ ] SKILL.md word count ≤800 words
- [ ] Frontmatter (name, description) unchanged
- [ ] Core debugging process visible in SKILL.md
- [ ] Iron Law / principle visible in SKILL.md
- [ ] Red flags / discipline content visible in SKILL.md
- [ ] Existing external files moved to references/
- [ ] Reference pointers updated to new paths
- [ ] Skill triggers on "debug this issue"

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

- [x] **Existing features tested**: Skill triggers correctly, external file references work
- [x] **New dependencies assessed**: N/A
- [x] **Contracts aligned**: Reference paths updated correctly
- [x] **Degradation handled**: N/A

---

## Unit Test Plan

**Required Coverage Categories:**

- [x] **Happy Path**: Skill loads with discipline content inline
- [x] **Error/Exception Path**: N/A
- [x] **Edge/Boundary Case**: External file references resolve to new paths

---

## Behavior Definitions

| Scenario | Expected Behavior |
|----------|-------------------|
| Skill invoked | Core debugging process appears immediately |
| User needs root cause technique | Claude reads references/root-cause-tracing.md |
| User needs condition-based waiting | Claude reads references/condition-based-waiting.md |

---

## Spike Verification

**Spike N/A reason:** Pattern validated in Task 01. File moves are straightforward.
