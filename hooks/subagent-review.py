#!/usr/bin/env python3
"""
SubagentStop hook for devpowers workflow.
Reminds about code review after implementation subagents complete.
"""

import json
import sys
import os
from pathlib import Path

def read_recent_transcript(transcript_path: str, lines: int = 100) -> str:
    """Read the last N lines of the transcript."""
    try:
        path = Path(transcript_path)
        if not path.exists():
            return ""

        with open(path, 'r') as f:
            content = f.readlines()
            return ''.join(content[-lines:])
    except Exception:
        return ""

def check_implementation_done(transcript: str) -> bool:
    """Check if transcript indicates implementation work was done."""
    impl_indicators = [
        'implementation',
        'implemented',
        'created file',
        'wrote file',
        'added function',
        'built component',
        'tests passing',
        'committed'
    ]

    transcript_lower = transcript.lower()
    return any(ind in transcript_lower for ind in impl_indicators)

def check_review_done(transcript: str) -> bool:
    """Check if code review was already performed."""
    review_indicators = [
        'code-reviewer',
        'code review',
        'reviewed the code',
        'review complete'
    ]

    transcript_lower = transcript.lower()
    return any(ind in transcript_lower for ind in review_indicators)

def main():
    # Read input from stdin
    try:
        input_data = json.load(sys.stdin)
    except json.JSONDecodeError:
        print(json.dumps({}))
        return

    transcript_path = input_data.get('transcript_path', '')

    if not transcript_path:
        print(json.dumps({}))
        return

    # Read transcript
    transcript = read_recent_transcript(transcript_path)

    if not transcript:
        print(json.dumps({}))
        return

    # Check if implementation was done
    impl_done = check_implementation_done(transcript)

    if not impl_done:
        # Not an implementation subagent, no reminder needed
        print(json.dumps({}))
        return

    # Check if review was done
    review_done = check_review_done(transcript)

    if review_done:
        # Review already done, no reminder needed
        print(json.dumps({}))
        return

    # Implementation done but no review - remind
    print(json.dumps({
        "systemMessage": "Implementation subagent completed. Consider invoking code-reviewer agent before proceeding."
    }))

if __name__ == "__main__":
    main()
