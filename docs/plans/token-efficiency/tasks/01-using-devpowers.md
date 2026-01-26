# Task 01: Compress using-devpowers

> **Feature:** token-efficiency | [Overview](./00-overview.md) | [Next](./02-test-driven-development.md)

## Goal

Compress the always-loaded `using-devpowers` skill from 1,686 to ~600 words by moving detailed content to references/.

## Context

This is the highest-impact task - `using-devpowers` loads on every session via the SessionStart hook. Reducing it from 1,686 to 600 words saves ~1,100 tokens per session.

The skill contains:
- Scope tier definitions (Trivial/Small/Medium/Large) - verbose, can move
- Hard gates table - detailed, can move
- Scope precedence rules - edge cases, can move
- Red flags rationalization table - should stay inline per plan (only ~200 words)
- Entry-point workflow - must stay (routing logic)
- Scope decision flowchart - must stay (routing logic)
- Handoff rules - must stay (routing logic)

## Files

**Modify:**
- `skills/using-devpowers/SKILL.md` (compress to ~600 words)

**Create:**
- `skills/using-devpowers/references/scope-tiers.md`
- `skills/using-devpowers/references/hard-gates.md`
- `skills/using-devpowers/references/scope-precedence.md`

## Implementation Steps

1. Create `skills/using-devpowers/references/` directory
2. Extract "Scope Tiers (Detailed)" section (lines ~51-163) to `references/scope-tiers.md`
3. Extract "Hard Gates by Scope" table to `references/hard-gates.md`
4. Extract "Scope Precedence Rules" section to `references/scope-precedence.md`
5. In SKILL.md, replace extracted sections with reference pointers
6. Verify frontmatter (name, description) unchanged
7. Count words with `wc -w SKILL.md` - target ≤600
8. Test: Start new session, verify skill content appears
9. Test: Say "start a feature", verify routes to brainstorming
10. Commit changes

## Acceptance Criteria

- [ ] SKILL.md word count ≤600 words
- [ ] Frontmatter (name, description) unchanged
- [ ] references/ directory created with 3 files
- [ ] Reference pointers use standard format from plan
- [ ] Entry-point workflow still present in SKILL.md
- [ ] Scope decision flowchart still present in SKILL.md
- [ ] Red flags table still present in SKILL.md (inline)
- [ ] SessionStart hook works (skill appears in new session)
- [ ] Skill routing works ("start a feature" → brainstorming)

## Dependencies

- Depends on: None
- Blocks: Tasks 02-06 (proves pattern works)

---

## Domain Checklists

### Security Checklist

**Security Checklist Status:** N/A

**If N/A, verify all conditions:**
- [x] Task touches no external data paths
- [x] Task produces no user/system output
- [x] Task modifies no persistent state
- [x] Task adds no new dependencies

**N/A Justification:** This task only restructures markdown documentation files. No code execution, no external data, no persistent state changes.

### Interface Checklist

**Interface N/A reason:** No user-facing interface changes. Skill content is documentation only.

### Data/State Checklist

**Data/State N/A reason:** No persistent state modified. Only markdown files restructured.

### Integration Checklist

- [x] **Existing features tested**: SessionStart hook still works with compressed skill
- [x] **New dependencies assessed**: N/A - no new dependencies
- [x] **Contracts aligned**: Reference pointer format follows standard from plan
- [x] **Degradation handled**: N/A - no runtime components

---

## Unit Test Plan

**Required Coverage Categories:**

- [x] **Happy Path**: Skill routing - "start a feature" triggers brainstorming handoff
- [x] **Error/Exception Path**: N/A - documentation has no error paths
- [x] **Edge/Boundary Case**: Reference loading - "explain scope conflicts" triggers scope-tiers.md read

**Note:** Tests are manual verification since this is documentation restructuring.

## E2E/Integration Test Plan

- Verify new session shows compressed skill content
- Verify "start a feature" routes correctly
- Verify reference content loads when needed

---

## Behavior Definitions

| Scenario | Expected Behavior |
|----------|-------------------|
| New session starts | Compressed SKILL.md (~600 words) injected by hook |
| User says "start a feature" | Routes to brainstorming skill |
| User asks about scope precedence | Claude reads references/scope-precedence.md |
| User asks about hard gates | Claude reads references/hard-gates.md |

---

## Spike Verification

**Spike N/A reason:** Pattern already verified in plan - 9 existing skills use references/ pattern successfully.
