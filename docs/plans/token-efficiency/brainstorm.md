# Token Efficiency Refactor - Design

## Problem Statement

Devpowers consumes excessive tokens, impacting:
- **Cost** (primary concern)
- Session length limits
- Response latency

Current state:
- Total skill content: 21,682 words across 22 skills
- `using-devpowers` (1,686 words) loads on every session via SessionStart hook
- Several skills are 2-3x recommended sizes for progressive disclosure

## Goals

Reduce devpowers token consumption by ~60% while maintaining functionality.

**Target word counts:**
| Category | Current | Target |
|----------|---------|--------|
| Always-loaded (using-devpowers) | 1,686 | ~500 |
| Frequently-loaded skills | 1,500-1,600 | ~600-800 |
| Rarely-loaded skills | 2,500-3,200 | No change (low ROI) |

## Chosen Strategies

1. **Tiered skill loading** - Move detailed content to `references/` subdirectories
2. **Frequency-based prioritization** - Aggressive compression for frequently-loaded skills
3. **Model selection guidance** - Document haiku/sonnet/opus recommendations (Opus default for Max plan)
4. **Parallel foreground agents** - Document pattern for multi-critic reviews
5. **Minimal hook changes** - Skill compression handles injection naturally

## Skill Restructuring

### Priority 1: Always Loaded (Critical)

**`using-devpowers`** (1,686 → ~500 words)

```
using-devpowers/
├── SKILL.md                    # ~500 words - routing logic, flowchart, handoffs
└── references/
    ├── scope-tiers.md          # Detailed tier definitions
    ├── hard-gates.md           # Gate tables by scope
    └── red-flags.md            # Rationalization tables
```

**What stays in SKILL.md:**
- Version block and EXTREMELY-IMPORTANT directive
- Entry-point workflow (5-line pseudocode)
- Scope decision flowchart (simple ASCII)
- Handoff rules (3 bullets)
- "The Rule" and skill priority sections
- Pointers to references/ for details

**What moves to references/:**
- Detailed scope tier definitions (~500 words)
- Hard gates table (~150 words)
- Scope precedence rules (~150 words)
- Red flags rationalization table (~200 words)
- Integration checklist (~100 words)

### Priority 2: Frequently Loaded

| Skill | Current | Target | Strategy |
|-------|---------|--------|----------|
| test-driven-development | 1,612 | ~700 | Move examples + rationalization details to references/ |
| systematic-debugging | 1,504 | ~600 | Move detailed techniques to references/ |
| subagent-driven-development | 1,499 | ~600 | Move review workflows to references/ |
| reviewing-plans | 1,157 | ~500 | Move critic details to references/ |
| domain-review | 1,093 | ~500 | Move gate checklists to references/ |

### Priority 3: Lower Frequency (Light Touch)

| Skill | Current | Action |
|-------|---------|--------|
| writing-skills | 3,204 | No change - rarely loaded, reference skill |
| using-git-worktrees | 2,597 | Light compression if easy wins exist |
| Others (<900 words) | Various | No change - already reasonable |

## Model Selection Guidance

Add to `dispatching-parallel-agents` skill:

```markdown
## Model Selection for Subagents

The Task tool supports `model` parameter: "haiku", "sonnet", "opus".

**Default: Opus** - Use for all substantive work:
- Code review and analysis
- Implementation tasks
- Architectural decisions
- Security reviews
- Debugging and exploration
- Any task requiring judgment or creativity

**Haiku - Use for mechanical tasks only:**
- File existence checks (ls, glob patterns)
- Simple grep searches with known patterns
- STATUS.md reads/updates
- Counting lines, files, or matches
- Format validation (JSON valid? YAML valid?)
- Extracting specific fields from structured files

**Sonnet - Rarely needed:**
- Middle ground if Opus quota is running low
- Batch operations where Opus would be overkill but Haiku too limited

**Principle:** Quality over cost. Use Opus by default; drop to Haiku only
for tasks that are purely mechanical with no judgment required.
```

## Parallel Agent Guidance

Update `dispatching-parallel-agents` skill:

```markdown
## Parallel Foreground Pattern (Preferred)

When running multiple independent tasks:
1. Send single message with multiple Task tool calls
2. All agents run in parallel
3. Results return together
4. Main context stays lean (agent work is isolated)

**Example - Multi-critic review:**
Single message with 3 Task calls → 3 critics run simultaneously → results aggregated

**Avoid:** Sequential critic execution (loads each result into context serially)
```

## Implementation Phases

### Phase 1: Highest Impact (using-devpowers)
1. Create `references/` directory structure
2. Move detailed content to reference files
3. Compress SKILL.md to ~500 words
4. Test that skill still routes correctly
5. Verify hook injection works with smaller skill

**Estimated savings:** ~1,200 words per session

### Phase 2: Frequently Loaded Skills
In priority order:
1. `test-driven-development` (1,612 → ~700)
2. `systematic-debugging` (1,504 → ~600)
3. `subagent-driven-development` (1,499 → ~600)
4. `reviewing-plans` (1,157 → ~500)
5. `domain-review` (1,093 → ~500)

Each skill:
1. Identify content to move to references/
2. Create reference files
3. Update SKILL.md with pointers
4. Verify skill still functions correctly

**Estimated savings:** ~800-1,000 words per skill invocation

### Phase 3: Guidance Updates
1. Add model selection guidance to `dispatching-parallel-agents`
2. Update `subagent-driven-development` with parallel foreground patterns
3. Add `references/model-selection.md` as central reference

### Phase 4: Optional Light Touch
If time permits:
- Light compression of `using-git-worktrees` (2,597 words)
- Review other skills for easy wins

## Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| Skill behavior changes after moving content | Keep essential routing logic in SKILL.md. Test each skill after refactoring. |
| Reference files not loaded when needed | Include explicit "For details, see references/X.md" callouts |
| Over-compression breaks discipline skills | Keep red-flag lists inline. Move only detailed explanations to references. |
| Testing coverage | Test each skill with realistic scenarios after refactoring |

## Out of Scope

- Hook architecture changes (kept simple)
- Rarely-loaded skills (low ROI)
- Automated token counting/enforcement

## Estimated Impact

- Per-session baseline: ~1,200 words saved (using-devpowers alone)
- Per-skill-invocation: ~800 words saved (for refactored skills)
- Typical workflow with 3-4 skill loads: ~4,000-5,000 words saved
- Overall reduction: ~60% for common workflows
