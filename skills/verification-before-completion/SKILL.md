---
name: verification-before-completion
description: Use before claiming any task is "done", "fixed", or "ready". Actually run verification (build, unit tests, lint, manual repro) and provide checkable evidence; never declare completion based on reasoning alone or "should be fine". Symptoms - about to wrap up, commit, merge, ship, or report the task as complete.
---

# Verification Before Completion

## Overview

Before claiming "done", **actually run verification and provide checkable evidence.** No reasoning, no "should be fine", no "I checked the logic". Evidence first.

Core belief: **a verification you didn't run is a verification you didn't do.** "I think it's fine" is a common starting point for production incidents.

## When to use

- Before saying "done", "fixed", "ready to merge"
- Before committing / opening a PR / shipping
- Before reporting task completion to the user

**Symptoms** (these thoughts → stop and verify):
- "Should be fine now"
- "Logically it's correct"
- "My change is tiny, nothing can go wrong"
- "I ran the test in my head"

**Not for**: none — any completion claim requires verification first. This is a no-exception discipline.

## Process

### 1. Verify against the success criteria, item by item
Go back to the original requirement/plan (the verification steps in [[writing-plans]], the acceptance criteria in [[brainstorming]]) and **check each one** — don't go by impression.

### 2. Actually run it, show evidence
For each item, run it and paste the output:
- **Build**: `mvn clean package` / `mvn compile` passes — show the result.
- **Tests**: run the relevant unit/integration tests, show the pass count. New logic must have tests ([[test-driven-development]]).
- **Lint / conventions**: `checkstyle` / company convention checks pass.
- **Manual repro**: for a bug fix, walk the original repro path and confirm it no longer occurs.

### 3. Check side effects (fix one, break many?)
- Run the **full** relevant test suite, not just the part you changed.
- Confirm no existing functionality broke, no new errors.

### 4. Report honestly
- What you ran, what the result was, **what you didn't / couldn't run** — state it plainly.
- Verifications you couldn't do (need a specific environment, need manual UI testing) → **explicitly mark as "unverified"** and say who needs to cover it, don't gloss over it.

**Done when**: every acceptance item has actual run evidence, side effects checked, unverified items explicitly marked.

## Core principles

- **Evidence > claims**: when you say "done", attach the output proving it.
- **Ran > thought**: mental execution doesn't count. Actual execution does.
- **Honest > pretty**: didn't verify? say so; don't fake it.
- **Small changes need verification too**: "my change is tiny" is exactly when you let your guard down — the more you think "can't possibly break", the more you should run it.

## Anti-patterns (Never)

- **Never** say "done" without evidence you ran something.
- **Never** substitute "should be fine" / "logically correct" for actually running.
- **Never** run only your one changed test and call it "tests pass" — run the full relevant suite.
- **Never** gloss over a verification you couldn't run — mark it "unverified + who covers it".
- **Never** report "complete" when verification failed — fail → go fix ([[systematic-debugging]]) → verify again.
- **Never** skip the build and claim "code is fine" — compile/build catches a lot.

## Working with other skills

- Verification basis comes from [[writing-plans]] "verification steps" and [[brainstorming]] "success criteria"
- Found a bug while verifying → [[systematic-debugging]]
- New-feature verification assumes tests exist → [[test-driven-development]]
- Complex projects: the verification report can be backfilled into the OpenSpec change archive for audit traceability
