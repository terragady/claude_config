# Global preferences

## Installing software
- Never install anything (brew, npm/pnpm/yarn global installs, apt, cask, etc.)
  without asking first and getting explicit confirmation — even for things that
  seem minor or easily reversible (e.g. a font, a CLI tool). Explain what you
  want to install and why, then wait for a yes.

## Git & attribution
- Do NOT add Claude Code attribution. No "🤖 Generated with Claude Code" line in PR
  descriptions, and no "Co-Authored-By: Claude ..." trailer in commit messages.

## PR descriptions
- Write like a human, not like a changelog generator. Short, plain language,
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
