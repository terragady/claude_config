---
name: implement
description: Takes a feature or Jira ticket from idea to an open PR (spec, plan, build, verify, review) on its own branch, with confirm gates after the spec and after the plan. Reads the ticket from Jira and reports back when given a key or browse URL.
disable-model-invocation: true
---

# Implement

Spec → plan → branch → build → verify → review → PR. Pause at the spec gate and
the plan gate, where wrong assumptions are cheapest to fix. Ask gate questions
the way the Gates section of CLAUDE.md describes.

## Input

- **Jira key or URL** (`ABC-123`, or `*.atlassian.net/browse/ABC-123`): run
  Phase 0 and Phase 7. The ticket's acceptance criteria become the success
  criteria.
- **"worktree"** in the arguments: do the work in a git worktree. Otherwise
  never create one.
- The rest is the task description. If there is no task and no key, ask what to
  implement.

## Phase 0: Jira intake (key only)

Use the `acli` skill:

1. Read the summary, description, status, and comments. Pull out the acceptance
   criteria.
2. Self-assign the ticket and move it into progress, one transition at a time
   (in BW: `Received` → `Prioritised Issues Development` →
   `In Progress Development`).
3. If the ticket links a Figma frame and Figma tooling is available, pull the
   design.

## Phase 1: Spec

1. **Explore before asking.** Read the code the change touches, look for
   similar features, and list the existing utils, components, and hooks the
   change can reuse.
2. Use the `grilling` skill to settle every open decision. Don't carry an
   assumption past this phase.
3. Write a short spec: objective, success criteria, scope (in and out), what
   gets reused, and the decisions made. A small change gets a few lines.
4. Save it to `spec/<slug>/spec.md`. The slug is the Jira key, or else a short
   kebab-case name. This file is a throwaway and is never committed.
5. **Gate:** Proceed to planning (Recommended) / Revise the spec / Stop here.

## Phase 2: Plan

1. Write ordered tasks as vertical slices, each touching about 5 files or
   fewer. Give each task an acceptance check and the command that verifies it.
2. Save the plan to `spec/<slug>/plan.md`.
3. **Gate:** Proceed to build (Recommended) / Revise the plan / Stop here.

## Phase 3: Branch

Only branch after the plan gate. Never commit to the trunk (the default branch:
`gh repo view --json defaultBranchRef -q .defaultBranchRef.name`).

- **On the trunk:** run `git pull --ff-only`, then branch.
- **On another branch:** ask: Branch off the trunk (Recommended) / Stack on
  `<current>` (only if the work needs that branch's unmerged code) / Stay on
  `<current>` (a follow-up to work already in review).
- **Dirty tree:** confirm before carrying the changes onto the new branch.
- Name the branch `<KEY>-<slug>`, or follow the naming in `git branch -a` if
  it differs.

## Phase 4: Build

Work without gates. For each task:

1. Write a failing test for the behavior. Go through public interfaces, follow
   the existing test patterns, and prefer real implementations over mocks.
2. Make the smallest change that passes it.
3. Run the tests, lint, and types for the area you touched. Track progress in
   the todo list.

Touch only what the plan names, and note unrelated issues instead of fixing
them. Check library APIs against their docs (`doc-lookup` agent) instead of
guessing. For a knotty TypeScript or React problem, ask the `react-ts-consult`
agent. Stop only for a blocking ambiguity or an irreversible action.

## Phase 5: Verify and review

1. Run the full suite, lint, type-check, and build, using the commands in
   AGENTS.md or `package.json`. Check every success criterion. Fix failures at
   the root cause. Name pre-existing failures as pre-existing, with the
   evidence.
2. Run the built-in `code-review` skill on the diff to hunt for bugs, then go
   through the `code-review-and-quality` checklist yourself.
3. Fix every Critical and Required finding, then verify again.

## Phase 6: Commit, push, PR

1. Delete `spec/`. If a hook blocks the delete, confirm the folder is untracked
   and leave it.
2. Stage explicit paths only. Never use `git add -A` or `.`, and never
   `--no-verify`. If a hook fails, fix the cause or ask.
3. Commit using the `commit` skill's format. A fix the task forced on you that
   is unrelated to it gets its own commit.
4. Push, then open the PR with `--base <base>`. Write the body with the
   `github-pr-description` skill.

## Phase 7: Jira report-back (key only)

1. Comment on the ticket with what changed, the PR link, and how it was
   verified. Use plain text, or ADF via `--body-file`; Markdown doesn't render.
2. Move the ticket to `QA Development`, one transition at a time.

## Report

Keep it short:

- what changed, and the decisions made at the gates
- verification results
- review findings and what was fixed
- issues noted but not touched
- branch, base, and PR URL
- the Jira status
