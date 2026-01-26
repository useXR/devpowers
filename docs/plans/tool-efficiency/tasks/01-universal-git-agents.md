# Task 1: Universal Git Agents

> **Feature:** tool-efficiency | [Next](./02-agent-templates.md)

## Goal

Create three universal git agents (git-status, git-sync, git-push) that route to Haiku for mechanical git operations.

## Context

These agents will be available to all projects using devpowers. They handle common git operations with minimal token usage by routing to Haiku instead of Opus.

## Files

**Create:**
- `agents/git-status.md`
- `agents/git-sync.md`
- `agents/git-push.md`

**Modify:**
- None

**Test:**
- Manual invocation after creation

## Implementation Steps

1. Create `agents/git-status.md`:
   - `model: haiku`
   - Commands: `git status`, `git diff --stat`
   - Report: branch, ahead/behind, staged, unstaged, untracked

2. Create `agents/git-sync.md`:
   - `model: haiku`
   - Commands: `git fetch && git pull --rebase`
   - Report: success/failure, commits pulled

3. Create `agents/git-push.md`:
   - `model: haiku`
   - Commands: `git push` with branch safety check
   - Report: success/failure, commits pushed

## Acceptance Criteria

- [ ] All three agents created in `agents/` directory
- [ ] Each agent has `model: haiku` in frontmatter
- [ ] Each agent has specific description for discoverability
- [ ] Descriptions don't conflict with existing reviewer agents

## Dependencies

- Depends on: None
- Blocks: Task 5 (project-setup)

---

## Domain Checklists

### Security Checklist

**Security Checklist Status:** N/A

**If N/A, verify all conditions:**
- [x] Task touches no external data paths (git commands are local)
- [x] Task produces no user/system output (just reporting status)
- [x] Task modifies no persistent state (agents are read-only definitions)
- [x] Task adds no new dependencies

**N/A Justification:** Creating agent definition files only. No code execution, no external data processing, no state modification.

### Interface Checklist

- [x] **Feedback provided**: Agent reports operation result
- [x] **Errors actionable**: Agent reports command errors with exit codes
- [x] **Edge inputs handled**: N/A - no user input, fixed commands
- [ ] **Accessibility considered**: N/A - CLI output only

**Interface N/A reason:** CLI agents - accessibility N/A for terminal output.

### Data/State Checklist

**Data/State N/A reason:** Agents don't modify persistent state. They execute git commands that may modify repo, but that's intentional user-requested behavior.

### Integration Checklist

- [x] **Existing features tested**: Won't conflict with existing reviewer agents (different descriptions)
- [x] **New dependencies assessed**: No new dependencies
- [x] **Contracts aligned**: Standard agent frontmatter format
- [x] **Degradation handled**: If git command fails, agent reports error

---

## Unit Test Plan

**Required Coverage Categories:**

- [x] **Happy Path**: Manually invoke git-status agent in a clean repo - verify output shows branch info
- [x] **Error/Exception Path**: Invoke git-push on a repo with no remote - verify error reported
- [x] **Edge/Boundary Case**: Invoke git-status in repo with uncommitted changes - verify shows staged/unstaged

## E2E/Integration Test Plan

N/A - Manual verification during Task 6.

---

## Behavior Definitions

| Scenario | Expected Behavior |
|----------|-------------------|
| No git repo | Agent reports "not a git repository" error |
| No remote configured | git-push reports error, doesn't crash |
| Merge conflicts during sync | git-sync reports conflict, doesn't auto-resolve |
| Detached HEAD | git-status reports detached HEAD state |

---

## Spike Verification

**Spike N/A reason:** Agent frontmatter format already used by existing agents (code-reviewer.md, etc.)
