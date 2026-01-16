# Task 5: Core Workflow Skills

> **Devpowers Implementation** | [← Project Setup](./04-project-setup.md) | [Next: Domain Review →](./06-domain-review.md)

---

## Context

**This task updates existing skills and creates task-breakdown for the core workflow.** These skills form the planning phase before domain review.

### Prerequisites
- **Task 3** completed (using-devpowers entry point)
- **Task 4** completed (project-setup with master docs)

### What This Task Creates/Modifies
- Updates `skills/brainstorming/SKILL.md`
- Updates `skills/writing-plans/SKILL.md`
- Updates `skills/reviewing-plans/SKILL.md` with critic prompts
- Creates `skills/task-breakdown/` skill
- Updates `skills/chunking-plans/SKILL.md` (if exists)

### Tasks That Depend on This
- **Task 6** (Domain Review) - reviews output of task-breakdown

---

## Sub-Tasks

This task has 5 sub-tasks:
1. Update brainstorming
2. Update writing-plans
3. Update reviewing-plans with critics
4. Create task-breakdown
5. Update chunking-plans

---

## Sub-Task 5.1: Update brainstorming

**File:** `skills/brainstorming/SKILL.md`

**Changes to add:**

1. **Scope assessment at start:**
```markdown
## Scope Assessment

Before brainstorming, assess scope:
- **Trivial:** Direct implementation, skip brainstorming
- **Small:** Brief brainstorm, simple plan
- **Medium/Large:** Full brainstorming process

Ask user to confirm scope if unclear.
```

2. **Output to /docs/plans/[feature]/ structure:**
```markdown
## Output Structure

Create:
```
/docs/plans/[feature]/
├── STATUS.md          # From template
├── learnings.md       # From template
└── brainstorm.md      # Brainstorming notes
```
```

3. **Reference master docs:**
```markdown
## Before Brainstorming

Read master docs for context:
- `/docs/master/design-system.md` — UI patterns to follow
- `/docs/master/lessons-learned/` — Past learnings to consider
- `/docs/master/patterns/` — Established patterns
```

4. **Update handoff:**
```markdown
## Handoff

"Brainstorming complete. Feature folder created at `/docs/plans/[feature]/`.

Ready to write the high-level plan?"

→ Invokes `writing-plans`
```

**Commit:**
```bash
git add skills/brainstorming/
git commit -m "feat: update brainstorming for devpowers workflow"
```

---

## Sub-Task 5.2: Update writing-plans

**File:** `skills/writing-plans/SKILL.md`

**Changes to add:**

1. **Focus on high-level architecture:**
```markdown
## Plan Focus

Write HIGH-LEVEL architecture, not implementation details:
- Major components and their responsibilities
- Data flow between components
- Key interfaces and contracts
- Technology choices and rationale

Do NOT include:
- Specific function implementations
- Line-by-line code changes
- Detailed file modifications (that's task-breakdown)
```

2. **Output location:**
```markdown
## Output

Save to: `/docs/plans/[feature]/high-level-plan.md`
```

3. **State update:**
```markdown
## State Update

After writing plan, update STATUS.md:
- Stage: high-level-plan
- Last Action: High-level plan written
- Next Action: Plan review
```

4. **Update handoff:**
```markdown
## Handoff

"High-level plan complete and saved to `/docs/plans/[feature]/high-level-plan.md`.

Ready for plan review?"

→ Invokes `reviewing-plans`
```

**Commit:**
```bash
git add skills/writing-plans/
git commit -m "feat: update writing-plans for devpowers workflow"
```

---

## Sub-Task 5.3: Update reviewing-plans with Critics

**Files to create/modify:**
- `skills/reviewing-plans/SKILL.md` (update)
- `skills/reviewing-plans/feasibility-critic.md` (create)
- `skills/reviewing-plans/completeness-critic.md` (create)
- `skills/reviewing-plans/simplicity-critic.md` (create)
- `skills/reviewing-plans/references/severity-guide.md` (create)

### Update SKILL.md frontmatter:

```markdown
---
name: reviewing-plans
description: >
  This skill should be used when the user asks to "review the plan",
  "validate the architecture", "check if the plan is ready", "critique the design",
  or after writing-plans produces a high-level-plan.md file. Runs parallel critics
  to find issues before committing to implementation.
---
```

### Add to SKILL.md body:

```markdown
## Scope Clarification

This skill reviews `high-level-plan.md` (architecture, approach, major components).

It does NOT review:
- Individual task files (that's `domain-review`)
- Integration between domains (that's `cross-domain-review`)
- Actual code (that's code reviewers)

## Review Loop

This skill uses review loops. Follow the central review loop rules:
- Maximum 3 rounds per review stage
- Convergence: No CRITICAL or IMPORTANT issues
- After 3 rounds: Present user with accept/escalate/abort options

## Three Parallel Critics

Dispatch all three critics in parallel (single message with 3 Task tool calls):

1. **Feasibility Critic** — Will this architecture work? Correct assumptions? Dependencies?
2. **Completeness Critic** — All requirements covered? Error handling? Edge cases?
3. **Simplicity Critic** — Over-engineered? YAGNI violations? Unnecessary complexity?

## Workflow

1. Read high-level plan from `/docs/plans/[feature]/high-level-plan.md`
2. Dispatch 3 critics in parallel
3. Aggregate findings by severity (CRITICAL → IMPORTANT → MINOR → NITPICK)
4. Present to user with recommended fixes
5. If fixes applied: Loop until converged (max 3 rounds)
6. Update STATUS.md with review outcome

## Handoff

"Plan review complete. [Summary of findings/fixes].

Ready to break into implementable tasks?"

→ Invokes `task-breakdown`
```

### Create feasibility-critic.md:

```markdown
# Feasibility Critic

You are reviewing a high-level architecture plan for technical feasibility.

## Your Focus

1. **Technical Viability** — Will this architecture actually work?
2. **Assumptions** — What assumptions does the plan make? Are they valid?
3. **Dependencies** — Are all required dependencies available?
4. **Constraints** — Performance, scalability, security requirements?

## Output Format

```markdown
## Feasibility Review

### CRITICAL Issues
[Must fix before proceeding]

### IMPORTANT Issues
[Should fix before proceeding]

### MINOR Issues
[Can proceed, fix before merge]

### NITPICK
[Optional improvements]

### Summary
[Overall feasibility assessment]
```
```

### Create completeness-critic.md:

```markdown
# Completeness Critic

You are reviewing a high-level architecture plan for completeness.

## Your Focus

1. **Requirements Coverage** — Are all stated requirements addressed?
2. **Error Handling** — How are errors handled at each boundary?
3. **Edge Cases** — Empty states, limits, concurrent access, network failures?
4. **Security** — Authentication, authorization, input validation, data protection?

## Output Format

[Same structure as feasibility critic]
```

### Create simplicity-critic.md:

```markdown
# Simplicity Critic

You are reviewing a high-level architecture plan for unnecessary complexity.

## Your Focus

1. **Over-Engineering** — Are there simpler alternatives?
2. **YAGNI Violations** — Features not requested? Premature optimization?
3. **Complexity Hotspots** — Areas with too many moving parts?

## Output Format

[Same structure as feasibility critic]
```

### Create references/severity-guide.md:

```markdown
# Issue Severity Guide

## CRITICAL
Must fix before proceeding. Blocks workflow.
- Architectural flaws that would require rewrite
- Missing core requirements
- Security vulnerabilities
- Technical impossibilities

## IMPORTANT
Should fix before proceeding.
- Missing edge cases
- Incomplete error handling
- Non-obvious dependencies
- Scalability concerns

## MINOR
Can proceed, fix before merge.
- Code style concerns
- Minor optimizations
- Documentation gaps

## NITPICK
Optional improvements.
- Naming suggestions
- Alternative approaches to consider
- Nice-to-haves
```

**Commit:**
```bash
mkdir -p skills/reviewing-plans/references
git add skills/reviewing-plans/
git commit -m "feat: add parallel critics to reviewing-plans skill"
```

---

## Sub-Task 5.4: Create task-breakdown Skill

**Files to create:**
- `skills/task-breakdown/SKILL.md`
- `skills/task-breakdown/breakdown-agent.md`
- `skills/task-breakdown/references/task-sizing-guide.md`
- `skills/task-breakdown/assets/task-template.md`
- `skills/task-breakdown/assets/overview-template.md`

### Create directory structure:

```bash
mkdir -p skills/task-breakdown/{references,assets}
```

### Create SKILL.md:

```markdown
---
name: task-breakdown
description: >
  This skill should be used when the user asks to "break down the plan",
  "create task files", "split into implementable tasks", "generate task documents",
  or after reviewing-plans completes successfully. Converts high-level architecture
  into discrete task files ready for domain review.
---

# Task Breakdown

## Overview

Break a reviewed high-level plan into implementable task documents.

Distinct from `chunking-plans` which handles **recursive subdivision** of tasks that turn out to be too complex during domain review.

| Skill | Purpose | Input | Output |
|-------|---------|-------|--------|
| `task-breakdown` | Initial breakdown | high-level-plan.md | tasks/*.md |
| `chunking-plans` | Recursive subdivision | Existing task too complex | task/subtasks/*.md |

## Output Structure

Creates:
```
/docs/plans/[feature]/tasks/
├── 00-overview.md      # Dependency map and task index
├── 01-setup.md         # First task
├── 02-models.md        # Second task
└── ...
```

Each task sized for ~30 min to 2 hours of implementation work.

## Workflow

1. Read approved high-level plan
2. Identify logical task boundaries (by component, by layer, by feature slice)
3. Create task files using `assets/task-template.md`
4. Generate `00-overview.md` with task map showing execution order
5. Validate: each task is self-contained enough to implement independently
6. Update STATUS.md

## Handoff

"Task breakdown complete. Created [N] tasks in `/docs/plans/[feature]/tasks/`.

Ready for domain review?"

→ Invokes `domain-review`
```

### Create assets/task-template.md:

See complete plan for full template. Key sections:
- Goal, Context
- Files to Create/Modify
- Implementation Steps
- Acceptance Criteria
- Dependencies
- Unit Test Plan (populated by testing critic)
- E2E Test Plan (from journey mapping)

### Create assets/overview-template.md:

See complete plan for full template with ASCII task map.

**Commit:**
```bash
git add skills/task-breakdown/
git commit -m "feat: add task-breakdown skill"
```

---

## Sub-Task 5.5: Update chunking-plans

**File:** `skills/chunking-plans/SKILL.md` (or create if using plugin)

**Changes to add:**

```markdown
## Recursion Rules

- **Maximum depth:** 3 levels (task → subtask → sub-subtask)
- **If deeper needed:** Reconsider task boundaries, likely architectural issue
- **Naming convention:** `tasks/03-auth/subtasks/01-validation/subtasks/01-email.md`

## Domain Review Integration

When critic flags "task too complex":
1. Pause domain review
2. Invoke chunking-plans → creates subtask folder
3. Resume domain review on NEW subtasks (round counter resets for new tasks)
4. Original task marked as "container" (not directly implemented)

## Complexity Signals (Triggers Chunking)

- Task description exceeds 500 words
- More than 10 implementation steps
- Multiple unrelated acceptance criteria
- Critic explicitly flags complexity
```

**Commit:**
```bash
git add skills/chunking-plans/
git commit -m "feat: update chunking-plans with recursive subdivision"
```

---

## Verification Checklist

- [ ] `skills/brainstorming/SKILL.md` has scope assessment
- [ ] `skills/writing-plans/SKILL.md` outputs to `/docs/plans/[feature]/`
- [ ] `skills/reviewing-plans/` has all 3 critic files
- [ ] `skills/reviewing-plans/references/severity-guide.md` exists
- [ ] `skills/task-breakdown/` skill created with templates
- [ ] `skills/chunking-plans/SKILL.md` has recursion rules
- [ ] All changes committed

---

## Next Steps

Proceed to **[Task 6: Domain Review](./06-domain-review.md)**.
