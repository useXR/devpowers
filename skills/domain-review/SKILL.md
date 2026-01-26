---
name: domain-review
description: >
  This skill should be used when the user asks to "review tasks for implementation",
  "validate task documents", "run domain expert review", "check if tasks are ready",
  or after task-breakdown produces task files in `/docs/plans/[feature]/tasks/`.
  Reviews implementation details with specialized domain critics.
---

# Domain Review

## Scope Clarification

| Skill | Reviews | When |
|-------|---------|------|
| `reviewing-plans` | High-level architecture (high-level-plan.md) | After writing-plans |
| `domain-review` | Implementation tasks (tasks/*.md) | After task-breakdown |
| `cross-domain-review` | Integration between domains | After domain-review |

## Review Loop: Convergence-Based

```
CONVERGED when:
- 2 consecutive rounds find 0 new CRITICAL issues AND
- 2 consecutive rounds find 0 new IMPORTANT issues AND
- All hard gates are satisfied
- (MINOR issues do not block convergence)

ESCALATE when:
- 5+ rounds without convergence -> ask user to intervene
- Issue count is stable but not decreasing -> likely fundamental problem
```

**What counts as "new"?** An issue is new if it identifies a problem not previously flagged. Rephrased versions of existing issues don't count as new.

## Hard Gates (BLOCKING)

**Convergence is blocked until ALL applicable gates pass:**

| Gate | Requirement | How to Check |
|------|-------------|--------------|
| **Test Plan Populated** | Unit Test Plan has >=3 specific test cases | Count items in "Unit Test Plan" section |
| **Security Checklist Complete** | All security checklist items marked | Verify no unchecked items in Security Checklist |
| **Behavior Definitions Present** | Tasks with user-facing changes have behavior table | Check "Behavior Definitions" section populated |
| **Spike Verified** | Tasks with new dependencies have spike result | Check "Spike Verification" section |

**If a gate fails:**
```
GATE FAILED: [Gate name]
Reason: [What's missing]
Action required: [What critic/user must do]

Cannot converge until this gate passes.
```

## Domain Detection

Detect relevant domains from task content. Security and Testing always run.

> **See:** `references/domain-detection.md` for detection rules and algorithm

## Critic Responsibilities

| Critic | Primary Job | Hard Gate Owned |
|--------|-------------|-----------------|
| **Frontend** | UI patterns, a11y, performance | Frontend Checklist |
| **Backend** | API design, data flow, error handling | Backend Checklist |
| **Security** | Input/output security, auth boundaries | Security Checklist |
| **Testing** | Test coverage, test quality | Test Plan Populated |
| **Infrastructure** | Deployment, monitoring | Integration Checklist |

Each critic verifies their owned checklist is complete (not empty, not placeholder).

## Workflow

1. Read task document(s) and relevant master docs
2. Detect domains, confirm: "Detected domains: [list]. Run all, or adjust?"
3. Dispatch selected critics in parallel
4. Aggregate findings by severity (CRITICAL -> IMPORTANT -> MINOR -> NITPICK)
5. **Check hard gates** - all must pass before convergence
6. If gate fails -> request fix, do not converge
7. If task too complex -> invoke `chunking-plans` -> re-review
8. Loop until converged AND gates pass (escalate at 5+ rounds)
9. Update STATUS.md

> **See:** `references/gate-checking.md` for gate verification algorithm
> **See:** `references/test-plan-examples.md` for test plan enforcement
> **See:** `references/security-examples.md` for security checklist enforcement
> **See:** `references/severity-guide.md` for issue severity classification
> **See:** `references/gap-finding-protocol.md` for gap analysis

## State Update

After review converges AND gates pass, update STATUS.md:
- Stage: domain-review (complete)
- Last Action: Domain review converged, all gates passed
- Next Action: Cross-domain review

## Handoff

"Domain review complete. [Summary of findings].
All hard gates passed: Test Plan, Security, Behavior, Spike.

Ready for cross-domain review?"

-> Invokes `cross-domain-review`
