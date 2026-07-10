---
name: vibe
description: Use when the user says "/vibe", "vibe", "用 vibe", "走 vibe", or wants help picking which vibe-coding methodology pack to use for a task before starting. A gateway that shows the 5 sibling packs as a numbered menu (each with its positioning + recommended scenario), lets the user pick by number or name, and hands off with context. Never auto-triggers; always user-invoked. Symptoms - the user isn't sure which pack fits, has multiple packs installed and can't remember when to use which, or wants a single entry point to dispatch from.
---

# Vibe — Gateway to the 5 Methodology Packs

## Overview

`/vibe` is a **switchboard, not a methodology**. When invoked, it shows the five sibling packs as a numbered menu, lets the user pick one, and hands off — carrying the requirement analysis with it so the chosen pack doesn't start from zero. It does **no coding, no clarifying, no planning itself**. It routes.

The point: the user shouldn't have to remember whether their task is a `grill-me` job or a `superpowers` job. They say `/vibe`, see the menu, pick, and go.

> This is a **reach-for-it** tool. It never auto-triggers — the user always invokes it deliberately.

## The 5 sibling packs (two-step menu)

The 5 packs are grouped into **4 categories** so they fit a 4-option picker card (pickers cap at 4). Two steps: pick a category, then pick the pack inside it. No pack is lost — all 5 are reachable.

### Step 1 — show 4 category cards

Present these 4 as selectable options (use the picker card UI if available; otherwise a numbered list):

```
你要做哪类事?选一个大类:

A. 动手前 · 澄清与计划 —— 需求还没想清楚 / 计划有隐患
   含:superpowers(brainstorming+writing-plans)、grill-me

B. 规格与契约 —— 需求要跨会话 / 团队共识 / 涉及 Lina 框架
   含:openspec

C. 写码时 · 纪律与质量 —— 嫌 AI 写太啰嗦 / 过度设计
   含:ponytail

D. 跨会话与协作 —— 多 agent / 要记忆 / 团队共享
   含:Trellis
```

### Step 2 — expand the chosen category

Once the user picks a category, show the pack(s) inside it and let them pick the exact one:

- **A picked** →
  ```
  A 类里有两个包,选哪个?
  1. (superpowers) 方法论全流程 —— 推荐:多人协作 / 中大型项目
     动手前澄清→拆计划→TDD→系统化调试→完成前验证,一开就锁全流程
  2. (grill-me) 单点深度盘问 —— 推荐:计划"差不多对了"但有没拍板的决策
     把计划当决策树逐枝走完,一次问一个,直到共识
  ```
- **B picked** → 直接是 `openspec`,无需二选,直接转交。
- **C picked** → 直接是 `ponytail`,无需二选,直接转交。
- **D picked** → 直接是 `Trellis`,无需二选,直接转交。

> If the user already stated their task with `/vibe` (e.g. `/vibe 帮我加个导出功能`), you may **highlight your recommended category/pack** ("→ 建议 A 类的 superpowers,因为…") — but **still let them choose**. Never pick for them.
>
> Shortcut: if the user replies with a pack name directly (`/vibe openspec` or just `openspec`), skip both steps and hand off to that pack immediately.

## Handoff protocol (after the user picks)

Once the user picks a pack (via the two-step menu or a direct pack name), load that pack's `SKILL.md` and **hand off carrying context**:

- **What the user asked for** (their original requirement, restated in one line)
- **Why this pack was chosen** (the routing reason)
- **Anything already known** (constraints, files mentioned, prior decisions)

Then step back — the chosen pack takes over. You are the switchboard, not the executor.

### Re-assess after each step (optional)

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
