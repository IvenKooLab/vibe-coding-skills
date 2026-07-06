---
name: trellis-channel
description: Use when multiple AI agents/processes need to collaborate through a durable shared log — peer brainstorming between agents, spawning implement/check workers as separate processes, cross-agent review, durable issue/topic boards (forum channels), or debugging a stalled worker. Symptoms - the user wants agents to "discuss", "let another agent review", "spawn a worker", "open an issue board", or a spawned worker is stuck/truncated.
---

# Trellis-Channel — Multi-Agent Collaboration

## Overview

`trellis channel` is the multi-agent collaboration runtime: it lets agents talk to each other **through a durable event log** instead of ephemeral chat, spawn each other as peer processes, and keep a permanent record of issues and decisions. Reach for it the moment collaboration needs to outlive a single turn.

User signals: "和 codex/claude 讨论", "brainstorm with another agent", "spawn an implement/check worker", "let agent X review", "open an issue board / changelog", "channel is stuck / no output", "progress was truncated".

## The model (three ideas)

1. **Durable event log, not ephemeral chat.** Every message is an appended event with a sequence number (file-locked), in a project-scoped store. Replay-safe, auditable (`--raw`), survives restarts. This is what makes agent-to-agent work reviewable instead of lost.
2. **Forum channels & threads.** A *forum channel* (`--type forum`) is a durable issue/topic board; a *thread* is one item inside it. Use it to capture actionable issues, decisions, a changelog — things that should persist and be filterable, not vanish.
3. **Spawned workers.** An implement or check agent can run as a **peer process** with its own context injection (files / JSONL), interrupts, and kill semantics. The dispatcher **waits on system events** (`--kind done` / `turn_finished`), not on a user-invented tag.

## Core rules

- New durable boards use `--type forum`; a thread is one item in a forum.
- For long or mixed Chinese/English messages, use `--stdin` or `--text-file` — don't put them in the positional shell argument.
- Pick scope deliberately: `--scope project` (default, the current project's bucket) vs `--scope global` (a shared bucket invisible from project listings unless you ask for it).
- For brainstorm, do **multiple pressure-test rounds** — one answer plus one confirmation is review, not brainstorm (same instinct as [[grill-me]] / [[trellis-brainstorm]]).
- **Dispatcher wait pattern:** rely on trellis-emitted system events (`--kind done` / `turn_finished`), NOT a user `--tag` as the completion signal. LLM workers commonly *write* the tag string into prose instead of running the CLI command, so a worker doing `send --tag <my_signal>` is unreliable.
- Forum channels are event-sourced — don't hand-parse `events.jsonl`; use the `forum` / `thread` / `messages --thread` / `context list` views.
- Sequence numbers are assigned under a file lock — never hand-edit the event log; replay-safe writes go through the CLI / SDK.

## When NOT to use

- A **one-shot static review** where a markdown file + prompt is enough — don't stand up a channel for that.
- Replacing normal tool calls with self-logging.
- **Long-term memory retrieval** — use durable forum channels for *actionable issues*, and the cross-session memory recall (`trellis mem`, the `trellis-session-insight` skill upstream) for *history search*.

## Collaborates with

- The collaboration surface of [[trellis]]. Workers typically run [[trellis-brainstorm]] (research/plan), an implement step, and [[trellis-check]] (review) as peer processes.
- This skill is the **concept index**; the full command reference (every subcommand/flag, scope/type model, worker OOM guard, exit codes) lives upstream in `trellis channel --help` and the Trellis docs — load it when you actually need to write a command.
