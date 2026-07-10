---
description: Turn on Superpowers methodology mode - all following tasks this session auto-run the clarify, plan, TDD, debug, verify flow
---

Enable Superpowers methodology mode. From now on, **every development task** this session runs the flow below, proactively checking and invoking the matching skill — **no need to trigger them one by one**:

1. **brainstorming** — clarify the requirement before coding: ask questions, offer 2-3 options, confirm in chunks, then proceed
2. **writing-plans** — break into 2-5 minute executable tasks, each with exact file paths and verification steps
3. **test-driven-development** — write a failing test first, then the minimal code to pass it (RED-GREEN-REFACTOR)
4. **systematic-debugging** — on a bug/error, reproduce reliably and locate the root cause first; no trial-and-error
5. **verification-before-completion** — actually run build/tests and show checkable evidence before claiming "done"

> These 5 disciplines live in the single `superpowers` skill (`skills/superpowers/SKILL.md`), invoked as a whole by `/superpowers`.

Rules:
- Before each step, check whether a matching skill exists; if so, follow its process strictly.
- Explicit user instructions take the highest priority; to exit this mode, the user says "disable superpowers" / "停用 superpowers".
- When company frameworks (Lina etc.) are involved, use the matching `lina-*` skill.

Now, start with brainstorming on the user's current task to clarify the requirement.
