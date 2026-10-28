---
name: commit
description: Commits the already-staged changes with a conventional-commit message derived from the diff, and pushes when asked. Use when the user says "commit", "commit my changes", "commit the staged files", or "commit and push". Never stages files itself.
---

# Commit

1. Run `git diff --cached --name-only`. If nothing is staged, say so and stop.
   Never run `git add`, and never pass paths to `git commit`.
2. Read the staged diff with `git diff --cached -- . ':!*.csv'`. Skip CSV
   files; their diffs are noise.
3. **Pick the format.** Use the repo's convention: AGENTS.md / CLAUDE.md,
   commitlint config, or the shape of `git log --oneline -10`. If the repo has
   no convention, use `<type>(<scope>): <KEY> <description>`.
   - Take the Jira key from the branch name (`[A-Z]+-[0-9]+`). Never invent one.
   - Types: `feat`, `fix`, `refactor`, `perf`, `docs`, `style`, `test`,
     `build`, `ci`, `chore`, `revert`. Add `!` for a breaking change.
   - Write the subject in the imperative and describe the change, not the
     files.
   - Add a body only when the "why" isn't obvious. Write it in plain, human
     prose.
   - No emoji and no AI attribution trailers.
4. Decide the type, scope, and description yourself, without asking, then run
   `git commit -m "<message>"`.
5. If the user said "and push" or passed `push`, run `git push`. Use
   `git push -u origin HEAD` when the branch has no upstream.
6. Report the message, the short hash, the files committed, and whether it was
   pushed.
