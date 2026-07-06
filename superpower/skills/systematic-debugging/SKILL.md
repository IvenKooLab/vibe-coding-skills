---
name: systematic-debugging
description: Use when investigating bugs, test failures, errors, performance issues, or data inconsistency. Follow reproduce - locate root cause (no guessing) - minimal hypothesis - fix - verify. Refuse trial-and-error patching. Symptoms - issue not reliably reproducible, fixing one thing breaks another, repeatedly fixing the same problem, or guessing via print statements.
---

# Systematic Debugging

## Overview

Four-phase debugging: **reproduce reliably → locate root cause → form a minimal hypothesis → minimal fix → verify**. Drive with evidence and hypotheses, not by editing code on a hunch.

Core belief: **"try a change" is not debugging, it's gambling.** Fixing without finding the root cause either treats the symptom or introduces new bugs.

## When to use

- Bugs, test failures, errors, performance problems, data inconsistency
- Intermittent, not reliably reproducible behavior
- "Fixed A, broke B"

**Symptoms**:
- Stack trace / failure message / monitoring alert
- Unstable behavior (occurs sometimes)
- Fixing the same problem repeatedly as it comes back
- Scattering `System.out.println` / logs to guess the cause

**Not for**:
- A fix with a known root cause and known remedy → just do it (but still verify per Phase 4)

## Four-phase process

### Phase 1: reproduce reliably
- Goal: turn "happens sometimes" into "triggers every time".
- Means: fix inputs, data, environment; write a test or script that triggers it reliably.
- **Can't reproduce, can't fix** — this phase is the foundation. An uncertain "seems fixed" doesn't count.

### Phase 2: locate root cause (no guessing)
- Goal: find **why** it happens, not just where.
- Means:
  - Read the stack, logs, monitoring; follow the evidence.
  - Bisect: comment out half, revert to an old version, halve the dataset to narrow scope.
  - Form a **hypothesis**: "I think X is null and Y doesn't null-check", then **design an observation to confirm or refute it** — don't just edit.
- **Key: observe and falsify hypotheses first, then edit.** Every hypothesis needs a prediction: "if I'm right, I'll observe Z".

### Phase 3: minimal fix
- Goal: change **only** the point that causes the problem; don't widen the blast radius.
- Before fixing, write a test that reproduces the bug ([[test-driven-development]] bug-fix mode): red → fix → green.
- Don't "optimize" nearby code on the side — it muddies what caused the regression.

### Phase 4: verify + prevent regression
- Run all relevant tests; confirm: ① the bug is gone; ② nothing new broke (fix one, break many).
- Keep the repro test in the suite to prevent regression.
- Ask: **could this root cause exist elsewhere?** Check similar spots (defensive fix, but don't over-do it).

**Done when**: bug reliably reproducible → root cause clear → minimal fix → all green + regression test in place.

## Core principles

- **Evidence first**: every step backed by observation, not "I feel".
- **One variable at a time**: change one thing while debugging, or you won't know which one mattered.
- **Hypotheses must be falsifiable**: "might be X" → design an observation to prove/disprove X, don't just edit.
- **Find the root cause, not the symptom**: NullPointerException is a symptom; the cause is "why is this null here".

## Anti-patterns (Never)

- **Never** edit on seeing an error before reproducing and locating the root cause.
- **Never** "try a change" on a hunch — every edit needs a hypothesis and a verification.
- **Never** change multiple things at once then run — you won't know which one fixed (or broke) it.
- **Never** swallow the exception (`catch (Exception e) {}`) to "make the error go away" — that hides the symptom; the root cause remains.
- **Never** say "should be fixed" without verifying after the fix — run tests, walk the repro path. Verify per [[verification-before-completion]].
- **Never** refactor nearby code on the side mid-debug — mixing debug and refactor makes it impossible to locate regressions.

## Working with other skills

- Fix phase: [[test-driven-development]] (write the repro test before fixing)
- Wrap-up verification: [[verification-before-completion]]
- Multiple suspects needing wide investigation → dispatch parallel subagents to locate, but conclusions still come back through this process for verification
