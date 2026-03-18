# Why Each Setting

Rationale and evidence for every key in `settings.json.template`.

---

## `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=85`

**What it does:** Triggers auto-compaction at 85% context window usage instead of the default (typically 95%+).

**Why 85%:** The last 10-15% of a nearly-full context window degrades in quality — models start losing earlier context, instructions become less reliable, and tool call accuracy drops. Compacting at 85% preserves a clean summary rather than a noisy one made under pressure.

**Evidence:** Anecdotal across multiple long sessions: compacting earlier produces cleaner `pre-compact-state.md` summaries and fewer "I seem to have lost track of..." errors in resumed sessions.

**Trade-off:** Slightly more frequent compactions. Each compaction costs ~1-2K tokens for the summary. Worth it for sessions > 50K tokens.

---

## `ENABLE_TOOL_SEARCH=auto:10`

**What it does:** Enables the deferred tool schema loading feature. Tools not immediately needed are loaded on demand rather than included in every prompt. `auto:10` means tools are auto-fetched when fewer than 10 are currently available.

**Why this matters:** Each tool schema in the system prompt costs tokens. A typical Claude Code session loads 30-50 tool schemas upfront. Many are never used. `ENABLE_TOOL_SEARCH` saves 5-20K tokens per session by deferring rarely-used tool schemas until they're actually needed.

**Evidence:** Tool schema overhead is visible in the `total_input_tokens` in the statusline. Compare a session with `ENABLE_TOOL_SEARCH` vs without on the same task — input token count is measurably lower.

**Trade-off:** Tiny latency when a deferred tool is first requested. Not noticeable in practice.

---

## `statusLine.type=command` → `statusline.sh`

**What it does:** Replaces Claude Code's default status bar with a custom script that shows model name, context window percentage (color-coded), and input/output token counts.

**Why visibility matters:** Without real-time context usage, you don't know when you're approaching the window limit until behavior degrades. With it, you can proactively `/compact` before quality drops.

**Color coding:**
- Green (< 50%): plenty of room
- Yellow (50-79%): moderate usage, continue normally
- Red (≥ 80%): approaching limit, finish current subtask then compact

**`⚡` warning:** Appears when `PCT >= CLAUDE_AUTOCOMPACT_PCT_OVERRIDE`. Signals that auto-compact is about to fire or should be triggered manually.

---

## `hooks.PreCompact` → `pre-compact.sh`

**What it does:** Runs just before Claude Code compacts the context window. Writes a snapshot of git state (status, recent log, branch) to `.claude/pre-compact-state.md` in the project root.

**Why this matters:** After compaction, Claude loses knowledge of in-progress work — uncommitted files, what was being debugged, which branch is active. The snapshot gives the next session (or post-compact context) immediate recovery data.

**Recovery:** After compaction, `CLAUDE.md` instructs Claude to read `pre-compact-state.md` if it exists. This restores ~30% of the context that would otherwise require re-investigation.

**Why it always exits 0:** Pre-compact hooks that exit non-zero can block compaction. This hook must never prevent compaction — even if git fails, the hook exits 0.
