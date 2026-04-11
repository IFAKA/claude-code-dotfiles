#!/bin/sh
# curl -fsSL https://raw.githubusercontent.com/IFAKA/claude-code-dotfiles/main/uninstall.sh | sh
set -eu

DOTFILES_DIR="$HOME/.claude/dotfiles"
CLAUDE_DIR="$HOME/.claude"

echo "Removing claude-code-dotfiles..."

# Use local manifest if available; otherwise hardcode the known targets
if [[ -f "$DOTFILES_DIR/manifest.json" ]]; then
    # Remove symlinks from manifest
    while IFS=' ' read -r _src dst; do
        target="$CLAUDE_DIR/$dst"
        if [[ -L "$target" ]]; then rm "$target"; echo "Removed: $dst"; fi
    done < <(jq -r '.symlinks | to_entries[] | "\(.key) \(.value)"' "$DOTFILES_DIR/manifest.json")

    # Strip dotfiles-managed settings keys
    PATCH=$(jq -r '.settings_patch // empty' "$DOTFILES_DIR/manifest.json")
    if [[ -n "${PATCH:-}" && -f "$CLAUDE_DIR/settings.json" ]]; then
        jq 'del(.env.CLAUDE_AUTOCOMPACT_PCT_OVERRIDE, .env.ENABLE_TOOL_SEARCH, .hooks.PreCompact)' \
            "$CLAUDE_DIR/settings.json" > "$CLAUDE_DIR/settings.json.tmp" \
            && mv "$CLAUDE_DIR/settings.json.tmp" "$CLAUDE_DIR/settings.json"
        echo "Cleaned: settings.json"
    fi
else
    # Fallback: hardcoded known targets
    for t in statusline.sh CLAUDE.md hooks rules skills/context-budget skills/owasp-code-review; do
        [[ -L "$CLAUDE_DIR/$t" ]] && rm "$CLAUDE_DIR/$t" && echo "Removed: $t"
    done
fi

rm -rf "$DOTFILES_DIR"
rm -f "$CLAUDE_DIR/.dotfiles-version"

BACKUP=$(ls -dt "$CLAUDE_DIR/backups/dotfiles-"* 2>/dev/null | head -1 || echo "")
[[ -n "$BACKUP" ]] && echo "" && echo "Last backup: $BACKUP"
echo "Done."
