#!/bin/sh
# claude-code-dotfiles — manifest-driven curl installer
# Usage: curl -fsSL https://raw.githubusercontent.com/IFAKA/claude-code-dotfiles/main/install.sh | sh
#
# Env vars:
#   DOTFILES_REPO=owner/repo             (default: IFAKA/claude-code-dotfiles)
#   DOTFILES_VERSION=main|v1.0.0         (default: main)
#   DOTFILES_PROFILE=minimal|hooks|full  (default: full)
set -eu

REPO="${DOTFILES_REPO:-IFAKA/claude-code-dotfiles}"
VERSION="${DOTFILES_VERSION:-main}"
PROFILE="${DOTFILES_PROFILE:-full}"
RAW="https://raw.githubusercontent.com/$REPO/$VERSION"
DOTFILES_DIR="$HOME/.claude/dotfiles"
CLAUDE_DIR="$HOME/.claude"
BACKUP_DIR="$CLAUDE_DIR/backups/dotfiles-$(date +%s)"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
ok()   { printf "${GREEN}✓${NC} %s\n" "$1"; }
warn() { printf "${YELLOW}!${NC} %s\n" "$1"; }
err()  { printf "${RED}✗${NC} %s\n" "$1"; exit 1; }

# ── deps ──────────────────────────────────────────────────────────
command -v curl >/dev/null 2>&1 || err "curl is required"
command -v jq   >/dev/null 2>&1 || err "jq is required: brew install jq"

mkdir -p "$DOTFILES_DIR" "$CLAUDE_DIR" "$BACKUP_DIR"

printf "\nInstalling claude-code-dotfiles\n"
printf "  Repo:    %s @ %s\n" "$REPO" "$VERSION"
printf "  Profile: %s\n" "$PROFILE"
printf "  Files →  %s\n\n" "$DOTFILES_DIR"

# ── fetch manifest ────────────────────────────────────────────────
MANIFEST_FILE="$DOTFILES_DIR/manifest.json"
curl -fsSL "$RAW/manifest.json" -o "$MANIFEST_FILE"
ok "Fetched manifest.json"

# Validate profile exists
jq -e ".profiles[\"$PROFILE\"]" "$MANIFEST_FILE" >/dev/null 2>&1 \
    || err "Unknown profile: $PROFILE. Available: $(jq -r '.profiles | keys | join(", ")' "$MANIFEST_FILE")"

# ── download files for this profile ──────────────────────────────
jq -r ".profiles[\"$PROFILE\"][]" "$MANIFEST_FILE" | while IFS= read -r path; do
    dest="$DOTFILES_DIR/$path"
    mkdir -p "$(dirname "$dest")"
    curl -fsSL "$RAW/$path" -o "$dest"
    ok "Downloaded: $path"
done

# ── set permissions ───────────────────────────────────────────────
jq -r '.executable[]' "$MANIFEST_FILE" | while IFS= read -r f; do
    target="$DOTFILES_DIR/$f"
    [ -f "$target" ] && chmod +x "$target"
done

# ── symlink helper ────────────────────────────────────────────────
link() {
    src="$DOTFILES_DIR/$1"
    dst="$CLAUDE_DIR/$2"
    [ -e "$src" ] || return 0   # skip if not downloaded in this profile
    if [ -L "$dst" ]; then
        current=$(readlink "$dst")
        if [ "$current" = "$src" ]; then ok "Already linked: $2"; return; fi
        warn "Relinking: $2"; rm "$dst"
    elif [ -e "$dst" ]; then
        warn "Backing up: $2"
        cp -r "$dst" "$BACKUP_DIR/"
        rm -rf "$dst"
    fi
    mkdir -p "$(dirname "$dst")"
    ln -s "$src" "$dst"
    ok "Linked: $2 → dotfiles/$1"
}

# ── create symlinks (from manifest) ──────────────────────────────
jq -r '.symlinks | to_entries[] | "\(.key) \(.value)"' "$MANIFEST_FILE" | while IFS=' ' read -r src_rel dst_rel; do
    link "$src_rel" "$dst_rel"
done

# ── patch settings.json ───────────────────────────────────────────
PATCH_TEMPLATE=$(jq -r '.settings_patch // empty' "$MANIFEST_FILE")
if [ -n "${PATCH_TEMPLATE:-}" ]; then
    template_file="$DOTFILES_DIR/$PATCH_TEMPLATE"
    if [ -f "$template_file" ]; then
        settings="$CLAUDE_DIR/settings.json"
        [ -f "$settings" ] && cp "$settings" "$BACKUP_DIR/settings.json"
        existing="{}"
        [ -f "$settings" ] && existing=$(cat "$settings")
        tmp=$(mktemp)
        printf '%s\n' "$existing" > "$tmp"
        merged=$(jq -s '.[0] * .[1] | del(._comment)' "$tmp" "$template_file")
        rm -f "$tmp"
        printf '%s\n' "$merged" > "$settings"
        ok "Patched: settings.json"
    fi
fi

# ── migrate from previous versions ───────────────────────────────
# v0.2.0: context-budget.md and code-review.md moved to skills/
for demoted in "rules/context-budget.md" "rules/code-review.md"; do
    f="$DOTFILES_DIR/$demoted"
    [ -f "$f" ] && rm "$f" && ok "Migrated: removed demoted $demoted"
done

# ── version marker ────────────────────────────────────────────────
jq -r '.version' "$MANIFEST_FILE" > "$CLAUDE_DIR/.dotfiles-version"
printf '  (repo: %s, ref: %s)\n' "$REPO" "$VERSION" >> "$CLAUDE_DIR/.dotfiles-version"
ok "Version: $(head -1 "$CLAUDE_DIR/.dotfiles-version")"

# ── optional extras (skip with DOTFILES_EXTRAS=0) ────────────────
if [ "${DOTFILES_EXTRAS:-1}" = "1" ]; then
    printf "\nSetting up extras...\n"

    # engram — persistent cross-session memory via MCP
    if command -v brew >/dev/null 2>&1; then
        brew install gentleman-programming/tap/engram >/dev/null 2>&1 \
            && ok "Installed engram (memory)" \
            || warn "engram install failed — run: brew install gentleman-programming/tap/engram"
    fi
    if command -v claude >/dev/null 2>&1; then
        claude plugin marketplace add Gentleman-Programming/engram >/dev/null 2>&1 \
        && claude plugin install engram >/dev/null 2>&1 \
        && ok "Registered engram MCP plugin" \
        || warn "engram plugin registration failed — run manually"

        # caveman — output compression + /caveman:compress tool (auto-activates each session)
        claude plugin marketplace add JuliusBrussee/caveman >/dev/null 2>&1 \
        && claude plugin install caveman@caveman >/dev/null 2>&1 \
        && ok "Installed caveman (compression)" \
        || warn "caveman install failed — run manually"
    fi
fi

printf "\nBackup: %s\n" "$BACKUP_DIR"
printf "Done. Restart claude to pick up changes.\n"
