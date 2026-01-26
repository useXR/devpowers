# Tool Efficiency Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use devpowers:subagent-driven-development to implement this plan task-by-task.

**Goal:** Reduce Opus token usage by routing mechanical tasks to Haiku agents and enabling dora/LSP for code exploration.

**Architecture:** Create haiku-routed agents for git/test/lint operations, update project-setup to auto-configure dora and stack-specific agents.

**Tech Stack:** Claude Code agents with `model: haiku`, dora CLI, typescript-language-server

---

## Spike Verification Summary

| Assumption | Status | Evidence |
|------------|--------|----------|
| Skills support `model` field | ❌ Failed | Docs show only agents support `model` |
| Agents support `model: haiku` | ✅ Verified | sub-agents.md: "Can be a model alias (`sonnet`, `opus`, `haiku`)" |
| Dora creates predictable structure | ✅ Verified | Tested in session - creates `.dora/` with config.json |

**Design adjusted:** Using agents instead of skills for haiku-routed tasks.

---

## 1. Components

### 1.1 Universal Haiku Agents (in devpowers)

Agents that work for any project:

| Agent | Purpose | Commands |
|-------|---------|----------|
| `git-status` | Show repo state | `git status`, `git diff --stat` |
| `git-sync` | Pull latest changes | `git fetch && git pull --rebase` |
| `git-push` | Push changes safely | `git push` with branch checks |

Location: `devpowers/agents/`

### 1.2 Stack-Specific Agent Templates (in project-setup)

Templates customized per-project by project-setup:

| Agent | Customized By |
|-------|---------------|
| `test` | Package manager + test runner (jest, pytest, cargo) |
| `lint` | Linter detected (eslint, ruff, clippy) |
| `typecheck` | Type checker detected (tsc, pyright, mypy) |
| `build` | Build system detected |

Location: `project-setup/assets/agent-templates/`
Output: `.claude/agents/` in target project

### 1.3 Dora Integration Assets

| Asset | Purpose |
|-------|---------|
| `dora/SKILL.md` | Comprehensive dora skill (already exists) |
| `hooks/dora-hooks.json` | SessionStart/Stop auto-indexing hooks |

Location: `project-setup/assets/`

### 1.4 Updated Project-Setup Skill

Extended workflow:
1. Detect stack (existing)
2. Create master docs (existing)
3. **NEW:** Initialize dora if supported
4. **NEW:** Check LSP availability
5. **NEW:** Generate stack-specific agents
6. Commit and handoff

## 2. Specifications (Reviewer-Requested)

### 2.1 Hook Merging Algorithm

When merging dora hooks into `settings.local.json`:

```
1. Read existing settings.local.json (or create empty {})
2. Parse hooks object (or create empty {hooks: {}})
3. For each dora hook event (SessionStart, Stop):
   a. Get existing hooks array for that event (or create [])
   b. Append dora hook entry to array
   c. Preserve all existing hooks
4. Write merged result back to settings.local.json
```

**Dora hooks to add:**
```json
{
  "hooks": {
    "SessionStart": [{"type": "command", "command": "dora status 2>/dev/null && (dora index > /tmp/dora-index.log 2>&1 &) || echo 'dora not initialized'"}],
    "Stop": [{"type": "command", "command": "(dora index > /tmp/dora-index.log 2>&1 &) || true"}]
  }
}
```

### 2.2 Template Substitution Format

Agent templates use `{{PLACEHOLDER}}` syntax:

| Placeholder | Source | Example Values |
|-------------|--------|----------------|
| `{{TEST_COMMAND}}` | detect-stack.sh | `npm test`, `pytest`, `cargo test` |
| `{{LINT_COMMAND}}` | detect-stack.sh | `npm run lint`, `ruff check .`, `cargo clippy` |
| `{{TYPECHECK_COMMAND}}` | detect-stack.sh | `npx tsc --noEmit`, `pyright`, N/A |
| `{{BUILD_COMMAND}}` | detect-stack.sh | `npm run build`, `cargo build`, N/A |

**Substitution algorithm:**
1. Read template from `assets/agent-templates/`
2. For each `{{PLACEHOLDER}}`:
   a. Look up value from detect-stack.sh output
   b. If found, replace placeholder
   c. If not found, skip creating that agent (not all stacks have all tools)
3. Write result to `.claude/agents/`

### 2.3 Dora Dependency Detection

Dora requires **both** the CLI and a language-specific indexer:

| Language | CLI | Indexer | Check Command |
|----------|-----|---------|---------------|
| TypeScript/JS | `dora` | `scip-typescript` | `which scip-typescript` |
| Python | `dora` | `scip-python` | `which scip-python` |
| Rust | `dora` | `rust-analyzer` | `which rust-analyzer` |

**Detection flow:**
1. Check `which dora` - if missing, advise: "Install dora: `npm install -g @anthropic/dora-cli`"
2. Check language-specific indexer - if missing, advise: "Install indexer: `npm install -g @anthropic/scip-typescript`"
3. Only proceed with dora init if both are present

### 2.4 LSP Scope (Advisory Only)

LSP detection is **advisory only** - no integration, just user guidance:

| Language | Check | Advisory Message |
|----------|-------|------------------|
| TypeScript | `which typescript-language-server` | "For better IDE support, install: `npm install -g typescript-language-server`" |
| Python | `which pyright` | "For better IDE support, install: `pip install pyright`" |

No agents or skills are created for LSP. It's a helpful note in project-setup output.

---

## 3. Data Flow

### 3.1 Agent Invocation Flow

```
User/Claude requests mechanical task
         │
         ▼
┌─────────────────────┐
│ Claude recognizes   │
│ agent description   │
│ matches task        │
└─────────────────────┘
         │
         ▼
┌─────────────────────┐
│ Task tool launches  │
│ agent with model:   │
│ haiku               │
└─────────────────────┘
         │
         ▼
┌─────────────────────┐
│ Haiku executes      │
│ command, reports    │
│ results             │
└─────────────────────┘
         │
         ▼
Results return to main conversation
(minimal tokens consumed)
```

### 3.2 Project-Setup Flow

```
project-setup invoked
         │
         ▼
┌─────────────────────┐
│ detect-stack.sh     │
│ → languages, tools  │
└─────────────────────┘
         │
         ▼
┌─────────────────────────────────────┐
│ For each supported language:        │
│ - Check dora installed              │
│ - Run dora init                     │
│ - Copy dora skill to .dora/docs/    │
│ - Create symlink in .claude/skills/ │
│ - Merge hooks into settings.local   │
└─────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────┐
│ For each detected tool:             │
│ - Read agent template               │
│ - Substitute commands               │
│ - Write to .claude/agents/          │
└─────────────────────────────────────┘
         │
         ▼
Commit, handoff
```

## 4. Key Decisions

### 4.1 Agents vs Skills for Mechanical Tasks

**Decision:** Use agents, not skills.

**Rationale:** Only agents support the `model` field for routing to Haiku. Additionally, agents run in isolated context, preventing mechanical task output from polluting the main conversation.

### 4.2 Universal vs Per-Project Agents

**Decision:** Git agents in plugin (universal), test/lint/build as templates (per-project).

**Rationale:** Git commands are identical everywhere. Test/lint/build vary by stack.

### 4.3 Detect and Advise vs Auto-Install

**Decision:** Detect tools, advise user if missing. Don't auto-install.

**Rationale:** Installation requires user consent and varies by system (npm, pip, cargo, homebrew). Safer to advise.

### 4.4 Dora Skill Location

**Decision:** Copy template to `.dora/docs/SKILL.md`, symlink from `.claude/skills/dora/`.

**Rationale:** Matches the pattern you've already established. Skill travels with dora config.

## 5. Error Handling Strategy

### Tool Detection Failures

- If `detect-stack.sh` fails: Continue with generic fallbacks, warn user
- If dora not installed: Skip dora setup, advise user with install command
- If LSP not installed: Skip LSP note, advise user

### Agent Execution Failures

Haiku agents should:
- Report command exit code
- Include stderr in output
- Not attempt to fix problems (that's Opus's job)

### Missing Commands

If a generated agent's command fails (e.g., `npm test` but no test script):
- Agent reports the error
- User/Opus decides how to proceed

## 6. Testing Strategy

### Unit Testing

- Test `detect-stack.sh` with various project structures
- Test template substitution logic

### Integration Testing

- Run project-setup on sample TypeScript project
- Verify agents created with correct commands
- Verify dora initialized and hooks added
- Test each agent runs successfully

### Manual Verification

- Invoke `/test`, `/lint`, etc. and verify Haiku handles them
- Check token usage to confirm savings

## 7. Known Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| Agent `model: haiku` not respected by Claude Code | Test early; this is core to the feature |
| detect-stack.sh misidentifies project | Keep detection simple; err toward generic |
| Dora indexing fails for some projects | Graceful failure; dora is optional enhancement |
| Agent descriptions conflict with existing agents | Use specific descriptions with "mechanical task" and "Haiku" keywords |
| Template substitution edge cases | Keep templates simple; test common stacks |
| Windows symlink limitations | Use file copy instead of symlink; symlinks optional optimization |
| Dora indexer missing | Check for both dora CLI and language indexer before init |

## 8. File Structure

### In devpowers plugin

```
devpowers/
├── agents/
│   ├── git-status.md      # NEW: Universal, model: haiku
│   ├── git-sync.md        # NEW: Universal, model: haiku
│   └── git-push.md        # NEW: Universal, model: haiku
└── skills/
    └── project-setup/
        ├── SKILL.md       # UPDATED: Extended workflow
        ├── scripts/
        │   └── detect-stack.sh  # EXISTS
        └── assets/
            ├── agent-templates/
            │   ├── test.md      # NEW
            │   ├── lint.md      # NEW
            │   ├── typecheck.md # NEW
            │   └── build.md     # NEW
            ├── dora/
            │   └── SKILL.md     # NEW: Dora skill template
            └── hooks/
                └── dora-hooks.json  # NEW
```

### Output in target project

```
.claude/
├── settings.local.json  # UPDATED: Includes dora hooks
├── skills/
│   └── dora/
│       └── SKILL.md → ../../../.dora/docs/SKILL.md
└── agents/
    ├── test.md          # Customized for stack
    ├── lint.md          # Customized for stack
    ├── typecheck.md     # Customized for stack
    └── build.md         # Customized for stack

.dora/
├── config.json
└── docs/
    └── SKILL.md         # Copied from template
```

## 9. Implementation Order

1. **Create universal git agents** - Quick win, immediately useful
2. **Create agent templates** - Test/lint/typecheck/build
3. **Create dora assets** - Skill template + hooks template
4. **Update detect-stack.sh** - Add tool detection (test runner, linter, etc.)
5. **Update project-setup SKILL.md** - Extended workflow
6. **Test on sample projects** - TypeScript, Python, Rust
7. **Update related skills** - Add references to new agents

---

## Revision History

### v2 - 2026-01-26 - Plan Review Round 1

**Issues Addressed:**
- [CRITICAL] Added Section 2: Specifications with hook merging algorithm
- [CRITICAL] Added template substitution format with placeholders
- [CRITICAL] Added dora indexer dependency detection
- [IMPORTANT] Clarified LSP scope as advisory-only
- [IMPORTANT] Added Windows symlink mitigation
- [MINOR] Fixed section numbering (was missing section 2)

**Reviewer Notes:** 3 critics found overlapping issues around undefined specifications. Added concrete algorithms for hook merging, template substitution, and dependency detection.
