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
3. Create task files using `assets/task-template-v3.md`
4. Generate `00-overview.md` with task map showing execution order
5. Validate: each task is self-contained enough to implement independently
6. **Scope Re-evaluation Checkpoint** (see below)
7. Update STATUS.md
   - Stage: task-breakdown
   - Last Action: Tasks created
   - Next Action: Domain review

## Scope Re-evaluation Checkpoint

**After creating tasks, re-evaluate scope.** Task breakdown reveals the true complexity.

### Check for Scope Escalation Triggers

| Finding | Action |
|---------|--------|
| More than 5 tasks created | Consider: is this still the scope we estimated? |
| Any task requires new dependency not in plan | Escalate to Medium if was Small |
| Any task touches auth/security not anticipated | Escalate to Medium if was Small |
| Tasks span multiple services/repos | Escalate to Large |
| Architectural decisions needed that weren't in plan | Escalate to Large |

### Scope Re-evaluation Prompt

If triggers detected:

> "Task breakdown complete. Created [N] tasks.
>
> **Scope re-evaluation:** [Describe what was found]
> - Original scope: [Small/Medium/Large]
> - Suggested scope: [Small/Medium/Large]
> - Reason: [Why scope should change]
>
> Adjust scope and workflow, or continue with original scope?"

### What Changes with Scope Escalation

| From → To | What's Added |
|-----------|--------------|
| Small → Medium | Plan review, domain review with hard gates, integration checklist |
| Medium → Large | User journey mapping, cross-domain review, mandatory lessons-learned |

**If user declines escalation:** Document the decision in STATUS.md and proceed, but note the risk.

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
- Scope: [Original or escalated scope]
- Next Action: Domain review

## Handoff

"Task breakdown complete. Created [N] tasks in `/docs/plans/[feature]/tasks/`.
[Scope re-evaluation note if applicable]

Ready for domain review?"

-> Invokes `domain-review`
