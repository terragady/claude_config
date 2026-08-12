---
description: Run a feature or Jira ticket end-to-end in place — spec, plan, build, verify, review — with confirms after the spec and plan; always asks open questions instead of assuming
---

Drive **$ARGUMENTS** from idea to merged-quality code in five phases: **spec →
plan → build → verify → review**, working **in place on the current branch** (no
worktree, no PR). Advance automatically, pausing for a go/no-go after the spec
and after the plan — wrong assumptions caught there are the cheapest to fix.
**Never assume when something is unclear: whenever an open question would change
the spec, plan, or implementation, stop and ask it with the `question` tool
(three concrete proposals, best first) before proceeding — do not silently pick
an interpretation.**

## Modifiers — parse `$ARGUMENTS` first

Read the optional Jira modifier out of `$ARGUMENTS` before anything else;
whatever remains is the task description.

- **Jira key / URL** — a `^[A-Z]+-[0-9]+$` token or a
  `*.atlassian.net/browse/<KEY>` URL (take the key from the URL's last path
  segment) turns on **Jira intake + report-back** (Phase 0 and Phase 6). The
  ticket's acceptance criteria become the spec's success criteria.

If, after stripping the modifier, there is no task description and no Jira key,
ask what to implement before starting.

## Phase 0 — Jira intake (only when a Jira key was passed)

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
   (`figma.com/design/...`) or node id **and** you have a `figma` skill
   installed, use it to pull the design's structure, variables/tokens, and a code
   draft for the relevant frame. No design link (or no figma skill) → skip.

Carry the acceptance criteria (and any design tokens/components) into the spec
as concrete success criteria.

## Phase 1 — Spec

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
you are inferring anything that would change scope or behavior, ask them with the
`question` tool (three concrete proposals each, best first) and fold the answers
in before presenting the spec — never carry an unresolved assumption past this
gate.

**Confirm gate after the spec.** Present the spec + assumptions, then use the
`question` tool with exactly these three options:

- **Proceed to planning (Recommended)** — the spec is right; continue.
- **Revise the spec first** — adjust assumptions/scope, then re-confirm.
- **Stop here** — hand back the spec without planning or building.

Do not start planning until this gate returns "Proceed".

## Phase 2 — Plan

1. Use the `planning-and-task-breakdown` skill and follow it.
2. Break the spec into **ordered, dependency-aware tasks**, each sized S–M (no
   task touching more than ~5 files). Every task gets acceptance criteria and a
   verification step (test / build / manual check). Prefer vertical slices.
3. **Save the plan to `spec/<task-slug>/plan.md`.** Write the task list into the
   **same per-task subfolder** as the spec (reuse the `<task-slug>` chosen in
   Phase 1). Like the spec it is a throwaway working aid, cleared at the finalize
   step before the change lands.

**Resolve open questions first.** If sequencing, scope, or approach still has an
open question, ask it with the `question` tool before presenting the plan — do
not guess.

**Confirm gate after the plan.** Present the task list, then use the `question`
tool with exactly these three options:

- **Proceed to build (Recommended)** — the plan is right; start implementing.
- **Revise the plan first** — re-slice/re-order, then re-confirm.
- **Stop here** — hand back the spec + plan without building.

Do not write implementation code until this gate returns "Proceed".

## Phase 3 — Build (autonomous)

Run without further gates — implement every task to completion:

1. Use `incremental-implementation` and `test-driven-development` and follow
   them. For framework/library specifics, ground decisions in official docs
   (verify APIs before using them rather than guessing).
2. For each task: write the test, implement the smallest slice, run the
   project's tests/build/lint, and keep the tree green before moving on. Use a
   todo list to track task-by-task progress.
3. Touch only what the task requires (scope discipline). Note — don't fix —
   unrelated issues you spot.

**The only reasons to stop the build and ask:** a genuinely blocking ambiguity
that wasn't settled earlier, or an **irreversible / destructive action**
(deleting data, force-push, prod deploy, schema drops, anything moving money or
sending external comms). Otherwise keep going.

## Phase 4 — Verify

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

## Phase 5 — Review

Use `code-review-and-quality` and review the complete change across every axis
(correctness, design, tests, security, readability) as if it were someone
else's PR. Fix anything that wouldn't pass review, then **re-verify** (Phase 4)
after the fixes.

## Phase 6 — Report back to Jira (only when a Jira key was passed)

When the work is complete and verified:

1. Comment a summary on the ticket (what changed, the branch, how it was
   verified):
   ```bash
   acli jira workitem comment create --key <KEY> --body "<summary of work, branch, verification>"
   ```
2. Propose the next transition (e.g. `"In Review"` or `"Done"`) and run it after
   confirming the exact status name from the project's workflow:
   ```bash
   acli jira workitem transition --key <KEY> --status "In Review" --yes
   ```

## Done

**Clear the spec/plan artifacts first.** The spec
(`spec/<task-slug>/spec.md`) and plan (`spec/<task-slug>/plan.md`) were working
aids for the build, not part of the deliverable. Before the change lands, remove
the whole repo-root `spec/` folder — `rm -rf spec/` — so the per-task subfolder
and its spec/plan files are never committed into the change.

Report: the spec summary, any clarifications/confirms and how they were
resolved, the task list with each task's status, the verify results (tests /
build / lint / coverage), the review findings and how they were resolved,
anything noted-but-not-touched, and — for a Jira ticket — the comment posted and
the ticket's resulting status. If the change is ready to land, suggest
committing with the `commit` skill (include the Jira key in the message when
present).
