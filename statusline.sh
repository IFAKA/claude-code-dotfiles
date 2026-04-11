#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
WINDOW_SIZE=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
CACHE_CREATE=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')
CACHE_READ=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')

# Use cache tokens as numerator — includes all overhead (system prompt, CLAUDE.md, tools, MCP)
# Deduct 64K output reservation from denominator for accurate effective limit
EFFECTIVE=$(( WINDOW_SIZE - 64000 ))
ACTUAL=$(( CACHE_CREATE + CACHE_READ ))

if [ "$ACTUAL" -gt 0 ]; then
  PCT=$(( ACTUAL * 100 / EFFECTIVE ))
  [ "$PCT" -gt 100 ] && PCT=100
else
  PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
fi

USED_K=$(( ACTUAL / 1000 ))
EFFECTIVE_K=$(( EFFECTIVE / 1000 ))

if [ "$PCT" -lt 50 ]; then COLOR="\033[32m"
elif [ "$PCT" -lt 80 ]; then COLOR="\033[33m"
else COLOR="\033[31m"
fi
RESET="\033[0m"

FILLED=$(( PCT / 10 ))
[ "$FILLED" -gt 10 ] && FILLED=10
BAR=$(printf '%*s' "$FILLED" '' | tr ' ' '█')$(printf '%*s' "$((10 - FILLED))" '' | tr ' ' '░')

COMPACT_THRESHOLD="${CLAUDE_AUTOCOMPACT_PCT_OVERRIDE:-85}"
if [ "$PCT" -ge "$COMPACT_THRESHOLD" ] 2>/dev/null; then WARN=" ⚡"; else WARN=""; fi

CAVEMAN_TEXT=""
CAVEMAN_FLAG="$HOME/.claude/.caveman-active"
if [ -f "$CAVEMAN_FLAG" ]; then
  CAVEMAN_MODE=$(cat "$CAVEMAN_FLAG" 2>/dev/null)
  if [ "$CAVEMAN_MODE" = "full" ] || [ -z "$CAVEMAN_MODE" ]; then
    CAVEMAN_TEXT=" \033[38;5;172m[CAVEMAN]\033[0m"
  else
    CAVEMAN_SUFFIX=$(echo "$CAVEMAN_MODE" | tr '[:lower:]' '[:upper:]')
    CAVEMAN_TEXT=" \033[38;5;172m[CAVEMAN:${CAVEMAN_SUFFIX}]\033[0m"
  fi
fi

echo -e "[$MODEL] ${COLOR}${BAR} ${PCT}% (${USED_K}K/${EFFECTIVE_K}K)${WARN}${RESET}${CAVEMAN_TEXT}"
