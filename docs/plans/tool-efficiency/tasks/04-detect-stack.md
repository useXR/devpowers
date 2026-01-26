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

3. Add JSON output section at the end:
   ```bash
   # Output structured data for template substitution
   echo "---TOOL_COMMANDS---"
   echo "TEST_COMMAND=$TEST_CMD"
   echo "LINT_COMMAND=$LINT_CMD"
   echo "TYPECHECK_COMMAND=$TYPECHECK_CMD"
   echo "BUILD_COMMAND=$BUILD_CMD"
   ```

4. Detection logic for each stack:
   - **npm/yarn/pnpm**: Check package.json for scripts
   - **Python**: Check for pytest in requirements.txt or pyproject.toml
   - **Rust**: Cargo commands are standard

## Acceptance Criteria

- [ ] detect-stack.sh outputs `---TOOL_COMMANDS---` section
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

- [x] **Happy Path**: Run on npm project with test script - outputs `TEST_COMMAND=npm test`
- [x] **Error/Exception Path**: Run on project with no test config - outputs `TEST_COMMAND=`
- [x] **Edge/Boundary Case**: Run on project with multiple package managers - picks correct one

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
