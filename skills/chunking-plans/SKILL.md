---
name: chunking-plans
description: >
  This skill should be used when the user asks to "split a plan into smaller files",
  "chunk this plan", "break up the plan document", "create task files from this plan",
  or when a plan created with writing-plans has grown large (>500 lines or 5+ major tasks).
  Transforms monolithic implementation plans into navigable task file folders.
forked_from: userSettings:chunking-plans
---

# Chunking Plans (devpowers fork)

## Overview

Transform a monolithic implementation plan into a folder of interconnected task files. Distinct from `task-breakdown` which does initial breakdown; this skill handles **recursive subdivision** during domain review.

## When to Apply

Apply this skill when:
- A plan document exceeds ~500 lines
- A plan contains 5+ major tasks
- The user explicitly requests splitting/chunking
- Navigation through a large plan becomes cumbersome
- **Domain review flags "task too complex"**

## Recursion Rules

- **Maximum depth:** 3 levels (task -> subtask -> sub-subtask)
- **If deeper needed:** Reconsider task boundaries, likely architectural issue
- **Naming convention:** `tasks/03-auth/subtasks/01-validation/subtasks/01-email.md`

## Domain Review Integration

When critic flags "task too complex":
1. Pause domain review
2. Invoke chunking-plans -> creates subtask folder
3. Resume domain review on NEW subtasks (round counter resets for new tasks)
4. Original task marked as "container" (not directly implemented)

## Complexity Signals (Triggers Chunking)

- Task description exceeds 500 words
- More than 10 implementation steps
- Multiple unrelated acceptance criteria
- Critic explicitly flags complexity

## Output Structure

```
docs/plans/<feature>/tasks/
├── 00-overview.md
├── 01-first-task.md
├── 02-second-task/              # Container task
│   ├── 00-overview.md           # Subtask index
│   ├── 01-subtask-a.md
│   └── 02-subtask-b.md
├── 03-third-task.md
└── 99-verification.md
```

## Process

1. Identify tasks needing subdivision
2. Create subtask folder inside parent task
3. Create 00-overview.md for subtask index
4. Move implementation details to subtask files
5. Update parent task as "container" with pointer to subtasks
6. Update navigation links

## Container Task Format

When a task becomes a container:

```markdown
# Task 02: Authentication

> This task has been subdivided. See [subtasks/](./02-authentication/) for implementation.

## Subtask Overview

| # | Subtask | Description |
|---|---------|-------------|
| 01 | Token Validation | JWT verification |
| 02 | Session Management | Session handling |

## Dependencies

Same as before, but completion depends on all subtasks.
```

## Navigation

- Container tasks link to their subtask 00-overview.md
- Subtasks link back to parent container
- Linear navigation continues through subtasks before proceeding

## Changelog

### v1.0.0 (devpowers)
- Added recursion rules and domain review integration
- Added container task format
- Added complexity signals
