#!/usr/bin/env bash
# Custom hook: detect wildcards in gateway configs.
# Install as .git/hooks/pre-push (or wire via lefthook / pre-commit).
# Adjust the grep patterns and the gateway/ path to the actual gateway in use.

WILDCARD_FOUND=$(grep -rE '(handle\s+/\*|path:\s*"/\*"|"path":\s*"/\*"|location\s+/\*)' \
                 gateway/ 2>/dev/null || true)

if [ -n "$WILDCARD_FOUND" ]; then
  echo "❌ Gateway configs contain wildcards (forbidden):"
  echo "$WILDCARD_FOUND"
  echo ""
  echo "See ~/.claude/skills/gateway-hardening/SKILL.md"
  exit 1
fi
