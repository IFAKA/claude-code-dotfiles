#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
IN_TOKENS=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
OUT_TOKENS=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')

format_num() {
    if [ $1 -ge 1000000 ]; then echo "$(($1/1000000))M"
    elif [ $1 -ge 1000 ]; then echo "$(($1/1000))K"
    else echo "$1"
    fi
}

if [ "$PCT" -lt 50 ]; then COLOR="\033[32m"
elif [ "$PCT" -lt 80 ]; then COLOR="\033[33m"
else COLOR="\033[31m"
fi
RESET="\033[0m"

COMPACT_THRESHOLD="${CLAUDE_AUTOCOMPACT_PCT_OVERRIDE:-85}"
if [ "$PCT" -ge "$COMPACT_THRESHOLD" ] 2>/dev/null; then WARN=" ⚡"; else WARN=""; fi

echo -e "[$MODEL] ${COLOR}◉ ${PCT}%${WARN}${RESET} | $(format_num $IN_TOKENS)↓ $(format_num $OUT_TOKENS)↑"
