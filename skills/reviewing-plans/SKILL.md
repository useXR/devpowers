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

**Announce at start:** "I'm using the reviewing-plans skill to critically review this plan."

## Scope Clarification

This skill reviews `high-level-plan.md` (architecture, approach, major components).

It does NOT review:
- Individual task files (that's `domain-review`)
- Integration between domains (that's `cross-domain-review`)
- Actual code (that's code reviewers)

## Review Loop: Convergence-Based

**NOT round-based.** Keep iterating until convergence:

```
CONVERGED when:
- 2 consecutive rounds find 0 new CRITICAL issues AND
- 2 consecutive rounds find 0 new IMPORTANT issues
- (MINOR issues do not block convergence)

ESCALATE when:
- 5+ rounds without convergence → ask user to intervene
- Issue count is stable but not decreasing → likely fundamental problem
```

**Why 2 consecutive rounds?** A single clean round could be lucky. Two consecutive clean rounds indicates stable convergence.

**What counts as "new"?** An issue is new if it identifies a problem not previously flagged. Rephrased versions of existing issues don't count as new.

## Workflow Position

```
writing-plans → reviewing-plans → task-breakdown
```

## The Process

### Step 1: Load Plan

Read the plan file. Extract:
- Goal and architecture
- All tasks/components with their descriptions
- Any assumptions or constraints mentioned
- Technology choices and dependencies

### Step 2: Dispatch Critics (Parallel, Flexible)

**Do NOT use predefined critics.** Instead, spin up multiple subagents to critique the plan. Let the LLM decide how many based on plan complexity.

Each subagent should receive this prompt:

```
Critically review this plan. Your job is to find issues that would cause
problems during implementation.

Look for BOTH:
1. What's WRONG with what's here (issues in existing content)
2. What's MISSING that should be here (gaps in coverage)

Categories to consider:
- Feasibility: Will this approach actually work?
- Completeness: Are all cases covered?
- Simplicity: Is this over-engineered?
- Security: Are there security risks?
- Integration: Will this work with existing systems?

For each issue, provide:
- Severity: CRITICAL (blocks execution) / IMPORTANT (high risk) / MINOR (friction)
- Location: Where in the plan
- Issue: What's wrong or missing
- Fix: Specific correction

End with: "Found X critical, Y important, Z minor issues."

Plan to review:
{PLAN_CONTENT}
```

Launch subagents simultaneously using the Task tool. Each will independently decide what to focus on based on the plan content.

### Step 3: Aggregate Findings

Collect all issues and organize by severity:

| Severity | Meaning | Action |
|----------|---------|--------|
| **CRITICAL** | Blocks execution | Must fix before starting |
| **IMPORTANT** | High risk | Should fix before execution |
| **MINOR** | May cause friction | Can address during implementation |
| **NITPICK** | Pedantic | Ignore |

Deduplicate issues found by multiple critics.

### Step 4: Check Convergence

**If CRITICAL or IMPORTANT issues found:**
- Apply fixes (or let user modify)
- Return to Step 2 (new round)

**If only MINOR/NITPICK issues found:**
- Proceed to Step 5 (Fresh Skeptic Pass)

### Step 5: Fresh Skeptic Pass

**After initial convergence, one final pass with fresh perspective:**

Spin up 1 subagent with this prompt:

```
You are reviewing this plan with fresh eyes. The previous reviewers found and
fixed several issues, and the plan now appears ready. Your job is NOT to
manufacture problems, but to ask the questions that might not have been asked.

Investigate:
- What assumptions does this plan make that weren't explicitly verified?
- What edge cases or failure modes weren't discussed?
- What integration points with existing systems weren't addressed?
- What security implications might have been overlooked?
- What happens if a key dependency doesn't work as expected?

Be calibrated: If you genuinely find nothing significant after thorough review,
say "Plan passes skeptic review - no significant gaps found." Do not manufacture
issues to justify your role.

If you DO find CRITICAL or IMPORTANT issues, list them with:
- What's missing or wrong
- Why it matters
- Suggested fix

Plan to review:
{PLAN_CONTENT}
```

**If skeptic finds CRITICAL/IMPORTANT issues:** Return to Step 2
**If skeptic approves:** Proceed to Step 6

### Step 6: Present Final Results

Format findings for the user:

```markdown
## Plan Review: [Plan Name]

### Summary
- Rounds completed: X
- Issues fixed: Y
- Remaining minor issues: Z

### Review History
| Round | Critics | CRIT | IMP | MIN | Outcome |
|-------|---------|------|-----|-----|---------|
| 1 | 2 | 3 | 5 | 2 | Fixed, continued |
| 2 | 2 | 0 | 2 | 3 | Fixed, continued |
| 3 | 2 | 0 | 0 | 1 | Converged |
| Skeptic | 1 | 0 | 0 | 0 | Passed |

### Minor Issues (Can Defer)
[List briefly - these can be addressed during implementation]

### Recommendation
Plan is ready for task breakdown. The minor issues can be addressed during implementation.
```

### Step 7: Task Breakdown Handoff

When ready to proceed:

> "Plan review complete. [X rounds, Y issues fixed, skeptic passed].
>
> Ready to break into implementable tasks?"

**REQUIRED SUB-SKILL:** Use devpowers:task-breakdown

## Recording Changes

After applying fixes, append to the **Revision History** section at the end of the plan:

```markdown
---

## Revision History

### v2 - YYYY-MM-DD - Plan Review Round 1

**Issues Addressed:**
- [CRITICAL] Task 3, Step 2: Fixed bcrypt API
- [IMPORTANT] Task 2: Added token expiry handling

**Reviewer Notes:** Plan had critical API compatibility issue.

### v3 - YYYY-MM-DD - Plan Review Round 2

**Issues Addressed:**
- [IMPORTANT] Added rate limiting consideration

**Reviewer Notes:** Convergence reached. Skeptic pass clean.
```

## Severity Reference

Read `./references/severity-guide.md` for detailed severity classification guidance.

## Escalation

If 5 rounds without convergence:

> "This plan has gone through 5 review rounds without converging. This usually means:
> 1. The plan has fundamental issues that fixes aren't addressing
> 2. The scope is too large and should be split
> 3. Requirements are unclear and need user clarification
>
> Options:
> - Continue reviewing (not recommended)
> - Split into smaller features
> - Clarify requirements with user
> - Accept current state and proceed (risks remain)"

## Integration

**Upstream:**
- devpowers:writing-plans - Creates plans this skill reviews

**Downstream:**
- devpowers:task-breakdown - Breaks reviewed plans into tasks

## Red Flags

**Never:**
- Skip review for complex plans (> 5 tasks or unfamiliar domain)
- Proceed with CRITICAL issues unfixed
- Apply fixes without showing user what changed
- Skip the skeptic pass (fresh perspective catches what familiarity misses)

**When critics find different issues:**
- This is good - different perspectives catch different things
- Combine all findings, deduplicate, prioritize by severity
