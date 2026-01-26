# Recording Changes

After applying fixes, append to the **Revision History** section at the end of the plan:

```markdown
---

## Revision History

### v2 - YYYY-MM-DD - Plan Review Round 1

**Issues Addressed:**
- [CRITICAL] Task 3, Step 2: Fixed bcrypt API
- [IMPORTANT] Task 2: Added token expiry handling

**Reviewer Notes:** Plan had critical API compatibility issue.

### v3 - YYYY-MM-DD - Plan Review Round 2

**Issues Addressed:**
- [IMPORTANT] Added rate limiting consideration

**Reviewer Notes:** Convergence reached. Skeptic pass clean.
```

## Format Guidelines

- Use semantic versioning: v2, v3, etc.
- Include date in YYYY-MM-DD format
- Group issues by the round they were fixed
- Tag each issue with severity level
- Add brief reviewer notes for context
