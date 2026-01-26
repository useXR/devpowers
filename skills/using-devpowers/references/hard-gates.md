# Hard Gates by Scope

| Gate | Trivial | Small | Medium | Large |
|------|---------|-------|--------|-------|
| Architectural Assessment | Skip | Skip | Required | Required |
| Security Checklist | Skip | Mental | Required | Required |
| Test Plan (coverage categories) | Skip | Required | Required | Required |
| Spike Verification | Skip | If needed | Required for new deps | Required |
| Behavior Definitions | Skip | Skip | If user-facing | Required |
| Integration Checklist | Skip | Skip | Required | Required |
| Journey Categories | Skip | Skip | Skip | Required |
| Skeptic Pass | Skip | Skip | Required | Required |

## Integration Checklist (Medium+ scope)

Even without full cross-domain review, Medium scope tasks must verify:
- [ ] Works with existing autosave/persistence (if applicable)
- [ ] Works with existing undo/redo (if applicable)
- [ ] Works with existing error handling patterns
- [ ] No breaking changes to existing functionality
- [ ] New dependencies don't conflict with existing ones
