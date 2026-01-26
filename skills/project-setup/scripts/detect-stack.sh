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

# ===== TOOL COMMAND DETECTION =====

# Initialize command variables
TEST_CMD=""
LINT_CMD=""
TYPECHECK_CMD=""
BUILD_CMD=""

# Detect package manager
PKG_MGR="npm"
if [ -f "yarn.lock" ]; then
    PKG_MGR="yarn"
elif [ -f "pnpm-lock.yaml" ]; then
    PKG_MGR="pnpm"
fi

# Node.js project detection
if [ -f "package.json" ]; then
    # Prefer jq for safe JSON parsing
    if command -v jq &>/dev/null; then
        TEST_CMD=$(jq -r '.scripts.test // empty' package.json 2>/dev/null)
        LINT_CMD=$(jq -r '.scripts.lint // empty' package.json 2>/dev/null)
        TYPECHECK_CMD=$(jq -r '.scripts.typecheck // .scripts["type-check"] // empty' package.json 2>/dev/null)
        BUILD_CMD=$(jq -r '.scripts.build // empty' package.json 2>/dev/null)
    else
        # Fallback: grep with sanitization (remove shell metacharacters)
        # Note: This is less safe, prefer jq
        TEST_CMD=$(grep -oP '"test"\s*:\s*"\K[^"]+' package.json 2>/dev/null | tr -d ';|&$`')
        LINT_CMD=$(grep -oP '"lint"\s*:\s*"\K[^"]+' package.json 2>/dev/null | tr -d ';|&$`')
    fi

    # Prepend package manager if command exists
    [ -n "$TEST_CMD" ] && TEST_CMD="$PKG_MGR test"
    [ -n "$LINT_CMD" ] && LINT_CMD="$PKG_MGR run lint"
    [ -n "$TYPECHECK_CMD" ] && TYPECHECK_CMD="$PKG_MGR run typecheck"
    [ -n "$BUILD_CMD" ] && BUILD_CMD="$PKG_MGR run build"
fi

# Python project detection
if [ -f "pyproject.toml" ] || [ -f "requirements.txt" ]; then
    # Check for pytest
    if grep -q "pytest" pyproject.toml 2>/dev/null || grep -q "pytest" requirements.txt 2>/dev/null; then
        TEST_CMD="pytest"
    fi
    # Check for ruff
    if command -v ruff &>/dev/null; then
        LINT_CMD="ruff check ."
    fi
    # Check for pyright or mypy
    if command -v pyright &>/dev/null; then
        TYPECHECK_CMD="pyright"
    elif command -v mypy &>/dev/null; then
        TYPECHECK_CMD="mypy ."
    fi
fi

# Rust project detection
if [ -f "Cargo.toml" ]; then
    TEST_CMD="cargo test"
    LINT_CMD="cargo clippy"
    BUILD_CMD="cargo build"
fi

# Output structured data for template substitution
echo ""
echo "---TOOL_COMMANDS---"
printf 'TEST_COMMAND=%q\n' "$TEST_CMD"
printf 'LINT_COMMAND=%q\n' "$LINT_CMD"
printf 'TYPECHECK_COMMAND=%q\n' "$TYPECHECK_CMD"
printf 'BUILD_COMMAND=%q\n' "$BUILD_CMD"
