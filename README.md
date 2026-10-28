# claude_config

My personal Claude Code (and GitHub Copilot CLI) setup: global instructions, a
small set of skills, and a few subagents. `install.sh` symlinks them into
`~/.claude` (and `~/.copilot` if it exists), so editing them here is editing the
live config.

```bash
./install.sh --dry-run   # show what it would do
./install.sh             # link skills/, commands/, agents/ and CLAUDE.md
```

`settings.json` is left alone. It's machine-specific and managed elsewhere.

## Skills

Typed by me (`disable-model-invocation`, so they never fire on their own):

| Skill | Does |
|---|---|
| `/implement <task or KEY>` | Spec → plan → branch → build → verify → review → PR, with gates after the spec and the plan. Add `worktree` to work in a worktree. |
| `/review-pr <PR>` | A fresh subagent reviews the PR. Findings are walked one by one, then posted as one batched review. |
| `/address-review [PR]` | Judges each review comment on my PR. Walks fix / reply / skip, applies the fixes, then replies and resolves. |

Typed or picked up automatically:

| Skill | Does |
|---|---|
| `fix` | Reproduce → regression test → root-cause fix → full verify. |
| `commit` | Commits the staged changes in the repo's convention. Pushes on "and push". |
| `github-pr-description` | Short, human PR title and body. |
| `create-jira-ticket` | Gathers, drafts, and confirms a plain-language ticket, then creates it via `acli`. |
| `grilling` | Interviews in rounds until no decision is left assumed. Used by `implement` and `create-jira-ticket`. |
| `code-review-and-quality` | The house review checklist and severity labels. Used by `implement` and `review-pr`, alongside the built-in `code-review`. |
| `acli` | Atlassian CLI reference: ADF bodies, transitions, the BW workflow. |

Built-ins cover the rest: `/code-review`, `/simplify`, `/security-review`.

## Agents

| Agent | Model | For |
|---|---|---|
| `search` | haiku | Cheap code search fan-out |
| `search-deep` | sonnet | Ambiguous, multi-step code searches |
| `doc-lookup` | sonnet | Docs, pricing, and external references |
| `react-ts-consult` | sonnet | A second opinion on knotty TypeScript or React problems |

## Scripts

`scripts/text-visible.sh <marker>` checks whether text printed mid-turn reached
the session log as a real text block. Claude Code sometimes stores it as
thinking, and then I never see it. CLAUDE.md's Gates section runs it before any
question that depends on printed content.

## Writing skills here

- Keep them short. Write only what the model wouldn't do by default, and keep
  each rule in one place.
- A rule that must always hold belongs in settings (permissions or hooks), not
  prose.
- Workflows with side effects get `disable-model-invocation: true`.
- `AskUserQuestion` is Claude Code only. CLAUDE.md's Gates section covers the
  plain-text fallback for Copilot CLI.

See [`ATTRIBUTION.md`](./ATTRIBUTION.md) for sources and licenses.
