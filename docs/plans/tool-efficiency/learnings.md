# Learnings Log: Tool Efficiency

## Plan Review Phase

### Round 1 (3 critics)
- **Critical finding:** Skills do NOT support `model` field - only agents do. This was caught by spike verification before writing the plan, but critics reinforced it.
- **Critical gap:** Specifications were undefined (hook merging, template substitution, dora dependencies). Added Section 2 with concrete algorithms.
- **Important clarity:** LSP scope was ambiguous - clarified as "advisory only" with no integration.

### Round 2 (1 verifier)
- All critical issues addressed. Plan converged.

### Skeptic Pass
- Raised valid concern about agent invocation mechanism, but this was already verified by Task tool's `model` parameter working during critic dispatch.
- Edge cases identified: hook JSON validation, dora indexing race condition, Windows symlink handling. These are implementation details.

## Domain Review Phase
<!-- Domain critics append here -->

## Implementation Phase

### Parallel Task Execution
- **Tasks 1-4 ran in parallel** successfully using subagent-driven-development
- **Task 4 subagent failed** due to bash permission denial in automated context - completed manually
- **Lesson:** Subagents running bash commands in background may hit permission issues; have fallback plan

### detect-stack.sh Enhancements
- **jq preferred** for JSON parsing - safer than grep for complex scripts
- **printf %q escaping** works well for safe output of potentially dangerous values
- **Package manager detection** (yarn.lock, pnpm-lock.yaml) should happen before command prefix

### Hook JSON Structure
- **Claude Code hooks** require nested `hooks` array: `{ "SessionStart": [{ "hooks": [...] }] }`
- **Cross-platform paths:** Use `${HOME}/.claude/logs/` not `/tmp` for Windows compatibility

### Agent Templates
- **Single placeholder per template** keeps substitution simple and safe
- **Validation important:** Reject commands with shell metacharacters before substitution

## Code Review Phase
<!-- Code reviewers append here -->
