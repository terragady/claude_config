#!/usr/bin/env bash
# Run the project's test suite for whatever stack is detected.
# Extra args are forwarded (e.g. scripts/ai/run-tests.sh path/to/file.test.ts).
. "$(cd "$(dirname "$0")" && pwd)/_lib.sh"

root="$(repo_root)"
banner "Tests"

if [ -f "$root/package.json" ] && has_pkg_script test; then
  exec pm_run test "$@"
elif [ -f "$root/Cargo.toml" ]; then
  exec cargo test "$@"
elif [ -f "$root/go.mod" ]; then
  exec go test ./... "$@"
elif [ -f "$root/pyproject.toml" ] || [ -f "$root/setup.py" ] || [ -f "$root/requirements.txt" ]; then
  exec pytest "$@"
elif [ -f "$root/pom.xml" ]; then
  exec mvn test "$@"
elif [ -f "$root/build.gradle" ] || [ -f "$root/build.gradle.kts" ]; then
  exec ./gradlew test "$@"
else
  skip "no known test command for this project — run the project's own tests"
fi
