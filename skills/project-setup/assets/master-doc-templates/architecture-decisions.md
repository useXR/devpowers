# Architecture Decisions

This document records architectural approach decisions made during feature development. Each decision captures the assessment that led to it and when to reconsider.

**Purpose:**
- Ensure consistency across features in the same domain
- Document why approaches were chosen
- Identify when circumstances warrant revisiting past decisions

---

<!-- New ADRs are appended below. Use the template format. -->

## ADR Template

```markdown
## ADR-XXX: [Feature Name] (YYYY-MM-DD)

**Decision:** [Chosen architectural approach]

**Assessment:**
| Dimension | Score | Notes |
|-----------|-------|-------|
| Business Logic | Low/Medium/High | [Brief context] |
| Data Relationships | Simple/Moderate/Complex | [Brief context] |
| Domain Expert Involvement | None/Some/High | [Brief context] |
| Change Frequency | Stable/Moderate/Frequent | [Brief context] |

**Rationale:** [How the dimension scores led to this decision]

**Key Patterns:** [Specific patterns to use - e.g., "service objects for business logic", "entities are anemic", "use repository pattern"]

**When to Reconsider:** [Triggers that would warrant reassessing - e.g., "if business rules emerge", "if we need audit history", "if domain experts get involved"]
```

---

<!-- ADRs start here -->
