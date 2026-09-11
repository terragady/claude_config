#!/usr/bin/env bash
# Install this config into Claude Code by symlinking the skills, commands and
# agents folders plus CLAUDE.md into ~/.claude, and making the helper scripts
# executable. If ~/.copilot exists, the same skills folder and CLAUDE.md are
# linked into GitHub Copilot CLI too — SKILL.md is a shared open format, so both
# agents read the exact same files.
#
#   ./install.sh            # do it
#   ./install.sh --dry-run  # just print what would happen
#
# Re-running is safe: it refreshes the symlinks. Anything it would replace that
# isn't already a symlink gets moved aside to a .backup.<pid> file first, so an
# existing ~/.claude/CLAUDE.md is never lost. settings.json is left alone.

set -euo pipefail

DRY_RUN=0
[ "${1:-}" = "--dry-run" ] && DRY_RUN=1

REPO="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"

say()  { printf '%s\n' "$*"; }
run()  { if [ "$DRY_RUN" = 1 ]; then say "  [dry-run] $*"; else eval "$*"; fi; }

link() {
  local src="$1" dest="$2"
  if [ -L "$dest" ]; then
    say "• $dest is a symlink → relinking"
    run "rm '$dest'"
  elif [ -e "$dest" ]; then
    local backup="$dest.backup.$$"
    say "• $dest already exists (not a symlink) → backing up to $backup"
    run "mv '$dest' '$backup'"
  else
    say "• $dest → creating symlink"
  fi
  run "ln -s '$src' '$dest'"
}

say "Installing from: $REPO"
say "Into Claude config dir: $CLAUDE_DIR"
[ "$DRY_RUN" = 1 ] && say "(dry run — no changes will be made)"
say ""

run "mkdir -p '$CLAUDE_DIR'"
link "$REPO/claude/skills"    "$CLAUDE_DIR/skills"
link "$REPO/claude/commands"  "$CLAUDE_DIR/commands"
link "$REPO/claude/agents"    "$CLAUDE_DIR/agents"
link "$REPO/claude/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"

COPILOT_DIR="$HOME/.copilot"
if [ -d "$COPILOT_DIR" ]; then
  say ""
  say "GitHub Copilot CLI detected at $COPILOT_DIR — linking the same files:"
  link "$REPO/claude/skills"    "$COPILOT_DIR/skills"
  link "$REPO/claude/CLAUDE.md" "$COPILOT_DIR/copilot-instructions.md"
fi

say ""
say "Making helper scripts executable…"
run "chmod +x '$REPO'/scripts/ai/*.sh"

say ""
say "Done. Next steps:"
say "  1. Restart Claude Code (or start a new session) so it picks up the new skills."
say "  2. Type /  to see them (/implement, /fix, /commit, /create-jira-ticket, /review-pr, /undraft-pr)."
say "  3. For Jira: install acli (brew install atlassian/acli/acli) and run 'acli auth login'."
say "  4. Read README.md for the full guide."
