#!/bin/bash
# Port of the Claude Code statusline in ~/.claude/settings.json.
# Copilot reports AI credits instead of a dollar cost, so that slot shows credits.
input=$(cat)
j() { jq -r "$1 // empty" <<<"$input"; }
m=$(j .model.display_name)
credits=$(j .ai_used.formatted)
ctx=$(j .context_window.used_percentage)
cdir=$(j .workspace.current_dir); [ -n "$cdir" ] || cdir=$(j .cwd)
proj=$cdir
branch=$(git -C "$proj" branch --show-current 2>/dev/null)
projbase=$(basename "$proj" 2>/dev/null)
gitroot=$(git -C "$proj" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)
gitdir=$(git -C "$proj" rev-parse --path-format=absolute --git-dir 2>/dev/null)
inwt=""
[ -n "$gitroot" ] && [ "$gitdir" != "$gitroot" ] && inwt=1
[ -n "$gitroot" ] && proj=$(dirname "$gitroot")
proj=$(basename "$proj" 2>/dev/null)
cdir=$(basename "$cdir" 2>/dev/null)
d="\033[2m"; r="\033[0m"; out=""
add() { [ -n "$out" ] && out="${out} ${d}|${r} $1" || out="$1"; }
[ -n "$m" ] && add "$m"
[ -n "$credits" ] && add "\033[36m${credits} AI${r}"
[ -n "$ctx" ] && add "${d}ctx:${r}\033[33m${ctx}%${r}"
wtbadge=""; [ -n "$inwt" ] && wtbadge="\033[1;34mWT${r} "
[ -n "$proj" ] && add "${wtbadge}${d}proj:${r}${proj}"
jirakey=$(printf "%s" "$branch" | grep -oE "[A-Z][A-Z0-9]+-[0-9]+" | head -1)
branchlabel="$branch"
[ -n "$jirakey" ] && branchlabel="\033]8;;https://storebrand.atlassian.net/browse/${jirakey}\007${branch}\033]8;;\007"
[ -n "$branch" ] && add "\033[38;5;203m${branchlabel}${r}"
[ -n "$cdir" ] && [ "$cdir" != "$proj" ] && [ "$cdir" != "$projbase" ] && add "${d}dir:${r}${cdir}"
printf "%b\n" "$out"
