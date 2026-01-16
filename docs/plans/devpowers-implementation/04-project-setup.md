# Task 4: Project Setup Skill

> **Devpowers Implementation** | [← Entry Point](./03-entry-point.md) | [Next: Core Workflow Skills →](./05-core-workflow-skills.md)

---

## Context

**This task creates the project-setup skill with master document templates.** Initializes projects with tailored knowledge bases for institutional learning.

### Prerequisites
- **Task 2** completed (state templates exist)

### What This Task Creates
- `skills/project-setup/SKILL.md`
- `skills/project-setup/scripts/detect-stack.sh`
- `skills/project-setup/references/stack-detection-guide.md`
- `skills/project-setup/assets/master-doc-templates/design-system.md`
- `skills/project-setup/assets/master-doc-templates/lessons-learned/frontend.md`
- `skills/project-setup/assets/master-doc-templates/lessons-learned/backend.md`
- `skills/project-setup/assets/master-doc-templates/lessons-learned/testing.md`
- `skills/project-setup/assets/master-doc-templates/lessons-learned/infrastructure.md`

### Tasks That Depend on This
- **Task 5** (Core Workflow Skills) - brainstorming references master docs

### Parallel Tasks
This task can be done in parallel with:
- **Task 3** (Entry Point)

---

## Files to Create

```
skills/project-setup/
├── SKILL.md
├── scripts/
│   └── detect-stack.sh
├── references/
│   └── stack-detection-guide.md
└── assets/
    └── master-doc-templates/
        ├── design-system.md
        └── lessons-learned/
            ├── frontend.md
            ├── backend.md
            ├── testing.md
            └── infrastructure.md
```

---

## Steps

### Step 1: Create directory structure

```bash
mkdir -p skills/project-setup/{scripts,references,assets/master-doc-templates/lessons-learned}
```

### Step 2: Create SKILL.md

Create `skills/project-setup/SKILL.md`:

```markdown
---
name: project-setup
description: >
  This skill should be used when the user asks to "set up a new project",
  "initialize master documents", "create project structure", "bootstrap devpowers",
  or when starting development in a repo without `/docs/master/` directory.
  Sets up master documents tailored to the detected technology stack.
---

# Project Setup

## Overview

Initialize a project with tailored master documents for institutional knowledge accumulation.

## Workflow

1. Run `scripts/detect-stack.sh` — outputs detected frameworks
2. Interpret results using `references/stack-detection-guide.md`
3. Read template master docs from `assets/master-doc-templates/`
4. Tailor templates based on detected stack (apply judgment)
5. Write tailored docs to `/docs/master/`
6. Commit initial master docs
7. Handoff: "Project setup complete. Ready to start brainstorming a feature?"

## Directory Conventions

- `assets/`: Templates and static resources copied to project (not loaded into context)
- `references/`: Documentation loaded on-demand when Claude needs guidance
- `scripts/`: Executable tools that output data for Claude to interpret

## Output Structure

Creates:
```
/docs/master/
  design-system.md           # UI patterns, component conventions
  lessons-learned/
    frontend.md
    backend.md
    testing.md
    infrastructure.md
  patterns/
    [stack-specific patterns discovered over time]
```

## Handoff

"Project setup complete. Master docs created at `/docs/master/`.

Ready to start brainstorming a feature?"

→ Invokes `brainstorming`
```

### Step 3: Create detect-stack.sh

Create `skills/project-setup/scripts/detect-stack.sh`:

```bash
#!/bin/bash
# Detect technology stack from project files

echo "=== Stack Detection ==="

# Check for package.json (Node.js ecosystem)
if [ -f "package.json" ]; then
    echo "DETECTED: Node.js project"
    echo "Dependencies:"

    # Frontend frameworks
    grep -oE '"(react|vue|svelte|angular|next|nuxt|gatsby|remix|astro)"' package.json 2>/dev/null | tr -d '"' | while read dep; do
        echo "  - $dep (frontend)"
    done

    # Backend frameworks
    grep -oE '"(express|fastify|koa|hapi|nest|hono)"' package.json 2>/dev/null | tr -d '"' | while read dep; do
        echo "  - $dep (backend)"
    done

    # Testing
    grep -oE '"(jest|vitest|mocha|playwright|cypress)"' package.json 2>/dev/null | tr -d '"' | while read dep; do
        echo "  - $dep (testing)"
    done

    # Styling
    grep -oE '"(tailwindcss|styled-components|emotion|sass)"' package.json 2>/dev/null | tr -d '"' | while read dep; do
        echo "  - $dep (styling)"
    done
fi

# Check for Python
if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ] || [ -f "setup.py" ]; then
    echo "DETECTED: Python project"
    if [ -f "requirements.txt" ]; then
        grep -oE '^(django|flask|fastapi|pytest|numpy|pandas)' requirements.txt 2>/dev/null | while read dep; do
            echo "  - $dep"
        done
    fi
fi

# Check for Go
if [ -f "go.mod" ]; then
    echo "DETECTED: Go project"
fi

# Check for Rust
if [ -f "Cargo.toml" ]; then
    echo "DETECTED: Rust project"
fi

# Check for Docker
if [ -f "Dockerfile" ] || [ -f "docker-compose.yml" ] || [ -f "docker-compose.yaml" ]; then
    echo "DETECTED: Docker/containerized"
fi

# Check for CI/CD
if [ -d ".github/workflows" ]; then
    echo "DETECTED: GitHub Actions CI/CD"
fi
if [ -f ".gitlab-ci.yml" ]; then
    echo "DETECTED: GitLab CI/CD"
fi

# Check folder structure
echo ""
echo "=== Directory Structure ==="
ls -d */ 2>/dev/null | head -20

echo ""
echo "=== Key Files ==="
ls -la *.json *.yaml *.yml *.toml 2>/dev/null | head -10
```

Make it executable:
```bash
chmod +x skills/project-setup/scripts/detect-stack.sh
```

### Step 4: Create stack-detection-guide.md

Create `skills/project-setup/references/stack-detection-guide.md`:

```markdown
# Stack Detection Guide

## Interpreting detect-stack.sh Output

When the script outputs detected frameworks, apply these heuristics:

### Frontend Stack Detection
- React + Next.js → Server-side rendering focus
- React + Vite → Client-side SPA focus
- Vue + Nuxt → Server-side rendering focus
- Svelte + SvelteKit → Full-stack focus

### Backend Stack Detection
- Express → Minimal, flexible backend
- Fastify → Performance-focused backend
- NestJS → Enterprise-grade, TypeScript-first

### Testing Stack Detection
- Jest → Unit testing focus
- Playwright → E2E testing focus
- Vitest → Modern unit testing with Vite

### Tailoring Templates

Based on detected stack, customize:
1. **design-system.md**: Include framework-specific component patterns
2. **lessons-learned/frontend.md**: Add framework-specific gotchas
3. **lessons-learned/testing.md**: Add testing library patterns
```

### Step 5: Create design-system.md template

Create `skills/project-setup/assets/master-doc-templates/design-system.md`:

```markdown
# Design System

## Colors
- Primary: [detected or placeholder]
- Secondary: [detected or placeholder]
- Error/Success/Warning states

## Typography
- Font families
- Size scale
- Line heights

## Spacing
- Base unit
- Scale (xs, sm, md, lg, xl)

## Components
- Button variants
- Form elements
- Card patterns
- Navigation patterns

## Responsive Breakpoints
- Mobile/Tablet/Desktop definitions

## Anti-Patterns (avoid these)
<!-- Populated from lessons learned -->
```

### Step 6: Create lessons-learned templates

Create `skills/project-setup/assets/master-doc-templates/lessons-learned/frontend.md`:

```markdown
# Lessons Learned: Frontend

## Patterns That Work
<!-- Successful approaches discovered during implementation -->

## Anti-Patterns
<!-- Approaches that failed or caused issues -->

## Gotchas
<!-- Non-obvious behaviors, edge cases, surprises -->

## Useful Tools/Libraries
<!-- Recommendations with context -->
```

Create similar files for `backend.md`, `testing.md`, and `infrastructure.md` with the same template structure but domain-appropriate headers.

### Step 7: Verify files created

```bash
find skills/project-setup -type f | sort
```

**Expected:** All files listed

### Step 8: Commit

```bash
git add skills/project-setup/
git commit -m "feat: add project-setup skill with master doc templates

- SKILL.md with workflow and handoff
- detect-stack.sh for technology detection
- stack-detection-guide.md for interpretation
- Master doc templates (design-system, lessons-learned)"
```

---

## Verification Checklist

- [ ] `skills/project-setup/SKILL.md` exists
- [ ] `scripts/detect-stack.sh` exists and is executable
- [ ] `references/stack-detection-guide.md` exists
- [ ] `assets/master-doc-templates/design-system.md` exists
- [ ] `assets/master-doc-templates/lessons-learned/frontend.md` exists
- [ ] `assets/master-doc-templates/lessons-learned/backend.md` exists
- [ ] `assets/master-doc-templates/lessons-learned/testing.md` exists
- [ ] `assets/master-doc-templates/lessons-learned/infrastructure.md` exists
- [ ] Changes committed

---

## Next Steps

Proceed to **[Task 5: Core Workflow Skills](./05-core-workflow-skills.md)**.
