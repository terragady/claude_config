#!/usr/bin/env bash
# Run the project's type checker for whatever stack is detected.
. "$(cd "$(dirname "$0")" && pwd)/_lib.sh"

root="$(repo_root)"
banner "Type check"

if [ -f "$root/package.json" ]; then
  if has_pkg_script typecheck; then exec pm_run typecheck "$@"; fi
  if has_pkg_script type-check; then exec pm_run type-check "$@"; fi
  if [ -f "$root/tsconfig.json" ]; then
    pm="$(detect_pm)"
    case "$pm" in
      pnpm) exec pnpm exec tsc --noEmit "$@" ;;
      yarn) exec yarn tsc --noEmit "$@" ;;
      bun)  exec bunx tsc --noEmit "$@" ;;
      *)    exec npx --no-install tsc --noEmit "$@" ;;
    esac
  fi
  skip "no TypeScript / typecheck script found (plain JS project?)"
elif [ -f "$root/go.mod" ]; then
  exec go build ./...   # compilation is the type check
elif [ -f "$root/pyproject.toml" ] || [ -f "$root/requirements.txt" ]; then
  command -v mypy >/dev/null && exec mypy . "$@"
  skip "no type checker found (install mypy, or skip)"
else
  skip "no known type-check command for this project"
fi
