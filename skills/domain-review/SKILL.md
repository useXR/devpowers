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

## Review Loop

This skill uses review loops:
- Maximum 3 rounds per review stage
- Convergence: No CRITICAL or IMPORTANT issues
- After 3 rounds: Present user with accept/escalate/abort options

## Domain Detection

Not all critics run for every task. Detect relevant domains from task content.

### Detection Rules (any 2+ signals triggers domain)

| Domain | File Path Signals | Keyword Signals | Import Signals |
|--------|------------------|-----------------|----------------|
| **Frontend** | `src/components/`, `src/ui/`, `*.css`, `*.tsx` | "component", "render", "useState", "UI" | react, vue, svelte, tailwind |
| **Backend** | `src/api/`, `src/server/`, `routes/`, `controllers/` | "endpoint", "database", "query", "API" | express, fastify, prisma |
| **Testing** | (always runs) | - | - |
| **Infrastructure** | `Dockerfile`, `*.yaml`, `terraform/`, `.github/` | "deployment", "CI/CD", "kubernetes" | docker, terraform |

### Detection Algorithm

```
1. Parse task "Files to Create/Modify" section
2. Match file paths against domain patterns
3. Scan task content for keyword signals
4. Score each domain by signal count
5. Trigger domain if score >= 2
6. Always include Testing (maintains test plan)
```

## Each Domain Critic Checks

- Feasibility — Will this approach work?
- Completeness — All cases covered?
- Simplicity — Over-engineered?
- Patterns — Follows master docs?

## Workflow

1. Read task document(s) and relevant master docs
2. Detect relevant domains, confirm with user: "Detected domains: [list]. Run all, or adjust?"
3. Dispatch selected critics in parallel
4. Aggregate findings by severity (CRITICAL -> IMPORTANT -> MINOR -> NITPICK)
5. If chunking needed (task too complex) -> invoke `chunking-plans` -> re-review new tasks
6. Loop until converged (max 3 rounds per task)
7. Update STATUS.md

## Test Plan Maintenance

- Testing critic reviews task and proposes unit tests
- Test plan updated in task doc after each domain review round
- Other critics can flag "needs test for X" which testing critic incorporates

## State Update

After review converges, update STATUS.md:
- Stage: domain-review (complete)
- Last Action: Domain review converged
- Next Action: Cross-domain review

## Handoff

"Domain review complete. [Summary of findings across domains].

Ready for cross-domain review?"

-> Invokes `cross-domain-review`
