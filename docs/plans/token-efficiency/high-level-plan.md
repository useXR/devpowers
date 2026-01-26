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
| P2 | test-driven-development | 1,612 | ~700 | Loads on most implementations |
| P2 | systematic-debugging | 1,504 | ~600 | Loads on debugging |
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

**Decision:** Add clear "For details, see references/X.md" callouts in SKILL.md.

**Rationale:** Claude won't know references exist unless explicitly told. Implicit discovery is unreliable.

### 3.3 Keep red-flag lists inline for discipline skills

**Decision:** For TDD and debugging skills, keep the "red flags" / rationalization tables in SKILL.md, move only detailed explanations to references.

**Rationale:** These tables are critical for preventing shortcuts. They must be immediately visible, not buried in references.

### 3.4 No hook architecture changes

**Decision:** Keep session-start.sh unchanged except it now reads a smaller skill file.

**Rationale:** Simplicity. The skill compression naturally reduces injected content.

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

After compressing each skill:
1. Invoke skill with typical trigger phrase
2. Verify skill loads and provides correct guidance
3. Verify Claude reads references when appropriate
4. Check no critical content is missing from immediate view

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

### Phase 3: Guidance documentation

1. Add model selection section to dispatching-parallel-agents
2. Create references/model-selection.md
3. Update subagent-driven-development with parallel patterns
4. Commit

### Phase 4: Validation

1. Run integration test through complete workflow
2. Measure token savings
3. Document results in learnings.md

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
| using-devpowers word count | ≤500 words |
| P2 skills word count | ≤800 words each |
| Per-session token reduction | ~1,200 words |
| Per-workflow token reduction | ~4,000-5,000 words |
| All skills still functional | 100% pass rate |
| No workflow breaks | Zero regressions |

---

## 9. Out of Scope

- Rarely-loaded skills (writing-skills, using-git-worktrees) - low ROI
- Hook architecture changes - unnecessary complexity
- Automated token counting/enforcement - manual measurement sufficient
- Changes to skill discovery/routing mechanism - working as designed
