# Task 9: Lessons Learned

> **Devpowers Implementation** | [← User Journey Mapping](./08-user-journey-mapping.md) | [Next: Implementation Skills →](./10-implementation-skills.md)

---

## Context

**This task creates the lessons-learned skill with master doc merge algorithm.** Captures insights from implementations and feeds them back into master documents.

### Prerequisites
- **Task 7** completed (cross-domain-review exists)
- **Task 8** completed (user-journey-mapping exists)

### What This Task Creates
- `skills/lessons-learned/SKILL.md`
- `skills/lessons-learned/learnings-reviewer.md`
- `skills/lessons-learned/references/update-categories.md`

### Tasks That Depend on This
- **Task 11** (Hook Automation) - Stop hook checks learnings.md

---

## Files to Create

```
skills/lessons-learned/
├── SKILL.md
├── learnings-reviewer.md
└── references/
    └── update-categories.md
```

---

## Steps

### Step 1: Create directory structure

```bash
mkdir -p skills/lessons-learned/references
```

### Step 2: Create SKILL.md

**File:** `skills/lessons-learned/SKILL.md`

```markdown
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

### Section Targeting

Map learnings to sections:

| Learning Type | Target Section |
|---------------|----------------|
| API usage pattern | `patterns/` → relevant domain file |
| Library gotcha | `gotchas.md` |
| Architecture decision | `architecture.md` |
| Testing insight | `lessons-learned/testing.md` |
| Performance finding | `lessons-learned/performance.md` |
| Security concern | `lessons-learned/security.md` |
| Tooling tip | `lessons-learned/tooling.md` |

### Atomic Update Rule

Each master doc update is a single atomic commit. Never batch unrelated updates.

Commit message format:
```
docs(master): [section] brief description

Context: [feature] during [phase]
Classification: [NEW|REFINEMENT|SUPERSEDE]
Previous: [if SUPERSEDE, what was replaced]
```

## Parallel Append Coordination

When multiple critics run in parallel, they write to separate temp files:

```
/docs/plans/[feature]/learnings-temp/
├── domain-review-frontend.md
├── domain-review-backend.md
├── domain-review-testing.md
└── domain-review-infrastructure.md
```

After all critics complete, orchestrator merges temp files into learnings.md.

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

→ Invokes `finishing-a-development-branch`
```

### Step 3: Create learnings-reviewer.md

**File:** `skills/lessons-learned/learnings-reviewer.md`

```markdown
# Learnings Reviewer

You are reviewing implementation artifacts and learnings.md to identify what should be added to master documents.

## Your Focus

1. **Pattern Discovery** — What reusable patterns emerged? What approaches worked well?
2. **Problem Documentation** — What was difficult? What took multiple attempts? Workarounds?
3. **Anti-Pattern Identification** — What didn't work? What should be avoided?
4. **Corrections** — Did any master doc guidance prove wrong? What needs updating?

## Output Format

```markdown
## Learnings Review: [Feature]

### Proposed Master Doc Updates

#### 1. [Target: /docs/master/path/file.md]
**Classification:** NEW | REFINEMENT | CONTRADICTION | SUPERSEDE
**Content:**
> [The content to add/update]

**Rationale:** [Why this should be captured]

#### 2. [Next update...]

### No-Action Items
[Learnings that don't need master doc updates and why]

### Summary
[Overall assessment of learnings capture]
```
```

### Step 4: Create update-categories.md

**File:** `skills/lessons-learned/references/update-categories.md`

```markdown
# Update Categories

## When to Update Master Docs

### Always Update
- Security vulnerabilities discovered
- Performance issues with solutions
- Breaking changes in dependencies
- Patterns that saved significant time

### Consider Updating
- Approaches that worked better than expected
- Tools that proved useful
- Gotchas that weren't obvious

### Don't Update
- One-off workarounds
- Project-specific configurations
- Temporary fixes

## Section Selection Guide

### design-system.md
- New component patterns
- Color/typography discoveries
- Responsive design patterns

### lessons-learned/frontend.md
- Framework-specific gotchas
- State management patterns
- Performance optimizations

### lessons-learned/backend.md
- API design patterns
- Database query optimizations
- Error handling approaches

### lessons-learned/testing.md
- Test structure patterns
- Mocking strategies
- CI/CD optimizations

### lessons-learned/infrastructure.md
- Deployment patterns
- Scaling strategies
- Monitoring approaches

### patterns/
- Reusable code patterns
- Architecture patterns
- Integration patterns
```

### Step 5: Commit

```bash
git add skills/lessons-learned/
git commit -m "feat: add lessons-learned skill with merge algorithm"
```

---

## Verification Checklist

- [ ] `skills/lessons-learned/SKILL.md` exists
- [ ] `skills/lessons-learned/learnings-reviewer.md` exists
- [ ] `skills/lessons-learned/references/update-categories.md` exists
- [ ] Merge algorithm documented with classification types
- [ ] Contradiction resolution prompt included
- [ ] Parallel append coordination documented
- [ ] Changes committed

---

## Next Steps

Proceed to **[Task 10: Implementation Skills Updates](./10-implementation-skills.md)**.
