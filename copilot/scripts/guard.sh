#!/bin/bash
# PreToolUse hook mirroring the deny/ask rules in ~/.claude/settings.json.
# Copilot's user settings can't hold deny rules, but a hook deny still wins in allow-all mode.
in=$(cat)
decide() { jq -nc --arg d "$1" --arg r "$2" '{permissionDecision:$d,permissionDecisionReason:$r}'; exit 0; }
tool=$(jq -r '.tool_name // empty' <<<"$in")
case "$tool" in
  Read|Edit|Write)
    p=$(jq -r '.tool_input.path // .tool_input.file_path // empty' <<<"$in")
    p=${p/#\~/$HOME}
    case "${p##*/}" in .env|.env.local|.env.production|.envrc) decide deny "Secret env files are off limits";; esac
    case "$p" in "$HOME"/.ssh/*|"$HOME"/.aws/*) decide deny "Credentials folder is off limits";; esac
    if [ "$tool" = Read ]; then
      case "$p" in "$HOME"/.gnupg/*|"$HOME"/.netrc|"$HOME"/.config/gcloud/*) decide deny "Credentials are off limits";; esac
    else
      case "$p" in "$HOME"/.zshrc|"$HOME"/.zshenv|"$HOME"/.zprofile|"$HOME"/Library/LaunchAgents/*) decide deny "Shell startup files and LaunchAgents are off limits";; esac
    fi ;;
  Bash)
    c=$(jq -r '.tool_input.command // empty' <<<"$in")
    case "$c" in
      "rm -rf /"|"rm -rf /*"|"rm -rf ~"|"rm -rf ~/*") decide deny "Refusing to wipe / or home";;
      sudo\ *|crontab\ *|launchctl\ *) decide ask "Needs your confirmation";;
    esac ;;
esac
printf '{}\n'
