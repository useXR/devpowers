# Journey Categories Guide

This guide applies to **any interface type**: Web UI, CLI, API, mobile app, embedded system, backend service.

## HARD GATE: Coverage Checklist

Before marking journey mapping complete, verify coverage of EACH category:

| Category | Min Journeys | Covered? |
|----------|--------------|----------|
| Happy Path | 1 per component | [ ] |
| Error States | 2 per component | [ ] |
| Edge Cases | 1 per component | [ ] |
| Interruption/Termination | 1 per feature | [ ] |
| Async/In-Progress States | 1 per async operation | [ ] |
| Alternative Access | 1 per component (if applicable) | [ ] |

**Convergence blocked until all categories covered or explicitly marked N/A with reason.**

---

## Category 1: Happy Path

The primary success scenario. What happens when everything works as intended.

**Document:**
- Entry point (where interaction starts)
- Each action/input
- Each system response
- Success state (final outcome)

**Platform Examples:**

| Platform | Example Happy Path |
|----------|-------------------|
| Web UI | User enters credentials → clicks login → sees dashboard |
| CLI | User runs `tool --config file.yaml` → sees "Config loaded" → operation completes |
| API | Client sends POST /users → receives 201 → user created |
| Backend Service | Request received → processed → response returned within SLA |

---

## Category 2: Error States

What happens when things go wrong.

**Must cover:**
- Invalid input (validation errors)
- System failures (service unavailable, resource exhausted)
- Network/communication failures (timeout, connection refused)
- Business logic errors (permissions, limits, conflicts)

**For each error:**
- Triggering condition
- Error indication (message, exit code, response code)
- Recovery options (how does caller get unstuck?)

**Platform Examples:**

| Platform | Error Indication |
|----------|-----------------|
| Web UI | Error message in UI, form validation |
| CLI | Non-zero exit code, stderr message |
| API | 4xx/5xx status code, error response body |
| Backend | Exception logged, circuit breaker triggered |

---

## Category 3: Edge Cases

Unusual but valid scenarios.

**Common edge cases (all platforms):**
- Empty state (no data yet)
- Maximum limits (huge input, many items)
- Minimum limits (empty input, zero items)
- Boundary values (exactly at limit)
- Rapid/repeated actions

**Platform-specific edge cases:**

| Platform | Edge Cases to Consider |
|----------|----------------------|
| CLI | Very long arguments, special characters in paths, Unicode input |
| API | Concurrent requests, request body at size limit, malformed JSON |
| Backend | High load, resource contention, clock skew |

---

## Category 4: Interruption/Termination

**This category was commonly missed in reviews.** What happens when operation is interrupted.

**Universal interruption scenarios:**
- Operation cancelled mid-way
- Process/connection terminated unexpectedly
- Timeout during operation
- Resource becomes unavailable mid-operation

**Platform-specific interruptions:**

| Platform | Interruption Scenarios |
|----------|----------------------|
| Web UI | Browser close, navigate away, tab switch, browser back |
| CLI | Ctrl+C (SIGINT), SIGTERM, SIGHUP, pipe closed |
| API | Client disconnect, request timeout, load balancer cut |
| Backend | Graceful shutdown signal, pod termination, database connection lost |
| Embedded | Watchdog timeout, power loss, hardware interrupt |

**For each interruption:**
- What state is preserved vs lost?
- Is partial work committed or rolled back?
- How to resume or restart?
- Are resources properly cleaned up?

---

## Category 5: Async/In-Progress States

**This category was commonly missed in reviews.** What happens during long-running operations.

**Must cover:**
- What indication during operation (progress, status, heartbeat)
- What actions available during operation (cancel, query status)
- What happens if operation is slow (timeout, retry)
- What happens if operation fails mid-way (partial success, cleanup)

**Platform-specific patterns:**

| Platform | In-Progress Indication |
|----------|----------------------|
| Web UI | Loading spinner, progress bar, streaming preview |
| CLI | Progress bar, spinner, periodic status output |
| API | 202 Accepted + polling endpoint, webhook callback, SSE stream |
| Backend | Health check endpoint, metrics, distributed tracing |

**For streaming/incremental output:**
- What does caller see as data arrives?
- Can caller interact with partial results?
- What happens if stream is interrupted?
- How does caller know operation is complete vs still running?

---

## Category 6: Alternative Access

Paths for users/callers with different needs or constraints.

**This category generalizes "Accessibility" to all platforms:**

| Platform | Alternative Access Patterns |
|----------|---------------------------|
| Web UI | Keyboard-only, screen reader, reduced motion, high contrast |
| CLI | Non-interactive/scripted use, piped input, no TTY, CI environment |
| API | Rate-limited clients, bandwidth-constrained, legacy client versions |
| Backend | Degraded mode, read-only mode, maintenance mode |

**For Web UI specifically:**
- Keyboard navigation complete?
- Screen reader announcements sensible?
- Focus management correct?
- Reduced motion respected?

**For CLI specifically:**
- Works when stdin is not a TTY?
- Works when stdout is piped?
- Works in CI (no interactive prompts)?
- Supports quiet/verbose modes?

**For API specifically:**
- Handles slow/limited clients gracefully?
- Backward compatible with older clients?
- Provides useful error messages for debugging?

---

## Category Applicability

Not all categories apply to every feature. Mark N/A with reason when appropriate:

| Category | When to mark N/A |
|----------|------------------|
| Happy Path | Never - always required |
| Error States | Never - always required (even if just "operation failed") |
| Edge Cases | Rarely - most features have at least empty/max states |
| Interruption/Termination | N/A for instantaneous operations (<100ms) |
| Async/In-Progress | N/A for synchronous-only features |
| Alternative Access | N/A if no alternative access patterns exist for this platform |

---

## Minimum Coverage Summary

**Per component/endpoint:**
- 1 happy path
- 2+ error states
- 1+ edge cases
- 1 alternative access journey (if applicable to platform)

**Per feature (in addition to per-component):**
- 1 interruption/termination journey
- 1 async/in-progress journey (if feature has async operations)

**Total minimum:** 5-7 journeys per component, plus feature-level journeys

---

## Red Flags (Gaps Often Missed)

If your journeys don't answer these questions, you have gaps:

### Universal (all platforms)
1. **"What if operation is killed mid-way?"** → Interruption gap
2. **"What does caller see while waiting?"** → Async/in-progress gap
3. **"What if this fails halfway through?"** → Error state gap
4. **"What if there's no data yet?"** → Edge case gap
5. **"What if caller does this twice rapidly?"** → Edge case gap

### Web UI specific
6. **"Can a keyboard-only user complete this?"** → Alternative access gap
7. **"What if user navigates away and back?"** → Interruption gap

### CLI specific
8. **"Does this work in a CI pipeline (non-interactive)?"** → Alternative access gap
9. **"What happens on Ctrl+C during operation?"** → Interruption gap
10. **"What's the exit code on failure?"** → Error state gap

### API specific
11. **"What if client disconnects mid-request?"** → Interruption gap
12. **"What status code for each error type?"** → Error state gap
13. **"Does response work for bandwidth-limited clients?"** → Alternative access gap

### Backend specific
14. **"What happens during graceful shutdown?"** → Interruption gap
15. **"How does health check behave during this operation?"** → Async/in-progress gap
