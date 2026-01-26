---
name: systematic-debugging
description: Use when encountering any bug, test failure, or unexpected behavior, before proposing fixes
---

# Systematic Debugging

Random fixes waste time and create new bugs. Quick patches mask underlying issues.

**Core principle:** ALWAYS find root cause before attempting fixes. Symptom fixes are failure.

## The Iron Law

```
NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST
```

If you haven't completed Phase 1, you cannot propose fixes.

## When to Use

Use for ANY technical issue: test failures, bugs, unexpected behavior, performance problems, build failures, integration issues.

**Use ESPECIALLY when:** Under time pressure, "just one quick fix" seems obvious, you've already tried multiple fixes, you don't fully understand the issue.

**Don't skip when:** Issue seems simple, you're in a hurry, manager wants it NOW. Systematic is FASTER than thrashing.

## The Four Phases

You MUST complete each phase before proceeding to the next. See `./references/phase-details.md` for detailed instructions.

### Phase 1: Root Cause Investigation

**BEFORE attempting ANY fix:**
1. **Read error messages** - Stack traces, line numbers, error codes
2. **Reproduce consistently** - If not reproducible, gather more data
3. **Check recent changes** - Git diff, dependencies, config, environment
4. **Gather evidence** - For multi-component systems, log at each boundary
5. **Trace data flow** - See `./references/root-cause-tracing.md`

### Phase 2: Pattern Analysis

1. **Find working examples** - Similar working code in codebase
2. **Compare against references** - Read completely, don't skim
3. **Identify differences** - List every difference, however small
4. **Understand dependencies** - Components, config, assumptions

### Phase 3: Hypothesis and Testing

1. **Form single hypothesis** - "I think X because Y" - be specific
2. **Test minimally** - SMALLEST possible change, one variable
3. **Verify** - Worked? Phase 4. Failed? NEW hypothesis, don't pile fixes

### Phase 4: Implementation

1. **Create failing test** - Use `devpowers:test-driven-development`
2. **Single fix** - ONE change, no "while I'm here" improvements
3. **Verify** - Test passes, no regressions
4. **If fix fails** - Count attempts. If >= 3, question architecture
5. **3+ failures** - Stop. Discuss fundamentals with human partner

## Red Flags - STOP and Follow Process

If you catch yourself thinking:
- "Quick fix for now, investigate later"
- "Just try changing X and see if it works"
- "Add multiple changes, run tests"
- "Skip the test, I'll manually verify"
- "It's probably X, let me fix that"
- "I don't fully understand but this might work"
- "Pattern says X but I'll adapt it differently"
- "Here are the main problems: [lists fixes without investigation]"
- Proposing solutions before tracing data flow
- **"One more fix attempt" (when already tried 2+)**
- **Each fix reveals new problem in different place**

**ALL of these mean: STOP. Return to Phase 1.**

**If 3+ fixes failed:** Question the architecture.

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "Issue is simple, don't need process" | Simple issues have root causes too. Process is fast for simple bugs. |
| "Emergency, no time for process" | Systematic debugging is FASTER than guess-and-check thrashing. |
| "Just try this first, then investigate" | First fix sets the pattern. Do it right from the start. |
| "I'll write test after confirming fix works" | Untested fixes don't stick. Test first proves it. |
| "Multiple fixes at once saves time" | Can't isolate what worked. Causes new bugs. |
| "Reference too long, I'll adapt the pattern" | Partial understanding guarantees bugs. Read it completely. |
| "I see the problem, let me fix it" | Seeing symptoms != understanding root cause. |
| "One more fix attempt" (after 2+ failures) | 3+ failures = architectural problem. Question pattern, don't fix again. |

## Quick Reference

| Phase | Key Activities | Success Criteria |
|-------|---------------|------------------|
| **1. Root Cause** | Read errors, reproduce, check changes, gather evidence | Understand WHAT and WHY |
| **2. Pattern** | Find working examples, compare | Identify differences |
| **3. Hypothesis** | Form theory, test minimally | Confirmed or new hypothesis |
| **4. Implementation** | Create test, fix, verify | Bug resolved, tests pass |

## Supporting Techniques

Available in `./references/`:
- **`root-cause-tracing.md`** - Trace bugs backward through call stack
- **`defense-in-depth.md`** - Add validation at multiple layers
- **`condition-based-waiting.md`** - Replace arbitrary timeouts with condition polling
- **`phase-details.md`** - Detailed phase instructions and examples

**Related skills:**
- **devpowers:test-driven-development** - For creating failing test case
- **devpowers:verification-before-completion** - Verify fix worked before claiming success
