# Git Safety Protocol

## Never Do
- `git push --force` to main/master — warn the user instead, full stop
- `--no-verify` — never skip hooks unless the user explicitly requests it
- `--no-gpg-sign` or `-c commit.gpgsign=false` — same rule
- `git add -A` or `git add .` — could accidentally stage secrets or large binaries
- `git commit --amend` on published commits — rewrites shared history
- `git reset --hard` without confirming with the user first
- `git checkout -- .` or `git restore .` — destroys uncommitted work

## Always Do
- Stage specific files by name: `git add src/foo.py tests/test_foo.py`
- Create new commits rather than amending, unless the user explicitly asks to amend
- When a pre-commit hook fails: fix the issue, re-stage, create a NEW commit (not --amend)
- Before destructive operations: explain what will happen and ask for confirmation

## Commit Message Format
- Lead with the type: `feat:`, `fix:`, `refactor:`, `docs:`, `test:`, `chore:`
- Keep subject line under 72 characters
- Focus on *why*, not *what* — the diff shows what changed
- Pass via HEREDOC to preserve formatting:
  ```bash
  git commit -m "$(cat <<'EOF'
  feat: add pre-compact hook for git state snapshot
  EOF
  )"
  ```

## Branch Safety
- Never push to main/master directly without confirmation
- Non-critical PRs should be flagged if a merge freeze is active
- Prefer rebasing feature branches over merge commits (unless repo convention differs)

## When You Find Unexpected State
- Unfamiliar files, branches, or stash entries: investigate before overwriting
- Lock files: find the process holding them, don't just delete
- Merge conflicts: resolve them, don't discard one side wholesale
