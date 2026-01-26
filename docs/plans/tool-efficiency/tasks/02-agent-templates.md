# Task 2: Agent Templates

> **Feature:** tool-efficiency | [Previous](./01-universal-git-agents.md) | [Next](./03-dora-assets.md)

## Goal

Create stack-specific agent templates (test, lint, typecheck, build) with `{{PLACEHOLDER}}` syntax for command substitution.

## Context

These templates will be customized per-project by project-setup. The placeholders allow the same template structure to work for npm, pytest, cargo, etc.

## Files

**Create:**
- `skills/project-setup/assets/agent-templates/test.md`
- `skills/project-setup/assets/agent-templates/lint.md`
- `skills/project-setup/assets/agent-templates/typecheck.md`
- `skills/project-setup/assets/agent-templates/build.md`

**Modify:**
- None

**Test:**
- Validate placeholder syntax is consistent

## Implementation Steps

1. Create `assets/agent-templates/` directory in project-setup skill

2. Create `test.md` template:
   - `model: haiku`
   - Command placeholder: `{{TEST_COMMAND}}`
   - Report: pass/fail count, failures with file:line

3. Create `lint.md` template:
   - `model: haiku`
   - Command placeholder: `{{LINT_COMMAND}}`
   - Report: error/warning count, locations

4. Create `typecheck.md` template:
   - `model: haiku`
   - Command placeholder: `{{TYPECHECK_COMMAND}}`
   - Report: type errors with locations

5. Create `build.md` template:
   - `model: haiku`
   - Command placeholder: `{{BUILD_COMMAND}}`
   - Report: success/failure, build errors

## Acceptance Criteria

- [ ] All four templates created with correct placeholder syntax
- [ ] Each template has `model: haiku` in frontmatter
- [ ] Each template has description explaining it's a mechanical task
- [ ] Placeholder names match spec: `{{TEST_COMMAND}}`, etc.

## Dependencies

- Depends on: None
- Blocks: Task 5 (project-setup)

---

## Domain Checklists

### Security Checklist

**Security Checklist Status:** N/A

**If N/A, verify all conditions:**
- [x] Task touches no external data paths
- [x] Task produces no user/system output
- [x] Task modifies no persistent state
- [x] Task adds no new dependencies

**N/A Justification:** Creating template files only. Placeholders are substituted later by project-setup.

### Interface Checklist

- [x] **Feedback provided**: Templates define output format for agent
- [x] **Errors actionable**: Templates instruct agent to report command errors
- [x] **Edge inputs handled**: N/A - templates are passive definitions
- [ ] **Accessibility considered**: N/A - CLI output

**Interface N/A reason:** Templates define agent behavior, not direct interface.

### Data/State Checklist

**Data/State N/A reason:** Template files are read-only definitions.

### Integration Checklist

- [x] **Existing features tested**: No conflicts with existing agents
- [x] **New dependencies assessed**: No dependencies
- [x] **Contracts aligned**: Placeholder format matches spec in Section 2.2 of plan
- [x] **Degradation handled**: If command fails, agent reports error

---

## Unit Test Plan

**Required Coverage Categories:**

- [x] **Happy Path**: Template contains valid YAML frontmatter with `model: haiku`
- [x] **Error/Exception Path**: Template handles command failure (instructs agent to report)
- [x] **Edge/Boundary Case**: Placeholder syntax `{{...}}` is consistent across all templates

## E2E/Integration Test Plan

N/A - Integration tested in Task 5 when templates are substituted.

---

## Behavior Definitions

| Scenario | Expected Behavior |
|----------|-------------------|
| Placeholder not substituted | Agent would show literal `{{COMMAND}}` - caught by project-setup |
| Command returns non-zero | Agent reports exit code and stderr |
| Very long output | Agent summarizes (count errors) rather than full dump |

---

## Spike Verification

**Spike N/A reason:** Template substitution is string replacement - no library needed.
