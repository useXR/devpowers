#!/bin/bash
# Scaffold a new Playwright test file

FEATURE=$1
COMPONENT=$2

if [ -z "$FEATURE" ] || [ -z "$COMPONENT" ]; then
    echo "Usage: scaffold-test.sh <feature> <component>"
    exit 1
fi

cat > "tests/e2e/${COMPONENT}.spec.ts" << 'EOF'
import { test, expect } from '@playwright/test';

test.describe('COMPONENT', () => {
  test('should complete happy path', async ({ page }) => {
    // TODO: Implement from journey map
  });
});
EOF

echo "Created tests/e2e/${COMPONENT}.spec.ts"
