---
name: trellis-brainstorm
description: Use when requirements are unclear, there are multiple valid approaches, or the user describes a new feature or complex task — guide collaborative requirements discovery before implementation. Creates/seeds the task PRD, asks high-value questions one at a time (each with a recommended answer), researches technical choices, decomposes to fundamentals when things feel over-engineered, and converges on MVP scope. Symptoms - a new feature with unknowns; the plan feels over-engineered "because everyone does it"; multiple approaches with unclear trade-offs; the user's request is vague.
---

# Trellis-Brainstorm — Requirements Discovery Before Implementation

## The Non-Negotiable Interview Contract

Interview me relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. **For each question, provide your recommended answer.** **Ask one question at a time.**

> This is the same relentless-interview contract as [[grill-me]] — Trellis bakes it into the Plan phase. The difference is scope: `grill-me` is a stateless standalone stress-test of one plan; `trellis-brainstorm` is the opening of a structured task that produces durable `prd.md` / `design.md` / `implement.md` artifacts.

## The Non-Negotiable Evidence Rule

If a question can be answered by exploring the codebase, **explore the codebase instead.** Before asking the user anything, first check whether the answer is already in code, tests, configs, docs, existing specs, or task history. Ask the user **only** for product intent, preference, scope, risk tolerance, or decisions that remain ambiguous after inspection. Do not ask the user to confirm facts the repository can answer.

## Planning Flow

1. Capture the user's request and initial known facts in `prd.md`.
2. Inspect available evidence first: code, tests, fixtures, configs; READMEs, docs, existing specs, domain notes; related tasks, research files, session history.
3. Sort what you found into: confirmed facts · product intent still needed · scope/risk decisions still needed · likely out-of-scope.
4. Ask the **single highest-value remaining question** (parent decisions before children).
5. Include your recommended answer with the question.
6. After each answer, update `prd.md` before continuing.
7. For complex tasks, create/update `design.md` and `implement.md` before implementation.
8. Before declaring planning ready, run the **PRD convergence pass** below.

Do not invent a project-specific product/spec hierarchy — use what the repo already has.

## Question Rules

One question per message. Each question states: the decision needed · why it matters · your recommended answer · the trade-off if they choose differently. Do **not** ask process questions ("should I search? inspect files? continue?") — do the evidence work directly.

## Thinking Framework: First Principles (when things feel over-engineered)

When requirements are vague or a solution feels like complexity "because everyone does it," decompose to fundamental truths before reasoning upward:

1. **Restate the problem** stripped of implementation detail — one sentence. (*Bad:* "we need Redis caching for the profile endpoint." *Good:* "profile data loads too slowly.")
2. **List fundamental truths** — physical constraints, business rules, technical invariants, real user needs (not opinion or convention).
3. **Challenge assumptions** — fact or convention? What if we removed this? Are we solving the actual problem or a symptom? Who benefits from this complexity?
4. **Build up from truths** — start with the minimum viable mechanism satisfying all truths; add complexity only when a specific truth demands it (each addition must answer "which truth requires this?").
5. **Validate** — does it solve the original problem? What's the simplest experiment to test it?

(This is the same instinct as [[ponytail]]'s ladder — reach for the minimum that the actual constraints require.)

## Artifacts

- `prd.md` — goal & user value · confirmed facts · requirements · **testable acceptance criteria** · out of scope · genuinely blocking open questions.
- `design.md` (complex tasks) — architecture & boundaries · data flow & contracts · compatibility/migration · trade-offs · operational/rollback.
- `implement.md` (complex tasks) — ordered checklist · validation commands · risky files/rollback points.

Lightweight tasks may have only `prd.md`. Complex tasks must have all three before implementation starts.

## PRD Convergence Pass (the final planning gate)

Before declaring planning ready, rewrite `prd.md` once against the artifact structure — **lossless**:

- Collapse repeated facts into one authoritative section.
- Fold temporary brainstorm sections ("what I already know", "assumptions", resolved open questions) into Goal / Background / Requirements / Technical Notes / Acceptance.
- Remove resolved open questions; merge parallel bug/requirement lists describing the same work.
- **Preserve every file:line anchor, decision, constraint, requirement ID, and acceptance mapping.**
- Keep only genuinely blocking open questions.

Read `prd.md` top to bottom afterward and verify no fact is repeated across sections unless the repetition adds new information.

## Quality Bar (before "planning ready")

- `prd.md` has testable acceptance criteria and has passed the convergence pass.
- Repository-answerable questions already answered through inspection.
- Remaining open questions are genuinely about user intent or scope.
- Complex tasks have `design.md` + `implement.md`.
- **The user has reviewed the final artifacts or explicitly approved proceeding.**

Do not start implementation until the user approves. (See [[trellis]] for the full 4-phase loop; hand off to [[writing-plans]] when you want the converged PRD turned into an executable task breakdown.)
