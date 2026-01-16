# Task 2: Workflow State Infrastructure

> **Devpowers Implementation** | [← Cleanup](./01-cleanup.md) | [Next: Entry Point →](./03-entry-point.md)

---

## Context

**This task creates the templates for workflow state tracking.** STATUS.md, ACTIVE.md, and learnings.md templates enable session resumption and progress tracking.

### Prerequisites
- **Task 1** completed (cleanup done)

### What This Task Creates
- `skills/using-devpowers/assets/STATUS-template.md`
- `skills/using-devpowers/assets/ACTIVE-template.md`
- `skills/using-devpowers/assets/learnings-template.md`

### Tasks That Depend on This
- **Task 3** (Entry Point) - uses these templates
- **Task 4** (Project Setup) - creates learnings.md from template
- **Task 11** (Hooks) - reads/writes STATUS.md

---

## Files to Create

- `skills/using-devpowers/assets/STATUS-template.md`
- `skills/using-devpowers/assets/ACTIVE-template.md`
- `skills/using-devpowers/assets/learnings-template.md`

---

## Steps

### Step 1: Create directory structure

```bash
mkdir -p skills/using-devpowers/assets
```

### Step 2: Create STATUS-template.md

Create `skills/using-devpowers/assets/STATUS-template.md`:

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

### Step 3: Create ACTIVE-template.md

Create `skills/using-devpowers/assets/ACTIVE-template.md`:

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

### Step 4: Create learnings-template.md

Create `skills/using-devpowers/assets/learnings-template.md`:

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

### Step 5: Verify files created

```bash
ls -la skills/using-devpowers/assets/
```

**Expected:** Three template files listed

### Step 6: Commit

```bash
git add skills/using-devpowers/assets/
git commit -m "feat: add workflow state templates

- STATUS-template.md for feature workflow tracking
- ACTIVE-template.md for multi-feature management
- learnings-template.md for capturing insights"
```

---

## Verification Checklist

- [ ] `skills/using-devpowers/assets/` directory exists
- [ ] `STATUS-template.md` exists with all sections
- [ ] `ACTIVE-template.md` exists
- [ ] `learnings-template.md` exists with phase sections
- [ ] Changes committed

---

## State Machine Reference

Valid workflow stages (for STATUS.md):

```
brainstorming → high-level-plan → reviewing-plans → task-breakdown →
domain-review → cross-domain-review → user-journey-mapping →
worktree → implementing → lessons-learned → finishing
```

---

## Next Steps

After this task, proceed to **[Task 3: Entry Point](./03-entry-point.md)**.

Tasks 3 and 4 can be done in parallel.
