# Token Efficiency Refactor Tasks

> **For Claude:** REQUIRED SUB-SKILL: Use devpowers:subagent-driven-development to implement tasks.

## Task Map

```
[01-using-devpowers] ──────────────────────────────────────────────┐
         │                                                          │
         v                                                          v
[02-tdd] ──> [03-debugging] ──> [04-subagent] ──> [05-reviewing] ──> [06-domain] ──> [07-validation]
```

All P2 tasks (02-06) can technically run in parallel after 01, but are shown sequentially for simplicity.

## Task Index

| # | Task | Description | Depends On | Target Words | Status |
|---|------|-------------|------------|--------------|--------|
| 01 | using-devpowers | Compress always-loaded skill (P1) | None | 600 | Pending |
| 02 | test-driven-development | Compress discipline skill | 01 | 900 | Pending |
| 03 | systematic-debugging | Compress discipline skill | 01 | 800 | Pending |
| 04 | subagent-driven-development | Compress workflow skill | 01 | 600 | Pending |
| 05 | reviewing-plans | Compress review skill | 01 | 600 | Pending |
| 06 | domain-review | Compress review skill | 01 | 600 | Pending |
| 07 | validation | Integration test and measurement | 01-06 | N/A | Pending |

## Execution Order

1. **Must do first:** Task 01 (using-devpowers) - validates approach works
2. **Parallel batch:** Tasks 02-06 can run in any order after 01
3. **Final:** Task 07 (validation) after all compressions complete

## Measurement Baseline

| Skill | Before (words) | Target (words) | Expected Savings |
|-------|---------------|----------------|------------------|
| using-devpowers | 1,686 | 600 | 1,086 (64%) |
| test-driven-development | 1,612 | 900 | 712 (44%) |
| systematic-debugging | 1,504 | 800 | 704 (47%) |
| subagent-driven-development | 1,499 | 600 | 899 (60%) |
| reviewing-plans | 1,157 | 600 | 557 (48%) |
| domain-review | 1,093 | 600 | 493 (45%) |
| **Total** | **8,551** | **4,100** | **4,451 (52%)** |

## Content Categorization Quick Reference

**Keep inline:**
- Routing logic and flowcharts
- Handoff rules
- Discipline enforcers (red flags, rationalization tables) for TDD/debugging
- Convergence algorithms

**Move to references/:**
- Detailed tier definitions
- Verbose explanations
- Example tables
- Severity guides

## Reference Pointer Format

**Required:**
```markdown
**For detailed guidance:** Read `./references/[name].md` before proceeding.
```

**Optional:**
```markdown
**Reference:** `./references/[name].md` - [one-line description]
```
