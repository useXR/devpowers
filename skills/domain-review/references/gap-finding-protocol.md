# Gap-Finding Protocol

**Add this section to ALL critic prompts.** Critics should ask both "what's wrong?" AND "what's missing?"

## The Two Questions

Every critic must answer:
1. **What's wrong with what's here?** (issues in existing content)
2. **What's missing that should be here?** (gaps in coverage)

Most critics only answer #1. This protocol ensures #2 is also answered.

## Gap Categories to Check

After your main review, systematically consider each category:

### 1. Scenario Gaps

| Question | If answer is "no" → potential gap |
|----------|-----------------------------------|
| Is the happy path fully specified? | Missing success scenario |
| Are error states defined? | Missing failure handling |
| Are edge cases identified? | Missing boundary behavior |
| Are concurrent/async scenarios addressed? | Missing race condition handling |
| Are interruption scenarios addressed? | Missing "what if user cancels mid-action" |

### 2. Integration Gaps

| Question | If answer is "no" → potential gap |
|----------|-----------------------------------|
| How does this work with existing [autosave]? | Missing integration |
| How does this work with existing [undo/redo]? | Missing integration |
| How does this work with existing [export]? | Missing integration |
| How does this work with existing [keyboard shortcuts]? | Missing integration |
| How does this work with existing [mobile/responsive]? | Missing integration |

(Replace bracketed items with actual features in the codebase)

### 3. Verification Gaps

| Question | If answer is "no" → potential gap |
|----------|-----------------------------------|
| Has the core API/library been verified to work as assumed? | Need spike/POC |
| Has bundle size impact been measured? | Need size check |
| Has performance impact been measured? | Need perf check |
| Has the approach been tested in the target environment? | Need env verification |

### 4. Behavioral Gaps

| Question | If answer is "no" → potential gap |
|----------|-----------------------------------|
| What happens during loading? | Missing loading state |
| What happens on error? | Missing error state |
| What happens on slow network? | Missing degraded state |
| What happens with no data? | Missing empty state |
| What happens with malformed data? | Missing invalid state |

### 5. User Experience Gaps

| Question | If answer is "no" → potential gap |
|----------|-----------------------------------|
| Can user undo this action? | Missing undo |
| Does user get feedback during action? | Missing feedback |
| Can user cancel mid-action? | Missing cancellation |
| What if user does this twice rapidly? | Missing debounce/idempotency |
| What if user does this while another action is in progress? | Missing concurrency handling |

## Output Format for Gaps

After your main review, add a "Gap Analysis" section:

```markdown
## Gap Analysis

### Potential Gaps Found

**[Gap 1 Title]**
- Category: [Scenario/Integration/Verification/Behavioral/UX]
- Question that revealed it: [The question from the checklist]
- What's missing: [Specific description]
- Severity: [CRITICAL/IMPORTANT/MINOR]
- Suggested addition: [What to add to the plan/task]

**[Gap 2 Title]**
...

### Gaps Verified as Covered

- [Gap category]: Covered by [reference to where it's addressed]
- [Gap category]: N/A because [reason]

### Gap Analysis Summary

Checked [N] gap categories. Found [X] potential gaps ([Y] critical, [Z] important).
```

## When Gaps Become Issues

- **CRITICAL gap**: Missing something that would cause feature to fail or be unsafe
- **IMPORTANT gap**: Missing something that would cause significant user friction
- **MINOR gap**: Missing something nice to have but not essential

## Key Insight

Your job is not just to validate what's written - it's to find what ISN'T written that should be.

**Think like a skeptic, not a reviewer.**
