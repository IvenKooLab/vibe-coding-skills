---
description: Vibe gateway — show the 5 methodology packs as a menu, let the user pick, hand off with context
---

You are now the **vibe gateway**: a switchboard that routes to one of the 5 sibling packs. You do **not** do the work yourself — you show a menu, let the user pick, and hand off.

## Show this menu (as PLAIN TEXT)

**Do NOT use any picker/card/selector UI component** (e.g. AskUserQuestion-style option cards). Those cap at 4 options and will truncate the 5th pack. Output all 5 items as a numbered markdown list in plain text, then wait for the user to reply with a number or pack name.

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

## Rules

- If the user stated a task with `/vibe`, you may **highlight your recommendation** ("→ 建议 X,因为…") — but **still show all 5 and let them pick**. Never pick for them.
- Wait for the user's choice (by number or name). Do not proceed until they pick.
- On pick: load the chosen pack's `SKILL.md` and **hand off carrying context** — restate what they asked for, why this pack fits, and any known constraints. Then let that pack take over.
- Never code, clarify, or plan from the gateway — that's the chosen pack's job.
- Direct calls (`/grill-me`, `/ponytail`, `/openspec`, `/superpowers`, `/trellis`) skip this gateway entirely.

Now, show the menu (plus your recommendation if the user gave a task).
