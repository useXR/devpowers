#!/usr/bin/env bash
# PostToolUse hook for Write tool - detects task file creation

set -euo pipefail

# Read input JSON from stdin
INPUT=$(cat)

# Extract file_path from tool_input
FILE_PATH=$(echo "$INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"\([^"]*\)"/\1/' || echo "")

# Check if file matches task file pattern: docs/plans/*/tasks/*.md
if echo "$FILE_PATH" | grep -qE 'docs/plans/[^/]+/tasks/[^/]+\.md$'; then
    TASK_NAME=$(basename "$FILE_PATH")
    echo "{\"systemMessage\": \"Task file created: ${TASK_NAME}. Consider running domain review.\"}"
    exit 0
fi

# Check if file matches STATUS.md pattern
if echo "$FILE_PATH" | grep -qE 'docs/plans/[^/]+/STATUS\.md$'; then
    FEATURE_NAME=$(basename "$(dirname "$FILE_PATH")")
    echo "{\"systemMessage\": \"Workflow state updated for feature: ${FEATURE_NAME}\"}"
    exit 0
fi

# No special handling needed
echo "{}"
exit 0
