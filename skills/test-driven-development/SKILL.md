---
name: test-driven-development
description: Use when writing or changing business logic, adding features, or fixing bugs. Enforce RED-GREEN-REFACTOR - write a failing test and watch it fail, write the minimal code to make it pass, then refactor. Code written before tests must be deleted and rewritten. Symptoms - writing new logic, fixing a defect, adding a safety net to untested code.
---

# Test-Driven Development (TDD)

## Overview

Strict red-green-refactor: **write a failing test first, watch it fail, write the minimal code to make it pass, then refactor.** Every small step is backed by a test.

Core belief: **no failing test, no real feature.** Writing code first and bolting on tests later usually just "annotates" existing code and misses design problems.

## When to use

- New business logic, new features
- Fixing a bug (write a test that reproduces it first)
- Before changing untested legacy code (add a "characterization test" to lock current behavior)
- Refactoring (tests are the safety net)

**Symptoms**:
- About to write new logic
- Fixing a defect but no test reproduces it yet
- Changing old code with no test coverage

**Not for**:
- Exploratory scripts, one-off prototypes, pure config changes → use judgement
- UI visual tweaks, pure copy → case by case

## Process (RED-GREEN-REFACTOR)

### RED — write a failing test first
1. Decide the behavior for this small step; write **one** test expressing it.
2. **Run it and confirm it fails for the right reason** (not a compile error, not an import error — a failed assertion).
   - Seeing red proves the test is valid and the feature isn't there yet.

### GREEN — minimal code to pass
1. Write the **least** code that turns this test green. Don't implement the next test's feature early.
2. Run, confirm green.

### REFACTOR — improve under green
1. With all tests green, improve structure (naming, extract methods, remove duplication).
2. **Re-run tests** after each small refactor, keep green.

### Loop
Back to RED for the next small step. One feature = many such loops stacked.

**Done when**: all behavior is covered by tests, tests are green, code refactored to readable.

## Core principles

- **Small steps**: one test, one behavior. Don't cram five assertions into one test.
- **See red before green**: skipping "watch it fail" means you never validated the test itself.
- **Tests drive API design**: if the test is awkward to write, the interface design is bad — fix the interface first.
- **Test behavior, not implementation**: assert "input X returns Y", not "internal method was called 3 times". Tests that break on implementation changes are bad tests.

## TDD for bug fixes

1. Write a test that **reproduces the bug** (it's red).
2. Fix the code to turn it green.
3. Keep that test in the suite permanently — prevents regression.

## Anti-patterns (Never)

- **Never** write implementation first then add tests — that's annotation, not testing. Test first, watch it fail.
- **Never** skip "confirm it fails" then implement — you won't know the test actually tests what you think.
- **Never** write a batch of tests then implement them all at once — one at a time, red-green alternating.
- **Never** implement "what's coming next anyway" during GREEN — YAGNI; write it when the next test demands it.
- **Never** let tests depend on order, time, network, or shared mutable state — tests must be independent, deterministic, repeatable.
- **Never** mock everything — mock only external boundaries (DB, network, filesystem, third parties), not the unit's own internal collaborators.

## Working with other skills

- Before: tasks come from [[writing-plans]]; one plan task = a set of TDD loops
- Debugging: test red for no reason / flaky → [[systematic-debugging]]
- Exception paths: when tests must cover exception scenarios, follow exception-handling best practices
- Wrap up: after all green, do full verification [[verification-before-completion]]
