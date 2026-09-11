# claude_config

My personal configuration for **Claude Code** and **GitHub Copilot CLI**: a
curated set of *skills* and *helper scripts*, adapted from
[JimmyTranDev/dotfiles](https://github.com/JimmyTranDev/dotfiles) and
[addyosmani/agent-skills](https://github.com/addyosmani/agent-skills).

Everything lives in this repo and is symlinked into `~/.claude` (and `~/.copilot`
if it exists) by `install.sh`, so it's version-controlled and reproducible.
Workflows are written as **skills**, not slash commands, because `SKILL.md` is an
open format both agents read — one file, two hosts.

---

## Contents

- [Quick start](#quick-start)
- [Background: where does config live?](#background)
- [Skills vs subagents (and why no commands)](#skills-vs-subagents)
- [How do I invoke them?](#how-do-i-invoke-them)
- [The daily workflow: how to work a feature](#the-daily-workflow)
- [Jira setup (and the "should I remove the Jira MCP?" question)](#jira-setup)
- [What's installed](#whats-installed)
- [The `scripts/ai/` helper library](#the-scriptsai-helper-library)
- [How to add more skills later](#how-to-add-more)
- [FAQ](#faq)

---

## Quick start

```bash
cd ~/code/claude_config
./install.sh --dry-run     # see what it will do
./install.sh               # symlink skills/ agents/ CLAUDE.md into ~/.claude (+ ~/.copilot)
```

Then **restart Claude Code** (start a new session) and type `/` — you should see
`/implement`, `/fix`, `/commit`, `/create-jira-ticket`, `/review-pr`,
`/undraft-pr`. In Copilot CLI the same skills are there: `/skills list`, and
`/skills reload` after you edit one.

For Jira, also install the Atlassian CLI once:

```bash
brew install atlassian/acli/acli
acli auth login
```

---

## Background

- **Your editable config lives in `~/.claude/`** — this is where `CLAUDE.md`,
  `settings.json`, and (after install) `skills/`, `commands/` and `agents/` live.
  `commands/` is installed but empty: every workflow here is a skill instead
  (see [below](#skills-vs-subagents)).
- Everything except `settings.json` is a symlink back into this repo, so editing
  `~/.claude/CLAUDE.md` edits `claude/CLAUDE.md` here and shows up in `git diff`.
  `settings.json` is deliberately left out: it's machine- and workplace-specific
  (auth, model routing, hooks) and is often rewritten by the managed
  distribution's own tooling.
- Some workplaces ship Claude Code as a **managed distribution**: the same binary
  under the hood, wrapped in its own directory with a governance layer (an MCP
  allow/deny list, a policy engine). If that's your setup, the managed directory
  is *not* where your skills go — `~/.claude/` still is.
- Where MCP servers are governed by an allow/deny list they may simply be
  unavailable. That's a big reason this config uses a **CLI for Jira** (`acli`)
  instead of an MCP server — see [Jira setup](#jira-setup).

Config resolution order (highest wins): enterprise-managed → **personal
(`~/.claude`)** → project (`.claude/` in a repo). This repo installs at the
**personal** level, so it applies in every project.

---

## Skills vs subagents

Two different things. Neither is "better" — they solve different problems.

| | **Skill** | **Subagent** |
|---|---|---|
| What | Reusable knowledge / procedure | A separate worker with its own context window |
| Lives in | `~/.claude/skills/<name>/SKILL.md` | `~/.claude/agents/<name>.md` |
| Runs | Inline, in your current conversation | In an isolated context; returns only a summary |
| Invoked | Auto (by description match) or `/name` | Auto-delegated, or `@agent-name`, or `--agent` |
| Best for | Checklists, conventions, workflows | Big/noisy side-work, parallel work, tool restriction |
| Portable to Copilot CLI | **Yes** | No (Copilot has its own custom-agent format) |

A **subagent** is for work that would flood your context (search 100 files, run
the whole suite) or needs its own tool limits. This config ships **no custom
subagents** — the built-in ones (Explore, Plan, general-purpose) are enough to
start.

### Why there are no slash commands here

Claude Code used to keep `commands/*.md` and `skills/<name>/SKILL.md` separate;
they have since largely merged — both create a `/name` entry point. Skills win on
two counts, so everything here is a skill and `claude/commands/` is empty:

- **Portability.** Copilot CLI (and VS Code, and other hosts) read `SKILL.md` from
  `~/.claude/skills`, `~/.copilot/skills`, `.github/skills`, or `.agents/skills`.
  Nothing reads `~/.claude/commands`. A command is Claude-Code-only by
  construction.
- **Auto-triggering.** A skill's `description` lets the agent load it on its own
  when your plain-language request matches. A command only ever fires when you
  type it.

Two things to keep in mind when writing one:

- **Arguments.** `$ARGUMENTS` is a command-only substitution and is *not* expanded
  in a `SKILL.md`. Write the input section in prose instead — "the PR is whatever
  was passed with the invocation" — which works for both `/review-pr 123` and
  *"review PR 123"*.
- **Host-specific tools.** `AskUserQuestion` exists in Claude Code but not in
  Copilot CLI. Name it with a fallback ("use `AskUserQuestion` when available,
  otherwise ask in plain text") so the better UI is used where it exists and the
  skill degrades cleanly where it doesn't. The interactive skills here all carry
  an *Asking the user* section that says exactly this.

---

## How do I invoke them?

Three ways — mostly it's **automatic**:

1. **Automatic (the main way).** Claude reads every skill's `description` and
   loads the matching one when your request fits. This is why descriptions are
   long and full of trigger phrases. Just say *"commit my changes"* and the
   `commit` skill kicks in.
2. **Slash.** Type `/commit`, `/implement PROJ-1234`, etc. Anything after the
   name is passed through as the skill's input. In Copilot CLI, mention the skill
   with a slash inside your prompt: *"use the /review-pr skill on 123"*.
3. **Explicit.** Say *"use the commit skill"* to force it.

Subagents auto-delegate, or you force one with `@agent-<name>`.

---

## The daily workflow

**How to start a feature — the one command to remember is `/implement`.**

```
/implement PROJ-1234
```

(or `/implement add a CSV export button to the reports page` if there's no ticket)

It drives the whole lifecycle, pausing at the cheap decision points:

1. **Jira intake** (if you gave a key) — reads the ticket via `acli`, self-assigns
   it, moves it to *In Progress*, and turns its acceptance criteria into the spec.
2. **Spec** → writes a short spec, asks open questions, then a **go/no-go**.
3. **Plan** → breaks it into small ordered tasks, then a **go/no-go**.
4. **Build** → implements slice by slice with **TDD**, keeping the tree green.
5. **Verify** → runs the full suite (prefers `scripts/ai/verify-all.sh`) and fixes
   root causes.
6. **Review** → self-reviews with `code-review-and-quality` as if it were someone
   else's PR.
7. **Report back to Jira** → comments a summary and proposes the next transition.

Then you finish up:

```
/commit          # conventional commit of staged changes; Jira key pulled from the branch name
gh pr create     # open the PR (the github-pr-description skill writes a good title + body)
/review-pr 123   # review a PR (yours or a teammate's) and optionally post comments
/undraft-pr      # flip your draft PR to ready when it's done
```

Smaller loops:

- `/fix <bug or failing test>` — reproduce → write a regression test → fix the
  root cause → verify.
- `/create-jira-ticket <idea>` — interactively build a well-formed ticket and
  create it via `acli`.

You don't *have* to type the slash — describing the task in plain language
auto-triggers the right skill. The slash form is just a reliable shortcut.

---

## Jira setup

This config talks to Jira through **`acli`** (Atlassian's official CLI), not an
MCP server.

```bash
brew install atlassian/acli/acli
acli auth login          # authenticate once
acli auth status         # verify
```

Optionally set environment variables Jimmy's flow understands (e.g. in `~/.zshrc`):

```bash
export ORG_NAME="your-site"                  # used to build browse URLs
export ORG_EMAIL="you@example.com"
# set your own default project key in the create-jira-ticket skill
```

### "Should I remove the Jira MCP, or will it pick the CLI itself?"

**There's nothing to remove** — you don't have a Jira MCP configured, and this
config doesn't add one. And Claude doesn't "pick the CLI by luck": the **`acli`
skill contains a hard rule** — *never WebFetch `*.atlassian.net`, always use
`acli`* — which is what forces every Jira read/write through the CLI.

**CLI vs MCP, briefly:** a CLI needs no running server, reuses your terminal auth,
is fully scriptable, and only puts output in context when asked. An MCP server is
better for heavy, autonomous, structured tool use — but where MCP servers are
governed by an allow/deny list, the CLI is the simpler, reliable choice. If a Jira
MCP ever becomes available, you can still keep it off; the skill prefers `acli`.

---

## What's installed

**Skills** (`claude/skills/`), by lifecycle phase. The **workflow** row is the
set you invoke directly (`/implement`, `/fix`, …); the rest are the methodology
skills those load:

| Phase | Skills |
|---|---|
| Workflow | `implement`, `fix`, `review-pr`, `undraft-pr`, `commit`, `create-jira-ticket` |
| Meta | `using-agent-skills` (the router / operating rules) |
| Define | `interview-me`, `idea-refine`, `spec-driven-development`, `create-jira-ticket` |
| Plan | `planning-and-task-breakdown` |
| Build | `incremental-implementation`, `fast-implementation`, `context-engineering`, `prefer-scripts-over-ai-instructions` |
| Verify | `test-driven-development`, `debugging-and-error-recovery` |
| Review | `code-review-and-quality`, `code-simplification`, `security-and-hardening` |
| Ship | `commit`, `git-workflow-and-versioning`, `github-pr-description`, `acli` |

> **Note on overlap with built-ins:** Claude Code already ships `/code-review`,
> `/simplify`, `/verify`, `/deep-research`, and more. Jimmy's
> `code-review-and-quality` / `code-simplification` overlap with those — that's
> fine; use whichever you prefer. These are kept because the `implement` /
> `review-pr` flow references them.

---

## The `scripts/ai/` helper library

Deterministic, repeatable checks live as **committed scripts** the agent runs
instead of improvising shell (the `prefer-scripts-over-ai-instructions` skill
teaches this). They auto-detect the stack (npm/pnpm/yarn, cargo, go, python, jvm):

| Script | Does |
|---|---|
| `detect-stack.sh` | Report stack, package manager, and available npm scripts |
| `run-tests.sh` | Run the test suite |
| `lint-check.sh` | Run the linter |
| `type-check.sh` | Run the type checker (`tsc --noEmit`, etc.) |
| `format-check.sh` | Check formatting (no writes) |
| `verify-all.sh` | Run type-check + lint + format + tests + build; summary + non-zero on failure |

Run them from any project: `bash ~/code/claude_config/scripts/ai/verify-all.sh`.
If a script doesn't fit a project's stack it says so (and exits 0) rather than
guessing. Adjust them to match your team's conventions.

---

## How to add more

The upstream repos have many more skills (frontend, performance, figma→jira, docs
& ADRs, observability, etc.) — left out to keep this understandable. To add one:

```bash
cd ~/code/claude_config
# copy a skill from Jimmy's repo (example: frontend-ui-engineering)
curl -sS -o claude/skills/frontend-ui-engineering/SKILL.md --create-dirs \
  https://raw.githubusercontent.com/JimmyTranDev/dotfiles/main/src/opencode/skills/frontend-ui-engineering/SKILL.md
# add a row to claude/skills/using-agent-skills/SKILL.md's Quick Reference table
```

Because `~/.claude/skills` is a symlink to this repo's `claude/skills`, new files
are picked up on the next session — no re-install needed. Watch for references to
skills you *haven't* installed and trim them (like we did here).

**Good sources for skills:**

- [JimmyTranDev/dotfiles](https://github.com/JimmyTranDev/dotfiles) — a broad,
  Jira-oriented set.
- [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) — the MIT
  upstream lifecycle pack.
- [anthropics/skills](https://github.com/anthropics/skills) and the built-in
  skills that ship with Claude Code.
- The `/plugin` marketplace (if enabled by your policy).

---

## FAQ

**Can I reuse Jimmy's config?** Yes — his skills/commands are plain Markdown and
drop-in compatible with Claude Code. This repo *is* a curated, cleaned reuse of it.

**Do these work in GitHub Copilot CLI?** Yes — that's why they're skills rather
than slash commands. Copilot CLI reads `~/.claude/skills` natively, and
`install.sh` also links `~/.copilot/skills` to the same folder. Use `/skills list`
to see them and `/skills reload` after editing one. Claude-Code-only bits
(`AskUserQuestion`, subagents) are written with a plain-text fallback.

**Can I reuse skills from elsewhere?** Yes — copy a `SKILL.md` into
`claude/skills/<name>/`. No special format beyond `name` + `description`
frontmatter.

**Are agents (subagents) better than skills?** No — different jobs. Skills =
inline reusable knowledge; subagents = isolated workers for noisy/parallel tasks.
Start with skills; reach for subagents when context gets crowded.

**Is the CLI better than an MCP for Jira?** For this setup, yes — see
[Jira setup](#jira-setup).

**How are skills triggered — automatically or manually?** Both. Mostly automatic
(by `description` match); or manually via `/name` or "use the X skill".

**Is this "enough" to start?** Yes — it covers the whole feature lifecycle. Grow
it as real needs appear rather than importing everything up front.

---

See [`ATTRIBUTION.md`](./ATTRIBUTION.md) for licensing/credits.
