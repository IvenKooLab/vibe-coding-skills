---
name: ponytail-debt
description: Use when the user says "/ponytail-debt", "show my ponytail shortcuts", or wants every `ponytail:` shortcut comment harvested into one tracked ledger so a deliberate deferral can't quietly become permanent. Grep-only, read-and-report; persists to a file only if asked. Symptoms - the codebase has `ponytail:` markers (intentional simplifications with a named ceiling) and the user wants them tracked, or flagged when they name no upgrade trigger.
---

# Ponytail-Debt — Shortcut Ledger

Every deliberate ponytail shortcut is marked with a `ponytail:` comment naming its ceiling and upgrade path. This collects them into one ledger so a deferral can't quietly become permanent.

## Scan

Grep the repo for comment markers, skipping `node_modules`, `.git`, and build output:

```bash
grep -rnE '(#|//) ?ponytail:' .   # add other comment prefixes if your stack uses them
```

Each hit is one ledger row. The comment prefix keeps prose that merely *mentions* the convention out of the ledger.

## Output

One row per marker, grouped by file:

`<file>:<line>, <what was simplified>. ceiling: <the limit named>. upgrade: <the trigger to revisit>.`

The convention is `ponytail: <ceiling>, <upgrade path>`, so pull the ceiling and trigger straight from the comment. Want an owner per row? Add `git blame -L<line>,<line>`.

**Flag the rot risk:** any `ponytail:` comment that names **no upgrade path or trigger** gets a `no-trigger` tag — those are the ones that silently rot.

End with `<N> markers, <M> with no trigger.`  Nothing found: `No ponytail: debt. Clean ledger.`

## Boundaries (Never)

- **Reads and reports only, changes nothing.** To persist it, the user asks and it writes the ledger to a file (e.g. `PONYTAIL-DEBT.md`).
- One-shot. (Say "stop ponytail-debt" / "normal mode" to revert.)

## Collaborates with

- The accounting layer of [[ponytail]]. After a [[ponytail-audit]] or [[ponytail-review]] cut pass, run this to confirm the shortcuts you *kept* are all tracked with a trigger.
