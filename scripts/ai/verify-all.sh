#!/usr/bin/env bash
# The pre-commit gate: type-check + lint + format + tests + build.
# Runs every step (doesn't stop at the first failure) and reports a summary,
# exiting non-zero if anything failed. Steps with no command for the stack are
# treated as passed (skipped).
here="$(cd "$(dirname "$0")" && pwd)"
. "$here/_lib.sh"
set +e   # we manage failures ourselves so every step runs

root="$(repo_root)"
declare -a FAILED=()

run_step() {
  local label="$1" script="$2"
  # each child script prints its own banner
  bash "$here/$script"
  if [ $? -ne 0 ]; then FAILED+=("$label"); fi
}

run_step "Type check" type-check.sh
run_step "Lint"       lint-check.sh
run_step "Format"     format-check.sh
run_step "Tests"      run-tests.sh

# Build (JS/TS only; other stacks build as part of test/type-check above)
banner "Build"
if [ -f "$root/package.json" ] && has_pkg_script build; then
  pm_run build || FAILED+=("Build")
else
  echo "  (skip) no build script"
fi

banner "Summary"
if [ ${#FAILED[@]} -eq 0 ]; then
  echo "  ✓ all checks passed"
  exit 0
else
  printf '  ✗ failed: %s\n' "${FAILED[*]}"
  exit 1
fi
