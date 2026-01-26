# Scope Precedence Rules

**When indicators conflict, use these rules:**

| Conflict | Resolution | Rationale |
|----------|------------|-----------|
| File count says Small, but adds new dependency | **Medium** | New dependencies need spike verification |
| Line count says Small, but touches auth/security | **Medium** | Security-sensitive code needs full review |
| Seems Small, but multiple components affected | **Medium** | Cross-component changes need integration review |
| Seems Medium, but architectural decision required | **Large** | Architectural decisions need full workflow |
| Any uncertainty about scope | **Go higher** | Over-process is better than under-process |

## Automatic Escalation Triggers

These triggers apply regardless of initial assessment:
- Adds new external dependency → at least Medium
- Modifies authentication/authorization → at least Medium
- Changes database schema → at least Medium
- Affects multiple services/repos → Large
- Introduces new API contract → at least Medium

## When Still Uncertain

Ask user. Present the options:

> "This could be Small or Medium scope. Indicators: [list what points each way]. Small means lighter process (no formal plan review). Medium means full review cycle. Which fits better?"
