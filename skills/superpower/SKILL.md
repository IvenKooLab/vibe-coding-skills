---
name: superpower
description: Use when the user says "/superpower", "enable superpowers", "启用 superpowers", "按 superpowers 方法论工作", or asks to make all following tasks follow this methodology. Once active, every task runs through brainstorming then writing-plans then test-driven-development then systematic-debugging then verification-before-completion, until the user says "disable superpowers". Symptoms - user wants to turn on the whole workflow at once rather than invoking skills one by one.
---

# Superpowers Methodology Master Switch

## Overview

This is a "switch" skill: the user says `/superpower` or "启用 superpowers" / "enable superpowers", and the agent flips into "work by the methodology" mode — all following tasks **automatically** follow the standard flow, no need to trigger the 5 skills one at a time.

> In Claude Code, type `/superpower` (slash command). In Qoder or other tools, say "启用 superpowers" / "enable superpowers".

## What to do once enabled

From now on, for every dev task, run in order:

1. [[brainstorming]] — clarify the requirement first; offer options; confirm in chunks
2. [[writing-plans]] — break into 2-5 minute executable tasks (file paths + verification steps)
3. [[test-driven-development]] — write the failing test first, then the minimal implementation
4. [[systematic-debugging]] — on bugs, reproduce → root cause → minimal fix; no guessing
5. [[verification-before-completion]] — run build/tests and show evidence before claiming "done"

## Rules

- **Check proactively**: before each step, look for a matching skill and follow its process.
- **User instruction wins**: explicit user instructions have the highest priority; say "disable superpowers" / "停用 superpowers" to exit.
- **Work with the framework**: when company frameworks (Lina etc.) are involved, use the matching `lina-*` skill.
- **Interruptible**: the user can stop any step or the whole mode at any time.

## When to use

- User says `/superpower`, "enable superpowers", "启用 superpowers", "turn on the workflow", "按这套规范来做"
- User wants every following task this session to follow the methodology automatically

## When NOT to use

- User explicitly says "don't use superpowers", "exit the mode", "just write it, don't ask"
- A one-off, unambiguous small change (the user gave a complete, unambiguous instruction)
