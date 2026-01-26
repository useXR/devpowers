# Scope Tiers (Detailed)

## Trivial Scope

**Indicators:**
- Single file change
- <20 lines modified
- Obvious fix (typo, config tweak, rename)
- No new dependencies
- No architectural decisions

**Workflow:**
```
Direct implementation → Done
```

**What runs:**
- Nothing - just implement

**What to still consider:**
- If touching security-sensitive code, at least run security checklist mentally
- If change could break tests, run tests after

---

## Small Scope

**Indicators:**
- 1-3 files changed
- <100 lines modified
- Bug fix or minor enhancement
- Known patterns (already used elsewhere in codebase)
- No new dependencies

**Workflow:**
```
brainstorming (brief) → implement → verify
```

**What runs:**
| Step | What | Why |
|------|------|-----|
| Brainstorming | Quick scope confirmation | Ensure we understand the ask |
| Security Checklist | Mental check or explicit | Even small changes can introduce vulnerabilities |
| Test Plan | At least 3 test cases | Ensure change is verified |
| Verification | Run tests | Confirm nothing broke |

**What's skipped:**
- Formal plan document
- Multi-round review
- User journey mapping
- Task breakdown (single task)

---

## Medium Scope

**Indicators:**
- Multiple components affected
- 100-500 lines modified
- New feature or significant enhancement
- May introduce new patterns
- May add dependencies

**Workflow:**
```
brainstorming → writing-plans → reviewing-plans (converge) → task-breakdown →
domain-review (with hard gates) → implement → verify → lessons-learned (optional)
```

**What runs:**
| Step | What | Why |
|------|------|-----|
| Brainstorming | Full exploration + architectural assessment | Understand requirements, assess domain complexity, choose approach |
| Writing Plans | High-level plan with spike verification | Document approach, verify risky assumptions |
| Reviewing Plans | Multiple critics until convergence + skeptic pass | Catch issues before implementation |
| Task Breakdown | Create task files | Organize implementation |
| Domain Review | Critics with hard gates | Security checklist, test plans, behavior definitions |
| Implementation | Subagent-driven or direct | Execute tasks |
| Verification | Tests pass, manual verification | Confirm feature works |

**What's skipped:**
- User journey mapping (unless UI-heavy)
- Cross-domain review (unless truly multi-domain)

---

## Large Scope

**Indicators:**
- Architectural change
- >500 lines or many files
- New subsystem or major feature
- Multiple new dependencies
- Unfamiliar domain or technology

**Workflow:**
```
brainstorming → writing-plans (with spikes) → reviewing-plans (converge + skeptic) →
task-breakdown → domain-review (all gates) → cross-domain-review →
user-journey-mapping → implement → verify → lessons-learned
```

**What runs:**
| Step | What | Why |
|------|------|-----|
| Everything from Medium | - | - |
| Cross-Domain Review | Integration critic | Catch issues at component boundaries |
| User Journey Mapping | All journey categories | Ensure UX is complete |
| Lessons Learned | Required | Capture insights for master docs |
