---
name: writing-plans
description: Use after the requirement/design is confirmed and before coding starts. Break the work into 2-5 minute granular tasks, each with exact file paths, change notes, and verification steps, producing an executable plan. Symptoms - requirement is clear but the task is large, touches multiple files, or will be executed in subagents or multiple turns.
---

# Writing Plans

## Overview

Turn the confirmed design into a plan "clear enough that an enthusiastic junior engineer with no judgement and no project context could follow and get it right". Each task is **small enough to finish in 2-5 minutes**, with exact file paths, complete change notes, and verification steps.

Core belief: **the finer the plan, the steadier the execution.** A vague "do A then B" lets the AI drift, miss, or veer off mid-flight.

## When to use

- Requirement/design confirmed via [[brainstorming]], about to start coding
- A change touches multiple files / modules
- Multi-step, multi-turn (or subagent) work
- You want the "how" reviewed before executing

**Symptoms**:
- User says "requirement's clear, go" but there are 5+ sub-steps
- Changes hit controller / service / mapper / config
- Unclear change order, unclear how to verify each step

**Not for**:
- Single-file small change, verify-as-you-go → just do it
- Requirement not confirmed → back to [[brainstorming]]

## Process

### 1. Derive tasks from the design
Break the confirmed design into ordered tasks. **Top-down**: module level first, then refine.

### 2. Make each task executable + verifiable
Every task entry must include:
- **Exact file path** (`src/main/java/.../UserExportService.java`) — not "the relevant service"
- **Change notes**: what to add/modify, key code skeleton or points (not line-by-line, but specific enough)
- **Verification step**: how to confirm this step is right (which test to run, what output to check)

### 3. Control granularity: 2-5 minutes per task
- Too big ("implement the export module") → split.
- Too tiny ("add an import") → merge.
- Rule of thumb: one task = one independently verifiable change.

### 4. Mark dependencies and order
Which tasks must come first (e.g. entity before mapper), which can parallelize. Number them or use dependency arrows.

### 5. Flag risks and rollback
For risky tasks (changing shared logic, data migration, deleting a field) note: **risk + how to roll back**.

### 6. Review before executing
Show the plan to the user ("does this approach work?"), then execute task by task after sign-off. Execution uses TDD ([[test-driven-development]]) and verification ([[verification-before-completion]]).

**Done when**: a task list where every entry has path + notes + verification, order and dependencies clear, user has nodded.

## Task entry template

```
## Task N: <verb-led title>
- File: <exact path>
- Change: <notes / code skeleton>
- Verify: <what to run, what counts as pass>
- Depends on: <task number, or "none">
- Risk / rollback: <optional>
```

## Anti-patterns (Never)

- **Never** write "modify the relevant service class" with no path — the executor will guess the wrong file.
- **Never** make "implement the whole module" a single task — too big, it'll drift.
- **Never** list "what" without "how to verify" — a task without verification isn't a plan.
- **Never** smuggle requirement clarification into the plan — that's [[brainstorming]]; the plan only covers "how".
- **Never** start a destructive change (data migration, deleting a field, changing a public interface) without risk/rollback notes.

## Working with other skills

- Before: [[brainstorming]] (don't plan an unconfirmed requirement)
- Execute: [[test-driven-development]] (each task via TDD)
- Wrap up: [[verification-before-completion]] (full verification after all tasks)
- Complex projects: top-level tasks come from OpenSpec's `tasks.md`; this skill refines them to code-unit level — **do not define top-level requirements yourself**
