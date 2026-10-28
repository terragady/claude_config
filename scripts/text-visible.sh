#!/usr/bin/env bash
# Exits 0 once an assistant text block containing MARKER shows up in a recent
# session log. Claude Code sometimes stores mid-turn text as thinking, so it never
# renders; run this before asking a question that depends on printed text.
set -euo pipefail

marker="${1:?usage: text-visible.sh <marker>}"
projects="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/projects"

for _ in 1 2 3 4 5; do
  sleep 3
  while IFS= read -r log; do
    if jq -r --arg m "$marker" '
        select(.type == "assistant") | .message.content[]?
        | select(.type == "text" and (.text | contains($m))) | "hit"' "$log" 2>/dev/null | grep -q hit; then
      echo visible
      exit 0
    fi
  done < <(find "$projects" -name '*.jsonl' -mmin -10 2>/dev/null)
done

echo missing
exit 1
