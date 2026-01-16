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

-> Invokes `brainstorming`
