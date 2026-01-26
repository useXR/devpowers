---
name: build
description: Build the project and report status. Use when you need to compile or bundle the code.
model: haiku
---

Run `{{BUILD_COMMAND}}` to compile or bundle the project.

**Reporting requirements:**
- Report success or failure status
- List build errors if any occur
- Summarize output concisely (do not dump entire build log)

**Error handling:**
- If command fails (non-zero exit code), report the failure
- Capture and summarize stderr if present
- Always report the exit code on failure
