---
name: create-jira-ticket
description: Creates a Jira ticket from an idea. Gathers the project, type, parent epic, details, Figma links, and acceptance criteria, writes a short plain-language description for PMs, designers, QA, and developers, confirms the draft, then creates it with acli. Use when asked to "create a Jira ticket", "file a ticket", "raise a story/bug/task", or to turn an idea into a ticket.
---

# Create Jira ticket

Every `acli` call follows the `acli` skill. Never WebFetch `*.atlassian.net`.

## 1. Gather

Use the `grilling` skill to settle the following, looking up whatever Jira or
the code can answer instead of asking:

- **Project and type** (`Task`, `Story`, `Bug`, `Epic`). Confirm them; never
  invent them.
- **Parent epic.** Always set one. Read a sibling ticket's parent if that helps,
  and only leave it out if the user confirms there is no epic.
- **Summary.** One action-oriented line. Draft it from the seed text.
- **Details.** What is changing and why, the outcome, and what is out of scope.
  Stop asking once the what and why are clear.
- **Figma links,** if any. Add the link plus a one-line plain summary of the
  design.
- **Technical notes.** Only for API or backend work, and only a sentence or two
  (which endpoint, what changes).
- **Acceptance criteria.** One line each, written as what the user sees or can
  do.
- **Labels, assignee, priority.** Priority can only be set at creation, via
  `--from-json` with `"additionalAttributes": {"priority": {"name": "High"}}`.

## 2. Draft and confirm

1. Write the description as ADF JSON (see the `acli` skill) to a `mktemp` file,
   with the sections Details, Figma, Technical notes, and Acceptance criteria.
   Leave out empty sections.
2. Keep it short and jargon-free, so a non-engineer can read it end to end.
3. Print the full draft: project, type, parent, summary, the description as it
   will read, and the labels and assignee. Use the Gates section of CLAUDE.md
   for printing before asking.
4. **Gate:** Create the ticket (Recommended) / Edit the draft first / Cancel.
   Never create before the user approves.

## 3. Create and report

```bash
acli jira workitem create --project <P> --type <T> --summary "<S>" \
  --description-file "$desc" --parent <EPIC> [--label a,b] [--assignee @me] --json
```

Use `--from-json` instead when a priority is set. Report the new key and
`https://<site>.atlassian.net/browse/<KEY>`. Then offer to self-assign the
ticket and move it into progress, one transition at a time.
