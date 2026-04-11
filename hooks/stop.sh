#!/bin/sh
# claude-code-dotfiles — Stop hook
# Auto-creates .claudeignore in new git projects on session end.
# Runs once per session stop — low overhead.

PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
[ -f "$PROJECT_ROOT/.claudeignore" ] && exit 0
TEMPLATE="$HOME/.claude/dotfiles/.claudeignore.template"
[ -f "$TEMPLATE" ] || exit 0
cp "$TEMPLATE" "$PROJECT_ROOT/.claudeignore"
