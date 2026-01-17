# [Feature Name] Tasks

> **For Claude:** REQUIRED SUB-SKILL: Use devpowers:subagent-driven-development to implement tasks.

## Task Map

```
[01-setup] ─────────────────┐
                            v
[02-models] ────> [03-api] ──> [04-ui]
                    │
                    v
                 [05-tests]
```

## Task Index

| # | Task | Description | Depends On | Status |
|---|------|-------------|------------|--------|
| 01 | Setup | Project configuration | None | Pending |
| 02 | Models | Data models | 01 | Pending |
| 03 | API | Backend endpoints | 02 | Pending |
| 04 | UI | Frontend components | 03 | Pending |
| 05 | Tests | Integration tests | 03 | Pending |

## Execution Order

1. **Sequential:** 01 -> 02 -> 03
2. **Parallel:** 04 and 05 can run after 03

## Quick Start

1. Read each task file in order
2. Complete implementation steps
3. Verify acceptance criteria
4. Run tests
5. Commit changes
