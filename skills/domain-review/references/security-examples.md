# Security Checklist Enforcement

Security critic MUST:
1. Verify EACH checklist item (not just read and approve)
2. Mark items as: checked, needs fix, or N/A (with reason)
3. Any unchecked item -> gate fails

## Example of VALID security checklist

```markdown
### Security Checklist
- [x] Input validation: Validated via zod schema at API boundary
- [x] Output encoding: Using React's JSX escaping, no dangerouslySetInnerHTML
- [x] Auth boundaries: Requires authenticated session, checked in middleware
- [ ] Data exposure: N/A - no sensitive data in this task
- [x] Injection prevention: N/A - no database queries in this task
```

## Example of INVALID checklist (will fail gate)

```markdown
### Security Checklist
- [ ] Input validation: All external input validated at entry points
- [ ] Output encoding: Content rendered to DOM is sanitized
```

Note: Items must be explicitly marked (checked, N/A with reason), not left unchecked with generic descriptions.
