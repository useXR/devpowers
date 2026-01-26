# Learnings Template

When you encounter iterations, mismatches, patterns, or workarounds during implementation, append to `/docs/plans/[feature]/learnings.md`:

```markdown
### [Date/Task] - Brief title
**Context:** What was being attempted
**Issue:** What went wrong or was tricky
**Resolution:** What finally worked
**Lesson:** What to remember for next time
```

## Examples

### 2024-01-15/Task 2 - API timeout on large payloads
**Context:** Implementing batch upload endpoint
**Issue:** Requests over 1MB were timing out silently
**Resolution:** Added chunking with progress callback
**Lesson:** Always test with production-scale data sizes

### 2024-01-16/Task 4 - Test isolation failure
**Context:** Writing integration tests for user service
**Issue:** Tests passed individually but failed when run together
**Resolution:** Database cleanup was missing between tests
**Lesson:** Check test isolation early, especially with shared resources
