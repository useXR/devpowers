---
name: project-setup
description: >
  This skill should be used when the user asks to "set up a new project",
  "initialize master documents", "create project structure", "bootstrap devpowers",
  or when starting development in a repo without `/docs/master/` directory.
  Sets up master documents tailored to the detected technology stack.
---

# Project Setup

## Overview

Initialize a project with tailored master documents for institutional knowledge accumulation.

## Workflow

### Step 1: Detect Stack
Run `scripts/detect-stack.sh` — outputs detected frameworks and tool commands.

### Step 2: Create Master Docs
1. Interpret results using `references/stack-detection-guide.md`
2. Read template master docs from `assets/master-doc-templates/`
3. Tailor templates based on detected stack (apply judgment)
4. Write tailored docs to `/docs/master/`
5. Commit initial master docs

### Step 3: Dora Integration (Optional)

**Check prerequisites:**
```bash
which dora        # If missing: "Install dora with: npm i -g @getdora/cli"
which scip-typescript  # Or scip-python, etc. based on stack
```

**If both present:**
1. Check if already initialized: `[ -f .dora/config.json ]` → skip init if exists
2. Run `dora init` (if not already initialized)
3. Copy `assets/dora/SKILL.md` to `.dora/docs/SKILL.md`
4. Create `.claude/skills/dora/` directory
5. Create skill link (OS-dependent):
   ```bash
   if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
     cp .dora/docs/SKILL.md .claude/skills/dora/SKILL.md
   else
     ln -sf ../../../.dora/docs/SKILL.md .claude/skills/dora/SKILL.md
   fi
   ```
6. Merge hooks from `assets/hooks/dora-hooks.json` into `.claude/settings.local.json`

**Hook Merge Algorithm:**
1. Read existing `.claude/settings.local.json` (or create `{}`)
2. Ensure `"hooks"` key exists (or create empty `{}`)
3. For each event in dora-hooks.json (SessionStart, Stop):
   a. Get existing hooks array for that event (or create `[]`)
   b. Check for duplicates: if existing hook command contains "dora index", skip
   c. Append new hook entry to array
4. Ensure `~/.claude/logs/` directory exists (`mkdir -p`)
5. Write merged result back to settings.local.json

### Step 4: LSP Advisory

Check for language server availability and advise if missing:
- TypeScript: `which typescript-language-server` → "Install with: npm i -g typescript-language-server"
- Python: `which pyright` → "Install with: npm i -g pyright"

No action required — advisory only.

### Step 5: Generate Stack-Specific Agents

**5a. Parse detect-stack.sh output safely (NO eval):**
```bash
OUTPUT=$(./scripts/detect-stack.sh)
TOOL_SECTION=$(echo "$OUTPUT" | sed -n '/---TOOL_COMMANDS---/,$p')

# Extract each command value using grep + cut (safe parsing)
TEST_CMD=$(echo "$TOOL_SECTION" | grep '^TEST_COMMAND=' | cut -d'=' -f2-)
LINT_CMD=$(echo "$TOOL_SECTION" | grep '^LINT_COMMAND=' | cut -d'=' -f2-)
TYPECHECK_CMD=$(echo "$TOOL_SECTION" | grep '^TYPECHECK_COMMAND=' | cut -d'=' -f2-)
BUILD_CMD=$(echo "$TOOL_SECTION" | grep '^BUILD_COMMAND=' | cut -d'=' -f2-)
```

**5b. For each command (TEST, LINT, TYPECHECK, BUILD):**
1. If value is empty → skip that agent template
2. **Validate value**: reject if contains shell metacharacters: `; | & $ \` ' " ( ) < > { }`
   - If invalid: `echo "Warning: Skipping [type] agent - unsafe characters in command"`
3. Check if agent already exists: `[ -f .claude/agents/[type].md ]` → skip if yes
4. Read template from `assets/agent-templates/[type].md`
5. Substitute `{{COMMAND}}` placeholder with validated value
6. Write result to `.claude/agents/[type].md`

### Step 6: Commit and Handoff

Commit all setup changes and report what was created.

## Directory Conventions

- `assets/`: Templates and static resources copied to project (not loaded into context)
- `references/`: Documentation loaded on-demand when Claude needs guidance
- `scripts/`: Executable tools that output data for Claude to interpret

## Output Structure

Creates:
```
/docs/master/
  design-system.md           # UI patterns, component conventions
  lessons-learned/
    frontend.md
    backend.md
    testing.md
    infrastructure.md
  patterns/
    [stack-specific patterns discovered over time]

.claude/
  agents/
    test.md                  # Stack-specific test agent (routes to Haiku)
    lint.md                  # Stack-specific lint agent (routes to Haiku)
    typecheck.md             # Stack-specific typecheck agent (routes to Haiku)
    build.md                 # Stack-specific build agent (routes to Haiku)
  skills/
    dora/SKILL.md            # Dora skill (symlink or copy)
  settings.local.json        # Hooks for dora auto-indexing

.dora/
  config.json                # Dora configuration (if dora installed)
  docs/SKILL.md              # Dora skill source
```

## Handoff

Report what was created:

```
Project setup complete.

Created:
- /docs/master/ (design system, lessons-learned, patterns)
- .claude/agents/test.md (npm test → Haiku)
- .claude/agents/lint.md (npm run lint → Haiku)
- .claude/skills/dora/SKILL.md (linked)
- .claude/settings.local.json (dora hooks merged)

Skipped:
- typecheck agent (no typecheck script found)
- build agent (already exists)

Advisories:
- Install pyright for better type checking: npm i -g pyright

Ready to start brainstorming a feature?
```

-> Invokes `brainstorming`
