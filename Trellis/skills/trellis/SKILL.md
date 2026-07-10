---
name: trellis
description: Use when the user says "/trellis", "启用 trellis", "用 trellis 工作流", or wants AI work to persist specs / tasks / memory into the repo so any coding session continues with real project context instead of starting from scratch. Also use when deciding whether a project needs a full spec-task-memory engineering framework (multi-session, multi-agent, team-shared conventions) vs a lighter methodology-only setup. Symptoms - the user keeps re-explaining project conventions every session; work is lost when context fills up; multiple agents/sessions need to stay aligned; the team wants one person's hard-won rules to benefit everyone.
---

# Trellis — Persistent Spec / Task / Memory Engineering Layer

## Overview

AI writes code fast, but **every session it starts from scratch** — no memory of your project, your conventions, or your team's requirements. Trellis fixes that by **persisting specs, tasks, and memory into the repo**, so any coding agent works to your engineering standards, and a new session picks up where the last left off.

This skill captures the **portable essence** of [mindfold-ai/Trellis](https://github.com/mindfold-ai/Trellis): the persistence model and the 4-phase loop. The full automation (CLI, hooks, `.trellis/` scripts) comes from installing Trellis upstream (`npm i -g @mindfoldhq/trellis` → `trellis init`); these skills give you the methodology even without it, and align with the harness if you adopt it.

## The Persistence Model (three things that live in the repo)

| Surface | Holds | Why it matters |
|---|---|---|
| **Specs** (`.trellis/spec/`) | Project conventions, design constraints, coding standards | Write a rule once → auto-injected into every relevant session. Stops you repeating yourself. |
| **Tasks** (`.trellis/tasks/`) | PRDs, design notes, implement plans, research, task status (parent/child trees) | Keeps AI work structured: what was asked, what was decided, what's done. Reviewable like any artifact. |
| **Memory** (`.trellis/workspace/` journals + cross-session recall) | What happened last time; decisions and lessons | A new session starts with real context, not amnesia. |

> The contrast with a monolithic `CLAUDE.md` / `AGENTS.md` / `.cursorrules`: those are useful entry points but become a wall of text. Trellis adds **scoped** specs, task PRDs, workflow gates, and workspace memory *around* them — versioned, reviewable, team-shared.

## The 4-Phase Loop

Trellis runs a loop with auto-invoked skills (or sub-agents in the full harness):

1. **Plan** — [[trellis-brainstorm]] walks requirements **one question at a time** until the PRD is clear; research-heavy items go to a research sub-agent. *Output: a curated `prd.md` (lightweight tasks) or `prd.md` + `design.md` + `implement.md` (complex tasks).*
2. **Implement** — write code from the PRD with the relevant specs auto-injected. Read the applicable spec index + pre-development checklist **before** writing a line (Trellis calls this `trellis-before-dev`). No commit yet.
3. **Verify** — [[trellis-check]] reviews the diff against specs and runs lint / type-check / tests, self-fixing where it can.
4. **Finish** — a final check runs, new learnings are **promoted back into `.trellis/spec/`** so the next session starts smarter; the task is archived and a session journal recorded.

Resuming later is a first-class operation: load current context → figure out which phase/step to pick up at → continue. (Upstream calls this `trellis-continue`.)

## The key gate: before declaring "planning ready"

- The PRD has **testable acceptance criteria**.
- Repository-answerable questions were already answered by **reading**, not by asking the user.
- Remaining open questions are genuinely about user intent or scope.
- Complex tasks have `design.md` + `implement.md`.
- The user has reviewed the artifacts or explicitly approved proceeding.

Do not start implementation until the user approves. (Same instinct as [[grill-me]] — Trellis's brainstorm literally embeds the relentless-interview contract.)

## When to use (and when NOT to)

**Use Trellis when** the project is multi-session, multi-agent, or team-shared — you're paying the cost of keeping specs/tasks/memory, and reaping not-amnesia, shared standards, and reviewable context.

**Skip it when** the project is light, single-dev, short-lived, and you don't need cross-session memory — the methodology layer ([[superpowers]]: §brainstorming → §writing-plans → §test-driven-development → §verification-before-completion) plus [[ponytail]] is enough. Don't pay the framework tax you won't use.

## Anti-patterns (Never)

- **Never** treat the upstream Trellis source / `node_modules` as the customization target for a project — customize the local `.trellis/` and platform files; the npm packages ship as-is.
- **Never** overwrite user-modified local files with default templates — check the template-hash state first; prefer `.new` sidecars over destructive overwrites.
- **Never** put team-private project rules into a public/shared bundled skill — put them in `.trellis/spec/`, a project-local skill, the current task, or the workspace journal.
- **Never** describe a removed or never-shipped knob as current Trellis behavior — cross-check against the local `.trellis/config.yaml` and `trellis --help` before claiming a setting exists.

## Collaborates with

- Plan phase = [[trellis-brainstorm]] (shares DNA with [[grill-me]]). Verify phase = [[trellis-check]]. Multi-agent = [[trellis-channel]].
- Sits **above** the methodology layer ([[superpowers]]: §brainstorming / §writing-plans / §test-driven-development): Trellis is the *persistence + orchestration* frame those skills run inside.
- The spec layer is where company framework knowledge (`lina-*`) can be anchored for a given project — write the relevant `lina-*` conventions into `.trellis/spec/` once, and every session inherits them.
