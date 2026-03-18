# claude-code-dotfiles

Shareable, versioned Claude Code configuration that optimizes your context window. Install in one command — no git clone required. Community contributions improve the config for everyone.

---

## Install

```bash
# Full install (recommended)
curl -fsSL https://raw.githubusercontent.com/IFAKA/claude-code-dotfiles/main/install.sh | sh
```

### Options

```bash
# Minimal: patch settings.json only (no CLAUDE.md, no hooks)
DOTFILES_PROFILE=minimal \
  curl -fsSL https://raw.githubusercontent.com/IFAKA/claude-code-dotfiles/main/install.sh | sh

# Pin to a stable version
DOTFILES_VERSION=v1.0.0 \
  curl -fsSL https://raw.githubusercontent.com/IFAKA/claude-code-dotfiles/main/install.sh | sh

# Use a fork
DOTFILES_REPO=yourname/claude-code-dotfiles \
  curl -fsSL https://raw.githubusercontent.com/yourname/claude-code-dotfiles/main/install.sh | sh
```

**Requirements:** `curl`, `jq`

---

## What Gets Installed

| File | Purpose | minimal | hooks | full |
|------|---------|---------|-------|------|
| `settings.json` patch | Context autocompact, tool search, statusline | ✓ | ✓ | ✓ |
| `hooks/pre-compact.sh` | Git state snapshot before compaction | — | ✓ | ✓ |
| `hooks/post-tool-use.sh` | No-op stub for custom extension | — | ✓ | ✓ |
| `CLAUDE.md` | Global instructions: context budget, git discipline | — | — | ✓ |
| `statusline.sh` | Color-coded context % + token counts | — | — | ✓ |
| `rules/*.md` | `@import`able rule files | — | — | ✓ |

Files install to `~/.claude/dotfiles/` and symlink into `~/.claude/`.

### Settings patched into `~/.claude/settings.json`

| Key | Value | Why |
|-----|-------|-----|
| `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` | `85` | Compact at 85% for cleaner summaries |
| `ENABLE_TOOL_SEARCH` | `auto:10` | Defer unused tool schemas, saves 5-20K tokens/session |
| `statusLine` | `statusline.sh` | Real-time context % visibility |
| `hooks.PreCompact` | `pre-compact.sh` | Git snapshot for post-compact recovery |

See [`docs/why-each-setting.md`](docs/why-each-setting.md) for rationale and evidence.

---

## Update

Re-run the same install command — it's idempotent:

```bash
curl -fsSL https://raw.githubusercontent.com/IFAKA/claude-code-dotfiles/main/install.sh | sh
```

---

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/IFAKA/claude-code-dotfiles/main/uninstall.sh | sh
```

Removes symlinks and dotfiles-managed settings keys. Your original `settings.json` is restored from backup.

---

## How to Contribute

See [CONTRIBUTING.md](CONTRIBUTING.md) for the full guide.

**The key file is `manifest.json`** — it's the single source of truth for what gets installed and in which profile. Adding a new file to the project means:
1. Add the file to the repo
2. Add it to the appropriate profile(s) in `manifest.json`
3. Open a PR — `install.sh` doesn't need to change

---

## What Stays Personal

These are intentionally NOT in this repo:

| Config | Where it lives | Why not here |
|--------|---------------|--------------|
| Project-specific `CLAUDE.md` | Each project repo | Project context is team-specific |
| `settings.local.json` | `~/.claude/settings.local.json` | Machine-specific overrides |
| Ollama model choices | User preference | Varies by hardware |
| MCP server configs | `~/.claude/mcp.json` | Contains credentials and personal endpoints |
| Memory files | `~/.claude/projects/*/memory/` | Personal and project-specific |

---

## Security Note

This installer pipes to bash. Before running:
- Inspect: `curl -fsSL .../install.sh | less`
- Pin a version: `DOTFILES_VERSION=v1.0.0 curl ... | sh`
- Fork and host your own: `DOTFILES_REPO=yourname/claude-code-dotfiles`
