---
name: grilling
description: Interviews the user in rounds about a plan, design, ticket, or idea until every decision is settled and nothing is silently assumed. Use before building anything non-trivial, when a choice would change scope or behavior, during the spec phase of implement and the intake of create-jira-ticket, or when the user says "grill me", "ask me questions", or "stress-test this".
---

# Grilling

Reach a shared understanding before anything gets built.

1. **Map the open decisions as a tree.** Each decision unlocks the ones that
   hang off it.
2. **Facts are your job, decisions are the user's.** Anything the code, git
   history, Jira, or docs can answer, look up yourself (send a subagent for
   broad searches) instead of asking. When a fact is ambiguous, for example which
   of several fields a ticket means, find every candidate, then ask with each
   one named by product and file.
3. **Ask in rounds.** A round is every decision whose prerequisites are already
   settled: up to 4 questions per `AskUserQuestion` call, recommended option
   first and marked "(Recommended)". A question that depends on an unanswered
   one waits for a later round.
4. **Recompute after each round.** Answers close some branches and open others.
5. **Stop when nothing is open or assumed.** Recap the settled decisions in a
   few lines before acting on them.

Skip questions that have an obvious conventional default: pick the default and
mention it in the recap.

Without `AskUserQuestion`, ask each round as a numbered list with your
recommended answer for each, and wait for the reply.
