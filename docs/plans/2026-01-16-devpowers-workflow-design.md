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

### Master Doc Merge Algorithm

**Input:**
- `existing_content`: Current master doc section content
- `proposed_addition`: New learning to integrate
- `source_context`: Where the learning came from (feature, task, review)

**Classification step:**
```
classify_change(existing, proposed):
    1. Extract key concepts from proposed addition
    2. Search existing content for related concepts
    3. Classify as one of:
       - NEW: No related concepts found
       - REFINEMENT: Related concept exists, proposed adds detail
       - CONTRADICTION: Related concept exists, proposed disagrees
       - SUPERSEDE: Related concept exists, proposed is clearly better
       - DUPLICATE: Proposed is already covered
```

**Merge strategy by classification:**

| Classification | Action | User Approval |
|----------------|--------|---------------|
| NEW | Append to appropriate section | Show diff only |
| REFINEMENT | Inline edit with additions | Show diff only |
| CONTRADICTION | Present both versions | Required |
| SUPERSEDE | Replace with changelog | Show diff + reason |
| DUPLICATE | Skip, note in learnings.md | None |

**Contradiction resolution prompt (when user approval required):**
```markdown
## Master Doc Conflict

**Section:** /docs/master/patterns/authentication.md

**Existing content:**
> Always use bcrypt with cost factor 10 for password hashing.

**Proposed update:**
> Use Argon2id for password hashing. bcrypt is outdated for new projects.

**Context:** Learned during auth-feature implementation after security review.

**Options:**
1. Keep existing (ignore new learning)
2. Accept proposed (replace existing)
3. Keep both with context (document the evolution)
4. Manual edit (I'll merge myself)
```

**Section targeting:**

Master docs have standard sections. Map learnings to sections:

| Learning Type | Target Section |
|---------------|----------------|
| API usage pattern | `patterns/` → relevant domain file |
| Library gotcha | `gotchas.md` |
| Architecture decision | `architecture.md` |
| Testing insight | `lessons-learned/testing.md` |
| Performance finding | `lessons-learned/performance.md` |
| Security concern | `lessons-learned/security.md` |
| Tooling tip | `lessons-learned/tooling.md` |

**Atomic update rule:**
Each master doc update is a single atomic commit. Never batch unrelated updates. Commit message format:
```
docs(master): [section] brief description

Context: [feature] during [phase]
Classification: [NEW|REFINEMENT|SUPERSEDE]
Previous: [if SUPERSEDE, what was replaced]
```

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

### Skills with Review Loops

All skills with review loops MUST follow the central review loop rules above. This table documents which skills have loops and any skill-specific variations:

| Skill | Loop Type | Max Rounds | Convergence Criteria | Special Rules |
|-------|-----------|------------|---------------------|---------------|
| `reviewing-plans` | Critic review | 3 | No CRITICAL/IMPORTANT | None - follows standard |
| `domain-review` | Multi-critic | 3 | No CRITICAL/IMPORTANT | Per-task chunking if >5 findings |
| `cross-domain-review` | Issue routing | 3 | No unresolved cross-domain | Max 2 round-trips per issue |
| `chunking-plans` | Recursive subdivision | 3 | Each task <500 words | Recurse depth max 3 levels |
| `user-journey-mapping` | Gap filling | 3 | All journeys have error/edge/a11y | — |
| `lessons-learned` | Approval | 3 | User approves master doc updates | Max 2 discussions per conflict |

**Notes:**
- `task-breakdown` does initial breakdown (no loop) — `chunking-plans` handles recursive subdivision
- `lessons-learned` "Max 2 discussions per conflict" means within the 3 total rounds, each individual conflict gets at most 2 back-and-forth discussions before escalating to user decision

**Skill implementers:** Reference these central rules in your skill's SKILL.md. Do NOT define custom loop limits unless approved and documented in this table.

**Example skill reference:**
```markdown
## Review Loop

This skill uses review loops. Follow the central review loop rules
defined in the devpowers workflow design:
- Maximum 3 rounds per review stage
- Convergence: No CRITICAL or IMPORTANT issues
- After 3 rounds: Present user with accept/escalate/abort options

See: Review Loop Rules in workflow design doc
```

### User Override for Critic Disagreement

When critics disagree on recommendations (not just severity), the user must decide. This section defines how to handle disagreements.

**Types of critic disagreement:**

| Disagreement Type | Example | Resolution |
|-------------------|---------|------------|
| **Severity** | Frontend says MINOR, Backend says CRITICAL | Take higher severity (automatic) |
| **Approach** | Frontend: "Use CSS Grid", Backend: "Use Flexbox" | Present both → user decides |
| **Necessity** | Testing: "Need 10 more tests", Infra: "Tests are sufficient" | Present both → user decides |
| **Conflicting fixes** | Two critics suggest incompatible changes | Present both → user decides |

**Presenting disagreements to user:**

```markdown
## Critic Disagreement

**Issue:** API response structure

**Frontend Critic says:**
> Use nested objects for cleaner component mapping
> Severity: IMPORTANT
> Reasoning: Reduces prop drilling, matches React patterns

**Backend Critic says:**
> Use flat objects for simpler serialization
> Severity: IMPORTANT
> Reasoning: Avoids deep cloning, matches REST conventions

**Your options:**
1. Follow Frontend recommendation (nested)
2. Follow Backend recommendation (flat)
3. Hybrid approach (describe)
4. Defer to domain owner ([tag if known])
5. Skip this for now, revisit during implementation
```

**Recording user override:**

After user decides, update STATUS.md:

```markdown
## User Overrides
- 2026-01-16: API structure: Chose flat objects (Backend) over nested (Frontend)
  - Reason: "Prioritizing API stability over frontend convenience"
  - Revisit if: Frontend complexity becomes unmanageable
```

**Override persistence:**

User overrides MUST be persisted because:
1. Future critics see the decision and don't re-raise the same issue
2. learnings.md can capture the rationale for master docs
3. If decision causes problems later, context is preserved

**Skill implementation:**

Skills handling disagreements should:
```markdown
1. Detect conflicting recommendations from critics
2. Group by issue (multiple critics may comment on same thing)
3. Present using the disagreement template above
4. Wait for user response (use AskUserQuestion if needed)
5. Record decision in STATUS.md User Overrides section
6. Optionally append to learnings.md if decision has broader implications
7. Continue review with user's decision as constraint
```

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

When scope changes during work (task turns out bigger than expected):

**Detection triggers by tier:**

| Current Tier | Escalation Trigger | Escalate To |
|--------------|-------------------|-------------|
| **Trivial** | >10 lines changed, or touches >2 files, or introduces new behavior | Small |
| **Trivial** | Requires understanding context, affects other features | Medium |
| **Small** | Task breakdown yields >5 tasks | Medium |
| **Small** | Architectural changes identified | Large |
| **Medium** | >10 tasks, or cross-cutting concerns | Large |

### Trivial Scope Escalation Path

Trivial scope has special handling because it skips all planning. Escalation can happen mid-implementation.

**Trivial → Small/Medium triggers:**

During "direct implementation" of a Trivial task, escalate if:
1. **Complexity discovery:** "This typo fix requires changing the API contract"
2. **Scope creep:** User adds requirements while you're working
3. **Dependency chain:** Fix in A requires changes in B, C, D
4. **Test requirements:** Change needs new tests beyond simple verification
5. **Risk realization:** Change could break existing functionality

**Trivial escalation process:**

```
1. Pause implementation
2. Save any partial work (commit with "WIP: [description]")
3. Present escalation:

   "This started as Trivial (single-line change) but has grown:
   - Originally: Fix typo in error message
   - Discovery: Error message is generated from template, template is wrong,
     fix affects 12 other messages

   Recommend escalating to: [Small|Medium]

   Options:
   1. Escalate → Start proper planning
   2. Continue as Trivial → Accept risk, no review
   3. Abort → Revert partial work"

4. If escalate:
   - Create /docs/plans/[feature]/ structure
   - Document what was discovered
   - Begin at brainstorming (but can be brief given context)
```

**Preserving Trivial work:**

If escalating from Trivial with partial implementation:
- Commit partial work as WIP
- Reference in new plan: "Partial implementation in commit [hash]"
- Plan can build on existing work rather than discard

### Standard Escalation Process (Small → Medium → Large)

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

### Mid-Skill Abort Handling

When a skill is interrupted mid-execution (user sends "stop", "cancel", Ctrl+C, or session crashes):

**Skill-level checkpointing:**

Each skill with multi-step workflows must checkpoint after significant progress:

```markdown
## Checkpoint Protocol

1. After completing a discrete unit of work, update STATUS.md:
   ```
   Stage: domain-review
   Sub-State:
     Current-Task: 03-api-endpoints
     Critics-Completed: [frontend, backend]
     Critics-Pending: [testing, infrastructure]
   ```

2. If interrupted, the skill can resume from last checkpoint
```

**Resumption detection:**

Skills check for interrupted state on load:

```
on_skill_start():
    1. Read STATUS.md
    2. If Sub-State section exists:
       - Parse completed/pending items
       - Prompt: "Found interrupted [skill] at [checkpoint]. Resume or restart?"
    3. If user chooses resume:
       - Skip completed items
       - Continue from first pending
    4. If user chooses restart:
       - Clear Sub-State section
       - Start fresh
```

**Per-skill checkpoint points:**

| Skill | Checkpoint After | Resume From |
|-------|-----------------|-------------|
| `reviewing-plans` | Each critic completes | First incomplete critic |
| `domain-review` | Each task reviewed | First unreviewed task |
| `cross-domain-review` | Each routing resolved | First unresolved routing |
| `task-breakdown` | Each task file written | First missing task file |
| `user-journey-mapping` | Each journey documented | First incomplete journey |
| `lessons-learned` | Each master doc updated | First pending update |
| `subagent-driven-development` | Each task + review | Next task number |

**Partial output preservation:**

When interrupted, preserve:
- ✅ Completed review findings (even if aggregation pending)
- ✅ Written task files (even if index incomplete)
- ✅ learnings.md entries (even if master doc sync pending)
- ❌ Don't preserve partial file writes (atomic writes only)

**Session crash recovery:**

If Claude session crashes (vs. user interrupt):
1. STATUS.md persists on disk
2. Next session detects `Stage:` without `## Completed` marker
3. Prompts: "Previous session ended unexpectedly during [skill]. Resume?"
4. Recovery reads checkpoint, continues from last saved state

**STATUS.md corruption handling:**

STATUS.md can become corrupted (malformed YAML, invalid stage, conflicting state). Detection and recovery:

```
on_status_read():
    1. Attempt to parse STATUS.md
    2. If parse fails (malformed):
       - Backup corrupted file: STATUS.md.corrupted.[timestamp]
       - Infer state from artifacts:
         * /tasks/ exists → stage ≥ task-breakdown
         * high-level-plan.md exists → stage ≥ high-level-plan
         * learnings.md modified recently → stage = implementing
       - Create fresh STATUS.md with inferred state
       - Prompt: "STATUS.md was corrupted. Inferred stage: [stage]. Correct?"
    3. If stage is invalid (not in valid transitions):
       - Prompt: "STATUS.md shows invalid stage '[stage]'. Reset to [inferred]?"
    4. If conflicting state (e.g., stage=implementing but no tasks/):
       - Prompt: "STATUS.md shows [stage] but expected artifacts missing. Options:"
         * "Reset to [earlier-stage]"
         * "Create missing artifacts"
         * "Manual inspection"
```

**Prevention:**
- Atomic writes: Write to STATUS.md.tmp, then rename
- Validate before write: Check stage is valid before persisting
- Backup on change: Copy to STATUS.md.bak before significant updates

## Skills Inventory

### New Skills

#### `using-devpowers`

Entry-point skill that teaches Claude how to use the devpowers workflow. Analogous to `using-superpowers` in the original superpowers plugin.

**Description (frontmatter):**
```yaml
description: >
  This skill should be used when the user asks to "start a feature",
  "use devpowers", "plan a new feature", "begin development", "work on [feature]",
  or when starting any non-trivial development task. Provides workflow overview,
  scope detection, and routes to appropriate starting skill.
```

**Purpose:**
- Detect if project has devpowers set up (check for `/docs/master/`)
- Assess scope of requested work (trivial/small/medium/large)
- Route to appropriate workflow entry point
- Provide workflow state if resuming existing feature

**Workflow:**
```
1. Check /docs/master/ exists
   - If not: hand off to project-setup
   - If yes: continue

2. Check /docs/plans/ for existing features
   - If active feature found: offer to resume or start new
   - If no features: start fresh

3. Assess scope of request (ask user if unclear):
   - Trivial: Direct implementation, no planning
   - Small: brainstorming → plan → implement
   - Medium/Large: Full workflow with reviews

4. Hand off to appropriate skill:
   - project-setup (if /docs/master/ missing)
   - brainstorming (for new features)
   - Resume point (for existing features)
```

**Key instruction in SKILL.md:**
> "If you think there is even a 1% chance another devpowers skill applies,
> invoke it. Skills tell you HOW to do things - don't skip them."

---

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
Not all critics run for every task. Detect relevant domains from task content using these heuristics:

**Domain detection rules (any 2+ signals triggers domain):**

| Domain | File Path Signals | Keyword Signals | Import Signals |
|--------|------------------|-----------------|----------------|
| **Frontend** | `src/components/`, `src/ui/`, `*.css`, `*.scss`, `*.tsx` | "component", "render", "useState", "CSS", "styled", "UI", "layout", "responsive" | react, vue, svelte, tailwind, styled-components |
| **Backend** | `src/api/`, `src/server/`, `routes/`, `controllers/`, `*.py` | "endpoint", "database", "query", "middleware", "authentication", "API", "REST", "GraphQL" | express, fastify, django, flask, prisma, typeorm |
| **Testing** | (always runs) | - | - |
| **Infrastructure** | `Dockerfile`, `*.yaml`, `terraform/`, `.github/`, `deploy/` | "deployment", "CI/CD", "environment", "scaling", "container", "kubernetes", "AWS", "monitoring" | docker, kubernetes, terraform, github-actions |

**Detection algorithm:**
```
1. Parse task "Files to Create/Modify" section
2. Match file paths against domain patterns
3. Scan task content for keyword signals
4. Check any code snippets for import signals
5. Score each domain by signal count
6. Trigger domain if score >= 2
7. Always include Testing (maintains test plan)
```

**Multi-domain tasks:**
- Task can trigger multiple domains (e.g., full-stack feature)
- All triggered domains review in parallel
- Each domain critic only reviews aspects in their scope

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

**Task document template (`NN-task-name.md`):**
```markdown
# Task NN: [Task Name]

> **Feature:** [feature] | **Depends on:** [task numbers] | **Blocks:** [task numbers]

## Goal
[One sentence describing what this task accomplishes]

## Context
[2-3 sentences explaining where this fits in the feature and why it matters]

## Files to Create/Modify
- `path/to/file.ts` — [what changes]
- `path/to/other.ts` — [what changes]

## Implementation Steps
1. [Step 1 with enough detail to implement]
2. [Step 2]
3. [Step 3]

## Acceptance Criteria
- [ ] [Criterion 1 — specific, testable]
- [ ] [Criterion 2]
- [ ] [Criterion 3]

## Dependencies
- [ ] Task [N] complete: [brief description]
- [ ] [External service/API] available

## Unit Test Plan
<!-- Testing critic populates this during domain review -->
- [ ] [Function] - [test case description]
- [ ] [Function] - [test case description]

## E2E Test Plan
<!-- From user journey mapping, if applicable -->
- [ ] [Journey] - [test case description]

## Notes
<!-- Implementation notes, gotchas, references -->
```

**00-overview.md template:**
```markdown
# Task Overview: [Feature Name]

## Task Map
```
01-setup ─────► 02-models ─────► 03-api ─────────┐
                    │                            │
                    └────► 04-validation ────────┤
                                                 ▼
                                          05-integration
                                                 │
                                                 ▼
                    06-ui ◄─────────────── 07-state
```

## Task Index
| # | Task | Dependencies | Status |
|---|------|--------------|--------|
| 01 | Setup project structure | - | ⬜ |
| 02 | Define data models | 01 | ⬜ |
| 03 | Implement API endpoints | 02 | ⬜ |
| 04 | Add validation | 02 | ⬜ |
| 05 | Integration layer | 03, 04 | ⬜ |
| 06 | UI components | 07 | ⬜ |
| 07 | State management | 05 | ⬜ |

## Execution Order
1. **Sequential:** 01 → 02 → {03, 04} → 05 → 07 → 06
2. **Parallel opportunities:** 03 and 04 can run in parallel after 02

## Status Legend
- ⬜ Not started
- 🔄 In progress
- ✅ Complete
- ⏸️ Blocked
```

**Workflow:**
1. Read approved high-level plan
2. Identify logical task boundaries (by component, by layer, by feature slice)
3. Create task files using template above
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

**Routing protocol:**
Cross-domain critic outputs issues with routing information:

```json
{
  "issues": [
    {
      "id": "API_001",
      "severity": "CRITICAL",
      "description": "Frontend expects user.fullName but backend returns user.firstName + user.lastName",
      "affected_tasks": ["03-api-endpoints", "06-user-profile-ui"]
    }
  ],
  "routing": [
    {
      "domain": "backend",
      "issue_id": "API_001",
      "task": "03-api-endpoints",
      "context": "API response shape doesn't match frontend expectations",
      "requested_fix": "Add computed fullName field to user response, or document that frontend must concatenate"
    }
  ]
}
```

**Domain critic receives routing request:**
```json
{
  "routing_request": {
    "issue_id": "API_001",
    "context": "...",
    "requested_fix": "..."
  },
  "task_content": "[full task document]",
  "master_docs": "[relevant sections]"
}
```

**Domain critic returns fix:**
```json
{
  "issue_id": "API_001",
  "fix_applied": true,
  "task_updates": {
    "section": "Implementation Steps",
    "change": "Added step 4: Add fullName computed property to user serializer"
  },
  "verification_note": "Frontend can now use user.fullName directly"
}
```

**Round-trip counting:**
- One round-trip = cross-domain → domain → cross-domain (verify)
- Cross-domain's 3 rounds are separate from round-trips
- After 2 failed round-trips (domain fix doesn't resolve): Escalate to user

**Workflow:**
1. Read all task documents + 00-overview.md (dependency map)
2. Dispatch integration critic that sees everything
3. Findings focus on interfaces between domains
4. If domain-specific fix needed → route using protocol above → re-verify
5. Loop if CRITICAL/IMPORTANT issues found (max 3 rounds, max 2 round-trips per issue)
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

### Fork Skills Implementation Guide

**Step-by-step process for creating fork skills:**

1. **Locate the source skill:**
   ```bash
   # Find the original skill in installed plugins
   ls ~/.claude/plugins/cache/*/skills/
   # Or search by name
   find ~/.claude -name "SKILL.md" -exec grep -l "frontend-design" {} \;
   ```

2. **Create fork structure:**
   ```bash
   mkdir -p skills/frontend-design/{references,examples,scripts}
   ```

3. **Copy vs. create fresh:**
   - **Copy:** `references/` directory (patterns, documentation)
   - **Copy:** `examples/` directory (working examples)
   - **Create fresh:** `SKILL.md` with devpowers-specific instructions
   - **Create fresh:** Any new scripts for integration

4. **Customize SKILL.md:**
   ```markdown
   ---
   name: frontend-design
   description: This skill should be used when... [devpowers-specific triggers]
   version: 1.0.0
   forked_from: frontend-design:frontend-design v2.3.0
   ---

   # Frontend Design (devpowers fork)

   **Fork notes:** Customized from frontend-design plugin v2.3.0.
   Key changes: [list what changed and why]

   [Rest of skill content...]
   ```

5. **Add integration points:**
   ```markdown
   ## Master Document Integration

   Before designing, read:
   - `/docs/master/design-system.md` — Project design system
   - `/docs/master/lessons-learned/frontend.md` — Past learnings

   ## Learnings Capture

   After implementing, append to learnings.md:
   - What patterns worked well
   - What patterns to avoid next time
   - Any design system updates needed
   ```

6. **Verify fork works:**
   ```bash
   # Start Claude Code with plugin dir
   cc --plugin-dir /path/to/devpowers

   # Test trigger phrases
   # "design a component", "build the UI", etc.
   ```

**Maintaining forks:**

| Activity | Frequency | Process |
|----------|-----------|---------|
| Check upstream | Monthly | Review upstream changelog for updates |
| Pull improvements | As needed | Manually merge useful upstream changes |
| Contribute back | When stable | PR generic improvements to upstream |

**Fork vs. wrapper decision tree:**

```
Is the customization...
├── Project-specific data (master docs)? → Fork (upstream doesn't have context)
├── Workflow integration? → Fork (devpowers-specific handoffs)
├── Bug fix? → PR upstream, use original
├── Feature enhancement? → PR upstream, use original
└── Style preference? → Don't fork, accept original
```

### SKILL.md Update Requirements

When modifying existing skills (rather than forking), update the SKILL.md file with:

1. **Version bump:** Increment version in frontmatter
2. **Description update:** Add devpowers-specific trigger phrases if changed
3. **Changelog section:** Add to bottom of SKILL.md:
   ```markdown
   ## Changelog

   ### v1.1.0 (devpowers)
   - Added master document integration
   - Added learnings capture handoff
   - Modified output path to `/docs/plans/[feature]/`
   ```

4. **Fork notation:** If skill is a fork, add to frontmatter:
   ```yaml
   forked_from: plugin-name:skill-name v1.0.0
   ```
   **Note:** `forked_from` is a **devpowers convention**, not an official SKILL.md field. It helps track fork provenance but may be ignored by Claude Code.

5. **Integration section:** Add to skill body:
   ```markdown
   ## Devpowers Integration

   **Reads from:**
   - `/docs/master/` — Project knowledge
   - `learnings.md` — Past lessons

   **Writes to:**
   - `learnings.md` — New insights (append only)

   **Hands off to:**
   - `[next-skill]` — [When/why]
   ```

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

Handles **recursive subdivision** of existing tasks when domain review finds them too complex. Distinct from `task-breakdown` (initial breakdown).

**Recursion rules:**
- **Maximum depth:** 3 levels (task → subtask → sub-subtask)
- **If deeper needed:** Reconsider task boundaries, likely architectural issue
- **Naming convention:** `tasks/03-auth/subtasks/01-validation/subtasks/01-email.md`

**Path structure:**
```
docs/plans/[feature]/tasks/
├── 00-overview.md
├── 01-setup.md
├── 02-models.md
├── 03-auth/                    # Task too complex → chunked
│   ├── 03-auth.md              # Original task, updated with "See subtasks"
│   └── subtasks/
│       ├── 00-overview.md      # Subtask dependency map
│       ├── 01-validation.md
│       ├── 02-hashing.md
│       └── 03-session/         # Subtask too complex → chunked again
│           ├── 03-session.md
│           └── subtasks/
│               ├── 00-overview.md
│               ├── 01-create.md
│               └── 02-refresh.md
```

**00-overview.md updates:**
- Parent `00-overview.md` shows chunked task as expandable
- Each subtask folder has its own `00-overview.md`
- Status rolls up: subtask complete only when all sub-subtasks complete

**Domain review integration:**
- When critic flags "task too complex" → pause domain review
- Invoke chunking-plans → creates subtask folder
- Resume domain review on NEW subtasks (round counter resets for new tasks)
- Original task marked as "container" (not directly implemented)

**Complexity signals:**
- Task description exceeds 500 words
- More than 10 implementation steps
- Multiple unrelated acceptance criteria
- Critic explicitly flags complexity

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

### Migration Paths for Deleted Skills

#### Migrating from `executing-plans`

**Old workflow:**
```
User: /executing-plans
→ Opens parallel session
→ Executes plan in separate context
→ No review between tasks
```

**New workflow:**
```
User: "Execute this plan with task-by-task review"
→ Invokes subagent-driven-development
→ Fresh subagent per task (context isolation)
→ Code review after each task
→ Same session, parent orchestrates
```

**Breaking changes:**
| Old Behavior | New Behavior | Migration |
|--------------|--------------|-----------|
| Separate Claude session | Same session with subagents | No action needed |
| No inter-task review | Mandatory code review per task | Accept or configure |
| Manual checkpoint saves | Automatic git commits per task | Ensure git configured |

**Trigger phrase changes:**
- Old: `/executing-plans` or "execute the plan in a new session"
- New: "execute with subagent-driven development" or "implement with task-by-task review"

#### Migrating from `receiving-code-review`

**Old workflow:**
```
User: Receives code review feedback
User: /receiving-code-review
→ Structured process to handle feedback
→ Separate skill invocation
```

**New workflow:**
```
User: Completes task
→ subagent-driven-development auto-invokes code-reviewer
→ Review findings integrated into task completion
→ Learnings auto-captured
```

**Breaking changes:**
| Old Behavior | New Behavior | Migration |
|--------------|--------------|-----------|
| User explicitly invokes | Auto-invoked after each task | Happens automatically |
| Standalone skill | Integrated into subagent-driven | No separate invocation |
| Manual learnings capture | Auto-appends to learnings.md | Configure learnings path |

**Where the functionality lives now:**
The code review handling logic from `receiving-code-review` is now embedded in:
1. `subagent-driven-development` — Step 4 invokes code-reviewer
2. SubagentStop hook — Validates review happened
3. `lessons-learned` skill — Captures review findings

**If you need standalone code review handling:**
Use the `code-reviewer` agent directly via Task tool, but prefer letting `subagent-driven-development` orchestrate it.

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

When multiple critics run in parallel (e.g., domain review), a race condition can occur if they try to write to the same file simultaneously. Solution: **write to separate files, then aggregate**.

**Write phase (parallel, no conflicts):**

Each critic writes to a separate temp file:
```
/docs/plans/[feature]/learnings-temp/
├── domain-review-frontend.md
├── domain-review-backend.md
├── domain-review-testing.md
└── domain-review-infrastructure.md
```

Critic prompt includes:
```
Write your findings to: /docs/plans/[feature]/learnings-temp/domain-review-[your-domain].md
Do NOT write to learnings.md directly.
```

**Aggregate phase (sequential, after all critics complete):**

Orchestrator merges temp files into learnings.md:

```python
# After all critics complete
def aggregate_learnings(feature_path, phase_name):
    temp_dir = f"{feature_path}/learnings-temp"
    learnings_path = f"{feature_path}/learnings.md"

    # Read all temp files
    findings = []
    for file in glob(f"{temp_dir}/{phase_name}-*.md"):
        findings.append({
            "domain": extract_domain(file),
            "content": read(file)
        })

    # Append to learnings.md under phase section
    append_to_section(learnings_path, phase_name, findings)

    # Cleanup temp files
    for file in glob(f"{temp_dir}/{phase_name}-*.md"):
        delete(file)
```

**Final learnings.md structure:**
```markdown
## Domain Review Phase

### Frontend Critic Findings
[aggregated from learnings-temp/domain-review-frontend.md]

### Backend Critic Findings
[aggregated from learnings-temp/domain-review-backend.md]

### Testing Critic Findings
[aggregated from learnings-temp/domain-review-testing.md]

### Infrastructure Critic Findings
[aggregated from learnings-temp/domain-review-infrastructure.md]
```

**Why this solves the race condition:**
- Critics write to different files → no write conflicts
- Aggregation is sequential, run by orchestrator after critics complete
- Temp files are cleaned up after merge
- If crash occurs, temp files preserve critic output for manual recovery

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

| Skill | Next Step | Notes |
|-------|-----------|-------|
| `using-devpowers` | Routes to `project-setup` or `brainstorming` | Entry point |
| `project-setup` | "Ready to start brainstorming a feature?" | Invokes `brainstorming` |
| `brainstorming` | "Ready to write the high-level plan?" | Invokes `writing-plans` |
| `writing-plans` | "Ready for plan review?" | Invokes `reviewing-plans` |
| `reviewing-plans` | "Ready to break into implementable tasks?" | Invokes `task-breakdown` |
| `task-breakdown` | "Ready for domain review?" | Creates tasks/*.md |
| `domain-review` | "Ready for cross-domain review?" | May invoke `chunking-plans` if task too complex |
| `cross-domain-review` | "Ready to map user journeys? (skip if no UI)" | |
| `user-journey-mapping` | "Ready to create worktree?" | Or skip with "(s)kip" |
| `using-git-worktrees` | "Worktree ready. Start implementation?" | |
| `subagent-driven-development` | "Ready to capture lessons learned?" | |
| `lessons-learned` | "Ready to finish the branch?" | |
| `finishing-a-development-branch` | "[Complete summary]" | |

**Note on chunking-plans:** This skill is NOT in the main handoff chain. It's invoked FROM `domain-review` when a task is flagged as too complex, then control returns to `domain-review` to review the newly chunked subtasks.

---

## Workflow State Tracking

Each feature maintains explicit state in `STATUS.md` for robust session resumption.

**Location:** `/docs/plans/[feature]/STATUS.md`

### State Machine

Valid workflow transitions (arrows show allowed next states):

```
                                    ┌─────────────────────────────────────┐
                                    │         SCOPE TIERS                 │
                                    │  Trivial: direct → implementing     │
                                    │  Small: brainstorming → plan → impl │
                                    │  Medium/Large: full workflow        │
                                    └─────────────────────────────────────┘

brainstorming ─────► high-level-plan ─────► reviewing-plans ◄─────┐
                                                   │               │
                                                   │ (loop max 3)  │
                                                   ▼               │
                                           ┌───────────────┐       │
                                           │ issues found? │───────┘
                                           └───────────────┘
                                                   │ no issues
                                                   ▼
                                           task-breakdown ─────► domain-review ◄──────┐
                                                                       │               │
                                                    ┌──────────────────┤               │
                                                    │                  │ (loop max 3)  │
                                                    ▼                  ▼               │
                                           ┌──────────────┐    ┌───────────────┐      │
                                           │ too complex? │    │ issues found? │──────┘
                                           └──────────────┘    └───────────────┘
                                                    │                  │ no issues
                                                    ▼                  ▼
                                           chunking-plans      cross-domain-review ◄──┐
                                           (loops back to            │                │
                                            domain-review)           │ (loop max 3)   │
                                                                     ▼                │
                                                             ┌───────────────┐        │
                                                             │ issues found? │────────┘
                                                             └───────────────┘
                                                                     │ no issues
                                                                     ▼
                                                             user-journey-mapping
                                                             (skip if no UI)
                                                                     │
                                                                     ▼
                                                             using-git-worktrees
                                                                     │
                                                                     ▼
                                                             implementing ◄───────────┐
                                                                     │                │
                                                                     │ (per task)     │
                                                                     ▼                │
                                                             ┌───────────────┐        │
                                                             │ more tasks?   │────────┘
                                                             └───────────────┘
                                                                     │ all complete
                                                                     ▼
                                                             lessons-learned
                                                                     │
                                                                     ▼
                                                             finishing
```

### Valid Transitions Table

| From Stage | Valid Next Stages | Trigger |
|------------|-------------------|---------|
| `(none)` | `project-setup`, `brainstorming` | New project / existing project |
| `project-setup` | `brainstorming` | Master docs created |
| `brainstorming` | `high-level-plan` | User ready to write plan |
| `high-level-plan` | `reviewing-plans` | Plan written |
| `reviewing-plans` | `reviewing-plans`, `task-breakdown` | Issues found / converged |
| `task-breakdown` | `domain-review` | Tasks created |
| `domain-review` | `domain-review`, `cross-domain-review` | Issues found / converged |
| `cross-domain-review` | `cross-domain-review`, `domain-review`, `user-journey-mapping`, `worktree` | Issues / routing / converged / skip |
| `user-journey-mapping` | `user-journey-mapping`, `worktree` | Issues found / converged |
| `worktree` | `implementing` | Worktree created |
| `implementing` | `implementing`, `lessons-learned` | More tasks / all complete |
| `lessons-learned` | `finishing` | Learnings captured |
| `finishing` | (terminal) | Branch merged/closed |

**Stage vs Skill naming clarification:**

Some stages have different names than the skills that execute them:

| Stage Name | Skill Used | Output |
|------------|------------|--------|
| `project-setup` | `project-setup` | `/docs/master/` directory |
| `brainstorming` | `brainstorming` | `/docs/plans/[feature]/` directory |
| `high-level-plan` | `writing-plans` | `high-level-plan.md` |
| `reviewing-plans` | `reviewing-plans` | Updated `high-level-plan.md` |
| `task-breakdown` | `task-breakdown` | `tasks/*.md` files |
| `worktree` | `using-git-worktrees` | Git worktree created |
| `implementing` | `subagent-driven-development` | Code changes |
| `lessons-learned` | `lessons-learned` | Updated `learnings.md` |

The stage name reflects the workflow state; the skill name reflects the action.

**Skip transitions (scope-dependent):**
- Small scope: `brainstorming` → `high-level-plan` → `implementing` (skip reviews)
- Medium scope: Skip `user-journey-mapping` if no UI
- Any scope: `user-journey-mapping` can be skipped with explicit user choice

### Parallel Feature Management

When multiple features are in development, use a central tracker:

**Location:** `/docs/plans/ACTIVE.md`

```markdown
# Active Features

## Current Feature
feature-name-here

## All Features
| Feature | Stage | Last Updated | Status |
|---------|-------|--------------|--------|
| auth-system | implementing | 2026-01-16 | active |
| dashboard | domain-review | 2026-01-15 | paused |

## Switch Feature
To switch: "Switch to [feature]"
```

**SessionStart behavior with multiple features:**
1. Read `/docs/plans/ACTIVE.md` for current feature
2. If no ACTIVE.md but multiple STATUS.md files exist: List all and ask which to resume
3. If single feature: Use that one automatically

### STATUS.md Template (Expanded)

```markdown
# Workflow Status: [Feature Name]

## Current State
- **Stage:** [see valid stages above]
- **Scope:** [trivial | small | medium | large]
- **Last Updated:** [ISO timestamp]
- **Last Action:** [brief description]

## Sub-State (for review loops)
- **Review Round:** [1 | 2 | 3] of 3
- **Critics Completed:** [e.g., "frontend, backend" or "2/4"]
- **Pending Critics:** [e.g., "testing, infrastructure"]

## Progress
- [x] Brainstorming complete
- [x] High-level plan written
- [ ] Plan review converged (round _/3)
- [ ] Tasks broken down
- [ ] Domain review converged (round _/3)
- [ ] Cross-domain review passed (round _/3)
- [ ] User journeys mapped [skipped: no UI | user choice]
- [ ] Worktree created
- [ ] Implementation complete (_/_ tasks)
- [ ] Lessons captured
- [ ] Branch finished

## Blocking Issues
<!-- Any issues preventing progress -->

## User Overrides
<!-- Decisions where user overrode critic recommendations -->
- [date]: Proceeded despite [critic] concerns about [issue]

## Next Action
[What should happen next]

## Recovery Info
- **Partial Progress:** [description of what's saved if interrupted]
- **Resume Command:** [suggested skill invocation]
```

**When to update:**
- At every skill handoff
- When pausing or aborting
- On session resume (hooks update automatically)
- After each review round (update sub-state)
- When user makes override decisions

---

## Hook-Based Automation

Hooks provide deterministic automation at key workflow points. These run automatically without consuming context window for their logic.

### Hook Capabilities and Limitations

Understanding what hooks can and cannot do is critical for correct design:

| Hook Event | Can Block? | Can Dispatch Agents? | Primary Use |
|------------|------------|---------------------|-------------|
| `SessionStart` | No | No | Inject context at session start |
| `UserPromptSubmit` | **Yes** (decision: block) | No | Add context; block if needed |
| `PreToolUse` | **Yes** (allow/deny/ask) | No | Validate before tool execution |
| `PostToolUse` | No (already executed) | No | React to tool results |
| `SubagentStop` | **Yes** (block/omit) | No | Validate subagent completion |
| `Stop` | **Yes** (block/omit) | No | Validate session end |

**Decision values by hook type:**
- PreToolUse: `allow`, `deny`, `ask` (permission decision)
- Stop/SubagentStop: `block` or omit/undefined (to allow)

**Key insight:** Hooks cannot dispatch new agents or initiate work. They can only:
1. Inject context via `systemMessage`
2. Block/allow operations (where supported)
3. Provide feedback to Claude

Workflow enforcement in devpowers uses **advisory** mode (context injection) rather than hard blocks where possible, to avoid frustrating users.

### hooks.json File Structure

**Location:** Plugin hooks go in `hooks/hooks.json` at plugin root.

**Required wrapper structure for plugin hooks:**
```json
{
  "description": "Optional description of plugin hooks",
  "hooks": {
    "SessionStart": [...],
    "UserPromptSubmit": [...],
    "PreToolUse": [...],
    "PostToolUse": [...],
    "SubagentStop": [...],
    "Stop": [...]
  }
}
```

**Important:** The `hooks` wrapper is required for plugin hooks. The events (SessionStart, PreToolUse, etc.) nest inside this wrapper. This differs from user settings format which has events at the top level.

**Hook timeout defaults:**
- Command hooks: 60 seconds (per official docs)
- Override with `"timeout": <ms>` in hook config

**Hook file locations:**

| Location | Purpose | Format |
|----------|---------|--------|
| Plugin: `hooks/hooks.json` | Plugin-provided hooks | Wrapper format (with `"hooks": {...}`) |
| User: `~/.claude/settings.json` | User's global hooks | Direct format (events at top level) |
| Project: `.claude/settings.local.json` | Project-specific hooks | Direct format (events at top level) |

**For devpowers plugin:** All hooks go in `hooks/hooks.json` using the wrapper format. These merge with any user/project hooks and run in parallel.

---

### SessionStart Hook

**Purpose:** Detect workflow state and inject minimal context on session start.

**Input (stdin JSON):**
```json
{
  "hook_event_name": "SessionStart",
  "session_id": "abc123",
  "transcript_path": "/path/to/.claude/projects/.../transcript.jsonl",
  "cwd": "/path/to/project",
  "source": "startup"
}
```

**Environment variables:**
- `CLAUDE_PROJECT_DIR` — Project root directory
- `CLAUDE_ENV_FILE` — File to write persistent env vars to

**Implementation logic:**
```bash
1. Find active feature:
   - Check /docs/plans/ACTIVE.md for current feature
   - If not found, glob /docs/plans/*/STATUS.md
   - If multiple, list all for user selection

2. Parse STATUS.md:
   - Extract: Stage, Scope, Last Action, Next Action

3. Build minimal context (<100 words)
```

**Output (stdout):**

SessionStart hooks use `hookSpecificOutput.additionalContext` to inject context:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "📍 Active: auth-feature | Stage: domain-review (round 2/3) | Next: Complete testing critic review"
  }
}
```

**Note:** `additionalContext` is the official field for SessionStart. The context is injected into Claude's system prompt for this session.

**Implementation:** `hooks/session-start-workflow.sh`

---

### UserPromptSubmit Hook

**Purpose:** Provide workflow guidance when user prompts suggest out-of-sequence actions.

**Capability:** CAN block prompts with `decision: block`, but devpowers uses advisory mode (context injection only) to avoid frustrating users. Blocking erases the prompt and shows only stderr to user.

**Input (stdin JSON):**
```json
{
  "hook_event_name": "UserPromptSubmit",
  "session_id": "abc123",
  "prompt": "let's start implementing the login component",
  "cwd": "/path/to/project"
}
```

**Keyword detection patterns:**
```yaml
implement_keywords: ["implement", "write code", "build", "create the", "start coding"]
review_keywords: ["review", "check", "validate", "critique"]
pr_keywords: ["create PR", "pull request", "merge", "push"]
```

**Stage validation matrix:**
| User Intent | Required Stage | Warning if Before |
|-------------|----------------|-------------------|
| implement | `implementing` | "Reviews not complete" |
| create PR | `finishing` | "Lessons not captured" |
| domain review | `domain-review` | "Tasks not broken down" |

**Output (stdout):**
```json
{
  "systemMessage": "⚠️ Domain review not complete. Consider running domain-review first. Current stage: task-breakdown"
}
```

**Implementation:** `hooks/workflow-advisor.py`

---

### PreToolUse Hook (Write validation)

**Purpose:** Validate file operations against workflow state. **Can block.**

**Matcher config (in hooks/hooks.json):**
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/write-validator.py"
          }
        ]
      }
    ]
  }
}
```

**Input (stdin JSON):**
```json
{
  "hook_event_name": "PreToolUse",
  "session_id": "abc123",
  "cwd": "/path/to/project",
  "tool_name": "Write",
  "tool_input": {
    "file_path": "/path/to/project/src/components/Login.tsx",
    "content": "..."
  }
}
```

**Implementation logic:**
```python
1. Extract file_path from tool_input
2. Check if path matches implementation directories:
   - src/, lib/, app/, components/, pages/
   - Exclude: docs/, tests/, *.md, *.json
3. If implementation path:
   a. Read STATUS.md
   b. Check if stage >= "implementing"
   c. If not: return "ask" with reason
4. Otherwise: return "allow"
```

**Output (stdout JSON):**
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "ask",
    "permissionDecisionReason": "Writing to src/ but domain review not complete (stage: task-breakdown). Proceed anyway?"
  }
}
```

**Permission decisions:**
- `"allow"` — Proceed without asking
- `"deny"` — Block with reason (use sparingly)
- `"ask"` — Prompt user to confirm

**Note:** All `hookSpecificOutput` responses must include `hookEventName` matching the hook type.

**Implementation:** `hooks/write-validator.py`

---

### PostToolUse Hook (Write)

**Purpose:** Update workflow state and provide next-step guidance after task file creation.

**Limitation:** Cannot block — write has already completed. Reactive only.

**Matcher config (in hooks/hooks.json):**
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/task-created.sh"
          }
        ]
      }
    ]
  }
}
```

**Input (stdin JSON):**
```json
{
  "hook_event_name": "PostToolUse",
  "session_id": "abc123",
  "cwd": "/path/to/project",
  "tool_name": "Write",
  "tool_input": {
    "file_path": "/path/to/project/docs/plans/auth/tasks/01-login-form.md"
  },
  "tool_response": {
    "success": true,
    "filePath": "/path/to/project/docs/plans/auth/tasks/01-login-form.md"
  }
}
```

**Implementation logic:**
```bash
1. Check if tool_input.file_path matches */docs/plans/*/tasks/*.md
2. If match:
   a. Update STATUS.md: increment task count
   b. Return guidance message
3. If not task file: exit silently
```

**Output (stdout):**
```json
{
  "systemMessage": "✅ Task file created: 01-login-form.md. Domain review recommended as next step."
}
```

**Implementation:** `hooks/task-created.sh`

---

### SubagentStop Hook

**Purpose:** Validate implementation subagent completion and remind about code review.

**Limitation:** Cannot dispatch code review agent automatically. Can block completion or inject reminder.

**Input (stdin JSON):**
```json
{
  "hook_event_name": "SubagentStop",
  "session_id": "abc123",
  "transcript_path": "/path/to/.claude/projects/.../transcript.jsonl",
  "cwd": "/path/to/project",
  "stop_hook_active": true
}
```

**Note:** Unlike some hooks, SubagentStop does NOT receive subagent description or output directly. The hook must parse the transcript file to extract subagent context.

**Implementation logic:**
```python
1. Read transcript_path to find recent subagent invocation
2. Extract subagent description/task from Task tool call in transcript
3. Check if subagent_description contains implementation keywords:
   - "implement", "build", "create", "write code"
4. If implementation subagent:
   a. Check transcript for code-reviewer invocations
   b. If no code review found:
      - Return systemMessage reminder
      - Optionally block if mandatory
5. Update STATUS.md with completed task
```

**Output (stdout JSON):**

SubagentStop uses same format as Stop - top-level `decision` and `reason`, NOT `hookSpecificOutput`:

To allow with reminder:
```json
{
  "systemMessage": "Implementation complete. Invoke code-reviewer agent before proceeding to next task."
}
```

Or to block:
```json
{
  "decision": "block",
  "reason": "Code review required before approving implementation subagent. Run code-reviewer first."
}
```

**Note:** To allow subagent to stop, omit `decision` or return `{}`. Use `systemMessage` for advisory reminders.

**Implementation:** `hooks/subagent-review.py`

---

### Stop Hook

**Purpose:** Ensure learnings capture before session ends.

**Limitation:** Can block stopping, but cannot prompt user directly. Blocking forces Claude to continue.

**Input (stdin JSON):**
```json
{
  "hook_event_name": "Stop",
  "session_id": "abc123",
  "transcript_path": "/path/to/.claude/projects/.../transcript.jsonl",
  "cwd": "/path/to/project",
  "stop_hook_active": true
}
```

**Implementation logic:**
```bash
1. Find active feature from ACTIVE.md or STATUS.md
2. Check STATUS.md stage:
   - If stage is "implementing" or later
3. Check learnings.md modification time:
   - If not modified this session (compare timestamps)
4. If significant work done but no learnings:
   - Block with reason to prompt user
5. Otherwise: approve
```

**Output (stdout JSON):**

Stop/SubagentStop hooks use a **different format** than PreToolUse - top-level `decision` and `reason` fields, NOT `hookSpecificOutput`:

```json
{
  "decision": "block",
  "reason": "Ask user about learnings before ending session. Implementation work was done but learnings.md not updated."
}
```

Or to allow (omit decision or set to undefined):
```json
{
  "systemMessage": "Session ending. Learnings were captured."
}
```

**Note:** `decision: "block"` requires `reason`. To allow stopping, either omit `decision` entirely or return empty object `{}`.

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

### Agent Structure (Frontmatter Fields)

**Official documented fields** (per docs.claude.com/plugins-reference):
- `description` (required): What this agent specializes in
- `capabilities` (optional): Array of task capabilities

**Extended fields** (verify at implementation time - may exist in runtime but not public docs):
- `model`: If supported, use `inherit` (default), `sonnet`, `opus`, or `haiku`
- `tools`: If supported, restrict available tools (e.g., `["Read", "Grep", "Glob"]` for read-only)

**Note:** The official Claude Code docs show a minimal schema. Extended fields like `model`, `tools`, `name`, and `color` may be supported but require API verification during implementation. Design below uses extended schema; adjust based on actual API capabilities.

Agent descriptions **must** include:
- Triggering conditions ("Use this agent when...")
- `<example>` blocks with context, user request, assistant response, and commentary

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

### Agent Color Assignments (If Supported)

**Note:** `color` field may not be supported in official API. Verify at implementation. If not supported, omit these fields.

| Agent | Color | Rationale |
|-------|-------|-----------|
| frontend-reviewer | cyan | Visual/UI association |
| backend-reviewer | green | Server/data association |
| testing-reviewer | yellow | Caution/validation association |
| infrastructure-reviewer | magenta | Operations/systems association |
| integration-reviewer | blue | Cross-cutting/coordination association |

### Agent Tools Restrictions

All domain reviewer agents are **read-only** by default to prevent accidental modifications during review.

| Agent | Tools | Rationale |
|-------|-------|-----------|
| frontend-reviewer | `["Read", "Grep", "Glob", "WebFetch"]` | Read-only; WebFetch for design system docs |
| backend-reviewer | `["Read", "Grep", "Glob", "Bash"]` | Read-only; Bash for read-only commands (e.g., `curl`, `psql --command`) |
| testing-reviewer | `["Read", "Grep", "Glob", "Bash"]` | Read-only; Bash for running tests (`npm test`, `pytest`) |
| infrastructure-reviewer | `["Read", "Grep", "Glob", "Bash"]` | Read-only; Bash for `kubectl get`, `docker ps`, etc. |
| integration-reviewer | `["Read", "Grep", "Glob"]` | Strictly read-only; cross-domain review needs no execution |

**Bash restrictions for reviewers:**
- Reviewers with Bash access should only run **read-only commands**
- Acceptable: `git log`, `npm test`, `curl -X GET`, `kubectl get`
- Unacceptable: `rm`, `npm install`, `git push`, `kubectl apply`
- Agent prompts must explicitly state: "Run read-only commands only. Never modify files, install packages, or apply changes."

**Example system prompt section for agents with Bash access:**
```markdown
## Important Constraints

**BASH READ-ONLY POLICY:** You have Bash access for read-only operations only.
- ALLOWED: `git log`, `npm test`, `pytest`, `curl -X GET`, `kubectl get`, `docker ps`
- FORBIDDEN: `rm`, `npm install`, `git push`, `kubectl apply`, `docker run`, any write operation

If you need to run a command that modifies state, document it as a finding for the main agent to execute.
```

**When to grant Write/Edit access:**
- Never for domain reviewers — they identify issues, not fix them
- Fix suggestions go into review findings; main agent or user applies fixes

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

### v6 - 2026-01-16 - Fourth Review Round (Implementation Readiness & Workflow Coherence)

**Issues Addressed:**
- [CRITICAL] Added STATUS.md state machine with valid transitions and ASCII workflow diagram
- [CRITICAL] Added hook input/output schemas for all 6 hook events (SessionStart, UserPromptSubmit, PreToolUse, PostToolUse, SubagentStop, Stop)
- [CRITICAL] Added task document schema/template (NN-task-name.md and 00-overview.md)
- [CRITICAL] Fixed handoff chain to include task-breakdown and using-git-worktrees
- [CRITICAL] Added parallel feature management mechanism (ACTIVE.md)
- [CRITICAL] Added chunking-plans recursion depth (max 3 levels) and path structure
- [IMPORTANT] Added domain detection heuristics table (file path, keyword, import signals)
- [IMPORTANT] Added cross-domain routing protocol with JSON schemas
- [IMPORTANT] Added agent tools restrictions table (all reviewers read-only by default)
- [IMPORTANT] Added fork skills implementation guide (step-by-step, maintaining forks, decision tree)
- [IMPORTANT] Added migration paths for deleted skills (executing-plans, receiving-code-review)
- [IMPORTANT] Added master doc merge algorithm specification (classification, strategies, conflict resolution)
- [IMPORTANT] Standardized review loop rules across all skills (central table, skill references)
- [IMPORTANT] Added mid-skill abort handling (checkpointing, resumption, per-skill checkpoints)
- [IMPORTANT] Fixed learnings.md parallel write race condition (write to temp files, then aggregate)
- [IMPORTANT] Added user override for critic disagreement (presentation template, recording, persistence)
- [IMPORTANT] Added Trivial scope escalation path (triggers, process, preserving partial work)
- [MINOR] Expanded STATUS.md template with Sub-State section for review loop tracking
- [MINOR] Added detection algorithm for domain assignment
- [MINOR] Added round-trip counting rules for cross-domain routing

**Reviewer Notes:** This round focused on implementation readiness — ensuring all schemas, algorithms, and protocols are specified in enough detail for implementation. Key additions include state machine diagrams, JSON schemas for hooks and routing, and comprehensive handling of edge cases (abort, race conditions, escalation).

### v7 - 2026-01-16 - Fifth Review Round (API Accuracy)

**Issues Addressed:**
- [CRITICAL] Fixed hook output field names: `reason` → `permissionDecisionReason`, added `hookEventName` to all `hookSpecificOutput`
- [CRITICAL] Fixed hook input field names: `tool` → `tool_name`, `input` → `tool_input`, `output` → `tool_response`, added `hook_event_name` and `session_id` fields
- [CRITICAL] Fixed UserPromptSubmit documentation: CAN block (not advisory only)
- [CRITICAL] Fixed SubagentStop input schema: removed invented fields (`subagent_description`, `subagent_output`), added note about parsing transcript for context
- [IMPORTANT] Added hooks.json wrapper structure requirement for plugin hooks
- [IMPORTANT] Added hook timeout defaults (command: 60s, prompt: 30s)
- [IMPORTANT] Added hook file locations table (plugin vs user vs project)
- [IMPORTANT] Added Stage vs Skill naming clarification table
- [IMPORTANT] Added Bash read-only enforcement example for agent system prompts
- [IMPORTANT] Added SKILL.md update requirements for modified skills (version bump, changelog, integration section)
- [IMPORTANT] Added STATUS.md corruption handling (detection, backup, inference, recovery)
- [IMPORTANT] Clarified agent frontmatter fields: official (`description`, `capabilities`) vs extended (`model`, `tools`, `color`)
- [MINOR] Fixed Hook Capabilities table: UserPromptSubmit CAN block
- [MINOR] Added Stop hook input/output with correct schema
- [MINOR] Annotated Agent Color Assignments as "if supported"

**Reviewer Notes:** This round verified all JSON schemas against official Claude Code documentation. Multiple hook schemas had incorrect field names that would have caused implementation failures. Agent frontmatter schema discrepancy between official docs and plugin-dev skill was documented for implementation-time verification.

### v8 - 2026-01-16 - Sixth Review Round (Hook Format Corrections & Workflow Completeness)

**Issues Addressed:**
- [CRITICAL] Fixed Stop/SubagentStop hook output format: Use top-level `decision` and `reason`, NOT `hookSpecificOutput` (different from PreToolUse)
- [IMPORTANT] Fixed UserPromptSubmit input field: `user_prompt` → `prompt`
- [IMPORTANT] Fixed SessionStart output: Use `hookSpecificOutput.additionalContext` for context injection
- [IMPORTANT] Fixed hook config JSON structure: Use nested `hooks: [{type, command}]` format, not `event`/`script`
- [IMPORTANT] Fixed Hook Capabilities table: `approve/block` → `block/omit` for Stop/SubagentStop
- [IMPORTANT] Added `using-devpowers` skill definition (entry-point skill)
- [IMPORTANT] Added `project-setup` to state machine transitions table
- [IMPORTANT] Removed undocumented "Prompt hooks: 30 seconds" timeout claim
- [MINOR] Added `cwd` field to PreToolUse and PostToolUse input schemas
- [MINOR] Clarified lessons-learned max rounds (3 total, max 2 discussions per conflict)
- [MINOR] Fixed review loops table: `task-breakdown` → `chunking-plans` for recursive subdivision
- [MINOR] Added explicit skill invocations to handoff chain table
- [MINOR] Noted `forked_from` is a devpowers convention, not official field
- [MINOR] Standardized placeholder naming: `[feature-name]` → `[feature]`

**Reviewer Notes:** This round corrected the Stop/SubagentStop hook output schemas which were incorrectly using PreToolUse format. Key insight: different hook types have different output formats - PreToolUse uses `hookSpecificOutput.permissionDecision`, while Stop/SubagentStop use top-level `decision`/`reason`. Also added missing entry-point skill and improved workflow completeness.
