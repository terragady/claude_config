#!/usr/bin/env bash
# Report the project's stack, package manager, and which npm scripts exist.
# Run this first so the agent knows what the other scripts will do.
. "$(cd "$(dirname "$0")" && pwd)/_lib.sh"

root="$(repo_root)"
banner "Stack detection for $root"

stacks="$(detect_stacks)"
echo "Ecosystems: ${stacks:-none detected}"

pm="$(detect_pm)"
if [ -n "$pm" ]; then
  echo "JS/TS package manager: $pm"
  echo "npm scripts present:"
  for s in test lint typecheck type-check tsc format format:check build; do
    if has_pkg_script "$s"; then echo "  - $s"; fi
  done
fi

echo
echo "Tip: run scripts/ai/verify-all.sh to run tests + lint + type-check + build."
