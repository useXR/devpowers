# Task 12: Fork Skills (Optional)

> **Devpowers Implementation** | [← Hook Automation](./11-hook-automation.md) | [Next: Verification →](./99-verification.md)

---

## Context

**This task forks external skills and customizes them for devpowers.** Integrates with master documents and learnings capture.

### Prerequisites
- **Task 6** completed (domain-review exists for reference)

### What This Task Creates
- `skills/frontend-design/SKILL.md` (fork of `frontend-design:frontend-design`)
- `skills/playwright-testing/SKILL.md` (fork of `playwright-skill:playwright-skill`)

### Tasks That Depend on This
- None (enhancement layer)

### Note
This task is **optional** and can be deferred. The core devpowers workflow works without these forked skills.

---

## Sub-Tasks

1. Fork frontend-design skill
2. Fork playwright-testing skill

---

## Sub-Task 12.1: Fork frontend-design Skill

### Why Fork?

1. **Master doc integration** — Original doesn't know about `/docs/master/design-system.md`
2. **Learnings capture** — Need to append to learnings.md during implementation
3. **Domain review integration** — Frontend critic should reference these principles

### Create directory structure

```bash
mkdir -p skills/frontend-design/{references,examples/component-patterns}
```

### Create SKILL.md

**File:** `skills/frontend-design/SKILL.md`

```markdown
---
name: frontend-design
description: >
  This skill should be used when the user asks to "design a component",
  "build the UI", "create the interface", "make it look good", "avoid generic design",
  or when implementing frontend tasks. Creates distinctive, non-generic UI
  that follows project design system.
version: 1.0.0
forked_from: frontend-design:frontend-design v2.3.0
---

# Frontend Design (devpowers fork)

**Fork notes:** Customized from frontend-design plugin. Key changes:
- Master document integration
- Learnings capture handoff
- Domain review integration

## Devpowers Integration

**Reads from:**
- `/docs/master/design-system.md` — Project design system
- `/docs/master/lessons-learned/frontend.md` — Past learnings

**Writes to:**
- `learnings.md` — New insights (append only)

**Hands off to:**
- Continue with implementation task

## Before Designing

1. Read `/docs/master/design-system.md` for:
   - Color palette
   - Typography scale
   - Spacing system
   - Component patterns

2. Read `/docs/master/lessons-learned/frontend.md` for:
   - Patterns that work
   - Anti-patterns to avoid
   - Framework-specific gotchas

## Key Behaviors

- Avoid generic "AI look" patterns
- Focus on distinctive, purposeful design
- Maintain project-specific component patterns
- Use project's established color/typography/spacing

## After Implementing

Append to learnings.md when discovering:
- What patterns worked well
- What patterns to avoid next time
- Any design system updates needed

## Changelog

### v1.0.0 (devpowers)
- Added master document integration
- Added learnings capture handoff
- Modified to reference project design system
```

### Create references/design-principles.md

Copy design principles from the original `frontend-design:frontend-design` plugin, or create based on anti-patterns to avoid (generic AI look, etc.).

### Commit

```bash
git add skills/frontend-design/
git commit -m "feat: add frontend-design skill (forked)

Fork of frontend-design:frontend-design with:
- Master doc integration (/docs/master/design-system.md)
- Learnings capture to learnings.md
- Domain review integration"
```

---

## Sub-Task 12.2: Fork playwright-testing Skill

### Why Fork?

1. **Journey map integration** — Original generates tests ad-hoc; we derive from journey maps
2. **Master doc integration** — Need to read `/docs/master/lessons-learned/testing.md`
3. **Learnings capture** — Append to learnings.md when tests reveal unexpected behavior

### Create directory structure

```bash
mkdir -p skills/playwright-testing/{scripts,references,examples/sample-tests}
```

### Create SKILL.md

**File:** `skills/playwright-testing/SKILL.md`

```markdown
---
name: playwright-testing
description: >
  This skill should be used when the user asks to "write e2e tests",
  "implement tests from journeys", "set up Playwright", "test the user flows",
  or when implementing test tasks. Generates tests from user journey maps
  for comprehensive coverage.
version: 1.0.0
forked_from: playwright-skill:playwright-skill v1.0.0
---

# Playwright Testing (devpowers fork)

**Fork notes:** Customized from playwright-skill plugin. Key changes:
- Journey map integration for test derivation
- Master document integration
- Learnings capture when tests reveal unexpected behavior

## Devpowers Integration

**Reads from:**
- `/docs/plans/[feature]/journeys/` — User journey maps
- `/docs/master/lessons-learned/testing.md` — Past testing learnings
- Task documents with "E2E Test Plan" section

**Writes to:**
- `learnings.md` — When tests reveal unexpected behavior

## Key Behaviors

- Generates tests FROM user journey maps (not ad-hoc)
- Covers error states, edge cases, accessibility per journey categories
- Validates against journey map completeness

## Test Derivation Process

1. Read journey map for component
2. For each journey:
   - Create test case with descriptive name
   - Implement steps from journey
   - Add assertions for expected outcomes
3. Verify all journeys have corresponding tests

## After Testing

Append to learnings.md when:
- Tests reveal unexpected application behavior
- New edge cases discovered
- Testing patterns prove useful

## Changelog

### v1.0.0 (devpowers)
- Added journey map integration
- Added master document integration
- Added learnings capture
```

### Create scripts/scaffold-test.sh

```bash
#!/bin/bash
# Scaffold a new Playwright test file

FEATURE=$1
COMPONENT=$2

if [ -z "$FEATURE" ] || [ -z "$COMPONENT" ]; then
    echo "Usage: scaffold-test.sh <feature> <component>"
    exit 1
fi

cat > "tests/e2e/${COMPONENT}.spec.ts" << 'EOF'
import { test, expect } from '@playwright/test';

test.describe('COMPONENT', () => {
  test('should complete happy path', async ({ page }) => {
    // TODO: Implement from journey map
  });
});
EOF

echo "Created tests/e2e/${COMPONENT}.spec.ts"
```

### Commit

```bash
chmod +x skills/playwright-testing/scripts/scaffold-test.sh
git add skills/playwright-testing/
git commit -m "feat: add playwright-testing skill (forked)

Fork of playwright-skill:playwright-skill with:
- Journey map integration for test derivation
- Master doc integration (/docs/master/lessons-learned/testing.md)
- Learnings capture when tests reveal unexpected behavior"
```

---

## Fork Maintenance

| Activity | Frequency | Process |
|----------|-----------|---------|
| Check upstream | Monthly | Review upstream changelog for updates |
| Pull improvements | As needed | Manually merge useful upstream changes |
| Contribute back | When stable | PR generic improvements to upstream |

### Fork vs Wrapper Decision

```
Is the customization...
├── Project-specific data (master docs)? → Fork
├── Workflow integration? → Fork
├── Bug fix? → PR upstream, use original
├── Feature enhancement? → PR upstream, use original
└── Style preference? → Don't fork, accept original
```

---

## Verification Checklist

- [ ] `skills/frontend-design/SKILL.md` exists with fork notes
- [ ] `skills/frontend-design/` references master docs
- [ ] `skills/playwright-testing/SKILL.md` exists with fork notes
- [ ] `skills/playwright-testing/` references journey maps
- [ ] Both skills have `forked_from` in frontmatter
- [ ] Both skills have changelog section
- [ ] All changes committed

---

## Next Steps

Proceed to **[Task 99: Verification](./99-verification.md)** to verify the complete implementation.
