#!/usr/bin/env bash
# Stop hook for devpowers workflow - ensures learnings captured

set -euo pipefail

# Read input JSON from stdin
INPUT=$(cat)

# Extract cwd from input
CWD=$(echo "$INPUT" | grep -o '"cwd"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"\([^"]*\)"/\1/' || echo ".")

# Check if we're in a feature workflow by looking for STATUS.md files
PLANS_DIR="${CWD}/docs/plans"

if [ ! -d "$PLANS_DIR" ]; then
    # No plans directory, not in devpowers workflow
    echo "{}"
    exit 0
fi

# Find any STATUS.md file that indicates implementing or later stage
for STATUS_FILE in "${PLANS_DIR}"/*/STATUS.md; do
    if [ ! -f "$STATUS_FILE" ]; then
        continue
    fi

    # Extract stage
    STAGE=$(grep -m1 '\*\*Stage:\*\*' "$STATUS_FILE" 2>/dev/null | sed 's/.*\*\*Stage:\*\* *//' || echo "")

    # Check if stage indicates implementation done
    case "$STAGE" in
        implementing|lessons-learned|finishing)
            # Check if learnings.md exists and has content
            FEATURE_DIR=$(dirname "$STATUS_FILE")
            LEARNINGS_FILE="${FEATURE_DIR}/learnings.md"

            if [ ! -f "$LEARNINGS_FILE" ]; then
                # Learnings file doesn't exist
                echo "{\"decision\": \"block\", \"reason\": \"Implementation in progress but no learnings.md file found. Consider capturing learnings before ending session.\"}"
                exit 0
            fi

            # Check if learnings file has content beyond template
            CONTENT_LINES=$(grep -c '^\s*[^#\s]' "$LEARNINGS_FILE" 2>/dev/null || echo "0")

            if [ "$CONTENT_LINES" -lt 3 ]; then
                # Learnings file appears empty or just has headers
                FEATURE_NAME=$(basename "$FEATURE_DIR")
                echo "{\"decision\": \"block\", \"reason\": \"Feature '${FEATURE_NAME}' has implementation work but learnings.md appears empty. Capture any insights before ending session?\"}"
                exit 0
            fi
            ;;
    esac
done

# All checks passed
echo "{}"
exit 0
