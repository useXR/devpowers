#!/usr/bin/env python3
"""
UserPromptSubmit hook for devpowers workflow guidance.
Detects user intent and warns if action doesn't match current workflow stage.
"""

import json
import sys
import os
import re
from pathlib import Path

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

def detect_intent(prompt: str) -> str:
    """Detect user intent from prompt keywords."""
    prompt_lower = prompt.lower()

    # Implementation intent
    impl_keywords = ['implement', 'build', 'create', 'add', 'write code', 'code', 'develop']
    for kw in impl_keywords:
        if kw in prompt_lower:
            return 'implement'

    # Review intent
    review_keywords = ['review', 'pr', 'pull request', 'merge']
    for kw in review_keywords:
        if kw in prompt_lower:
            return 'review'

    # Planning intent
    plan_keywords = ['plan', 'design', 'architect', 'brainstorm']
    for kw in plan_keywords:
        if kw in prompt_lower:
            return 'plan'

    return None

def check_sequence(intent: str, stage: str) -> str:
    """Check if intent matches expected workflow stage."""
    # Workflow stages in order
    pre_implement_stages = [
        'brainstorming', 'high-level-plan', 'reviewing-plans',
        'task-breakdown', 'domain-review', 'cross-domain-review',
        'user-journey-mapping', 'worktree'
    ]

    implement_stages = ['implementing']
    post_implement_stages = ['lessons-learned', 'finishing']

    if intent == 'implement':
        if stage in pre_implement_stages:
            return f"Want to implement but currently in '{stage}' stage. Complete reviews first?"

    if intent == 'review' or intent == 'pr':
        if stage in pre_implement_stages:
            return f"Want to review/PR but currently in '{stage}' stage. Implementation not started."
        if stage in implement_stages:
            return f"Want to review/PR but still implementing. Complete implementation first?"

    return None

def main():
    # Read input from stdin
    try:
        input_data = json.load(sys.stdin)
    except json.JSONDecodeError:
        # No valid JSON, exit silently
        print(json.dumps({}))
        return

    prompt = input_data.get('prompt', '')
    cwd = input_data.get('cwd', os.getcwd())

    # Detect intent
    intent = detect_intent(prompt)
    if not intent:
        # No clear intent detected, no guidance needed
        print(json.dumps({}))
        return

    # Get current stage
    feature, stage = get_current_stage(cwd)
    if not stage:
        # No workflow state found, no guidance needed
        print(json.dumps({}))
        return

    # Check if intent matches stage
    warning = check_sequence(intent, stage)
    if warning:
        print(json.dumps({
            "systemMessage": f"Workflow guidance: {warning}"
        }))
    else:
        print(json.dumps({}))

if __name__ == "__main__":
    main()
