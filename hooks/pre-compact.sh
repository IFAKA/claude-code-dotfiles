#!/bin/bash
# PreCompact hook — always exits 0, never blocks compaction
set -uo pipefail

if ! git rev-parse --git-dir >/dev/null 2>&1; then exit 0; fi

PROJECT_ROOT=$(git rev-parse --show-toplevel)
mkdir -p "$PROJECT_ROOT/.claude"

{
    echo "# Pre-Compact State — $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
    echo ""
    echo "## Git Status"
    echo '```'
    git -C "$PROJECT_ROOT" status --short 2>/dev/null | head -20 || echo "(clean)"
    echo '```'
    echo "## Recent Commits"
    echo '```'
    git -C "$PROJECT_ROOT" log --oneline -5 2>/dev/null || echo "(none)"
    echo '```'
    echo "## Branch"
    echo '```'
    git -C "$PROJECT_ROOT" branch --show-current 2>/dev/null || echo "(detached)"
    echo '```'
} > "$PROJECT_ROOT/.claude/pre-compact-state.md"

exit 0
