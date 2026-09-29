---
name: create-jira-ticket
description: Creates a well-formed Jira work item (ticket) end-to-end from the terminal — interactively gathers the project, type, summary, details, Figma designs, and any technical notes, assembles a short, plain-language description with acceptance criteria, confirms the draft, then creates it via the `acli` skill and reports the new key + browse URL. Descriptions are written for a mixed audience (PMs, designers, QA, developers) — concise and jargon-free, not an engineering spec. Use when asked to "create a Jira ticket", "create a Jira issue", "file a ticket", "open a work item", "raise a Jira task/story/bug/epic", or to turn an idea into a well-structured ticket. Delegates every raw `acli jira workitem` call to the `acli` skill and never WebFetches `*.atlassian.net`; for reading, editing, transitioning, or commenting on existing tickets — or a single create with all fields already known — use the `acli` skill directly.
---

# Create Jira Ticket

## Overview

Creates a well-formed Jira work item by gathering everything a good ticket needs
— the details, the Figma designs, and any relevant technical notes — then
creating it through the `acli` skill. This is the repeatable, interactive
routine for turning an idea into a structured ticket with acceptance criteria;
the low-level `acli jira workitem` surface (flags, auth, JSON output) lives in
the `acli` skill, which this skill delegates to for every Jira read and write.

**Write for whoever opens the ticket, not just the engineer who implements it.**
A PM, designer, or QA person should be able to read the description and
understand what's being asked without decoding jargon or wading through
implementation detail. Default to plain language and the shortest description
that's still clear. Technical specifics (endpoints, payloads, schemas) belong
only in the optional "Technical notes" section, and only when they're actually
needed to scope or verify the work — not as a matter of course.

## When to Use

- The user asks to create, file, open, or raise a Jira ticket, issue, or work
  item (`Task`, `Story`, `Bug`, `Epic`).
- Turning a vague request or idea into a well-structured ticket with concrete,
  testable acceptance criteria.
- Seeding a ticket that will be picked up immediately (self-assigned and moved
  to *In Progress*).

**Do NOT use when:**

- You already know every field and just need one raw `acli jira workitem create`
  call — use the `acli` skill directly.
- Reading, searching, editing, assigning, transitioning, or commenting on
  existing tickets — that is the `acli` skill.
- Confluence or admin work — out of scope.

## Prerequisites

Use the `acli` skill first — it owns every `acli jira
workitem` call. Route all Jira reads and writes through it; never WebFetch an
`*.atlassian.net` URL. If any `acli` command returns an auth error, run `acli
auth status` (and `acli auth login` if needed) before retrying, and never print
tokens or auth output.

The seed input (whatever idea or summary the caller passed in) seeds the summary.
If it is empty, ask what the ticket is about before starting.

## Asking the user

Where this skill says **ask** or names a **confirm gate**, use the
`AskUserQuestion` tool when it is available, with the listed options in the
listed order (best first). On a host without that tool, ask the same question in
plain text and wait for a real answer — never choose on the user's behalf, and
never treat silence as approval.

## Workflow

### Phase 1 — Gather the inputs

Collect the following **in order**. For any decision with discrete options, ask
with 3 concrete proposals (best first); for free-text fields (summary, details),
ask a direct open question and draft a proposal the user can accept or edit.
Never invent a project key or type — confirm them.

1. **Project & type.** Establish the target **project key** and **work item
   type** (`Task`, `Story`, `Bug`, `Epic`). If the project is unknown, list the
   user's recent ones with
   `acli jira workitem search --jql "assignee = currentUser() ORDER BY updated DESC" --fields project --json`
   and offer the top hits.
2. **Summary.** A concise, action-oriented one-liner. Draft one from the seed
   input and let the user refine it.
3. **Details.** The substance of the work in plain language — what's changing,
   why, the desired outcome, and anything explicitly out of scope. A few short
   sentences or bullets, not an essay. Ask follow-ups only until the *what and
   why* is clear — stop there; don't dig for implementation detail the reader
   doesn't need.
4. **Figma designs.** Ask for any Figma links. For each one supplied, fold the
   link and a one-line design summary into the description (if a `figma` skill
   is installed, use it to pull the frame's structure first, but summarize in
   plain terms — don't paste raw design-system values). No link → skip.
5. **Technical notes (optional).** Only raise this if the user brings up
   APIs/backend work or the ticket is clearly that kind of work. If so, capture
   just enough to scope it — which endpoint(s) and what's changing — in a
   sentence or two under a "Technical notes" heading, not a full request/
   response spec. Skip this step entirely for tickets that don't need it (most
   UI, content, or process work won't).
6. **Acceptance criteria.** Turn the details into a short checklist of
   specific, observable outcomes that define "done" — phrased as what the user
   sees or can do, not internal implementation checks. Propose a draft for the
   user to adjust; keep each item to one line.
7. **Metadata.** Always set a **parent epic** (`--parent <KEY>`) — without one
   the ticket sits loose in the project instead of hanging off the epic its
   siblings belong to. If the right epic isn't obvious, read a sibling's
   (`acli jira workitem view <KEY> --fields parent --json`) or ask; only omit it
   when the user confirms the ticket genuinely has no parent. Then offer labels,
   an assignee (`@me` or someone else), and **priority** — note that `acli` can
   only set priority at **creation** time, via `--from-json` with
   `"additionalAttributes": {"priority": {"name": "High"}}`; `edit` has no
   `--priority` flag, so otherwise the user must bump it by hand in the UI.

### Phase 2 — Assemble & confirm the draft

1. Compose the description with clear sections — **Details**, **Figma**,
   **Technical notes**, **Acceptance criteria** (omit any empty section, and
   omit **Technical notes** for most tickets — see step 5). Keep the whole
   description short: prefer a few tight sentences or bullets per section over
   exhaustive prose, and write it so a non-engineer could read it end to end
   without getting lost.
2. **Write it as ADF JSON** (see below) to a `mktemp` path and pass that via
   `--description-file` — never inline `--description`, where multi-line content
   breaks under shell quoting.
3. Show the full draft back to the user — project, type, summary, the
   description as it will read, and any labels/assignee/parent.

#### Description format — ADF, not Markdown

`acli` takes **plain text or Atlassian Document Format**, never Markdown. Hand
it Markdown and it wraps the whole string in one ADF paragraph, so the ticket
renders literal `## Details`, `- item`, and `**bold**`. Build the document
instead:

```json
{
  "type": "doc",
  "version": 1,
  "content": [
    { "type": "heading", "attrs": { "level": 3 },
      "content": [{ "type": "text", "text": "Details" }] },
    { "type": "paragraph",
      "content": [
        { "type": "text", "text": "The advisor cannot see the granted limit on " },
        { "type": "text", "text": "getCreditCard", "marks": [{ "type": "code" }] },
        { "type": "text", "text": "." }
      ] },
    { "type": "heading", "attrs": { "level": 3 },
      "content": [{ "type": "text", "text": "Acceptance criteria" }] },
    { "type": "bulletList", "content": [
      { "type": "listItem", "content": [
        { "type": "paragraph",
          "content": [{ "type": "text", "text": "The limit shows on the detail page." }] }
      ] }
    ] }
  ]
}
```

`heading`, `paragraph`, `bulletList`/`listItem`, `codeBlock`, and the `code` /
`strong` / `link` marks all work. Two things to get right before running the
create:

- **Every `text` node needs a non-empty string `text` field.** A nested
  `{"text": {"text": ...}}` (from double-wrapping a helper) is the usual cause of
  `The field value is not valid Atlassian Document Format (ADF) content` — a
  generic error that never names the bad node. Validate locally first
  (`jq . <file>`, and eyeball that no `text` value is an object or `""`).
- A failed `create` is a **no-op**, so retrying after a fix is safe. Never create
  a throwaway "probe" ticket to test formatting.

**Confirm gate (before creating).** Creating a ticket is an external side effect,
so never auto-create. Ask with exactly these three options:

- **Create the ticket (Recommended)** — the draft is right; create it now.
- **Edit the draft first** — adjust fields, then re-confirm.
- **Cancel** — discard the draft without creating anything.

Do not run the create command until this gate returns "Create".

### Phase 3 — Create & report

1. Create the work item, appending `--label`, `--assignee`, and `--parent` only
   for the metadata the user chose:
   ```bash
   acli jira workitem create --project <KEY> --type <TYPE> --summary "<summary>" \
     --description-file <file> --json
   ```
   Parse the JSON for the new key.
2. Report the created **key** and its **browse URL**
   (`https://<site>.atlassian.net/browse/<KEY>`).
3. Offer to pick it up now — self-assign and move it into progress:
   ```bash
   acli jira workitem assign --key <KEY> --assignee "@me" --yes
   acli jira workitem transition --key <KEY> --status "In Progress" --yes
   ```
   Skip if the user declines. Two workflow facts to expect:
   - **Status names are project-specific.** In **BW** the chain is
     `Received` → `Prioritised Issues Development` → `In Progress Development`
     → `QA Development` → `Testable` → `Release` → `Closed` (note the British
     *s*), so `"In Progress"` is rejected there.
   - **`acli` cannot skip statuses**, and has no flag to list the allowed ones —
     it only reports `No allowed transitions found for given status`. Walk the
     chain **one hop at a time** from the ticket's current status; if a hop is
     rejected, `view` the ticket to read where it actually is.

## Rules

- Delegate every raw `acli jira workitem` call to the `acli` skill; never
  WebFetch an `*.atlassian.net` URL.
- Never invent a project key or work item type — confirm both with the user.
- Never auto-create: pass the confirm gate before running the create command.
- Always set `--parent` unless the user confirms the ticket has no epic.
- Write the description as **ADF JSON** to a temp file and pass
  `--description-file`. Never Markdown, never a multi-line inline
  `--description`.
- Decide priority at creation time (`--from-json`); it cannot be set afterwards.
- Omit empty sections (Figma / Technical notes) from the assembled description.
- Write in plain, concise language for a mixed audience — include technical
  detail only where a section calls for it (see step 5), and only as much as
  is needed to scope or verify the work.
- Never print secrets or sign-in output.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I know the project/type, I'll skip confirming." | Never invent a project key or type — a wrong one files the ticket in the wrong place. Confirm both. |
| "I'll pass the description inline with `--description`." | Multi-line structured content breaks under shell quoting. Write it to a temp file and use `--description-file`. |
| "Markdown headings and bullets will render fine." | `acli` accepts plain text or ADF only. Markdown arrives as one paragraph of literal `##` and `**`. Build the ADF document. |
| "The ADF error will tell me which node is wrong." | It won't — it's generic. Validate the JSON locally and check every `text` node holds a non-empty string. |
| "I'll file a quick test ticket to check the formatting." | A failed create is a no-op, so just fix and retry. Never create probe tickets. |
| "The draft looks right, I'll just create it." | Creating a ticket is an external side effect. Pass the confirm gate first. |
| "I'll WebFetch the atlassian.net URL to check the result." | Those URLs return a JS shell with no data. Use the `acli` skill for every read. |
| "I'll reimplement the `acli` flags here." | The CLI surface lives in the `acli` skill. Delegate to it instead of duplicating. |
| "More technical detail makes the ticket more complete." | Tickets are read by PMs, designers, and QA, not just engineers. Include only what's needed to understand and verify the work; leave deep technical detail out unless the ticket is genuinely API/backend work. |
| "I should keep asking follow-ups until every detail is nailed down." | Stop once the *what and why* is clear. A short, plain description beats an exhaustive one — more follow-ups than needed just slows the user down. |

## Red Flags

- Running `acli jira workitem create` before the confirm gate returns "Create".
- WebFetching an `*.atlassian.net` URL instead of using the `acli` skill.
- Inventing a project key or work item type instead of confirming it.
- Passing a multi-line `--description` inline instead of `--description-file`.
- A description file containing Markdown (`##`, `-`, `**`) instead of an ADF doc.
- Creating without `--parent` because the epic wasn't obvious.
- Retrying a rejected transition with a *later* status instead of the next hop.
- Printing secrets or sign-in output.
- A description full of endpoint/schema detail, jargon, or implementation
  minutiae for a ticket that isn't backend/API work.
- A "Details" section longer than a short paragraph, or acceptance criteria
  that read like code review comments instead of user-visible outcomes.

## Verification

- [ ] The `acli` skill was loaded and every Jira read/write went through it.
- [ ] Project key and work item type were confirmed with the user (not invented).
- [ ] The description was assembled from only non-empty sections, written as valid ADF JSON, and passed via `--description-file`.
- [ ] `--parent` was set (or the user confirmed the ticket has no epic), and priority was settled at creation time.
- [ ] The description is short and plain-language — a non-engineer could read it and understand the ticket.
- [ ] Technical notes were included only where the work genuinely called for them, and kept brief.
- [ ] The confirm gate returned "Create" before the create command ran.
- [ ] The new key and its browse URL were reported.
- [ ] Self-assign + transition to *In Progress* was offered, and run if accepted.
