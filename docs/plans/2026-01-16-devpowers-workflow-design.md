# Devpowers Workflow Design

This document describes the redesigned devpowers plugin workflow, customized for a development process with explicit review stages, master documents for institutional knowledge, and comprehensive test planning.

## Overview

Devpowers is a fork of superpowers, modified to support:
- **Master documents** — Persistent knowledge that accumulates per-project
- **Two-level planning** — High-level architecture reviewed separately from implementation details
- **Domain-expert review** — Specialized agents validate their areas before implementation
- **User journey mapping** — Comprehensive test coverage through explicit behavior mapping
- **Learnings capture** — Agent-experienced insights feed back into master docs

## Master Documents System

### Location & Scope

- **Global templates:** Live in the plugin at `master-docs-templates/`
- **Project-local:** Created at `/docs/master/` during project setup
- **Relationship:** Global templates get copied and tailored to each project

### Structure

```
/docs/master/
  design-system.md           # UI patterns, component conventions
  lessons-learned/
    frontend.md
    backend.md
    testing.md
    infrastructure.md
  patterns/
    [stack-specific patterns discovered over time]
```

### Setup Flow

1. User runs `project-setup` skill in a new project
2. Stack analysis agent examines project (package.json, folder structure, existing code)
3. Agent reads global templates and generates project-tailored versions
4. Writes to `/docs/master/`
5. These docs evolve via the "lessons learned" step after implementations

### How They're Used

- Domain review agents reference them when reviewing plans
- Implementation subagents reference them for context
- Lessons learned skill proposes updates after each feature

## Complete Workflow

```
PROJECT SETUP (once per project)
    ↓
BRAINSTORM → /docs/plans/[feature]/ created
    ↓
HIGH-LEVEL PLAN → high-level-plan.md
    ↓
REVIEWING-PLANS (feasibility/completeness/simplicity) → loop
    ↓
BREAK INTO TASKS → /tasks/ folder
    ↓
DOMAIN REVIEW (frontend/backend/testing/infra) → loop, chunk if needed
  └─ Testing critic maintains unit test plan
    ↓
CROSS-DOMAIN REVIEW → integration validated
    ↓
USER JOURNEY MAPPING → e2e test plan
    ↓
WORKTREE
    ↓
IMPLEMENT (TDD with pre-planned tests, append to learnings.md)
    ↓
LESSONS LEARNED → master doc updates
    ↓
FINISH BRANCH
```

## Skills Inventory

### New Skills

#### `project-setup`

Initializes a project with tailored master documents.

**Structure:**
```
skills/project-setup/
├── SKILL.md
├── scripts/
│   └── detect-stack.sh
├── assets/
│   └── master-doc-templates/
│       ├── design-system.md
│       ├── lessons-learned/
│       └── patterns/
└── references/
    └── stack-detection-guide.md
```

**Workflow:**
1. Run `scripts/detect-stack.sh` — outputs detected frameworks
2. Agent reads template master docs from `assets/`
3. Agent tailors templates based on detected stack
4. Writes tailored docs to `/docs/master/`
5. Commits initial master docs

**Trigger phrases:** "set up devpowers", "initialize master docs", "configure project"

---

#### `domain-review`

Orchestrates parallel domain-expert agents to review implementation-level task documents.

**Structure:**
```
skills/domain-review/
├── SKILL.md
├── frontend-critic-prompt.md
├── backend-critic-prompt.md
├── testing-critic-prompt.md
├── infrastructure-critic-prompt.md
└── references/
    └── severity-guide.md
```

**Each domain critic checks:**
- Feasibility — Will this approach work?
- Completeness — All cases covered?
- Simplicity — Over-engineered?
- Patterns — Follows master docs?

**Additional responsibilities:**
- Testing critic maintains unit test plan as design evolves
- If task too complex → recommend chunking

**Workflow:**
1. Read task document(s) and relevant master docs
2. Dispatch 4 domain critics in parallel
3. Aggregate findings by severity (CRITICAL/IMPORTANT/MINOR/NITPICK)
4. If task too complex → chunk and re-review
5. Loop until converged

**Trigger phrases:** "domain review", "check if implementation-ready"

---

#### `cross-domain-review`

Validates integration points between domains after individual domain reviews pass.

**Structure:**
```
skills/cross-domain-review/
├── SKILL.md
├── integration-critic-prompt.md
└── references/
    └── common-integration-issues.md
```

**What it checks:**
- API contracts — Does frontend expect what backend provides?
- Data flow — Correct transformations between layers?
- Error propagation — Errors flow correctly across boundaries?
- Timing/sequencing — Async operations coordinated?
- Dependencies — Cross-domain deps explicit and ordered?

**Workflow:**
1. Read all task documents + 00-overview.md (dependency map)
2. Dispatch integration critic that sees everything
3. Findings focus on interfaces between domains
4. Loop if CRITICAL/IMPORTANT issues found

**Trigger phrases:** "cross-domain review", "check integration points"

---

#### `user-journey-mapping`

Comprehensively maps user behaviors before test writing.

**Structure:**
```
skills/user-journey-mapping/
├── SKILL.md
├── journey-critic-prompt.md
├── references/
│   └── journey-categories.md
└── examples/
    └── login-journey.md
```

**Journey map covers:**
- Happy paths
- Variations (different entry points, user states)
- Error states (validation, network, server, permissions)
- Edge cases (limits, empty states, rapid actions, unicode)
- Interruptions (navigation, refresh, timeout)
- Accessibility (keyboard, screen reader, focus)

**Workflow:**
1. Generate initial journey map
2. Dispatch Journey Critic to review for gaps
3. If gaps found → add to map → re-review
4. Loop until critic finds no significant gaps
5. Output: `/docs/plans/[feature]/journeys/[component]-journeys.md`
6. Derive e2e test plan from journey map (added to task docs)

**Trigger phrases:** "map user journeys", "identify test scenarios"

---

#### `lessons-learned`

Reviews completed implementations and proposes updates to master documents.

**Structure:**
```
skills/lessons-learned/
├── SKILL.md
├── implementation-reviewer-prompt.md
└── references/
    └── update-categories.md
```

**What it captures:**
- New patterns — Reusable approaches that emerged
- Difficult problems — Issues and solutions
- New tools/procedures — Utilities or workflows created
- Anti-patterns — What didn't work
- Corrections — Master doc content that was wrong

**Two sources of learnings:**
1. **Artifacts** — Inferred from code, plans, git history
2. **Agent experience** — Captured in `learnings.md` during review/implementation

**Workflow:**
1. Read `learnings.md` (agent-captured notes)
2. Review artifacts (plan, tasks, git diff/log)
3. Categorize findings by master doc section
4. Present proposed updates
5. On approval, apply updates and commit

**Trigger phrases:** "capture lessons learned", "update master docs"

---

#### `frontend-design` (fork)

Custom frontend design skill that avoids generic UI patterns.

**Structure:**
```
skills/frontend-design/
├── SKILL.md
├── references/
│   └── design-principles.md
└── examples/
    └── component-patterns/
```

**Key behaviors:**
- Reads `/docs/master/design-system.md` for project conventions
- Avoids generic "AI look" patterns
- Focuses on distinctive, purposeful design
- Appends to learnings log when discovering what works

---

#### `playwright-testing` (fork)

Custom e2e testing skill using journey maps.

**Structure:**
```
skills/playwright-testing/
├── SKILL.md
├── scripts/
│   └── scaffold-test.sh
├── references/
│   └── testing-patterns.md
└── examples/
    └── sample-tests/
```

**Key behaviors:**
- Reads journey maps to ensure complete coverage
- Reads `/docs/master/lessons-learned/testing.md` for patterns
- Covers error states, edge cases, accessibility
- Appends to learnings log when tests reveal unexpected behavior

---

### Skills to Modify

#### `brainstorming`
- Output to `/docs/plans/[feature]/` structure
- Reference master docs during design exploration
- Create `learnings.md` file when feature folder created

#### `writing-plans`
- Focus on high-level architecture, not implementation details
- Output to `/docs/plans/[feature]/high-level-plan.md`
- Add handoff to `reviewing-plans`

#### `reviewing-plans`
- Move to standard skill location
- Add instructions for critics to append to `learnings.md`
- Update handoff to reference breakdown/domain-review flow

#### `chunking-plans`
- Support recursive chunking (tasks can be chunked further)
- Integrate with domain review loop
- Update output structure to match `/docs/plans/[feature]/tasks/`

#### `subagent-driven-development`
- Implementation agents reference test plan in task docs
- Add instructions to append to `learnings.md`
- Ensure TDD flow uses pre-planned test cases

#### `test-driven-development`
- Reference test plan from task doc
- Adapt for both unit tests (from domain review) and e2e tests (from journey mapping)

#### All agent prompts
- Add learnings log instructions
- Reference master docs for patterns

---

### Skills to Delete

- `dispatching-parallel-agents` — Redundant with domain-review orchestration
- `executing-plans` — If subagent-driven is primary execution method
- `receiving-code-review` — Evaluate based on workflow needs

---

## Learnings Log

Each feature gets a learnings log that agents append to during work.

**Location:** `/docs/plans/[feature]/learnings.md`

**Template:**
```markdown
# Learnings Log: [Feature Name]

## Review Phase
<!-- Agents append here during plan review -->

## Implementation Phase
<!-- Agents append here during implementation -->
```

**When agents append:**
- Multiple iterations needed to solve something
- Documentation didn't match reality
- A pattern emerged across multiple places
- A workaround was required
- Something that "should have worked" didn't

**Entry format:**
```markdown
### [Date/Task] - Brief title
**Context:** What was being attempted
**Issue:** What went wrong or was tricky
**Resolution:** What finally worked
**Lesson:** What to remember for next time
```

---

## Test Planning

### Unit Tests

Planned during domain review by the testing critic. As features/details change, the unit test plan updates immediately. By the time design is finalized, unit test plan is complete.

**Format in task docs:**
```markdown
## Unit Test Plan
- [ ] validateEmail() - valid formats accepted
- [ ] validateEmail() - invalid formats rejected
- [ ] hashPassword() - returns different hash each time
```

### E2E Tests

Planned after design is finalized via user journey mapping. Journey maps are created, then e2e test cases are derived from them.

**Format in task docs:**
```markdown
## E2E Test Plan (from journey maps)
- [ ] Login: happy path - valid credentials → dashboard
- [ ] Login: invalid email format → inline error
- [ ] Login: wrong password → error message, stay on page
```

### Implementation

During implementation, tests are written following the pre-planned test cases, TDD-style (write test, see fail, implement, see pass).

---

## Explicit Handoffs

Each skill ends with a prompt asking if the user is ready for the next step.

**Pattern:**
```
> "[Skill] complete. [Brief summary].
>
> Next step: [Next skill] — [what it does]
>
> Ready to proceed?"
```

**Handoff chain:**

| Skill | Next Step |
|-------|-----------|
| `project-setup` | "Ready to start brainstorming a feature?" |
| `brainstorming` | "Ready to write the high-level plan?" |
| `writing-plans` | "Ready for plan review?" |
| `reviewing-plans` | "Ready to break into implementable tasks?" |
| `chunking-plans` | "Ready for domain review?" |
| `domain-review` | "Ready for cross-domain review?" |
| `cross-domain-review` | "Ready to map user journeys?" |
| `user-journey-mapping` | "Ready to create worktree and implement?" |
| `subagent-driven-development` | "Ready to capture lessons learned?" |
| `lessons-learned` | "Ready to finish the branch?" |
| `finishing-a-development-branch` | "[Complete summary]" |

---

## Implementation Order

1. **Foundation:** Move `reviewing-plans` into proper skill structure
2. **Master docs:** Create `project-setup` with templates
3. **Core workflow:** Modify `writing-plans`, `chunking-plans`
4. **Review agents:** Create `domain-review`, `cross-domain-review`
5. **Testing flow:** Create `user-journey-mapping`, fork `playwright-testing`
6. **Learning loop:** Create `lessons-learned`, update all prompts for learnings log
7. **Polish:** Fork `frontend-design`, integrate master doc references everywhere
