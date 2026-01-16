---
name: writing-plans
description: Use when you have a spec or requirements for a multi-step task, before touching code
---

# Writing Plans

## Overview

Write comprehensive high-level architecture plans. Document the approach, major components, data flow, and key decisions. This plan will be reviewed by critics and then broken down into implementable tasks.

**Announce at start:** "I'm using the writing-plans skill to create the high-level plan."

## Plan Focus

Write HIGH-LEVEL architecture, not implementation details:
- Major components and their responsibilities
- Data flow between components
- Key interfaces and contracts
- Technology choices and rationale
- Error handling strategy
- Testing approach

Do NOT include:
- Specific function implementations
- Line-by-line code changes
- Detailed file modifications (that's task-breakdown)
- Exact test code (test plans come later)

## Output

Save to: `/docs/plans/[feature]/high-level-plan.md`

## Plan Document Header

**Every plan MUST start with this header:**

```markdown
# [Feature Name] Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use devpowers:subagent-driven-development to implement this plan task-by-task.

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

---
```

## Plan Sections

### 1. Components

List major components with responsibilities:
- Component name and purpose
- Key interfaces it exposes
- Dependencies it requires

### 2. Data Flow

Describe how data moves through the system:
- Input sources
- Transformations
- Output destinations
- Error paths

### 3. Key Decisions

Document major architectural choices:
- Decision and rationale
- Alternatives considered
- Trade-offs accepted

### 4. Error Handling Strategy

High-level approach to errors:
- Error categories
- Recovery strategies
- User feedback approach

### 5. Testing Strategy

Overview of testing approach:
- Unit test focus areas
- Integration test boundaries
- E2E scenarios (if applicable)

## State Update

After writing plan, update STATUS.md:
- Stage: high-level-plan
- Last Action: High-level plan written
- Next Action: Plan review

## Remember
- Architecture-level detail, not implementation
- Complete enough for critics to find issues
- Reference relevant master docs patterns
- DRY, YAGNI principles throughout

## Handoff

"High-level plan complete and saved to `/docs/plans/[feature]/high-level-plan.md`.

Ready for plan review?"

-> Invokes `reviewing-plans`
