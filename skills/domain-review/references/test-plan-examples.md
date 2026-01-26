# Test Plan Enforcement

Testing critic MUST:
1. Propose specific test cases (not placeholders)
2. Include happy path, error case, and edge case
3. Update task document's "Unit Test Plan" section
4. If test plan is empty after review -> CRITICAL issue

## Example of VALID test plan

```markdown
## Unit Test Plan
- [ ] `formatMarkdown()` - returns formatted HTML for valid markdown
- [ ] `formatMarkdown()` - returns empty string for null input
- [ ] `formatMarkdown()` - escapes HTML entities to prevent XSS
```

## Example of INVALID test plan (will fail gate)

```markdown
## Unit Test Plan
<!-- Populated by testing critic during domain review -->
```
