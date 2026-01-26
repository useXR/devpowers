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

### Skill Structure

```
devpowers/skills/
├── git-status/
│   └── SKILL.md          # Universal, model: haiku
├── git-sync/
│   └── SKILL.md          # Universal, model: haiku
├── git-push/
│   └── SKILL.md          # Universal, model: haiku
└── project-setup/
    ├── SKILL.md          # Updated workflow
    ├── scripts/
    │   └── detect-stack.sh
    └── assets/
        ├── skill-templates/
        │   ├── test/SKILL.md
        │   ├── lint/SKILL.md
        │   ├── typecheck/SKILL.md
        │   └── build/SKILL.md
        ├── dora/
        │   └── SKILL.md
        └── hooks/
            └── dora-hooks.json
```

### Project Output (TypeScript example)

```
.claude/
├── settings.local.json     # Includes dora hooks
└── skills/
    ├── dora/
    │   └── SKILL.md → ../../../.dora/docs/SKILL.md
    ├── test/
    │   └── SKILL.md        # Customized: "npm test"
    ├── lint/
    │   └── SKILL.md        # Customized: "npm run lint"
    ├── typecheck/
    │   └── SKILL.md        # Customized: "npx tsc --noEmit"
    └── build/
        └── SKILL.md        # Customized: "npm run build"

.dora/
├── config.json
├── index.scip
└── docs/
    └── SKILL.md
```

### Model Routing

Via skill frontmatter:

```markdown
---
name: test
model: haiku
description: Run project tests and report results
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

## Haiku Skill Design

**Principles:**
- Minimal instructions (~50-100 words)
- Execute and report - no reasoning
- Facts only: pass/fail, errors with locations
- Fail fast - report problems, don't fix

**Example (`/test`):**

```markdown
---
name: test
model: haiku
description: Run project tests and report results
---

# Test

Execute the test command and report results.

## Command
`npm test`

## Output Format
- Total tests, passed, failed, skipped
- For failures: test name, file:line, error message
- Exit code

Do not analyze or suggest fixes. Just report results.
```

**Example (`/git-status`):**

```markdown
---
name: git-status
model: haiku
description: Show git repository status
---

# Git Status

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
| `using-devpowers` | Add note about haiku-routed skills |
| `systematic-debugging` | Reference `/test` and dora |
| `test-driven-development` | Reference `/test` for iterations |
| `verification-before-completion` | Reference `/test`, `/lint`, `/typecheck` |

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
