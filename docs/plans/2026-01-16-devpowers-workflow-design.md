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

**Description (frontmatter):**
```yaml
description: >
  This skill should be used when the user asks to "set up a new project",
  "initialize master documents", "create project structure", "bootstrap devpowers",
  or when starting development in a repo without `/docs/master/` directory.
  Sets up master documents tailored to the detected technology stack.
```

**Structure:**
```
skills/project-setup/
├── SKILL.md
├── scripts/
│   └── detect-stack.sh      # Outputs detected frameworks for Claude to interpret
├── assets/
│   └── master-doc-templates/
│       ├── design-system.md
│       ├── lessons-learned/
│       └── patterns/
└── references/
    └── stack-detection-guide.md   # Heuristics for Claude to apply judgment
```

**Directory conventions:**
- `assets/`: Templates and static resources copied to project (not loaded into context)
- `references/`: Documentation loaded on-demand when Claude needs guidance
- `scripts/`: Executable tools that output data for Claude to interpret

**Workflow:**
1. Run `scripts/detect-stack.sh` — outputs detected frameworks
2. Claude interprets results using `references/stack-detection-guide.md`
3. Agent reads template master docs from `assets/`
4. Agent tailors templates based on detected stack (applying judgment)
5. Writes tailored docs to `/docs/master/`
6. Commits initial master docs
7. Handoff: "Project setup complete. Ready to start brainstorming a feature?"

---

#### `domain-review`

Orchestrates parallel domain-expert agents to review **implementation-level task documents** (the output of `task-breakdown`). This is distinct from `reviewing-plans` which reviews high-level architecture.

**Description (frontmatter):**
```yaml
description: >
  This skill should be used when the user asks to "review tasks for implementation",
  "validate task documents", "run domain expert review", "check if tasks are ready",
  or after task-breakdown produces task files in `/docs/plans/[feature]/tasks/`.
  Reviews implementation details with specialized domain critics.
```

**Scope clarification:**
| Skill | Reviews | When |
|-------|---------|------|
| `reviewing-plans` | High-level architecture (high-level-plan.md) | After writing-plans |
| `domain-review` | Implementation tasks (tasks/*.md) | After task-breakdown |
| `cross-domain-review` | Integration between domains | After domain-review |

**Structure:**
```
skills/domain-review/
├── SKILL.md
├── frontend-critic.md        # Flat structure (consistent with existing skills)
├── backend-critic.md
├── testing-critic.md
├── infrastructure-critic.md
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
- Run `chunking-plans` on the complex task (recursive subdivision)
- Resume domain review with new smaller tasks
- Round counter resets for newly chunked tasks (they're new tasks)
- Original round counter continues for unchanged tasks

**Workflow:**
1. Read task document(s) and relevant master docs
2. Detect relevant domains, confirm with user
3. Dispatch selected critics in parallel
4. Aggregate findings by severity
5. If chunking needed → invoke chunking-plans → re-review new tasks
6. Loop until converged (max 3 rounds per task)
7. Handoff: "Domain review complete. Ready for cross-domain review?"

---

#### `task-breakdown`

Breaks a reviewed high-level plan into implementable task documents. This is the **initial breakdown** step. Distinct from `chunking-plans` which handles **recursive subdivision** of tasks that turn out to be too complex during domain review.

**Description (frontmatter):**
```yaml
description: >
  This skill should be used when the user asks to "break down the plan",
  "create task files", "split into implementable tasks", "generate task documents",
  or after reviewing-plans completes successfully. Converts high-level architecture
  into discrete task files ready for domain review.
```

**Distinction from chunking-plans:**
| Skill | Purpose | Input | Output |
|-------|---------|-------|--------|
| `task-breakdown` | Initial breakdown | high-level-plan.md | tasks/*.md |
| `chunking-plans` | Recursive subdivision | Existing task that's too complex | task/subtasks/*.md |

**Structure:**
```
skills/task-breakdown/
├── SKILL.md
├── breakdown-agent.md         # Flat structure
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
6. Handoff: "Task breakdown complete. Ready for domain review?"

---

#### `reviewing-plans`

Reviews **high-level architectural plans** for feasibility, completeness, and simplicity before breaking into tasks. This validates the overall approach before committing to detailed implementation planning.

**Description (frontmatter):**
```yaml
description: >
  This skill should be used when the user asks to "review the plan",
  "validate the architecture", "check if the plan is ready", "critique the design",
  or after writing-plans produces a high-level-plan.md file. Runs parallel critics
  to find issues before committing to implementation.
```

**Scope clarification:**
This reviews `high-level-plan.md` (architecture, approach, major components). It does NOT review:
- Individual task files (that's `domain-review`)
- Integration between domains (that's `cross-domain-review`)
- Actual code (that's code reviewers)

**Structure:**
```
skills/reviewing-plans/
├── SKILL.md
├── feasibility-critic.md      # Flat structure
├── completeness-critic.md
├── simplicity-critic.md
└── references/
    └── severity-guide.md
```

**Three parallel critics:**
- **Feasibility** — Will this architecture work? Correct assumptions? Dependencies available?
- **Completeness** — All requirements covered? Error handling? Edge cases?
- **Simplicity** — Over-engineered? YAGNI violations? Unnecessary complexity?

**Workflow:**
1. Read high-level plan from `/docs/plans/[feature]/high-level-plan.md`
2. Dispatch 3 critics in parallel (single message with 3 Task tool calls)
3. Aggregate findings by severity (CRITICAL → IMPORTANT → MINOR → NITPICK)
4. Present to user with recommended fixes
5. If fixes applied: Loop until converged (max 3 rounds)
6. Handoff: "Plan review complete. Ready to break into implementable tasks?"

---

#### `cross-domain-review`

Validates **integration points between domains** after individual domain reviews pass. Ensures frontend and backend align, APIs match expectations, and cross-cutting concerns are addressed.

**Description (frontmatter):**
```yaml
description: >
  This skill should be used when the user asks to "check integration points",
  "validate API contracts", "review frontend-backend alignment", "verify cross-domain dependencies",
  or after domain-review completes for all tasks. Ensures domains work together correctly.
```

**Scope clarification:**
This is the final review before implementation. It sees the complete picture:
- All task files from all domains
- The dependency map (00-overview.md)
- Interfaces between components

**Structure:**
```
skills/cross-domain-review/
├── SKILL.md
├── integration-critic.md      # Flat structure
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
6. Handoff: "Cross-domain review complete. Ready to map user journeys?" (or skip to implementation if no UI)

---

#### `user-journey-mapping`

Comprehensively maps user behaviors before test writing to ensure complete test coverage. Addresses the common problem of LLMs failing to generate all necessary test scenarios.

**Description (frontmatter):**
```yaml
description: >
  This skill should be used when the user asks to "map user journeys",
  "identify test scenarios", "plan e2e tests", "ensure test coverage",
  or after cross-domain-review completes for UI features. Systematically
  enumerates all user behaviors to derive comprehensive test plans.
```

**Why this exists:**
LLMs often miss edge cases, error states, and non-obvious user behaviors when generating tests ad-hoc. This skill forces systematic enumeration of all scenarios BEFORE test writing begins.

**Structure:**
```
skills/user-journey-mapping/
├── SKILL.md
├── journey-critic.md          # Reviews journey maps for gaps
├── references/
│   └── journey-categories.md  # Checklist of behavior categories
└── examples/
    └── login-journey.md       # Complete example journey map
```

**Journey map covers:**
- Happy paths — Primary success scenarios
- Variations — Different entry points, user states, data conditions
- Error states — Validation, network, server, permissions failures
- Edge cases — Limits, empty states, rapid actions, unicode, special chars
- Interruptions — Navigation, refresh, timeout, session expiry
- Accessibility — Keyboard navigation, screen reader, focus management

**Workflow:**
1. Read task docs to understand feature scope
2. Generate initial journey map using `references/journey-categories.md` as checklist
3. Dispatch Journey Critic to review for gaps
4. If gaps found → add to map → re-review
5. Loop until critic finds no significant gaps (max 3 rounds)
6. Output: `/docs/plans/[feature]/journeys/[component]-journeys.md`
7. Derive e2e test plan from journey map (added to task docs)
8. Handoff: "User journeys mapped. Ready to create worktree and implement?"

---

#### `lessons-learned`

Reviews completed implementations and proposes updates to master documents. Ensures institutional knowledge accumulates over time.

**Description (frontmatter):**
```yaml
description: >
  This skill should be used when the user asks to "capture lessons learned",
  "update master docs", "review what we learned", "document insights",
  or after implementation completes. Reviews both artifacts and agent-captured
  notes to propose master document updates.
```

**What are master docs?**
Master documents live in `/docs/master/` and contain accumulated project knowledge:
- `design-system.md` — UI patterns, component conventions
- `lessons-learned/frontend.md` — Frontend-specific learnings
- `lessons-learned/backend.md` — Backend-specific learnings
- `lessons-learned/testing.md` — Testing-specific learnings
- `lessons-learned/infrastructure.md` — Infrastructure-specific learnings
- `patterns/` — Reusable code patterns discovered over time

**Structure:**
```
skills/lessons-learned/
├── SKILL.md
├── learnings-reviewer.md      # Reviews artifacts and notes for learnings
└── references/
    └── update-categories.md   # Guide for categorizing learnings
```

**What it captures:**
- New patterns — Reusable approaches that emerged
- Difficult problems — Issues and solutions
- New tools/procedures — Utilities or workflows created
- Anti-patterns — What didn't work
- Corrections — Master doc content that was wrong

**Two sources of learnings:**
1. **Artifacts** — Inferred from code, plans, git diff/log
2. **Agent experience** — Captured in `learnings.md` during review/implementation

**Workflow:**
1. Read `/docs/plans/[feature]/learnings.md` (agent-captured notes)
2. Review artifacts (plan, tasks, git diff/log)
3. Categorize findings by master doc section
4. Present proposed updates with diffs
5. On approval, apply updates using LLM-driven merge (see Master Documents System)
6. Commit changes with context
7. Handoff: "Lessons captured. Ready to finish the branch?"

---

#### `frontend-design` (fork of `frontend-design:frontend-design`)

Custom frontend design skill that avoids generic UI patterns. Forked from the `frontend-design` plugin's skill, customized to integrate with devpowers master documents.

**Description (frontmatter):**
```yaml
description: >
  This skill should be used when the user asks to "design a component",
  "build the UI", "create the interface", "make it look good", "avoid generic design",
  or when implementing frontend tasks. Creates distinctive, non-generic UI
  that follows project design system.
```

**Fork source:** `frontend-design:frontend-design` plugin skill

**Why fork instead of using original:**
1. **Master doc integration** — Original doesn't know about `/docs/master/design-system.md`
2. **Learnings capture** — Need to append to learnings.md during implementation
3. **Domain review integration** — Frontend critic should reference these principles
4. **Workflow integration** — Must fit into devpowers handoff chain

**Contributing back:** If customizations prove generally useful, consider PRs to upstream plugin.

**Structure:**
```
skills/frontend-design/
├── SKILL.md
├── references/
│   └── design-principles.md   # Anti-patterns to avoid (generic AI look)
└── examples/
    └── component-patterns/    # Distinctive component examples
```

**Key customizations from original:**
- Reads `/docs/master/design-system.md` for project conventions
- Integrates with domain review (frontend critic references this skill's principles)
- Appends to learnings log when discovering what works

**Key behaviors:**
- Avoids generic "AI look" patterns
- Focuses on distinctive, purposeful design
- Maintains project-specific component patterns

---

#### `playwright-testing` (fork of `playwright-skill:playwright-skill`)

Custom e2e testing skill using journey maps. Forked from the `playwright-skill` plugin, customized to integrate with devpowers user journey mapping.

**Description (frontmatter):**
```yaml
description: >
  This skill should be used when the user asks to "write e2e tests",
  "implement tests from journeys", "set up Playwright", "test the user flows",
  or when implementing test tasks. Generates tests from user journey maps
  for comprehensive coverage.
```

**Fork source:** `playwright-skill:playwright-skill` plugin skill

**Why fork instead of using original:**
1. **Journey map integration** — Original generates tests ad-hoc; we derive from journey maps
2. **Master doc integration** — Need to read `/docs/master/lessons-learned/testing.md`
3. **Learnings capture** — Append to learnings.md when tests reveal unexpected behavior
4. **Domain review integration** — Testing critic should reference this skill

**Contributing back:** Journey map integration is devpowers-specific, but testing patterns could be contributed upstream.

**Structure:**
```
skills/playwright-testing/
├── SKILL.md
├── scripts/
│   └── scaffold-test.sh       # Creates test file structure
├── references/
│   └── testing-patterns.md    # Proven test patterns
└── examples/
    └── sample-tests/          # Complete test examples
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

### Skills to Keep (Clarified Roles)

#### `dispatching-parallel-agents`

**Keep.** Not redundant with domain-review — serves different purpose.

| Skill | Purpose | Use Case |
|-------|---------|----------|
| `domain-review` | Review tasks with domain experts | Planning phase |
| `dispatching-parallel-agents` | Parallel investigation of independent problems | Debugging, exploration |

**When to use:** Investigating multiple independent failures, exploring parallel hypotheses, running concurrent searches. NOT for sequential task execution.

---

### Skills to Delete

- `executing-plans` — Superseded by `subagent-driven-development` (same-session execution with review checkpoints)
- `receiving-code-review` — Merge into `subagent-driven-development` as post-implementation step

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

## Workflow State Tracking

Each feature maintains explicit state in `STATUS.md` for robust session resumption.

**Location:** `/docs/plans/[feature]/STATUS.md`

**Template:**
```markdown
# Workflow Status: [Feature Name]

## Current State
- **Stage:** [brainstorming | high-level-plan | reviewing-plans | task-breakdown | domain-review | cross-domain-review | user-journey-mapping | implementing | lessons-learned | finishing]
- **Last Updated:** [timestamp]
- **Last Action:** [brief description]

## Progress
- [x] Brainstorming complete
- [x] High-level plan written
- [ ] Plan review converged
- [ ] Tasks broken down
- [ ] Domain review converged
- [ ] Cross-domain review passed
- [ ] User journeys mapped
- [ ] Implementation complete
- [ ] Lessons captured
- [ ] Branch finished

## Blocking Issues
<!-- Any issues preventing progress -->

## Next Action
[What should happen next]
```

**When to update:**
- At every skill handoff
- When pausing or aborting
- On session resume (hooks update automatically)

---

## Hook-Based Automation

Hooks provide deterministic automation at key workflow points. These run automatically without consuming context window for their logic.

### Hook Capabilities and Limitations

Understanding what hooks can and cannot do is critical for correct design:

| Hook Event | Can Block? | Can Dispatch Agents? | Primary Use |
|------------|------------|---------------------|-------------|
| `SessionStart` | No | No | Inject context at session start |
| `UserPromptSubmit` | No (advisory only) | No | Add warnings/context to prompts |
| `PreToolUse` | **Yes** (allow/deny/ask) | No | Validate before tool execution |
| `PostToolUse` | No (already executed) | No | React to tool results |
| `SubagentStop` | **Yes** (approve/block) | No | Validate subagent completion |
| `Stop` | **Yes** (approve/block) | No | Validate session end |

**Key insight:** Hooks cannot dispatch new agents or initiate work. They can only:
1. Inject context via `systemMessage`
2. Block/allow operations (where supported)
3. Provide feedback to Claude

Workflow enforcement is therefore **advisory** (via context injection) rather than **mandatory** (via hard blocks).

---

### SessionStart Hook

**Purpose:** Detect workflow state and inject minimal context on session start.

**Behavior:**
1. Check for `/docs/plans/*/STATUS.md` files
2. If active feature found, inject: "Active feature: [name], Stage: [stage], Next: [action]"
3. Keep injection minimal (<100 words) to preserve context

**Implementation:** `hooks/session-start-workflow.sh`

---

### UserPromptSubmit Hook

**Purpose:** Provide workflow guidance when user prompts suggest out-of-sequence actions.

**Limitation:** Cannot hard-block prompts. Can only inject advisory context.

**Behavior:**
1. Parse user prompt for workflow keywords (implement, review, etc.)
2. Check current stage in STATUS.md
3. If action appears out of sequence: Inject warning via `systemMessage`
4. If action is valid: Optionally inject relevant master doc section

**Example warnings (advisory, not blocking):**
- User says "implement" but domain review not complete → systemMessage: "⚠️ Domain review not complete. Consider running domain-review first."
- User says "create PR" but lessons not captured → systemMessage: "⚠️ Lessons learned step skipped. Consider capturing learnings."

**Context efficiency:** Only inject master doc sections when directly relevant to the prompt.

**Implementation:** `hooks/workflow-advisor.py`

---

### PreToolUse Hook (Write validation)

**Purpose:** Validate file operations against workflow state. **Can block.**

**Matcher:** `Write` tool

**Behavior:**
1. Check if write path indicates implementation (e.g., `src/`, `lib/`)
2. Check STATUS.md for current workflow stage
3. If implementing before reviews complete: Return `permissionDecision: "ask"` with reason
4. Otherwise: Allow

**Example validation:**
- Writing to `src/` but domain review not complete → Ask user to confirm skipping review

**Implementation:** `hooks/write-validator.py`

---

### PostToolUse Hook (Write)

**Purpose:** Update workflow state and provide next-step guidance after task file creation.

**Limitation:** Cannot block — write has already completed. Reactive only.

**Matcher:** `Write` tool, path matches `*/tasks/*.md`

**Behavior:**
1. Detect task file written
2. Update STATUS.md
3. Return `systemMessage`: "Task file created. Domain review recommended as next step."

**Implementation:** `hooks/task-created.sh`

---

### SubagentStop Hook

**Purpose:** Validate implementation subagent completion and remind about code review.

**Limitation:** Cannot dispatch code review agent automatically. Can block completion or inject reminder.

**Behavior:**
1. Check if subagent was an implementation agent (by description or transcript)
2. Check if code review has occurred in this session
3. If no code review: Return `systemMessage`: "Implementation complete. Invoke code-reviewer agent before proceeding."
4. Optionally: Return `decision: "block"` with reason if code review is mandatory

**Implementation:** `hooks/subagent-review.py`

---

### Stop Hook

**Purpose:** Ensure learnings capture before session ends.

**Limitation:** Can block stopping, but cannot prompt user directly. Blocking forces Claude to continue.

**Behavior:**
1. Check if significant work was done (file changes in plan directory)
2. Check if learnings.md was updated this session
3. If no learnings captured after implementation work:
   - Return `decision: "block"` with `reason`: "Ask user about learnings before ending session"
   - Claude will then ask user about learnings
4. If learnings captured or no significant work: Allow stop

**Implementation:** `hooks/learnings-check.sh`

---

## Domain Reviewer Agents

In addition to skills, specialized agents provide focused expertise for reviews.

### Agent vs Skill

| Aspect | Skill | Agent |
|--------|-------|-------|
| Invocation | Loaded into context, followed by Claude | Dispatched via Task tool |
| Context | Full conversation context | Fresh context per invocation |
| Use case | Processes and workflows | Focused review/analysis roles |
| Output | Inline guidance | Single consolidated response |

### Domain Reviewer Agents

```
agents/
├── frontend-reviewer.md      # UI/UX, components, design system adherence
├── backend-reviewer.md       # API design, data flow, error handling
├── testing-reviewer.md       # Test coverage, edge cases, test quality
├── infrastructure-reviewer.md # Deployment, scaling, ops concerns
└── integration-reviewer.md   # Cross-domain interfaces, contracts
```

### Agent Structure (Required Fields)

All agents **must** include these frontmatter fields:
- `name` (required): Agent identifier
- `description` (required): Must include triggering conditions and `<example>` blocks
- `model` (optional): `inherit` (default), `sonnet`, `opus`, or `haiku`
- `color` (required): Visual identifier (`blue`, `cyan`, `green`, `yellow`, `magenta`, `red`)
- `tools` (optional): Restrict available tools (e.g., `["Read", "Grep", "Glob"]` for read-only)

**Example agent (frontend-reviewer.md):**
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
  <example>
  Context: PR includes CSS and component changes.
  user: "Review the styling changes in this PR"
  assistant: "Let me use the frontend-reviewer agent to evaluate the styling."
  <commentary>
  Styling changes require frontend expertise.
  </commentary>
  </example>
model: inherit
color: cyan
tools: ["Read", "Grep", "Glob", "WebFetch"]
---

# Frontend Reviewer

You are a senior frontend engineer reviewing implementation work.

## Your Focus
- Component structure and reusability
- Design system adherence (reference /docs/master/design-system.md)
- Accessibility compliance
- Performance considerations
- State management patterns

## Review Format
Provide findings in severity categories:
- CRITICAL: Must fix before merge
- IMPORTANT: Should fix before merge
- SUGGESTION: Consider for future

## Instructions
[Task-specific instructions injected here]
```

### Agent Color Assignments

| Agent | Color | Rationale |
|-------|-------|-----------|
| frontend-reviewer | cyan | Visual/UI association |
| backend-reviewer | green | Server/data association |
| testing-reviewer | yellow | Caution/validation association |
| infrastructure-reviewer | magenta | Operations/systems association |
| integration-reviewer | blue | Cross-cutting/coordination association |

**When to use agents vs domain-review skill:**
- `domain-review` skill: Orchestrates multiple critics during planning/review phases
- Individual reviewer agents: Deep-dive reviews during or after implementation

---

## Implementation Order

1. **Foundation:** Move `reviewing-plans` into proper skill structure
2. **Master docs:** Create `project-setup` with templates
3. **Core workflow:** Modify `writing-plans`, `chunking-plans`
4. **Review skills:** Create `domain-review`, `cross-domain-review`, `task-breakdown`
5. **Testing flow:** Create `user-journey-mapping`, fork `playwright-testing`
6. **Learning loop:** Create `lessons-learned`, update all prompts for learnings log
7. **Hooks:** Implement workflow automation hooks
8. **Reviewer agents:** Create domain reviewer agent files
9. **Polish:** Fork `frontend-design`, integrate master doc references everywhere

---

## Revision History

### v1 - 2026-01-16 - Initial Design

Initial design document created through brainstorming process.

### v2 - 2026-01-16 - First Review Round

**Issues Addressed:**
- [CRITICAL] Added loop termination rules (max 3 rounds)
- [CRITICAL] Added abort/rollback mechanism with archiving
- [IMPORTANT] Defined master doc conflict resolution (LLM-driven merge)
- [IMPORTANT] Fixed domain-review structure (prompts at root)
- [IMPORTANT] Added trigger conditions to fork skills
- [IMPORTANT] Added lightweight workflow path (scope tiers)

### v3 - 2026-01-16 - Second Review Round

**Issues Addressed:**
- [CRITICAL] Added agent failure handling (retry, graceful degradation)
- [CRITICAL] Clarified chunking-review loop integration
- [IMPORTANT] Added scope escalation mechanics
- [IMPORTANT] Defined master doc template contents
- [IMPORTANT] Added cross-domain bidirectional flow
- [IMPORTANT] Added learnings.md parallel append coordination
- [IMPORTANT] Added task-breakdown skill (distinct from chunking)

### v4 - 2026-01-16 - Hooks and Agents

**Issues Addressed:**
- Added workflow state tracking (STATUS.md)
- Added hook-based automation (5 hooks)
- Added domain reviewer agents (5 agents)
- Updated implementation order

### v5 - 2026-01-16 - Third Review Round (Claude Code Correctness & Skill Design)

**Issues Addressed:**
- [CRITICAL] Fixed hook architecture documentation — UserPromptSubmit cannot block (advisory only), PostToolUse is reactive, SubagentStop cannot dispatch agents
- [CRITICAL] Added PreToolUse hook for actual blocking capability
- [CRITICAL] Rewrote all skill trigger descriptions to third-person format with specific quoted phrases
- [CRITICAL] Added full reviewing-plans skill definition with scope clarification
- [CRITICAL] Clarified domain-review scope — reviews implementation tasks, not high-level plans
- [IMPORTANT] Added agent required fields (color, example blocks in descriptions)
- [IMPORTANT] Clarified task-breakdown vs chunking-plans distinction (initial breakdown vs recursive subdivision)
- [IMPORTANT] Added full cross-domain-review definition
- [IMPORTANT] Added fork skills differentiation rationale (why fork instead of using original)
- [IMPORTANT] Added full lessons-learned structure with master doc explanation
- [IMPORTANT] Kept dispatching-parallel-agents with clarified role (debugging/investigation, not redundant)
- [IMPORTANT] Added full user-journey-mapping definition with rationale
- [MINOR] Changed prompts/ directory to flat structure (consistent with existing skills)
- [MINOR] Added directory conventions (assets/, references/, scripts/)
- [MINOR] Added agent color assignments table

**Reviewer Notes:** Critical hook capability misunderstandings corrected. All skills now have proper third-person trigger descriptions with specific phrases. Review skill relationships clarified (reviewing-plans → task-breakdown → domain-review → cross-domain-review).
