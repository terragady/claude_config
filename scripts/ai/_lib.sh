#!/usr/bin/env bash
# Shared helpers for the scripts/ai/* library.
# Auto-detects the project stack and package manager so the individual scripts
# (run-tests, lint-check, ...) don't each re-implement detection.
#
# Source this from another script:  . "$(dirname "$0")/_lib.sh"

set -euo pipefail

# --- repo root -------------------------------------------------------------
repo_root() {
  git rev-parse --show-toplevel 2>/dev/null || pwd
}

# --- JS/TS package manager -------------------------------------------------
# Echoes one of: pnpm | yarn | bun | npm  (only meaningful if package.json exists)
detect_pm() {
  local root; root="$(repo_root)"
  if [ -f "$root/pnpm-lock.yaml" ]; then echo pnpm
  elif [ -f "$root/yarn.lock" ]; then echo yarn
  elif [ -f "$root/bun.lockb" ]; then echo bun
  elif [ -f "$root/package-lock.json" ]; then echo npm
  elif [ -f "$root/package.json" ]; then echo npm   # default when a package.json exists but no lockfile
  else echo ""
  fi
}

# True if package.json defines the given npm script.
has_pkg_script() {
  local root name; root="$(repo_root)"; name="$1"
  [ -f "$root/package.json" ] || return 1
  node -e "process.exit(((require('$root/package.json').scripts||{})['$name'])?0:1)" 2>/dev/null
}

# Run an npm script with the detected package manager.
pm_run() {
  local pm name; pm="$(detect_pm)"; name="$1"; shift || true
  case "$pm" in
    pnpm) pnpm run "$name" "$@" ;;
    yarn) yarn "$name" "$@" ;;
    bun)  bun run "$name" "$@" ;;
    *)    npm run "$name" "$@" ;;
  esac
}

# --- high-level stack detection -------------------------------------------
# Echoes a space-separated list of detected ecosystems.
detect_stacks() {
  local root; root="$(repo_root)"; local s=""
  [ -f "$root/package.json" ]      && s="$s node"
  [ -f "$root/Cargo.toml" ]        && s="$s rust"
  [ -f "$root/go.mod" ]            && s="$s go"
  { [ -f "$root/pyproject.toml" ] || [ -f "$root/setup.py" ] || [ -f "$root/requirements.txt" ]; } && s="$s python"
  { [ -f "$root/build.gradle" ] || [ -f "$root/build.gradle.kts" ] || [ -f "$root/pom.xml" ]; } && s="$s jvm"
  echo "${s# }"
}

# Print a short banner so output is self-explanatory in logs.
banner() { printf '\n\033[1m==> %s\033[0m\n' "$*"; }

# Exit 0 with a note when there's genuinely nothing to run (vs. a real failure).
skip() { echo "  (skip) $*"; exit 0; }
