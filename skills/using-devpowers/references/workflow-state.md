# Detecting Workflow State

Check for existing artifacts:
- `/docs/master/` exists → project setup complete
- `/docs/plans/[feature]/` exists → brainstorming done
- `high-level-plan.md` exists → planning done
- `/tasks/` folder exists → breakdown done
- `STATUS.md` → read for current stage and scope

If resuming, prompt: "Found existing [artifacts] for [feature] (scope: [X]). Continue from [stage]?"

## Reading STATUS.md

When STATUS.md exists, extract:
- **Stage** — Current workflow stage
- **Scope** — Trivial/Small/Medium/Large
- **Next Action** — What to do next

## How to Access Skills

**In Claude Code:** Use the `Skill` tool. When you invoke a skill, its content is loaded and presented to you—follow it directly. Never use the Read tool on skill files.

**In other environments:** Check your platform's documentation for how skills are loaded.

## Skill Priority

When multiple skills could apply, use this order:

1. **Process skills first** (brainstorming, debugging) - these determine HOW to approach the task
2. **Implementation skills second** (frontend-design, mcp-builder) - these guide execution

"Let's build X" → brainstorming first, then implementation skills.
"Fix this bug" → debugging first, then domain-specific skills.

## Skill Types

**Rigid** (TDD, debugging): Follow exactly. Don't adapt away discipline.

**Flexible** (patterns): Adapt principles to context.

The skill itself tells you which.

## User Instructions

Instructions say WHAT, not HOW. "Add X" or "Fix Y" doesn't mean skip workflows.
