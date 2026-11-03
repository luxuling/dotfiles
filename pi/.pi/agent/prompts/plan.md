---
description: Plan a solution before implementing
argument-hint: "<task description>"
---
Plan only — no implementation code (signatures/sketches are fine). Task: ${@:-the task described in the conversation so far}

1. Read the relevant code first (files, patterns, existing helpers). State what you checked.
2. List ambiguities and risks explicitly. Don't guess silently.
3. Recommend the simplest approach that works: reuse what exists in the codebase, stdlib and platform features before new code, no speculative abstractions. Compare alternatives only when genuinely torn.
4. Give an ordered plan: files to change/create, key changes, data flow, test strategy.
5. Flag high-risk items (auth, migrations, infra, prod config) for explicit confirmation.

End with a short "Ready to implement" summary.

Stop-and-ask: if the task is ambiguous, you're missing info only the user has, or you're re-reading the same files without progress — stop and ask immediately with `ask_user` (or `ask_user_choice` for named options), one question per call. Max one extra investigation pass after noticing you're stuck, then ask.
