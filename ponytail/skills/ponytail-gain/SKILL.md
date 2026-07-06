---
name: ponytail-gain
description: Use when the user says "/ponytail-gain", "show me ponytail's impact", or wants the measured-impact scoreboard (less code, less cost, more speed) from ponytail's published benchmark medians. One-shot display only; edits nothing, changes no mode. Symptoms - the user wants to see why the lazy discipline is worth keeping on, or the evidence behind the "less code" claim.
---

# Ponytail-Gain — Measured-Impact Scoreboard

Display this scoreboard when invoked. **One-shot:** do NOT change mode, write flag files, or persist anything.

The figures are the published benchmark medians (everyday tasks across Haiku / Sonnet / Opus, the same agent with and without the skill). They are **measured, not computed from the current repo**. Source: the ponytail benchmark suite.

## Scoreboard

```
  ponytail gain                  benchmark median · everyday tasks · 3 models

  Lines of code   no-skill  ████████████████████  100%
                  ponytail  ██▌·················    6–20%   ▼ 80–94%
  Cost            no-skill  ████████████████████  100%
                  ponytail  █████▌··············   23–53%  ▼ 47–77%
  Speed           ponytail  ▸ 3–6× faster

  This repo:  /ponytail-debt   (shortcuts you deferred)
              /ponytail-audit  (what's still cuttable)
```

## Honesty boundary (Never)

These are **benchmark medians, not this repo.** NEVER print a per-repo savings number ("you saved X lines/tokens here") — the unbuilt version was never written, so there is no real baseline to subtract from in a live repo. The only real per-repo figures come from [[ponytail-debt]] (a counted ledger); this card points there instead of inventing one.

## Boundaries (Never)

- One-shot display. **Edits nothing, changes no mode.** (Say "stop ponytail" / "normal mode" to revert.)

## Collaborates with

- The motivation layer of [[ponytail]]. For *this* repo's real numbers, use [[ponytail-debt]] (counted shortcuts) and [[ponytail-audit]] (remaining cuts).
