# Task 1: Cleanup

> **Devpowers Implementation** | [← Overview](./00-overview.md) | [Next: State Infrastructure →](./02-state-infrastructure.md)

---

## Context

**This task removes superseded skills and reorganizes files.** Cleans up the codebase before building new workflow features.

### Prerequisites
- Pre-flight checklist complete (see overview)

### What This Task Creates
- Removes `skills/executing-plans/`
- Removes `skills/receiving-code-review/`
- Removes `workflow/` directory
- Moves `reviewing-plans/` to `skills/reviewing-plans/`
- Updates skill references from `superpowers:` to `devpowers:`

### Tasks That Depend on This
- **Task 2** (State Infrastructure) - needs clean skill directory
- All subsequent tasks - need correct skill references

---

## Files to Remove

- `skills/executing-plans/` (entire directory)
- `skills/receiving-code-review/` (entire directory)
- `workflow/` (root directory)

## Files to Move

- `reviewing-plans/` → `skills/reviewing-plans/`

## Files to Modify

- `skills/reviewing-plans/SKILL.md` (after move)

---

## Steps

### Step 1: Verify current state

```bash
ls -la skills/ | head -20
ls -la reviewing-plans/ 2>/dev/null || echo "reviewing-plans not at root"
ls -la workflow/ 2>/dev/null || echo "workflow not at root"
```

### Step 2: Remove superseded skills

```bash
rm -rf skills/executing-plans/
rm -rf skills/receiving-code-review/
```

### Step 3: Remove workflow directory

```bash
rm -rf workflow/
```

### Step 4: Move reviewing-plans to skills/

```bash
# Check if reviewing-plans exists at root
if [ -d "reviewing-plans" ]; then
    mv reviewing-plans/ skills/reviewing-plans/
    echo "Moved reviewing-plans to skills/"
else
    echo "reviewing-plans already in skills/ or doesn't exist"
fi
```

### Step 5: Fix superpowers references in reviewing-plans

Open `skills/reviewing-plans/SKILL.md` and make these changes:

| Find | Replace With |
|------|--------------|
| `superpowers:subagent-driven-development` | `devpowers:subagent-driven-development` |
| `superpowers:writing-plans` | `devpowers:writing-plans` |
| `superpowers:executing-plans` | Remove entirely (skill deleted) |

Also remove any content describing "parallel session execution via executing-plans".

### Step 6: Verify no superpowers references remain

```bash
grep -r "superpowers:" skills/reviewing-plans/ || echo "No superpowers references found - good!"
```

### Step 7: Commit

```bash
git add -A
git commit -m "chore: cleanup superseded skills and fix references

- Remove skills/executing-plans/ (superseded by subagent-driven-development)
- Remove skills/receiving-code-review/ (merged into subagent-driven-development)
- Remove workflow/ directory (working notes captured in plan)
- Move reviewing-plans/ to skills/ for auto-discovery
- Update superpowers: references to devpowers:"
```

---

## Verification Checklist

- [ ] `skills/executing-plans/` does not exist
- [ ] `skills/receiving-code-review/` does not exist
- [ ] `workflow/` does not exist
- [ ] `skills/reviewing-plans/SKILL.md` exists
- [ ] No `superpowers:` references in `skills/reviewing-plans/`
- [ ] Changes committed

---

## Next Steps

Proceed to **[Task 2: State Infrastructure](./02-state-infrastructure.md)**.
