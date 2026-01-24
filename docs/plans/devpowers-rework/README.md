# Devpowers System Rework

## What We're Doing

Reworking the devpowers planning and review pipeline based on real-world testing feedback. Two medium-sized features were built using the system, and meta-reviews identified systematic gaps in the process.

## Why We're Doing It

### The Problem

After running the full devpowers workflow on two features:
1. Calendar animation overhaul (Framer Motion, react-spring)
2. Tiptap editor markdown formatting

Meta-review critics found significant issues that 6+ review rounds had missed:

| Gap Found | Why It Was Missed |
|-----------|-------------------|
| XSS risk in AI-generated markdown | No dedicated security critic; security scattered across backend/infrastructure |
| Empty test plans after 2 domain reviews | Placeholder comments, no hard gate enforcing population |
| Streaming UX undefined | No "behavior definitions" requirement for ambiguous scenarios |
| @tiptap/markdown API instability | No spike/POC step to verify assumptions before planning |
| Missing journeys (copy/paste, undo during streaming) | Journey categories didn't include interruption/async scenarios |
| Integration gaps (export, autosave compatibility) | Integration checklist not explicit |

### Root Cause Analysis

The current process relies on **generative critics** (LLMs thinking of what they think of) rather than **structured prompts that force coverage**. The meta-review critics found more issues because they were asked a different question:

| Current Critics | Meta-Critics |
|-----------------|--------------|
| "What's wrong with this plan?" | "What did this plan miss?" |
| "Is this implementation correct?" | "What scenarios weren't considered?" |

**Key insight:** The same LLM with a different prompt finds different issues. We need to change the prompts, not replace LLMs with checklists.

### Process Efficiency Concerns

The reviews also identified overhead issues:
- 1,200 lines of planning docs for 200 lines of code (6:1 ratio)
- 8 review rounds for a medium feature
- 9 task files for ~8 hours of work

The goal is **bulletproof plans**, not necessarily less process—but the process should scale appropriately with scope.

## What We Hope to Achieve

### Primary Goal: Bulletproof Plans

Plans that don't overlook critical issues. Specifically:
- Security vulnerabilities caught before implementation
- Test plans populated (not empty placeholders)
- Edge cases and error states defined
- Integration points verified
- Risky assumptions validated via spikes

### Secondary Goal: Appropriate Overhead

Scale the process based on task scope:
- Trivial: No planning overhead
- Small: Minimal guards (security checklist, test plan)
- Medium: Standard workflow
- Large: Full workflow with all reviews

### Measurable Success Criteria

1. **Gap reduction**: Meta-review of next feature finds <2 IMPORTANT issues (vs 8+ currently)
2. **Test plan completeness**: 0 tasks with empty test plans after domain review
3. **Security coverage**: 0 security issues found in post-implementation review
4. **Appropriate overhead**: Planning time <25% of implementation time for Medium scope

## Changes Made (Draft v2 Files)

All changes are in v2 draft files, not replacing originals yet.

### 1. Flexible Critics with Gap-Finding

**File:** `reviewing-plans/SKILL-v2.md`

- Changed from predefined critics (Feasibility, Completeness, Simplicity) to "spin up multiple subagents to critique"
- LLM decides how many critics and what they focus on based on plan content
- Each critic now asks BOTH "what's wrong?" AND "what's missing?"

### 2. Convergence-Based Stopping

**File:** `reviewing-plans/SKILL-v2.md`

- Changed from "max 3 rounds" to "keep iterating until no new IMPORTANT+ issues"
- Escalation at 5 rounds without convergence (ask user to intervene)

### 3. Fresh Skeptic Pass

**File:** `reviewing-plans/SKILL-v2.md`

- After initial convergence, one final pass with prompt: "Assume previous reviewers missed something. What would a senior engineer find?"
- Mimics the meta-review that found gaps

### 4. Hard Gates

**File:** `domain-review/SKILL-v2.md`

Convergence blocked until:
- Test Plan has ≥3 specific test cases
- Security Checklist complete (all items checked or N/A with reason)
- Behavior Definitions exist for user-facing tasks
- Spike Verification done for new dependencies

### 5. Dedicated Security Critic

**File:** `domain-review/security-critic-v2.md`

- Always runs (not conditional on domain detection)
- Checklist-based verification of input handling, output encoding, access control, data protection, injection prevention
- General-purpose (any language/platform)

### 6. Gap-Finding Protocol

**File:** `domain-review/references/gap-finding-protocol.md`

Structured categories for finding what's missing:
- Scenario gaps (happy path, error, edge, interruption, async)
- Integration gaps (with existing features)
- Verification gaps (spikes, performance, bundle size)
- Behavioral gaps (loading, error, empty, invalid states)
- UX gaps (undo, feedback, cancellation, concurrency)

### 7. Spike Verification

**File:** `writing-plans/SKILL-v2.md`

Before writing detailed plans:
- Identify risky assumptions (new dependencies, unfamiliar APIs)
- Run spike/POC to verify core assumption works
- Document verification result in plan

### 8. Journey Categories (Expanded)

**File:** `user-journey-mapping/references/journey-categories-v2.md`

Six categories (up from 4):
1. Happy Path
2. Error States
3. Edge Cases
4. **NEW:** Interruption/Cancellation (user cancels mid-action, browser back, etc.)
5. **NEW:** Async/Loading (what user sees during operations, streaming UX)
6. Accessibility

### 9. Scope Tiers

**File:** `using-devpowers/SKILL-v2.md`

| Scope | Indicators | What Runs |
|-------|------------|-----------|
| Trivial | Single file, <20 lines, obvious fix | Nothing |
| Small | 1-3 files, <100 lines, known patterns | Security checklist + test plan |
| Medium | Multiple components, new patterns | Full workflow minus journeys |
| Large | Architectural change, new subsystem | Full workflow with everything |

### 10. General-Purpose Task Template

**File:** `task-breakdown/assets/task-template-v3.md`

- Language/platform agnostic checklists
- Security, Interface, Data/State, Integration categories
- Checklists are prompts for LLM thinking, not rigid box-checking

## Work Still Required

### Phase 1: Complete v2 Files

| Task | Status | Notes |
|------|--------|-------|
| Update all domain critics with gap-finding | NOT STARTED | backend-critic, infrastructure-critic need v2 |
| Update completeness-critic and simplicity-critic | NOT STARTED | May be deprecated in favor of flexible critics |
| Update feasibility-critic | NOT STARTED | May be deprecated in favor of flexible critics |
| Create v2 of domain-review detection logic | NOT STARTED | Add security as always-on domain |
| Update user-journey-mapping SKILL.md | NOT STARTED | Reference new journey-categories-v2.md |
| Update cross-domain-review | NOT STARTED | Integration checklist enforcement |

### Phase 2: Integration Testing

| Task | Status | Notes |
|------|--------|-------|
| Test v2 workflow on Small scope feature | NOT STARTED | Verify minimal overhead works |
| Test v2 workflow on Medium scope feature | NOT STARTED | Verify gap-finding catches issues |
| Test v2 workflow on Large scope feature | NOT STARTED | Verify full workflow is bulletproof |
| Run meta-review on test results | NOT STARTED | Compare gap count to baseline |

### Phase 3: Refinement

| Task | Status | Notes |
|------|--------|-------|
| Tune convergence criteria based on testing | NOT STARTED | May need to adjust when to stop |
| Tune skeptic pass prompt based on effectiveness | NOT STARTED | May need different framing |
| Adjust scope tier boundaries based on testing | NOT STARTED | May need to move thresholds |
| Document lessons learned | NOT STARTED | Update master docs |

### Phase 4: Deployment

| Task | Status | Notes |
|------|--------|-------|
| Replace v1 files with v2 files | NOT STARTED | After testing validates improvements |
| Remove deprecated critic files | NOT STARTED | If flexible critics replace predefined ones |
| Update plugin documentation | NOT STARTED | Reflect new workflow |

## Meta-Critique Findings (2026-01-16)

Three meta-critics reviewed the v2 plan. Key findings to address:

### CRITICAL (to fix before testing)

| Issue | Description | Action |
|-------|-------------|--------|
| Convergence definition ambiguous | "No NEW issues" unclear - all severities or just CRITICAL/IMPORTANT? | Clarify: "No new CRITICAL/IMPORTANT in 2 consecutive rounds" |
| Inconsistent round limits | reviewing-plans: 5 rounds, domain-review: 3 rounds | Unify to convergence-based with same escalation threshold |
| Journey categories web-UI centric | No coverage for CLI, backend, embedded | Add platform-specific overlays or generalize categories |
| N/A gaming vulnerability | Can mark everything N/A with brief reason | Add validation requirements for N/A claims |
| Security checklist gaps | Missing: timing attacks, resource exhaustion, crypto misuse, race conditions | Expand security checklist |

### IMPORTANT (to fix during Phase 1)

| Issue | Description | Action |
|-------|-------------|--------|
| Hard gates quantity not quality | "≥3 test cases" gameable | Require coverage categories, not counts |
| Scope boundaries ambiguous | "Multiple components" vs "1-3 files" overlap | Add weighted scoring or explicit precedence rules |
| Skeptic may manufacture issues | Adversarial framing could cause false positives | Change from "prove them wrong" to "what assumptions weren't questioned" |
| No spike scope guidance | No time limits or verification criteria | Add: "Spikes <30 min, verification = working code or docs confirmation" |
| No integration gate for Medium | But integration gaps were primary issue found | Add integration checklist for Medium scope |
| No scope re-evaluation | If Small becomes Medium during work, no procedure | Add checkpoint after task breakdown |

### What We Got Right (per critics)

- Correct root cause diagnosis (generative critics asking wrong question)
- Gap-finding protocol structure
- Spike verification concept
- Scope tiers concept
- Skeptic pass concept

## Design Decisions

### Flexible Critics (DECIDED)

**Decision:** Use flexible "spin up multiple subagents to critique" approach, NOT predefined critics.

**Rationale:** Real-world testing shows this pattern works well. The LLM can adapt the number and focus of critics to the plan's actual needs. The root cause of missed gaps was the question asked ("what's wrong?" vs "what's missing?"), not the critic structure.

**Rejected alternative:** Meta-critics suggested keeping predefined critics (Feasibility, Completeness, Simplicity) with gap-finding added. Rejected because flexible critics have proven effective in manual use.

## Open Questions

1. **Checklist Ownership**: Should checklists live in task templates (filled by critics) or be generated fresh by critics each time?

2. **Scope Detection Automation**: Can we auto-detect scope from the request, or should it always be confirmed with user?

3. **Overhead Tracking**: Should we add explicit overhead tracking (planning time vs implementation time) to STATUS.md?

## Files Changed (Summary)

```
skills/
├── domain-review/
│   ├── SKILL-v2.md                    # Hard gates for convergence
│   ├── security-critic-v2.md          # Dedicated security critic
│   ├── testing-critic-v2.md           # Enforces test plan population
│   ├── frontend-critic-v2.md          # Gap-finding added
│   └── references/
│       └── gap-finding-protocol.md    # Protocol for all critics
├── reviewing-plans/
│   └── SKILL-v2.md                    # Flexible critics + convergence + skeptic
├── task-breakdown/
│   └── assets/
│       └── task-template-v3.md        # General-purpose with checklists
├── user-journey-mapping/
│   └── references/
│       └── journey-categories-v2.md   # 6 categories with hard gate
├── using-devpowers/
│   └── SKILL-v2.md                    # Detailed scope tiers
└── writing-plans/
    └── SKILL-v2.md                    # Spike verification step
```
