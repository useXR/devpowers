# Tool Efficiency - Task Overview

> **Feature:** tool-efficiency | **Scope:** Medium | **Tasks:** 6

## Task Dependency Map

```
Task 1: Universal Git Agents ──┐
                               ├──► Task 5: Update project-setup ──► Task 6: Testing
Task 2: Agent Templates ───────┤
                               │
Task 3: Dora Assets ───────────┤
                               │
Task 4: Update detect-stack.sh ┘
```

## Task Index

| # | Task | Est. Time | Depends On | Status |
|---|------|-----------|------------|--------|
| 1 | [Universal Git Agents](./01-universal-git-agents.md) | 45 min | None | Pending |
| 2 | [Agent Templates](./02-agent-templates.md) | 1 hour | None | Pending |
| 3 | [Dora Assets](./03-dora-assets.md) | 45 min | None | Pending |
| 4 | [Update detect-stack.sh](./04-detect-stack.md) | 1 hour | None | Pending |
| 5 | [Update project-setup](./05-project-setup.md) | 1.5 hours | 1, 2, 3, 4 | Pending |
| 6 | [Testing & Verification](./06-testing.md) | 1 hour | 5 | Pending |

## Parallelization Notes

Tasks 1-4 can be implemented in parallel - they have no dependencies on each other.

Task 5 integrates all previous work and must wait for 1-4 to complete.

Task 6 tests the complete integration.

## Key Files Created/Modified

**New files:**
- `agents/git-status.md`
- `agents/git-sync.md`
- `agents/git-push.md`
- `skills/project-setup/assets/agent-templates/test.md`
- `skills/project-setup/assets/agent-templates/lint.md`
- `skills/project-setup/assets/agent-templates/typecheck.md`
- `skills/project-setup/assets/agent-templates/build.md`
- `skills/project-setup/assets/dora/SKILL.md`
- `skills/project-setup/assets/hooks/dora-hooks.json`

**Modified files:**
- `skills/project-setup/scripts/detect-stack.sh`
- `skills/project-setup/SKILL.md`
