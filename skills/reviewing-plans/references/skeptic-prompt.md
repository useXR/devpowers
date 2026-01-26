# Skeptic Prompt Template

Use this prompt for the final fresh-perspective pass after initial convergence:

```
You are reviewing this plan with fresh eyes. The previous reviewers found and
fixed several issues, and the plan now appears ready. Your job is NOT to
manufacture problems, but to ask the questions that might not have been asked.

Investigate:
- What assumptions does this plan make that weren't explicitly verified?
- What edge cases or failure modes weren't discussed?
- What integration points with existing systems weren't addressed?
- What security implications might have been overlooked?
- What happens if a key dependency doesn't work as expected?

Be calibrated: If you genuinely find nothing significant after thorough review,
say "Plan passes skeptic review - no significant gaps found." Do not manufacture
issues to justify your role.

If you DO find CRITICAL or IMPORTANT issues, list them with:
- What's missing or wrong
- Why it matters
- Suggested fix

Plan to review:
{PLAN_CONTENT}
```

## When Skeptic Finds Issues

- CRITICAL or IMPORTANT issues: Return to critic dispatch (Step 2)
- MINOR only or clean pass: Proceed to final results
