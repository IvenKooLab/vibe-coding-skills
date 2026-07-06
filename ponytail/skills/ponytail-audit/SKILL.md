---
name: ponytail-audit
description: Use when the user says "/ponytail-audit", "audit this repo for bloat", or wants a repo-wide (not just diff) ranked list of what to delete, simplify, or replace with stdlib/native. Same scope and tags as ponytail-review, ranked biggest cut first. One-shot report; lists findings, applies nothing. Symptoms - a codebase has accumulated single-implementation interfaces, factories with one product, wrappers that only delegate, dead config, or hand-rolled stdlib.
---

# Ponytail-Audit — Whole-Repo Over-Engineering Audit

[[ponytail-review]], repo-wide. Scan the whole tree instead of a diff. **Rank findings biggest cut first.**

## Tags (same as ponytail-review)

- `delete:` dead code, unused flexibility, speculative feature. Replacement: nothing.
- `stdlib:` hand-rolled thing the standard library ships. Name the function.
- `native:` dependency or code doing what the platform already does. Name the feature.
- `yagni:` abstraction with one implementation, config nobody sets, layer with one caller.
- `shrink:` same logic, fewer lines. Show the shorter form.

## Hunt for

Deps the stdlib/platform already ships · single-implementation interfaces · factories with one product · wrappers that only delegate · files exporting one thing · dead flags and config · hand-rolled stdlib.

## Output

One line per finding, ranked: `<tag> <what to cut>. <replacement>. [path]`.

End with `net: -<N> lines, -<M> deps possible.`  Nothing to cut: `Lean already. Ship.`

## Boundaries (Never)

- **Scope: over-engineering and complexity only.** Correctness bugs, security holes, and performance are out of scope — route them to a normal review pass.
- **Lists findings, applies nothing.** One-shot. (Say "stop ponytail-audit" / "normal mode" to revert.)

## Collaborates with

- The repo-wide lens of [[ponytail]]; the diff-scoped version is [[ponytail-review]]. Pair with [[ponytail-debt]] to also surface the deliberate `ponytail:` shortcuts already deferred.
