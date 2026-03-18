# Changelog

All notable changes to claude-code-dotfiles are documented here.

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
Versioning follows [Semantic Versioning](https://semver.org/).

---

## [Unreleased]

---

## [0.1.0] — 2026-03-18

### Added
- `manifest.json`: single source of truth for files, profiles, symlinks, permissions
- `install.sh`: manifest-driven installer; supports `DOTFILES_REPO`, `DOTFILES_VERSION`, `DOTFILES_PROFILE` env vars
- `uninstall.sh`: manifest-driven cleanup with settings.json key removal
- `settings.json.template`: patches `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=85`, `ENABLE_TOOL_SEARCH=auto:10`, statusLine, PreCompact hook
- `statusline.sh`: color-coded context % display with `⚡` warning near threshold
- `CLAUDE.md`: global instructions — context budget, git discipline, code discipline, tool preference
- `hooks/pre-compact.sh`: git state snapshot to `.claude/pre-compact-state.md` before compaction
- `hooks/post-tool-use.sh`: no-op stub for community extension
- `rules/context-budget.md`: surgical reading discipline and file loading priority
- `rules/git-safety.md`: never-do list, always-do list, commit message format
- `rules/code-review.md`: security, correctness, minimum change, performance checklists
- `docs/why-each-setting.md`: rationale and evidence for each settings key
- `docs/hook-api.md`: hook stdin JSON schema, exit codes, environment, timeout
- `docs/benchmark-methodology.md`: reproducible 3-run test methodology for settings PRs
- `community/hook-recipes/`: staging area for contributed hooks
- Profiles: `minimal`, `hooks`, `full`
