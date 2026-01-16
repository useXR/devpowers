#!/usr/bin/env bash
# SessionStart hook for devpowers plugin

set -euo pipefail

# Determine plugin root directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
PLUGIN_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Read input JSON from stdin
INPUT=$(cat)
CWD=$(echo "$INPUT" | grep -o '"cwd"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"\([^"]*\)"/\1/' || echo ".")

# Check if legacy skills directory exists and build warning
warning_message=""
legacy_skills_dir="${HOME}/.config/devpowers/skills"
if [ -d "$legacy_skills_dir" ]; then
    warning_message="\n\n<important-reminder>IN YOUR FIRST REPLY AFTER SEEING THIS MESSAGE YOU MUST TELL THE USER:\n\n**WARNING:** Devpowers now uses Claude Code's skills system. Custom skills in ~/.config/devpowers/skills will not be read. Move custom skills to ~/.claude/skills instead. To make this message go away, remove ~/.config/devpowers/skills</important-reminder>"
fi

# Detect workflow state
workflow_status=""

# Look for ACTIVE.md first
if [ -f "${CWD}/.claude/ACTIVE.md" ]; then
    active_feature=$(grep -m1 "^## Active:" "${CWD}/.claude/ACTIVE.md" 2>/dev/null | sed 's/^## Active: *//' || echo "")
    if [ -n "$active_feature" ]; then
        workflow_status="Active feature: ${active_feature}"
    fi
fi

# Look for STATUS.md files in docs/plans/
if [ -d "${CWD}/docs/plans" ]; then
    for status_file in "${CWD}"/docs/plans/*/STATUS.md; do
        if [ -f "$status_file" ]; then
            feature_name=$(basename "$(dirname "$status_file")")
            stage=$(grep -m1 "^\*\*Stage:\*\*" "$status_file" 2>/dev/null | sed 's/.*\*\*Stage:\*\* *//' || echo "unknown")
            scope=$(grep -m1 "^\*\*Scope:\*\*" "$status_file" 2>/dev/null | sed 's/.*\*\*Scope:\*\* *//' || echo "unknown")
            last_action=$(grep -m1 "^\*\*Last Action:\*\*" "$status_file" 2>/dev/null | sed 's/.*\*\*Last Action:\*\* *//' || echo "")

            if [ -n "$workflow_status" ]; then
                workflow_status="${workflow_status}\n"
            fi
            workflow_status="${workflow_status}Feature: ${feature_name} | Stage: ${stage} | Scope: ${scope}"
            if [ -n "$last_action" ]; then
                workflow_status="${workflow_status} | Last: ${last_action}"
            fi
        fi
    done
fi

# Build workflow context if we found any state
workflow_context=""
if [ -n "$workflow_status" ]; then
    workflow_context="\n\n---\nWorkflow State:\n${workflow_status}\n---"
fi

# Read using-devpowers content
using_devpowers_content=$(cat "${PLUGIN_ROOT}/skills/using-devpowers/SKILL.md" 2>&1 || echo "Error reading using-devpowers skill")

# Escape outputs for JSON using pure bash
escape_for_json() {
    local input="$1"
    local output=""
    local i char
    for (( i=0; i<${#input}; i++ )); do
        char="${input:$i:1}"
        case "$char" in
            $'\\') output+='\\' ;;
            '"') output+='\"' ;;
            $'\n') output+='\n' ;;
            $'\r') output+='\r' ;;
            $'\t') output+='\t' ;;
            *) output+="$char" ;;
        esac
    done
    printf '%s' "$output"
}

using_devpowers_escaped=$(escape_for_json "$using_devpowers_content")
warning_escaped=$(escape_for_json "$warning_message")
workflow_escaped=$(escape_for_json "$workflow_context")

# Output context injection as JSON
cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "<EXTREMELY_IMPORTANT>\nYou have devpowers.\n\n**Below is the full content of your 'devpowers:using-devpowers' skill - your introduction to using skills. For all other skills, use the 'Skill' tool:**\n\n${using_devpowers_escaped}${workflow_escaped}${warning_escaped}\n\n</EXTREMELY_IMPORTANT>"
  }
}
EOF

exit 0
