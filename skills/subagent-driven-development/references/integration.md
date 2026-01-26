# Integration with Other Skills

## Required Workflow Skills

- **devpowers:writing-plans** - Creates the plan this skill executes
- **devpowers:requesting-code-review** - Code review template for reviewer subagents
- **devpowers:finishing-a-development-branch** - Complete development after all tasks

## Subagent Skills

**Implementer subagents should use:**
- **devpowers:test-driven-development** - TDD for each task

**Domain-specific skills for implementer subagents:**
- **devpowers:frontend-design** - For UI component tasks (avoids generic AI aesthetics, uses project design system)
- **devpowers:playwright-testing** - For E2E test tasks (derives tests from user journey maps)

When dispatching implementer subagents, include in context:
- For UI tasks: "Use devpowers:frontend-design skill. Read /docs/master/design-system.md first."
- For E2E test tasks: "Use devpowers:playwright-testing skill. Derive tests from /docs/plans/[feature]/journeys/."

**Problem-solving skills for implementer subagents:**
- **devpowers:systematic-debugging** - When encountering bugs or unexpected behavior
- **devpowers:verification-before-completion** - Before claiming any task is complete

## Parallel Execution

- **devpowers:dispatching-parallel-agents** - When multiple independent tasks can run concurrently

## Alternative Workflow

- **devpowers:executing-plans** - Use for parallel session instead of same-session execution
