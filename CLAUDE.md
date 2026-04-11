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

## Engram Persistent Memory

You have access to Engram (`mem_save`, `mem_search`, `mem_context`, `mem_get_observation`, `mem_session_summary`). This is ALWAYS ACTIVE — not on-demand.

### Save proactively (no need to ask) after any of:
- Architecture or design decision made
- Bug fix completed (include root cause)
- Non-obvious discovery about the codebase
- Tool/library choice made with tradeoffs
- Pattern or convention established
- User preference or constraint learned
- Configuration change done

Self-check after every task: "Did I decide, fix, or discover something non-obvious? → `mem_save` now."

`mem_save` format:
- **title**: Verb + what (e.g. "Fixed N+1 query in UserList")
- **type**: bugfix | decision | architecture | discovery | pattern | config | preference
- **content**: What / Why / Where / Learned (omit Learned if none)
- **topic_key**: stable key for evolving topics (e.g. `architecture/auth-model`)

### Search memory when:
- User says "remember", "recall", "what did we do", or references past work
- Starting work that might have been done before
- User's first message references a project, feature, or problem → search first, then respond

Search order: `mem_context` first (fast) → `mem_search` if not found → `mem_get_observation` for full content.

### Session close (before saying "done"):
Call `mem_session_summary` with: Goal / Discoveries / Accomplished / Next Steps / Relevant Files.

### After compaction:
1. Call `mem_session_summary` with the compacted summary content
2. Call `mem_context` to recover prior context
3. Then continue

### Context Offloading (keep messages lean):
- File read > ~100 lines → save key facts to Engram, don't keep raw content in messages
- Large tool output (logs, test results > 50 lines) → save summary to Engram
- Before `/compact` → `mem_save` session state: `{project}/session/state`
- After `/compact` → `mem_search("{project}/session/state")` → `mem_get_observation` → continue
- Naming: `{project}/{slug}/{type}` (e.g. `my-app/auth/schema`)
- Save **what you learned**, not raw output — compress facts, not content
