# Gate Checking Algorithm

After each review round, verify all hard gates:

```python
def check_gates(task):
    gates = []

    # Gate 1: Test Plan Populated
    test_items = count_checkbox_items(task, "Unit Test Plan")
    if test_items < 3:
        gates.append(("Test Plan Populated", "FAILED",
                      f"Only {test_items} test cases, need >=3"))

    # Gate 2: Security Checklist Complete
    security_unchecked = count_unchecked(task, "Security Checklist")
    if security_unchecked > 0:
        gates.append(("Security Checklist Complete", "FAILED",
                      f"{security_unchecked} items unchecked"))

    # Gate 3: Behavior Definitions (if user-facing)
    if has_user_facing_changes(task):
        behavior_rows = count_table_rows(task, "Behavior Definitions")
        if behavior_rows < 1:
            gates.append(("Behavior Definitions Present", "FAILED",
                          "User-facing task needs behavior definitions"))

    # Gate 4: Spike Verified (if new dependencies)
    if has_new_dependencies(task):
        spike_status = get_spike_status(task)
        if spike_status == "empty":
            gates.append(("Spike Verified", "FAILED",
                          "New dependencies need spike verification"))

    return gates
```

## Gate Failure Output Format

```
GATE FAILED: [Gate name]
Reason: [What's missing]
Action required: [What critic/user must do]

Cannot converge until this gate passes.
```
