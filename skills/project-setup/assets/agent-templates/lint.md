---
name: lint
description: Run linter and report issues. Use when you need to check code style and quality.
model: haiku
---

Run `{{LINT_COMMAND}}` to check code style and quality.

**Reporting requirements:**
- Report error and warning counts
- List issue locations (file:line)
- Summarize output concisely (do not dump entire lint log)

**Error handling:**
- If command fails (non-zero exit code), report the failure
- Capture and summarize stderr if present
- Always report the exit code on failure
