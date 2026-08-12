---
name: prefer-scripts-over-ai-instructions
description: Prefer running committed helper scripts over improvising ad-hoc shell for repeatable, deterministic steps. Use when a step is deterministic, repeated, and verifiable — running the test suite, lint, type-check, build, format check, detecting the package manager, or any multi-command plumbing. Triggers on "run the tests", "lint", "type-check", "build", "verify", "check the project", "which package manager", "prefer a script", "make it reproducible". Keep judgment steps (naming, design, wording, reviewing output) as prose — a script can't decide those.
---

# Prefer Scripts Over AI Instructions

## Overview

A repeatable workflow step can live in two mediums: a **committed script** you
run, or **ad-hoc commands** you re-derive every time. Prose/ad-hoc is flexible
but non-deterministic — you drift between runs and can silently skip a step. A
script runs the same way every time, fails loudly, and is testable. Reach for a
script when a step is deterministic and repeatable; keep prose for judgment.

## This repo ships a helper library

Prefer these over improvising equivalent shell. They live in `scripts/ai/` of the
config repo (`~/code/claude_config/scripts/ai/`) and auto-detect the project's
stack (npm/pnpm/yarn, etc.):

| Script | Use for |
|--------|---------|
| `detect-stack.sh` | Identify the package manager / stack before running anything |
| `run-tests.sh` | Run the project's test suite |
| `lint-check.sh` | Run the linter |
| `type-check.sh` | Run the type checker |
| `format-check.sh` | Check formatting |
| `verify-all.sh` | Run tests + lint + type-check + build together (the pre-commit gate) |

When verifying a change, prefer `scripts/ai/verify-all.sh`. If a script doesn't
fit the project (different stack, custom commands), fall back to the project's own
commands — and consider adding/adjusting a script so next time is deterministic.

## When to make something a script

Ask in order; the first "no" ends at the medium it names:

```
A workflow step
   │
   ├─ Deterministic? (same inputs → same steps, no judgment) ─ no ─→ INSTRUCTION
   │        │ yes
   ├─ Repeats / runs more than once? ────────────────────────── no ─→ INSTRUCTION (one-off)
   │        │ yes
   ├─ Verifiable? (exit code, diff, parseable output) ───────── no ─→ INSTRUCTION + a check
   │        │ yes
   ├─ More than a single trivial command? ──────────────────── no ─→ INLINE COMMAND
   │        │ yes
   └──────────────────────────────────────────────────────────────→ SCRIPT (commit it, run it)
```

**Make it a script:** parsing/reshaping JSON/CSV, `jq`/`sed` pipelines, strict
multi-step sequences, idempotent setup / environment probing, anything you'd
otherwise write as brittle "do X, copy the id, paste into Y" prose, or a procedure
duplicated across workflows.

**Keep it prose:** decisions needing judgment (naming, wording, architecture,
prioritization), interpreting output, genuinely one-off actions, and the thin glue
that says *when* and *why* to run a script.

## Verification

- [ ] Deterministic, repeated, verifiable steps run a committed script (or a
  single inline command), not multi-line brittle prose.
- [ ] Judgment/taste/one-off steps stay instructions.
- [ ] When a project's stack didn't fit a helper script, you said so rather than
  silently improvising something unrepeatable.
