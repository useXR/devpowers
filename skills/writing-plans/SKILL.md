---
name: writing-plans
description: Use when you have a spec or requirements for a multi-step task, before touching code
---

# Writing Plans

## Overview

Write comprehensive high-level architecture plans. Document the approach, major components, data flow, and key decisions. This plan will be reviewed by critics and then broken down into implementable tasks.

**Announce at start:** "I'm using the writing-plans skill to create the high-level plan."

## CRITICAL: Spike Verification Before Planning

**Before writing a detailed plan, identify and verify risky assumptions.**

### Identify Risky Assumptions

A risky assumption is any of:
- New dependency/library you haven't used before
- API you're assuming works a certain way
- Integration with external service
- Platform-specific behavior
- Performance characteristics

### Spike Protocol

For each risky assumption:

```markdown
## Risky Assumption: [Description]

**Assumption:** [What you're assuming]
**Risk if wrong:** [What breaks if this assumption is incorrect]
**Verification method:** [How to verify - POC code, docs check, etc.]
**Verification result:** [VERIFIED: evidence] or [FAILED: what was wrong]
```

### When to Spike

| Condition | Spike Required? |
|-----------|-----------------|
| Using library for first time | YES - verify core API works as expected |
| Assuming API returns X shape | YES - verify with actual call or docs |
| Assuming library handles edge case | YES - write minimal test |
| Using well-known pattern you've used before | NO |
| Simple CRUD operations | NO |

### Spike Scope Guidelines

**Time limit:** Spikes should take **<30 minutes**. If verification requires more:
- The assumption is too complex → break it down
- Or escalate to user: "Spike is taking longer than expected. Continue or adjust approach?"

**What counts as "verified":**

| Verification Method | When Sufficient |
|--------------------|-----------------|
| **Docs confirmation** | API shape, method signatures, configuration options |
| **Working code snippet** | Core functionality, integration behavior |
| **Passing test** | Edge cases, error handling, specific behaviors |
| **Performance measurement** | Bundle size impact, latency requirements |

**Spike output format:**
```markdown
**Risky assumption:** [What you assumed]
**Verification method:** [Docs / Code snippet / Test / Measurement]
**Result:** VERIFIED - [brief evidence] | FAILED - [what was wrong]
**Time spent:** [X minutes]
```

**If spike fails:**
- Do NOT proceed with the plan as-is
- Either adjust the approach or escalate to user
- Document what didn't work and why

### Spike Before Planning, Not After

```
WRONG: Write plan → Review → "Oh, this library doesn't work that way"
RIGHT: Identify risk → Spike → Verify → THEN write plan
```

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

## Spike Verification Summary

| Assumption | Status | Evidence |
|------------|--------|----------|
| [Assumption 1] | ✅ Verified | [Link or brief explanation] |
| [Assumption 2] | ✅ Verified | [Link or brief explanation] |
| No risky assumptions | N/A | [Explanation why all patterns are known] |

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

### 6. Known Risks and Mitigations

Document risks that could derail implementation:
- Technical risks (library instability, performance unknowns)
- Integration risks (compatibility with existing features)
- Scope risks (areas where requirements might expand)

For each risk: mitigation strategy or acceptance rationale.

## State Update

After writing plan, update STATUS.md:
- Stage: high-level-plan
- Last Action: High-level plan written (spikes verified)
- Next Action: Plan review

## Remember
- **Spike first**: Verify risky assumptions before committing to plan
- Architecture-level detail, not implementation
- Complete enough for critics to find issues
- Reference relevant master docs patterns
- DRY, YAGNI principles throughout

## Handoff

"High-level plan complete and saved to `/docs/plans/[feature]/high-level-plan.md`.
Spike verification: [N assumptions verified / No risky assumptions identified]

Ready for plan review?"

-> Invokes `reviewing-plans`
