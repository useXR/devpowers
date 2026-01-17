#!/usr/bin/env bash
# Notification hook - sends desktop toast when Claude needs input

set -euo pipefail

# Read input JSON from stdin
INPUT=$(cat)

# Extract message from input
MESSAGE=$(echo "$INPUT" | grep -o '"message"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"\([^"]*\)"/\1/' || echo "Awaiting input")

# Send desktop notification
if command -v notify-send &> /dev/null; then
    notify-send -u normal "Claude Code" "$MESSAGE"
elif command -v osascript &> /dev/null; then
    # macOS fallback
    osascript -e "display notification \"$MESSAGE\" with title \"Claude Code\" sound name \"Glass\""
fi

exit 0
