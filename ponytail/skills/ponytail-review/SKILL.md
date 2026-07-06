---
name: ponytail-review
description: Use when the user says "/ponytail-review", "review this diff for bloat", or wants the current diff scanned for over-engineering only — what to delete, what the stdlib/native already does, what speculative abstractions to inline. Returns one line per finding plus a net-lines-possible score. Does NOT hunt correctness bugs, security holes, or perf — route those to a normal review. Symptoms - a diff added a wrapper/reinvented stdlib/pulled a new dep for one call/introduced an abstraction with a single caller.
---

# Ponytail-Review — Diff Over-Engineering Review

Review the current diff for unnecessary complexity. **One line per finding**: location, what to cut, what replaces it. The diff's best outcome is getting shorter.

## Format

`L<line>: <tag> <what>. <replacement>.`  (or `<file>:L<line>: ...` for multi-file diffs.)

**Tags:**

- `delete:` dead code, unused flexibility, speculative feature. Replacement: nothing.
- `stdlib:` hand-rolled thing the standard library ships. Name the function.
- `native:` dependency or code doing what the platform already does. Name the feature.
- `yagni:` abstraction with one implementation, config nobody sets, layer with one caller.
- `shrink:` same logic, fewer lines. Show the shorter form.

## Examples

✅ `L12-38: stdlib: 27-line validator class. "@" in email, 1 line; real validation is the confirmation mail.`
✅ `L4: native: moment.js imported for one format call. Intl.DateTimeFormat, 0 deps.`
✅ `repo.py:L88: yagni: AbstractRepository with one implementation. Inline it until a second one exists.`
✅ `L52-71: delete: retry wrapper around an idempotent local call. Nothing replaces it.`
✅ `L30-44: shrink: manual loop builds dict. dict(zip(keys, values)), 1 line.`

## Scoring

End with the only metric that matters: `net: -<N> lines possible.`

If there is nothing to cut, say `Lean already. Ship.` and stop.

## Boundaries (Never)

- **Scope: over-engineering and complexity only.** Correctness bugs, security holes, and performance are explicitly out of scope — route them to a normal review pass, not this one.
- A single smoke test or `assert`-based self-check is the ponytail minimum, **not bloat** — never flag it for deletion.
- **Lists findings, applies nothing.** (Say "stop ponytail-review" / "normal mode" to revert to verbose review.)

## Collaborates with

- The review lens of [[ponytail]]. For the whole repo (not just the diff), use [[ponytail-audit]]. Tracked `ponytail:` shortcuts surface via [[ponytail-debt]].
