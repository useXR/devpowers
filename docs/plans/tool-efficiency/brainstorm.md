# Tool Efficiency - Design

## Problem Statement

Using Opus for everything burns through token limits quickly. Many tasks don't need Opus-level reasoning:
- Git operations (status, sync, push)
- Running tests, linting, typechecking
- Code exploration (finding symbols, dependencies)

## Goals

Reduce Opus token usage by:
1. Routing mechanical tasks to Haiku via dedicated skills
2. Using dora/LSP for code exploration (zero model tokens)
3. Auto-configuring these tools via project-setup

## Deliverables

| Type | Items |
|------|-------|
| **New skills in devpowers** | `git-status`, `git-sync`, `git-push` (universal, haiku) |
| **New skill templates** | `test`, `lint`, `typecheck`, `build` (stack-specific, haiku) |
| **Updates to project-setup** | Dora init, LSP detection, skill template customization |
| **Dora skill template** | Template for `.dora/docs/SKILL.md` |
| **Hooks template** | Auto-indexing hooks for `settings.local.json` |

## Architecture

**CORRECTION:** Spike verification revealed that `model` routing is only supported for **agents**, not skills. Design adjusted accordingly.

### Agent Structure

```
devpowers/agents/
├── git-status.md         # Universal, model: haiku
├── git-sync.md           # Universal, model: haiku
└── git-push.md           # Universal, model: haiku

devpowers/skills/project-setup/
├── SKILL.md              # Updated workflow
├── scripts/
│   └── detect-stack.sh
└── assets/
    ├── agent-templates/
    │   ├── test.md
    │   ├── lint.md
    │   ├── typecheck.md
    │   └── build.md
    ├── dora/
    │   └── SKILL.md
    └── hooks/
        └── dora-hooks.json
```

### Project Output (TypeScript example)

```
.claude/
├── settings.local.json     # Includes dora hooks
├── skills/
│   └── dora/
│       └── SKILL.md → ../../../.dora/docs/SKILL.md
└── agents/
    ├── test.md             # Customized: "npm test"
    ├── lint.md             # Customized: "npm run lint"
    ├── typecheck.md        # Customized: "npx tsc --noEmit"
    └── build.md            # Customized: "npm run build"

.dora/
├── config.json
├── index.scip
└── docs/
    └── SKILL.md
```

### Model Routing

Via agent frontmatter (agents support `model`, skills do not):

```markdown
---
name: test
model: haiku
description: Run project tests and report results
tools: Bash
---
```

## Project-Setup Workflow

```
1. Run `scripts/detect-stack.sh` → get languages/frameworks
2. Create master docs (existing behavior)

3. [NEW] Tool setup:
   a. Check if dora is installed (`which dora`)
   b. If language is dora-supported:
      - Run `dora init`
      - Copy dora SKILL.md to `.dora/docs/SKILL.md`
      - Create symlink `.claude/skills/dora/SKILL.md`
      - Merge dora hooks into `.claude/settings.local.json`
   c. If dora not installed → advise user

4. [NEW] LSP check:
   - TypeScript → check `typescript-language-server`
   - Python → check `pyright` or `pylsp`
   - If missing → advise user

5. [NEW] Stack-specific skills:
   - Read templates from `assets/skill-templates/`
   - Customize commands based on detected stack
   - Write to `.claude/skills/`

6. Commit setup files
7. Handoff
```

### Stack Detection → Command Mapping

| Detected | `/test` | `/lint` | `/typecheck` | `/build` |
|----------|---------|---------|--------------|----------|
| npm + jest | `npm test` | `npm run lint` | `npx tsc --noEmit` | `npm run build` |
| yarn + vitest | `yarn test` | `yarn lint` | `yarn tsc --noEmit` | `yarn build` |
| Python + pytest | `pytest` | `ruff check .` | `pyright` | N/A |
| Rust | `cargo test` | `cargo clippy` | N/A | `cargo build` |

## Haiku Agent Design

**Principles:**
- Minimal instructions (~50-100 words)
- Execute and report - no reasoning
- Facts only: pass/fail, errors with locations
- Fail fast - report problems, don't fix
- Agents run in isolated context (don't pollute main conversation)

**Example (`test` agent):**

```markdown
---
name: test
model: haiku
description: Run project tests and report results. Use when tests need to be run.
tools: Bash
---

Execute the test command and report results.

Command: `npm test`

Report:
- Total tests, passed, failed, skipped
- For failures: test name, file:line, error message
- Exit code

Do not analyze or suggest fixes. Just report results.
```

**Example (`git-status` agent):**

```markdown
---
name: git-status
model: haiku
description: Show git repository status. Use to check current branch and changes.
tools: Bash
---

Run `git status` and `git diff --stat`.

Report:
- Current branch
- Ahead/behind remote
- Staged changes (files)
- Unstaged changes (files)
- Untracked files

Keep output concise.
```

## Integration with Existing Skills

| Skill | Change |
|-------|--------|
| `using-devpowers` | Add note about haiku-routed agents |
| `systematic-debugging` | Reference test agent and dora |
| `test-driven-development` | Reference test agent for iterations |
| `verification-before-completion` | Reference test, lint, typecheck agents |

## Out of Scope

- Auto-installing tools (just advise)
- Changing the Explore agent
- LSP MCP integration (separate plugin)
- Forcing haiku for exploration

## Risks

| Risk | Mitigation |
|------|------------|
| `model: haiku` frontmatter not respected | Test it; may need Task tool param |
| Project-setup becomes complex | Keep detection simple; fail gracefully |
| Dora not available | Graceful skip with advice |
