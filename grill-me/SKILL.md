---
name: grill-me
description: Use when the user says "/grill-me", "grill me", "拷问我", "盘问这个计划", "stress-test this plan", or wants every hidden decision in a plan/design dragged into the open before building. A relentless, one-question-at-a-time interview that walks the whole design tree until you and the user reach a shared understanding; the user invokes it deliberately, the agent never auto-triggers it. Symptoms - a plan feels "roughly right" but unresolved decisions are hiding in it; the user wants the soft spots found before any code is written.
---

# Grill-Me — Relentless Plan Interview

## Overview

`grill-me` runs a relentless interview about a plan or design, walking every branch of the decision tree until the user and the agent reach a **shared understanding**. The point is not to reach agreement quickly — it is to make every implicit call explicit, so nothing important is left silently assumed. You come out the other side with a plan whose branches have all been visited.

This is a **reach-for-it, stateless** tool. It writes nothing and leaves no workspace behind — the only artifact is the sharpened understanding in the conversation itself. (If you instead want the same interview to leave a paper trail of ADRs and a glossary, that is the stateful sibling `grill-with-docs`; `grill-me` is deliberately stateless.)

## The Non-Negotiable Contract

1. **One question at a time.** Ask a single question, then wait. Never dump a batch of questions — that is bewildering. The next question does not go out until the current one is answered.
2. **Every question ships with your recommended answer.** The user reacts to a proposal, not a blank prompt. Each question carries: the decision needed · why it matters · your recommendation · the trade-off if they choose differently.
3. **Read before you ask.** If a question can be answered by exploring the codebase, configs, tests, docs, or existing specs — go explore it instead of asking. Ask the user **only** for product intent, preference, scope, or risk tolerance that the repository cannot answer.
4. **Walk the design tree, resolve dependencies in order.** Settle a parent decision before the choices that hang off it. Visit every branch; don't just head for agreement on the happy path.
5. **Do not enact the plan until the user confirms shared understanding.** You interview; you do not build, until explicitly released.

## When to use

- The user invokes it: `/grill-me`, "grill me", "拷问我", "盘问一下这个方案", "stress-test this plan before we build".
- A plan feels roughly right, but you can sense unresolved decisions hiding in it — the moment you want the soft spots forced into the open.

## When NOT to use

- The user has not asked for it — this skill is **never** auto-triggered; it is always user-invoked.
- The requirement is already crystal clear and unambiguous; grilling would be ceremony.
- You are mid-implementation debugging a concrete bug — use [[systematic-debugging]] instead.

## Process

1. **Restate the plan in one sentence** so both sides agree on what is being grilled.
2. **Do the evidence pass first.** Inspect code, configs, tests, docs, existing specs. Sort what you find into: confirmed facts · product intent still needed from the user · scope/risk decisions still needed · likely out-of-scope.
3. **Ask the single highest-value remaining question** — one question, with your recommended answer and the trade-off. Parent decisions before children.
4. **After each answer**, note the resolved decision and update the running shared understanding before the next question.
5. **Declare shared understanding** only when every branch has been visited and no implicit assumption remains. Hand control back to the user — let them decide whether to build.

## Anti-patterns (Never)

- **Never** ask more than one question per message — bewildering, defeats the point.
- **Never** ask a naked question without your own recommended answer — you are proposing, not interrogating.
- **Never** ask the user to confirm a fact the repository can answer — read the code first.
- **Never** start writing the plan's code before the user confirms shared understanding.
- **Never** confuse "we agreed quickly" with "every branch was visited" — speed is not the goal; completeness is.

## Example

> **Plan:** "Add a cache for these API responses."
>
> **Bad (batch, naked, lazy):** "What TTL? What eviction? What store? Distributed or local? Should we invalidate on write?"
>
> **Good (one at a time, recommended, code-aware):** "I checked — the endpoint is read-heavy, ~80 req/s, single instance today. **Q1 (recommended: `@lru_cache(maxsize=1000)` on the fetch fn, in-process):** do we need this cache to be correct across multiple instances, or is a per-process cache acceptable for now? Why it matters: cross-instance correctness forces Redis and roughly triples the surface area; per-process is one line. If you expect horizontal scale this quarter, say so and I'll grill the Redis path instead."

## Collaborates with

- Pairs with [[brainstorming]] (the methodology-layer requirement-clarifier) — `grill-me` is the dedicated deep-interview tool; `brainstorming` is the workflow opener.
- Hands off cleanly to [[writing-plans]] once shared understanding is reached — the visited decision tree becomes the plan's structure.
- See [[verification-before-completion]] for the *post*-build counterpart; `grill-me` is the *pre*-build stress test.
