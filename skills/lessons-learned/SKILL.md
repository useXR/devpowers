---
name: lessons-learned
description: >
  This skill should be used when the user asks to "capture lessons learned",
  "update master docs", "review what we learned", "document insights",
  or after implementation completes. Reviews both artifacts and agent-captured
  notes to propose master document updates.
---

# Lessons Learned

## What Are Master Docs?

Master documents live in `/docs/master/` and contain accumulated project knowledge:
- `design-system.md` — UI patterns, component conventions
- `lessons-learned/frontend.md` — Frontend-specific learnings
- `lessons-learned/backend.md` — Backend-specific learnings
- `lessons-learned/testing.md` — Testing-specific learnings
- `lessons-learned/infrastructure.md` — Infrastructure-specific learnings
- `patterns/` — Reusable code patterns discovered over time

## Review Loop

This skill uses review loops:
- Maximum 3 rounds total
- Max 2 discussions per conflict before escalating to user
- Convergence: User approves master doc updates

## What It Captures

- **New patterns** — Reusable approaches that emerged
- **Difficult problems** — Issues and solutions
- **New tools/procedures** — Utilities or workflows created
- **Anti-patterns** — What didn't work
- **Corrections** — Master doc content that was wrong

## Two Sources of Learnings

1. **Artifacts** — Inferred from code, plans, git diff/log
2. **Agent experience** — Captured in `learnings.md` during review/implementation

## Master Doc Merge Algorithm

### Classification Step

```
classify_change(existing, proposed):
    1. Extract key concepts from proposed addition
    2. Search existing content for related concepts
    3. Classify as one of:
       - NEW: No related concepts found
       - REFINEMENT: Related concept exists, proposed adds detail
       - CONTRADICTION: Related concept exists, proposed disagrees
       - SUPERSEDE: Related concept exists, proposed is clearly better
       - DUPLICATE: Proposed is already covered
```

### Merge Strategy by Classification

| Classification | Action | User Approval |
|----------------|--------|---------------|
| NEW | Append to appropriate section | Show diff only |
| REFINEMENT | Inline edit with additions | Show diff only |
| CONTRADICTION | Present both versions | Required |
| SUPERSEDE | Replace with changelog | Show diff + reason |
| DUPLICATE | Skip, note in learnings.md | None |

### Contradiction Resolution Prompt

When a contradiction is found:

```markdown
## Master Doc Conflict

**Section:** /docs/master/patterns/authentication.md

**Existing content:**
> Always use bcrypt with cost factor 10 for password hashing.

**Proposed update:**
> Use Argon2id for password hashing. bcrypt is outdated for new projects.

**Context:** Learned during auth-feature implementation after security review.

**Options:**
1. Keep existing (ignore new learning)
2. Accept proposed (replace existing)
3. Keep both with context (document the evolution)
4. Manual edit (I'll merge myself)
```

### Atomic Update Rule

Each master doc update is a single atomic commit. Never batch unrelated updates.

Commit message format:
```
docs(master): [section] brief description

Context: [feature] during [phase]
Classification: [NEW|REFINEMENT|SUPERSEDE]
Previous: [if SUPERSEDE, what was replaced]
```

## Workflow

1. Read `/docs/plans/[feature]/learnings.md` (agent-captured notes)
2. Review artifacts (plan, tasks, git diff/log)
3. Categorize findings by master doc section
4. Apply merge algorithm for each finding
5. Present proposed updates with diffs
6. On approval, apply updates
7. Commit changes with context
8. Update STATUS.md

## Handoff

"Lessons captured and master docs updated.

Ready to finish the branch?"

-> Invokes `finishing-a-development-branch`
