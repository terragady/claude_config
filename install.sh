#!/usr/bin/env bash
# Install this config into Claude Code (storecode) by symlinking the skills and
# commands folders into ~/.claude, and making the helper scripts executable.
#
#   ./install.sh            # do it
#   ./install.sh --dry-run  # just print what would happen
#
# Re-running is safe: it refreshes the symlinks. It never overwrites your
# existing ~/.claude/CLAUDE.md or settings.json.

set -euo pipefail

DRY_RUN=0
[ "${1:-}" = "--dry-run" ] && DRY_RUN=1

REPO="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"

say()  { printf '%s\n' "$*"; }
run()  { if [ "$DRY_RUN" = 1 ]; then say "  [dry-run] $*"; else eval "$*"; fi; }

link_dir() {
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
link_dir "$REPO/claude/skills"   "$CLAUDE_DIR/skills"
link_dir "$REPO/claude/commands" "$CLAUDE_DIR/commands"

say ""
say "Making helper scripts executable…"
run "chmod +x '$REPO'/scripts/ai/*.sh"

say ""
say "Done. Next steps:"
say "  1. Restart storecode (or start a new session) so it picks up the new skills/commands."
say "  2. Type /  to see the new commands (/implement, /fix, /commit, /create-jira-ticket, /review-pr, /undraft-pr)."
say "  3. For Jira: install acli (brew install atlassian/acli/acli) and run 'acli auth login'."
say "  4. Read README.md for the full guide."
