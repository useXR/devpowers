---
name: reviewing-plans
description: >
  This skill should be used when the user asks to "review the plan",
  "validate the architecture", "check if the plan is ready", "critique the design",
  or after writing-plans produces a high-level-plan.md file. Runs parallel critics
  to find issues before committing to implementation.
---

# Reviewing Plans

Dispatch parallel critic subagents to find issues in high-level plans before task breakdown.

**Announce:** "I'm using the reviewing-plans skill to critically review this plan."

## Scope

Reviews `high-level-plan.md` (architecture, approach, components). Does NOT review individual task files (domain-review), cross-domain integration, or actual code.

## Review Loop: Convergence-Based

**NOT round-based.** Keep iterating until convergence:

```
CONVERGED when:
- 2 consecutive rounds find 0 new CRITICAL issues AND
- 2 consecutive rounds find 0 new IMPORTANT issues
- (MINOR issues do not block convergence)

ESCALATE when:
- 5+ rounds without convergence → ask user to intervene
- Issue count stable but not decreasing → fundamental problem
```

**Why 2 consecutive rounds?** Single clean round could be lucky. Two consecutive indicates stable convergence.

**What counts as "new"?** Issue identifies problem not previously flagged. Rephrased versions don't count.

## Workflow Position

```
writing-plans → reviewing-plans → task-breakdown
```

## The Process

### Step 1: Load Plan

Read plan file. Extract goal, architecture, tasks/components, assumptions, constraints, and technology choices.

### Step 2: Dispatch Critics (Parallel)

Spin up multiple subagents based on plan complexity. See `./references/critic-prompt.md` for the prompt template. Launch simultaneously using Task tool.

### Step 3: Aggregate Findings

| Severity | Meaning | Action |
|----------|---------|--------|
| **CRITICAL** | Blocks execution | Must fix before starting |
| **IMPORTANT** | High risk | Should fix before execution |
| **MINOR** | May cause friction | Can address during implementation |
| **NITPICK** | Pedantic | Ignore |

Deduplicate issues found by multiple critics. See `./references/severity-guide.md` for detailed classification.

### Step 4: Check Convergence

- **CRITICAL/IMPORTANT found:** Apply fixes, return to Step 2
- **Only MINOR/NITPICK:** Proceed to Step 5

### Step 5: Fresh Skeptic Pass

After initial convergence, one final pass with fresh perspective. See `./references/skeptic-prompt.md` for prompt.

- **Skeptic finds CRITICAL/IMPORTANT:** Return to Step 2
- **Skeptic approves:** Proceed to Step 6

### Step 6: Present Results

```markdown
## Plan Review: [Plan Name]

### Summary
- Rounds completed: X | Issues fixed: Y | Remaining minor: Z

### Review History
| Round | Critics | CRIT | IMP | MIN | Outcome |
|-------|---------|------|-----|-----|---------|
| 1 | 2 | 3 | 5 | 2 | Fixed |
| 2 | 2 | 0 | 0 | 1 | Converged |
| Skeptic | 1 | 0 | 0 | 0 | Passed |

### Recommendation
Plan ready for task breakdown.
```

### Step 7: Handoff

> "Plan review complete. [X rounds, Y issues fixed, skeptic passed]. Ready to break into implementable tasks?"

**REQUIRED:** Use devpowers:task-breakdown

## Recording Changes

See `./references/recording-changes.md` for revision history format.

## Escalation

If 5 rounds without convergence, see `./references/escalation.md` for guidance and user options.

## Integration

- **Upstream:** devpowers:writing-plans
- **Downstream:** devpowers:task-breakdown

## Red Flags

**Never:**
- Skip review for complex plans (> 5 tasks or unfamiliar domain)
- Proceed with CRITICAL issues unfixed
- Apply fixes without showing user what changed
- Skip the skeptic pass (fresh perspective catches what familiarity misses)

**When critics find different issues:** This is good - different perspectives catch different things. Combine all findings, deduplicate, prioritize by severity.
