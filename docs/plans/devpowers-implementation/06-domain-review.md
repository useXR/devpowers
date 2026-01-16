# Task 6: Domain Review System

> **Devpowers Implementation** | [← Core Workflow Skills](./05-core-workflow-skills.md) | [Next: Cross-Domain Review →](./07-cross-domain-review.md)

---

## Context

**This task creates the domain-review skill and reviewer agents.** Multi-critic system reviews implementation tasks from domain expert perspectives.

### Prerequisites
- **Task 5** completed (task-breakdown skill exists)

### What This Task Creates
- `skills/domain-review/SKILL.md`
- `skills/domain-review/frontend-critic.md`
- `skills/domain-review/backend-critic.md`
- `skills/domain-review/testing-critic.md`
- `skills/domain-review/infrastructure-critic.md`
- `skills/domain-review/references/severity-guide.md`
- `agents/frontend-reviewer.md`
- `agents/backend-reviewer.md`
- `agents/testing-reviewer.md`
- `agents/infrastructure-reviewer.md`
- `agents/integration-reviewer.md`

### Tasks That Depend on This
- **Task 7** (Cross-Domain Review) - runs after domain review converges
- **Task 8** (User Journey Mapping) - runs after reviews
- **Task 10** (Implementation Skills) - uses test plans from testing critic

---

## Sub-Tasks

1. Create domain-review skill
2. Create domain critic prompts
3. Create reviewer agents

---

## Sub-Task 6.1: Create domain-review Skill

### Create directory structure:

```bash
mkdir -p skills/domain-review/references
```

### Create SKILL.md:

**File:** `skills/domain-review/SKILL.md`

```markdown
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
4. Aggregate findings by severity (CRITICAL → IMPORTANT → MINOR → NITPICK)
5. If chunking needed (task too complex) → invoke `chunking-plans` → re-review new tasks
6. Loop until converged (max 3 rounds per task)
7. Update STATUS.md

## Test Plan Maintenance

- Testing critic reviews task and proposes unit tests
- Test plan updated in task doc after each domain review round
- Other critics can flag "needs test for X" which testing critic incorporates

## Handoff

"Domain review complete. [Summary of findings across domains].

Ready for cross-domain review?"

→ Invokes `cross-domain-review`
```

---

## Sub-Task 6.2: Create Domain Critic Prompts

### Create frontend-critic.md:

```markdown
# Frontend Critic

You are a senior frontend engineer reviewing implementation task documents.

## Your Focus

1. **Component Structure** — Well-structured? Reusable? Follows project patterns?
2. **Design System Adherence** — Reference `/docs/master/design-system.md`
3. **Accessibility** — Keyboard nav, screen reader, focus management, ARIA
4. **Performance** — Unnecessary re-renders? Bundle size? Lazy loading?
5. **State Management** — State at right level? Prop drilling? Global state?

## Output Format

```markdown
## Frontend Review: [Task Name]

### CRITICAL Issues
[Must fix before proceeding]

### IMPORTANT Issues
[Should fix before proceeding]

### MINOR Issues
[Can proceed, fix before merge]

### NITPICK
[Optional improvements]

### Test Recommendations
[Tests the testing critic should include]

### Summary
[Overall frontend assessment]
```
```

### Create backend-critic.md:

```markdown
# Backend Critic

You are a senior backend engineer reviewing implementation task documents.

## Your Focus

1. **API Design** — RESTful conventions? Consistent naming? HTTP methods/status codes?
2. **Data Flow** — Clear transformations? Proper validation at boundaries?
3. **Error Handling** — All error cases covered? Appropriate messages? Proper propagation?
4. **Security** — Auth checks? Input validation? SQL injection prevention?
5. **Performance** — N+1 queries? Caching opportunities? Database indexing?

## Output Format

[Same structure as frontend critic]
```

### Create testing-critic.md:

```markdown
# Testing Critic

You are a senior QA engineer reviewing implementation task documents.

## Your Focus

1. **Unit Test Coverage** — All functions tested? Edge cases? Error paths?
2. **Test Quality** — Meaningful tests? Maintainable? Independent?
3. **Test Plan Completeness** — Happy paths, error states, boundary conditions?
4. **Testability** — Is the code testable? Dependencies injectable?

## Unit Test Plan Output

After review, propose unit tests to add to the task document:

```markdown
## Unit Test Plan
- [ ] [Function] - happy path with valid input
- [ ] [Function] - error case with invalid input
- [ ] [Function] - edge case with empty input
- [ ] [Function] - boundary case at max limit
```

## Output Format

[Same structure as other critics, plus Unit Test Plan section]
```

### Create infrastructure-critic.md:

```markdown
# Infrastructure Critic

You are a senior DevOps engineer reviewing implementation task documents.

## Your Focus

1. **Deployment** — How will this be deployed? Environment considerations?
2. **Scaling** — Will this scale? Bottlenecks? Resource requirements?
3. **Monitoring** — What should be monitored? Logging? Alerting?
4. **Security** — Secrets management? Network security? Access controls?
5. **Operations** — Runbooks needed? Rollback strategy? Migrations?

## Output Format

[Same structure as other critics]
```

### Create references/severity-guide.md:

Copy from reviewing-plans (same severity definitions).

**Commit:**
```bash
git add skills/domain-review/
git commit -m "feat: add domain-review skill with multi-critic system"
```

---

## Sub-Task 6.3: Create Reviewer Agents

### Create agents/frontend-reviewer.md:

```markdown
---
name: frontend-reviewer
description: |
  Use this agent when reviewing frontend implementation for UI/UX quality
  and design system adherence. Examples:
  <example>
  Context: User has completed a React component implementation.
  user: "I finished the dashboard component. Can you review the frontend code?"
  assistant: "I'll use the frontend-reviewer agent to check UI/UX quality and design system adherence."
  <commentary>
  Frontend implementation complete, needs domain-specific review.
  </commentary>
  </example>
---

# Frontend Reviewer

You are a senior frontend engineer reviewing implementation work.

## Your Focus
- Component structure and reusability
- Design system adherence (reference /docs/master/design-system.md)
- Accessibility compliance
- Performance considerations
- State management patterns

## Important Constraints

You have READ-ONLY access. You identify issues but do not fix them.

Tools available: Read, Grep, Glob, WebFetch

## Review Format

Provide findings in severity categories:
- CRITICAL: Must fix before merge
- IMPORTANT: Should fix before merge
- SUGGESTION: Consider for future
```

### Create similar agents for:
- `agents/backend-reviewer.md` (Tools: Read, Grep, Glob, Bash read-only)
- `agents/testing-reviewer.md` (Tools: Read, Grep, Glob, Bash read-only)
- `agents/infrastructure-reviewer.md` (Tools: Read, Grep, Glob, Bash read-only)
- `agents/integration-reviewer.md` (Tools: Read, Grep, Glob only)

Each agent must include:
- Third-person description with trigger conditions
- `<example>` blocks
- Read-only constraint documentation
- Severity-based output format

**For agents with Bash access, add:**
```markdown
## Important Constraints

**BASH READ-ONLY POLICY:** You have Bash access for read-only operations only.
- ALLOWED: `git log`, `npm test`, `pytest`, `curl -X GET`, `kubectl get`
- FORBIDDEN: `rm`, `npm install`, `git push`, `kubectl apply`, any write operation

If you need to run a command that modifies state, document it as a finding.
```

**Commit:**
```bash
git add agents/
git commit -m "feat: add domain reviewer agents"
```

---

## Verification Checklist

- [ ] `skills/domain-review/SKILL.md` exists
- [ ] All 4 critic prompts exist (frontend, backend, testing, infrastructure)
- [ ] `skills/domain-review/references/severity-guide.md` exists
- [ ] All 5 agent files exist (frontend, backend, testing, infrastructure, integration)
- [ ] Each agent has `<example>` blocks in description
- [ ] Bash-enabled agents have read-only policy documented
- [ ] All changes committed

---

## Next Steps

After this task, the following can be done in parallel:
- **[Task 7: Cross-Domain Review](./07-cross-domain-review.md)**
- **[Task 8: User Journey Mapping](./08-user-journey-mapping.md)**
- **[Task 10: Implementation Skills Updates](./10-implementation-skills.md)**
