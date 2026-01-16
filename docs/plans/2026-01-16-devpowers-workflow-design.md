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

- **Global templates:** Live in the plugin at `skills/project-setup/assets/master-doc-templates/`
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

### Template Contents

**design-system.md** (tailored based on detected UI framework):
```markdown
# Design System

## Colors
- Primary: [detected or placeholder]
- Secondary: [detected or placeholder]
- Error/Success/Warning states

## Typography
- Font families
- Size scale
- Line heights

## Spacing
- Base unit
- Scale (xs, sm, md, lg, xl)

## Components
- Button variants
- Form elements
- Card patterns
- Navigation patterns

## Responsive Breakpoints
- Mobile/Tablet/Desktop definitions

## Anti-Patterns (avoid these)
- [Populated from lessons learned]
```

**lessons-learned/[domain].md** template:
```markdown
# Lessons Learned: [Domain]

## Patterns That Work
<!-- Successful approaches discovered during implementation -->

## Anti-Patterns
<!-- Approaches that failed or caused issues -->

## Gotchas
<!-- Non-obvious behaviors, edge cases, surprises -->

## Useful Tools/Libraries
<!-- Recommendations with context -->
```

**patterns/** — Initially empty, populated as patterns emerge during development.

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

### Update & Conflict Resolution

When `lessons-learned` proposes updates to master docs:

1. **Read existing content** — Load current master doc section
2. **Analyze proposed addition** — Understand what the new learning contributes
3. **LLM-driven merge** — Agent determines how to integrate new content:
   - If new pattern: Add to appropriate section
   - If refinement of existing: Update existing content
   - If contradiction: Present both to user with context, let user decide
   - If supersedes: Replace old content, note what changed
4. **Present diff** — Show user what will change before applying
5. **Commit with context** — Commit message explains what was learned and why

## Workflow Scope Tiers

Not every change needs the full workflow. Scope determines which steps apply:

| Scope | Description | Workflow |
|-------|-------------|----------|
| **Trivial** | Typo fix, config tweak, single-line change | Direct implementation, no planning |
| **Small** | Bug fix, minor enhancement, <50 lines | Brainstorm → Plan → Implement → Lessons (optional) |
| **Medium** | Feature addition, moderate complexity | Full workflow, skip user journey mapping if no UI |
| **Large** | Major feature, architectural change | Full workflow |

**Scope detection:** At brainstorming start, assess scope and confirm with user. If scope changes during planning (task turns out bigger than expected), escalate to appropriate tier.

---

## Complete Workflow (Large Scope)

```
PROJECT SETUP (once per project)
    ↓
BRAINSTORM → /docs/plans/[feature]/ created
    ↓
HIGH-LEVEL PLAN → high-level-plan.md
    ↓
REVIEWING-PLANS (feasibility/completeness/simplicity) → loop (max 3 rounds)
    ↓
BREAK INTO TASKS → /tasks/ folder
    ↓
DOMAIN REVIEW (frontend/backend/testing/infra) → loop (max 3 rounds), chunk if needed
  └─ Testing critic maintains unit test plan
    ↓
CROSS-DOMAIN REVIEW → integration validated
    ↓
USER JOURNEY MAPPING → e2e test plan (skip for non-UI features)
    ↓
WORKTREE
    ↓
IMPLEMENT (TDD with pre-planned tests, append to learnings.md)
    ↓
LESSONS LEARNED → master doc updates
    ↓
FINISH BRANCH
```

---

## Review Loop Rules

All review loops follow these termination rules:

**Maximum iterations:** 3 rounds per review stage
- Round 1: Initial review, identify issues
- Round 2: Verify fixes, find remaining issues
- Round 3: Final verification

**After 3 rounds without convergence:**
> "Review has not converged after 3 rounds. Remaining issues:
> [list CRITICAL/IMPORTANT issues]
>
> Options:
> 1. Accept with known issues and proceed
> 2. Escalate for manual review
> 3. Abort and reconsider approach"

**Convergence criteria:**
- No CRITICAL issues remaining
- No IMPORTANT issues remaining (or explicitly accepted)
- MINOR/NITPICK issues can proceed to next stage

---

## Agent Failure Handling

When agents fail technically (timeout, crash, error), apply these recovery rules:

**Retry logic:**
- Automatic retry: 2 attempts with 5-second backoff
- If still failing after retries, report failure and continue

**Graceful degradation:**
- If one domain critic fails during `domain-review`: "Backend critic unavailable. Proceed with 3 critics, or retry?"
- If stack detection fails during `project-setup`: "Could not auto-detect stack. Please specify: [options] or proceed with generic templates?"
- If subagent fails during implementation: Save partial progress, report which task failed, offer to retry or skip

**Partial progress preservation:**
- Before each significant action, note state in `STATUS.md`
- On failure, state file shows exactly where to resume
- Completed review findings are preserved even if aggregation fails

**User notification:**
- Always inform user of failures: "[Agent] failed: [reason]. [Recovery options]"
- Never silently skip a failed step

---

## Scope Escalation

When scope changes during planning (task turns out bigger than expected):

**Detection triggers:**
- Task breakdown yields >5 tasks for a "Small" scope item
- Domain review identifies architectural changes for a "Medium" scope item
- Any reviewer flags "this is larger than expected"

**Escalation process:**
1. Pause current workflow
2. Present finding: "This appears larger than [current tier]. Recommend escalating to [higher tier]."
3. Show what additional steps would apply
4. User confirms or overrides
5. If escalated: Insert missing steps, continue from current position
6. Existing artifacts are preserved, not discarded

**Scope can only escalate, not descend** — once in Large workflow, stay there.

---

## Workflow Interruption & Recovery

### Detecting Current State

Each skill checks for existing artifacts to determine workflow state:
- `/docs/master/` exists → project setup complete
- `/docs/plans/[feature]/` exists → brainstorming done
- `high-level-plan.md` exists → planning done
- `/tasks/` folder exists → breakdown done

On resume, detect state and prompt: "Found existing [artifacts]. Continue from [stage]?"

### Aborting a Workflow

At any handoff prompt, user can respond with "abort" to trigger cleanup:

1. **Confirm scope of abort:** "Abort this feature entirely, or just pause?"
2. **If abort entirely:**
   - Archive `/docs/plans/[feature]/` to `/docs/plans/archived/[feature]-[date]/`
   - Delete worktree if created
   - Prompt: "Feature archived. Start fresh or work on something else?"
3. **If pause:**
   - Note current state in `/docs/plans/[feature]/STATUS.md`
   - Prompt: "Paused at [stage]. Resume anytime by opening this feature."

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

**Trigger conditions:** Use when starting a new project that needs master documents, when project has no `/docs/master/` directory, or after cloning a fresh repo that uses devpowers.

---

#### `domain-review`

Orchestrates parallel domain-expert agents to review implementation-level task documents.

**Structure:**
```
skills/domain-review/
├── SKILL.md
├── prompts/
│   ├── frontend-critic.md
│   ├── backend-critic.md
│   ├── testing-critic.md
│   └── infrastructure-critic.md
└── references/
    └── severity-guide.md
```

**Each domain critic checks:**
- Feasibility — Will this approach work?
- Completeness — All cases covered?
- Simplicity — Over-engineered?
- Patterns — Follows master docs?

**Selective domain execution:**
Not all critics run for every task. Detect relevant domains from task content:
- Frontend: Task mentions UI, components, styles, user interaction
- Backend: Task mentions API, database, server logic, authentication
- Testing: Always runs (maintains test plan)
- Infrastructure: Task mentions deployment, CI/CD, environment, scaling

Prompt: "Detected domains: [list]. Run all, or adjust?"

**Aggregation rules:**
- Collect all findings from parallel critics
- Group by severity (CRITICAL → IMPORTANT → MINOR → NITPICK)
- If critics disagree on severity, take the higher severity
- If critics have conflicting recommendations, present both to user

**Test plan maintenance:**
- Testing critic reviews task and proposes unit tests
- Test plan updated in task doc after each domain review round
- Other critics can flag "needs test for X" which testing critic incorporates

**Chunking integration:**
- If any critic flags "task too complex" → pause review
- Run `task-breakdown` on the complex task
- Resume domain review with new smaller tasks
- Round counter resets for newly chunked tasks (they're new tasks)
- Original round counter continues for unchanged tasks

**Workflow:**
1. Read task document(s) and relevant master docs
2. Detect relevant domains, confirm with user
3. Dispatch selected critics in parallel
4. Aggregate findings by severity
5. If chunking needed → chunk → re-review new tasks
6. Loop until converged (max 3 rounds per task)

**Trigger conditions:** Use when task documents need expert validation, when checking if tasks are implementation-ready, when validating implementation details across domains.

---

#### `task-breakdown`

Breaks a reviewed high-level plan into implementable task documents. Distinct from `chunking-plans` which handles recursive subdivision of already-created tasks.

**Structure:**
```
skills/task-breakdown/
├── SKILL.md
├── prompts/
│   └── breakdown-agent.md
└── references/
    └── task-sizing-guide.md
```

**What it produces:**
- Individual task files in `/docs/plans/[feature]/tasks/`
- `00-overview.md` with dependency map
- Each task sized for ~30 min to 2 hours of implementation work

**Workflow:**
1. Read approved high-level plan
2. Identify logical task boundaries (by component, by layer, by feature slice)
3. Create task files with: goal, context, acceptance criteria, dependencies
4. Generate `00-overview.md` with task map showing execution order
5. Validate: each task is self-contained enough to implement independently

**Trigger conditions:** Use after high-level plan review passes, when breaking architecture into implementable units, when creating task files for domain review.

---

#### `reviewing-plans`

Reviews high-level plans for feasibility, completeness, and simplicity before task breakdown.

**Structure:**
```
skills/reviewing-plans/
├── SKILL.md
├── prompts/
│   ├── feasibility-critic.md
│   ├── completeness-critic.md
│   └── simplicity-critic.md
└── references/
    └── review-severity-guide.md
```

**Three parallel critics:**
- **Feasibility** — Will this architecture work? Correct assumptions? Dependencies available?
- **Completeness** — All requirements covered? Error handling? Edge cases?
- **Simplicity** — Over-engineered? YAGNI violations? Unnecessary complexity?

**Workflow:**
1. Read high-level plan
2. Dispatch 3 critics in parallel
3. Aggregate findings by severity
4. Present to user with recommended fixes
5. Loop until converged (max 3 rounds)
6. Handoff to `task-breakdown`

**Trigger conditions:** Use after writing a high-level plan, when validating architecture before implementation, when checking if plan is ready for task breakdown.

---

#### `cross-domain-review`

Validates integration points between domains after individual domain reviews pass.

**Structure:**
```
skills/cross-domain-review/
├── SKILL.md
├── prompts/
│   └── integration-critic.md
└── references/
    └── common-integration-issues.md
```

**What it checks:**
- API contracts — Does frontend expect what backend provides?
- Data flow — Correct transformations between layers?
- Error propagation — Errors flow correctly across boundaries?
- Timing/sequencing — Async operations coordinated?
- Dependencies — Cross-domain deps explicit and ordered?
- External dependencies — Third-party APIs, services, infrastructure requirements

**Bidirectional flow:**
If cross-domain review finds issues requiring domain-specific changes:
1. Identify which domain(s) need updates
2. Route back to relevant domain critic(s) for targeted fix
3. Domain critic proposes fix within their scope
4. Re-run cross-domain review to verify fix
5. Max 2 round-trips before escalating to user

**Workflow:**
1. Read all task documents + 00-overview.md (dependency map)
2. Dispatch integration critic that sees everything
3. Findings focus on interfaces between domains
4. If domain-specific fix needed → route to domain → re-verify
5. Loop if CRITICAL/IMPORTANT issues found (max 3 rounds)

**Trigger conditions:** Use when validating integration points, checking API contracts, reviewing frontend-backend interfaces, or verifying cross-domain dependencies.

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

#### `frontend-design` (fork of `frontend-design:frontend-design`)

Custom frontend design skill that avoids generic UI patterns. Forked from the `frontend-design` plugin's skill, customized to integrate with devpowers master documents.

**Fork source:** `frontend-design:frontend-design` plugin skill

**Structure:**
```
skills/frontend-design/
├── SKILL.md
├── references/
│   └── design-principles.md
└── examples/
    └── component-patterns/
```

**Key customizations from original:**
- Reads `/docs/master/design-system.md` for project conventions
- Integrates with domain review (frontend critic references this skill's principles)
- Appends to learnings log when discovering what works

**Key behaviors:**
- Avoids generic "AI look" patterns
- Focuses on distinctive, purposeful design
- Maintains project-specific component patterns

**Trigger conditions:** Use when designing UI components, building frontend interfaces, creating visual designs, or when user asks for "distinctive" or "non-generic" UI.

---

#### `playwright-testing` (fork of `playwright-skill:playwright-skill`)

Custom e2e testing skill using journey maps. Forked from the `playwright-skill` plugin, customized to integrate with devpowers user journey mapping.

**Fork source:** `playwright-skill:playwright-skill` plugin skill

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

**Key customizations from original:**
- Reads journey maps to ensure complete test coverage
- Reads `/docs/master/lessons-learned/testing.md` for project patterns
- Integrates with domain review (testing critic references this skill)
- Appends to learnings log when tests reveal unexpected behavior

**Key behaviors:**
- Generates tests from user journey maps (not ad-hoc)
- Covers error states, edge cases, accessibility per journey categories
- Validates against journey map completeness

**Trigger conditions:** Use when writing e2e tests, implementing tests from journey maps, setting up Playwright test infrastructure, or when user asks about test coverage for user flows.

---

### Skills to Modify

#### `brainstorming`
- Output to `/docs/plans/[feature]/` structure
- Reference master docs during design exploration
- Create `learnings.md` file when feature folder created
- Add scope assessment at start (trivial/small/medium/large)

#### `writing-plans`
- Focus on high-level architecture, not implementation details
- Output to `/docs/plans/[feature]/high-level-plan.md`
- Add handoff to `reviewing-plans`

#### `chunking-plans`
- Rename role: handles **recursive subdivision** of existing tasks (when domain review finds a task too complex)
- Distinct from `task-breakdown` which handles **initial breakdown** from high-level plan
- Support arbitrarily deep recursion (subtasks can have subtasks)
- Integrate with domain review loop (called when complexity flagged)
- Update output: subdivided tasks go in `[task]/subtasks/` folder

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

## Plan Review Phase
<!-- Plan reviewers append here -->

## Domain Review Phase
<!-- Domain critics append here -->

## Implementation Phase
<!-- Implementation agents append here -->

## Code Review Phase
<!-- Code reviewers append here -->
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

**Parallel append coordination:**
When multiple critics run in parallel (e.g., domain review), each critic appends to their designated subsection:
```markdown
## Domain Review Phase

### Frontend Critic Findings
[Frontend critic appends here]

### Backend Critic Findings
[Backend critic appends here]

### Testing Critic Findings
[Testing critic appends here]

### Infrastructure Critic Findings
[Infrastructure critic appends here]
```

The orchestrating skill creates these subsections before dispatching critics. Each critic only writes to their section, avoiding write conflicts. After critics complete, the orchestrator aggregates and deduplicates if needed.

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
