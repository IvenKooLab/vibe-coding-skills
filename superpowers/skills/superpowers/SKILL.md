---
name: superpowers
description: Use when the user says "/superpowers", "enable superpowers", "启用 superpowers", "按 superpowers 方法论工作", or asks to make all following tasks follow this methodology. Once active, every dev task runs the 5 disciplines below in order — clarify (§brainstorming) → plan (§writing-plans) → TDD (§test-driven-development) → debug (§systematic-debugging) → verify (§verification-before-completion) — until the user says "disable superpowers". Also use on any single creative task: pick the matching discipline. Symptoms - vague requests, "just start coding", multi-file changes, about to write logic/fix a bug, unreliable repro, or about to claim "done".
---

# Superpowers — Methodology Layer (5 disciplines)

## Overview

This is the methodology layer: **how to work**, not what to use. Five disciplines, each owning one stretch from "before you touch the keyboard" to "before you claim done":

1. **§ brainstorming** — clarify the requirement before coding
2. **§ writing-plans** — break confirmed design into 2-5 min executable tasks
3. **§ test-driven-development** — RED-GREEN-REFACTOR while writing logic
4. **§ systematic-debugging** — evidence-driven debugging when bugs hit
5. **§ verification-before-completion** — actually run verification before "done"

Core belief: **jumping straight in is the biggest waste.** The 5 disciplines are the antidote to vibe-coding drift — but they are a *default order*, not a cage. Pick the matching one for the task; you don't always run all five.

> **How to enable**: type `/superpowers` (Claude Code) or say "启用 superpowers" / "enable superpowers". From then on, every dev task runs the disciplines in order. Say "disable superpowers" to exit. You can also invoke a single discipline when only one applies.

## The default chain

```
clarify → plan → TDD (while coding) → debug (when bugs hit) → verify (before done)
   §1        §2          §3                   §4                     §5
```

Each discipline names its own "done when" — reach it before moving on. Each hand-off to the next is explicit.

---

## §1 brainstorming — Requirement Clarification

### Overview

Before writing the first line of code, figure out what problem actually needs solving. Clarify the real intent through Socratic questions, explore alternatives, and present the design in chunks for the user to confirm — only then start implementing.

Core belief: **jumping straight in is the biggest waste.** Code written from a vague requirement almost always gets reworked.

### When to use

- Vague requests: "add a feature", "optimize this", "refactor this block"
- User says "just start coding" but key constraints are unclear
- The requirement has more than one reasonable interpretation
- Changes that cross modules, data models, or interface contracts

**Symptoms** (any of these → clarify first, don't write code yet):
- No acceptance criteria / definition of done
- Unknown data volume, concurrency, performance targets
- Unknown edges: failure, null, permission, rollback
- Unclear whether to extend existing logic or build new

**Not for**:
- Single-line typo, a bug fix with a known repro path → just do it
- User already gave a complete, unambiguous design → go to §writing-plans

### Process

1. **Restate the requirement (align the starting point).** One sentence: "What I understand you want is...". Let the user confirm or correct. Don't assume silently.
2. **Ask the key questions (3-5 at a time, not an interrogation).** Focus on questions that change the design. Four typical categories:
   - **Scope / edges**: inputs/outputs? failure / exception / empty data?
   - **Scale & performance**: data volume? concurrency? latency?
   - **Constraints**: permissions? compatibility? dependencies? deadline?
   - **Success criteria**: how do we verify it's "done"?
   > Don't dump 20 questions at once. Ask the 3-5 most architecture-changing ones first, then go deeper.
3. **Explore 2-3 alternatives.** Never give just one. For each: the approach + tradeoffs (cost / risk) + recommendation. State your recommendation with reasons, but leave the choice to the user.
4. **Present the design in chunks, confirm each chunk.** Break the design into digestible pieces (readable in one screen), present and confirm chunk by chunk. **Don't** dump a 2000-word design doc and ask "any issues?".
5. **Record conclusions, then implement.** After confirmation, lock the key decisions, edges, and acceptance criteria (lightweight projects: in the conversation / commit notes; complex projects: into OpenSpec spec). Then hand off to §writing-plans.

**Done when**: the user agrees on what to do, what NOT to do, and what counts as success — with no unresolved ambiguity.

### Anti-patterns (Never)

- **Never** start a branch on "add an export feature" without asking about format, volume, permissions, sync vs async.
- **Never** drown the user in a long question list at once — batch by rounds, most critical first.
- **Never** present one option as if it's the only way — there are always tradeoffs; show them.
- **Never** dump one huge design doc for "review" — chunk it, confirm each.
- **Never** finish clarifying without recording conclusions — it'll drift next round.

---

## §2 writing-plans — Executable Task Planning

### Overview

Turn the confirmed design into a plan "clear enough that an enthusiastic junior engineer with no judgement and no project context could follow and get it right". Each task is **small enough to finish in 2-5 minutes**, with exact file paths, complete change notes, and verification steps.

Core belief: **the finer the plan, the steadier the execution.** A vague "do A then B" lets the AI drift, miss, or veer off mid-flight.

### When to use

- Requirement/design confirmed via §brainstorming, about to start coding
- A change touches multiple files / modules
- Multi-step, multi-turn (or subagent) work
- You want the "how" reviewed before executing

**Symptoms**:
- User says "requirement's clear, go" but there are 5+ sub-steps
- Changes hit controller / service / mapper / config
- Unclear change order, unclear how to verify each step

**Not for**:
- Single-file small change, verify-as-you-go → just do it
- Requirement not confirmed → back to §brainstorming

### Process

1. **Derive tasks from the design.** Break the confirmed design into ordered tasks. **Top-down**: module level first, then refine.
2. **Make each task executable + verifiable.** Every task entry must include:
   - **Exact file path** (`src/main/java/.../UserExportService.java`) — not "the relevant service"
   - **Change notes**: what to add/modify, key code skeleton or points (not line-by-line, but specific enough)
   - **Verification step**: how to confirm this step is right (which test to run, what output to check)
3. **Control granularity: 2-5 minutes per task.** Too big ("implement the export module") → split. Too tiny ("add an import") → merge. Rule of thumb: one task = one independently verifiable change.
4. **Mark dependencies and order.** Which tasks must come first (e.g. entity before mapper), which can parallelize. Number them or use dependency arrows.
5. **Flag risks and rollback.** For risky tasks (changing shared logic, data migration, deleting a field) note: **risk + how to roll back**.
6. **Review before executing.** Show the plan to the user ("does this approach work?"), then execute task by task after sign-off. Execution uses TDD (§test-driven-development) and verification (§verification-before-completion).

**Done when**: a task list where every entry has path + notes + verification, order and dependencies clear, user has nodded.

### Task entry template

```
## Task N: <verb-led title>
- File: <exact path>
- Change: <notes / code skeleton>
- Verify: <what to run, what counts as pass>
- Depends on: <task number, or "none">
- Risk / rollback: <optional>
```

### Anti-patterns (Never)

- **Never** write "modify the relevant service class" with no path — the executor will guess the wrong file.
- **Never** make "implement the whole module" a single task — too big, it'll drift.
- **Never** list "what" without "how to verify" — a task without verification isn't a plan.
- **Never** smuggle requirement clarification into the plan — that's §brainstorming; the plan only covers "how".
- **Never** start a destructive change (data migration, deleting a field, changing a public interface) without risk/rollback notes.

---

## §3 test-driven-development — RED-GREEN-REFACTOR

### Overview

Strict red-green-refactor: **write a failing test first, watch it fail, write the minimal code to make it pass, then refactor.** Every small step is backed by a test.

Core belief: **no failing test, no real feature.** Writing code first and bolting on tests later usually just "annotates" existing code and misses design problems.

### When to use

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

### Process (RED-GREEN-REFACTOR)

1. **RED — write a failing test first.** Decide the behavior for this small step; write **one** test expressing it. **Run it and confirm it fails for the right reason** (not a compile error, not an import error — a failed assertion). Seeing red proves the test is valid and the feature isn't there yet.
2. **GREEN — minimal code to pass.** Write the **least** code that turns this test green. Don't implement the next test's feature early. Run, confirm green.
3. **REFACTOR — improve under green.** With all tests green, improve structure (naming, extract methods, remove duplication). **Re-run tests** after each small refactor, keep green.
4. **Loop.** Back to RED for the next small step. One feature = many such loops stacked.

**Done when**: all behavior is covered by tests, tests are green, code refactored to readable.

### Core principles

- **Small steps**: one test, one behavior. Don't cram five assertions into one test.
- **See red before green**: skipping "watch it fail" means you never validated the test itself.
- **Tests drive API design**: if the test is awkward to write, the interface design is bad — fix the interface first.
- **Test behavior, not implementation**: assert "input X returns Y", not "internal method was called 3 times". Tests that break on implementation changes are bad tests.

### TDD for bug fixes

1. Write a test that **reproduces the bug** (it's red).
2. Fix the code to turn it green.
3. Keep that test in the suite permanently — prevents regression.

### Anti-patterns (Never)

- **Never** write implementation first then add tests — that's annotation, not testing. Test first, watch it fail.
- **Never** skip "confirm it fails" then implement — you won't know the test actually tests what you think.
- **Never** write a batch of tests then implement them all at once — one at a time, red-green alternating.
- **Never** implement "what's coming next anyway" during GREEN — YAGNI; write it when the next test demands it.
- **Never** let tests depend on order, time, network, or shared mutable state — tests must be independent, deterministic, repeatable.
- **Never** mock everything — mock only external boundaries (DB, network, filesystem, third parties), not the unit's own internal collaborators.

---

## §4 systematic-debugging — Evidence-Driven Debugging

### Overview

Four-phase debugging: **reproduce reliably → locate root cause → form a minimal hypothesis → minimal fix → verify**. Drive with evidence and hypotheses, not by editing code on a hunch.

Core belief: **"try a change" is not debugging, it's gambling.** Fixing without finding the root cause either treats the symptom or introduces new bugs.

### When to use

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

### Four-phase process

1. **Phase 1: reproduce reliably.** Goal: turn "happens sometimes" into "triggers every time". Means: fix inputs, data, environment; write a test or script that triggers it reliably. **Can't reproduce, can't fix** — this phase is the foundation. An uncertain "seems fixed" doesn't count.
2. **Phase 2: locate root cause (no guessing).** Goal: find **why** it happens, not just where. Means: read the stack, logs, monitoring; bisect (comment out half, revert to an old version, halve the dataset); form a **hypothesis** ("I think X is null and Y doesn't null-check"), then **design an observation to confirm or refute it** — don't just edit. **Key: observe and falsify hypotheses first, then edit.** Every hypothesis needs a prediction: "if I'm right, I'll observe Z".
3. **Phase 3: minimal fix.** Goal: change **only** the point that causes the problem; don't widen the blast radius. Before fixing, write a test that reproduces the bug (§test-driven-development bug-fix mode): red → fix → green. Don't "optimize" nearby code on the side — it muddies what caused the regression.
4. **Phase 4: verify + prevent regression.** Run all relevant tests; confirm: ① the bug is gone; ② nothing new broke (fix one, break many). Keep the repro test in the suite to prevent regression. Ask: **could this root cause exist elsewhere?** Check similar spots (defensive fix, but don't over-do it).

**Done when**: bug reliably reproducible → root cause clear → minimal fix → all green + regression test in place.

### Core principles

- **Evidence first**: every step backed by observation, not "I feel".
- **One variable at a time**: change one thing while debugging, or you won't know which one mattered.
- **Hypotheses must be falsifiable**: "might be X" → design an observation to prove/disprove X, don't just edit.
- **Find the root cause, not the symptom**: NullPointerException is a symptom; the cause is "why is this null here".

### Anti-patterns (Never)

- **Never** edit on seeing an error before reproducing and locating the root cause.
- **Never** "try a change" on a hunch — every edit needs a hypothesis and a verification.
- **Never** change multiple things at once then run — you won't know which one fixed (or broke) it.
- **Never** swallow the exception (`catch (Exception e) {}`) to "make the error go away" — that hides the symptom; the root cause remains.
- **Never** say "should be fixed" without verifying after the fix — run tests, walk the repro path. Verify per §verification-before-completion.
- **Never** refactor nearby code on the side mid-debug — mixing debug and refactor makes it impossible to locate regressions.

---

## §5 verification-before-completion — Run It Before "Done"

### Overview

Before claiming "done", **actually run verification and provide checkable evidence.** No reasoning, no "should be fine", no "I checked the logic". Evidence first.

Core belief: **a verification you didn't run is a verification you didn't do.** "I think it's fine" is a common starting point for production incidents.

### When to use

- Before saying "done", "fixed", "ready to merge"
- Before committing / opening a PR / shipping
- Before reporting task completion to the user

**Symptoms** (these thoughts → stop and verify):
- "Should be fine now"
- "Logically it's correct"
- "My change is tiny, nothing can go wrong"
- "I ran the test in my head"

**Not for**: none — any completion claim requires verification first. This is a no-exception discipline.

### Process

1. **Verify against the success criteria, item by item.** Go back to the original requirement/plan (the verification steps in §writing-plans, the acceptance criteria in §brainstorming) and **check each one** — don't go by impression.
2. **Actually run it, show evidence.** For each item, run it and paste the output:
   - **Build**: `mvn clean package` / `mvn compile` passes — show the result.
   - **Tests**: run the relevant unit/integration tests, show the pass count. New logic must have tests (§test-driven-development).
   - **Lint / conventions**: `checkstyle` / company convention checks pass.
   - **Manual repro**: for a bug fix, walk the original repro path and confirm it no longer occurs.
3. **Check side effects (fix one, break many?).** Run the **full** relevant test suite, not just the part you changed. Confirm no existing functionality broke, no new errors.
4. **Report honestly.** What you ran, what the result was, **what you didn't / couldn't run** — state it plainly. Verifications you couldn't do (need a specific environment, need manual UI testing) → **explicitly mark as "unverified"** and say who needs to cover it, don't gloss over it.

**Done when**: every acceptance item has actual run evidence, side effects checked, unverified items explicitly marked.

### Core principles

- **Evidence > claims**: when you say "done", attach the output proving it.
- **Ran > thought**: mental execution doesn't count. Actual execution does.
- **Honest > pretty**: didn't verify? say so; don't fake it.
- **Small changes need verification too**: "my change is tiny" is exactly when you let your guard down — the more you think "can't possibly break", the more you should run it.

### Anti-patterns (Never)

- **Never** say "done" without evidence you ran something.
- **Never** substitute "should be fine" / "logically correct" for actually running.
- **Never** run only your one changed test and call it "tests pass" — run the full relevant suite.
- **Never** gloss over a verification you couldn't run — mark it "unverified + who covers it".
- **Never** report "complete" when verification failed — fail → go fix (§systematic-debugging) → verify again.
- **Never** skip the build and claim "code is fine" — compile/build catches a lot.

---

## Priority & interrupt rules

- **Check proactively**: before each step, look for a matching discipline and follow its process.
- **User instruction wins**: explicit user instructions have the highest priority; say "disable superpowers" / "停用 superpowers" to exit.
- **Work with the framework**: when company frameworks (Lina etc.) are involved, use the matching `lina-*` skill.
- **Interruptible**: the user can stop any step or the whole mode at any time.

## Collaborates with

- **Framework knowledge layer** (`lina-*`): `lina-*` = what to use; this skill = how to work. Orthogonal, complementary. Touches Lina structure/starter choice → [[lina-framework-base]]; involves Redis/MQ/multi-datasource → the relevant `lina-*` skill. Java conventions → Alibaba Java Development Manual.
- **[[grill-me]]**: a deeper, single-point plan interrogation — use it when a plan feels "roughly right" but hides decisions.
- **[[ponytail]]**: orthogonal discipline for *what the code looks like* (minimal, lazy-but-not-negligent). Stack with any discipline.
- **[[openspec]]**: the contract layer. Complex projects: requirements/design contracts go into OpenSpec's proposal/spec/design/tasks; this skill only executes and **does not** define the requirement baseline.
- **[[trellis]]**: the persistence + orchestration frame; these disciplines run *inside* it for multi-session/multi-agent projects.
