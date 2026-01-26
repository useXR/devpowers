# Task 07: Validation and Measurement

> **Feature:** token-efficiency | [Previous](./06-domain-review.md) | [Overview](./00-overview.md)

## Goal

Validate all compressed skills work correctly together and measure actual token savings against baseline.

## Context

This is the final validation task. All 6 skills have been compressed. Need to:
1. Verify complete workflow still works (brainstorm → plan → review → implement)
2. Measure actual word counts vs targets
3. Calculate total savings
4. Document results

## Files

**Read (to measure):**
- All 6 compressed SKILL.md files

**Modify:**
- `/docs/plans/token-efficiency/learnings.md` (document results)
- `/docs/plans/token-efficiency/STATUS.md` (mark complete)

## Implementation Steps

1. **Measure word counts:**
   ```bash
   wc -w skills/using-devpowers/SKILL.md
   wc -w skills/test-driven-development/SKILL.md
   wc -w skills/systematic-debugging/SKILL.md
   wc -w skills/subagent-driven-development/SKILL.md
   wc -w skills/reviewing-plans/SKILL.md
   wc -w skills/domain-review/SKILL.md
   ```

2. **Compare to targets:**
   | Skill | Target | Actual | Pass/Fail |
   |-------|--------|--------|-----------|
   | using-devpowers | ≤600 | ? | ? |
   | test-driven-development | ≤900 | ? | ? |
   | systematic-debugging | ≤800 | ? | ? |
   | subagent-driven-development | ≤600 | ? | ? |
   | reviewing-plans | ≤600 | ? | ? |
   | domain-review | ≤600 | ? | ? |

3. **Integration test:**
   - Start fresh session
   - Say "start a feature" (tests using-devpowers routing)
   - Go through brainstorming
   - Write a high-level plan (tests writing-plans)
   - Review the plan (tests reviewing-plans)
   - Would test implementation if time permits

4. **Calculate total savings:**
   - Before: 8,551 words
   - After: [sum of actuals]
   - Savings: [percentage]

5. **Document in learnings.md:**
   - Actual vs target comparison
   - Any unexpected issues
   - Recommendations for future

6. **Update STATUS.md:**
   - Stage: complete
   - Last Action: Validation passed

## Acceptance Criteria

- [ ] All 6 skills meet word count targets
- [ ] Integration test passes (complete workflow works)
- [ ] Total savings ≥40% (minimum threshold from plan)
- [ ] Results documented in learnings.md
- [ ] STATUS.md updated to complete

## Dependencies

- Depends on: Tasks 01-06 (all compressions complete)
- Blocks: None (final task)

---

## Domain Checklists

### Security Checklist

**Security Checklist Status:** N/A

**N/A Justification:** Validation/measurement only. No code changes.

### Interface Checklist

**Interface N/A reason:** Testing existing interfaces, no changes.

### Data/State Checklist

**Data/State N/A reason:** No state modifications.

### Integration Checklist

- [x] **Existing features tested**: Complete workflow tested
- [x] **New dependencies assessed**: N/A
- [x] **Contracts aligned**: N/A
- [x] **Degradation handled**: N/A

---

## Unit Test Plan

**Required Coverage Categories:**

- [x] **Happy Path**: Complete workflow executes successfully
- [x] **Error/Exception Path**: N/A for validation
- [x] **Edge/Boundary Case**: Skills at word count boundary still function

---

## Behavior Definitions

| Scenario | Expected Behavior |
|----------|-------------------|
| Word count above target | Task fails, skill needs more compression |
| Integration test fails | Identify which skill broke, revert if needed |
| Savings below 40% | Evaluate if acceptable or need more work |

---

## Spike Verification

**Spike N/A reason:** No new patterns - just measuring and testing.

---

## Rollback Criteria (from plan)

- If any skill fails to trigger on expected phrases: revert that skill immediately
- If workflow breaks (can't complete brainstorm→implement cycle): revert to last working state
- If token savings <40%: evaluate whether to proceed or adjust targets
