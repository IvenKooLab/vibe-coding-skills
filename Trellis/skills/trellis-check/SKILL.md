---
name: trellis-check
description: Use when code is written and needs quality verification, before committing changes, or to catch context drift during long sessions. Comprehensive verification: spec compliance, lint, type-check, tests, cross-layer data flow, code reuse, and consistency. Self-fixes where it can. Symptoms - implementation is done and needs the gate before commit; a long session where the agent may have drifted from specs; a change touches multiple layers and needs cross-layer review.
---

# Trellis-Check — Comprehensive Quality Verification

The Verify-phase gate for recently written code. Combines **spec compliance**, **cross-layer safety**, and **pre-commit checks**. Find violations and fix them directly; re-run project checks after fixes.

## Step 1 — Identify what changed

`git diff --name-only HEAD` and `git status`. Know the blast radius before reviewing.

## Step 2 — Read task artifacts + applicable specs

Read `prd.md` → `design.md` (if present) → `implement.md` (if present). For each changed package/layer, read the spec index and follow its **Quality Check** section, then the specific guideline files it points to — *the index is a pointer, not the goal.*

## Step 3 — Run project checks

Run lint, type-check, and tests. **Fix failures before proceeding.**

## Step 4 — The checklist

**Code quality**

- [ ] Linter passes · type checker passes (if applicable) · tests pass
- [ ] No debug logging left in · no suppressed warnings or type-safety bypasses

**Test coverage**

- [ ] New function → unit test added
- [ ] Bug fix → regression test added
- [ ] Changed behavior → existing tests updated

**Spec sync**

- [ ] Does `.trellis/spec/` need updates? (new patterns, conventions, lessons learned)
- [ ] "If I fixed a bug or discovered something non-obvious — should I document it so future-me won't hit it?" → if yes, update the relevant spec doc.

## Step 5 — Cross-layer dimensions (skip if change is single-layer)

**A. Data flow (change touches 3+ layers):** read flow Storage→Service→API→UI correct? Write flow UI→API→Service→Storage correct? Types/schemas passed correctly between layers? Errors propagated to the caller?

**B. Code reuse (modifying constants / creating utilities):** searched for existing similar code before creating new? 2+ places define the same value → extracted to a shared constant? After batch modification, all occurrences updated?

**C. Import / dependency (creating new files):** correct import paths (relative vs absolute)? No circular dependencies?

**D. Same-layer consistency:** other places using the same concept are consistent?

## Step 6 — Report and fix

Report violations found and fix them directly. Re-run project checks after fixes.

## Anti-patterns (Never)

- **Never** skip the project's lint/type/test gate because "it probably passes" — run it. (This is the [[superpowers]] §verification-before-completion instinct made concrete.)
- **Never** leave a debug log or a suppressed warning in to make a check "pass."
- **Never** finish without asking whether the discovery warrants a spec update — that's how the next session gets smarter.
- **Never** flag a ponytail-style minimal self-check as a defect — a single `assert`/smoke test is the floor, not bloat (see [[ponytail]]).

## Collaborates with

- The Verify phase of [[trellis]]. For the over-engineering lens specifically (what to *delete*), add [[ponytail-review]]; this skill covers correctness/compliance, that one covers complexity.
- Mirrors and extends [[superpowers]] §verification-before-completion with spec-compliance and cross-layer dimensions.
