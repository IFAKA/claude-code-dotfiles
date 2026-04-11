# Global Claude Code Config

## Context Budget
- `Grep` before `Read`; no speculative file reads
- `offset`/`limit` on large files — read only needed section
- Batch independent calls (parallel, not sequential)
- No re-read of files in context this session
- Context > 80%: finish subtask, then /compact

## After Auto-Compact
- `.claude/pre-compact-state.md` present → read immediately
- Contains git state + log from before compaction

## Planning
- Tasks > 3 steps: TodoWrite to track progress
- Plans → `.claude/plans/` (not in chat)
- Check todos before new work: TaskList first

## Git Discipline
- No `--no-verify` or `--no-gpg-sign` unless asked
- No force-push to main/master — warn user instead
- New commits over amending published commits
- Stage by name, not `git add -A`

## Code Discipline
- Only change what was asked — no unrequested refactors or comments
- No error handling for impossible scenarios
- No abstractions for one-off operations

## Tool Preference
- Read/Edit/Grep/Glob over Bash equivalents (cat, grep, find)
- Dedicated tools; Bash only for system commands
