# Task Sizing Guide

## Target Size: 30 min - 2 hours

Each task should represent a coherent unit of work that:
- Has a clear start and end state
- Can be reviewed independently
- Produces testable output

## Signs a Task is Too Large

- Description exceeds 500 words
- More than 10 implementation steps
- Multiple unrelated acceptance criteria
- Touches 5+ files across different domains
- Requires multiple git commits to complete properly

**Action:** Split into subtasks using chunking-plans

## Signs a Task is Too Small

- Can be completed in under 15 minutes
- Only adds a single line/config change
- Has no meaningful acceptance criteria
- Natural extension of previous task

**Action:** Merge with adjacent related task

## Breaking Down by Boundary

### By Component
- Each UI component = task
- Each API endpoint = task
- Each data model = task

### By Layer
- Database schema = task
- API implementation = task
- UI implementation = task

### By Feature Slice
- Vertical slice through all layers = task
- Each user story = task

## Dependencies

Tasks should minimize dependencies:
- Prefer vertical slices over horizontal layers
- Order tasks so dependencies flow forward
- Clearly document when task A depends on task B
