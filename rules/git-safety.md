# Git Safety Protocol

## Never Do
- `git push --force` to main/master — warn user, full stop
- `--no-verify` — no hook skip unless user explicitly requests
- `--no-gpg-sign` or `-c commit.gpgsign=false` — same rule
- `git add -A` or `git add .` — may stage secrets or large binaries
- `git commit --amend` on published commits — rewrites shared history
- `git reset --hard` without confirming first
- `git checkout -- .` or `git restore .` — destroys uncommitted work

## Always Do
- Stage by name: `git add src/foo.py tests/test_foo.py`
- New commits over amending, unless user asks to amend
- Pre-commit hook fails: fix, re-stage, NEW commit (not --amend)
- Before destructive ops: explain + confirm

## Commit Message Format
- Type prefix: `feat:`, `fix:`, `refactor:`, `docs:`, `test:`, `chore:`
- Subject ≤ 72 chars
- Why not what — diff shows what changed
- HEREDOC format:
  ```bash
  git commit -m "$(cat <<'EOF'
  feat: add pre-compact hook for git state snapshot
  EOF
  )"
  ```

## Branch Safety
- No push to main/master without confirmation
- Flag non-critical PRs during merge freeze
- Rebase feature branches over merge commits (unless repo convention differs)

## Unexpected State
- Unknown files/branches/stash: investigate before overwriting
- Lock files: find holding process, don't delete
- Merge conflicts: resolve, don't discard one side
