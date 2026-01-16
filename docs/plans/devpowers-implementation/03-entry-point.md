# Task 3: Entry-Point Skill (using-devpowers)

> **Devpowers Implementation** | [← State Infrastructure](./02-state-infrastructure.md) | [Next: Project Setup →](./04-project-setup.md)

---

## Context

**This task creates the using-devpowers skill as the workflow entry point.** It detects project state, assesses scope, and routes to the appropriate skill.

### Prerequisites
- **Task 2** completed (state templates exist)

### What This Task Creates
- Updated `skills/using-devpowers/SKILL.md` with workflow entry-point logic

### Tasks That Depend on This
- **Task 5** (Core Workflow Skills) - handoff chain starts here

### Parallel Tasks
This task can be done in parallel with:
- **Task 4** (Project Setup)

---

## Files to Modify

- `skills/using-devpowers/SKILL.md`

---

## Steps

### Step 1: Read current SKILL.md

```bash
cat skills/using-devpowers/SKILL.md
```

Note the current structure to preserve any useful content.

### Step 2: Update SKILL.md with workflow entry-point

Replace or update `skills/using-devpowers/SKILL.md` with:

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

## Reading STATUS.md

When STATUS.md exists, extract:
- **Stage** — Current workflow stage
- **Scope** — Trivial/Small/Medium/Large
- **Next Action** — What to do next

## Handoffs

After routing:
- If project-setup needed: "No master docs found. Let's set up the project first." → Invoke `project-setup`
- If new feature: "Ready to brainstorm [feature]?" → Invoke `brainstorming`
- If resume: "Resuming [feature] at [stage]. [Next action]?" → Invoke appropriate skill

## Skill Invocation Priority

Process skills first (determine HOW to approach):
1. brainstorming
2. systematic-debugging
3. writing-plans

Implementation skills second (guide execution):
1. subagent-driven-development
2. test-driven-development
3. frontend-design
```

### Step 3: Verify the update

```bash
head -50 skills/using-devpowers/SKILL.md
```

### Step 4: Commit

```bash
git add skills/using-devpowers/SKILL.md
git commit -m "feat: update using-devpowers as workflow entry-point

- Add project setup detection (/docs/master/)
- Add scope assessment (trivial/small/medium/large)
- Add workflow routing logic
- Add resume detection for existing features
- Add STATUS.md parsing for state"
```

---

## Verification Checklist

- [ ] `skills/using-devpowers/SKILL.md` updated
- [ ] Frontmatter has correct trigger phrases
- [ ] Entry-point workflow documented
- [ ] Scope tiers table included
- [ ] Handoff instructions included
- [ ] Changes committed

---

## Next Steps

Proceed to **[Task 4: Project Setup](./04-project-setup.md)** (can be done in parallel).

Or if Task 4 is complete, proceed to **[Task 5: Core Workflow Skills](./05-core-workflow-skills.md)**.
