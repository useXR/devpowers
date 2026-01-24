# Architectural Dimensions Scoring Guide

Use this guide to assess the four dimensions that inform architectural approach recommendations.

## Dimension 1: Business Logic Complexity

**Question:** Is this mostly data storage/retrieval, or are there significant business rules, validations, or state transitions?

| Score | Indicators | Examples |
|-------|------------|----------|
| **Low** | Pure CRUD, validation is just data types, no workflows | Admin dashboard, content management, simple listings |
| **Medium** | Some business rules, conditional logic, basic state machines | Order status tracking, approval with simple rules, notifications |
| **High** | Complex workflows, many interdependent rules, state machines with guards | Insurance claims processing, compliance workflows, pricing engines |

**Key questions:**
- Could a junior developer implement this with just framework knowledge?
- Are there rules that require domain expertise to understand?
- Would a flowchart of the logic fit on one page?

## Dimension 2: Data Relationships

**Question:** Are we dealing with simple independent entities, or complex aggregates with invariants that must be enforced together?

| Score | Indicators | Examples |
|-------|------------|----------|
| **Simple** | Flat entities, no cross-entity constraints, can update independently | User profiles, blog posts, configuration settings |
| **Moderate** | Related entities, foreign keys, but no complex consistency rules | Orders with line items, categories with products |
| **Complex** | Aggregates with invariants, changes must be atomic across entities | Shopping cart with inventory reservation, accounts with transaction history |

**Key questions:**
- Can each entity be saved independently without breaking consistency?
- Are there rules like "X must always equal sum of Y"?
- Do changes to one entity require validating/updating others atomically?

## Dimension 3: Domain Expert Involvement

**Question:** Is this a technical/internal tool, or will business stakeholders be involved in defining and evolving the rules?

| Score | Indicators | Examples |
|-------|------------|----------|
| **None** | Internal tooling, developers define all rules | CLI tools, infrastructure dashboards, developer utilities |
| **Some** | Business provides requirements but rules are stable | Customer-facing CRUD, standard e-commerce, content sites |
| **High** | Business actively shapes rules, needs shared vocabulary | Compliance systems, domain-specific applications, enterprise workflows |

**Key questions:**
- Will you be talking to non-technical stakeholders regularly?
- Do stakeholders have specialized vocabulary you need to learn?
- Will stakeholders review the code/behavior for correctness?

## Dimension 4: Change Frequency

**Question:** Are the rules well-understood and stable, or will they evolve frequently as the business learns?

| Score | Indicators | Examples |
|-------|------------|----------|
| **Stable** | Well-understood domain, rare rule changes | Basic auth, standard CRUD, mature processes |
| **Moderate** | Occasional updates, predictable change patterns | Pricing tiers, feature flags, configurable rules |
| **Frequent** | Rules evolve as business learns, experimentation | New product lines, regulatory compliance, market-driven features |

**Key questions:**
- How often did similar features change in the past year?
- Is the business still discovering the rules?
- Are there external factors (regulations, market) driving changes?

## Score Combinations and Recommendations

These are guidelines, not rules. Claude synthesizes recommendations based on context.

### Low across all dimensions
→ Transaction Script, Active Record, simple procedural code

### High business logic, low-moderate others
→ Service objects, domain services, rich validation

### High business logic + high domain expert involvement
→ Domain-Driven Design tactical patterns (entities, value objects, domain services)

### High data relationships + high change frequency
→ Consider event sourcing, CQRS for audit/history needs

### Mixed scores
→ Use judgment; often a hybrid approach works best

## Anti-Patterns to Avoid

**Over-engineering (all dimensions Low/Medium):**
- DDD aggregates for simple CRUD
- Event sourcing for basic state
- Microservices for single-team projects

**Under-engineering (multiple dimensions High):**
- Transaction scripts for complex workflows
- Anemic models with logic scattered in controllers
- No domain vocabulary when experts are involved
