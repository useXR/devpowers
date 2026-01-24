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

This skill uses the same convergence logic as reviewing-plans:

```
CONVERGED when:
- 2 consecutive rounds find 0 new CRITICAL issues AND
- 2 consecutive rounds find 0 new IMPORTANT issues AND
- All hard gates are satisfied
- (MINOR issues do not block convergence)

ESCALATE when:
- 5+ rounds without convergence → ask user to intervene
- Issue count is stable but not decreasing → likely fundamental problem
```

**What counts as "new"?** An issue is new if it identifies a problem not previously flagged. Rephrased versions of existing issues don't count as new.

## Hard Gates (BLOCKING)

**Convergence is blocked until ALL applicable gates pass:**

| Gate | Requirement | How to Check |
|------|-------------|--------------|
| **Test Plan Populated** | Unit Test Plan has ≥3 specific test cases | Count items in "Unit Test Plan" section |
| **Security Checklist Complete** | All security checklist items marked (checked, N/A with reason) | Verify no unchecked items in Security Checklist |
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

Not all critics run for every task. Detect relevant domains from task content.

### Detection Rules (any 2+ signals triggers domain)

| Domain | File Path Signals | Keyword Signals | Import Signals |
|--------|------------------|-----------------|----------------|
| **Frontend** | `src/components/`, `src/ui/`, `*.css`, `*.tsx` | "component", "render", "useState", "UI" | react, vue, svelte, tailwind |
| **Backend** | `src/api/`, `src/server/`, `routes/`, `controllers/` | "endpoint", "database", "query", "API" | express, fastify, prisma |
| **Security** | (always runs) | - | - |
| **Testing** | (always runs) | - | - |
| **Infrastructure** | `Dockerfile`, `*.yaml`, `terraform/`, `.github/` | "deployment", "CI/CD", "kubernetes" | docker, terraform |

### Detection Algorithm

```
1. Parse task "Files to Create/Modify" section
2. Match file paths against domain patterns
3. Scan task content for keyword signals
4. Score each domain by signal count
5. Trigger domain if score >= 2
6. Always include Security (checks all input/output handling)
7. Always include Testing (maintains test plan)
```

## Critic Responsibilities

| Critic | Primary Job | Hard Gate Owned |
|--------|-------------|-----------------|
| **Frontend** | UI patterns, a11y, performance | Frontend Checklist |
| **Backend** | API design, data flow, error handling | Backend Checklist |
| **Security** | Input/output security, auth boundaries | Security Checklist |
| **Testing** | Test coverage, test quality | Test Plan Populated |
| **Infrastructure** | Deployment, monitoring | Integration Checklist |

Each critic MUST:
1. Review task for domain-specific issues
2. **Verify their owned checklist is complete** (not empty, not placeholder)
3. Report any checklist items that need updating

## Workflow

1. Read task document(s) and relevant master docs
2. Detect relevant domains, confirm with user: "Detected domains: [list]. Run all, or adjust?"
3. Dispatch selected critics in parallel
4. Aggregate findings by severity (CRITICAL → IMPORTANT → MINOR → NITPICK)
5. **Check hard gates** - all must pass before convergence
6. If any gate fails → request fix, do not converge
7. If chunking needed (task too complex) → invoke `chunking-plans` → re-review new tasks
8. Loop until converged AND gates pass (escalate at 5+ rounds)
9. Update STATUS.md

## Gate Checking Algorithm

After each round, verify:

```python
def check_gates(task):
    gates = []

    # Gate 1: Test Plan Populated
    test_items = count_checkbox_items(task, "Unit Test Plan")
    if test_items < 3:
        gates.append(("Test Plan Populated", "FAILED",
                      f"Only {test_items} test cases, need ≥3"))

    # Gate 2: Security Checklist Complete
    security_unchecked = count_unchecked(task, "Security Checklist")
    if security_unchecked > 0:
        gates.append(("Security Checklist Complete", "FAILED",
                      f"{security_unchecked} items unchecked"))

    # Gate 3: Behavior Definitions (if user-facing)
    if has_user_facing_changes(task):
        behavior_rows = count_table_rows(task, "Behavior Definitions")
        if behavior_rows < 1:
            gates.append(("Behavior Definitions Present", "FAILED",
                          "User-facing task needs behavior definitions"))

    # Gate 4: Spike Verified (if new dependencies)
    if has_new_dependencies(task):
        spike_status = get_spike_status(task)
        if spike_status == "empty":
            gates.append(("Spike Verified", "FAILED",
                          "New dependencies need spike verification"))

    return gates
```

## Test Plan Enforcement

Testing critic MUST:
1. Propose specific test cases (not placeholders)
2. Include happy path, error case, and edge case
3. Update task document's "Unit Test Plan" section
4. If test plan is empty after review → CRITICAL issue

**Example of VALID test plan:**
```markdown
## Unit Test Plan
- [ ] `formatMarkdown()` - returns formatted HTML for valid markdown
- [ ] `formatMarkdown()` - returns empty string for null input
- [ ] `formatMarkdown()` - escapes HTML entities to prevent XSS
```

**Example of INVALID test plan (will fail gate):**
```markdown
## Unit Test Plan
<!-- Populated by testing critic during domain review -->
```

## Security Checklist Enforcement

Security critic MUST:
1. Verify EACH checklist item (not just read and approve)
2. Mark items as: ✅ checked, ❌ needs fix, or N/A (with reason)
3. Any unchecked item → gate fails

**Example of VALID security checklist:**
```markdown
### Security Checklist
- [x] Input validation: Validated via zod schema at API boundary
- [x] Output encoding: Using React's JSX escaping, no dangerouslySetInnerHTML
- [x] Auth boundaries: Requires authenticated session, checked in middleware
- [ ] Data exposure: N/A - no sensitive data in this task
- [x] Injection prevention: N/A - no database queries in this task
```

**Example of INVALID checklist (will fail gate):**
```markdown
### Security Checklist
- [ ] Input validation: All external input validated at entry points
- [ ] Output encoding: Content rendered to DOM is sanitized
```

## State Update

After review converges AND gates pass, update STATUS.md:
- Stage: domain-review (complete)
- Last Action: Domain review converged, all gates passed
- Next Action: Cross-domain review

## Handoff

"Domain review complete. [Summary of findings across domains].
All hard gates passed: Test Plan ✅, Security ✅, Behavior ✅, Spike ✅

Ready for cross-domain review?"

→ Invokes `cross-domain-review`
