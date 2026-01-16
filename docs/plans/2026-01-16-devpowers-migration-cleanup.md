# Devpowers Migration & Cleanup Plan

This document tracks the work needed to align the current devpowers codebase with the workflow design plan (`2026-01-16-devpowers-workflow-design.md`).

**Created:** 2026-01-16
**Status:** Draft

---

## Phase 1: Immediate Cleanup (No New Features)

### 1.1 Files to Remove

| File/Directory | Reason | Status |
|---------------|--------|--------|
| `skills/executing-plans/` | Superseded by `subagent-driven-development` | [ ] |
| `skills/receiving-code-review/` | Merged into `subagent-driven-development` | [ ] |
| `workflow` (root) | Working notes - content captured in design doc | [ ] |

### 1.2 Files to Move

| Current Location | New Location | Reason | Status |
|-----------------|--------------|--------|--------|
| `reviewing-plans/` | `skills/reviewing-plans/` | Skills must be in `skills/` for auto-discovery | [ ] |

### 1.3 Fix superpowers: References

**File:** `reviewing-plans/SKILL.md` (will be `skills/reviewing-plans/SKILL.md` after move)

| Line | Current | New | Status |
|------|---------|-----|--------|
| 135 | `superpowers:subagent-driven-development` | `devpowers:subagent-driven-development` | [ ] |
| 136 | `superpowers:executing-plans` | Remove (skill deleted) | [ ] |
| 225 | `superpowers:writing-plans` | `devpowers:writing-plans` | [ ] |
| 228 | `superpowers:subagent-driven-development` | `devpowers:subagent-driven-development` | [ ] |
| 229 | `superpowers:executing-plans` | Remove (skill deleted) | [ ] |

**Note:** Lines 136 and 229 reference `executing-plans` which is being deleted. The skill content needs updating to remove references to parallel session execution via `executing-plans`.

---

## Phase 2: New Skills Creation

Skills defined in the workflow design that don't yet exist.

### 2.1 High Priority (Core Workflow)

| Skill | Purpose | Dependencies | Status |
|-------|---------|--------------|--------|
| `project-setup` | Initialize project with master docs | None | [ ] |
| `task-breakdown` | Break high-level plan into task files | `reviewing-plans` | [ ] |
| `domain-review` | Multi-critic review of task documents | `task-breakdown` | [ ] |

### 2.2 Medium Priority (Full Workflow)

| Skill | Purpose | Dependencies | Status |
|-------|---------|--------------|--------|
| `cross-domain-review` | Validate integration between domains | `domain-review` | [ ] |
| `user-journey-mapping` | Map user behaviors for e2e tests | `cross-domain-review` | [ ] |
| `lessons-learned` | Capture learnings to master docs | Implementation complete | [ ] |

### 2.3 Low Priority (Enhancements)

| Skill | Purpose | Fork Source | Status |
|-------|---------|-------------|--------|
| `frontend-design` | Customized frontend design | `frontend-design:frontend-design` | [ ] |
| `playwright-testing` | Customized e2e testing | `playwright-skill:playwright-skill` | [ ] |

---

## Phase 3: Hooks Implementation

Current state: Only `SessionStart` hook exists with basic skill loading.

### 3.1 New Hooks to Create

| Hook Event | Purpose | Implementation File | Status |
|------------|---------|---------------------|--------|
| `UserPromptSubmit` | Workflow guidance for out-of-sequence actions | `hooks/workflow-advisor.py` | [ ] |
| `PreToolUse` (Write) | Validate file writes against workflow state | `hooks/write-validator.py` | [ ] |
| `PostToolUse` (Write) | Update state when task files created | `hooks/task-created.sh` | [ ] |
| `SubagentStop` | Validate implementation completion + code review | `hooks/subagent-review.py` | [ ] |
| `Stop` | Ensure learnings captured before session ends | `hooks/learnings-check.sh` | [ ] |

### 3.2 Update Existing Hooks

| Hook | Current State | Changes Needed | Status |
|------|---------------|----------------|--------|
| `SessionStart` | Loads `using-devpowers` skill | Add STATUS.md detection, ACTIVE.md parsing, workflow state injection | [ ] |

### 3.3 hooks.json Updates

Current `hooks/hooks.json` only defines SessionStart. Needs expansion to include all hook events per the design doc.

---

## Phase 4: Skill Modifications

Existing skills that need updates per the workflow design.

### 4.1 brainstorming

**Changes needed:**
- [ ] Add scope assessment at start (trivial/small/medium/large)
- [ ] Output to `/docs/plans/[feature]/` structure
- [ ] Reference master docs during design exploration
- [ ] Create `learnings.md` file when feature folder created

### 4.2 writing-plans

**Changes needed:**
- [ ] Focus on high-level architecture, not implementation details
- [ ] Output to `/docs/plans/[feature]/high-level-plan.md`
- [ ] Add handoff to `reviewing-plans`

### 4.3 chunking-plans

**Changes needed:**
- [ ] Add recursive subdivision rules
- [ ] Maximum depth: 3 levels
- [ ] Path structure: `tasks/NN-name/subtasks/`
- [ ] Integration with domain-review (pause/resume)

### 4.4 subagent-driven-development

**Changes needed:**
- [ ] Implementation agents reference test plan in task docs
- [ ] Add instructions to append to `learnings.md`
- [ ] Ensure TDD flow uses pre-planned test cases

### 4.5 test-driven-development

**Changes needed:**
- [ ] Reference test plan from task doc
- [ ] Adapt for both unit tests (from domain review) and e2e tests (from journey mapping)

### 4.6 reviewing-plans

**Changes needed (after move to skills/):**
- [ ] Update description triggers for devpowers workflow
- [ ] Remove references to deleted `executing-plans`
- [ ] Update handoff chain to `task-breakdown`
- [ ] Integrate with STATUS.md tracking

### 4.7 using-devpowers

The existing skill is a generic "how to use skills" guide. The workflow design specifies it should be the workflow entry-point with state detection.

**Changes needed:**
- [ ] Add project setup detection (check `/docs/master/` exists)
- [ ] Add scope assessment (trivial/small/medium/large)
- [ ] Add workflow routing (to `project-setup` or `brainstorming`)
- [ ] Add resume detection (check existing features in `/docs/plans/`)
- [ ] Add STATUS.md/ACTIVE.md parsing for workflow state injection
- [ ] Keep existing "how to use skills" content as foundation

---

## Phase 5: Infrastructure

### 5.1 Master Document Templates

Create `skills/project-setup/assets/master-doc-templates/`:

| File | Purpose | Status |
|------|---------|--------|
| `design-system.md` | UI patterns, component conventions | [ ] |
| `lessons-learned/frontend.md` | Frontend-specific learnings template | [ ] |
| `lessons-learned/backend.md` | Backend-specific learnings template | [ ] |
| `lessons-learned/testing.md` | Testing-specific learnings template | [ ] |
| `lessons-learned/infrastructure.md` | Infrastructure-specific learnings template | [ ] |

### 5.2 Domain Critic Prompts

Create for `skills/domain-review/`:

| File | Purpose | Status |
|------|---------|--------|
| `frontend-critic.md` | Frontend domain expert prompt | [ ] |
| `backend-critic.md` | Backend domain expert prompt | [ ] |
| `testing-critic.md` | Testing domain expert prompt | [ ] |
| `infrastructure-critic.md` | Infrastructure domain expert prompt | [ ] |
| `references/severity-guide.md` | Issue severity classification | [ ] |

### 5.3 Reviewing-Plans Critic Prompts

Create for `skills/reviewing-plans/` (after move from root):

| File | Purpose | Status |
|------|---------|--------|
| `feasibility-critic.md` | Will this architecture work? Correct assumptions? Dependencies available? | [ ] |
| `completeness-critic.md` | All requirements covered? Error handling? Edge cases? | [ ] |
| `simplicity-critic.md` | Over-engineered? YAGNI violations? Unnecessary complexity? | [ ] |
| `references/severity-guide.md` | Issue severity classification (CRITICAL/IMPORTANT/MINOR/NITPICK) | [ ] |

### 5.4 Other Critic Prompts

| Skill | Files Needed | Status |
|-------|--------------|--------|
| `cross-domain-review` | `integration-critic.md`, `references/common-integration-issues.md` | [ ] |
| `user-journey-mapping` | `journey-critic.md`, `references/journey-categories.md`, `examples/login-journey.md` | [ ] |
| `lessons-learned` | `learnings-reviewer.md`, `references/update-categories.md` | [ ] |

### 5.5 Stack Detection

Create `skills/project-setup/scripts/detect-stack.sh`:
- Examine package.json, folder structure, existing code
- Output detected frameworks for Claude to interpret

Create `skills/project-setup/references/stack-detection-guide.md`:
- Heuristics for Claude to apply judgment on stack detection results

### 5.6 Task Document Templates

Create for `skills/task-breakdown/assets/`:

| File | Purpose | Status |
|------|---------|--------|
| `task-template.md` | Template for `NN-task-name.md` files | [ ] |
| `overview-template.md` | Template for `00-overview.md` with dependency map | [ ] |

### 5.7 Workflow State Templates

Create for `skills/using-devpowers/assets/` or `skills/project-setup/assets/`:

| File | Purpose | Status |
|------|---------|--------|
| `STATUS-template.md` | Template for `/docs/plans/[feature]/STATUS.md` | [ ] |
| `ACTIVE-template.md` | Template for `/docs/plans/ACTIVE.md` (multi-feature tracking) | [ ] |
| `learnings-template.md` | Template for `/docs/plans/[feature]/learnings.md` | [ ] |

---

## Phase 6: Domain Reviewer Agents

The workflow design specifies 5 domain reviewer agents. Currently only `agents/code-reviewer.md` exists.

### 6.1 Agents to Create

| Agent | Purpose | Tools (read-only) | Status |
|-------|---------|-------------------|--------|
| `agents/frontend-reviewer.md` | UI/UX, components, design system adherence | Read, Grep, Glob, WebFetch | [ ] |
| `agents/backend-reviewer.md` | API design, data flow, error handling | Read, Grep, Glob, Bash | [ ] |
| `agents/testing-reviewer.md` | Test coverage, edge cases, test quality | Read, Grep, Glob, Bash | [ ] |
| `agents/infrastructure-reviewer.md` | Deployment, scaling, ops concerns | Read, Grep, Glob, Bash | [ ] |
| `agents/integration-reviewer.md` | Cross-domain interfaces, contracts | Read, Grep, Glob | [ ] |

**Note:** All reviewers are read-only by default. Bash access is for read-only commands (`git log`, `npm test`, `kubectl get`) only.

### 6.2 Agent Requirements

Per the workflow design, each agent must include:
- [ ] Third-person description with trigger conditions
- [ ] `<example>` blocks with context, user request, assistant response, and commentary
- [ ] Reference to master docs (`/docs/master/`)
- [ ] Severity classification output (CRITICAL/IMPORTANT/SUGGESTION)
- [ ] Read-only constraint documentation in system prompt

---

## Execution Order

Recommended order to minimize dependencies:

1. **Phase 1** - Immediate cleanup (can do now)
2. **Phase 4.6** - Fix reviewing-plans after move
3. **Phase 4.7** - Update using-devpowers with workflow entry-point logic
4. **Phase 2.1** - High priority skills (project-setup first)
5. **Phase 5.1-5.3** - Master doc templates and critic prompts
6. **Phase 3.2** - Update SessionStart hook
7. **Phase 4.1-4.5** - Modify existing skills
8. **Phase 6** - Domain reviewer agents (needed for domain-review skill)
9. **Phase 2.2** - Medium priority skills
10. **Phase 5.4-5.7** - Remaining infrastructure (other critics, templates)
11. **Phase 3.1** - New hooks
12. **Phase 2.3** - Fork skills (can defer)

---

## Notes

- The workflow design doc (`2026-01-16-devpowers-workflow-design.md`) is the source of truth for all schema definitions and hook formats
- Skills should reference the central review loop rules rather than defining custom limits
- All skills must use third-person description format with trigger phrases
- Hook implementations must match the JSON schemas defined in the design doc

---

## Revision History

### v2 - 2026-01-16 - Review Corrections

**Issues Addressed:**
- Added Phase 4.7: `using-devpowers` needs major modifications (workflow entry-point, state detection, scope assessment)
- Added Phase 6: Domain Reviewer Agents (5 agents missing: frontend, backend, testing, infrastructure, integration)
- Added Phase 5.3: Critic prompts for reviewing-plans (feasibility, completeness, simplicity critics)
- Added Phase 5.6: Task document templates (task-template.md, overview-template.md)
- Added Phase 5.7: Workflow state templates (STATUS.md, ACTIVE.md, learnings.md)
- Fixed duplicate section numbering (5.4 → 5.5)
- Updated execution order to include new phases

### v1 - 2026-01-16 - Initial Draft
- Created from project analysis comparing current state to workflow design
- Identified 3 files to remove, 1 to move, 5 reference fixes
- Documented 8 new skills, 6 hooks, 6 skill modifications needed
