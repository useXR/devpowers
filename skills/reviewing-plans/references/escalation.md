# Escalation Guidance

If 5 rounds without convergence, present this to the user:

> "This plan has gone through 5 review rounds without converging. This usually means:
> 1. The plan has fundamental issues that fixes aren't addressing
> 2. The scope is too large and should be split
> 3. Requirements are unclear and need user clarification
>
> Options:
> - Continue reviewing (not recommended)
> - Split into smaller features
> - Clarify requirements with user
> - Accept current state and proceed (risks remain)"

## Root Cause Patterns

**Fundamental Issues:** Critics keep finding new problems because the core approach is flawed. Consider redesigning rather than patching.

**Scope Creep:** Large plans have too many interaction points. Break into smaller, independent features.

**Unclear Requirements:** Ambiguous goals lead to contradictory fixes. Get explicit requirements before continuing.

## When to Override

User may choose to accept risks and proceed. Document:
- Which issues remain unresolved
- Why user chose to proceed
- Recommended mitigations during implementation
