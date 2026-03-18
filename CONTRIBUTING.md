# Contributing

## The Short Version

- **Adding a file**: add to repo + update `manifest.json` profiles → PR. `install.sh` never changes.
- **New hook**: `community/hook-recipes/` first → graduate to `hooks/` after 2+ approvals.
- **Settings change**: requires benchmark data (see [`docs/benchmark-methodology.md`](docs/benchmark-methodology.md)).
- **CLAUDE.md change**: must cite why the rule changes observable Claude behavior.

---

## Adding a New File

1. Add the file to the repo in the appropriate directory
2. Add it to the relevant profile(s) in `manifest.json`:
   ```json
   "full": [
     ...,
     "rules/my-new-rule.md"
   ]
   ```
3. If the file should be executable, add it to `manifest.json`'s `executable` array
4. If the file should be symlinked into `~/.claude/`, add it to `manifest.json`'s `symlinks` map
5. Open a PR — `install.sh` doesn't need to change

## Adding a New Profile

1. Add a profile key to `manifest.json`:
   ```json
   "profiles": {
     ...,
     "my-profile": ["settings.json.template", "hooks/pre-compact.sh"]
   }
   ```
2. Document the profile in README's "What Gets Installed" table
3. Open a PR

## Contributing a Hook

New hooks go through staging before being auto-installed:

1. **Stage**: add your hook to `community/hook-recipes/` with a README explaining what it does
2. **Graduate**: after 2+ approvals and positive feedback, it can move to `hooks/` and be added to a profile in `manifest.json`
3. **Requirements for graduation**:
   - Must always `exit 0` for PreCompact/PostToolUse (never blocks Claude Code)
   - Must handle missing dependencies gracefully
   - Must not write outside `.claude/` or the project root
   - Must include a timeout recommendation

## Changing `settings.json.template`

Any change to the settings template must include:
- Benchmark data using the methodology in [`docs/benchmark-methodology.md`](docs/benchmark-methodology.md)
- ≥ 3 runs baseline and variant
- ≥ 5% improvement in at least one metric
- Zero quality regressions
- A new or updated entry in [`docs/why-each-setting.md`](docs/why-each-setting.md)

## Changing `CLAUDE.md`

Changes to the global `CLAUDE.md` must:
- Cite a specific, observable behavior that the rule changes
- Not contradict instructions already enforced by Claude Code itself
- Be general enough to apply to any project (project-specific rules belong in project-level `CLAUDE.md` files)

## Fork Guidance

Want to maintain your own variant? Fork this repo and install with:

```bash
DOTFILES_REPO=yourname/claude-code-dotfiles \
  curl -fsSL https://raw.githubusercontent.com/yourname/claude-code-dotfiles/main/install.sh | sh
```

Your fork is immediately installable without editing `install.sh`. Share your fork URL in a PR comment if it has interesting experiments that might graduate to core.

## PR Checklist

- [ ] `manifest.json` updated if new files added
- [ ] New executables added to `manifest.json`'s `executable` array
- [ ] New symlink targets added to `manifest.json`'s `symlinks` map
- [ ] `CHANGELOG.md` updated under `[Unreleased]`
- [ ] Benchmark data included (for settings changes)
- [ ] Behavioral citation included (for CLAUDE.md changes)
