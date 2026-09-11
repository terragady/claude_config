---
name: implement
description: Drives a feature or Jira ticket end-to-end on its own branch through five phases — spec, plan, build, verify, review — finishing with a pushed branch and an open PR, with confirm gates after the spec and after the plan. Optionally reads the ticket from Jira first and reports back to it at the end when a Jira key or browse URL is passed. Use when asked to "implement X", "build this feature", "work ticket ABC-123", or to take a task from idea to PR. Never assumes on an open question and never commits to the trunk. For fixing a bug use `fix`; for a spec or plan alone use `spec-driven-development` or `planning-and-task-breakdown`.
---

# Implement

## Overview

Takes a task from idea to merged-quality code in five phases — **spec → plan →
build → verify → review** — on a **dedicated branch** cut from the trunk,
finishing with a **pushed branch and an open PR**. Advances automatically,
pausing for a go/no-go after the spec and after the plan: wrong assumptions
caught there are the cheapest to fix.

**Never assume when something is unclear.** Whenever an open question would
change the spec, plan, or implementation, stop and ask it (three concrete
proposals, best first) before proceeding — do not silently pick an
interpretation.

## When to Use

- A feature, change, or Jira ticket needs to go from description to open PR.
- The user wants the full disciplined pass (spec, tests, verification, review),
  not a quick edit.

**Do NOT use when:**

- Fixing a bug or a failing test — use `fix`.
- The user only wants a spec, a plan, or a one-line edit — use
  `spec-driven-development`, `planning-and-task-breakdown`, or just do the edit.
- Speed matters more than the full pass — use `fast-implementation`.

## Input

The task is whatever was passed with the invocation. Read the optional Jira
modifier out of it before anything else; whatever remains is the task
description.

- **Jira key / URL** — a `^[A-Z]+-[0-9]+$` token or a
  `*.atlassian.net/browse/<KEY>` URL (take the key from the URL's last path
  segment) turns on **Jira intake + report-back** (Phase 0 and Phase 7). The
  ticket's acceptance criteria become the spec's success criteria.

If, after stripping the modifier, there is no task description and no Jira key,
ask what to implement before starting.

## Asking the user

Where this skill says **ask** or names a **confirm gate**, use the
`AskUserQuestion` tool when it is available, with the listed options in the
listed order (best first). On a host without that tool, ask the same question in
plain text and wait for a real answer — never choose on the user's behalf, and
never treat silence as approval.

## Workflow

### Phase 0 — Jira intake (only when a Jira key was passed)

1. **Read the ticket.** Use the `acli` skill, then:
   ```bash
   acli jira workitem view <KEY> --fields summary,description,status,assignee,comment --json
   ```
   Summarize the objective and pull the acceptance criteria from the
   description/comments. If auth fails, run `acli auth status` / `acli auth login`.
2. **Pick up the ticket.** Self-assign and move it into progress (reversible,
   expected when starting work):
   ```bash
   acli jira workitem assign --key <KEY> --assignee "@me" --yes
   acli jira workitem transition --key <KEY> --status "In Progress" --yes
   ```
   Status names are workflow-specific — if `"In Progress"` is rejected, `view`
   the ticket, read its current status, and confirm the correct target name.
3. **Pull the design (if any).** If the ticket references a Figma link
   (`figma.com/design/...`) or node id **and** a `figma` skill or MCP server is
   available, use it to pull the design's structure, variables/tokens, and a code
   draft for the relevant frame. No design link (or no figma tooling) → skip.

Carry the acceptance criteria (and any design tokens/components) into the spec
as concrete success criteria.

### Phase 1 — Spec

1. Use the `spec-driven-development` skill and follow it.
2. **Surface assumptions first** — list what you're inferring about scope, stack,
   and behavior before writing spec content.
3. Produce a **concise** spec: objective, success criteria (specific and
   testable), scope/boundaries (always / ask-first / never), and open questions.
   Keep it proportional to the task — a small change gets a few lines, not pages.
   For a Jira key, the **success criteria are the ticket's acceptance criteria**.
4. **Save the spec to `spec/<task-slug>/spec.md`.** Write it to a **per-task
   subfolder** of the repo-root `spec/` folder so it persists as a working aid
   through the build and never collides with a concurrent run. Derive
   `<task-slug>` **once here and reuse it for the plan**: the Jira `<KEY>` when a
   key was passed, otherwise a short kebab-case slug of the task description. It
   is a throwaway artifact, not part of the deliverable: the finalize step clears
   the whole `spec/` folder before the change lands (see **Done** below), so it
   never reaches the base branch or a PR.

**Resolve open questions first.** If the spec still contains open questions or
you are inferring anything that would change scope or behavior, ask them (three
concrete proposals each, best first) and fold the answers in before presenting
the spec — never carry an unresolved assumption past this gate.

**Confirm gate after the spec.** Present the spec + assumptions, then ask with
exactly these three options:

- **Proceed to planning (Recommended)** — the spec is right; continue.
- **Revise the spec first** — adjust assumptions/scope, then re-confirm.
- **Stop here** — hand back the spec without planning or building.

Do not start planning until this gate returns "Proceed".

### Phase 2 — Plan

1. Use the `planning-and-task-breakdown` skill and follow it.
2. Break the spec into **ordered, dependency-aware tasks**, each sized S–M (no
   task touching more than ~5 files). Every task gets acceptance criteria and a
   verification step (test / build / manual check). Prefer vertical slices.
3. **Save the plan to `spec/<task-slug>/plan.md`.** Write the task list into the
   **same per-task subfolder** as the spec (reuse the `<task-slug>` chosen in
   Phase 1). Like the spec it is a throwaway working aid, cleared at the finalize
   step before the change lands.

**Resolve open questions first.** If sequencing, scope, or approach still has an
open question, ask it before presenting the plan — do not guess.

**Confirm gate after the plan.** Present the task list, then ask with exactly
these three options:

- **Proceed to build (Recommended)** — the plan is right; start implementing.
- **Revise the plan first** — re-slice/re-order, then re-confirm.
- **Stop here** — hand back the spec + plan without building.

Do not write implementation code until this gate returns "Proceed".

### Phase 2.5 — Branch

Only once the plan gate returns "Proceed" — a run that stops at the spec or plan
must not leave a stray branch behind. **Never commit directly to the trunk**
(`develop`, or `main`/`master` where that is the default branch).

1. **Identify the trunk** — the repo's default branch, not whatever is checked
   out. `gh repo view --json defaultBranchRef -q .defaultBranchRef.name`, falling
   back to `git symbolic-ref refs/remotes/origin/HEAD`.
2. **Pick the base.**
   - **On the trunk** → pull first (`git pull --ff-only`), then branch from it. No
     question needed.
   - **Not on the trunk** → the current branch is someone's unmerged work, so ask
     before touching anything:
     - **Branch off the trunk (Recommended)** — an independent branch and PR
       targeting the trunk. Default: independent work gets an independent review,
       and nothing has to be rebased if the other branch is reworked.
     - **Stack on `<current-branch>`** — branch from it and target the PR at it.
       Choose this **only when the new work genuinely depends on unmerged code**
       there (it will not compile or cannot be reviewed without it). Warn that a
       squash-merge of the parent will force a rebase; a merge-commit repo is
       safe.
     - **Stay on `<current-branch>`** — no new branch, commit straight onto it.
       For a follow-up fix to work already in review.
   - If the working tree is dirty, say so and confirm the changes should travel
     onto the new branch before creating it.
3. **Create it.** Name it `<KEY>-<kebab-slug>` when a Jira key was passed
   (e.g. `BW-1234-status-transitions`), otherwise a short kebab-case slug of the
   task. Match the naming already visible in `git branch -a` if it differs.

Record the chosen **base branch** — Phase 6 targets the PR at it.

### Phase 3 — Build (autonomous)

Run without further gates — implement every task to completion:

1. Use `incremental-implementation` and `test-driven-development` and follow
   them. For framework/library specifics, ground decisions in official docs
   (verify APIs before using them rather than guessing). When a TypeScript type
   won't resolve or a React pattern is genuinely non-trivial (complex generics,
   cache/mutation shapes, hook/effect correctness) and a `react-ts-consult` agent
   is available, delegate a quick second opinion and apply its recommendation —
   don't burn the main thread spinning on it.
2. For each task: write the test, implement the smallest slice, run the
   project's tests/build/lint, and keep the tree green before moving on. Track
   task-by-task progress in a todo list.
3. Touch only what the task requires (scope discipline). Note — don't fix —
   unrelated issues you spot.

**The only reasons to stop the build and ask:** a genuinely blocking ambiguity
that wasn't settled earlier, or an **irreversible / destructive action**
(deleting data, force-push, prod deploy, schema drops, anything moving money or
sending external comms). Otherwise keep going.

### Phase 4 — Verify

With all tasks built, verify the change as a whole (not just the slices you
touched):

1. Run the **full** suite — tests, build, lint, type-check — and confirm every
   spec success criterion is actually met. Prefer `scripts/ai/verify-all.sh` if
   present.
2. If anything fails or behaves unexpectedly, use `debugging-and-error-recovery`
   and fix the **root cause** (not the symptom), then re-run.
3. Confirm new/changed logic is **meaningfully covered**; if coverage is thin,
   add the missing tests before moving on.
4. For high-stakes, security-sensitive, or irreversible logic, do an adversarial
   self-review pass (assume it's wrong and try to break it) before it stands.

Don't proceed to review until the suite is green.

### Phase 5 — Review

Use `code-review-and-quality` and review the complete change across every axis
(correctness, design, tests, security, readability) as if it were someone
else's PR. For a TypeScript/React-heavy change you may delegate a focused
type-and-pattern correctness pass to the `react-ts-consult` agent alongside the
general review. Fix anything that wouldn't pass review, then **re-verify**
(Phase 4) after the fixes.

### Phase 6 — Commit, push, PR

Only with Phase 4 green and Phase 5's findings resolved.

1. **Clear the throwaway artifacts first** — see **Done** below. They must not be
   in the commit.
2. **Stage explicitly.** Name the paths; never `git add -A`/`--all`/`.`, which
   sweeps in secrets, build output, and other sessions' files. Check
   `git status --short` and leave anything you did not create untracked.
3. **Commit with the hooks intact.** Follow the repo's convention (the `commit`
   skill, `CONTRIBUTING`, or the shape of recent `git log` subjects), and include
   the Jira key when there is one. **Never** reach for `--no-verify`: if a
   pre-commit hook fails, fix the cause, or — when it is blocked on something
   only the human can do — stop and ask how to proceed.
4. **Separate unrelated commits.** Tooling or drive-by fixes that the task forced
   you into get their own commit with an honest scope, not a hiding place inside
   the feature commit.
5. **Push and open the PR** with `--base <base branch from Phase 2.5>`. Write the
   description for a reviewer who has not read the ticket: what changed and why,
   the decisions a reader would otherwise question, what is deliberately *not*
   included, how it was verified, and anything noted-but-not-fixed. Follow the
   repo's PR template if one exists.
6. **Report the PR URL.**

If the user has asked for no PR, stop after the commit and say so.

### Phase 7 — Report back to Jira (only when a Jira key was passed)

When the work is complete, verified, and the PR is open:

1. Comment a summary on the ticket (what changed, the **PR link**, how it was
   verified):
   ```bash
   acli jira workitem comment create --key <KEY> --body "<summary of work, PR link, verification>"
   ```
2. Move the ticket to the review/QA column. Default to **`"QA Development"`** —
   that is the target status in the projects this config is used with. Status
   names are workflow-specific, so if it is rejected, `view` the ticket, read the
   available transitions, and use the exact name from that project's workflow
   (commonly `"In Review"`):
   ```bash
   acli jira workitem transition --key <KEY> --status "QA Development" --yes
   ```

## Rules

- Never assume past an open question — ask, with concrete proposals.
- Never start planning before the spec gate, or coding before the plan gate.
- Never commit to the trunk; every run that builds gets its own branch.
- Never `git add -A` / `.`; stage explicit paths.
- Never `--no-verify`.
- Never leave the `spec/` artifacts in the commit.
- Report honestly: pre-existing failures are named as pre-existing, with
  evidence, not folded into the change's results.

## Red Flags

- A branch created before the plan gate returned "Proceed".
- Implementation code written while the spec still lists an open question.
- `git add -A`, `git commit --no-verify`, or a commit on `develop`/`main`.
- `spec/` files showing up in `git status` at commit time.
- A "green" report where the full suite was never run.
- A PR description that reads like a file-by-file changelog.

## Verification

- [ ] Spec saved to `spec/<task-slug>/spec.md` and its gate returned "Proceed".
- [ ] Plan saved to `spec/<task-slug>/plan.md` and its gate returned "Proceed".
- [ ] Work happened on a dedicated branch, never on the trunk.
- [ ] Every planned task built, with tests written first.
- [ ] Full suite, build, lint, and type-check all green.
- [ ] Review pass done and its findings resolved, then re-verified.
- [ ] `spec/` cleared before the commit; only explicit paths staged.
- [ ] Branch pushed, PR opened against the recorded base, URL reported.
- [ ] For a Jira key: ticket commented and transitioned.

## Done

**Clear the spec/plan artifacts** (Phase 6, step 1). The spec
(`spec/<task-slug>/spec.md`) and plan (`spec/<task-slug>/plan.md`) were working
aids for the build, not part of the deliverable. Before committing, remove the
whole repo-root `spec/` folder so they never reach the branch or the PR. If a
safety hook blocks the delete, do not work around it — the folder is usually
gitignored anyway, so confirm it is untracked, leave it, and say so.

Report: the spec summary, any clarifications/confirms and how they were
resolved, the task list with each task's status, the verify results (tests /
build / lint / coverage), the review findings and how they were resolved,
anything noted-but-not-touched, the **branch, its base, and the PR URL**, and —
for a Jira ticket — the comment posted and the ticket's resulting status.

Be honest in this report. Failures that came from outside the change (another
worktree, a pre-existing lint warning, a flaky suite) get named as such, with the
evidence that they are pre-existing — never folded into the change's own results,
and never quietly fixed to make the numbers look green.
