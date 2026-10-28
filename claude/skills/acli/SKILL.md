---
name: acli
description: Manages Jira from the terminal with the Atlassian CLI `acli`. Use when reading, searching, creating, editing, assigning, commenting on, or transitioning Jira work items, when running JQL, or whenever a Jira key (e.g. ABC-123) or an atlassian.net browse URL appears. Triggers on "acli", "jira", "work item", "transition the ticket", "JQL".
---

# acli: Jira from the terminal

Route every Jira read and write through `acli`. Never WebFetch
`*.atlassian.net`: those URLs return a JavaScript shell with no ticket data. A
browse URL's last path segment is the key. Add `--json` to anything you parse,
and check flags with `acli jira workitem <sub> --help` rather than guessing.

On an auth error, run `acli auth status`, then `acli auth login`. Never print
tokens.

## View and search

```bash
acli jira workitem view ABC-123 --fields summary,description,status,assignee,comment,parent --json
acli jira workitem search --jql "assignee = currentUser() AND statusCategory != Done" --limit 50 --json
acli jira workitem search --jql "project = ABC" --count
```

`--fields '*all'` returns every field. A `-` prefix excludes one
(`'*navigable,-comment'`).

## Create and edit

```bash
acli jira workitem create --project ABC --type Story --summary "..." \
  --description-file desc.json --parent ABC-100 --assignee "@me" --label "a,b" --json
acli jira workitem create --from-json item.json      # --generate-json scaffolds one
acli jira workitem edit --key ABC-123 --summary "..." --yes
acli jira workitem edit --key "ABC-1,ABC-2" --description-file desc.json --yes
```

- Priority can only be set at creation, via `--from-json` with
  `"additionalAttributes": {"priority": {"name": "High"}}`. `edit` has no
  priority flag and rejects `additionalAttributes`.
- `edit` also supports `--assignee`, `--labels`, `--remove-assignee`, and
  `--remove-labels`.
- A failed `create` changes nothing, so fix the input and retry. Never create
  probe tickets.

## Rich text: ADF, not Markdown

`--description`, `--description-file`, `--body`, and `--body-file` accept plain
text or Atlassian Document Format (ADF). Markdown and wiki markup render
literally (`## Heading`, `**bold**`, `h3.`). A one-line plain body is fine.
Anything with structure needs an ADF file:

```json
{ "type": "doc", "version": 1, "content": [
  { "type": "heading", "attrs": { "level": 3 },
    "content": [{ "type": "text", "text": "Details" }] },
  { "type": "paragraph", "content": [
    { "type": "text", "text": "Fixed in " },
    { "type": "text", "text": "getCreditCard", "marks": [{ "type": "code" }] } ] },
  { "type": "bulletList", "content": [
    { "type": "listItem", "content": [
      { "type": "paragraph", "content": [{ "type": "text", "text": "The limit shows on the detail page." }] } ] } ] }
] }
```

These all work: `heading`, `paragraph`, `bulletList`/`listItem`, `codeBlock`,
and the `code`/`strong`/`link` marks. The error "not valid Atlassian Document
Format" never says which node is wrong. The usual cause is a `text` node whose
value is empty or an object (a double-wrapped `{"text": {"text": ...}}`).
Validate with `jq .` before sending.

## Assign, transition, comment

```bash
acli jira workitem assign --key ABC-123 --assignee "@me" --yes
acli jira workitem transition --key ABC-123 --status "In Progress Development" --yes
acli jira workitem comment create --key ABC-123 --body "Shipped in PR #42."
acli jira workitem comment create --key ABC-123 --body-file summary.json
acli jira workitem comment list --key ABC-123 --json
```

**Transitions can't skip states,** and no command lists the allowed ones. A bad
target only returns "No allowed transitions found for given status". Move one
step at a time from the current status. In **BW** the chain is:

`Received` → `Prioritised Issues Development` → `In Progress Development` →
`QA Development` → `Testable` → `Release` → `Closed`

Note the British spelling of *Prioritised*. Plain `"In Progress"` never works
there.

`--yes` skips the prompt on mutating commands. Confirm `delete` and `archive`
with the user first. Other subcommands: `clone`, `link`, `watcher`,
`attachment`, `create-bulk`, plus the `acli jira board|sprint|project|filter`
groups.
