# Task 5: Update project-setup

> **Feature:** tool-efficiency | [Previous](./04-detect-stack.md) | [Next](./06-testing.md)

## Goal

Update project-setup SKILL.md to integrate dora initialization, hook merging, and agent template substitution into the setup workflow.

## Context

This is the integration task that brings together all previous work. Project-setup will now configure dora, LSP advisories, and stack-specific agents automatically.

## Files

**Modify:**
- `skills/project-setup/SKILL.md`

**Reference:**
- Assets created in Tasks 2, 3
- detect-stack.sh updated in Task 4

## Implementation Steps

1. Read current project-setup SKILL.md to understand structure

2. Add new sections to the workflow (after "Create master docs"):

   **Step 3: Dora Integration**
   - Check `which dora` - if missing, advise: "Install dora with: npm i -g @getdora/cli"
   - Check language-specific indexer (scip-typescript, etc.)
   - If both present:
     - Check if already initialized: `[ -f .dora/config.json ]` - if yes, skip init
     - Run `dora init` (if not already initialized)
     - Copy `assets/dora/SKILL.md` to `.dora/docs/SKILL.md`
     - Create `.claude/skills/dora/` directory
     - **OS Detection for symlink/copy:**
       ```bash
       if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
         cp .dora/docs/SKILL.md .claude/skills/dora/SKILL.md
       else
         ln -sf ../../../.dora/docs/SKILL.md .claude/skills/dora/SKILL.md
       fi
       ```
     - Merge hooks from `assets/hooks/dora-hooks.json` into `settings.local.json`

   **Step 4: LSP Advisory**
   - Check for typescript-language-server, pyright, etc.
   - Output advisory message if missing (no action needed)

   **Step 5: Generate Stack-Specific Agents**

   **5a. Parse detect-stack.sh output safely (NO eval):**
   ```bash
   # Run detect-stack.sh and capture TOOL_COMMANDS section
   OUTPUT=$(./scripts/detect-stack.sh)
   TOOL_SECTION=$(echo "$OUTPUT" | sed -n '/---TOOL_COMMANDS---/,$p')

   # Extract each command value using grep + cut (safe parsing)
   TEST_CMD=$(echo "$TOOL_SECTION" | grep '^TEST_COMMAND=' | cut -d'=' -f2-)
   LINT_CMD=$(echo "$TOOL_SECTION" | grep '^LINT_COMMAND=' | cut -d'=' -f2-)
   # ... repeat for TYPECHECK_COMMAND, BUILD_COMMAND
   ```

   **5b. For each placeholder (TEST_COMMAND, LINT_COMMAND, etc.):**
   - If value is empty, skip that agent template
   - **Validate value**: reject if contains shell metacharacters: `; | & $ \` ' " ( ) < > { }`
     - If invalid: `echo "Warning: Skipping test agent - unsafe characters in command: $TEST_CMD"`
   - Substitute placeholder `{{COMMAND}}` with validated value using `sed`
   - Check if agent already exists: `[ -f .claude/agents/test.md ]` - if yes, skip (don't overwrite)
   - Write result to `.claude/agents/`
   - Example: `TEST_COMMAND=npm test` → `agents/test.md` with `npm test` substituted

3. Add hook merging implementation detail:
   ```
   Hook Merge Algorithm:
   1. Read existing .claude/settings.local.json (or create {})
   2. Ensure "hooks" key exists (or create empty {})
   3. For each event in dora-hooks.json (SessionStart, Stop):
      a. Get existing hooks array for that event (or create [])
      b. Check for duplicates: if existing hook command contains "dora index", skip (already present)
      c. Append new hook entry to array
   4. Ensure ~/.claude/logs/ directory exists (mkdir -p)
   5. Write merged result back to settings.local.json
   ```
   - Idempotency: Running twice doesn't duplicate hooks (duplicate check in step 3b)
   - Preserves existing hooks (other than dora-related ones)

4. Update handoff message to list what was created

## Acceptance Criteria

- [ ] SKILL.md includes dora initialization steps
- [ ] SKILL.md includes hook merging algorithm
- [ ] SKILL.md includes agent template substitution
- [ ] SKILL.md includes LSP advisory
- [ ] Handoff message lists created agents
- [ ] Windows compatibility noted (copy instead of symlink)

## Dependencies

- Depends on: Tasks 1, 2, 3, 4
- Blocks: Task 6 (testing)

---

## Domain Checklists

### Security Checklist

**Security Checklist Status:** COMPLETED

- [x] **Input boundaries validated**: detect-stack.sh output parsed with known format
- [x] **Output safely encoded**: Agents/skills are static content, no injection risk
- [x] **Access control verified**: Writing to project's .claude/ directory (expected)
- [x] **Sensitive data protected**: No credentials involved
- [x] **Injection prevented**: Template substitution uses known placeholders only

### Interface Checklist

- [x] **Feedback provided**: Skill outputs what was created/skipped
- [x] **Errors actionable**: Missing dora/indexer gets specific install advice
- [x] **Edge inputs handled**: Missing tools result in skipped features with advice
- [ ] **Accessibility considered**: N/A - CLI output

### Data/State Checklist

- [x] **Failure handling defined**: If hook merge fails, warn and continue
- [x] **Concurrency addressed**: N/A - single setup process
- [x] **Rollback possible**: Files created can be deleted manually
- [x] **Migration planned**: N/A - creates new files

### Integration Checklist

- [x] **Existing features tested**: Preserve existing project-setup behavior
- [x] **New dependencies assessed**: Requires dora CLI (optional, advise if missing)
- [x] **Contracts aligned**: Hook format, agent format per Claude Code docs
- [x] **Degradation handled**: Missing tools = advisory, not failure

---

## Unit Test Plan

**Required Coverage Categories:**

- [x] **Happy Path**: Run on TS project with `npm test` and `npm run lint` in package.json, dora installed → verify `.claude/agents/test.md` and `.claude/agents/lint.md` exist with substituted commands (not `{{PLACEHOLDER}}`)
- [x] **Error/Exception Path**: Run on project without dora → verify advisory "Install dora with: npm i -g @getdora/cli" shown, setup continues
- [x] **Edge/Boundary Case**: Run on project with existing settings.local.json containing `PostToolUse` hook → verify result contains BOTH original `PostToolUse` AND new dora `SessionStart` hooks
- [x] **Idempotency**: Run project-setup twice on same project → verify second run doesn't duplicate hooks or agents
- [x] **Validation**: Run with malicious package.json containing `test: "npm test; rm -rf /"` → verify command rejected with warning, agent not created

## E2E/Integration Test Plan

Full integration tested in Task 6.

---

## Behavior Definitions

| Scenario | Expected Behavior |
|----------|-------------------|
| dora installed, indexer missing | Skip dora, advise "Install scip-typescript" |
| settings.local.json exists with hooks | Merge dora hooks, preserve existing |
| settings.local.json doesn't exist | Create new with dora hooks |
| package.json has no test script | Skip test.md agent, create others |
| Windows OS detected | Copy files instead of symlink |
| Run twice (idempotency) | Second run: no duplicates, no errors |
| Command contains shell metacharacters | Reject with warning, skip that agent |
| dora init already done | Skip init (check for .dora/config.json) |

---

## Spike Verification

**Spike N/A reason:** All patterns (file reading, JSON merging, template substitution) are standard bash/text operations used elsewhere.
