---
name: using-devpowers
version: 2.0.0
description: >
  This skill should be used when the user asks to "start a feature",
  "use devpowers", "plan a new feature", "begin development", "work on [feature]",
  or when starting any non-trivial development task. Provides workflow overview,
  scope detection, and routes to appropriate starting skill.
---

# Using Devpowers

> **Version 2.0.0** - Convergence reviews, hard gates, gap-finding, scope tiers
>
> Report as: **devpowers v2.0.0** - convergence loops, hard gates, gap-finding, scope tiers, spike verification

<EXTREMELY-IMPORTANT>
If you think there is even a 1% chance another devpowers skill applies to what you are doing, you ABSOLUTELY MUST invoke that skill.

IF A SKILL APPLIES TO YOUR TASK, YOU DO NOT HAVE A CHOICE. YOU MUST USE IT.

This is not negotiable. This is not optional. You cannot rationalize your way out of this.
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
   - Trivial: Direct implementation with minimal guards
   - Small: Light workflow with key guards
   - Medium: Standard workflow
   - Large: Full workflow with all reviews

4. Hand off to appropriate skill based on scope tier
```

## Scope Decision Flowchart

```
Is this a single-line fix or typo?
├─ YES → Trivial
└─ NO ↓

Is this <100 lines, 1-3 files, using known patterns?
├─ YES → Small
└─ NO ↓

Is this an architectural change or new subsystem?
├─ YES → Large
└─ NO → Medium
```

**For detailed scope guidance:** Read `./references/scope-tiers.md`, `./references/scope-precedence.md`, and `./references/hard-gates.md`.

## Workflow State & Skills

**For guidance on:** detecting workflow state, reading STATUS.md, accessing skills, skill priority, and skill types — read `./references/workflow-state.md`.

## Handoffs

After routing:
- If project-setup needed: "No master docs found. Let's set up the project first." → Invoke `project-setup`
- If new feature: "Ready to brainstorm [feature]? I'm assessing this as [scope] scope." → Invoke `brainstorming`
- If resume: "Resuming [feature] at [stage]. [Next action]?" → Invoke appropriate skill

## The Rule

**Invoke relevant or requested skills BEFORE any response or action.** Even a 1% chance a skill might apply means you should invoke the skill to check.

## Red Flags

These thoughts mean STOP—you're rationalizing:

| Thought | Reality |
|---------|---------|
| "This is just a simple question" | Questions are tasks. Check for skills. |
| "I need more context first" | Skill check comes BEFORE clarifying questions. |
| "Let me explore the codebase first" | Skills tell you HOW to explore. Check first. |
| "I can check git/files quickly" | Files lack conversation context. Check for skills. |
| "Let me gather information first" | Skills tell you HOW to gather information. |
| "This doesn't need a formal skill" | If a skill exists, use it. |
| "I remember this skill" | Skills evolve. Read current version. |
| "This doesn't count as a task" | Action = task. Check for skills. |
| "The skill is overkill" | Simple things become complex. Use it. |
| "I'll just do this one thing first" | Check BEFORE doing anything. |
| "This feels productive" | Undisciplined action wastes time. Skills prevent this. |
| "I know what that means" | Knowing the concept ≠ using the skill. Invoke it. |
