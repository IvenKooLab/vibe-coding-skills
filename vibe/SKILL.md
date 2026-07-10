---
name: vibe
description: Use when the user says "/vibe", "vibe", "用 vibe", "走 vibe", or wants help picking which vibe-coding methodology pack to use for a task before starting. A gateway that shows the 5 sibling packs as a numbered menu (each with its positioning + recommended scenario), lets the user pick by number or name, and hands off with context. Never auto-triggers; always user-invoked. Symptoms - the user isn't sure which pack fits, has multiple packs installed and can't remember when to use which, or wants a single entry point to dispatch from.
---

# Vibe — Gateway to the 5 Methodology Packs

## Overview

`/vibe` is a **switchboard, not a methodology**. When invoked, it shows the five sibling packs as a numbered menu, lets the user pick one, and hands off — carrying the requirement analysis with it so the chosen pack doesn't start from zero. It does **no coding, no clarifying, no planning itself**. It routes.

The point: the user shouldn't have to remember whether their task is a `grill-me` job or a `superpowers` job. They say `/vibe`, see the menu, pick, and go.

> This is a **reach-for-it** tool. It never auto-triggers — the user always invokes it deliberately.

## The 5 sibling packs (the menu)

When `/vibe` fires, output the menu below **as plain text**. Do **NOT** use any picker/card/selector UI component (e.g. AskUserQuestion-style option cards) — those cap at 4 options and will truncate the 5th. Output all 5 items as a numbered markdown list, then ask the user to reply with a number or pack name.

```
你要做哪类事?选一个(回编号或包名):

1. (superpowers) 方法论全流程 —— 推荐:多人协作 / 中大型项目
   动手前澄清→拆计划→TDD→系统化调试→完成前验证,一开就锁全流程

2. (openspec) 规格契约 —— 推荐:需求要跨会话/团队共识 / 涉及 Lina 框架
   把需求契约沉淀进仓库 spec;涉及 Lina 时路由到对应 lina-*

3. (grill-me) 单点深度盘问 —— 推荐:计划"差不多对了"但有没拍板的决策
   把计划当决策树逐枝走完,一次问一个,直到共识

4. (ponytail) 精简纪律 —— 推荐:嫌 AI 写太啰嗦 / 过度设计
   像最懒的资深开发,能不写就不写,能一行就一行

5. (Trellis) 工程框架 —— 推荐:多 agent 协作 / 需要跨会话记忆
   spec/task/memory 持久化 + 多 worker 编排
```

> If the user already stated their task when invoking `/vibe` (e.g. `/vibe 帮我加个导出功能`), you may **highlight your recommendation** in the menu ("→ 建议 1 或 4,因为…") — but **still let them choose**. Never pick for them.

## The 3-step protocol

### 1. Show the menu (and optionally recommend)

If the user gave a task with `/vibe`, read it and mark your recommendation, but show all 5 options. If they just said `/vibe` with no task, show the menu as-is. Ask them to pick by number or name.

**Wait.** Do not proceed until they pick.

### 2. Hand off with context

Once the user picks a pack, load that pack's `SKILL.md` and **hand off carrying context**:

- **What the user asked for** (their original requirement, restated in one line)
- **Why this pack was chosen** (the routing reason)
- **Anything already known** (constraints, files mentioned, prior decisions)

Then step back — the chosen pack takes over. You are the switchboard, not the executor.

### 3. Re-assess after each step (optional)

When the chosen pack finishes a step, `/vibe` *may* re-surface to suggest the next pack (e.g. after `grill-me` converges → suggest `superpowers` §writing-plans). This is **opt-in** — only do it if the user asked for multi-step routing. For a single-shot pick, `/vibe` hands off once and is done.

## When to use

- The user says `/vibe`, "用 vibe", "走 vibe", "我不确定用哪个包".
- The user has multiple packs installed and wants one entry point.
- The user isn't sure whether their task is a clarify / plan / debug / spec / framework job.

## When NOT to use

- The user already named a specific pack (`/grill-me`, `/ponytail`, `/openspec`, `/superpowers`, `/trellis`) — go straight to it, no menu needed.
- The user gave a crystal-clear, single-step task — just do it.
- The user is mid-flow in another pack — don't interrupt to show a menu.

## Anti-patterns (Never)

- **Never** do the work yourself — you route, the chosen pack executes. If you catch yourself coding/clarifying/planning, stop and hand off.
- **Never** pick a pack for the user without confirmation — always show the menu and let them choose, even when you have a strong recommendation (you may *highlight* it, not *enact* it).
- **Never** dump more than the 5-line menu — it's a switchboard, not a lecture. The detail lives in each pack.
- **Never** chain packs automatically without checking back — multi-step routing is opt-in; default is single-shot handoff.
- **Never** alter the chosen pack's process — load it and follow *its* rules; don't second-guess from the gateway.

## Collaborates with

- The 5 sibling packs are all routing targets: [[superpowers]], [[openspec]], [[grill-me]], [[ponytail]], [[trellis]].
- `/vibe` is the **entry layer**; the 5 packs are the **execution layers**. It does not replace any of them.
- Direct invocations (`/grill-me`, `/ponytail`, etc.) skip `/vibe` entirely — the gateway is for when you're not sure which one.
```
