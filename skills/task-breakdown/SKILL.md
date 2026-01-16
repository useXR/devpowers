---
name: task-breakdown
description: >
  This skill should be used when the user asks to "break down the plan",
  "create task files", "split into implementable tasks", "generate task documents",
  or after reviewing-plans completes successfully. Converts high-level architecture
  into discrete task files ready for domain review.
---

# Task Breakdown

## Overview

Break a reviewed high-level plan into implementable task documents.

Distinct from `chunking-plans` which handles **recursive subdivision** of tasks that turn out to be too complex during domain review.

| Skill | Purpose | Input | Output |
|-------|---------|-------|--------|
| `task-breakdown` | Initial breakdown | high-level-plan.md | tasks/*.md |
| `chunking-plans` | Recursive subdivision | Existing task too complex | task/subtasks/*.md |

## Output Structure

Creates:
```
/docs/plans/[feature]/tasks/
├── 00-overview.md      # Dependency map and task index
├── 01-setup.md         # First task
├── 02-models.md        # Second task
└── ...
```

Each task sized for ~30 min to 2 hours of implementation work.

## Workflow

1. Read approved high-level plan from `/docs/plans/[feature]/high-level-plan.md`
2. Identify logical task boundaries (by component, by layer, by feature slice)
3. Create task files using `assets/task-template.md`
4. Generate `00-overview.md` with task map showing execution order
5. Validate: each task is self-contained enough to implement independently
6. Update STATUS.md
   - Stage: task-breakdown
   - Last Action: Tasks created
   - Next Action: Domain review

## Task Sizing Guidelines

Read `references/task-sizing-guide.md` for detailed guidance.

Quick rules:
- **Too small:** < 30 min, merge with adjacent task
- **Right size:** 30 min - 2 hours
- **Too large:** > 2 hours, consider splitting

## State Update

After creating tasks, update STATUS.md:
- Stage: task-breakdown
- Last Action: [N] tasks created
- Next Action: Domain review

## Handoff

"Task breakdown complete. Created [N] tasks in `/docs/plans/[feature]/tasks/`.

Ready for domain review?"

-> Invokes `domain-review`
