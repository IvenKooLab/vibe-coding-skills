# Trellis · 把 spec / task / memory 持久化进仓库的工程框架

> AI 写码很快,但**每个会话都从零开始**——不记得你的项目、你的约定、你团队的需求。Trellis 把**规格(spec)、任务(task)、记忆(memory)持久化进仓库**,让任何编码 agent 都按你的工程标准干活,新会话能接上上一会的进度。

本包是 [mindfold-ai/Trellis](https://github.com/mindfold-ai/Trellis) 的**核心工作流精华蒸馏版**(中文说明 + 英文 `SKILL.md`),只取「meta 总览 + 开发循环 + 关键概念」;完整 CLI / hooks / `.trellis/` 脚本自动化需装上游。

---

## 这是什么 / 解决什么

| 能力 | 改变了什么 |
|---|---|
| **自动注入的 spec** | 在 `.trellis/spec/` 写一次约定,后续每个会话自动注入相关上下文,不用反复说 |
| **任务为中心的工作流** | PRD / 实现上下文 / review 上下文 / 任务状态都放 `.trellis/tasks/`,AI 工作结构化 |
| **项目记忆** | `.trellis/workspace/` 的日志保留上次发生了什么,新会话带着真实上下文开局 |
| **团队共享标准** | spec 在仓库里,一个人的踩坑规则全团队受益 |
| **多 agent 协作** | 通过持久事件日志协调多个 AI worker 进程 |

> 和单体 `CLAUDE.md` / `AGENTS.md` / `.cursorrules` 的区别:那些是有用的入口,但容易变成一面文字墙。Trellis 在它们外面包了**分层 spec、任务 PRD、工作流闸门、工作区记忆**——版本化、可 review、团队共享。

---

## 4 阶段循环

Trellis 跑一个带自动调用 skill(全量 harness 里是 sub-agent)的循环:

1. **Plan 计划** —— [[trellis-brainstorm]] **一次只问一个问题**直到 PRD 清晰;研究型事项交给 research sub-agent。产物:`prd.md`(轻量任务)或 `prd.md` + `design.md` + `implement.md`(复杂任务)。
2. **Implement 实现** —— 按 PRD 写码,相关 spec 自动注入。写码前先读对应 spec 索引 + 「开发前检查清单」(上游叫 `trellis-before-dev`)。先不提交。
3. **Verify 验证** —— [[trellis-check]] 对着 spec review diff,跑 lint / type-check / 测试,能自修就自修。
4. **Finish 收尾** —— 跑最终检查,把新学到的**回写到 `.trellis/spec/`** 让下个会话更聪明;归档任务、记会话日志。

> 「继续上次」是一等公民:加载当前上下文 → 判断该从哪个阶段/步骤接着干 → 继续(上游叫 `trellis-continue`)。

---

## 持久化模型(仓库里的三样东西)

| 表面 | 存什么 | 为什么重要 |
|---|---|---|
| **spec**(`.trellis/spec/`) | 项目约定、设计约束、编码标准 | 写一次 → 每个相关会话自动注入,不用重复 |
| **task**(`.trellis/tasks/`) | PRD、设计笔记、实现计划、研究、任务状态(父子树) | AI 工作结构化:被要求啥、拍了啥板、做完没,可 review |
| **memory**(`.trellis/workspace/` 日志 + 跨会话召回) | 上次发生了什么、决策和教训 | 新会话带真实上下文开局,不「失忆」 |

---

## 4 个 skills

| Skill | 定位 |
|---|---|
| `trellis` | 总览:持久化模型 + 4 阶段循环 + 何时用 Trellis vs 轻量方案 |
| `trellis-brainstorm` | 计划阶段:无情盘问式需求澄清(与 [[grill-me]] 同源)+ 第一性原理 + PRD 收敛闸门 |
| `trellis-check` | 验证阶段:spec 合规 + lint/type/test + 跨层数据流/复用/一致性 |
| `trellis-channel` | 多 agent 协作:持久事件日志 + 派生 worker + forum 议题板 |

> 💡 **skill 正文为英文**(省 token),中文说明看本 README。
>
> 本包未单独拆出 `trellis-before-dev` / `trellis-continue` / `trellis-finish-work`——它们是绑定 `.trellis/` 脚本的工作流「管道」,其要义(写码前先读 spec、能续接、收尾回写 spec)已并入 `trellis` 总览。`first-principles-thinking` 的精华并入 `trellis-brainstorm`(上游本就内联在那)。

---

## 何时用 / 何时不用

**用 Trellis**:项目跨会话、多 agent、团队共享——你愿意付出维护 spec/task/memory 的成本,换来不失忆、共享标准、可 review 的上下文。

**不用**:轻量、单人、短期、不需要跨会话记忆的项目——方法论层([[superpowers]]:brainstorming→writing-plans→test-driven-development→verification-before-completion)加 [[ponytail]] 就够了。**别交用不上的框架税。**

---

## 怎么装

### 想要完整自动化(推荐用于中大型项目)

```bash
npm install -g @mindfoldhq/trellis@latest   # 需 Node ≥18、Python ≥3.9
trellis init -u your-name                    # 在你的仓库初始化 .trellis/
# 或指定平台:trellis init --cursor --opencode --codex -u your-name
```

详见 [官方 Quick Start](https://docs.trytrellis.app/start/install-and-first-task)。

### 只想要本包的 skill 精华(轻量,Claude Code)

```bash
cp -r skills/* ~/.claude/skills/            # 全局
# 或:cp -r skills/* <项目>/.claude/skills/  # 某项目
```

Qoder 同理复制到 `<项目>/.qoder/skills/`,字节同构。

---

## 和其他技能的关系

- Plan 阶段 = [[trellis-brainstorm]](与 [[grill-me]] 同源)。Verify 阶段 = [[trellis-check]]。多 agent = [[trellis-channel]]。
- Trellis 在方法论层之上,是**持久化 + 编排**框架,让那些 skill 跑在里头。
- spec 层正好可以锚定公司框架知识(`lina-*`):把相关 `lina-*` 约定写进 `.trellis/spec/` 一次,每个会话自动继承。

---

## 致谢与来源

- 上游:[mindfold-ai/Trellis](https://github.com/mindfold-ai/Trellis)(**AGPL-3.0**)
- ⚠️ **License 注意**:Trellis 上游为 AGPL-3.0。本包仅做**方法论的蒸馏摘录与中文说明**(spec/task/memory 模型、4 阶段循环、brainstorm/check/channel 的可迁移原则),**未整体搬运其源码 / CLI / 脚本**。若你 `npm install` 使用上游完整 harness,或把 Trellis 源码纳入你的项目,请遵守 AGPL-3.0 的条款(含开源义务)。
