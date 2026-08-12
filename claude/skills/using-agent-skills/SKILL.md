---
name: using-agent-skills
description: Discovers and invokes agent skills. Use when starting a session or when you need to discover which skill applies to the current task. This is the meta-skill that governs how all other skills are discovered and invoked.
---

# Using Agent Skills

## Overview

Agent Skills is a collection of engineering workflow skills organized by
development phase. Each skill encodes a specific process that senior engineers
follow. This meta-skill helps you discover and apply the right skill for your
current task.

This config installs a **curated subset** (adapted from JimmyTranDev/dotfiles and
addyosmani/agent-skills). Only the skills listed in the Quick Reference below are
installed — do not try to load skills that aren't listed here.

## Skill Discovery

When a task arrives, identify the development phase and apply the corresponding
skill:

```
Task arrives
    │
    ├── Don't know what you want yet? ──────→ interview-me
    ├── Have a rough concept, need variants? → idea-refine
    ├── New project / feature / change? ─────→ spec-driven-development
    ├── Have a spec, need tasks? ────────────→ planning-and-task-breakdown
    ├── Implementing code? ──────────────────→ incremental-implementation
    │   ├── Small, low-risk, obvious? ───────→ fast-implementation
    │   └── Need better context loaded? ─────→ context-engineering
    ├── Codify a repeatable step as a script? → prefer-scripts-over-ai-instructions
    ├── Writing / running tests? ────────────→ test-driven-development
    ├── Something broke? ────────────────────→ debugging-and-error-recovery
    ├── Create a well-formed Jira ticket? ───→ create-jira-ticket
    ├── Any Jira read/write (view/search/transition/comment)? → acli
    ├── Reviewing code? ─────────────────────→ code-review-and-quality
    │   ├── Too complex? ────────────────────→ code-simplification
    │   └── Security concerns? ──────────────→ security-and-hardening
    ├── Commit already-staged changes? ──────→ commit
    ├── Committing / branching strategy? ────→ git-workflow-and-versioning
    └── Write a GitHub PR title / body? ─────→ github-pr-description
```

The slash **commands** wire these together into workflows: `/implement` (drive a
feature end-to-end), `/fix` (root-cause a bug), `/commit`, `/create-jira-ticket`,
`/review-pr`, `/undraft-pr`.

## Core Operating Behaviors

These behaviors apply at all times, across all skills. They are non-negotiable.

### 1. Surface Assumptions

Before implementing anything non-trivial, explicitly state your assumptions:

```
ASSUMPTIONS I'M MAKING:
1. [assumption about requirements]
2. [assumption about architecture]
3. [assumption about scope]
→ Correct me now or I'll proceed with these.
```

Don't silently fill in ambiguous requirements. The most common failure mode is
making wrong assumptions and running with them unchecked. Surface uncertainty
early — it's cheaper than rework.

### 2. Manage Confusion Actively

When you encounter inconsistencies, conflicting requirements, or unclear
specifications:

1. **STOP.** Do not proceed with a guess.
2. Name the specific confusion.
3. Present the tradeoff or ask the clarifying question.
4. Wait for resolution before continuing.

**Bad:** Silently picking one interpretation and hoping it's right.
**Good:** "I see X in the spec but Y in the existing code. Which takes precedence?"

### 3. Push Back When Warranted

You are not a yes-machine. When an approach has clear problems:

- Point out the issue directly
- Explain the concrete downside (quantify when possible — "this adds ~200ms
  latency" not "this might be slower")
- Propose an alternative
- Accept the human's decision if they override with full information

Sycophancy is a failure mode. Honest technical disagreement is more valuable than
false agreement.

### 4. Enforce Simplicity

Your natural tendency is to overcomplicate. Actively resist it. Before finishing
any implementation, ask:

- Can this be done in fewer lines?
- Are these abstractions earning their complexity?
- Would a staff engineer look at this and say "why didn't you just..."?

Prefer the boring, obvious solution. Cleverness is expensive.

### 5. Maintain Scope Discipline

Touch only what you're asked to touch. Do NOT:

- Remove comments you don't understand
- "Clean up" code orthogonal to the task
- Refactor adjacent systems as a side effect
- Delete code that seems unused without explicit approval
- Add features not in the spec because they "seem useful"

Your job is surgical precision, not unsolicited renovation.

### 6. Verify, Don't Assume

Every skill includes a verification step. A task is not complete until
verification passes. "Seems right" is never sufficient — there must be evidence
(passing tests, build output, runtime data).

## Failure Modes to Avoid

1. Making wrong assumptions without checking
2. Not managing your own confusion — plowing ahead when lost
3. Not surfacing inconsistencies you notice
4. Not presenting tradeoffs on non-obvious decisions
5. Being sycophantic to approaches with clear problems
6. Overcomplicating code and APIs
7. Modifying code or comments orthogonal to the task
8. Removing things you don't fully understand
9. Building without a spec because "it's obvious"
10. Skipping verification because "it looks right"

## Skill Rules

1. **Check for an applicable skill before starting work.** Skills encode
   processes that prevent common mistakes.
2. **Skills are workflows, not suggestions.** Follow the steps in order. Don't
   skip verification steps.
3. **Multiple skills can apply.** A feature implementation might chain
   `spec-driven-development` → `planning-and-task-breakdown` →
   `incremental-implementation` → `test-driven-development` →
   `code-review-and-quality` → `commit`.
4. **When in doubt, start with a spec.** If the task is non-trivial and there's
   no spec, begin with `spec-driven-development` (or just run `/implement`).

## Quick Reference (installed skills)

| Phase | Skill | One-line summary |
|-------|-------|-----------------|
| Define | interview-me | Surface what the user actually wants before any plan, spec, or code exists |
| Define | idea-refine | Refine ideas through structured divergent and convergent thinking |
| Define | spec-driven-development | Requirements and acceptance criteria before code |
| Define | create-jira-ticket | Interactively gather, confirm, and create a well-formed Jira work item via acli |
| Plan | planning-and-task-breakdown | Decompose into small, verifiable tasks |
| Build | incremental-implementation | Thin vertical slices, test each before expanding |
| Build | fast-implementation | Express lane for small, low-risk, obvious changes |
| Build | context-engineering | Feed the right context at the right time |
| Build | prefer-scripts-over-ai-instructions | Codify a deterministic, repeated step as a committed script |
| Verify | test-driven-development | Failing test first, then make it pass |
| Verify | debugging-and-error-recovery | Reproduce → localize → fix root cause → guard with a test |
| Review | code-review-and-quality | Five-axis review with quality gates |
| Review | code-simplification | Preserve behavior while reducing unnecessary complexity |
| Review | security-and-hardening | OWASP prevention, input validation, least privilege |
| Ship | commit | Conventional commit for already-staged changes |
| Ship | git-workflow-and-versioning | Atomic commits, clean history |
| Ship | github-pr-description | Reviewer-focused GitHub PR title + body, grounded in the diff |
| Ship | acli | Every Jira read/write via the Atlassian CLI (never WebFetch atlassian.net) |
| Meta | using-agent-skills | This file — how skills are discovered and invoked |

To add more skills later (frontend, performance, figma, docs/ADRs, etc.), copy
them from JimmyTranDev/dotfiles or addyosmani/agent-skills into
`claude/skills/<name>/SKILL.md` and add a row here.
