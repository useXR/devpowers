# Task [N]: [Task Name]

> **Feature:** [feature-name] | [Previous](./NN-prev.md) | [Next](./NN-next.md)

## Goal

[One sentence describing what this task accomplishes]

## Context

[Brief background needed to understand this task]

## Files

**Create:**
- `path/to/new/file`

**Modify:**
- `path/to/existing/file` (lines ~XX-YY)

**Test:**
- `tests/path/to/test`

## Implementation Steps

1. [Step 1]
2. [Step 2]
3. [Step 3]

## Acceptance Criteria

- [ ] [Criterion 1]
- [ ] [Criterion 2]
- [ ] [Criterion 3]

## Dependencies

- Depends on: Task [N-1] (or "None")
- Blocks: Task [N+1] (or "None")

---

## Domain Checklists

<!-- HARD GATE: Convergence blocked until all applicable checklists completed -->
<!-- Only include checklists relevant to this task's domain -->

### Security Checklist

<!-- STRICT N/A RULES - Security checklist can only be marked N/A if ALL of these are true:
     1. Task touches NO code paths that process external data (even indirectly)
     2. Task produces NO output that reaches users or external systems
     3. Task modifies NO persistent state
     4. Task adds NO new dependencies
     If ANY of these are false, you MUST complete the security checklist. -->

- [ ] **Input boundaries validated**: All external input (user, API, file, env) validated before use
- [ ] **Output safely encoded**: Content sent to users/other systems can't be interpreted as code/commands
- [ ] **Access control verified**: Authorization checked before accessing protected resources
- [ ] **Sensitive data protected**: Credentials, PII, secrets not logged, exposed in errors, or leaked
- [ ] **Injection prevented**: Dynamic queries/commands use safe construction (parameterization, escaping)

**Security Checklist Status:** [COMPLETED | N/A]

**If N/A, verify all conditions:**
- [ ] Task touches no external data paths
- [ ] Task produces no user/system output
- [ ] Task modifies no persistent state
- [ ] Task adds no new dependencies

**N/A Justification (required if N/A):** [Specific explanation of why ALL four conditions are met]

### Interface Checklist

<!-- REQUIRED for any task with user-facing interface (CLI, GUI, API, etc.) -->
<!-- Applies to: Web UI, desktop UI, mobile UI, CLI tools, APIs, etc. -->

- [ ] **Feedback provided**: User/caller knows operation is in progress, succeeded, or failed
- [ ] **Errors actionable**: Error messages tell user/caller what went wrong and how to fix
- [ ] **Edge inputs handled**: Empty, null, huge, malformed inputs have defined behavior
- [ ] **Accessibility considered**: Interface usable by people with different abilities (if applicable to interface type)

**Interface N/A reason (if applicable):** [Brief explanation]

### Data/State Checklist

<!-- REQUIRED for any task that modifies persistent state (database, files, cache, etc.) -->

- [ ] **Failure handling defined**: What happens if write fails mid-operation?
- [ ] **Concurrency addressed**: What if two processes/users modify simultaneously?
- [ ] **Rollback possible**: Can changes be undone if something goes wrong?
- [ ] **Migration planned**: How do existing data/state transition to new format? (if schema/format changes)

**Data/State N/A reason (if applicable):** [Brief explanation]

### Integration Checklist

<!-- REQUIRED for any task that touches existing features or adds new dependencies -->

- [ ] **Existing features tested**: Works with [list relevant existing features]
- [ ] **New dependencies assessed**: License compatible, maintained, size/performance acceptable
- [ ] **Contracts aligned**: Interfaces match between components (types, formats, protocols)
- [ ] **Degradation handled**: What happens if integrated component is unavailable/slow?

**Integration N/A reason (if applicable):** [Brief explanation]

---

## Unit Test Plan

<!-- HARD GATE: Must contain tests covering ALL THREE categories before convergence -->
<!-- Testing critic MUST populate this section during domain review -->
<!-- Quantity alone doesn't satisfy the gate - coverage of categories does -->

**Required Coverage Categories:**

- [ ] **Happy Path** (at least 1): [Function/Component] - [success scenario with expected output verified]
- [ ] **Error/Exception Path** (at least 1): [Function/Component] - [failure scenario with error type/message verified]
- [ ] **Edge/Boundary Case** (at least 1): [Function/Component] - [edge case like empty, null, max, boundary values]

**Additional tests (if complexity warrants):**
- [ ] [Additional test case]

## E2E/Integration Test Plan

<!-- From journey mapping, if applicable -->
<!-- Can remain empty if task is internal implementation with no user-facing changes -->

---

## Behavior Definitions

<!-- REQUIRED for any task with ambiguous behavior -->
<!-- Defines exact behavior for scenarios that could be interpreted multiple ways -->

| Scenario | Expected Behavior |
|----------|-------------------|
| [Edge case 1] | [What happens] |
| [Edge case 2] | [What happens] |

---

## Spike Verification

<!-- REQUIRED if task uses APIs/libraries not already verified in codebase -->
<!-- Mark N/A if all patterns are already used elsewhere in codebase -->

**Risky assumption:** [What assumption needs verification]
**Spike result:** [Link to POC code or "Verified: [brief explanation]"]
**Spike N/A reason (if applicable):** [Why no spike needed - e.g., "Pattern already used in src/foo.ts"]
