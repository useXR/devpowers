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

**Security Checklist Status:** COMPLETED

- [x] **Input boundaries validated**: Git commands use fixed syntax, no user input interpolation in agent definitions
- [x] **Output safely encoded**: Agent output is git command stdout/stderr (no code execution from output)
- [x] **Access control verified**: Agent runs in user's git repo context (by design, expected behavior)
- [x] **Sensitive data protected**: No credentials stored in agent definitions; git uses system credential store
- [x] **Injection prevented**: Commands are static bash/git with no eval or variable interpolation

**Note:** Agents execute code at invocation time, not creation time. The commands are static strings that run git directly.

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

- [x] **Happy Path (git-status)**: Invoke git-status agent in clean repo → verify output shows branch name and "nothing to commit"
- [x] **Happy Path (git-sync)**: Invoke git-sync agent on branch behind remote → verify fetches and rebases, reports commits pulled
- [x] **Happy Path (git-push)**: Invoke git-push agent on branch with unpushed commits → verify reports success and commit count
- [x] **Error/Exception Path**: Invoke git-push on repo with no remote → verify error message includes "no remote"
- [x] **Edge/Boundary Case**: Invoke git-status with uncommitted changes → verify shows staged/unstaged/untracked counts

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
