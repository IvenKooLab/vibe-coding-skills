---
name: ponytail-help
description: Use when the user says "/ponytail-help", "ponytail 速查", or wants a quick-reference card for ponytail's modes, skills, and commands. One-shot display only; edits nothing, changes no mode. Symptoms - the user forgot a command name, wants the intensity table, or asks "what does ponytail do again".
---

# Ponytail-Help — Reference Card

Display this card when invoked. **One-shot:** do NOT change mode, write flag files, or persist anything.

## Intensity levels

| Level | Trigger | What changes |
|-------|---------|-------------|
| **lite** | `/ponytail lite` | Build what's asked, name the lazier alternative in one line. |
| **full** | `/ponytail` | The ladder enforced: YAGNI → stdlib → native → one line → minimum. **Default.** |
| **ultra** | `/ponytail ultra` | YAGNI extremist. Deletion before addition. Challenges requirements before building. |

Level sticks until changed or session end.

## Skills / commands

| Skill | Trigger | What it does |
|-------|---------|--------------|
| **ponytail** | `/ponytail` | Lazy mode itself. Simplest solution that works. |
| **ponytail-review** | `/ponytail-review` | Over-engineering review of the current diff: `L42: yagni: factory, one product. Inline.` |
| **ponytail-audit** | `/ponytail-audit` | Whole-repo over-engineering audit: ranked list of what to delete. |
| **ponytail-debt** | `/ponytail-debt` | Harvest `ponytail:` shortcut comments into a tracked ledger. |
| **ponytail-gain** | `/ponytail-gain` | Measured-impact scoreboard: less code, less cost, more speed. |
| **ponytail-help** | `/ponytail-help` | This card. |

## Deactivate

Say "stop ponytail" or "normal mode". `/ponytail off` also works. Resume anytime with `/ponytail`.

## Configure default mode

Default = `full`, auto-active every session. Change it:

- **Env var** (highest priority): `export PONYTAIL_DEFAULT_MODE=ultra`
- **Config file** (`~/.config/ponytail/config.json`, Windows: `%APPDATA%\ponytail\config.json`): `{ "defaultMode": "lite" }`
- Set `"off"` to disable auto-activation; activate manually with `/ponytail` when wanted.

Resolution: env var > config file > `full`.

## Boundaries (Never)

- One-shot display. **Edits nothing, changes no mode.**

## More

Full upstream docs + examples: <https://github.com/DietrichGebert/ponytail>
