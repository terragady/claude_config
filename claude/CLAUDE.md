# Global preferences

## Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- Touch only the files the task needs. If the change grows past what was asked,
  stop and say so.
- Before writing a helper, hook, or component, search the codebase and its
  installed libraries for an existing one.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## Installing software
- Never install anything (brew, npm/pnpm/yarn global installs, apt, cask, etc.)
  without asking first and getting explicit confirmation — even for things that
  seem minor or easily reversible (e.g. a font, a CLI tool). Explain what you
  want to install and why, then wait for a yes.

## Git & attribution
- Do NOT add Claude Code attribution. No "🤖 Generated with Claude Code" line in PR
  descriptions, and no "Co-Authored-By: Claude ..." trailer in commit messages. Act as human and in my name.

## GitHub API commands
- For `gh api` creation calls, use `-f` / `-F` for simple fields or `--input` for
  structured JSON and let `gh` infer the request method. Do not specify
  `--method POST` or `-X POST`.
- Quote string values; use `-F` for typed values such as numeric line numbers.
  Reads with fields need `--method GET`; other methods still need explicit flags.
- Keep all user-confirmation gates for remote writes.

## Writing in my name
- PR descriptions, Jira tickets and comments, review replies, and commit bodies
  should read like I wrote them: short, plain language, no AI tone, and
  understandable without the repo or the ticket. No changelog-style lists or
  internal jargon. The PR shape lives in the `github-pr-description` skill.

## Gates (questions about something you printed)
Mid-turn text sometimes gets logged as thinking and never shows on my screen.
Before an `AskUserQuestion` that depends on printed content (spec, plan,
findings):
1. Print the full content, not a summary, and include a unique marker such as
   `[gate-7f3a]`.
2. Run `~/code/claude_config/scripts/text-visible.sh '<marker>'`.
3. On `visible`, ask with `AskUserQuestion`, one decision at a time when the
   workflow calls for it. On `missing`, end the turn with the full content and
   only the line "Reply anything and I'll open the interactive questions."
4. On hosts without `AskUserQuestion` (Copilot CLI), ask in plain text and wait.

## Naming & language
- All code identifiers must be plain English: variables, functions, components,
  file/folder names, types, and translation (e.g. FMS) KEYS.
- Localized text (Norwegian, etc.) belongs ONLY in translation VALUES — never in
  keys, code identifiers, or filenames.
