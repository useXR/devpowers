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
