#!/usr/bin/env bash
# Run the project's linter for whatever stack is detected.
. "$(cd "$(dirname "$0")" && pwd)/_lib.sh"

root="$(repo_root)"
banner "Lint"

if [ -f "$root/package.json" ] && has_pkg_script lint; then
  exec pm_run lint "$@"
elif [ -f "$root/Cargo.toml" ]; then
  exec cargo clippy "$@"
elif [ -f "$root/go.mod" ]; then
  command -v golangci-lint >/dev/null && exec golangci-lint run "$@"
  exec go vet ./... "$@"
elif [ -f "$root/pyproject.toml" ] || [ -f "$root/requirements.txt" ]; then
  command -v ruff >/dev/null && exec ruff check . "$@"
  skip "no linter found (install ruff, or add a lint command)"
else
  skip "no known lint command for this project"
fi
