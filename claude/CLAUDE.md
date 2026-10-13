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

## PR descriptions
- Write like a human (me), not like a changelog generator. Short, plain language,
  readable by someone who has never seen the repo or the ticket.
- Say what the change does and why, plus anything tricky you ran into. Skip the
  file-by-file walkthrough, exhaustive bullet lists, and internal jargon.
- A concrete example (before/after, a sample input, a short snippet) is worth
  more than three paragraphs of prose — include one when it helps.
- Add screenshots for anything visual when the tooling allows it; if it doesn't,
  say so instead of describing every pixel in words.
- Rough shape: a couple of sentences on what/why → an example or note on the
  tricky bit → how to check it. Vary it when the change calls for something else.

## Naming & language
- All code identifiers must be plain English: variables, functions, components,
  file/folder names, types, and translation (e.g. FMS) KEYS.
- Localized text (Norwegian, etc.) belongs ONLY in translation VALUES — never in
  keys, code identifiers, or filenames.
