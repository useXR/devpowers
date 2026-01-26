---
name: verification-before-completion
description: Use when about to claim work is complete, fixed, or passing, before committing or creating PRs - requires running verification commands and confirming output before making any success claims; evidence before assertions always
---

# Verification Before Completion

**Core principle:** Evidence before claims, always.

## The Iron Law

```
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
```

If you haven't run verification in this message, you cannot claim it passes.

## When to Dispatch Verifier

**BEFORE any of these:**
- Claiming tests pass
- Claiming build succeeds
- Claiming work is complete
- Committing or creating PR
- Moving to next task
- Expressing satisfaction ("Done!", "Perfect!")

## Dispatch Agent

Dispatch the `verifier` agent with:
```
Verification commands:
- npm test (or project's test command)
- npm run build (or project's build command)
- npm run lint (if applicable)

Requirements checklist (if task has acceptance criteria):
- [criterion 1]
- [criterion 2]

Working directory: [path]
```

## After Agent Returns

### If PASS
You may now make completion claims WITH the evidence:
"All tests pass (34/34, exit 0). Build succeeds. Ready to commit."

### If FAIL
Do NOT claim completion. State actual status:
"3 lint errors remain. Fixing before commit."

## Red Flags - STOP

If you're about to say any of these WITHOUT fresh verifier evidence:
- "Should work now"
- "Tests pass"
- "Build succeeds"
- "Done!"
- "Ready to commit"

**STOP. Dispatch verifier first.**

## The Bottom Line

Run the commands. Read the output. THEN claim the result.

No shortcuts. Non-negotiable.
