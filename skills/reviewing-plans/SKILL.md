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

## Review Loop

This skill uses review loops. Follow the central review loop rules:
- Maximum 3 rounds per review stage
- Convergence: No CRITICAL or IMPORTANT issues
- After 3 rounds: Present user with accept/escalate/abort options

## Workflow Position

```
writing-plans → reviewing-plans → task-breakdown
```

## The Process

### Step 1: Load Plan

Read the plan file. Extract:
- Goal and architecture
- All tasks with their steps
- Any assumptions or constraints mentioned

### Step 2: Dispatch Critics (Parallel)

Launch 3 subagents simultaneously using the Task tool with `subagent_type: "general-purpose"`:

1. **Feasibility Critic** - Read `./feasibility-critic.md`, replace `{PLAN_CONTENT}` with actual plan
2. **Completeness Critic** - Read `./completeness-critic.md`, replace `{PLAN_CONTENT}` with actual plan
3. **Simplicity Critic** - Read `./simplicity-critic.md`, replace `{PLAN_CONTENT}` with actual plan

All three must run in parallel (single message with 3 Task tool calls).

### Step 3: Aggregate Findings

Collect all issues and organize by severity:

| Severity | Meaning | Action |
|----------|---------|--------|
| **CRITICAL** | Blocks execution | Must fix before starting |
| **IMPORTANT** | High risk | Should fix before execution |
| **MINOR** | May cause friction | Can address during implementation |
| **NITPICK** | Pedantic | Ignore |

### Step 4: Present Results

Format findings for the user:

```markdown
## Plan Review: [Plan Name]

### Summary
- Critical: X issues
- Important: Y issues
- Minor: Z issues

### Critical Issues (Must Fix)
[List each with location, issue, and suggested fix]

### Important Issues (Should Fix)
[List each with location, issue, and suggested fix]

### Minor Issues (Can Defer)
[List briefly - these can be addressed during implementation]

---

### Recommendation
[See Step 5]
```

### Step 5: Recommend Next Steps

Based on findings, recommend one of:

**If Critical issues exist:**
> "This plan has critical issues that would block execution. I recommend fixing these before proceeding. Would you like me to apply the suggested fixes, or would you prefer to modify the plan manually?"

**If only Important issues exist:**
> "This plan has important issues that could cause problems during execution. I recommend addressing these before starting. Another review round after fixes would help verify the changes. Apply fixes?"

**If only Minor/Nitpick issues:**
> "This plan is ready for execution. The minor issues found can be addressed during implementation. Proceed with execution?"

### Step 6: Handle User Response

Based on user choice:

- **"Apply fixes"** → Edit the plan file with suggested fixes, update revision history, then offer another review round
- **"Modify manually"** → Wait for user to edit, then offer to re-review
- **"Another round"** → Return to Step 2
- **"Proceed"** → Handoff to execution

### Step 6a: Record Changes (When Applying Fixes)

After applying fixes, append to the **Revision History** section at the end of the plan:

```markdown
---

## Revision History

### v2 - YYYY-MM-DD - Plan Review Round 1

**Issues Addressed:**
- [CRITICAL] Task 3, Step 2: Fixed bcrypt API (Feasibility)
- [IMPORTANT] Task 2: Added token expiry handling (Completeness)
- [IMPORTANT] Task 4: Added session limit test (Completeness)

**Reviewer Notes:** Plan had critical API compatibility issue that would have caused immediate failure.
```

If the section doesn't exist, create it. If it exists, append a new version entry.

This creates an audit trail showing:
- What changed between versions
- Why it changed (which critic, what severity)
- When changes were made

### Step 7: Task Breakdown Handoff

When ready to proceed:

> "Plan review complete. [Summary of findings/fixes].
>
> Ready to break into implementable tasks?"

**REQUIRED SUB-SKILL:** Use devpowers:task-breakdown

## Convergence Detection

A plan has converged when:
- No CRITICAL issues found
- No IMPORTANT issues found
- Only MINOR/NITPICK issues remain (or none)

After each round, evaluate:
- If CRITICAL found → "Must fix, then review again"
- If only IMPORTANT found → "Should fix, recommend one more round"
- If only MINOR found → "Ready to proceed, minor issues can be handled during implementation"
- If only NITPICK found → "Plan is solid, proceed with confidence"

## Example Workflow

```
You: I'm using the reviewing-plans skill to critically review this plan.

[Read docs/plans/2024-01-15-auth-feature.md]
[Dispatch 3 critic subagents in parallel]

Feasibility Critic: Found 1 critical, 2 minor issues
Completeness Critic: Found 0 critical, 3 important, 1 minor issues
Simplicity Critic: Found 0 critical, 1 important, 2 minor issues

## Plan Review: Auth Feature

### Summary
- Critical: 1 issue
- Important: 4 issues
- Minor: 5 issues

### Critical Issues (Must Fix)

**Task 3, Step 2: bcrypt version incompatibility**
The plan uses `bcrypt.hash(password, 10)` but the installed bcrypt@5.x
changed the API to require a salt object. Fix: Use `bcrypt.genSalt(10)`
then `bcrypt.hash(password, salt)`.

### Important Issues (Should Fix)

1. **Task 2: Missing password reset error handling** - No handling for
   expired tokens. Add token expiry check before reset.

2. **Task 4: No test for concurrent session limit** - Plan mentions
   limiting to 5 sessions but no test verifies enforcement.

[...]

### Recommendation
This plan has a critical issue (bcrypt API) that would cause immediate
failure. I recommend fixing this and the important issues before
proceeding. Would you like me to apply the suggested fixes?

User: Yes, apply the fixes

[Edit plan file with fixes]
[Append to Revision History section:]
  ### v2 - 2024-01-15 - Plan Review Round 1
  **Issues Addressed:**
  - [CRITICAL] Task 3, Step 2: Fixed bcrypt API (Feasibility)
  - [IMPORTANT] Task 2: Added token expiry handling (Completeness)
  - [IMPORTANT] Task 4: Added session limit test (Completeness)
  **Reviewer Notes:** Critical API compatibility issue fixed.

You: Fixes applied and recorded in revision history. I recommend one
more review round to verify the changes. Run another review?

User: Yes

[Dispatch critics again]

All critics: No critical or important issues. 2 minor, 1 nitpick.

### Recommendation
Plan is ready for execution. The minor issues can be addressed during
implementation. Proceed with execution?

User: Yes, subagent-driven

You: I'm using the subagent-driven-development skill to execute this plan.
[Continues with subagent-driven-development skill]
```

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
- Run more than 3 review rounds (diminishing returns - proceed with IMPORTANT if stuck)

**If critics disagree:**
- Feasibility trumps simplicity (can't simplify what won't work)
- Completeness and simplicity may conflict - present both views to user
