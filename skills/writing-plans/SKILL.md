---
name: writing-plans
description: Use when you have a spec or requirements for a multi-step task, before touching code
---

# Writing Plans

Convert brainstorming output into a high-level architecture plan.

**Announce at start:** "I'm using the writing-plans skill to create the high-level plan."

## Dispatch Agent

Dispatch the `plan-writer` agent with:
```
Brainstorm path: /docs/plans/[feature]/brainstorm.md
Feature name: [feature]
Current scope: [Small/Medium/Large from STATUS.md]
```

The agent will:
1. Read brainstorm document
2. Identify and verify risky assumptions (spikes)
3. Write high-level-plan.md
4. Update STATUS.md

## After Agent Returns

### If Success
Review the plan summary. Proceed to plan review:

"High-level plan complete. Ready for plan review?"

→ Invokes `reviewing-plans`

### If Spike Failed
Agent returns failure with options. Present to user:

"Spike verification failed for [assumption]. Options:
1. Adjust approach: [agent's suggestion]
2. Accept risk and proceed
3. Abandon this approach

Which option?"

Then re-dispatch agent with decision, or adjust brainstorm.

## Plan Focus (Reference)

Plans should include:
- Major components and responsibilities
- Data flow between components
- Key interfaces and contracts
- Technology choices with rationale
- Error handling strategy
- Testing approach

Plans should NOT include:
- Specific function implementations
- Line-by-line code changes
- Detailed file modifications
