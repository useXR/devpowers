# Journey Categories Guide

## Category 1: Happy Path

The primary success scenario. What happens when everything works as intended.

**Document:**
- Entry point (where user starts)
- Each user action
- Each system response
- Success state (where user ends up)

**Example:**
- User enters valid credentials
- User clicks login
- System validates
- User sees dashboard

## Category 2: Error States

What happens when things go wrong.

**Must cover:**
- Invalid user input (validation errors)
- Server errors (500s)
- Network failures (timeout, offline)
- Business logic errors (permissions, limits)

**For each error:**
- Triggering condition
- Error message shown
- Recovery options

## Category 3: Edge Cases

Unusual but valid scenarios.

**Common edge cases:**
- Empty state (no data yet)
- Maximum limits (1000 items, long strings)
- Concurrent access (two users editing)
- Rapid actions (double-click, fast navigation)
- Interrupted flows (browser back, page reload)

## Category 4: Accessibility

Paths for users with different abilities.

**Must cover:**
- Keyboard-only navigation
- Screen reader flow
- Focus management
- Color contrast considerations
- Motion preferences

**For each path:**
- Starting focus position
- Tab order through elements
- Keyboard shortcuts
- Screen reader announcements
- Focus after actions

## Minimum Coverage

For each UI component:
- 1 happy path
- 2+ error states
- 1+ edge cases
- 1 accessibility journey

Total minimum: 5 journeys per component
