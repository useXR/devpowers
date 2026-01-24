# Architectural Guidance Enhancement

## Overview

Add architectural approach assessment to devpowers brainstorming, helping identify which patterns (DDD, Transaction Script, Active Record, event-driven, etc.) to use based on project scope and domain complexity.

## Problem Statement

Currently, devpowers helps with process (how to work) but doesn't guide architectural decisions (what patterns to use). This leads to:
- Over-engineering simple CRUD apps with DDD patterns
- Under-engineering complex domains with transaction scripts
- Inconsistent architectural approaches across features in the same project

## Goals

1. **Prevent over-engineering** - Avoid complex patterns when simpler approaches suffice
2. **Prevent under-engineering** - Ensure complex domains get proper architectural thinking
3. **Make architecture explicit** - Document chosen approaches so future work is consistent
4. **Enforce consistency** - New features default to established patterns unless assessment suggests otherwise

## Design

### Assessment Dimensions

Four structured questions during brainstorming (Medium+ scope):

| Dimension | Question | Scale |
|-----------|----------|-------|
| **Business Logic Complexity** | Is this mostly data storage/retrieval, or are there significant business rules, validations, or state transitions? | Low (CRUD) → Medium (some rules) → High (complex workflows) |
| **Data Relationships** | Are we dealing with simple independent entities, or complex aggregates with invariants? | Simple (flat) → Moderate (related) → Complex (aggregates) |
| **Domain Expert Involvement** | Is this a technical/internal tool, or will business stakeholders define and evolve the rules? | None → Some → High |
| **Change Frequency** | Are the rules well-understood and stable, or will they evolve frequently? | Stable → Moderate → Frequent |

### Recommendation Flow

1. Gather dimension scores through questions
2. Claude synthesizes recommendation (open-ended, not from fixed list)
3. Recommendation includes:
   - Recommended approach with rationale
   - Key patterns to use
   - Patterns to avoid
4. User confirms or adjusts

### Architecture Decision Records (ADRs)

Decisions recorded in `/docs/master/architecture-decisions.md`:

```markdown
## ADR-001: [Feature Name] (YYYY-MM-DD)

**Decision:** [Chosen approach]

**Assessment:**
| Dimension | Score | Notes |
|-----------|-------|-------|
| Business Logic | Low/Med/High | [Context] |
| Data Relationships | Low/Med/High | [Context] |
| Domain Expert Involvement | None/Some/High | [Context] |
| Change Frequency | Stable/Mod/Freq | [Context] |

**Rationale:** [How scores led to decision]

**Key Patterns:** [What to use]

**When to Reconsider:** [Triggers for reassessment]
```

### Consistency Enforcement

During brainstorming:

1. Check for existing ADRs relevant to feature's domain
2. Present relevant past decisions as context
3. Run assessment with awareness of precedent
4. Recommend with justification:
   - If consistent: Note alignment with past decision
   - If divergent: Explicitly justify why this feature warrants different approach

### Scope Gating

- **Trivial/Small:** Skip architectural assessment (fits existing patterns by definition)
- **Medium/Large:** Full assessment with ADR creation

## Implementation

### Files to Modify

1. **`skills/brainstorming/SKILL.md`**
   - Add "Architectural Assessment" section after scope assessment
   - Add logic to check/create ADR file
   - Add the four dimension questions
   - Add recommendation synthesis guidance

2. **`skills/using-devpowers/SKILL.md`**
   - Update scope tier descriptions to mention architectural assessment
   - Note that Medium+ scope includes architectural thinking

### Files to Create

3. **`skills/brainstorming/references/architectural-dimensions.md`**
   - Detailed guidance on scoring each dimension
   - Examples of Low/Medium/High for each
   - Common patterns for different score combinations

4. **`skills/project-setup/assets/master-doc-templates/architecture-decisions.md`**
   - Template for the ADR file
   - Header explaining purpose
   - Example entry format

## Open Questions

None - design validated through brainstorming session.

## Decision

Proceed with implementation as designed.
