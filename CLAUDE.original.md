# Global Claude Code Config

## Context Budget
- Prefer `Grep` before `Read`; never speculatively read whole files
- Use `offset`/`limit` on large files — read only the needed section
- Batch independent tool calls in one response (parallel, not sequential)
- Do not re-read files already in context this session
- If context > 80%: finish current subtask, then /compact

## After Auto-Compact
- If `.claude/pre-compact-state.md` exists in the project root, read it immediately
- It contains git state and recent log from just before compaction

## Planning
- For tasks > 3 steps: use TodoWrite to track progress
- Write plans to `.claude/plans/` (not in chat)
- Check existing todos before starting new work: TaskList first

## Git Discipline
- Never use `--no-verify` or `--no-gpg-sign` unless explicitly asked
- Never force-push to main/master — warn the user instead
- Prefer new commits over amending published commits
- Stage specific files by name, not `git add -A`

## Code Discipline
- Only change what was asked — no unrequested refactors or comments
- Don't add error handling for impossible scenarios
- Don't create abstractions for one-off operations

## Tool Preference
- Read/Edit/Grep/Glob over Bash equivalents (cat, grep, find)
- Use dedicated tools; reserve Bash for system commands only
