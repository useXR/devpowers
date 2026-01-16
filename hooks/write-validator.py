#!/usr/bin/env python3
"""
PreToolUse hook for Write tool validation.
Warns when writing to implementation files before the implementing stage.
"""

import json
import sys
import os
import re
from pathlib import Path

# Directories considered implementation code
IMPL_DIRS = ['src', 'lib', 'app', 'components', 'pages', 'api', 'services']

# Directories that are always OK to write to
SAFE_DIRS = ['docs', 'tests', '.claude', 'scripts']

def get_current_stage(cwd: str) -> tuple[str, str]:
    """Find the current workflow stage from STATUS.md files."""
    plans_dir = Path(cwd) / "docs" / "plans"

    if not plans_dir.exists():
        return None, None

    # Look for STATUS.md files
    for feature_dir in plans_dir.iterdir():
        if feature_dir.is_dir():
            status_file = feature_dir / "STATUS.md"
            if status_file.exists():
                content = status_file.read_text()
                # Extract stage
                stage_match = re.search(r'\*\*Stage:\*\*\s*(\S+)', content)
                if stage_match:
                    return feature_dir.name, stage_match.group(1)

    return None, None

def is_impl_file(file_path: str, cwd: str) -> bool:
    """Check if file is in an implementation directory."""
    try:
        rel_path = Path(file_path).relative_to(cwd)
    except ValueError:
        # File not under cwd, assume it's safe
        return False

    parts = rel_path.parts
    if not parts:
        return False

    first_dir = parts[0]

    # Check if in safe directories
    for safe in SAFE_DIRS:
        if first_dir == safe or first_dir.startswith('.'):
            return False

    # Check if in implementation directories
    for impl in IMPL_DIRS:
        if first_dir == impl:
            return True

    # Also check for common source patterns
    if any(part in ['src', 'lib', 'app'] for part in parts):
        return True

    return False

def main():
    # Read input from stdin
    try:
        input_data = json.load(sys.stdin)
    except json.JSONDecodeError:
        # No valid JSON, allow the write
        print(json.dumps({}))
        return

    tool_input = input_data.get('tool_input', {})
    file_path = tool_input.get('file_path', '')
    cwd = input_data.get('cwd', os.getcwd())

    if not file_path:
        print(json.dumps({}))
        return

    # Check if this is an implementation file
    if not is_impl_file(file_path, cwd):
        # Not an impl file, allow write
        print(json.dumps({}))
        return

    # Get current stage
    feature, stage = get_current_stage(cwd)
    if not stage:
        # No workflow state, allow write
        print(json.dumps({}))
        return

    # Pre-implementation stages
    pre_impl_stages = [
        'brainstorming', 'high-level-plan', 'reviewing-plans',
        'task-breakdown', 'domain-review', 'cross-domain-review',
        'user-journey-mapping', 'worktree'
    ]

    if stage in pre_impl_stages:
        # Ask user before writing to impl files during pre-impl stages
        print(json.dumps({
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "ask",
                "permissionDecisionReason": f"Writing to implementation file but workflow stage is '{stage}'. This may be premature. Proceed anyway?"
            }
        }))
    else:
        # In implementing or later stage, allow
        print(json.dumps({}))

if __name__ == "__main__":
    main()
