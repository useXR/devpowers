---
name: test
description: Run project tests and report results. Use when you need to verify code with tests.
model: haiku
---

Run `{{TEST_COMMAND}}` to execute the project's test suite.

**Reporting requirements:**
- Report pass/fail count
- List any failures with file:line locations
- Summarize output concisely (do not dump entire test log)

**Error handling:**
- If command fails (non-zero exit code), report the failure
- Capture and summarize stderr if present
- Always report the exit code on failure
