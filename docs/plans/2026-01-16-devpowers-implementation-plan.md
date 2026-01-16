# Devpowers Workflow Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development to implement this plan task-by-task.

**Goal:** Transform devpowers from a superpowers fork into a comprehensive development workflow system with master documents, multi-stage reviews, and automated state tracking.

**Architecture:** A plugin-based workflow with explicit handoffs between skills, persistent state in STATUS.md/ACTIVE.md, domain-expert review stages, and hook-based automation. Skills guide users through brainstorming → planning → task breakdown → domain review → cross-domain review → user journey mapping → implementation → lessons learned.

**Tech Stack:** Claude Code plugin system (skills, hooks, agents), bash/python scripts for hooks, markdown templates for state tracking.

**Source of Truth:** `docs/plans/2026-01-16-devpowers-workflow-design.md` contains all detailed specifications, schemas, and algorithms referenced in this plan.

---

## Phase 1: Immediate Cleanup

### Task 1.1: Remove Superseded Skills

**Files:**
- Delete: `skills/executing-plans/` (entire directory)
- Delete: `skills/receiving-code-review/` (entire directory)
- Delete: `workflow` (root directory - working notes)

**Step 1: Verify directories exist and check contents**

Run: `ls -la skills/executing-plans/ skills/receiving-code-review/ workflow/ 2>/dev/null || echo "Some directories don't exist"`

**Step 2: Remove the directories**

```bash
rm -rf skills/executing-plans/
rm -rf skills/receiving-code-review/
rm -rf workflow/
```

**Step 3: Verify removal**

Run: `ls skills/ | grep -E "(executing-plans|receiving-code-review)" || echo "Skills removed"`

**Step 4: Commit**

```bash
git add -A
git commit -m "chore: remove superseded skills (executing-plans, receiving-code-review)"
```

---

### Task 1.2: Move reviewing-plans to skills/

**Files:**
- Move: `reviewing-plans/` → `skills/reviewing-plans/`

**Step 1: Verify source exists**

Run: `ls reviewing-plans/`

**Step 2: Move directory**

```bash
mv reviewing-plans/ skills/reviewing-plans/
```

**Step 3: Verify move**

Run: `ls skills/reviewing-plans/SKILL.md`

**Step 4: Commit**

```bash
git add -A
git commit -m "refactor: move reviewing-plans to skills/ for auto-discovery"
```

---

### Task 1.3: Fix References in reviewing-plans

**Files:**
- Modify: `skills/reviewing-plans/SKILL.md`

**Step 1: Read current file to find references**

Identify lines containing `superpowers:` that need updating.

**Step 2: Update references**

| Current | New |
|---------|-----|
| `superpowers:subagent-driven-development` | `devpowers:subagent-driven-development` |
| `superpowers:executing-plans` | Remove entirely (skill deleted) |
| `superpowers:writing-plans` | `devpowers:writing-plans` |

**Step 3: Remove executing-plans content**

Remove any content describing parallel session execution via `executing-plans` since that skill no longer exists.

**Step 4: Run validation**

Run: `grep -n "superpowers:" skills/reviewing-plans/SKILL.md` (should return empty)

**Step 5: Commit**

```bash
git add skills/reviewing-plans/SKILL.md
git commit -m "fix: update skill references from superpowers to devpowers"
```

---

## Phase 2: Workflow State Infrastructure

### Task 2.1: Create STATUS.md Template

**Files:**
- Create: `skills/using-devpowers/assets/STATUS-template.md`

**Step 1: Create directory structure**

```bash
mkdir -p skills/using-devpowers/assets
```

**Step 2: Write template**

Create `STATUS-template.md` with the template from workflow design doc (Section: STATUS.md Template):

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

## Next Action
[What should happen next]

## Recovery Info
- **Partial Progress:** [description of what's saved if interrupted]
- **Resume Command:** [suggested skill invocation]
```

**Step 3: Commit**

```bash
git add skills/using-devpowers/assets/
git commit -m "feat: add STATUS.md template for workflow state tracking"
```

---

### Task 2.2: Create ACTIVE.md Template

**Files:**
- Create: `skills/using-devpowers/assets/ACTIVE-template.md`

**Step 1: Write template**

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

**Step 2: Commit**

```bash
git add skills/using-devpowers/assets/ACTIVE-template.md
git commit -m "feat: add ACTIVE.md template for multi-feature tracking"
```

---

### Task 2.3: Create Learnings Log Template

**Files:**
- Create: `skills/using-devpowers/assets/learnings-template.md`

**Step 1: Write template**

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

**Step 2: Commit**

```bash
git add skills/using-devpowers/assets/learnings-template.md
git commit -m "feat: add learnings.md template"
```

---

## Phase 3: Entry-Point Skill

### Task 3.1: Update using-devpowers Skill

**Files:**
- Modify: `skills/using-devpowers/SKILL.md`

**Step 1: Read current content**

Read `skills/using-devpowers/SKILL.md` to understand current structure.

**Step 2: Update frontmatter**

```yaml
---
name: using-devpowers
description: >
  This skill should be used when the user asks to "start a feature",
  "use devpowers", "plan a new feature", "begin development", "work on [feature]",
  or when starting any non-trivial development task. Provides workflow overview,
  scope detection, and routes to appropriate starting skill.
---
```

**Step 3: Add workflow entry-point logic**

The skill should:
1. Check `/docs/master/` exists → if not, hand off to `project-setup`
2. Check `/docs/plans/` for existing features → offer resume or start new
3. Assess scope (trivial/small/medium/large)
4. Route to appropriate skill

**Step 4: Include scope tier definitions**

From workflow design:
- **Trivial:** Direct implementation, no planning
- **Small:** Brainstorm → Plan → Implement → Lessons (optional)
- **Medium:** Full workflow, skip user journey mapping if no UI
- **Large:** Full workflow

**Step 5: Add handoff routing logic**

- If `/docs/master/` missing → `project-setup`
- If new feature → `brainstorming`
- If resume → appropriate skill based on STATUS.md

**Step 6: Commit**

```bash
git add skills/using-devpowers/SKILL.md
git commit -m "feat: update using-devpowers as workflow entry-point"
```

---

## Phase 4: Project Setup Skill

### Task 4.1: Create project-setup Skill Structure

**Files:**
- Create: `skills/project-setup/SKILL.md`
- Create: `skills/project-setup/scripts/detect-stack.sh`
- Create: `skills/project-setup/references/stack-detection-guide.md`
- Create: `skills/project-setup/assets/master-doc-templates/design-system.md`
- Create: `skills/project-setup/assets/master-doc-templates/lessons-learned/frontend.md`
- Create: `skills/project-setup/assets/master-doc-templates/lessons-learned/backend.md`
- Create: `skills/project-setup/assets/master-doc-templates/lessons-learned/testing.md`
- Create: `skills/project-setup/assets/master-doc-templates/lessons-learned/infrastructure.md`

**Step 1: Create directory structure**

```bash
mkdir -p skills/project-setup/{scripts,references,assets/master-doc-templates/lessons-learned}
```

**Step 2: Write SKILL.md**

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
4. Tailor templates based on detected stack
5. Write tailored docs to `/docs/master/`
6. Commit initial master docs
7. Handoff: "Project setup complete. Ready to start brainstorming a feature?"
```

**Step 3: Write detect-stack.sh**

```bash
#!/bin/bash
# Detect technology stack from project files

echo "=== Stack Detection ==="

# Check for package.json (Node.js ecosystem)
if [ -f "package.json" ]; then
    echo "DETECTED: Node.js project"
    echo "Dependencies:"
    cat package.json | grep -E '"(react|vue|svelte|angular|next|express|fastify)"' || echo "  (none detected)"
fi

# Check for Python
if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ] || [ -f "setup.py" ]; then
    echo "DETECTED: Python project"
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
if [ -f "Dockerfile" ] || [ -f "docker-compose.yml" ]; then
    echo "DETECTED: Docker/containerized"
fi

# Check folder structure
echo ""
echo "=== Directory Structure ==="
ls -d */ 2>/dev/null | head -20
```

**Step 4: Write master doc templates**

Create each template per the specifications in workflow design doc (Section: Template Contents).

**Step 5: Commit**

```bash
git add skills/project-setup/
git commit -m "feat: add project-setup skill with master doc templates"
```

---

## Phase 5: Update Existing Skills

### Task 5.1: Update brainstorming Skill

**Files:**
- Modify: `skills/brainstorming/SKILL.md`

**Changes:**
- [ ] Add scope assessment at start (trivial/small/medium/large)
- [ ] Output to `/docs/plans/[feature]/` structure
- [ ] Reference master docs during design exploration
- [ ] Create `learnings.md` file when feature folder created
- [ ] Create `STATUS.md` from template when feature folder created

**Commit message:** `feat: update brainstorming for devpowers workflow`

---

### Task 5.2: Update writing-plans Skill

**Files:**
- Modify: `skills/writing-plans/SKILL.md`

**Changes:**
- [ ] Focus on high-level architecture, not implementation details
- [ ] Output to `/docs/plans/[feature]/high-level-plan.md`
- [ ] Add handoff to `reviewing-plans`
- [ ] Update STATUS.md on completion

**Commit message:** `feat: update writing-plans for devpowers workflow`

---

### Task 5.3: Update chunking-plans Skill

**Files:**
- Modify: `skills/chunking-plans/SKILL.md` (or create if needed via chunking-plans plugin)

**Changes:**
- [ ] Add recursive subdivision rules (max depth: 3 levels)
- [ ] Path structure: `tasks/NN-name/subtasks/`
- [ ] Integration with domain-review (pause/resume)
- [ ] Round counter resets for newly chunked tasks

**Commit message:** `feat: update chunking-plans with recursive subdivision`

---

### Task 5.4: Update subagent-driven-development Skill

**Files:**
- Modify: `skills/subagent-driven-development/SKILL.md`

**Changes:**
- [ ] Implementation agents reference test plan in task docs
- [ ] Add instructions to append to `learnings.md`
- [ ] Ensure TDD flow uses pre-planned test cases
- [ ] Include code review step from merged `receiving-code-review`

**Commit message:** `feat: update subagent-driven-development for devpowers workflow`

---

### Task 5.5: Update reviewing-plans Skill (Full)

**Files:**
- Modify: `skills/reviewing-plans/SKILL.md`
- Create: `skills/reviewing-plans/feasibility-critic.md`
- Create: `skills/reviewing-plans/completeness-critic.md`
- Create: `skills/reviewing-plans/simplicity-critic.md`
- Create: `skills/reviewing-plans/references/severity-guide.md`

**Step 1: Update SKILL.md with proper structure**

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

**Step 2: Create three parallel critics**

Per workflow design:
- **Feasibility** — Will this architecture work? Correct assumptions? Dependencies available?
- **Completeness** — All requirements covered? Error handling? Edge cases?
- **Simplicity** — Over-engineered? YAGNI violations? Unnecessary complexity?

**Step 3: Create severity guide**

```markdown
# Issue Severity Guide

## CRITICAL
Must fix before proceeding. Blocks workflow.
- Architectural flaws that would require rewrite
- Missing core requirements
- Security vulnerabilities

## IMPORTANT
Should fix before proceeding.
- Missing edge cases
- Incomplete error handling
- Non-obvious dependencies

## MINOR
Can proceed, fix before merge.
- Code style concerns
- Minor optimizations

## NITPICK
Optional improvements.
- Naming suggestions
- Documentation improvements
```

**Commit message:** `feat: add parallel critics to reviewing-plans skill`

---

## Phase 6: Task Breakdown Skill

### Task 6.1: Create task-breakdown Skill

**Files:**
- Create: `skills/task-breakdown/SKILL.md`
- Create: `skills/task-breakdown/breakdown-agent.md`
- Create: `skills/task-breakdown/references/task-sizing-guide.md`
- Create: `skills/task-breakdown/assets/task-template.md`
- Create: `skills/task-breakdown/assets/overview-template.md`

**Step 1: Create directory structure**

```bash
mkdir -p skills/task-breakdown/{references,assets}
```

**Step 2: Write SKILL.md**

Use the specification from workflow design (Section: task-breakdown).

**Step 3: Create task document template**

Per workflow design (Section: Task document template).

**Step 4: Create overview template**

Per workflow design (Section: 00-overview.md template).

**Commit message:** `feat: add task-breakdown skill`

---

## Phase 7: Domain Review System

### Task 7.1: Create domain-review Skill

**Files:**
- Create: `skills/domain-review/SKILL.md`
- Create: `skills/domain-review/frontend-critic.md`
- Create: `skills/domain-review/backend-critic.md`
- Create: `skills/domain-review/testing-critic.md`
- Create: `skills/domain-review/infrastructure-critic.md`
- Create: `skills/domain-review/references/severity-guide.md`

**Step 1: Create directory structure**

```bash
mkdir -p skills/domain-review/references
```

**Step 2: Write SKILL.md with domain detection**

Include domain detection heuristics from workflow design (Section: Domain detection rules).

**Step 3: Create critic prompts**

Each critic checks:
- Feasibility — Will this approach work?
- Completeness — All cases covered?
- Simplicity — Over-engineered?
- Patterns — Follows master docs?

**Commit message:** `feat: add domain-review skill with multi-critic system`

---

### Task 7.2: Create Domain Reviewer Agents

**Files:**
- Create: `agents/frontend-reviewer.md`
- Create: `agents/backend-reviewer.md`
- Create: `agents/testing-reviewer.md`
- Create: `agents/infrastructure-reviewer.md`
- Create: `agents/integration-reviewer.md`

**Step 1: Create agents with proper structure**

Per workflow design (Section: Domain Reviewer Agents), each agent needs:
- Third-person description with trigger conditions
- `<example>` blocks
- Reference to master docs
- Severity classification output
- Read-only constraint in system prompt

**Step 2: Apply tool restrictions**

| Agent | Tools |
|-------|-------|
| frontend-reviewer | Read, Grep, Glob, WebFetch |
| backend-reviewer | Read, Grep, Glob, Bash (read-only) |
| testing-reviewer | Read, Grep, Glob, Bash (read-only) |
| infrastructure-reviewer | Read, Grep, Glob, Bash (read-only) |
| integration-reviewer | Read, Grep, Glob |

**Commit message:** `feat: add domain reviewer agents`

---

## Phase 8: Cross-Domain Review

### Task 8.1: Create cross-domain-review Skill

**Files:**
- Create: `skills/cross-domain-review/SKILL.md`
- Create: `skills/cross-domain-review/integration-critic.md`
- Create: `skills/cross-domain-review/references/common-integration-issues.md`

**Step 1: Create skill**

Per workflow design (Section: cross-domain-review).

**Step 2: Implement routing protocol**

Include JSON routing schema from workflow design for bidirectional flow.

**Commit message:** `feat: add cross-domain-review skill`

---

## Phase 9: User Journey Mapping

### Task 9.1: Create user-journey-mapping Skill

**Files:**
- Create: `skills/user-journey-mapping/SKILL.md`
- Create: `skills/user-journey-mapping/journey-critic.md`
- Create: `skills/user-journey-mapping/references/journey-categories.md`
- Create: `skills/user-journey-mapping/examples/login-journey.md`

**Step 1: Create skill**

Per workflow design (Section: user-journey-mapping).

**Step 2: Create journey categories checklist**

- Happy paths
- Variations
- Error states
- Edge cases
- Interruptions
- Accessibility

**Commit message:** `feat: add user-journey-mapping skill`

---

## Phase 10: Lessons Learned

### Task 10.1: Create lessons-learned Skill

**Files:**
- Create: `skills/lessons-learned/SKILL.md`
- Create: `skills/lessons-learned/learnings-reviewer.md`
- Create: `skills/lessons-learned/references/update-categories.md`

**Step 1: Create skill**

Per workflow design (Section: lessons-learned).

**Step 2: Implement master doc merge algorithm**

Include classification step and merge strategies from workflow design.

**Commit message:** `feat: add lessons-learned skill`

---

## Phase 11: Hook-Based Automation

### Task 11.1: Create hooks.json Structure

**Files:**
- Modify: `hooks/hooks.json`

**Step 1: Update with full hook configuration**

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

**Commit message:** `feat: configure all workflow hooks`

---

### Task 11.2: Create SessionStart Hook

**Files:**
- Create: `hooks/session-start-workflow.sh`

**Implementation:** Per workflow design (Section: SessionStart Hook).

Detects workflow state, injects minimal context.

**Commit message:** `feat: add SessionStart workflow detection hook`

---

### Task 11.3: Create UserPromptSubmit Hook

**Files:**
- Create: `hooks/workflow-advisor.py`

**Implementation:** Per workflow design (Section: UserPromptSubmit Hook).

Provides workflow guidance for out-of-sequence actions.

**Commit message:** `feat: add UserPromptSubmit workflow advisor hook`

---

### Task 11.4: Create PreToolUse Hook (Write)

**Files:**
- Create: `hooks/write-validator.py`

**Implementation:** Per workflow design (Section: PreToolUse Hook).

Validates file writes against workflow state.

**Commit message:** `feat: add PreToolUse write validator hook`

---

### Task 11.5: Create PostToolUse Hook (Write)

**Files:**
- Create: `hooks/task-created.sh`

**Implementation:** Per workflow design (Section: PostToolUse Hook).

Updates state when task files created.

**Commit message:** `feat: add PostToolUse task created hook`

---

### Task 11.6: Create SubagentStop Hook

**Files:**
- Create: `hooks/subagent-review.py`

**Implementation:** Per workflow design (Section: SubagentStop Hook).

Validates implementation completion and code review.

**Commit message:** `feat: add SubagentStop review validation hook`

---

### Task 11.7: Create Stop Hook

**Files:**
- Create: `hooks/learnings-check.sh`

**Implementation:** Per workflow design (Section: Stop Hook).

Ensures learnings captured before session ends.

**Commit message:** `feat: add Stop learnings check hook`

---

## Phase 12: Fork Skills (Low Priority)

### Task 12.1: Fork frontend-design Skill

**Files:**
- Create: `skills/frontend-design/SKILL.md`
- Create: `skills/frontend-design/references/design-principles.md`
- Create: `skills/frontend-design/examples/component-patterns/`

**Implementation:** Per workflow design (Section: frontend-design fork).

Fork from `frontend-design:frontend-design`, add master doc integration.

**Commit message:** `feat: add frontend-design skill (forked)`

---

### Task 12.2: Fork playwright-testing Skill

**Files:**
- Create: `skills/playwright-testing/SKILL.md`
- Create: `skills/playwright-testing/scripts/scaffold-test.sh`
- Create: `skills/playwright-testing/references/testing-patterns.md`

**Implementation:** Per workflow design (Section: playwright-testing fork).

Fork from `playwright-skill:playwright-skill`, add journey map integration.

**Commit message:** `feat: add playwright-testing skill (forked)`

---

## Summary: Execution Order

1. **Phase 1** - Immediate cleanup (remove/move files)
2. **Phase 2** - Workflow state infrastructure (templates)
3. **Phase 3** - Entry-point skill (using-devpowers)
4. **Phase 4** - Project setup skill
5. **Phase 5** - Update existing skills (brainstorming, writing-plans, etc.)
6. **Phase 6** - Task breakdown skill
7. **Phase 7** - Domain review system (skill + agents)
8. **Phase 8** - Cross-domain review
9. **Phase 9** - User journey mapping
10. **Phase 10** - Lessons learned
11. **Phase 11** - Hook automation
12. **Phase 12** - Fork skills (defer if needed)

---

## Revision History

### v1 - 2026-01-16 - Initial Merged Plan

Merged from:
- `2026-01-16-devpowers-workflow-design.md` (source of truth for specs)
- `2026-01-16-devpowers-migration-cleanup.md` (gap analysis and execution order)
