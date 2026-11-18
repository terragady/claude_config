#!/bin/bash
# SessionStart hook: share Claude Code's per-project memory with Copilot.
# Claude keys memory by the main repo root (worktrees share it), with every
# non-alphanumeric character in the path replaced by "-".
cwd=$(jq -r '.cwd // empty'); [ -n "$cwd" ] || cwd=$PWD
common=$(git -C "$cwd" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)
root=$cwd; [ -n "$common" ] && root=$(dirname "$common")
dir="$HOME/.claude/projects/$(printf %s "$root" | sed 's/[^a-zA-Z0-9]/-/g')/memory"
index="(empty, no memories saved yet for this project)"
[ -s "$dir/MEMORY.md" ] && index=$(cat "$dir/MEMORY.md")
read -r -d '' ctx <<TXT
# Memory (shared with Claude Code)
You have a persistent file-based memory at \`$dir/\`, shared with Claude Code. Use it instead of any built-in memory tool.
Each memory is one Markdown file holding one fact, with frontmatter:
---
name: <short-kebab-case-slug>
description: <one-line summary, used to decide relevance>
metadata:
  type: user | feedback | project | reference
---
<the fact; for feedback/project add **Why:** and **How to apply:** lines. Link related memories with [[name]].>
After writing a file, add a one-line pointer to \`MEMORY.md\` in that folder: \`- [Title](file.md) — hook\`. MEMORY.md is only the index.
Save who the user is, guidance they give on how to work (corrections and confirmed approaches, with the why), ongoing project context not in the code (absolute dates), and pointers to external resources. Update an existing file instead of duplicating; delete memories that turn out wrong. Don't save what the repo or git history already records.
Read a memory file when its description looks relevant. Memories reflect what was true when written; verify named files or flags still exist before relying on them.

Current MEMORY.md:
$index
TXT
jq -nc --arg c "$ctx" '{additionalContext:$c}'
