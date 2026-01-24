# Devpowers Rework Status

**Stage:** Phase 1 - Complete (v2 files ready for testing)
**Scope:** Medium (reworking existing system, not building new)
**Last Updated:** 2026-01-16

## Current State

### Completed
- [x] Analyzed critique feedback from two real features
- [x] Identified root cause (generative critics asking wrong question)
- [x] Created initial v2 files
- [x] Ran meta-critique with 3 parallel agents
- [x] Documented meta-critique findings
- [x] Decided: Keep flexible critics (user preference based on real-world use)
- [x] Addressed all CRITICAL issues from meta-critique
- [x] Addressed all IMPORTANT issues from meta-critique

### CRITICAL Issues (All Fixed)

| # | Task | Status |
|---|------|--------|
| 1 | Clarify convergence: "No new CRITICAL/IMPORTANT in 2 consecutive rounds" | ✅ DONE |
| 2 | Unify round limits across skills (convergence-based, same threshold) | ✅ DONE |
| 3 | Generalize journey categories for CLI/backend/embedded | ✅ DONE |
| 4 | Add N/A validation requirements (can't mark security N/A without proof) | ✅ DONE |
| 5 | Expand security checklist (timing, resource exhaustion, crypto, races) | ✅ DONE |

### IMPORTANT Issues (All Fixed)

| # | Task | Status |
|---|------|--------|
| 6 | Change test gate from quantity to coverage categories | ✅ DONE |
| 7 | Add scope precedence rules (when indicators conflict, go higher) | ✅ DONE |
| 8 | Soften skeptic framing (investigative not adversarial) | ✅ DONE |
| 9 | Add spike scope guidance (<30 min, verification criteria) | ✅ DONE |
| 10 | Add integration checklist for Medium scope | ✅ DONE |
| 11 | Add scope re-evaluation checkpoint after task breakdown | ✅ DONE |

### Next Actions

1. **Phase 2: Integration Testing**
   - Test v2 workflow on a Small scope feature
   - Test v2 workflow on a Medium scope feature
   - Run meta-review on test results to compare gap count

2. **Phase 3: Refinement** (after testing)
   - Tune based on test results

3. **Phase 4: Deployment** (after refinement)
   - Replace v1 files with v2 files

## Files Modified/Created

### New v2 Files
- `reviewing-plans/SKILL-v2.md` - Convergence + skeptic pass
- `domain-review/SKILL-v2.md` - Hard gates + convergence
- `domain-review/security-critic-v2.md` - Expanded checklist + N/A validation
- `domain-review/testing-critic-v2.md` - Coverage categories
- `domain-review/frontend-critic-v2.md` - Gap-finding
- `domain-review/references/gap-finding-protocol.md` - Gap-finding protocol
- `writing-plans/SKILL-v2.md` - Spike verification
- `task-breakdown/SKILL-v2.md` - Scope re-evaluation checkpoint
- `task-breakdown/assets/task-template-v3.md` - General-purpose with checklists
- `user-journey-mapping/references/journey-categories-v2.md` - Platform-agnostic
- `using-devpowers/SKILL-v2.md` - Scope tiers + precedence rules

## Decision Log

| Date | Decision | Rationale |
|------|----------|-----------|
| 2026-01-16 | Use "spin up multiple subagents" instead of fixed number | Let LLM decide how many critics needed |
| 2026-01-16 | Keep checklists general-purpose | System should work for any language/platform |
| 2026-01-16 | Add gap-finding to critics rather than replacing them | Same LLM with different prompt finds different issues |
| 2026-01-16 | **Keep flexible critics** | User has real-world success with this pattern |
| 2026-01-16 | Convergence = 2 consecutive clean rounds | Single clean round could be lucky |
| 2026-01-16 | Test gate = coverage categories not count | Prevents gaming with 3 trivial tests |
| 2026-01-16 | Security N/A requires proof of 4 conditions | Prevents gaming by marking everything N/A |

## Blockers

None currently.

## Notes

- All CRITICAL and IMPORTANT issues from meta-critique addressed
- Ready for Phase 2 testing
- v2 files are still drafts, originals unchanged
