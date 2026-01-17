#!/usr/bin/env bash
# PreToolUse hook for Bash - prevents heredoc file creation

set -euo pipefail

# Read input JSON from stdin
INPUT=$(cat)

# Extract command from tool_input
COMMAND=$(echo "$INPUT" | grep -o '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"\([^"]*\)"/\1/' || echo "")

# Check for heredoc patterns that should use Write tool instead
# Patterns: cat > file << EOF, cat >> file << EOF, cat > file <<EOF, etc.
if echo "$COMMAND" | grep -qE 'cat[[:space:]]*>.*<<'; then
    echo '{"hookSpecificOutput": {"hookEventName": "PreToolUse", "permissionDecision": "deny", "permissionDecisionReason": "Use Write tool instead of cat heredoc for file creation"}}' >&2
    exit 2
fi

# Also check for echo with redirects for multi-line content
if echo "$COMMAND" | grep -qE 'echo[[:space:]]+-e.*\\n.*>'; then
    echo '{"hookSpecificOutput": {"hookEventName": "PreToolUse", "permissionDecision": "deny", "permissionDecisionReason": "Use Write tool instead of echo with newlines for file creation"}}' >&2
    exit 2
fi

# Allow the command
echo "{}"
exit 0
