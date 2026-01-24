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

> **Version 2.0.0** (2025-01-23) - Convergence-based reviews, hard gates, gap-finding, scope tiers
>
> When asked "what version of devpowers?", report: **devpowers v2.0.0** with these key features:
> - Convergence-based review loops (2 clean rounds to pass)
> - Hard gates (security checklist, test coverage categories, behavior definitions)
> - Gap-finding protocol ("what's missing?" not just "what's wrong?")
> - Scope tiers (Trivial/Small/Medium/Large with different workflows)
> - Spike verification before planning
> - Fresh skeptic pass after convergence

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

## Scope Tiers (Detailed)

### Trivial Scope

**Indicators:**
- Single file change
- <20 lines modified
- Obvious fix (typo, config tweak, rename)
- No new dependencies
- No architectural decisions

**Workflow:**
```
Direct implementation → Done
```

**What runs:**
- Nothing - just implement

**What to still consider:**
- If touching security-sensitive code, at least run security checklist mentally
- If change could break tests, run tests after

---

### Small Scope

**Indicators:**
- 1-3 files changed
- <100 lines modified
- Bug fix or minor enhancement
- Known patterns (already used elsewhere in codebase)
- No new dependencies

**Workflow:**
```
brainstorming (brief) → implement → verify
```

**What runs:**
| Step | What | Why |
|------|------|-----|
| Brainstorming | Quick scope confirmation | Ensure we understand the ask |
| Security Checklist | Mental check or explicit | Even small changes can introduce vulnerabilities |
| Test Plan | At least 3 test cases | Ensure change is verified |
| Verification | Run tests | Confirm nothing broke |

**What's skipped:**
- Formal plan document
- Multi-round review
- User journey mapping
- Task breakdown (single task)

---

### Medium Scope

**Indicators:**
- Multiple components affected
- 100-500 lines modified
- New feature or significant enhancement
- May introduce new patterns
- May add dependencies

**Workflow:**
```
brainstorming → writing-plans → reviewing-plans (converge) → task-breakdown →
domain-review (with hard gates) → implement → verify → lessons-learned (optional)
```

**What runs:**
| Step | What | Why |
|------|------|-----|
| Brainstorming | Full exploration | Understand requirements and approach |
| Writing Plans | High-level plan with spike verification | Document approach, verify risky assumptions |
| Reviewing Plans | Multiple critics until convergence + skeptic pass | Catch issues before implementation |
| Task Breakdown | Create task files | Organize implementation |
| Domain Review | Critics with hard gates | Security checklist, test plans, behavior definitions |
| Implementation | Subagent-driven or direct | Execute tasks |
| Verification | Tests pass, manual verification | Confirm feature works |

**What's skipped:**
- User journey mapping (unless UI-heavy)
- Cross-domain review (unless truly multi-domain)

---

### Large Scope

**Indicators:**
- Architectural change
- >500 lines or many files
- New subsystem or major feature
- Multiple new dependencies
- Unfamiliar domain or technology

**Workflow:**
```
brainstorming → writing-plans (with spikes) → reviewing-plans (converge + skeptic) →
task-breakdown → domain-review (all gates) → cross-domain-review →
user-journey-mapping → implement → verify → lessons-learned
```

**What runs:**
| Step | What | Why |
|------|------|-----|
| Everything from Medium | - | - |
| Cross-Domain Review | Integration critic | Catch issues at component boundaries |
| User Journey Mapping | All journey categories | Ensure UX is complete |
| Lessons Learned | Required | Capture insights for master docs |

---

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

## Scope Precedence Rules

**When indicators conflict, use these rules:**

| Conflict | Resolution | Rationale |
|----------|------------|-----------|
| File count says Small, but adds new dependency | **Medium** | New dependencies need spike verification |
| Line count says Small, but touches auth/security | **Medium** | Security-sensitive code needs full review |
| Seems Small, but multiple components affected | **Medium** | Cross-component changes need integration review |
| Seems Medium, but architectural decision required | **Large** | Architectural decisions need full workflow |
| Any uncertainty about scope | **Go higher** | Over-process is better than under-process |

**Automatic escalation triggers (regardless of initial assessment):**
- Adds new external dependency → at least Medium
- Modifies authentication/authorization → at least Medium
- Changes database schema → at least Medium
- Affects multiple services/repos → Large
- Introduces new API contract → at least Medium

**When still uncertain:** Ask user. Present the options:

> "This could be Small or Medium scope. Indicators: [list what points each way]. Small means lighter process (no formal plan review). Medium means full review cycle. Which fits better?"

## Hard Gates by Scope

| Gate | Trivial | Small | Medium | Large |
|------|---------|-------|--------|-------|
| Security Checklist | Skip | Mental | Required | Required |
| Test Plan (coverage categories) | Skip | Required | Required | Required |
| Spike Verification | Skip | If needed | Required for new deps | Required |
| Behavior Definitions | Skip | Skip | If user-facing | Required |
| Integration Checklist | Skip | Skip | Required | Required |
| Journey Categories | Skip | Skip | Skip | Required |
| Skeptic Pass | Skip | Skip | Required | Required |

**Integration Checklist (Medium+ scope):**

Even without full cross-domain review, Medium scope tasks must verify:
- [ ] Works with existing autosave/persistence (if applicable)
- [ ] Works with existing undo/redo (if applicable)
- [ ] Works with existing error handling patterns
- [ ] No breaking changes to existing functionality
- [ ] New dependencies don't conflict with existing ones

## Detecting Workflow State

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

## Handoffs

After routing:
- If project-setup needed: "No master docs found. Let's set up the project first." → Invoke `project-setup`
- If new feature: "Ready to brainstorm [feature]? I'm assessing this as [scope] scope." → Invoke `brainstorming`
- If resume: "Resuming [feature] at [stage]. [Next action]?" → Invoke appropriate skill

## How to Access Skills

**In Claude Code:** Use the `Skill` tool. When you invoke a skill, its content is loaded and presented to you—follow it directly. Never use the Read tool on skill files.

**In other environments:** Check your platform's documentation for how skills are loaded.

## The Rule

**Invoke relevant or requested skills BEFORE any response or action.** Even a 1% chance a skill might apply means that you should invoke the skill to check. If an invoked skill turns out to be wrong for the situation, you don't need to use it.

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
