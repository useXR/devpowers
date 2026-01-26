---
name: chunking-plans
description: >
  This skill should be used when the user asks to "split a plan into smaller files",
  "chunk this plan", "break up the plan document", "create task files from this plan",
  or when a plan created with writing-plans has grown large (>500 lines or 5+ major tasks).
  Transforms monolithic implementation plans into navigable task file folders.
forked_from: userSettings:chunking-plans
---

# Chunking Plans

Subdivide complex tasks into smaller subtask files. Used during domain review when tasks are too large.

## When to Apply

- Domain review flags "task too complex"
- Task exceeds 500 words or 10+ implementation steps
- User explicitly requests chunking

## Dispatch Agent

Dispatch `task-chunker` agent with:

```
Task path: /docs/plans/[feature]/tasks/[NN]-[name].md
Complexity signals: [what triggered - word count, step count, critic flag]
Feature path: /docs/plans/[feature]/
```

The agent will:
1. Analyze task for logical boundaries
2. Create subtask folder and files
3. Convert original to container task
4. Update navigation links

## After Agent Returns

Resume domain review on the NEW subtasks:
- Round counter resets for new tasks
- Original task marked as "container"
- Container completes when all subtasks complete

## Recursion Rules

- **Maximum depth:** 3 levels (task → subtask → sub-subtask)
- **If deeper needed:** Likely architectural issue, reconsider boundaries

## Complexity Signals Reference

| Signal | Threshold |
|--------|-----------|
| Description length | > 500 words |
| Implementation steps | > 10 |
| Acceptance criteria | Multiple unrelated |
| Critic flag | "Task too complex" |
