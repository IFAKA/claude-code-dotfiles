#!/usr/bin/env bash
# claude-code-dotfiles — manifest-driven curl installer
# Usage: curl -fsSL https://raw.githubusercontent.com/IFAKA/claude-code-dotfiles/main/install.sh | bash
#
# Env vars:
#   DOTFILES_REPO=owner/repo             (default: IFAKA/claude-code-dotfiles)
#   DOTFILES_VERSION=main|v1.0.0         (default: main)
#   DOTFILES_PROFILE=minimal|hooks|full  (default: full)
set -euo pipefail

REPO="${DOTFILES_REPO:-IFAKA/claude-code-dotfiles}"
VERSION="${DOTFILES_VERSION:-main}"
PROFILE="${DOTFILES_PROFILE:-full}"
RAW="https://raw.githubusercontent.com/$REPO/$VERSION"
DOTFILES_DIR="$HOME/.claude/dotfiles"
CLAUDE_DIR="$HOME/.claude"
BACKUP_DIR="$CLAUDE_DIR/backups/dotfiles-$(date +%s)"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
ok()   { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}!${NC} $1"; }
err()  { echo -e "${RED}✗${NC} $1"; exit 1; }

# ── deps ──────────────────────────────────────────────────────────
command -v curl >/dev/null 2>&1 || err "curl is required"
command -v jq   >/dev/null 2>&1 || err "jq is required: brew install jq"
[[ "${BASH_VERSION%%.*}" -ge 4 ]] || err "bash ≥4 required (macOS: brew install bash)"

mkdir -p "$DOTFILES_DIR" "$CLAUDE_DIR" "$BACKUP_DIR"

echo ""
echo "Installing claude-code-dotfiles"
echo "  Repo:    $REPO @ $VERSION"
echo "  Profile: $PROFILE"
echo "  Files →  $DOTFILES_DIR"
echo ""

# ── fetch manifest ────────────────────────────────────────────────
MANIFEST_FILE="$DOTFILES_DIR/manifest.json"
curl -fsSL "$RAW/manifest.json" -o "$MANIFEST_FILE"
ok "Fetched manifest.json"

# Validate profile exists
jq -e ".profiles[\"$PROFILE\"]" "$MANIFEST_FILE" >/dev/null 2>&1 \
    || err "Unknown profile: $PROFILE. Available: $(jq -r '.profiles | keys | join(", ")' "$MANIFEST_FILE")"

# ── download files for this profile ──────────────────────────────
FILES=$(jq -r ".profiles[\"$PROFILE\"][]" "$MANIFEST_FILE")
for path in $FILES; do
    dest="$DOTFILES_DIR/$path"
    mkdir -p "$(dirname "$dest")"
    curl -fsSL "$RAW/$path" -o "$dest"
    ok "Downloaded: $path"
done

# ── set permissions ───────────────────────────────────────────────
EXECUTABLES=$(jq -r '.executable[]' "$MANIFEST_FILE")
for f in $EXECUTABLES; do
    target="$DOTFILES_DIR/$f"
    [[ -f "$target" ]] && chmod +x "$target"
done

# ── symlink helper ────────────────────────────────────────────────
link() {
    local src="$DOTFILES_DIR/$1"
    local dst="$CLAUDE_DIR/$2"
    [[ -e "$src" ]] || return 0   # skip if not downloaded in this profile
    if [[ -L "$dst" ]]; then
        current=$(readlink "$dst")
        if [[ "$current" == "$src" ]]; then ok "Already linked: $2"; return; fi
        warn "Relinking: $2"; rm "$dst"
    elif [[ -e "$dst" ]]; then
        warn "Backing up: $2"
        cp -r "$dst" "$BACKUP_DIR/"
        rm -rf "$dst"
    fi
    mkdir -p "$(dirname "$dst")"
    ln -s "$src" "$dst"
    ok "Linked: $2 → dotfiles/$1"
}

# ── create symlinks (from manifest) ──────────────────────────────
SYMLINKS=$(jq -r '.symlinks | to_entries[] | "\(.key) \(.value)"' "$MANIFEST_FILE")
while IFS=' ' read -r src_rel dst_rel; do
    link "$src_rel" "$dst_rel"
done <<< "$SYMLINKS"

# ── patch settings.json ───────────────────────────────────────────
PATCH_TEMPLATE=$(jq -r '.settings_patch // empty' "$MANIFEST_FILE")
if [[ -n "${PATCH_TEMPLATE:-}" ]]; then
    template_file="$DOTFILES_DIR/$PATCH_TEMPLATE"
    if [[ -f "$template_file" ]]; then
        settings="$CLAUDE_DIR/settings.json"
        [[ -f "$settings" ]] && cp "$settings" "$BACKUP_DIR/settings.json"
        existing="{}"
        [[ -f "$settings" ]] && existing=$(cat "$settings")
        merged=$(jq -s '.[0] * .[1] | del(._comment)' <(echo "$existing") "$template_file")
        echo "$merged" > "$settings"
        ok "Patched: settings.json"
    fi
fi

# ── version marker ────────────────────────────────────────────────
jq -r '.version' "$MANIFEST_FILE" > "$CLAUDE_DIR/.dotfiles-version"
echo "  (repo: $REPO, ref: $VERSION)" >> "$CLAUDE_DIR/.dotfiles-version"
ok "Version: $(head -1 "$CLAUDE_DIR/.dotfiles-version")"

echo ""
echo "Backup: $BACKUP_DIR"
echo "Done. Restart claude to pick up changes."
