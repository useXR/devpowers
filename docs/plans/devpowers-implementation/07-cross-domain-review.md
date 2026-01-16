# Task 7: Cross-Domain Review

> **Devpowers Implementation** | [← Domain Review](./06-domain-review.md) | [Next: User Journey Mapping →](./08-user-journey-mapping.md)

---

## Context

**This task creates the cross-domain-review skill with routing protocol.** Validates integration points between domains after individual domain reviews pass.

### Prerequisites
- **Task 6** completed (domain-review system exists)

### What This Task Creates
- `skills/cross-domain-review/SKILL.md`
- `skills/cross-domain-review/integration-critic.md`
- `skills/cross-domain-review/references/common-integration-issues.md`

### Tasks That Depend on This
- **Task 9** (Lessons Learned) - runs after all reviews complete

### Parallel Tasks
This task can be done in parallel with:
- **Task 8** (User Journey Mapping)
- **Task 10** (Implementation Skills Updates)

---

## Files to Create

```
skills/cross-domain-review/
├── SKILL.md
├── integration-critic.md
└── references/
    └── common-integration-issues.md
```

---

## Steps

### Step 1: Create directory structure

```bash
mkdir -p skills/cross-domain-review/references
```

### Step 2: Create SKILL.md

**File:** `skills/cross-domain-review/SKILL.md`

```markdown
---
name: cross-domain-review
description: >
  This skill should be used when the user asks to "check integration points",
  "validate API contracts", "review frontend-backend alignment", "verify cross-domain dependencies",
  or after domain-review completes for all tasks. Ensures domains work together correctly.
---

# Cross-Domain Review

## Scope

This is the final review before implementation. It sees the complete picture:
- All task files from all domains
- The dependency map (00-overview.md)
- Interfaces between components

## Review Loop

This skill uses review loops:
- Maximum 3 rounds
- Max 2 round-trips per issue when routing to domain critics
- Convergence: No unresolved cross-domain issues

## What It Checks

- **API contracts** — Does frontend expect what backend provides?
- **Data flow** — Correct transformations between layers?
- **Error propagation** — Errors flow correctly across boundaries?
- **Timing/sequencing** — Async operations coordinated?
- **Dependencies** — Cross-domain deps explicit and ordered?
- **External dependencies** — Third-party APIs, services, infrastructure

## Bidirectional Flow

If cross-domain review finds issues requiring domain-specific changes:
1. Identify which domain(s) need updates
2. Route back to relevant domain critic(s) for targeted fix
3. Domain critic proposes fix within their scope
4. Re-run cross-domain review to verify fix
5. Max 2 round-trips before escalating to user

## Routing Protocol

Cross-domain critic outputs issues with routing information:

```json
{
  "issues": [
    {
      "id": "API_001",
      "severity": "CRITICAL",
      "description": "Frontend expects user.fullName but backend returns firstName + lastName",
      "affected_tasks": ["03-api-endpoints", "06-user-profile-ui"]
    }
  ],
  "routing": [
    {
      "domain": "backend",
      "issue_id": "API_001",
      "task": "03-api-endpoints",
      "context": "API response shape doesn't match frontend expectations",
      "requested_fix": "Add computed fullName field to user response"
    }
  ]
}
```

Domain critic receives routing request and returns fix:

```json
{
  "issue_id": "API_001",
  "fix_applied": true,
  "task_updates": {
    "section": "Implementation Steps",
    "change": "Added step: Add fullName computed property to user serializer"
  },
  "verification_note": "Frontend can now use user.fullName directly"
}
```

## Round-Trip Counting

- One round-trip = cross-domain → domain → cross-domain (verify)
- Cross-domain's 3 rounds are separate from round-trips
- After 2 failed round-trips (domain fix doesn't resolve): Escalate to user

## Workflow

1. Read all task documents + 00-overview.md (dependency map)
2. Dispatch integration critic that sees everything
3. Findings focus on interfaces between domains
4. If domain-specific fix needed → route using protocol above → re-verify
5. Loop if CRITICAL/IMPORTANT issues found (max 3 rounds, max 2 round-trips per issue)
6. Update STATUS.md

## Handoff

"Cross-domain review complete. [Summary].

Ready to map user journeys? (or skip if no UI)"

→ Invokes `user-journey-mapping` or skip to `using-git-worktrees`
```

### Step 3: Create integration-critic.md

**File:** `skills/cross-domain-review/integration-critic.md`

```markdown
# Integration Critic

You are reviewing all task documents to find cross-domain integration issues.

## Your Focus

1. **API Contracts** — Does frontend expect what backend provides? Field names consistent? Data types compatible?
2. **Data Flow** — Transformations correct between layers? Validation at right boundaries?
3. **Error Propagation** — Errors flow correctly across boundaries? Codes/messages consistent?
4. **Timing/Sequencing** — Async operations coordinated? Race conditions possible?
5. **Dependencies** — Cross-domain deps explicit? Ordering correct in 00-overview.md?

## Output Format

```json
{
  "issues": [
    {
      "id": "UNIQUE_ID",
      "severity": "CRITICAL|IMPORTANT|MINOR|NITPICK",
      "description": "Clear description of the issue",
      "affected_tasks": ["task-file-1", "task-file-2"]
    }
  ],
  "routing": [
    {
      "domain": "frontend|backend|testing|infrastructure",
      "issue_id": "UNIQUE_ID",
      "task": "affected-task-file",
      "context": "Why this domain needs to address it",
      "requested_fix": "What change is needed"
    }
  ],
  "summary": "Overall integration assessment"
}
```
```

### Step 4: Create common-integration-issues.md

**File:** `skills/cross-domain-review/references/common-integration-issues.md`

```markdown
# Common Integration Issues

## API Contract Mismatches
- Field naming inconsistencies (camelCase vs snake_case)
- Missing fields in response
- Different data types (string vs number)
- Pagination format differences

## Data Flow Issues
- Missing data transformations
- Validation at wrong boundary
- Duplicate validation (wasteful)
- No validation (dangerous)

## Error Handling Issues
- Generic error messages losing context
- Error codes not matching frontend expectations
- Missing error states in UI

## Timing Issues
- Race conditions on parallel requests
- Stale data after mutations
- Missing loading states
- Optimistic updates without rollback

## Dependency Issues
- Circular dependencies
- Missing dependency in task order
- External service not in dependency list
```

### Step 5: Commit

```bash
git add skills/cross-domain-review/
git commit -m "feat: add cross-domain-review skill with routing protocol"
```

---

## Verification Checklist

- [ ] `skills/cross-domain-review/SKILL.md` exists
- [ ] `skills/cross-domain-review/integration-critic.md` exists
- [ ] `skills/cross-domain-review/references/common-integration-issues.md` exists
- [ ] Routing protocol documented with JSON schemas
- [ ] Round-trip counting rules documented
- [ ] Changes committed

---

## Next Steps

Proceed to **[Task 8: User Journey Mapping](./08-user-journey-mapping.md)** (can be done in parallel).

Or if Task 8 is complete, proceed to **[Task 9: Lessons Learned](./09-lessons-learned.md)**.
