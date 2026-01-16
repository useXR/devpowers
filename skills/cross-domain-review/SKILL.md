---
name: cross-domain-review
description: >
  This skill should be used when the user asks to "check integration",
  "review cross-domain concerns", "validate component boundaries",
  or after domain-review completes on all tasks. Reviews how different
  domains interact and identifies integration issues.
---

# Cross-Domain Review

## Scope Clarification

| Skill | Reviews | When |
|-------|---------|------|
| `reviewing-plans` | High-level architecture | After writing-plans |
| `domain-review` | Individual task implementation | After task-breakdown |
| `cross-domain-review` | Integration between domains | After domain-review |

## Review Loop

This skill uses review loops:
- Maximum 3 rounds
- Convergence: No CRITICAL or IMPORTANT issues
- After 3 rounds: Present user with accept/escalate/abort options

## What to Review

Cross-domain integration points:
- Frontend <-> Backend API contracts
- Backend <-> Database schema compatibility
- Service <-> Service communication
- UI <-> State management boundaries
- Error propagation across boundaries

## Routing Protocol

When issues span multiple domains, route findings with this format:

```json
{
  "issue": "API response shape doesn't match frontend TypeScript type",
  "severity": "IMPORTANT",
  "source_domain": "integration",
  "target_domains": ["frontend", "backend"],
  "suggested_resolution": {
    "frontend": "Update Response type to include 'metadata' field",
    "backend": "Document the metadata field in API spec"
  }
}
```

## Round-Trip Counting

If issue is routed to domain critic and comes back unresolved:
- First round-trip: normal
- Second round-trip: escalate severity
- Third round-trip: escalate to user decision

## Workflow

1. Read all task documents from `/docs/plans/[feature]/tasks/`
2. Identify integration boundaries between domains
3. Dispatch integration-reviewer agent
4. Review API contracts, data formats, error handling
5. Route domain-specific findings to respective domain critics
6. Aggregate all cross-domain issues
7. Loop until converged (max 3 rounds)
8. Update STATUS.md

## State Update

After review converges, update STATUS.md:
- Stage: cross-domain-review (complete)
- Last Action: Cross-domain review passed
- Next Action: User journey mapping (if UI) or implementing

## Handoff

"Cross-domain review complete. [Summary of integration findings].

Ready for user journey mapping?" (if feature has UI)
OR
"Ready to start implementation?" (if no UI)

-> Invokes `user-journey-mapping` or `subagent-driven-development`
