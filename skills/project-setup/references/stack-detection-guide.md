# Stack Detection Guide

## Interpreting detect-stack.sh Output

When the script outputs detected frameworks, apply these heuristics:

### Frontend Stack Detection
- React + Next.js -> Server-side rendering focus
- React + Vite -> Client-side SPA focus
- Vue + Nuxt -> Server-side rendering focus
- Svelte + SvelteKit -> Full-stack focus

### Backend Stack Detection
- Express -> Minimal, flexible backend
- Fastify -> Performance-focused backend
- NestJS -> Enterprise-grade, TypeScript-first

### Testing Stack Detection
- Jest -> Unit testing focus
- Playwright -> E2E testing focus
- Vitest -> Modern unit testing with Vite

### Tailoring Templates

Based on detected stack, customize:
1. **design-system.md**: Include framework-specific component patterns
2. **lessons-learned/frontend.md**: Add framework-specific gotchas
3. **lessons-learned/testing.md**: Add testing library patterns
