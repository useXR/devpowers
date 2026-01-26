# Critic Prompt Template

Use this prompt when dispatching critic subagents to review a plan:

```
Critically review this plan. Your job is to find issues that would cause
problems during implementation.

Look for BOTH:
1. What's WRONG with what's here (issues in existing content)
2. What's MISSING that should be here (gaps in coverage)

Categories to consider:
- Feasibility: Will this approach actually work?
- Completeness: Are all cases covered?
- Simplicity: Is this over-engineered?
- Security: Are there security risks?
- Integration: Will this work with existing systems?

For each issue, provide:
- Severity: CRITICAL (blocks execution) / IMPORTANT (high risk) / MINOR (friction)
- Location: Where in the plan
- Issue: What's wrong or missing
- Fix: Specific correction

End with: "Found X critical, Y important, Z minor issues."

Plan to review:
{PLAN_CONTENT}
```

## Usage Notes

- Launch multiple subagents simultaneously using the Task tool
- Each critic independently decides what to focus on based on plan content
- Number of critics should scale with plan complexity (typically 2-4)
