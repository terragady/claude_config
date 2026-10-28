---
name: github-pr-description
description: Writes a GitHub pull request title and body in the user's own voice, short and plain, grounded in the branch's actual diff and verification results. Use when opening or updating a PR, writing the `--body` for `gh pr create`, or when asked to write, shorten, or fix a PR description.
---

# PR description

Write it like the user wrote it: short, plain language, readable by someone
who has never seen the repo or the ticket.

## Gather facts first

- `git log <base>..HEAD --oneline` and `git diff <base>...HEAD --stat`, then
  the diff itself
- the ticket or spec, and its acceptance criteria
- the tests, lint, and build results you actually ran

## Title

Follow the repo's commit convention (for example
`feat(dash2): [BW-1234] show the transfer total`). It becomes the squash
commit subject, so keep it to about 70 characters and describe the change, not
the files.

## Body

A rough shape. Vary it when the change needs something else:

1. **What and why.** A couple of sentences.
2. **The tricky bit,** if there is one. A concrete example (before/after, a
   sample input, a short snippet) is worth more than three paragraphs of prose.
3. **How to check it.** Steps a reviewer can follow, plus what you actually ran.

Rules:

- Skip file-by-file walkthroughs, exhaustive bullet lists, internal jargon, and
  empty headings.
- Say what was deliberately left out, when a reviewer would otherwise ask.
- For anything visual, add screenshots when the tooling allows it. Otherwise say
  screenshots are missing rather than describing pixels.
- Only claim verification you actually ran.
- Fill in the repo's `PULL_REQUEST_TEMPLATE.md` if one exists.
- Link the Jira ticket. Use `Closes #N` for GitHub issues.
- No AI attribution line.

Read the body back once as the reviewer would. Cut anything that just restates
the diff.
