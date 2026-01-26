# Task 3: Dora Assets

> **Feature:** tool-efficiency | [Previous](./02-agent-templates.md) | [Next](./04-detect-stack.md)

## Goal

Create dora skill template and hooks configuration that project-setup will copy to target projects.

## Context

The dora skill template is based on the existing `.dora/docs/SKILL.md` in this repo. The hooks enable auto-indexing on session start/stop.

## Files

**Create:**
- `skills/project-setup/assets/dora/SKILL.md`
- `skills/project-setup/assets/hooks/dora-hooks.json`

**Reference:**
- `/home/arobb/PersonalDev/devpowers/.dora/docs/SKILL.md` (existing dora skill)

**Test:**
- Validate JSON syntax for hooks file

## Implementation Steps

1. Create `assets/dora/` directory in project-setup skill

2. Copy the existing dora skill from `.dora/docs/SKILL.md` to template location:
   - This skill already has comprehensive dora command documentation
   - Verify it works as a standalone template

3. Create `assets/hooks/dora-hooks.json`:
   ```json
   {
     "SessionStart": [
       {
         "hooks": [
           {
             "type": "command",
             "command": "dora status 2>/dev/null && (dora index > \"${HOME}/.claude/logs/dora-index.log\" 2>&1 &) || echo 'dora not initialized. Run: dora init && dora index'"
           }
         ]
       }
     ],
     "Stop": [
       {
         "hooks": [
           {
             "type": "command",
             "command": "(dora index > \"${HOME}/.claude/logs/dora-index.log\" 2>&1 &) || true"
           }
         ]
       }
     ]
   }
   ```

   **Note:** Uses `${HOME}/.claude/logs/` for cross-platform compatibility (not `/tmp`).

4. Validate hooks JSON is valid

## Acceptance Criteria

- [ ] Dora skill template created at `assets/dora/SKILL.md`
- [ ] Hooks template created at `assets/hooks/dora-hooks.json`
- [ ] Hooks JSON is valid (`jq . dora-hooks.json` exits 0)
- [ ] Hooks use nested `hooks` array format (matches Claude Code schema)
- [ ] Hooks use `${HOME}/.claude/logs/` for cross-platform log path
- [ ] SessionStart hook runs dora index in background
- [ ] Stop hook runs dora index in background

## Dependencies

- Depends on: None
- Blocks: Task 5 (project-setup)

---

## Domain Checklists

### Security Checklist

**Security Checklist Status:** COMPLETED

- [x] **Input boundaries validated**: Hooks use fixed commands, no user input
- [x] **Output safely encoded**: Hook output goes to /tmp log file
- [x] **Access control verified**: Hooks run in user context
- [x] **Sensitive data protected**: No credentials involved
- [x] **Injection prevented**: Commands are static strings

### Interface Checklist

**Interface N/A reason:** Templates are passive definitions, not direct interface.

### Data/State Checklist

- [x] **Failure handling defined**: Hooks use `|| true` to prevent failures from blocking
- [x] **Concurrency addressed**: Index runs in background, doesn't block session
- [x] **Rollback possible**: N/A - index can be regenerated anytime
- [x] **Migration planned**: N/A - no schema changes

### Integration Checklist

- [x] **Existing features tested**: Hooks format matches Claude Code settings.local.json
- [x] **New dependencies assessed**: Requires dora CLI (checked by project-setup)
- [x] **Contracts aligned**: Hook format per Claude Code docs
- [x] **Degradation handled**: If dora missing, hook prints warning, doesn't fail

---

## Unit Test Plan

**Required Coverage Categories:**

- [x] **Happy Path**: Run `jq . assets/hooks/dora-hooks.json` - verify exit code 0 (valid JSON)
- [x] **Error/Exception Path**: Execute SessionStart hook with dora not in PATH - verify outputs "dora not initialized" and exits 0
- [x] **Edge/Boundary Case**: Execute Stop hook without prior SessionStart - verify runs independently (exit 0)
- [x] **Validation**: Verify `assets/dora/SKILL.md` exists and contains valid markdown with at least one `#` heading (|| true)

## E2E/Integration Test Plan

Integration tested in Task 6 when hooks are triggered by session lifecycle.

---

## Behavior Definitions

| Scenario | Expected Behavior |
|----------|-------------------|
| dora not installed | SessionStart prints "dora not initialized. Run: dora init && dora index", continues |
| dora index fails | Failure goes to `~/.claude/logs/dora-index.log`, doesn't block |
| Very large codebase | Index runs in background (&), session starts immediately |
| Log directory missing | Hook creates `~/.claude/logs/` if needed (mkdir -p in wrapper) |

---

## Spike Verification

**Spike N/A reason:** Hook format matches existing devpowers settings.local.json pattern.
