---
name: subagent-driven-development
description: Use when executing implementation plans with independent tasks in the current session
---

# Subagent-Driven Development

Fresh subagent per task + two-stage review (spec then quality) = high quality, fast iteration.

## When to Use

```dot
digraph when_to_use {
    "Have plan?" [shape=diamond];
    "Independent tasks?" [shape=diamond];
    "Same session?" [shape=diamond];
    "subagent-driven-development" [shape=box];
    "executing-plans" [shape=box];
    "Manual or brainstorm" [shape=box];

    "Have plan?" -> "Independent tasks?" [label="yes"];
    "Have plan?" -> "Manual or brainstorm" [label="no"];
    "Independent tasks?" -> "Same session?" [label="yes"];
    "Independent tasks?" -> "Manual or brainstorm" [label="coupled"];
    "Same session?" -> "subagent-driven-development" [label="yes"];
    "Same session?" -> "executing-plans" [label="parallel"];
}
```

## The Process

```dot
digraph process {
    rankdir=TB;

    subgraph cluster_per_task {
        label="Per Task";
        "Dispatch implementer" [shape=box];
        "Questions?" [shape=diamond];
        "Answer" [shape=box];
        "Implement + commit" [shape=box];
        "Spec review" [shape=box];
        "Spec OK?" [shape=diamond];
        "Fix spec gaps" [shape=box];
        "Quality review" [shape=box];
        "Quality OK?" [shape=diamond];
        "Fix quality" [shape=box];
        "Mark complete" [shape=box];
    }

    "Extract tasks, create TodoWrite" [shape=box];
    "More tasks?" [shape=diamond];
    "Final review" [shape=box];
    "finishing-a-development-branch" [shape=box style=filled fillcolor=lightgreen];

    "Extract tasks, create TodoWrite" -> "Dispatch implementer";
    "Dispatch implementer" -> "Questions?";
    "Questions?" -> "Answer" [label="yes"];
    "Answer" -> "Dispatch implementer";
    "Questions?" -> "Implement + commit" [label="no"];
    "Implement + commit" -> "Spec review";
    "Spec review" -> "Spec OK?";
    "Spec OK?" -> "Fix spec gaps" [label="no"];
    "Fix spec gaps" -> "Spec review" [label="re-review"];
    "Spec OK?" -> "Quality review" [label="yes"];
    "Quality review" -> "Quality OK?";
    "Quality OK?" -> "Fix quality" [label="no"];
    "Fix quality" -> "Quality review" [label="re-review"];
    "Quality OK?" -> "Mark complete" [label="yes"];
    "Mark complete" -> "More tasks?";
    "More tasks?" -> "Dispatch implementer" [label="yes"];
    "More tasks?" -> "Final review" [label="no"];
    "Final review" -> "finishing-a-development-branch";
}
```

## Prompt Templates

- `references/implementer-prompt.md` - Implementer subagent
- `references/spec-reviewer-prompt.md` - Spec compliance reviewer
- `references/code-quality-reviewer-prompt.md` - Code quality reviewer

## Task Execution

1. Read task from `/docs/plans/[feature]/tasks/`
2. Check "Unit Test Plan" and "E2E Test Plan" sections
3. Follow TDD: tests first, then implement

## Red Flags

**Never:**
- Skip reviews (spec OR quality)
- Proceed with unfixed issues
- Dispatch parallel implementers (conflicts)
- Make subagent read plan (provide full text)
- Skip scene-setting context
- Ignore subagent questions
- Accept "close enough" on spec
- Skip review loops
- Let self-review replace actual review
- **Quality review before spec passes**
- Move on with open issues

**Questions:** Answer clearly. Don't rush.

**Issues found:** Implementer fixes, re-review, repeat until approved.

**Failed task:** Dispatch fix subagent. Don't fix manually.

## References

- `references/example-workflow.md` - Complete example
- `references/integration.md` - Related skills
- `references/learnings-template.md` - Capture learnings
