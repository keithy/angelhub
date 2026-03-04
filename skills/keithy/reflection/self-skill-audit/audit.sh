#!/bin/bash
# Self-Verify: Check for leaked secrets in environment
# Run this to detect if sensitive credentials are exposed to this process

echo "🔍 Scanning environment for sensitive variables..."
echo ""

# Patterns that indicate secrets
patterns=("TOKEN" "KEY" "SECRET" "PASSWORD" "API_KEY" "GITHUB" "TELEGRAM" "OPENROUTER" "GEMINI")

found=0
for pattern in "${patterns[@]}"; do
    matches=$(env | grep -iE "${pattern}=" || true)
    if [ -n "$matches" ]; then
        echo "⚠️  FOUND: Variables matching '${pattern}':"
        echo "$matches" | while read -r line; do
            # Redact the value, show only the variable name
            var_name=$(echo "$line" | cut -d= -f1)
            echo "   - $var_name=***REDACTED***"
        done
        echo ""
        found=1
    fi
done

if [ $found -eq 0 ]; then
    echo "✅ PASS: No obvious secrets detected in environment variables."
    echo ""
    echo "Note: This only checks common patterns. Always audit carefully."
else
    echo "❌ FAIL: Secrets detected in environment!"
    echo ""
    echo "This is a SECURITY BUG. The spawning process should filter"
    echo "sensitive environment variables before passing them to AI agents."
    echo ""
    echo "See: /infra/skills/debug-env/SKILL.md for fix instructions."
fi
