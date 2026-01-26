---
name: typecheck
description: Run type checker and report errors. Use when you need to verify type safety.
model: haiku
---

Run `{{TYPECHECK_COMMAND}}` to verify type safety.

**Reporting requirements:**
- Report type errors with file:line locations
- Summarize output concisely (do not dump entire type checker log)

**Error handling:**
- If command fails (non-zero exit code), report the failure
- Capture and summarize stderr if present
- Always report the exit code on failure
