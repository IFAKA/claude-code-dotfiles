# Hook API Reference

Claude Code hooks are shell commands that run at specific lifecycle events. This document covers the hook interface so you can write your own.

---

## Hook Events

| Event | When it fires | stdin | Blocks operation? |
|-------|--------------|-------|-------------------|
| `PreCompact` | Before context compaction | JSON (see below) | No — exit code ignored |
| `PostToolUse` | After each tool call completes | JSON (see below) | No — exit code ignored |
| `PreToolUse` | Before each tool call | JSON (see below) | Yes — non-zero exit cancels the tool |
| `Stop` | When Claude finishes a turn | JSON (see below) | No |

---

## stdin JSON Schema

All hooks receive a JSON object on stdin. The exact shape varies by event, but the common fields are:

```json
{
  "model": {
    "id": "claude-opus-4-6",
    "display_name": "Claude Opus 4.6"
  },
  "context_window": {
    "total_input_tokens": 45230,
    "total_output_tokens": 8410,
    "used_percentage": 42.3,
    "max_tokens": 200000
  },
  "session_id": "abc123",
  "project_root": "/Users/you/code/myproject"
}
```

### PreCompact additional fields
```json
{
  "trigger": "auto" | "manual",
  "compact_threshold": 85
}
```

### PostToolUse / PreToolUse additional fields
```json
{
  "tool": {
    "name": "Bash",
    "input": { "command": "git status" },
    "result": "..."
  }
}
```

---

## Exit Codes

| Exit code | Meaning |
|-----------|---------|
| `0` | Success — operation proceeds normally |
| Non-zero | Error — **only `PreToolUse` uses this to cancel**; other hooks ignore exit code |

**Important for PreCompact:** Always `exit 0`. A non-zero exit does not reliably block compaction and may cause confusing behavior.

---

## Timeout

Set `"timeout": 15` (seconds) in `settings.json` to cap hook runtime. Default is no timeout. Hooks that hang indefinitely will block Claude Code.

```json
{
  "hooks": {
    "PreCompact": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/pre-compact.sh",
            "timeout": 15
          }
        ]
      }
    ]
  }
}
```

---

## Working Directory

Hooks run with the working directory set to the **project root** (where Claude Code was launched), not `~/.claude/`.

---

## Environment

Hooks inherit the environment of the Claude Code process, including:
- `HOME`, `PATH`, `SHELL`
- Any `env` keys set in `settings.json`
- `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` if set

---

## Writing a Hook

1. Create a script in `~/.claude/hooks/` (or `community/hook-recipes/` for sharing)
2. Make it executable: `chmod +x myhook.sh`
3. Add it to `settings.json` under the appropriate event
4. Test: trigger the event and check the script's side effects

### Minimal hook template

```bash
#!/bin/bash
# Read stdin in case you need fields from it
input=$(cat)

# Parse with jq if needed
# PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0')

# Do your thing
# ...

exit 0
```

---

## Debugging Hooks

Hooks run in the background; stdout is not shown in the Claude Code UI. Use a log file:

```bash
echo "$(date): hook fired" >> /tmp/claude-hook.log
```

Then `tail -f /tmp/claude-hook.log` in a separate terminal while using Claude Code.
