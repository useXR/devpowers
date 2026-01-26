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

## 2. Data Flow

### Agent Invocation Flow

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

### Project-Setup Flow

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

## 3. Key Decisions

### 3.1 Agents vs Skills for Mechanical Tasks

**Decision:** Use agents, not skills.

**Rationale:** Only agents support the `model` field for routing to Haiku. Additionally, agents run in isolated context, preventing mechanical task output from polluting the main conversation.

### 3.2 Universal vs Per-Project Agents

**Decision:** Git agents in plugin (universal), test/lint/build as templates (per-project).

**Rationale:** Git commands are identical everywhere. Test/lint/build vary by stack.

### 3.3 Detect and Advise vs Auto-Install

**Decision:** Detect tools, advise user if missing. Don't auto-install.

**Rationale:** Installation requires user consent and varies by system (npm, pip, cargo, homebrew). Safer to advise.

### 3.4 Dora Skill Location

**Decision:** Copy template to `.dora/docs/SKILL.md`, symlink from `.claude/skills/dora/`.

**Rationale:** Matches the pattern you've already established. Skill travels with dora config.

## 4. Error Handling Strategy

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

## 5. Testing Strategy

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

## 6. Known Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| Agent `model: haiku` not respected by Claude Code | Test early; this is core to the feature |
| detect-stack.sh misidentifies project | Keep detection simple; err toward generic |
| Dora indexing fails for some projects | Graceful failure; dora is optional enhancement |
| Agent descriptions conflict with existing agents | Use specific, unique descriptions |
| Template substitution edge cases | Keep templates simple; test common stacks |

## 7. File Structure

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

## 8. Implementation Order

1. **Create universal git agents** - Quick win, immediately useful
2. **Create agent templates** - Test/lint/typecheck/build
3. **Create dora assets** - Skill template + hooks template
4. **Update detect-stack.sh** - Add tool detection (test runner, linter, etc.)
5. **Update project-setup SKILL.md** - Extended workflow
6. **Test on sample projects** - TypeScript, Python, Rust
7. **Update related skills** - Add references to new agents
