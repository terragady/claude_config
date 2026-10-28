---
name: code-review-and-quality
description: House code-review checklist covering review order, severity labels, and the issues this user flags most (reuse, scope, over-engineering, comments, generated files). Use whenever reviewing a diff: your own change before committing, inside implement and review-pr, or when asked to review local changes. Pair it with the built-in code-review skill, which hunts for bugs.
---

# Code review checklist

## Order

1. **Intent.** Read the ticket, spec, or PR body: what should this change do,
   and what should it leave alone?
2. **Tests.** Check that they test behavior through public interfaces, would
   fail without the change, and cover the edge cases.
3. **Implementation.** Read whole files, not just the hunks, along with the
   callers of anything that changed.
4. **Verification.** Check that tests, lint, and type-check were actually run
   and pass.

## What to look for beyond correctness

- **Reuse.** A new helper, hook, component, or constant that duplicates
  something already in the codebase or in a dependency in `package.json`. This
  is the most common miss. Search before accepting new code.
- **Scope.** Files or behavior the task didn't ask for: drive-by refactors,
  unrelated formatting, a simple fix that touched many files.
- **Over-engineering.** Abstractions with one caller, unrequested config, error
  handling for impossible cases, a multi-file solution where a one-liner would
  do.
- **Comments.** Narrative comments, or comments that restate the code. Keep
  only non-obvious business rules and gotchas.
- **Generated files.** Hand edits to anything a generator owns. Check the
  repo's "Do Not Edit" list.
- **Conventions.** The repo's AGENTS.md / CLAUDE.md rules: naming, folder
  layout, imports, no lint suppressions.
- **Security.** Untrusted input, secrets in code, missing auth checks,
  `dangerouslySetInnerHTML`, unvalidated URLs.
- **Leftovers.** Unused exports, props, types, or translation keys left behind
  by the change.

## Severity

Prefix every finding with a label and anchor it to `path:line`:

- **Critical**: a bug, data loss, or security hole. Blocks merge.
- **Required**: must change before merge (wrong behavior, broken convention,
  missing test).
- **Optional**: worth considering.
- **Nit**: style or taste. Take it or leave it.
- **FYI**: context only, no action needed.

No findings is a valid result. Don't pad a review with nits.
