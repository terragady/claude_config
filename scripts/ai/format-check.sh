#!/usr/bin/env bash
# Check formatting (does not write) for whatever stack is detected.
. "$(cd "$(dirname "$0")" && pwd)/_lib.sh"

root="$(repo_root)"
banner "Format check"

if [ -f "$root/package.json" ]; then
  if has_pkg_script format:check; then exec pm_run format:check "$@"; fi
  if has_pkg_script format; then exec pm_run format "$@"; fi
  if [ -f "$root/.prettierrc" ] || [ -f "$root/.prettierrc.json" ] || [ -f "$root/prettier.config.js" ]; then
    pm="$(detect_pm)"
    case "$pm" in
      pnpm) exec pnpm exec prettier --check . ;;
      yarn) exec yarn prettier --check . ;;
      bun)  exec bunx prettier --check . ;;
      *)    exec npx --no-install prettier --check . ;;
    esac
  fi
  skip "no formatter configured"
elif [ -f "$root/Cargo.toml" ]; then
  exec cargo fmt --check
elif [ -f "$root/go.mod" ]; then
  out="$(gofmt -l .)"; [ -z "$out" ] || { echo "unformatted:"; echo "$out"; exit 1; }
  echo "  ok"
elif [ -f "$root/pyproject.toml" ]; then
  command -v ruff >/dev/null && exec ruff format --check .
  skip "no formatter found"
else
  skip "no known format command for this project"
fi
