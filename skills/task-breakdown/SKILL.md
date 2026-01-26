---
name: task-breakdown
description: >
  This skill should be used when the user asks to "break down the plan",
  "create task files", "split into implementable tasks", "generate task documents",
  or after reviewing-plans completes successfully. Converts high-level architecture
  into discrete task files ready for domain review.
---

# Task Breakdown

Break a reviewed high-level plan into implementable task documents.

**Announce at start:** "I'm using the task-breakdown skill to create task files."

## Dispatch Agent

This skill delegates to the `task-breakdown` agent for execution.

**Dispatch with:**
```
Plan path: /docs/plans/[feature]/high-level-plan.md
Feature name: [feature]
Current scope: [Small/Medium/Large from STATUS.md]
```

The agent will:
1. Read the plan and identify task boundaries
2. Create task files in `/docs/plans/[feature]/tasks/`
3. Generate 00-overview.md with dependency map
4. Check for scope escalation triggers
5. Update STATUS.md
6. Return a summary

## After Agent Returns

Review the agent's summary for:

1. **Scope escalation warnings** - If detected, present to user:
   > "Task breakdown found scope triggers: [list]. Recommend escalating from [X] to [Y]. Adjust scope?"

2. **Task count sanity check** - More than 8 tasks may indicate scope creep

3. **Missing dependencies** - Verify task order makes sense

## Handoff

"Task breakdown complete. Created [N] tasks in `/docs/plans/[feature]/tasks/`.
[Scope re-evaluation note if applicable]

Ready for domain review?"

-> Invokes `domain-review`

## Templates (for agent reference)

The agent uses templates from:
- `assets/task-template.md`
- `assets/overview-template.md`
- `references/task-sizing-guide.md`
