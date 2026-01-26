# Domain Detection

Not all critics run for every task. Detect relevant domains from task content.

## Detection Rules (any 2+ signals triggers domain)

| Domain | File Path Signals | Keyword Signals | Import Signals |
|--------|------------------|-----------------|----------------|
| **Frontend** | `src/components/`, `src/ui/`, `*.css`, `*.tsx` | "component", "render", "useState", "UI" | react, vue, svelte, tailwind |
| **Backend** | `src/api/`, `src/server/`, `routes/`, `controllers/` | "endpoint", "database", "query", "API" | express, fastify, prisma |
| **Security** | (always runs) | - | - |
| **Testing** | (always runs) | - | - |
| **Infrastructure** | `Dockerfile`, `*.yaml`, `terraform/`, `.github/` | "deployment", "CI/CD", "kubernetes" | docker, terraform |

## Detection Algorithm

```
1. Parse task "Files to Create/Modify" section
2. Match file paths against domain patterns
3. Scan task content for keyword signals
4. Score each domain by signal count
5. Trigger domain if score >= 2
6. Always include Security (checks all input/output handling)
7. Always include Testing (maintains test plan)
```
