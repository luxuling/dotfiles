---
description: Implement a plan or task
argument-hint: "[plan or task description]"
---
Implement — don't re-litigate the design. Task: ${@:-the plan or task described in the conversation so far}

1. Read the code-standards skill (/home/lixuling/.agents/skills/code-standards/SKILL.md) before writing anything, and follow it for every file you write or edit — even small edits, even when the task never mentions style.
2. Read the relevant existing code and match its style, conventions, and libraries.
3. Implement completely — no TODOs or stubs unless explicitly scoped out.
4. Batch related edits, then build/compile and run relevant tests (write them if none exist and the change warrants it). Fix failures before finishing.
5. Keep the change scoped to what was asked — no unrelated refactors or extra abstractions.
6. Design ambiguity or high-risk action (auth, infra, data deletion, prod config)? Stop and ask instead of guessing.

When done: concise summary — what changed, what was verified (build/tests), what was not verified.
