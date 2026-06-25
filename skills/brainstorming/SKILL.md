---
name: brainstorming
description: Use before any creative work — new features, refactors, complex bug fixes, tech choices. Clarify the real intent through questions, explore 2-3 alternatives, and present the design in chunks for confirmation before implementing. Symptoms - vague requests like "add a feature" or "improve performance", user says "just start coding", or the requirement has multiple valid interpretations.
---

# Brainstorming (Requirement Clarification)

## Overview

Before writing the first line of code, figure out what problem actually needs solving. Clarify the real intent through Socratic questions, explore alternatives, and present the design in chunks for the user to confirm — only then start implementing.

Core belief: **jumping straight in is the biggest waste.** Code written from a vague requirement almost always gets reworked.

## When to use

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
- User already gave a complete, unambiguous design → go to [[writing-plans]]

## Process

### 1. Restate the requirement (align the starting point)
One sentence: "What I understand you want is...". Let the user confirm or correct. Don't assume silently.

### 2. Ask the key questions (3-5 at a time, not an interrogation)
Focus on questions that change the design. Four typical categories:
- **Scope / edges**: inputs/outputs? failure / exception / empty data?
- **Scale & performance**: data volume? concurrency? latency?
- **Constraints**: permissions? compatibility? dependencies? deadline?
- **Success criteria**: how do we verify it's "done"?

> Don't dump 20 questions at once. Ask the 3-5 most architecture-changing ones first, then go deeper.

### 3. Explore 2-3 alternatives
Never give just one. For each: the approach + tradeoffs (cost / risk) + recommendation. State your recommendation with reasons, but leave the choice to the user.

### 4. Present the design in chunks, confirm each chunk
Break the design into digestible pieces (readable in one screen), present and confirm chunk by chunk. **Don't** dump a 2000-word design doc and ask "any issues?".

### 5. Record conclusions, then implement
After confirmation, lock the key decisions, edges, and acceptance criteria (lightweight projects: in the conversation / commit notes; complex projects: into OpenSpec spec). Then hand off to [[writing-plans]].

**Done when**: the user agrees on what to do, what NOT to do, and what counts as success — with no unresolved ambiguity.

## Anti-patterns (Never)

- **Never** start a branch on "add an export feature" without asking about format, volume, permissions, sync vs async.
- **Never** drown the user in a long question list at once — batch by rounds, most critical first.
- **Never** present one option as if it's the only way — there are always tradeoffs; show them.
- **Never** dump one huge design doc for "review" — chunk it, confirm each.
- **Never** finish clarifying without recording conclusions — it'll drift next round.

## Working with other skills

- Touches the **Lina framework** structure / starter choice → check [[lina-framework-base]]
- Involves Redis / MQ / multi-datasource → check the relevant `lina-*` skill
- **Java conventions** → Alibaba Java Development Manual
- Design confirmed → [[writing-plans]]
- Complex project needs a contract → hand to OpenSpec (this skill does not define the baseline)
