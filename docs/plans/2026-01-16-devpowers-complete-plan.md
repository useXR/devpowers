# Devpowers Complete Implementation Plan

This document merges the workflow design specification and migration cleanup into a single comprehensive implementation plan. It is self-contained — no need to reference other documents.

**Created:** 2026-01-16
**Status:** Ready for implementation

---

## Table of Contents

1. [Overview](#overview)
2. [Cross-Cutting Concerns](#cross-cutting-concerns)
3. [Phase 1: Cleanup](#phase-1-cleanup)
4. [Phase 2: Workflow State Infrastructure](#phase-2-workflow-state-infrastructure)
5. [Phase 3: Entry-Point Skill (using-devpowers)](#phase-3-entry-point-skill)
6. [Phase 4: Project Setup Skill](#phase-4-project-setup-skill)
7. [Phase 5: Core Workflow Skills](#phase-5-core-workflow-skills)
8. [Phase 6: Domain Review System](#phase-6-domain-review-system)
9. [Phase 7: Cross-Domain Review](#phase-7-cross-domain-review)
10. [Phase 8: User Journey Mapping](#phase-8-user-journey-mapping)
11. [Phase 9: Lessons Learned](#phase-9-lessons-learned)
12. [Phase 10: Implementation Skills Updates](#phase-10-implementation-skills-updates)
13. [Phase 11: Hook-Based Automation](#phase-11-hook-based-automation)
14. [Phase 12: Fork Skills](#phase-12-fork-skills)

---

## Overview

### What is Devpowers?

Devpowers is a fork of superpowers, modified to support:
- **Master documents** — Persistent knowledge that accumulates per-project
- **Two-level planning** — High-level architecture reviewed separately from implementation details
- **Domain-expert review** — Specialized agents validate their areas before implementation
- **User journey mapping** — Comprehensive test coverage through explicit behavior mapping
- **Learnings capture** — Agent-experienced insights feed back into master docs

### Complete Workflow (Large Scope)

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

### Workflow Scope Tiers

Not every change needs the full workflow. Scope determines which steps apply:

| Scope | Description | Workflow |
|-------|-------------|----------|
| **Trivial** | Typo fix, config tweak, single-line change | Direct implementation, no planning |
| **Small** | Bug fix, minor enhancement, <50 lines | Brainstorm → Plan → Implement → Lessons (optional) |
| **Medium** | Feature addition, moderate complexity | Full workflow, skip user journey mapping if no UI |
| **Large** | Major feature, architectural change | Full workflow |

**Scope detection:** At brainstorming start, assess scope and confirm with user. If scope changes during planning (task turns out bigger than expected), escalate to appropriate tier.

### Explicit Handoff Chain

Each skill ends with a prompt asking if the user is ready for the next step.

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

---

## Cross-Cutting Concerns

These rules apply across multiple phases and skills.

### Review Loop Rules

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

**Skills with review loops:**

| Skill | Loop Type | Max Rounds | Convergence Criteria | Special Rules |
|-------|-----------|------------|---------------------|---------------|
| `reviewing-plans` | Critic review | 3 | No CRITICAL/IMPORTANT | None - follows standard |
| `domain-review` | Multi-critic | 3 | No CRITICAL/IMPORTANT | Per-task chunking if >5 findings |
| `cross-domain-review` | Issue routing | 3 | No unresolved cross-domain | Max 2 round-trips per issue |
| `chunking-plans` | Recursive subdivision | 3 | Each task <500 words | Recurse depth max 3 levels |
| `user-journey-mapping` | Gap filling | 3 | All journeys have error/edge/a11y | — |
| `lessons-learned` | Approval | 3 | User approves master doc updates | Max 2 discussions per conflict |

### Issue Severity Classification

| Severity | Description | Action |
|----------|-------------|--------|
| **CRITICAL** | Must fix before proceeding. Blocks workflow. Architectural flaws, missing core requirements, security vulnerabilities. | Block until fixed |
| **IMPORTANT** | Should fix before proceeding. Missing edge cases, incomplete error handling, non-obvious dependencies. | Fix before next stage |
| **MINOR** | Can proceed, fix before merge. Code style concerns, minor optimizations. | Track, fix later |
| **NITPICK** | Optional improvements. Naming suggestions, documentation improvements. | Optional |

### User Override for Critic Disagreement

When critics disagree on recommendations (not just severity), the user must decide.

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

**Recording user override (in STATUS.md):**

```markdown
## User Overrides
- 2026-01-16: API structure: Chose flat objects (Backend) over nested (Frontend)
  - Reason: "Prioritizing API stability over frontend convenience"
  - Revisit if: Frontend complexity becomes unmanageable
```

### Agent Failure Handling

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

### Scope Escalation

When scope changes during work (task turns out bigger than expected):

**Detection triggers by tier:**

| Current Tier | Escalation Trigger | Escalate To |
|--------------|-------------------|-------------|
| **Trivial** | >10 lines changed, or touches >2 files, or introduces new behavior | Small |
| **Trivial** | Requires understanding context, affects other features | Medium |
| **Small** | Task breakdown yields >5 tasks | Medium |
| **Small** | Architectural changes identified | Large |
| **Medium** | >10 tasks, or cross-cutting concerns | Large |

**Trivial → Small/Medium triggers (during "direct implementation"):**
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

**Scope can only escalate, not descend** — once in Large workflow, stay there.

### Workflow Interruption & Recovery

**Detecting current state:** Each skill checks for existing artifacts to determine workflow state:
- `/docs/master/` exists → project setup complete
- `/docs/plans/[feature]/` exists → brainstorming done
- `high-level-plan.md` exists → planning done
- `/tasks/` folder exists → breakdown done

On resume, detect state and prompt: "Found existing [artifacts]. Continue from [stage]?"

**Aborting a workflow:** At any handoff prompt, user can respond with "abort" to trigger cleanup:

1. **Confirm scope of abort:** "Abort this feature entirely, or just pause?"
2. **If abort entirely:**
   - Archive `/docs/plans/[feature]/` to `/docs/plans/archived/[feature]-[date]/`
   - Delete worktree if created
   - Prompt: "Feature archived. Start fresh or work on something else?"
3. **If pause:**
   - Note current state in `/docs/plans/[feature]/STATUS.md`
   - Prompt: "Paused at [stage]. Resume anytime by opening this feature."

**Mid-skill checkpointing:** Each skill with multi-step workflows must checkpoint after significant progress:

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

**STATUS.md corruption handling:**

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

### Skills to Delete (Migration Paths)

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

**Where the functionality lives now:**
1. `subagent-driven-development` — Step 4 invokes code-reviewer
2. SubagentStop hook — Validates review happened
3. `lessons-learned` skill — Captures review findings

---

## Phase 1: Cleanup

### Task 1.1: Remove Superseded Skills

**Files to delete:**

| File/Directory | Reason |
|---------------|--------|
| `skills/executing-plans/` | Superseded by `subagent-driven-development` |
| `skills/receiving-code-review/` | Merged into `subagent-driven-development` |
| `workflow` (root) | Working notes - content captured in this plan |

**Commands:**
```bash
rm -rf skills/executing-plans/
rm -rf skills/receiving-code-review/
rm -rf workflow/
git add -A
git commit -m "chore: remove superseded skills (executing-plans, receiving-code-review)"
```

### Task 1.2: Move reviewing-plans to skills/

**Current location:** `reviewing-plans/`
**New location:** `skills/reviewing-plans/`
**Reason:** Skills must be in `skills/` for auto-discovery

**Commands:**
```bash
mv reviewing-plans/ skills/reviewing-plans/
git add -A
git commit -m "refactor: move reviewing-plans to skills/ for auto-discovery"
```

### Task 1.3: Fix superpowers References

**File:** `skills/reviewing-plans/SKILL.md` (after move)

**Changes needed:**

| Line | Current | New |
|------|---------|-----|
| ~135 | `superpowers:subagent-driven-development` | `devpowers:subagent-driven-development` |
| ~136 | `superpowers:executing-plans` | Remove (skill deleted) |
| ~225 | `superpowers:writing-plans` | `devpowers:writing-plans` |
| ~228 | `superpowers:subagent-driven-development` | `devpowers:subagent-driven-development` |
| ~229 | `superpowers:executing-plans` | Remove (skill deleted) |

Also remove any content describing parallel session execution via `executing-plans`.

**Commit:**
```bash
git add skills/reviewing-plans/SKILL.md
git commit -m "fix: update skill references from superpowers to devpowers"
```

---

## Phase 2: Workflow State Infrastructure

### Task 2.1: Create STATUS.md Template

**File:** `skills/using-devpowers/assets/STATUS-template.md`

**Full template content:**

```markdown
# Workflow Status: [Feature Name]

## Current State
- **Stage:** brainstorming
- **Scope:** [trivial | small | medium | large]
- **Last Updated:** [ISO timestamp]
- **Last Action:** Feature created

## Sub-State (for review loops)
- **Review Round:** 1 of 3
- **Critics Completed:** []
- **Pending Critics:** []

## Progress
- [ ] Brainstorming complete
- [ ] High-level plan written
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

### Task 2.2: Create ACTIVE.md Template

**File:** `skills/using-devpowers/assets/ACTIVE-template.md`

**Full template content:**

```markdown
# Active Features

## Current Feature
[feature-name-here]

## All Features
| Feature | Stage | Last Updated | Status |
|---------|-------|--------------|--------|

## Switch Feature
To switch: "Switch to [feature]"
```

### Task 2.3: Create Learnings Log Template

**File:** `skills/using-devpowers/assets/learnings-template.md`

**Full template content:**

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

**Entry format (for agents to follow):**
```markdown
### [Date/Task] - Brief title
**Context:** What was being attempted
**Issue:** What went wrong or was tricky
**Resolution:** What finally worked
**Lesson:** What to remember for next time
```

**When agents should append:**
- Multiple iterations needed to solve something
- Documentation didn't match reality
- A pattern emerged across multiple places
- A workaround was required
- Something that "should have worked" didn't

### Task 2.4: Define State Machine

**Valid workflow stages:**

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

**Valid transitions table:**

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

**Stage vs Skill naming:**

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

**Commands:**
```bash
mkdir -p skills/using-devpowers/assets
# Create all template files above
git add skills/using-devpowers/assets/
git commit -m "feat: add workflow state templates (STATUS.md, ACTIVE.md, learnings.md)"
```

---

## Phase 3: Entry-Point Skill

### Task 3.1: Create using-devpowers Skill

**File:** `skills/using-devpowers/SKILL.md`

**Full SKILL.md content:**

```markdown
---
name: using-devpowers
description: >
  This skill should be used when the user asks to "start a feature",
  "use devpowers", "plan a new feature", "begin development", "work on [feature]",
  or when starting any non-trivial development task. Provides workflow overview,
  scope detection, and routes to appropriate starting skill.
---

# Using Devpowers

<EXTREMELY-IMPORTANT>
If you think there is even a 1% chance another devpowers skill applies to what you are doing, you ABSOLUTELY MUST invoke that skill.

IF A SKILL APPLIES TO YOUR TASK, YOU DO NOT HAVE A CHOICE. YOU MUST USE IT.
</EXTREMELY-IMPORTANT>

## Entry-Point Workflow

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

## Scope Tiers

| Scope | Description | Workflow |
|-------|-------------|----------|
| **Trivial** | Typo fix, config tweak, single-line change | Direct implementation, no planning |
| **Small** | Bug fix, minor enhancement, <50 lines | Brainstorm → Plan → Implement → Lessons (optional) |
| **Medium** | Feature addition, moderate complexity | Full workflow, skip user journey mapping if no UI |
| **Large** | Major feature, architectural change | Full workflow |

## Detecting Workflow State

Check for existing artifacts:
- `/docs/master/` exists → project setup complete
- `/docs/plans/[feature]/` exists → brainstorming done
- `high-level-plan.md` exists → planning done
- `/tasks/` folder exists → breakdown done
- `STATUS.md` → read for current stage

If resuming, prompt: "Found existing [artifacts] for [feature]. Continue from [stage]?"

## Handoff

After routing:
- If project-setup: "No master docs found. Let's set up the project first."
- If brainstorming: "Ready to brainstorm [feature]?"
- If resume: "Resuming [feature] at [stage]. [Next action]?"
```

**Commit:**
```bash
git add skills/using-devpowers/
git commit -m "feat: create using-devpowers entry-point skill"
```

---

## Phase 4: Project Setup Skill

### Task 4.1: Create project-setup Skill Structure

**Directory structure:**
```
skills/project-setup/
├── SKILL.md
├── scripts/
│   └── detect-stack.sh
├── assets/
│   └── master-doc-templates/
│       ├── design-system.md
│       └── lessons-learned/
│           ├── frontend.md
│           ├── backend.md
│           ├── testing.md
│           └── infrastructure.md
└── references/
    └── stack-detection-guide.md
```

### Task 4.2: Create SKILL.md

**File:** `skills/project-setup/SKILL.md`

```markdown
---
name: project-setup
description: >
  This skill should be used when the user asks to "set up a new project",
  "initialize master documents", "create project structure", "bootstrap devpowers",
  or when starting development in a repo without `/docs/master/` directory.
  Sets up master documents tailored to the detected technology stack.
---

# Project Setup

## Overview

Initialize a project with tailored master documents for institutional knowledge accumulation.

## Workflow

1. Run `scripts/detect-stack.sh` — outputs detected frameworks
2. Interpret results using `references/stack-detection-guide.md`
3. Read template master docs from `assets/master-doc-templates/`
4. Tailor templates based on detected stack (apply judgment)
5. Write tailored docs to `/docs/master/`
6. Commit initial master docs
7. Handoff: "Project setup complete. Ready to start brainstorming a feature?"

## Directory Conventions

- `assets/`: Templates and static resources copied to project (not loaded into context)
- `references/`: Documentation loaded on-demand when Claude needs guidance
- `scripts/`: Executable tools that output data for Claude to interpret

## Output Structure

Creates:
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
```

### Task 4.3: Create detect-stack.sh

**File:** `skills/project-setup/scripts/detect-stack.sh`

```bash
#!/bin/bash
# Detect technology stack from project files

echo "=== Stack Detection ==="

# Check for package.json (Node.js ecosystem)
if [ -f "package.json" ]; then
    echo "DETECTED: Node.js project"
    echo "Dependencies:"

    # Frontend frameworks
    grep -oE '"(react|vue|svelte|angular|next|nuxt|gatsby|remix|astro)"' package.json 2>/dev/null | tr -d '"' | while read dep; do
        echo "  - $dep (frontend)"
    done

    # Backend frameworks
    grep -oE '"(express|fastify|koa|hapi|nest|hono)"' package.json 2>/dev/null | tr -d '"' | while read dep; do
        echo "  - $dep (backend)"
    done

    # Testing
    grep -oE '"(jest|vitest|mocha|playwright|cypress)"' package.json 2>/dev/null | tr -d '"' | while read dep; do
        echo "  - $dep (testing)"
    done

    # Styling
    grep -oE '"(tailwindcss|styled-components|emotion|sass)"' package.json 2>/dev/null | tr -d '"' | while read dep; do
        echo "  - $dep (styling)"
    done
fi

# Check for Python
if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ] || [ -f "setup.py" ]; then
    echo "DETECTED: Python project"
    if [ -f "requirements.txt" ]; then
        grep -oE '^(django|flask|fastapi|pytest|numpy|pandas)' requirements.txt 2>/dev/null | while read dep; do
            echo "  - $dep"
        done
    fi
fi

# Check for Go
if [ -f "go.mod" ]; then
    echo "DETECTED: Go project"
fi

# Check for Rust
if [ -f "Cargo.toml" ]; then
    echo "DETECTED: Rust project"
fi

# Check for Docker
if [ -f "Dockerfile" ] || [ -f "docker-compose.yml" ] || [ -f "docker-compose.yaml" ]; then
    echo "DETECTED: Docker/containerized"
fi

# Check for CI/CD
if [ -d ".github/workflows" ]; then
    echo "DETECTED: GitHub Actions CI/CD"
fi
if [ -f ".gitlab-ci.yml" ]; then
    echo "DETECTED: GitLab CI/CD"
fi

# Check folder structure
echo ""
echo "=== Directory Structure ==="
ls -d */ 2>/dev/null | head -20

echo ""
echo "=== Key Files ==="
ls -la *.json *.yaml *.yml *.toml 2>/dev/null | head -10
```

### Task 4.4: Create Master Doc Templates

**File:** `skills/project-setup/assets/master-doc-templates/design-system.md`

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
<!-- Populated from lessons learned -->
```

**File:** `skills/project-setup/assets/master-doc-templates/lessons-learned/frontend.md`

```markdown
# Lessons Learned: Frontend

## Patterns That Work
<!-- Successful approaches discovered during implementation -->

## Anti-Patterns
<!-- Approaches that failed or caused issues -->

## Gotchas
<!-- Non-obvious behaviors, edge cases, surprises -->

## Useful Tools/Libraries
<!-- Recommendations with context -->
```

**Similar templates for:** `backend.md`, `testing.md`, `infrastructure.md`

### Task 4.5: Create Stack Detection Guide

**File:** `skills/project-setup/references/stack-detection-guide.md`

```markdown
# Stack Detection Guide

## Interpreting detect-stack.sh Output

When the script outputs detected frameworks, apply these heuristics:

### Frontend Stack Detection
- React + Next.js → Server-side rendering focus
- React + Vite → Client-side SPA focus
- Vue + Nuxt → Server-side rendering focus
- Svelte + SvelteKit → Full-stack focus

### Backend Stack Detection
- Express → Minimal, flexible backend
- Fastify → Performance-focused backend
- NestJS → Enterprise-grade, TypeScript-first

### Testing Stack Detection
- Jest → Unit testing focus
- Playwright → E2E testing focus
- Vitest → Modern unit testing with Vite

### Tailoring Templates

Based on detected stack, customize:
1. **design-system.md**: Include framework-specific component patterns
2. **lessons-learned/frontend.md**: Add framework-specific gotchas
3. **lessons-learned/testing.md**: Add testing library patterns
```

**Commit:**
```bash
mkdir -p skills/project-setup/{scripts,assets/master-doc-templates/lessons-learned,references}
chmod +x skills/project-setup/scripts/detect-stack.sh
# Create all files above
git add skills/project-setup/
git commit -m "feat: add project-setup skill with master doc templates"
```

---

## Phase 5: Core Workflow Skills

### Task 5.1: Update brainstorming Skill

**File:** `skills/brainstorming/SKILL.md`

**Changes needed:**

1. **Add scope assessment at start:**
```markdown
## Scope Assessment

Before brainstorming, assess scope:
- **Trivial:** Direct implementation, skip brainstorming
- **Small:** Brief brainstorm, simple plan
- **Medium/Large:** Full brainstorming process

Ask user to confirm scope if unclear.
```

2. **Output to `/docs/plans/[feature]/` structure:**
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

4. **Create learnings.md and STATUS.md when feature folder created**

5. **Update handoff:**
```markdown
## Handoff

"Brainstorming complete. Feature folder created at `/docs/plans/[feature]/`.

Ready to write the high-level plan?"

→ Invokes `writing-plans`
```

### Task 5.2: Update writing-plans Skill

**File:** `skills/writing-plans/SKILL.md`

**Changes needed:**

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

3. **Update STATUS.md:**
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

### Task 5.3: Update reviewing-plans Skill

**File:** `skills/reviewing-plans/SKILL.md`

**Full updated content:**

```markdown
---
name: reviewing-plans
description: >
  This skill should be used when the user asks to "review the plan",
  "validate the architecture", "check if the plan is ready", "critique the design",
  or after writing-plans produces a high-level-plan.md file. Runs parallel critics
  to find issues before committing to implementation.
---

# Reviewing Plans

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

### 1. Feasibility Critic
- Will this architecture work?
- Correct assumptions?
- Dependencies available?
- Technical constraints considered?

### 2. Completeness Critic
- All requirements covered?
- Error handling addressed?
- Edge cases considered?
- Security implications?

### 3. Simplicity Critic
- Over-engineered?
- YAGNI violations?
- Unnecessary complexity?
- Simpler alternatives?

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

### Task 5.4: Create Critic Prompts for reviewing-plans

**File:** `skills/reviewing-plans/feasibility-critic.md`

```markdown
# Feasibility Critic

You are reviewing a high-level architecture plan for technical feasibility.

## Your Focus

1. **Technical Viability**
   - Will this architecture actually work?
   - Are the technology choices appropriate?
   - Are there known limitations that would block this?

2. **Assumptions**
   - What assumptions does the plan make?
   - Are they valid?
   - What happens if they're wrong?

3. **Dependencies**
   - Are all required dependencies available?
   - Are version constraints considered?
   - Are there compatibility issues?

4. **Constraints**
   - Performance requirements
   - Scalability needs
   - Security requirements

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

**File:** `skills/reviewing-plans/completeness-critic.md`

```markdown
# Completeness Critic

You are reviewing a high-level architecture plan for completeness.

## Your Focus

1. **Requirements Coverage**
   - Are all stated requirements addressed?
   - Are there implied requirements not covered?

2. **Error Handling**
   - How are errors handled at each boundary?
   - What happens when things fail?
   - Is there graceful degradation?

3. **Edge Cases**
   - Empty states
   - Maximum limits
   - Concurrent access
   - Network failures

4. **Security**
   - Authentication/authorization
   - Input validation
   - Data protection

## Output Format

[Same as feasibility critic]
```

**File:** `skills/reviewing-plans/simplicity-critic.md`

```markdown
# Simplicity Critic

You are reviewing a high-level architecture plan for unnecessary complexity.

## Your Focus

1. **Over-Engineering**
   - Are there simpler alternatives?
   - Is abstraction justified?
   - Are patterns being used for their own sake?

2. **YAGNI Violations**
   - Features not requested
   - Premature optimization
   - Unnecessary flexibility

3. **Complexity Hotspots**
   - Areas with too many moving parts
   - Overly clever solutions
   - Hard-to-understand flows

## Output Format

[Same as feasibility critic]
```

**File:** `skills/reviewing-plans/references/severity-guide.md`

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

### Task 5.5: Create task-breakdown Skill

**Directory structure:**
```
skills/task-breakdown/
├── SKILL.md
├── breakdown-agent.md
├── references/
│   └── task-sizing-guide.md
└── assets/
    ├── task-template.md
    └── overview-template.md
```

**File:** `skills/task-breakdown/SKILL.md`

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

Break a reviewed high-level plan into implementable task documents. This is the **initial breakdown** step.

Distinct from `chunking-plans` which handles **recursive subdivision** of tasks that turn out to be too complex during domain review.

| Skill | Purpose | Input | Output |
|-------|---------|-------|--------|
| `task-breakdown` | Initial breakdown | high-level-plan.md | tasks/*.md |
| `chunking-plans` | Recursive subdivision | Existing task that's too complex | task/subtasks/*.md |

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

**File:** `skills/task-breakdown/assets/task-template.md`

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

**File:** `skills/task-breakdown/assets/overview-template.md`

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

### Task 5.6: Update chunking-plans Skill

**File:** `skills/chunking-plans/SKILL.md` (or via chunking-plans plugin)

**Changes needed:**

1. **Add recursion rules:**
```markdown
## Recursion Rules

- **Maximum depth:** 3 levels (task → subtask → sub-subtask)
- **If deeper needed:** Reconsider task boundaries, likely architectural issue
- **Naming convention:** `tasks/03-auth/subtasks/01-validation/subtasks/01-email.md`
```

2. **Path structure:**
```markdown
## Path Structure

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
```

3. **Domain review integration:**
```markdown
## Domain Review Integration

When critic flags "task too complex":
1. Pause domain review
2. Invoke chunking-plans → creates subtask folder
3. Resume domain review on NEW subtasks (round counter resets for new tasks)
4. Original task marked as "container" (not directly implemented)
```

4. **Complexity signals:**
```markdown
## Complexity Signals (Triggers Chunking)

- Task description exceeds 500 words
- More than 10 implementation steps
- Multiple unrelated acceptance criteria
- Critic explicitly flags complexity
```

**Commits for Phase 5:**
```bash
git add skills/brainstorming/
git commit -m "feat: update brainstorming for devpowers workflow"

git add skills/writing-plans/
git commit -m "feat: update writing-plans for devpowers workflow"

git add skills/reviewing-plans/
git commit -m "feat: add parallel critics to reviewing-plans skill"

git add skills/task-breakdown/
git commit -m "feat: add task-breakdown skill"

git add skills/chunking-plans/
git commit -m "feat: update chunking-plans with recursive subdivision"
```

---

## Phase 6: Domain Review System

### Task 6.1: Create domain-review Skill

**Directory structure:**
```
skills/domain-review/
├── SKILL.md
├── frontend-critic.md
├── backend-critic.md
├── testing-critic.md
├── infrastructure-critic.md
└── references/
    └── severity-guide.md
```

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

This skill uses review loops. Follow the central review loop rules:
- Maximum 3 rounds per review stage
- Convergence: No CRITICAL or IMPORTANT issues
- After 3 rounds: Present user with accept/escalate/abort options

## Domain Detection

Not all critics run for every task. Detect relevant domains from task content.

### Detection Rules (any 2+ signals triggers domain)

| Domain | File Path Signals | Keyword Signals | Import Signals |
|--------|------------------|-----------------|----------------|
| **Frontend** | `src/components/`, `src/ui/`, `*.css`, `*.scss`, `*.tsx` | "component", "render", "useState", "CSS", "styled", "UI", "layout", "responsive" | react, vue, svelte, tailwind, styled-components |
| **Backend** | `src/api/`, `src/server/`, `routes/`, `controllers/`, `*.py` | "endpoint", "database", "query", "middleware", "authentication", "API", "REST", "GraphQL" | express, fastify, django, flask, prisma, typeorm |
| **Testing** | (always runs) | - | - |
| **Infrastructure** | `Dockerfile`, `*.yaml`, `terraform/`, `.github/`, `deploy/` | "deployment", "CI/CD", "environment", "scaling", "container", "kubernetes", "AWS", "monitoring" | docker, kubernetes, terraform, github-actions |

### Detection Algorithm

```
1. Parse task "Files to Create/Modify" section
2. Match file paths against domain patterns
3. Scan task content for keyword signals
4. Check any code snippets for import signals
5. Score each domain by signal count
6. Trigger domain if score >= 2
7. Always include Testing (maintains test plan)
```

## Each Domain Critic Checks

- Feasibility — Will this approach work?
- Completeness — All cases covered?
- Simplicity — Over-engineered?
- Patterns — Follows master docs?

## Workflow

1. Read task document(s) and relevant master docs
2. Detect relevant domains, confirm with user: "Detected domains: [list]. Run all, or adjust?"
3. Dispatch selected critics in parallel (single message with multiple Task tool calls)
4. Aggregate findings by severity (CRITICAL → IMPORTANT → MINOR → NITPICK)
5. If chunking needed (task too complex) → invoke `chunking-plans` → re-review new tasks
6. Loop until converged (max 3 rounds per task)
7. Update STATUS.md

## Aggregation Rules

- Collect all findings from parallel critics
- Group by severity (CRITICAL → IMPORTANT → MINOR → NITPICK)
- If critics disagree on severity, take the higher severity
- If critics have conflicting recommendations, present both to user (see User Override protocol)

## Test Plan Maintenance

- Testing critic reviews task and proposes unit tests
- Test plan updated in task doc after each domain review round
- Other critics can flag "needs test for X" which testing critic incorporates

## Chunking Integration

- If any critic flags "task too complex" → pause review
- Run `chunking-plans` on the complex task (recursive subdivision)
- Resume domain review with new smaller tasks
- Round counter resets for newly chunked tasks (they're new tasks)
- Original round counter continues for unchanged tasks

## Handoff

"Domain review complete. [Summary of findings across domains].

Ready for cross-domain review?"

→ Invokes `cross-domain-review`
```

### Task 6.2: Create Domain Critic Prompts

**File:** `skills/domain-review/frontend-critic.md`

```markdown
# Frontend Critic

You are a senior frontend engineer reviewing implementation task documents.

## Your Focus

1. **Component Structure**
   - Is the component well-structured?
   - Is it reusable where appropriate?
   - Does it follow project patterns?

2. **Design System Adherence**
   - Reference `/docs/master/design-system.md`
   - Are colors, typography, spacing consistent?
   - Are component patterns followed?

3. **Accessibility**
   - Keyboard navigation
   - Screen reader support
   - Focus management
   - ARIA attributes

4. **Performance**
   - Unnecessary re-renders?
   - Bundle size impact?
   - Lazy loading opportunities?

5. **State Management**
   - Is state at the right level?
   - Are there unnecessary prop drilling?
   - Is global state used appropriately?

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

**File:** `skills/domain-review/backend-critic.md`

```markdown
# Backend Critic

You are a senior backend engineer reviewing implementation task documents.

## Your Focus

1. **API Design**
   - RESTful conventions followed?
   - Consistent naming?
   - Appropriate HTTP methods/status codes?

2. **Data Flow**
   - Clear data transformations?
   - Proper validation at boundaries?
   - Efficient queries?

3. **Error Handling**
   - All error cases covered?
   - Appropriate error messages?
   - Proper error propagation?

4. **Security**
   - Authentication/authorization checks?
   - Input validation?
   - SQL injection prevention?
   - Sensitive data handling?

5. **Performance**
   - N+1 query problems?
   - Caching opportunities?
   - Database indexing?

## Output Format

[Same structure as frontend critic]
```

**File:** `skills/domain-review/testing-critic.md`

```markdown
# Testing Critic

You are a senior QA engineer reviewing implementation task documents.

## Your Focus

1. **Unit Test Coverage**
   - All functions tested?
   - Edge cases covered?
   - Error paths tested?

2. **Test Quality**
   - Tests are meaningful (not just coverage)?
   - Tests are maintainable?
   - Tests are independent?

3. **Test Plan Completeness**
   - Happy paths
   - Error states
   - Boundary conditions
   - Integration points

4. **Testability**
   - Is the code testable?
   - Are dependencies injectable?
   - Are there testing anti-patterns?

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

**File:** `skills/domain-review/infrastructure-critic.md`

```markdown
# Infrastructure Critic

You are a senior DevOps engineer reviewing implementation task documents.

## Your Focus

1. **Deployment**
   - How will this be deployed?
   - Are there environment considerations?
   - Configuration management?

2. **Scaling**
   - Will this scale horizontally?
   - Are there bottlenecks?
   - Resource requirements?

3. **Monitoring**
   - What should be monitored?
   - Logging requirements?
   - Alerting needs?

4. **Security**
   - Secrets management?
   - Network security?
   - Access controls?

5. **Operations**
   - Runbooks needed?
   - Rollback strategy?
   - Database migrations?

## Output Format

[Same structure as other critics]
```

### Task 6.3: Create Domain Reviewer Agents

**File:** `agents/frontend-reviewer.md`

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

## Instructions

[Task-specific instructions injected here by orchestrating skill]
```

**File:** `agents/backend-reviewer.md`

```markdown
---
name: backend-reviewer
description: |
  Use this agent when reviewing backend implementation for API design,
  data flow, and error handling. Examples:
  <example>
  Context: User has implemented new API endpoints.
  user: "Can you review the new user API endpoints?"
  assistant: "I'll use the backend-reviewer agent to check API design and error handling."
  <commentary>
  API implementation needs backend expertise.
  </commentary>
  </example>
---

# Backend Reviewer

You are a senior backend engineer reviewing implementation work.

## Your Focus
- API design and RESTful conventions
- Data flow and transformations
- Error handling and edge cases
- Security considerations
- Database query efficiency

## Important Constraints

**BASH READ-ONLY POLICY:** You have Bash access for read-only operations only.
- ALLOWED: `git log`, `npm test`, `pytest`, `curl -X GET`, `psql --command "SELECT..."`
- FORBIDDEN: `rm`, `npm install`, `git push`, `INSERT/UPDATE/DELETE`, any write operation

If you need to run a command that modifies state, document it as a finding for the main agent to execute.

Tools available: Read, Grep, Glob, Bash (read-only)

## Review Format

[Same as frontend-reviewer]
```

**File:** `agents/testing-reviewer.md`

```markdown
---
name: testing-reviewer
description: |
  Use this agent when reviewing test coverage, test quality, and test plans. Examples:
  <example>
  Context: User has written tests for a new feature.
  user: "Are the tests for the auth module comprehensive enough?"
  assistant: "I'll use the testing-reviewer agent to evaluate test coverage and quality."
  <commentary>
  Test review needs QA expertise.
  </commentary>
  </example>
---

# Testing Reviewer

You are a senior QA engineer reviewing test implementation.

## Your Focus
- Test coverage completeness
- Test quality and maintainability
- Edge case coverage
- Test isolation and independence

## Important Constraints

**BASH READ-ONLY POLICY:** You have Bash access for read-only operations only.
- ALLOWED: `npm test`, `pytest`, `go test`, test runners
- FORBIDDEN: Any commands that modify files or state

Tools available: Read, Grep, Glob, Bash (read-only)

## Review Format

[Same as frontend-reviewer]
```

**File:** `agents/infrastructure-reviewer.md`

```markdown
---
name: infrastructure-reviewer
description: |
  Use this agent when reviewing deployment, scaling, and operations concerns. Examples:
  <example>
  Context: User has added Docker configuration.
  user: "Review the Dockerfile and docker-compose setup"
  assistant: "I'll use the infrastructure-reviewer agent to check deployment configuration."
  <commentary>
  Docker configuration needs DevOps expertise.
  </commentary>
  </example>
---

# Infrastructure Reviewer

You are a senior DevOps engineer reviewing infrastructure work.

## Your Focus
- Deployment configuration
- Scaling considerations
- Monitoring and logging
- Security and secrets management
- Operational runbooks

## Important Constraints

**BASH READ-ONLY POLICY:** You have Bash access for read-only operations only.
- ALLOWED: `kubectl get`, `docker ps`, `terraform plan`, read-only commands
- FORBIDDEN: `kubectl apply`, `docker run`, `terraform apply`, any write operation

Tools available: Read, Grep, Glob, Bash (read-only)

## Review Format

[Same as frontend-reviewer]
```

**File:** `agents/integration-reviewer.md`

```markdown
---
name: integration-reviewer
description: |
  Use this agent when reviewing cross-domain integration points and API contracts. Examples:
  <example>
  Context: Feature touches both frontend and backend.
  user: "Check if the frontend and backend are aligned on the API contract"
  assistant: "I'll use the integration-reviewer agent to verify cross-domain alignment."
  <commentary>
  Cross-domain review needs integration expertise.
  </commentary>
  </example>
---

# Integration Reviewer

You are a senior architect reviewing cross-domain integration.

## Your Focus
- API contracts between frontend and backend
- Data flow across boundaries
- Error propagation across layers
- Timing and sequencing of async operations
- Dependency ordering

## Important Constraints

You have STRICTLY READ-ONLY access. No Bash access.

Tools available: Read, Grep, Glob

## Review Format

[Same as frontend-reviewer]
```

**Commits for Phase 6:**
```bash
mkdir -p skills/domain-review/references
# Create all skill files
git add skills/domain-review/
git commit -m "feat: add domain-review skill with multi-critic system"

# Create all agent files
git add agents/
git commit -m "feat: add domain reviewer agents"
```

---

## Phase 7: Cross-Domain Review

### Task 7.1: Create cross-domain-review Skill

**Directory structure:**
```
skills/cross-domain-review/
├── SKILL.md
├── integration-critic.md
└── references/
    └── common-integration-issues.md
```

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
- **External dependencies** — Third-party APIs, services, infrastructure requirements

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

Domain critic receives routing request:
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

Domain critic returns fix:
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

**File:** `skills/cross-domain-review/integration-critic.md`

```markdown
# Integration Critic

You are reviewing all task documents to find cross-domain integration issues.

## Your Focus

1. **API Contracts**
   - Does frontend expect what backend provides?
   - Are field names consistent?
   - Are data types compatible?

2. **Data Flow**
   - Are transformations correct between layers?
   - Is data validated at the right boundaries?

3. **Error Propagation**
   - Do errors flow correctly across boundaries?
   - Are error codes/messages consistent?

4. **Timing/Sequencing**
   - Are async operations coordinated?
   - Race conditions possible?

5. **Dependencies**
   - Are cross-domain deps explicit?
   - Is ordering correct in 00-overview.md?

## Output Format

```json
{
  "issues": [
    {
      "id": "API_001",
      "severity": "CRITICAL|IMPORTANT|MINOR|NITPICK",
      "description": "Clear description of the issue",
      "affected_tasks": ["task-file-1", "task-file-2"]
    }
  ],
  "routing": [
    {
      "domain": "frontend|backend|testing|infrastructure",
      "issue_id": "API_001",
      "task": "affected-task-file",
      "context": "Why this domain needs to address it",
      "requested_fix": "What change is needed"
    }
  ],
  "summary": "Overall integration assessment"
}
```
```

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

**Commit:**
```bash
mkdir -p skills/cross-domain-review/references
git add skills/cross-domain-review/
git commit -m "feat: add cross-domain-review skill with routing protocol"
```

---

## Phase 8: User Journey Mapping

### Task 8.1: Create user-journey-mapping Skill

**Directory structure:**
```
skills/user-journey-mapping/
├── SKILL.md
├── journey-critic.md
├── references/
│   └── journey-categories.md
└── examples/
    └── login-journey.md
```

**File:** `skills/user-journey-mapping/SKILL.md`

```markdown
---
name: user-journey-mapping
description: >
  This skill should be used when the user asks to "map user journeys",
  "identify test scenarios", "plan e2e tests", "ensure test coverage",
  or after cross-domain-review completes for UI features. Systematically
  enumerates all user behaviors to derive comprehensive test plans.
---

# User Journey Mapping

## Why This Exists

LLMs often miss edge cases, error states, and non-obvious user behaviors when generating tests ad-hoc. This skill forces systematic enumeration of all scenarios BEFORE test writing begins.

## Review Loop

This skill uses review loops:
- Maximum 3 rounds
- Convergence: All journeys have error/edge/accessibility coverage

## Journey Map Covers

- **Happy paths** — Primary success scenarios
- **Variations** — Different entry points, user states, data conditions
- **Error states** — Validation, network, server, permissions failures
- **Edge cases** — Limits, empty states, rapid actions, unicode, special chars
- **Interruptions** — Navigation, refresh, timeout, session expiry
- **Accessibility** — Keyboard navigation, screen reader, focus management

## Workflow

1. Read task docs to understand feature scope
2. Generate initial journey map using `references/journey-categories.md` as checklist
3. Dispatch Journey Critic to review for gaps
4. If gaps found → add to map → re-review
5. Loop until critic finds no significant gaps (max 3 rounds)
6. Output: `/docs/plans/[feature]/journeys/[component]-journeys.md`
7. Derive e2e test plan from journey map (added to task docs)
8. Update STATUS.md

## Handoff

"User journeys mapped. E2E test plan added to task documents.

Ready to create worktree and implement?"

→ Invokes `using-git-worktrees`
```

**File:** `skills/user-journey-mapping/journey-critic.md`

```markdown
# Journey Critic

You are reviewing user journey maps for completeness.

## Your Focus

Check that the journey map covers ALL categories:

### 1. Happy Paths
- [ ] Primary success scenario documented
- [ ] All variations of success documented

### 2. Error States
- [ ] Validation errors (each field)
- [ ] Network errors
- [ ] Server errors (500, 503)
- [ ] Permission errors (401, 403)
- [ ] Not found errors (404)

### 3. Edge Cases
- [ ] Empty states
- [ ] Maximum limits
- [ ] Minimum limits
- [ ] Unicode/special characters
- [ ] Rapid repeated actions
- [ ] Concurrent actions

### 4. Interruptions
- [ ] Mid-flow navigation
- [ ] Browser refresh
- [ ] Session timeout
- [ ] Network disconnect/reconnect

### 5. Accessibility
- [ ] Keyboard-only navigation
- [ ] Screen reader flow
- [ ] Focus management
- [ ] Color contrast considerations

## Output Format

```markdown
## Journey Review: [Component]

### Missing Journeys
- [ ] [Category]: [Specific missing journey]

### Incomplete Journeys
- [ ] [Journey name]: Missing [what's missing]

### Suggestions
- [Optional improvements]

### Assessment
[Complete / Needs work]
```
```

**File:** `skills/user-journey-mapping/references/journey-categories.md`

```markdown
# Journey Categories Checklist

Use this checklist when creating journey maps.

## Happy Paths
- [ ] User completes primary action successfully
- [ ] User completes with optional fields
- [ ] User completes with all fields

## Variations
- [ ] New user vs returning user
- [ ] Logged in vs logged out
- [ ] Different permission levels
- [ ] Different data states (empty, partial, full)

## Error States
- [ ] Each required field empty
- [ ] Each field invalid format
- [ ] Network request fails
- [ ] Server returns error
- [ ] User not authorized
- [ ] Resource not found
- [ ] Rate limited

## Edge Cases
- [ ] Empty list/results
- [ ] Single item
- [ ] Maximum items
- [ ] Very long text input
- [ ] Unicode characters
- [ ] HTML/script injection attempt
- [ ] Rapid form submission
- [ ] Duplicate submission

## Interruptions
- [ ] Leave page mid-form
- [ ] Browser back button
- [ ] Refresh page
- [ ] Close tab and return
- [ ] Session expires mid-action
- [ ] Network drops mid-request

## Accessibility
- [ ] Tab through all interactive elements
- [ ] Submit form with keyboard only
- [ ] Navigate with screen reader
- [ ] All images have alt text
- [ ] Focus visible on all elements
- [ ] Error messages announced
```

**File:** `skills/user-journey-mapping/examples/login-journey.md`

```markdown
# Login Feature - User Journeys

## Happy Paths

### J1: Successful login with email/password
1. User navigates to /login
2. User enters valid email
3. User enters valid password
4. User clicks "Sign In"
5. System validates credentials
6. System redirects to dashboard
7. Dashboard shows user's name

### J2: Successful login with "Remember me"
1-6. Same as J1
7. User checks "Remember me"
8. After session expires, user returns
9. User is still logged in

## Error States

### J3: Invalid email format
1. User enters "notanemail"
2. User tabs to password
3. Inline error: "Please enter a valid email"
4. Submit button disabled

### J4: Wrong password
1. User enters valid email
2. User enters wrong password
3. User clicks "Sign In"
4. Error message: "Invalid credentials"
5. Password field cleared
6. Focus returns to password field

### J5: Account locked
1. User enters valid email
2. User enters wrong password 5 times
3. Error: "Account locked. Try again in 15 minutes."
4. Form disabled

### J6: Network error
1. User enters valid credentials
2. Network is down
3. User clicks "Sign In"
4. Error: "Network error. Please try again."
5. Form remains filled

## Edge Cases

### J7: Paste password
1. User pastes email from clipboard
2. User pastes password from clipboard
3. Login succeeds

### J8: Very long email
1. User enters 254-character email
2. System accepts (valid per RFC)

### J9: Unicode in password
1. User enters password with emoji
2. System accepts/rejects consistently

## Accessibility

### J10: Keyboard-only login
1. Tab to email field
2. Type email
3. Tab to password field
4. Type password
5. Tab to "Sign In" button
6. Press Enter
7. Login succeeds

### J11: Screen reader flow
1. Screen reader announces "Login form"
2. Each field label is read
3. Error messages are announced
4. Success redirect is announced

## E2E Test Plan (derived)

- [ ] J1: Login with valid credentials → dashboard
- [ ] J3: Invalid email → inline error, button disabled
- [ ] J4: Wrong password → error message, field cleared
- [ ] J5: 5 failed attempts → account locked message
- [ ] J6: Network error → retry message, form intact
- [ ] J10: Complete login using only keyboard
```

**Commit:**
```bash
mkdir -p skills/user-journey-mapping/{references,examples}
git add skills/user-journey-mapping/
git commit -m "feat: add user-journey-mapping skill"
```

---

## Phase 9: Lessons Learned

### Task 9.1: Create lessons-learned Skill

**Directory structure:**
```
skills/lessons-learned/
├── SKILL.md
├── learnings-reviewer.md
└── references/
    └── update-categories.md
```

**File:** `skills/lessons-learned/SKILL.md`

```markdown
---
name: lessons-learned
description: >
  This skill should be used when the user asks to "capture lessons learned",
  "update master docs", "review what we learned", "document insights",
  or after implementation completes. Reviews both artifacts and agent-captured
  notes to propose master document updates.
---

# Lessons Learned

## What Are Master Docs?

Master documents live in `/docs/master/` and contain accumulated project knowledge:
- `design-system.md` — UI patterns, component conventions
- `lessons-learned/frontend.md` — Frontend-specific learnings
- `lessons-learned/backend.md` — Backend-specific learnings
- `lessons-learned/testing.md` — Testing-specific learnings
- `lessons-learned/infrastructure.md` — Infrastructure-specific learnings
- `patterns/` — Reusable code patterns discovered over time

## Review Loop

This skill uses review loops:
- Maximum 3 rounds total
- Max 2 discussions per conflict before escalating to user
- Convergence: User approves master doc updates

## What It Captures

- **New patterns** — Reusable approaches that emerged
- **Difficult problems** — Issues and solutions
- **New tools/procedures** — Utilities or workflows created
- **Anti-patterns** — What didn't work
- **Corrections** — Master doc content that was wrong

## Two Sources of Learnings

1. **Artifacts** — Inferred from code, plans, git diff/log
2. **Agent experience** — Captured in `learnings.md` during review/implementation

## Master Doc Merge Algorithm

### Classification Step

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

### Merge Strategy by Classification

| Classification | Action | User Approval |
|----------------|--------|---------------|
| NEW | Append to appropriate section | Show diff only |
| REFINEMENT | Inline edit with additions | Show diff only |
| CONTRADICTION | Present both versions | Required |
| SUPERSEDE | Replace with changelog | Show diff + reason |
| DUPLICATE | Skip, note in learnings.md | None |

### Contradiction Resolution Prompt

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

### Section Targeting

Map learnings to sections:

| Learning Type | Target Section |
|---------------|----------------|
| API usage pattern | `patterns/` → relevant domain file |
| Library gotcha | `gotchas.md` |
| Architecture decision | `architecture.md` |
| Testing insight | `lessons-learned/testing.md` |
| Performance finding | `lessons-learned/performance.md` |
| Security concern | `lessons-learned/security.md` |
| Tooling tip | `lessons-learned/tooling.md` |

### Atomic Update Rule

Each master doc update is a single atomic commit. Never batch unrelated updates.

Commit message format:
```
docs(master): [section] brief description

Context: [feature] during [phase]
Classification: [NEW|REFINEMENT|SUPERSEDE]
Previous: [if SUPERSEDE, what was replaced]
```

## Workflow

1. Read `/docs/plans/[feature]/learnings.md` (agent-captured notes)
2. Review artifacts (plan, tasks, git diff/log)
3. Categorize findings by master doc section
4. Apply merge algorithm for each finding
5. Present proposed updates with diffs
6. On approval, apply updates
7. Commit changes with context
8. Update STATUS.md

## Handoff

"Lessons captured and master docs updated.

Ready to finish the branch?"

→ Invokes `finishing-a-development-branch`
```

**File:** `skills/lessons-learned/learnings-reviewer.md`

```markdown
# Learnings Reviewer

You are reviewing implementation artifacts and learnings.md to identify what should be added to master documents.

## Your Focus

1. **Pattern Discovery**
   - What reusable patterns emerged?
   - What approaches worked well?

2. **Problem Documentation**
   - What was difficult?
   - What took multiple attempts?
   - What required workarounds?

3. **Anti-Pattern Identification**
   - What didn't work?
   - What should be avoided?

4. **Corrections**
   - Did any master doc guidance prove wrong?
   - What needs updating?

## Output Format

```markdown
## Learnings Review: [Feature]

### Proposed Master Doc Updates

#### 1. [Target: /docs/master/path/file.md]
**Classification:** NEW | REFINEMENT | CONTRADICTION | SUPERSEDE
**Content:**
> [The content to add/update]

**Rationale:** [Why this should be captured]

#### 2. [Next update...]

### No-Action Items
[Learnings that don't need master doc updates and why]

### Summary
[Overall assessment of learnings capture]
```
```

**File:** `skills/lessons-learned/references/update-categories.md`

```markdown
# Update Categories

## When to Update Master Docs

### Always Update
- Security vulnerabilities discovered
- Performance issues with solutions
- Breaking changes in dependencies
- Patterns that saved significant time

### Consider Updating
- Approaches that worked better than expected
- Tools that proved useful
- Gotchas that weren't obvious

### Don't Update
- One-off workarounds
- Project-specific configurations
- Temporary fixes

## Section Selection Guide

### design-system.md
- New component patterns
- Color/typography discoveries
- Responsive design patterns

### lessons-learned/frontend.md
- Framework-specific gotchas
- State management patterns
- Performance optimizations

### lessons-learned/backend.md
- API design patterns
- Database query optimizations
- Error handling approaches

### lessons-learned/testing.md
- Test structure patterns
- Mocking strategies
- CI/CD optimizations

### lessons-learned/infrastructure.md
- Deployment patterns
- Scaling strategies
- Monitoring approaches

### patterns/
- Reusable code patterns
- Architecture patterns
- Integration patterns
```

### Task 9.2: Implement Parallel Append Coordination

When multiple critics run in parallel, they must write to separate files to avoid race conditions.

**Write phase (parallel, no conflicts):**

Each critic writes to a separate temp file:
```
/docs/plans/[feature]/learnings-temp/
├── domain-review-frontend.md
├── domain-review-backend.md
├── domain-review-testing.md
└── domain-review-infrastructure.md
```

**Aggregate phase (sequential, after all critics complete):**

Orchestrator merges temp files into learnings.md, then cleans up temp files.

This is implemented in the skill instructions, not as a separate file.

**Commit:**
```bash
mkdir -p skills/lessons-learned/references
git add skills/lessons-learned/
git commit -m "feat: add lessons-learned skill with merge algorithm"
```

---

## Phase 10: Implementation Skills Updates

### Task 10.1: Update subagent-driven-development Skill

**File:** `skills/subagent-driven-development/SKILL.md`

**Changes needed:**

1. **Reference test plan in task docs:**
```markdown
## Task Execution

Before implementing each task:
1. Read task document
2. Check "Unit Test Plan" section
3. Check "E2E Test Plan" section
4. Follow TDD: Write tests first, then implement
```

2. **Append to learnings.md:**
```markdown
## During Implementation

When you encounter:
- Multiple iterations to solve something
- Documentation that didn't match reality
- A pattern that emerged
- A workaround that was required
- Something that "should have worked" but didn't

Append to `/docs/plans/[feature]/learnings.md`:

```markdown
### [Date/Task] - Brief title
**Context:** What was being attempted
**Issue:** What went wrong or was tricky
**Resolution:** What finally worked
**Lesson:** What to remember for next time
```
```

3. **Include code review step (from merged receiving-code-review):**
```markdown
## After Each Task

After implementing a task:
1. Run tests to verify
2. Invoke code-reviewer agent
3. Address findings
4. Commit with descriptive message
5. Update STATUS.md task status
```

4. **Reference pre-planned test cases:**
```markdown
## TDD Flow

For each task:
1. Read "Unit Test Plan" from task document
2. Write the first failing test from the plan
3. Run test, confirm it fails
4. Write minimal implementation to pass
5. Run test, confirm it passes
6. Repeat for remaining tests in plan
7. Check "E2E Test Plan" and ensure coverage
```

### Task 10.2: Update test-driven-development Skill

**File:** `skills/test-driven-development/SKILL.md`

**Changes needed:**

1. **Reference test plan from task doc:**
```markdown
## Test Plan Integration

When a task document exists with test plans:
1. Read "Unit Test Plan" section for unit tests
2. Read "E2E Test Plan" section for integration tests
3. Implement tests in the order specified
4. Do not skip planned tests
5. Add additional tests only if gaps discovered
```

2. **Adapt for both unit and e2e tests:**
```markdown
## Unit Tests (from domain review)

Execute tests from "Unit Test Plan":
- Function-level tests
- Edge cases
- Error handling

## E2E Tests (from journey mapping)

Execute tests from "E2E Test Plan":
- User journey scenarios
- Happy paths
- Error states
- Accessibility flows
```

**Commits for Phase 10:**
```bash
git add skills/subagent-driven-development/
git commit -m "feat: update subagent-driven-development for devpowers workflow"

git add skills/test-driven-development/
git commit -m "feat: update test-driven-development with test plan integration"
```

---

## Phase 11: Hook-Based Automation

### Hook Capabilities and Limitations

| Hook Event | Can Block? | Can Dispatch Agents? | Primary Use |
|------------|------------|---------------------|-------------|
| `SessionStart` | No | No | Inject context at session start |
| `UserPromptSubmit` | **Yes** (decision: block) | No | Add context; block if needed |
| `PreToolUse` | **Yes** (allow/deny/ask) | No | Validate before tool execution |
| `PostToolUse` | No (already executed) | No | React to tool results |
| `SubagentStop` | **Yes** (block/omit) | No | Validate subagent completion |
| `Stop` | **Yes** (block/omit) | No | Validate session end |

**Key insight:** Hooks cannot dispatch new agents or initiate work. They can only:
1. Inject context via `systemMessage`
2. Block/allow operations (where supported)
3. Provide feedback to Claude

### Task 11.1: Create hooks.json

**File:** `hooks/hooks.json`

```json
{
  "description": "Devpowers workflow automation hooks",
  "hooks": {
    "SessionStart": [
      {
        "type": "command",
        "command": "${CLAUDE_PLUGIN_ROOT}/hooks/session-start-workflow.sh"
      }
    ],
    "UserPromptSubmit": [
      {
        "type": "command",
        "command": "${CLAUDE_PLUGIN_ROOT}/hooks/workflow-advisor.py"
      }
    ],
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
    ],
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
    ],
    "SubagentStop": [
      {
        "type": "command",
        "command": "${CLAUDE_PLUGIN_ROOT}/hooks/subagent-review.py"
      }
    ],
    "Stop": [
      {
        "type": "command",
        "command": "${CLAUDE_PLUGIN_ROOT}/hooks/learnings-check.sh"
      }
    ]
  }
}
```

### Task 11.2: Create SessionStart Hook

**File:** `hooks/session-start-workflow.sh`

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

**Implementation:**
```bash
#!/bin/bash
# Detect workflow state and inject context

set -e

# Read input from stdin
INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd')

# Check for ACTIVE.md
ACTIVE_FILE="$CWD/docs/plans/ACTIVE.md"
if [ -f "$ACTIVE_FILE" ]; then
    FEATURE=$(grep -A1 "## Current Feature" "$ACTIVE_FILE" | tail -1 | tr -d ' ')
else
    # Find any STATUS.md
    STATUS_FILES=$(find "$CWD/docs/plans" -name "STATUS.md" 2>/dev/null | head -5)
    if [ -z "$STATUS_FILES" ]; then
        # No workflow state
        echo '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"No active devpowers workflow. Use using-devpowers skill to start."}}'
        exit 0
    fi

    # Multiple features, list them
    FEATURE_COUNT=$(echo "$STATUS_FILES" | wc -l)
    if [ "$FEATURE_COUNT" -gt 1 ]; then
        FEATURES=$(echo "$STATUS_FILES" | xargs -I{} dirname {} | xargs -I{} basename {})
        echo "{\"hookSpecificOutput\":{\"hookEventName\":\"SessionStart\",\"additionalContext\":\"Multiple features found: $FEATURES. Which to resume?\"}}"
        exit 0
    fi

    FEATURE=$(dirname "$STATUS_FILES" | xargs basename)
fi

# Read STATUS.md for current feature
STATUS_FILE="$CWD/docs/plans/$FEATURE/STATUS.md"
if [ ! -f "$STATUS_FILE" ]; then
    echo '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"Feature folder exists but no STATUS.md. Run using-devpowers to initialize."}}'
    exit 0
fi

# Extract stage and next action
STAGE=$(grep "^\- \*\*Stage:\*\*" "$STATUS_FILE" | sed 's/.*Stage:\*\* //')
SCOPE=$(grep "^\- \*\*Scope:\*\*" "$STATUS_FILE" | sed 's/.*Scope:\*\* //')
NEXT=$(grep "^\[" "$STATUS_FILE" | head -1)

CONTEXT="📍 Active: $FEATURE | Stage: $STAGE | Scope: $SCOPE | Next: $NEXT"

echo "{\"hookSpecificOutput\":{\"hookEventName\":\"SessionStart\",\"additionalContext\":\"$CONTEXT\"}}"
```

### Task 11.3: Create UserPromptSubmit Hook

**File:** `hooks/workflow-advisor.py`

**Input (stdin JSON):**
```json
{
  "hook_event_name": "UserPromptSubmit",
  "session_id": "abc123",
  "prompt": "let's start implementing the login component",
  "cwd": "/path/to/project"
}
```

**Implementation:**
```python
#!/usr/bin/env python3
"""Provide workflow guidance for out-of-sequence actions."""

import json
import sys
import os
import re

def main():
    # Read input
    input_data = json.load(sys.stdin)
    prompt = input_data.get('prompt', '').lower()
    cwd = input_data.get('cwd', '')

    # Keyword detection
    implement_keywords = ["implement", "write code", "build", "create the", "start coding", "let's code"]
    review_keywords = ["review", "check", "validate", "critique"]
    pr_keywords = ["create pr", "pull request", "merge", "push"]

    # Detect intent
    intent = None
    if any(kw in prompt for kw in implement_keywords):
        intent = "implement"
    elif any(kw in prompt for kw in pr_keywords):
        intent = "pr"
    elif any(kw in prompt for kw in review_keywords):
        intent = "review"

    if not intent:
        # No workflow-relevant intent detected
        print('{}')
        return

    # Find active feature and check stage
    status_file = find_status_file(cwd)
    if not status_file:
        print('{}')
        return

    stage = get_current_stage(status_file)

    # Stage validation
    warnings = []

    if intent == "implement" and stage not in ["implementing", "worktree"]:
        warnings.append(f"⚠️ Want to implement but reviews not complete. Current stage: {stage}")

    if intent == "pr" and stage != "finishing":
        warnings.append(f"⚠️ Want to create PR but workflow not complete. Current stage: {stage}")

    if intent == "review" and stage == "brainstorming":
        warnings.append(f"⚠️ Want to review but plan not written yet. Current stage: {stage}")

    if warnings:
        output = {"systemMessage": " | ".join(warnings)}
        print(json.dumps(output))
    else:
        print('{}')

def find_status_file(cwd):
    """Find STATUS.md for active feature."""
    active_file = os.path.join(cwd, "docs/plans/ACTIVE.md")
    if os.path.exists(active_file):
        with open(active_file) as f:
            content = f.read()
            match = re.search(r'## Current Feature\n(\S+)', content)
            if match:
                feature = match.group(1)
                return os.path.join(cwd, f"docs/plans/{feature}/STATUS.md")

    # Try to find any STATUS.md
    plans_dir = os.path.join(cwd, "docs/plans")
    if os.path.exists(plans_dir):
        for item in os.listdir(plans_dir):
            status = os.path.join(plans_dir, item, "STATUS.md")
            if os.path.exists(status):
                return status

    return None

def get_current_stage(status_file):
    """Extract current stage from STATUS.md."""
    if not os.path.exists(status_file):
        return None

    with open(status_file) as f:
        content = f.read()
        match = re.search(r'\*\*Stage:\*\* (\S+)', content)
        if match:
            return match.group(1)

    return None

if __name__ == "__main__":
    main()
```

### Task 11.4: Create PreToolUse Hook (Write)

**File:** `hooks/write-validator.py`

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

**Implementation:**
```python
#!/usr/bin/env python3
"""Validate file writes against workflow state."""

import json
import sys
import os
import re

# Implementation directories (writes here require implementing stage)
IMPL_PATTERNS = [
    r'/src/',
    r'/lib/',
    r'/app/',
    r'/components/',
    r'/pages/',
    r'/api/',
    r'/server/',
]

# Excluded patterns (always allowed)
EXCLUDED_PATTERNS = [
    r'/docs/',
    r'/tests/',
    r'\.md$',
    r'\.json$',
    r'\.yaml$',
    r'\.yml$',
]

def main():
    input_data = json.load(sys.stdin)
    cwd = input_data.get('cwd', '')
    tool_input = input_data.get('tool_input', {})
    file_path = tool_input.get('file_path', '')

    # Check if this is an implementation file
    is_impl = any(re.search(p, file_path) for p in IMPL_PATTERNS)
    is_excluded = any(re.search(p, file_path) for p in EXCLUDED_PATTERNS)

    if not is_impl or is_excluded:
        # Allow non-implementation writes
        output = {
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "allow"
            }
        }
        print(json.dumps(output))
        return

    # Check workflow stage
    status_file = find_status_file(cwd)
    if not status_file:
        # No workflow, allow but warn
        output = {
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "allow"
            }
        }
        print(json.dumps(output))
        return

    stage = get_current_stage(status_file)

    # Implementation files require implementing stage
    impl_stages = ["implementing", "worktree", "finishing"]
    if stage not in impl_stages:
        output = {
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "ask",
                "permissionDecisionReason": f"Writing to implementation file but stage is '{stage}'. Reviews may not be complete. Proceed anyway?"
            }
        }
        print(json.dumps(output))
        return

    # Allow
    output = {
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "allow"
        }
    }
    print(json.dumps(output))

def find_status_file(cwd):
    """Find STATUS.md for active feature."""
    # Same implementation as workflow-advisor.py
    active_file = os.path.join(cwd, "docs/plans/ACTIVE.md")
    if os.path.exists(active_file):
        with open(active_file) as f:
            content = f.read()
            match = re.search(r'## Current Feature\n(\S+)', content)
            if match:
                feature = match.group(1)
                return os.path.join(cwd, f"docs/plans/{feature}/STATUS.md")

    plans_dir = os.path.join(cwd, "docs/plans")
    if os.path.exists(plans_dir):
        for item in os.listdir(plans_dir):
            status = os.path.join(plans_dir, item, "STATUS.md")
            if os.path.exists(status):
                return status

    return None

def get_current_stage(status_file):
    """Extract current stage from STATUS.md."""
    if not os.path.exists(status_file):
        return None

    with open(status_file) as f:
        content = f.read()
        match = re.search(r'\*\*Stage:\*\* (\S+)', content)
        if match:
            return match.group(1)

    return None

if __name__ == "__main__":
    main()
```

### Task 11.5: Create PostToolUse Hook (Write)

**File:** `hooks/task-created.sh`

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

**Implementation:**
```bash
#!/bin/bash
# Update state when task files created

set -e

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path')
CWD=$(echo "$INPUT" | jq -r '.cwd')

# Check if this is a task file
if [[ "$FILE_PATH" =~ /docs/plans/.*/tasks/[0-9]+-.*\.md$ ]]; then
    TASK_NAME=$(basename "$FILE_PATH")
    echo "{\"systemMessage\":\"✅ Task file created: $TASK_NAME. Domain review recommended as next step.\"}"
else
    echo '{}'
fi
```

### Task 11.6: Create SubagentStop Hook

**File:** `hooks/subagent-review.py`

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

**Implementation:**
```python
#!/usr/bin/env python3
"""Validate implementation subagent completion and remind about code review."""

import json
import sys
import os

def main():
    input_data = json.load(sys.stdin)
    transcript_path = input_data.get('transcript_path', '')
    cwd = input_data.get('cwd', '')

    # Read transcript to find recent subagent invocation
    if not os.path.exists(transcript_path):
        print('{}')
        return

    # Parse transcript to find Task tool calls
    impl_keywords = ["implement", "build", "create", "write code", "develop"]
    review_keywords = ["code-reviewer", "review"]

    found_implementation = False
    found_review = False

    with open(transcript_path) as f:
        for line in f:
            try:
                entry = json.loads(line)
                # Look for Task tool usage
                if 'tool_name' in entry and entry['tool_name'] == 'Task':
                    task_input = entry.get('tool_input', {})
                    description = task_input.get('description', '').lower()
                    prompt = task_input.get('prompt', '').lower()

                    if any(kw in description or kw in prompt for kw in impl_keywords):
                        found_implementation = True
                    if any(kw in description or kw in prompt for kw in review_keywords):
                        found_review = True
            except json.JSONDecodeError:
                continue

    # If implementation but no review, remind
    if found_implementation and not found_review:
        output = {
            "systemMessage": "Implementation complete. Invoke code-reviewer agent before proceeding to next task."
        }
        print(json.dumps(output))
    else:
        print('{}')

if __name__ == "__main__":
    main()
```

### Task 11.7: Create Stop Hook

**File:** `hooks/learnings-check.sh`

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

**Implementation:**
```bash
#!/bin/bash
# Ensure learnings captured before session ends

set -e

INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd')

# Find active feature
ACTIVE_FILE="$CWD/docs/plans/ACTIVE.md"
if [ -f "$ACTIVE_FILE" ]; then
    FEATURE=$(grep -A1 "## Current Feature" "$ACTIVE_FILE" | tail -1 | tr -d ' ')
else
    # Try to find any feature
    FEATURE=$(ls "$CWD/docs/plans/" 2>/dev/null | grep -v "ACTIVE.md" | grep -v "archived" | head -1)
fi

if [ -z "$FEATURE" ]; then
    echo '{}'
    exit 0
fi

# Check STATUS.md
STATUS_FILE="$CWD/docs/plans/$FEATURE/STATUS.md"
if [ ! -f "$STATUS_FILE" ]; then
    echo '{}'
    exit 0
fi

# Get stage
STAGE=$(grep "^\- \*\*Stage:\*\*" "$STATUS_FILE" | sed 's/.*Stage:\*\* //')

# Only check if in implementation or later stages
if [[ "$STAGE" == "implementing" || "$STAGE" == "lessons-learned" ]]; then
    # Check if learnings.md was modified recently
    LEARNINGS_FILE="$CWD/docs/plans/$FEATURE/learnings.md"
    if [ -f "$LEARNINGS_FILE" ]; then
        # Check if file has content beyond template
        CONTENT_LINES=$(grep -v "^#" "$LEARNINGS_FILE" | grep -v "^<!--" | grep -v "^$" | wc -l)
        if [ "$CONTENT_LINES" -lt 3 ]; then
            echo '{"decision":"block","reason":"Ask user about learnings before ending session. Implementation work was done but learnings.md appears empty."}'
            exit 0
        fi
    else
        echo '{"decision":"block","reason":"learnings.md not found. Create and capture learnings before ending session."}'
        exit 0
    fi
fi

echo '{}'
```

**Commits for Phase 11:**
```bash
chmod +x hooks/*.sh hooks/*.py
git add hooks/
git commit -m "feat: add workflow automation hooks"
```

---

## Phase 12: Fork Skills

### Task 12.1: Fork frontend-design Skill

**Fork source:** `frontend-design:frontend-design` plugin skill

**Why fork instead of using original:**
1. **Master doc integration** — Original doesn't know about `/docs/master/design-system.md`
2. **Learnings capture** — Need to append to learnings.md during implementation
3. **Domain review integration** — Frontend critic should reference these principles
4. **Workflow integration** — Must fit into devpowers handoff chain

**Directory structure:**
```
skills/frontend-design/
├── SKILL.md
├── references/
│   └── design-principles.md
└── examples/
    └── component-patterns/
```

**File:** `skills/frontend-design/SKILL.md`

```markdown
---
name: frontend-design
description: >
  This skill should be used when the user asks to "design a component",
  "build the UI", "create the interface", "make it look good", "avoid generic design",
  or when implementing frontend tasks. Creates distinctive, non-generic UI
  that follows project design system.
version: 1.0.0
forked_from: frontend-design:frontend-design v2.3.0
---

# Frontend Design (devpowers fork)

**Fork notes:** Customized from frontend-design plugin. Key changes:
- Master document integration
- Learnings capture handoff
- Domain review integration

## Devpowers Integration

**Reads from:**
- `/docs/master/design-system.md` — Project design system
- `/docs/master/lessons-learned/frontend.md` — Past learnings

**Writes to:**
- `learnings.md` — New insights (append only)

**Hands off to:**
- Continue with implementation task

## Before Designing

1. Read `/docs/master/design-system.md` for:
   - Color palette
   - Typography scale
   - Spacing system
   - Component patterns

2. Read `/docs/master/lessons-learned/frontend.md` for:
   - Patterns that work
   - Anti-patterns to avoid
   - Framework-specific gotchas

## Key Behaviors

- Avoid generic "AI look" patterns
- Focus on distinctive, purposeful design
- Maintain project-specific component patterns
- Use project's established color/typography/spacing

## After Implementing

Append to learnings.md when discovering:
- What patterns worked well
- What patterns to avoid next time
- Any design system updates needed

## Changelog

### v1.0.0 (devpowers)
- Added master document integration
- Added learnings capture handoff
- Modified to reference project design system
```

### Task 12.2: Fork playwright-testing Skill

**Fork source:** `playwright-skill:playwright-skill` plugin skill

**Why fork instead of using original:**
1. **Journey map integration** — Original generates tests ad-hoc; we derive from journey maps
2. **Master doc integration** — Need to read `/docs/master/lessons-learned/testing.md`
3. **Learnings capture** — Append to learnings.md when tests reveal unexpected behavior
4. **Domain review integration** — Testing critic should reference this skill

**Directory structure:**
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

**File:** `skills/playwright-testing/SKILL.md`

```markdown
---
name: playwright-testing
description: >
  This skill should be used when the user asks to "write e2e tests",
  "implement tests from journeys", "set up Playwright", "test the user flows",
  or when implementing test tasks. Generates tests from user journey maps
  for comprehensive coverage.
version: 1.0.0
forked_from: playwright-skill:playwright-skill v1.0.0
---

# Playwright Testing (devpowers fork)

**Fork notes:** Customized from playwright-skill plugin. Key changes:
- Journey map integration for test derivation
- Master document integration
- Learnings capture when tests reveal unexpected behavior

## Devpowers Integration

**Reads from:**
- `/docs/plans/[feature]/journeys/` — User journey maps
- `/docs/master/lessons-learned/testing.md` — Past testing learnings
- Task documents with "E2E Test Plan" section

**Writes to:**
- `learnings.md` — When tests reveal unexpected behavior

## Key Behaviors

- Generates tests FROM user journey maps (not ad-hoc)
- Covers error states, edge cases, accessibility per journey categories
- Validates against journey map completeness

## Test Derivation Process

1. Read journey map for component
2. For each journey:
   - Create test case with descriptive name
   - Implement steps from journey
   - Add assertions for expected outcomes
3. Verify all journeys have corresponding tests

## After Testing

Append to learnings.md when:
- Tests reveal unexpected application behavior
- New edge cases discovered
- Testing patterns prove useful

## Changelog

### v1.0.0 (devpowers)
- Added journey map integration
- Added master document integration
- Added learnings capture
```

**Commits for Phase 12:**
```bash
mkdir -p skills/frontend-design/{references,examples/component-patterns}
mkdir -p skills/playwright-testing/{scripts,references,examples/sample-tests}
git add skills/frontend-design/ skills/playwright-testing/
git commit -m "feat: add forked skills (frontend-design, playwright-testing)"
```

---

## Implementation Order Summary

| Phase | Focus | Dependencies |
|-------|-------|--------------|
| 1 | Cleanup | None |
| 2 | State infrastructure | None |
| 3 | Entry-point skill | Phase 2 |
| 4 | Project setup | Phase 2 |
| 5 | Core workflow skills | Phase 3, 4 |
| 6 | Domain review system | Phase 5 |
| 7 | Cross-domain review | Phase 6 |
| 8 | User journey mapping | Phase 7 |
| 9 | Lessons learned | Phase 8 |
| 10 | Implementation skills | Phase 6 |
| 11 | Hooks | Phase 2-9 |
| 12 | Fork skills | Phase 6 |

**Recommended execution:**
1. Phase 1 (cleanup) - immediately
2. Phases 2-4 (foundation) - in order
3. Phases 5-9 (workflow) - in order
4. Phase 10-11 (automation) - can parallelize
5. Phase 12 (forks) - defer if needed

---

## Revision History

### v1 - 2026-01-16 - Initial Merged Plan

Created by merging:
- `2026-01-16-devpowers-workflow-design.md` (full specifications)
- `2026-01-16-devpowers-migration-cleanup.md` (gap analysis)

All content from both documents is included in this single comprehensive plan.
