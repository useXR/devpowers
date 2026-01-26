# Token Efficiency Refactor - Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use devpowers:subagent-driven-development to implement this plan task-by-task.

**Goal:** Reduce devpowers token consumption by ~60% through progressive disclosure and skill compression.

**Architecture:** Restructure high-token skills to use references/ subdirectories for detailed content, keeping SKILL.md files lean (~500 words for always-loaded, ~600-800 for frequently-loaded). Add model selection guidance for subagent delegation.

**Tech Stack:** Markdown restructuring, shell script (hook unchanged), YAML frontmatter

---

## Spike Verification Summary

| Assumption | Status | Evidence |
|------------|--------|----------|
| references/ pattern is supported | ✅ Verified | 9 existing skills use it; documented in project-setup |
| Compressed skills route correctly | ✅ Verified | project-setup (196 words) works via frontmatter description |

---

## 1. Components

### 1.1 Skill Compression Module

**Purpose:** Restructure individual skills to separate core content from reference material.

**For each skill:**
- Identify content categories (core routing vs. detailed reference)
- Create references/ subdirectory
- Move detailed content to reference files
- Update SKILL.md with pointers to references
- Preserve frontmatter description (routing depends on it)

**Skills to compress (in priority order):**

| Priority | Skill | Current | Target | Reason |
|----------|-------|---------|--------|--------|
| P1 | using-devpowers | 1,686 | ~500 | Loads every session |
| P2 | test-driven-development | 1,612 | ~900 | Loads on most implementations (discipline skill - higher target) |
| P2 | systematic-debugging | 1,504 | ~800 | Loads on debugging (discipline skill - higher target) |
| P2 | subagent-driven-development | 1,499 | ~600 | Loads on plan execution |
| P2 | reviewing-plans | 1,157 | ~500 | Loads during review phase |
| P2 | domain-review | 1,093 | ~500 | Loads during review phase |

### 1.2 Model Selection Guidance

**Purpose:** Document when to use haiku vs. opus for subagents.

**Location:** Add section to `dispatching-parallel-agents` skill + create `references/model-selection.md` as central reference.

**Content:**
- Opus as default for substantive work
- Haiku for mechanical tasks (file checks, simple greps, STATUS updates)
- Sonnet as fallback if opus quota concerns

### 1.3 Parallel Agent Guidance

**Purpose:** Document parallel foreground pattern for multi-critic reviews.

**Location:** Update `dispatching-parallel-agents` and `subagent-driven-development` skills.

**Content:**
- Single message with multiple Task calls
- Results return together
- Avoids sequential context accumulation

---

## 2. Data Flow

### 2.1 Skill Loading Flow (Current)

```
SessionStart hook
    → Reads using-devpowers/SKILL.md (1,686 words)
    → Injects into context

User invokes skill
    → Skill tool loads SKILL.md
    → Full content in context
```

### 2.2 Skill Loading Flow (After)

```
SessionStart hook
    → Reads using-devpowers/SKILL.md (~500 words)
    → Injects into context

User invokes skill
    → Skill tool loads SKILL.md (~500-800 words)
    → Claude reads references/ as needed
    → Only relevant details loaded
```

### 2.3 Content Migration Flow

For each skill being compressed:

```
1. Analyze SKILL.md content
2. Categorize: core (keep) vs. detailed (move)
3. Create references/ files
4. Update SKILL.md with pointers
5. Test skill still functions
6. Commit changes
```

---

## 3. Key Decisions

### 3.1 Keep frontmatter unchanged

**Decision:** Do not modify skill frontmatter (name, description).

**Rationale:** Routing depends on description matching user queries. Changing descriptions risks breaking skill discovery.

### 3.2 Explicit reference pointers

**Decision:** Add clear reference pointers using a standard format.

**Standard format for required references:**
```markdown
**For detailed guidance:** Read `./references/[name].md` before proceeding.
```

**Standard format for optional references:**
```markdown
**Reference:** `./references/[name].md` - [one-line description]
```

**Rationale:** Claude won't know references exist unless explicitly told. Consistent format aids discovery and makes pointer intent clear (required vs optional).

### 3.3 Content categorization criteria

**Decision:** Use explicit criteria to decide what stays inline vs. moves to references.

**Core content (keep inline):**
- Routing logic and decision flowcharts
- Handoff rules and skill invocation triggers
- Discipline enforcers (red-flag lists, rationalization tables) for TDD and debugging skills
- Convergence algorithms and procedural steps

**Reference content (can move):**
- Detailed tier definitions and verbose explanations
- Example tables and supporting evidence
- Severity guides and classification details
- Scope precedence rules and edge cases

**Rationale:** Core content must be immediately visible for correct behavior. Reference content supports understanding but isn't needed for every invocation.

**Special cases:**
- `using-devpowers` red flags SHOULD stay inline (frequently referenced, only ~200 words)
- TDD and debugging red flags MUST stay inline (discipline enforcement is critical)

**Existing structure handling:**
- Some skills already have direct files in skill folder (e.g., `systematic-debugging/root-cause-tracing.md`)
- During compression: move existing direct files to `references/` subdirectory for consistency
- Or document that direct files remain if they serve different purposes (e.g., technique guides vs. reference tables)

### 3.4 No hook architecture changes

**Decision:** Keep session-start.sh unchanged. The hook uses `cat` to read SKILL.md, so compressing the file directly reduces injected tokens.

**Rationale:** The hook reads whatever is in SKILL.md. No code changes needed - compress the skill file and the hook automatically injects less content.

**Verification:** After compression, session-start.sh will inject ~500 words instead of ~1,686 words.

### 3.5 Opus as default model

**Decision:** Document opus as the default for subagents, haiku only for mechanical tasks.

**Rationale:** User has Max plan (20x), prioritizes quality over cost savings on model selection.

---

## 4. Error Handling Strategy

### 4.1 Skill breaks after compression

**Detection:** Skill doesn't trigger correctly or produces wrong behavior.

**Recovery:**
- Restore from git (each skill committed separately)
- Analyze what was incorrectly moved to references
- Re-compress with corrections

### 4.2 References not loaded

**Detection:** Claude doesn't read referenced content when needed.

**Recovery:**
- Make reference pointers more explicit ("MUST read references/X.md before...")
- Consider keeping more content inline for critical paths

### 4.3 Discipline skill circumvented

**Detection:** TDD or debugging shortcuts observed after compression.

**Recovery:**
- Move rationalization counters back to SKILL.md
- Keep references only for verbose explanations, not the rules themselves

---

## 5. Testing Strategy

### 5.1 Per-skill functional tests

After compressing each skill, test with specific scenarios:

| Skill | Trigger Phrase | Expected Behavior | Critical Content to Verify |
|-------|---------------|-------------------|---------------------------|
| using-devpowers | "start a feature" | Routes to brainstorming | Scope flowchart visible |
| test-driven-development | "implement with TDD" | Shows red-green-refactor | Red flags table inline |
| systematic-debugging | "debug this issue" | Shows hypothesis process | Iron law visible |
| subagent-driven-development | "execute this plan" | Dispatches subagents | Review workflow present |
| reviewing-plans | "review this plan" | Runs critics | Convergence rules present |
| domain-review | "review tasks" | Checks hard gates | Gate criteria visible |

**Test procedure:**
1. Invoke skill with trigger phrase
2. Verify critical content appears without reading references
3. Trigger a scenario requiring reference content (see table below)
4. Verify Claude reads the appropriate reference file

**Reference trigger scenarios:**
| Skill | Scenario | Expected Reference |
|-------|----------|-------------------|
| using-devpowers | "Explain what happens when scope conflicts" | scope-tiers.md |
| reviewing-plans | "What severity is a missing edge case?" | severity-guide.md |
| domain-review | "What's the gap-finding protocol?" | gap-finding-protocol.md |
| TDD/debugging | N/A - discipline content stays inline | N/A |

### 5.2 Integration test

After all P1 and P2 skills compressed:
1. Run through complete workflow (brainstorm → plan → review → implement)
2. Measure actual token usage vs. baseline
3. Verify no workflow breaks

### 5.3 Regression markers

Document expected behavior for each skill:
- Trigger phrases that should work
- Key guidance that must appear
- References that should be consulted for specific scenarios

---

## 6. Implementation Sequence

### Phase 1: using-devpowers (P1)

1. Create references/ directory structure
2. Move scope tier details to `references/scope-tiers.md`
3. Move hard gates table to `references/hard-gates.md`
4. Move red flags table to `references/red-flags.md`
5. Compress SKILL.md to ~500 words with pointers
6. Test hook injection still works
7. Test skill routing still works
8. Commit

### Phase 2: Frequently loaded skills (P2)

For each skill (TDD, debugging, subagent-driven, reviewing-plans, domain-review):
1. Identify detailed content to move
2. Create references/ files
3. Compress SKILL.md with pointers
4. Test skill functions correctly
5. Commit

### Phase 3: Guidance documentation (Optional/Stretch)

**Note:** This phase adds new content rather than compressing existing content. It's orthogonal to the main token reduction goal. Implement only if Phases 1-2 complete successfully and time permits.

1. Add model selection section to dispatching-parallel-agents
2. Create references/model-selection.md
3. Update subagent-driven-development with parallel patterns
4. Commit

### Phase 4: Validation

1. Run integration test: brainstorm → plan → review → implement cycle
2. Measure word counts before/after for each compressed skill
3. Verify no workflow breaks in the integration test
4. Document results in learnings.md

**Rollback criteria:**
- If any skill fails to trigger on expected phrases: revert that skill immediately
- If workflow breaks (can't complete brainstorm→implement cycle): revert to last working state
- If token savings <40% (vs. target 60%): evaluate whether to proceed or adjust targets

**Baseline measurement:**
| Skill | Before (words) | Target (words) | Expected Savings | Notes |
|-------|---------------|----------------|------------------|-------|
| using-devpowers | 1,686 | 600 | 1,086 (64%) | Keep red flags inline |
| test-driven-development | 1,612 | 900 | 712 (44%) | Discipline skill - keep tables inline |
| systematic-debugging | 1,504 | 800 | 704 (47%) | Discipline skill - keep tables inline |
| subagent-driven-development | 1,499 | 600 | 899 (60%) | Templates already external |
| reviewing-plans | 1,157 | 600 | 557 (48%) | Already has references/ |
| domain-review | 1,093 | 600 | 493 (45%) | Already has references/ |
| **Total** | **8,551** | **4,100** | **4,451 (52%)** | Realistic targets |

**Measurement methodology:** Use `wc -w SKILL.md` for consistency. All measurements exclude references/ content.

---

## 7. Known Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Compressed skill loses critical content | Medium | High | Test each skill after compression; keep red-flag lists inline |
| References not consulted when needed | Medium | Medium | Explicit pointers with "MUST read" language for critical refs |
| Frontmatter description accidentally changed | Low | High | Review diffs carefully; descriptions are routing-critical |
| Hook injection breaks | Low | High | Test session start after P1; hook code unchanged |
| Token savings less than expected | Low | Medium | Measure after each phase; adjust targets if needed |

---

## 8. Success Criteria

| Metric | Target |
|--------|--------|
| using-devpowers word count | ≤600 words |
| Discipline skills (TDD, debugging) | ≤900 words each |
| Other P2 skills | ≤600 words each |
| Per-session word reduction | ~1,100 words |
| Overall reduction | ~52% (4,451 words) |
| All skills still functional | 100% pass rate |
| No workflow breaks | Zero regressions |

---

## 9. Out of Scope

- Rarely-loaded skills (writing-skills, using-git-worktrees) - low ROI
- Hook architecture changes - unnecessary complexity
- Automated token counting/enforcement - manual measurement sufficient
- Changes to skill discovery/routing mechanism - working as designed

---

## Revision History

### v2 - 2026-01-26 - Plan Review Round 1

**Issues Addressed:**
- [CRITICAL] Clarified hook injection mechanism - compression reduces injected tokens directly
- [CRITICAL] Resolved contradictory red-flags decision - routing skills can move red-flags, discipline skills keep inline
- [CRITICAL] Added content categorization criteria for core vs. reference content
- [IMPORTANT] Added specific test scenarios with trigger phrases and expected behaviors
- [IMPORTANT] Added rollback criteria and baseline measurement table
- [IMPORTANT] Added standard reference pointer format
- [IMPORTANT] Marked Phase 3 as optional/stretch goal (scope creep concern)

**Reviewer Notes:** Three critics found overlapping concerns about hook mechanism, testing specificity, and content categorization. All critical issues addressed.

### v3 - 2026-01-26 - Plan Review Round 2

**Issues Addressed:**
- [CRITICAL] Added handling for existing directory structures (some skills use direct files, not references/)
- [IMPORTANT] Increased discipline skill targets (TDD: 700→900, debugging: 600→800) - must keep tables inline
- [IMPORTANT] Increased using-devpowers target (500→600) - keep red flags inline
- [IMPORTANT] Added reference trigger scenarios for testing methodology
- [IMPORTANT] Added measurement methodology note (wc -w for consistency)
- [MINOR] Updated total savings estimate (60%→52%) to reflect realistic targets

**Reviewer Notes:** Two critics converged on discipline skill targets being unrealistic. Adjusted targets to preserve discipline enforcement. Overall savings reduced but more achievable.
