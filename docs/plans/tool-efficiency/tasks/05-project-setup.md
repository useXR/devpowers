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
   - Check `which dora` - if missing, advise installation
   - Check language-specific indexer (scip-typescript, etc.)
   - If both present:
     - Run `dora init`
     - Copy `assets/dora/SKILL.md` to `.dora/docs/SKILL.md`
     - Create `.claude/skills/dora/` directory
     - Create symlink (or copy on Windows): `.claude/skills/dora/SKILL.md`
     - Merge hooks from `assets/hooks/dora-hooks.json` into `settings.local.json`

   **Step 4: LSP Advisory**
   - Check for typescript-language-server, pyright, etc.
   - Output advisory message if missing (no action needed)

   **Step 5: Generate Stack-Specific Agents**
   - Parse detect-stack.sh output for TOOL_COMMANDS
   - For each placeholder (TEST_COMMAND, etc.):
     - If value exists, substitute into template
     - Write result to `.claude/agents/`
   - Skip agents for empty commands

3. Add hook merging implementation detail:
   - Read existing settings.local.json
   - Deep merge hooks object
   - Write back

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

- [x] **Happy Path**: Run project-setup on TS project with dora installed - verify agents created
- [x] **Error/Exception Path**: Run on project without dora - verify advisory shown, no crash
- [x] **Edge/Boundary Case**: Run on project with existing settings.local.json - verify hooks merged not replaced

## E2E/Integration Test Plan

Full integration tested in Task 6.

---

## Behavior Definitions

| Scenario | Expected Behavior |
|----------|-------------------|
| dora installed, indexer missing | Skip dora, advise on indexer |
| settings.local.json exists with hooks | Merge dora hooks, preserve existing |
| settings.local.json doesn't exist | Create new with dora hooks |
| package.json has no test script | Skip test.md agent, create others |
| Windows OS detected | Copy files instead of symlink |

---

## Spike Verification

**Spike N/A reason:** All patterns (file reading, JSON merging, template substitution) are standard bash/text operations used elsewhere.
