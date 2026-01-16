# Devpowers Implementation Verification

> **Devpowers Implementation** | [← Fork Skills](./12-fork-skills.md) | **Final Step**

---

## Purpose

**This checklist verifies that all devpowers implementation tasks are complete and working.**

---

## Automated Verification

Run this script to check file existence:

```bash
#!/bin/bash
echo "=== Devpowers Implementation Verification ==="

ERRORS=0

check_file() {
    if [ -f "$1" ]; then
        echo "✅ $1"
    else
        echo "❌ $1 MISSING"
        ERRORS=$((ERRORS + 1))
    fi
}

check_dir() {
    if [ -d "$1" ]; then
        echo "✅ $1/"
    else
        echo "❌ $1/ MISSING"
        ERRORS=$((ERRORS + 1))
    fi
}

check_executable() {
    if [ -x "$1" ]; then
        echo "✅ $1 (executable)"
    else
        echo "❌ $1 NOT EXECUTABLE"
        ERRORS=$((ERRORS + 1))
    fi
}

echo ""
echo "--- Task 1: Cleanup ---"
check_file "skills/reviewing-plans/SKILL.md"
echo "Verify: skills/executing-plans/ should NOT exist"
echo "Verify: skills/receiving-code-review/ should NOT exist"

echo ""
echo "--- Task 2: State Infrastructure ---"
check_file "skills/using-devpowers/assets/STATUS-template.md"
check_file "skills/using-devpowers/assets/ACTIVE-template.md"
check_file "skills/using-devpowers/assets/learnings-template.md"

echo ""
echo "--- Task 3: Entry Point ---"
check_file "skills/using-devpowers/SKILL.md"

echo ""
echo "--- Task 4: Project Setup ---"
check_file "skills/project-setup/SKILL.md"
check_executable "skills/project-setup/scripts/detect-stack.sh"
check_file "skills/project-setup/references/stack-detection-guide.md"
check_file "skills/project-setup/assets/master-doc-templates/design-system.md"
check_dir "skills/project-setup/assets/master-doc-templates/lessons-learned"

echo ""
echo "--- Task 5: Core Workflow Skills ---"
check_file "skills/brainstorming/SKILL.md"
check_file "skills/writing-plans/SKILL.md"
check_file "skills/reviewing-plans/SKILL.md"
check_file "skills/reviewing-plans/feasibility-critic.md"
check_file "skills/reviewing-plans/completeness-critic.md"
check_file "skills/reviewing-plans/simplicity-critic.md"
check_file "skills/task-breakdown/SKILL.md"
check_dir "skills/task-breakdown/assets"

echo ""
echo "--- Task 6: Domain Review ---"
check_file "skills/domain-review/SKILL.md"
check_file "skills/domain-review/frontend-critic.md"
check_file "skills/domain-review/backend-critic.md"
check_file "skills/domain-review/testing-critic.md"
check_file "skills/domain-review/infrastructure-critic.md"
check_file "agents/frontend-reviewer.md"
check_file "agents/backend-reviewer.md"
check_file "agents/testing-reviewer.md"
check_file "agents/infrastructure-reviewer.md"
check_file "agents/integration-reviewer.md"

echo ""
echo "--- Task 7: Cross-Domain Review ---"
check_file "skills/cross-domain-review/SKILL.md"
check_file "skills/cross-domain-review/integration-critic.md"

echo ""
echo "--- Task 8: User Journey Mapping ---"
check_file "skills/user-journey-mapping/SKILL.md"
check_file "skills/user-journey-mapping/journey-critic.md"
check_file "skills/user-journey-mapping/references/journey-categories.md"

echo ""
echo "--- Task 9: Lessons Learned ---"
check_file "skills/lessons-learned/SKILL.md"
check_file "skills/lessons-learned/learnings-reviewer.md"

echo ""
echo "--- Task 10: Implementation Skills ---"
check_file "skills/subagent-driven-development/SKILL.md"
check_file "skills/test-driven-development/SKILL.md"

echo ""
echo "--- Task 11: Hook Automation ---"
check_file "hooks/hooks.json"
check_executable "hooks/session-start-workflow.sh"
check_executable "hooks/workflow-advisor.py"
check_executable "hooks/write-validator.py"
check_executable "hooks/task-created.sh"
check_executable "hooks/subagent-review.py"
check_executable "hooks/learnings-check.sh"

echo ""
echo "--- Task 12: Fork Skills (Optional) ---"
check_file "skills/frontend-design/SKILL.md"
check_file "skills/playwright-testing/SKILL.md"

echo ""
echo "=== Summary ==="
if [ $ERRORS -eq 0 ]; then
    echo "✅ All checks passed!"
else
    echo "❌ $ERRORS errors found"
fi
```

---

## Manual Verification Steps

### 1. Skill Discovery

```bash
# List all skills
ls -la skills/
```

**Expected:** All new skills listed:
- [ ] `using-devpowers/`
- [ ] `project-setup/`
- [ ] `brainstorming/`
- [ ] `writing-plans/`
- [ ] `reviewing-plans/`
- [ ] `task-breakdown/`
- [ ] `domain-review/`
- [ ] `cross-domain-review/`
- [ ] `user-journey-mapping/`
- [ ] `lessons-learned/`
- [ ] `subagent-driven-development/`
- [ ] `test-driven-development/`
- [ ] `chunking-plans/`
- [ ] `frontend-design/` (optional)
- [ ] `playwright-testing/` (optional)

### 2. Agent Discovery

```bash
# List all agents
ls -la agents/
```

**Expected:**
- [ ] `frontend-reviewer.md`
- [ ] `backend-reviewer.md`
- [ ] `testing-reviewer.md`
- [ ] `infrastructure-reviewer.md`
- [ ] `integration-reviewer.md`
- [ ] `code-reviewer.md` (existing)

### 3. Hook Configuration

```bash
# Verify hooks.json structure
cat hooks/hooks.json | jq '.hooks | keys'
```

**Expected:** `["SessionStart", "UserPromptSubmit", "PreToolUse", "PostToolUse", "SubagentStop", "Stop"]`

### 4. Reference Checks

```bash
# Check for superpowers references that should be devpowers
grep -r "superpowers:" skills/ --include="*.md"
```

**Expected:** No matches (all should be `devpowers:`)

### 5. Template Content

```bash
# Verify STATUS template has all sections
grep "## " skills/using-devpowers/assets/STATUS-template.md
```

**Expected:** Current State, Sub-State, Progress, Blocking Issues, User Overrides, Next Action, Recovery Info

---

## File Checklist by Task

### Task 1 - Cleanup
- [ ] `skills/executing-plans/` does NOT exist
- [ ] `skills/receiving-code-review/` does NOT exist
- [ ] `workflow/` does NOT exist
- [ ] `skills/reviewing-plans/SKILL.md` exists
- [ ] No `superpowers:` references in reviewing-plans

### Task 2 - State Infrastructure
- [ ] `skills/using-devpowers/assets/STATUS-template.md` exists
- [ ] `skills/using-devpowers/assets/ACTIVE-template.md` exists
- [ ] `skills/using-devpowers/assets/learnings-template.md` exists

### Task 3 - Entry Point
- [ ] `skills/using-devpowers/SKILL.md` has scope tiers
- [ ] `skills/using-devpowers/SKILL.md` has handoff logic

### Task 4 - Project Setup
- [ ] `skills/project-setup/SKILL.md` exists
- [ ] `skills/project-setup/scripts/detect-stack.sh` executable
- [ ] All master doc templates exist

### Task 5 - Core Workflow Skills
- [ ] `skills/brainstorming/SKILL.md` has scope assessment
- [ ] `skills/writing-plans/SKILL.md` outputs to docs/plans
- [ ] `skills/reviewing-plans/` has 3 critic files
- [ ] `skills/task-breakdown/` exists with templates

### Task 6 - Domain Review
- [ ] `skills/domain-review/SKILL.md` has detection rules
- [ ] All 4 domain critic files exist
- [ ] All 5 reviewer agents exist

### Task 7 - Cross-Domain Review
- [ ] `skills/cross-domain-review/SKILL.md` has routing protocol

### Task 8 - User Journey Mapping
- [ ] `skills/user-journey-mapping/` has journey categories

### Task 9 - Lessons Learned
- [ ] `skills/lessons-learned/SKILL.md` has merge algorithm

### Task 10 - Implementation Skills
- [ ] `skills/subagent-driven-development/SKILL.md` has learnings capture
- [ ] `skills/test-driven-development/SKILL.md` has test plan integration

### Task 11 - Hook Automation
- [ ] `hooks/hooks.json` has all 6 events
- [ ] All 6 hook scripts exist and are executable

### Task 12 - Fork Skills (Optional)
- [ ] `skills/frontend-design/SKILL.md` has forked_from
- [ ] `skills/playwright-testing/SKILL.md` has forked_from

---

## Summary

| Task | Status |
|------|--------|
| 1. Cleanup | [ ] |
| 2. State Infrastructure | [ ] |
| 3. Entry Point | [ ] |
| 4. Project Setup | [ ] |
| 5. Core Workflow Skills | [ ] |
| 6. Domain Review | [ ] |
| 7. Cross-Domain Review | [ ] |
| 8. User Journey Mapping | [ ] |
| 9. Lessons Learned | [ ] |
| 10. Implementation Skills | [ ] |
| 11. Hook Automation | [ ] |
| 12. Fork Skills (Optional) | [ ] |

---

## Implementation Complete

**All checks passing? Devpowers implementation is complete!**

The workflow is now ready for use:
1. Start with `using-devpowers` skill
2. Follow the handoff chain through planning → review → implementation
3. Capture learnings at the end

**Documentation:**
- Complete plan: `docs/plans/2026-01-16-devpowers-complete-plan.md`
- Chunked tasks: `docs/plans/devpowers-implementation/`
