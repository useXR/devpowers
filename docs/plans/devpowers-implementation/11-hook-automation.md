# Task 11: Hook-Based Automation

> **Devpowers Implementation** | [← Implementation Skills](./10-implementation-skills.md) | [Next: Fork Skills →](./12-fork-skills.md)

---

## Context

**This task creates all 6 workflow automation hooks.** Hooks provide deterministic automation at key workflow points without consuming context window.

### Prerequisites
- **Tasks 2-9** completed (all workflow stages exist)

### What This Task Creates
- `hooks/hooks.json` (update)
- `hooks/session-start-workflow.sh`
- `hooks/workflow-advisor.py`
- `hooks/write-validator.py`
- `hooks/task-created.sh`
- `hooks/subagent-review.py`
- `hooks/learnings-check.sh`

### Tasks That Depend on This
- None (final automation layer)

---

## Hook Capabilities Reference

| Hook Event | Can Block? | Primary Use |
|------------|------------|-------------|
| `SessionStart` | No | Inject context at session start |
| `UserPromptSubmit` | Yes | Add context; block if needed |
| `PreToolUse` | Yes (allow/deny/ask) | Validate before tool execution |
| `PostToolUse` | No | React to tool results |
| `SubagentStop` | Yes (block/omit) | Validate subagent completion |
| `Stop` | Yes (block/omit) | Validate session end |

---

## Sub-Tasks

1. Update hooks.json configuration
2. Create SessionStart hook
3. Create UserPromptSubmit hook
4. Create PreToolUse hook (Write)
5. Create PostToolUse hook (Write)
6. Create SubagentStop hook
7. Create Stop hook

---

## Sub-Task 11.1: Update hooks.json

**File:** `hooks/hooks.json`

```json
{
  "description": "Devpowers workflow automation hooks",
  "hooks": {
    "SessionStart": [
      {
        "type": "command",
        "command": "${CLAUDE_PLUGIN_ROOT}/hooks/session-start-workflow.sh"
      }
    ],
    "UserPromptSubmit": [
      {
        "type": "command",
        "command": "${CLAUDE_PLUGIN_ROOT}/hooks/workflow-advisor.py"
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Write",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/write-validator.py"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/task-created.sh"
          }
        ]
      }
    ],
    "SubagentStop": [
      {
        "type": "command",
        "command": "${CLAUDE_PLUGIN_ROOT}/hooks/subagent-review.py"
      }
    ],
    "Stop": [
      {
        "type": "command",
        "command": "${CLAUDE_PLUGIN_ROOT}/hooks/learnings-check.sh"
      }
    ]
  }
}
```

---

## Sub-Task 11.2: Create SessionStart Hook

**File:** `hooks/session-start-workflow.sh`

**Purpose:** Detect workflow state and inject minimal context.

**Input (stdin JSON):**
```json
{
  "hook_event_name": "SessionStart",
  "session_id": "abc123",
  "cwd": "/path/to/project"
}
```

**Output:**
```json
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "📍 Active: auth-feature | Stage: domain-review | Next: Complete testing critic"
  }
}
```

**Implementation:** See complete plan for full bash script that:
1. Finds active feature from ACTIVE.md or STATUS.md files
2. Parses STATUS.md for current stage, scope, next action
3. Returns formatted context string

---

## Sub-Task 11.3: Create UserPromptSubmit Hook

**File:** `hooks/workflow-advisor.py`

**Purpose:** Provide workflow guidance for out-of-sequence actions.

**Input (stdin JSON):**
```json
{
  "hook_event_name": "UserPromptSubmit",
  "session_id": "abc123",
  "prompt": "let's start implementing the login component",
  "cwd": "/path/to/project"
}
```

**Output:**
```json
{
  "systemMessage": "⚠️ Want to implement but reviews not complete. Current stage: task-breakdown"
}
```

**Implementation:** See complete plan for full Python script that:
1. Detects intent from keywords (implement, review, PR)
2. Finds STATUS.md and reads current stage
3. Returns warning if intent doesn't match stage

---

## Sub-Task 11.4: Create PreToolUse Hook (Write)

**File:** `hooks/write-validator.py`

**Purpose:** Validate file writes against workflow state. CAN BLOCK.

**Input (stdin JSON):**
```json
{
  "hook_event_name": "PreToolUse",
  "tool_name": "Write",
  "tool_input": {
    "file_path": "/path/to/project/src/components/Login.tsx"
  },
  "cwd": "/path/to/project"
}
```

**Output (to ask user):**
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "ask",
    "permissionDecisionReason": "Writing to src/ but stage is 'task-breakdown'. Proceed anyway?"
  }
}
```

**Implementation:** See complete plan for full Python script that:
1. Checks if file path matches implementation directories
2. Reads STATUS.md for current stage
3. Returns "ask" if writing to impl files before implementing stage

---

## Sub-Task 11.5: Create PostToolUse Hook (Write)

**File:** `hooks/task-created.sh`

**Purpose:** Update state when task files created. CANNOT BLOCK.

**Input (stdin JSON):**
```json
{
  "hook_event_name": "PostToolUse",
  "tool_name": "Write",
  "tool_input": {
    "file_path": "/path/to/project/docs/plans/auth/tasks/01-login-form.md"
  }
}
```

**Output:**
```json
{
  "systemMessage": "✅ Task file created: 01-login-form.md. Domain review recommended."
}
```

**Implementation:** Simple bash script that checks if file matches task pattern.

---

## Sub-Task 11.6: Create SubagentStop Hook

**File:** `hooks/subagent-review.py`

**Purpose:** Remind about code review after implementation subagents.

**Input (stdin JSON):**
```json
{
  "hook_event_name": "SubagentStop",
  "transcript_path": "/path/to/.claude/projects/.../transcript.jsonl",
  "cwd": "/path/to/project"
}
```

**Output:**
```json
{
  "systemMessage": "Implementation complete. Invoke code-reviewer agent before proceeding."
}
```

**Implementation:** See complete plan for Python script that:
1. Reads transcript to find recent Task tool calls
2. Checks if implementation keywords present
3. Checks if code-reviewer was invoked
4. Returns reminder if implementation but no review

---

## Sub-Task 11.7: Create Stop Hook

**File:** `hooks/learnings-check.sh`

**Purpose:** Ensure learnings captured before session ends. CAN BLOCK.

**Input (stdin JSON):**
```json
{
  "hook_event_name": "Stop",
  "cwd": "/path/to/project"
}
```

**Output (to block):**
```json
{
  "decision": "block",
  "reason": "Ask user about learnings. Implementation done but learnings.md appears empty."
}
```

**Implementation:** See complete plan for bash script that:
1. Finds active feature
2. Checks if stage is implementing or later
3. Checks if learnings.md has content
4. Blocks if implementation done but no learnings

---

## Final Steps

### Make all hooks executable

```bash
chmod +x hooks/*.sh hooks/*.py
```

### Commit all hooks

```bash
git add hooks/
git commit -m "feat: add workflow automation hooks

- SessionStart: inject workflow state context
- UserPromptSubmit: warn about out-of-sequence actions
- PreToolUse (Write): validate writes against workflow stage
- PostToolUse (Write): confirm task file creation
- SubagentStop: remind about code review
- Stop: ensure learnings captured"
```

---

## Verification Checklist

- [ ] `hooks/hooks.json` has all 6 hook events configured
- [ ] `hooks/session-start-workflow.sh` exists and is executable
- [ ] `hooks/workflow-advisor.py` exists and is executable
- [ ] `hooks/write-validator.py` exists and is executable
- [ ] `hooks/task-created.sh` exists and is executable
- [ ] `hooks/subagent-review.py` exists and is executable
- [ ] `hooks/learnings-check.sh` exists and is executable
- [ ] All changes committed

---

## Next Steps

Proceed to **[Task 12: Fork Skills](./12-fork-skills.md)** (optional, can be deferred).
