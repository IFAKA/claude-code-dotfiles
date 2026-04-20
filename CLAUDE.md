# Global Claude Code Config

## ⚡️ Token Efficiency (CRITICAL)
- **Grep > Read**: Always search for symbols/patterns before reading whole files.
- **Surgical Reads**: Use `offset`/`limit` or line ranges for files > 100 lines.
- **No Redundancy**: If a fact is in Engram or current context, do not re-fetch.
- **Batching**: Run independent tool calls in parallel.
- **Context > 80%**: Finish the immediate subtask, then `/compact`.

## 📜 Planning & Git
- **Complex Tasks**: Use `TodoWrite` for tasks > 3 steps.
- **Git**: No `--no-verify`. Use descriptive commits. Stage by name, not `git add .`.
- **Minimalism**: Only change what is requested. No unasked refactors.

## 🧠 Engram (Persistent Memory)
Engram is ALWAYS ACTIVE. Use `mem_save`, `mem_search`, `mem_context`.

### Save Proactively:
- Architecture/Design decisions.
- Bug root causes + fixes.
- Non-obvious codebase discoveries.
- User preferences/constraints.

### Session Lifecycle:
- **Start**: `mem_context` (fast) -> `mem_search` if needed.
- **After Compaction**: `mem_session_summary` -> `mem_context` -> Continue.
- **End**: `mem_session_summary` (Goal / Accomplished / Next Steps).

## 🛠 Tooling
- **Dedicated Tools**: Prefer Read/Edit/Grep/Glob over Bash (cat/find).
- **Caveman**: If active, use `/caveman:compress` for large log outputs or test results to keep context lean.
