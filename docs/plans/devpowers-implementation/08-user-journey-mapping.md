# Task 8: User Journey Mapping

> **Devpowers Implementation** | [← Cross-Domain Review](./07-cross-domain-review.md) | [Next: Lessons Learned →](./09-lessons-learned.md)

---

## Context

**This task creates the user-journey-mapping skill for comprehensive e2e test planning.** Forces systematic enumeration of all user behaviors before test writing.

### Prerequisites
- **Task 6** completed (domain-review system exists)

### What This Task Creates
- `skills/user-journey-mapping/SKILL.md`
- `skills/user-journey-mapping/journey-critic.md`
- `skills/user-journey-mapping/references/journey-categories.md`
- `skills/user-journey-mapping/examples/login-journey.md`

### Tasks That Depend on This
- **Task 9** (Lessons Learned) - runs after all reviews complete

### Parallel Tasks
This task can be done in parallel with:
- **Task 7** (Cross-Domain Review)
- **Task 10** (Implementation Skills Updates)

---

## Files to Create

```
skills/user-journey-mapping/
├── SKILL.md
├── journey-critic.md
├── references/
│   └── journey-categories.md
└── examples/
    └── login-journey.md
```

---

## Steps

### Step 1: Create directory structure

```bash
mkdir -p skills/user-journey-mapping/{references,examples}
```

### Step 2: Create SKILL.md

**File:** `skills/user-journey-mapping/SKILL.md`

```markdown
---
name: user-journey-mapping
description: >
  This skill should be used when the user asks to "map user journeys",
  "identify test scenarios", "plan e2e tests", "ensure test coverage",
  or after cross-domain-review completes for UI features. Systematically
  enumerates all user behaviors to derive comprehensive test plans.
---

# User Journey Mapping

## Why This Exists

LLMs often miss edge cases, error states, and non-obvious user behaviors when generating tests ad-hoc. This skill forces systematic enumeration of all scenarios BEFORE test writing begins.

## Review Loop

This skill uses review loops:
- Maximum 3 rounds
- Convergence: All journeys have error/edge/accessibility coverage

## Journey Map Covers

- **Happy paths** — Primary success scenarios
- **Variations** — Different entry points, user states, data conditions
- **Error states** — Validation, network, server, permissions failures
- **Edge cases** — Limits, empty states, rapid actions, unicode, special chars
- **Interruptions** — Navigation, refresh, timeout, session expiry
- **Accessibility** — Keyboard navigation, screen reader, focus management

## Workflow

1. Read task docs to understand feature scope
2. Generate initial journey map using `references/journey-categories.md` as checklist
3. Dispatch Journey Critic to review for gaps
4. If gaps found → add to map → re-review
5. Loop until critic finds no significant gaps (max 3 rounds)
6. Output: `/docs/plans/[feature]/journeys/[component]-journeys.md`
7. Derive e2e test plan from journey map (added to task docs)
8. Update STATUS.md

## Handoff

"User journeys mapped. E2E test plan added to task documents.

Ready to create worktree and implement?"

→ Invokes `using-git-worktrees`
```

### Step 3: Create journey-critic.md

**File:** `skills/user-journey-mapping/journey-critic.md`

```markdown
# Journey Critic

You are reviewing user journey maps for completeness.

## Your Focus

Check that the journey map covers ALL categories:

### 1. Happy Paths
- [ ] Primary success scenario documented
- [ ] All variations of success documented

### 2. Error States
- [ ] Validation errors (each field)
- [ ] Network errors
- [ ] Server errors (500, 503)
- [ ] Permission errors (401, 403)
- [ ] Not found errors (404)

### 3. Edge Cases
- [ ] Empty states
- [ ] Maximum limits
- [ ] Minimum limits
- [ ] Unicode/special characters
- [ ] Rapid repeated actions
- [ ] Concurrent actions

### 4. Interruptions
- [ ] Mid-flow navigation
- [ ] Browser refresh
- [ ] Session timeout
- [ ] Network disconnect/reconnect

### 5. Accessibility
- [ ] Keyboard-only navigation
- [ ] Screen reader flow
- [ ] Focus management
- [ ] Color contrast considerations

## Output Format

```markdown
## Journey Review: [Component]

### Missing Journeys
- [ ] [Category]: [Specific missing journey]

### Incomplete Journeys
- [ ] [Journey name]: Missing [what's missing]

### Suggestions
- [Optional improvements]

### Assessment
[Complete / Needs work]
```
```

### Step 4: Create journey-categories.md

**File:** `skills/user-journey-mapping/references/journey-categories.md`

```markdown
# Journey Categories Checklist

Use this checklist when creating journey maps.

## Happy Paths
- [ ] User completes primary action successfully
- [ ] User completes with optional fields
- [ ] User completes with all fields

## Variations
- [ ] New user vs returning user
- [ ] Logged in vs logged out
- [ ] Different permission levels
- [ ] Different data states (empty, partial, full)

## Error States
- [ ] Each required field empty
- [ ] Each field invalid format
- [ ] Network request fails
- [ ] Server returns error
- [ ] User not authorized
- [ ] Resource not found
- [ ] Rate limited

## Edge Cases
- [ ] Empty list/results
- [ ] Single item
- [ ] Maximum items
- [ ] Very long text input
- [ ] Unicode characters
- [ ] HTML/script injection attempt
- [ ] Rapid form submission
- [ ] Duplicate submission

## Interruptions
- [ ] Leave page mid-form
- [ ] Browser back button
- [ ] Refresh page
- [ ] Close tab and return
- [ ] Session expires mid-action
- [ ] Network drops mid-request

## Accessibility
- [ ] Tab through all interactive elements
- [ ] Submit form with keyboard only
- [ ] Navigate with screen reader
- [ ] All images have alt text
- [ ] Focus visible on all elements
- [ ] Error messages announced
```

### Step 5: Create login-journey.md example

**File:** `skills/user-journey-mapping/examples/login-journey.md`

```markdown
# Login Feature - User Journeys

## Happy Paths

### J1: Successful login with email/password
1. User navigates to /login
2. User enters valid email
3. User enters valid password
4. User clicks "Sign In"
5. System validates credentials
6. System redirects to dashboard
7. Dashboard shows user's name

### J2: Successful login with "Remember me"
1-6. Same as J1
7. User checks "Remember me"
8. After session expires, user returns
9. User is still logged in

## Error States

### J3: Invalid email format
1. User enters "notanemail"
2. User tabs to password
3. Inline error: "Please enter a valid email"
4. Submit button disabled

### J4: Wrong password
1. User enters valid email
2. User enters wrong password
3. User clicks "Sign In"
4. Error message: "Invalid credentials"
5. Password field cleared
6. Focus returns to password field

### J5: Account locked
1. User enters wrong password 5 times
2. Error: "Account locked. Try again in 15 minutes."
3. Form disabled

### J6: Network error
1. User enters valid credentials
2. Network is down
3. User clicks "Sign In"
4. Error: "Network error. Please try again."
5. Form remains filled

## Edge Cases

### J7: Very long email
1. User enters 254-character email
2. System accepts (valid per RFC)

### J8: Unicode in password
1. User enters password with emoji
2. System accepts/rejects consistently

## Accessibility

### J9: Keyboard-only login
1. Tab to email field
2. Type email
3. Tab to password field
4. Type password
5. Tab to "Sign In" button
6. Press Enter
7. Login succeeds

### J10: Screen reader flow
1. Screen reader announces "Login form"
2. Each field label is read
3. Error messages are announced
4. Success redirect is announced

## E2E Test Plan (derived)

- [ ] J1: Login with valid credentials → dashboard
- [ ] J3: Invalid email → inline error, button disabled
- [ ] J4: Wrong password → error message, field cleared
- [ ] J5: 5 failed attempts → account locked message
- [ ] J6: Network error → retry message, form intact
- [ ] J9: Complete login using only keyboard
```

### Step 6: Commit

```bash
git add skills/user-journey-mapping/
git commit -m "feat: add user-journey-mapping skill"
```

---

## Verification Checklist

- [ ] `skills/user-journey-mapping/SKILL.md` exists
- [ ] `skills/user-journey-mapping/journey-critic.md` exists
- [ ] `skills/user-journey-mapping/references/journey-categories.md` exists
- [ ] `skills/user-journey-mapping/examples/login-journey.md` exists
- [ ] All journey categories covered in checklist
- [ ] Example shows derived E2E test plan
- [ ] Changes committed

---

## Next Steps

Proceed to **[Task 9: Lessons Learned](./09-lessons-learned.md)**.
