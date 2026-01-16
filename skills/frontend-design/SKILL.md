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
