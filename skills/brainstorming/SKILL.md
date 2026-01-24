---
name: brainstorming
description: "You MUST use this before any creative work - creating features, building components, adding functionality, or modifying behavior. Explores user intent, requirements and design before implementation."
---

# Brainstorming Ideas Into Designs

## Overview

Help turn ideas into fully formed designs and specs through natural collaborative dialogue.

Start by understanding the current project context, then ask questions one at a time to refine the idea. Once you understand what you're building, present the design in small sections (200-300 words), checking after each section whether it looks right so far.

## Scope Assessment

Before brainstorming, assess scope:
- **Trivial:** Direct implementation, skip brainstorming
- **Small:** Brief brainstorm, simple plan
- **Medium/Large:** Full brainstorming process

Ask user to confirm scope if unclear.

## Architectural Assessment (Medium+ Scope)

For Medium and Large scope features, assess architectural approach after understanding the feature's purpose.

### Step 1: Check Existing ADRs

If `/docs/master/architecture-decisions.md` exists:
- Read it and identify decisions relevant to the current feature's domain
- Note these for context during assessment

### Step 2: Assess Four Dimensions

Ask these questions (can combine if context is already clear):

| Dimension | Question | Scale |
|-----------|----------|-------|
| **Business Logic Complexity** | Is this mostly data storage/retrieval, or are there significant business rules, validations, or state transitions? | Low (CRUD) → Medium (some rules) → High (complex workflows) |
| **Data Relationships** | Are we dealing with simple independent entities, or complex aggregates with invariants? | Simple (flat) → Moderate (related) → Complex (aggregates) |
| **Domain Expert Involvement** | Is this a technical/internal tool, or will business stakeholders define and evolve the rules? | None → Some → High |
| **Change Frequency** | Are the rules well-understood and stable, or will they evolve frequently? | Stable → Moderate → Frequent |

See `./references/architectural-dimensions.md` for detailed scoring guidance.

### Step 3: Recommend Approach

Based on dimension scores and any relevant past ADRs:
- Synthesize a recommendation (open-ended, not from a fixed list)
- Include rationale tied to dimension scores
- Note consistency with or divergence from past decisions
- If diverging from past ADRs, explicitly justify why

Get user confirmation before proceeding.

### Step 4: Record Decision

After brainstorming completes, if architectural approach was assessed:
- Append new ADR to `/docs/master/architecture-decisions.md`
- Create the file from template if it doesn't exist

**Skip this section for Trivial/Small scope** — these fit into existing architecture by definition.

## Before Brainstorming

Read master docs for context:
- `/docs/master/design-system.md` — UI patterns to follow
- `/docs/master/lessons-learned/` — Past learnings to consider
- `/docs/master/patterns/` — Established patterns
- `/docs/master/architecture-decisions.md` — Past architectural decisions (if exists)

## The Process

**Understanding the idea:**
- Check out the current project state first (files, docs, recent commits)
- Ask questions one at a time to refine the idea
- Prefer multiple choice questions when possible, but open-ended is fine too
- Only one question per message - if a topic needs more exploration, break it into multiple questions
- Focus on understanding: purpose, constraints, success criteria

**Exploring approaches:**
- Propose 2-3 different approaches with trade-offs
- Present options conversationally with your recommendation and reasoning
- Lead with your recommended option and explain why

**Presenting the design:**
- Once you believe you understand what you're building, present the design
- Break it into sections of 200-300 words
- Ask after each section whether it looks right so far
- Cover: architecture, components, data flow, error handling, testing
- Be ready to go back and clarify if something doesn't make sense

## Output Structure

Create:
```
/docs/plans/[feature]/
├── STATUS.md          # From template
├── learnings.md       # From template
└── brainstorm.md      # Brainstorming notes
```

## After the Design

**Documentation:**
- Write the validated design to `/docs/plans/[feature]/brainstorm.md`
- Copy STATUS-template.md to `/docs/plans/[feature]/STATUS.md`
- Copy learnings-template.md to `/docs/plans/[feature]/learnings.md`
- Use elements-of-style:writing-clearly-and-concisely skill if available
- Commit the design document to git

**Update STATUS.md:**
- Stage: brainstorming (complete)
- Last Action: Brainstorming complete
- Next Action: High-level plan

## Key Principles

- **One question at a time** - Don't overwhelm with multiple questions
- **Multiple choice preferred** - Easier to answer than open-ended when possible
- **YAGNI ruthlessly** - Remove unnecessary features from all designs
- **Explore alternatives** - Always propose 2-3 approaches before settling
- **Incremental validation** - Present design in sections, validate each
- **Be flexible** - Go back and clarify when something doesn't make sense

## Handoff

"Brainstorming complete. Feature folder created at `/docs/plans/[feature]/`.

Ready to write the high-level plan?"

-> Invokes `writing-plans`
