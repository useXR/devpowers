# Devpowers Workflow Implementation

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development to implement this plan task-by-task.

**Goal:** Transform devpowers from a superpowers fork into a comprehensive development workflow system with master documents, multi-stage reviews, and automated state tracking.

**Source Document:** `docs/plans/2026-01-16-devpowers-complete-plan.md` contains full specifications for all items referenced in these task files.

---

## Task Map

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                    DEVPOWERS WORKFLOW IMPLEMENTATION                             │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  ┌──────────────┐                                                                │
│  │ 1. Cleanup   │                                                                │
│  │ (remove/move)│                                                                │
│  └──────┬───────┘                                                                │
│         │                                                                        │
│         ▼                                                                        │
│  ┌──────────────┐                                                                │
│  │ 2. State     │                                                                │
│  │Infrastructure│                                                                │
│  └──────┬───────┘                                                                │
│         │                                                                        │
│         ├─────────────────────┐                                                  │
│         ▼                     ▼                                                  │
│  ┌──────────────┐      ┌──────────────┐                                          │
│  │ 3. Entry     │      │ 4. Project   │                                          │
│  │   Point      │      │    Setup     │                                          │
│  │ (using-dev)  │      │    Skill     │                                          │
│  └──────┬───────┘      └──────┬───────┘                                          │
│         │                     │                                                  │
│         └──────────┬──────────┘                                                  │
│                    ▼                                                             │
│             ┌──────────────┐                                                     │
│             │ 5. Core      │                                                     │
│             │   Workflow   │                                                     │
│             │   Skills     │                                                     │
│             └──────┬───────┘                                                     │
│                    │                                                             │
│                    ▼                                                             │
│             ┌──────────────┐                                                     │
│             │ 6. Domain    │                                                     │
│             │   Review     │                                                     │
│             │   System     │                                                     │
│             └──────┬───────┘                                                     │
│                    │                                                             │
│         ┌─────────┼─────────┐                                                    │
│         ▼         ▼         ▼                                                    │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐                                          │
│  │7. Cross- │ │8. User   │ │10. Impl  │                                          │
│  │  Domain  │ │ Journey  │ │  Skills  │                                          │
│  │  Review  │ │ Mapping  │ │ Updates  │                                          │
│  └────┬─────┘ └────┬─────┘ └────┬─────┘                                          │
│       │            │            │                                                │
│       └────────────┼────────────┘                                                │
│                    ▼                                                             │
│             ┌──────────────┐                                                     │
│             │ 9. Lessons   │                                                     │
│             │   Learned    │                                                     │
│             └──────┬───────┘                                                     │
│                    │                                                             │
│                    ▼                                                             │
│             ┌──────────────┐                                                     │
│             │ 11. Hook     │                                                     │
│             │  Automation  │                                                     │
│             └──────┬───────┘                                                     │
│                    │                                                             │
│                    ▼                                                             │
│             ┌──────────────┐                                                     │
│             │ 12. Fork     │                                                     │
│             │   Skills     │                                                     │
│             │ (optional)   │                                                     │
│             └──────────────┘                                                     │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## Task Files

| File | Task | Description | Prerequisites |
|------|------|-------------|---------------|
| [01-cleanup.md](./01-cleanup.md) | 1 | Remove superseded skills, move reviewing-plans, fix references | Pre-flight |
| [02-state-infrastructure.md](./02-state-infrastructure.md) | 2 | Create STATUS.md, ACTIVE.md, learnings templates | 1 |
| [03-entry-point.md](./03-entry-point.md) | 3 | Create using-devpowers entry-point skill | 2 |
| [04-project-setup.md](./04-project-setup.md) | 4 | Create project-setup skill with master doc templates | 2 |
| [05-core-workflow-skills.md](./05-core-workflow-skills.md) | 5 | Update brainstorming, writing-plans, reviewing-plans, task-breakdown, chunking-plans | 3, 4 |
| [06-domain-review.md](./06-domain-review.md) | 6 | Create domain-review skill and reviewer agents | 5 |
| [07-cross-domain-review.md](./07-cross-domain-review.md) | 7 | Create cross-domain-review skill with routing protocol | 6 |
| [08-user-journey-mapping.md](./08-user-journey-mapping.md) | 8 | Create user-journey-mapping skill | 6 |
| [09-lessons-learned.md](./09-lessons-learned.md) | 9 | Create lessons-learned skill with merge algorithm | 7, 8 |
| [10-implementation-skills.md](./10-implementation-skills.md) | 10 | Update subagent-driven-development and TDD skills | 6 |
| [11-hook-automation.md](./11-hook-automation.md) | 11 | Create all 6 workflow hooks | 2-9 |
| [12-fork-skills.md](./12-fork-skills.md) | 12 | Fork frontend-design and playwright-testing skills | 6 (optional) |
| [99-verification.md](./99-verification.md) | - | Complete verification checklist | All tasks |

---

## Key Dependencies

- **Claude Code** - Plugin system with skills, hooks, and agents
- **Git** - Version control for commits
- **Bash/Python** - Hook implementations

---

## Pre-Flight Checklist

Before starting any task, verify:

```bash
# Verify in devpowers directory
pwd  # Should be in devpowers root

# Verify git repo
git status

# Verify skills directory exists
ls skills/

# Verify hooks directory exists
ls hooks/
```

---

## Execution Strategy

### Sequential vs Parallel Tasks

- **Tasks 1 → 2** must be sequential (state infrastructure depends on cleanup)
- **Tasks 3 and 4** can be done in parallel after task 2
- **Task 5** requires both 3 and 4
- **Task 6** requires task 5
- **Tasks 7, 8, and 10** can be done in parallel after task 6
- **Task 9** requires tasks 7 and 8
- **Task 11** requires tasks 2-9 (hooks reference all workflow stages)
- **Task 12** can be deferred or done in parallel with 11

### Recommended Order (Single Developer)

Follow numerical order: 1 → 2 → 3 → 4 → 5 → 6 → 7 → 8 → 9 → 10 → 11 → 12

### Parallel Execution (Multiple Agents)

1. Complete 1 → 2 first
2. Then parallel: 3 | 4
3. Then 5 → 6
4. Then parallel: 7 | 8 | 10
5. Then 9 → 11 → 12

---

## Cross-Cutting Concerns

These rules apply across all tasks. Reference the complete plan for full details.

### Review Loop Rules
- Maximum 3 rounds per review stage
- Convergence: No CRITICAL or IMPORTANT issues
- After 3 rounds: Present user with accept/escalate/abort options

### Issue Severity
- **CRITICAL** — Must fix before proceeding
- **IMPORTANT** — Should fix before proceeding
- **MINOR** — Can proceed, fix before merge
- **NITPICK** — Optional improvements

### Scope Tiers
- **Trivial** — Direct implementation, no planning
- **Small** — Brainstorm → Plan → Implement
- **Medium** — Full workflow, skip journey mapping if no UI
- **Large** — Full workflow

### State Machine Stages
brainstorming → high-level-plan → reviewing-plans → task-breakdown → domain-review → cross-domain-review → user-journey-mapping → worktree → implementing → lessons-learned → finishing
