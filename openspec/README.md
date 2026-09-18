# OpenSpec · 规格契约层 + 内部框架知识中转

> AI 写码容易「各说各的」——上次会话拍板的需求,这次又得重讲一遍;或者你问「这个功能到底要干嘛」,三个人三个版本。OpenSpec 把**需求和契约沉淀进仓库**,让任何会话都对着**唯一可信基线**干活。同时,涉及企业内部框架时,它像 superpowers 那样**一带多**,把你路由到对应的框架 skill(示例 `your-framework-*`)。

本包是 [Fission-AI/OpenSpec](https://github.com/Fission-AI/OpenSpec)(MIT)的核心工作流**蒸馏版** + 内部框架知识层的**中转索引**(占位示例),中文说明 + 英文 `SKILL.md`,与 grill-me 同为最简单例(README + 单个 SKILL.md)。

---

## 这是什么 / 解决什么

一个 skill,两层职责,**正交**:

| 层 | 管什么 | 解决什么 |
|---|---|---|
| **Part A · 规格契约层** | 做什么 / 契约 / 沉淀 | 需求反复重讲、跨会话/跨人对不上口径、AI 偏离已定契约 |
| **Part B · 框架知识中转** | 涉及内部框架时,路由到对的 `your-framework-*` | 不用自己推「用哪个 starter、怎么配」,一个总入口分流到 若干框架模块 |

> **红线(记死这条)**:OpenSpec 管「做什么 + 契约」,Superpowers 方法论([[superpowers]] 的 brainstorming / writing-plans / test-driven-development 等纪律)管「怎么做 + 质量」。一件事只由一套主导,互不越界。skill 只读 spec、不修改需求基线。**轻量项目可以完全不引入 OpenSpec**,只用方法论层。

---

## Part A:OpenSpec 方法论

### 哲学

- **fluid not rigid**——spec 会演进,不是刻在石头上。提一个 delta、评审、合并。
- **iterative not waterfall**——同一个功能可以反复走 explore → propose → apply → archive。
- **brownfield not just greenfield**——存量项目本来就有(隐式)spec,第一步是把它显式化,不是推倒重来。

### 4 阶段循环

| 阶段 | 上游命令 | 做什么 | 改 spec 吗 |
|---|---|---|---|
| **1. Explore 探索** | `/opsx:explore` | 读代码、读现有 spec,摸清现状,为 proposal 备好要问的问题 | 否(只读) |
| **2. Propose 提案** | `/opsx:propose` | 产出**四件套**:`proposal.md` + `specs/`(delta)+ 可选 `design.md` + `tasks.md`。用户评审后才动手 | 提 delta,尚未应用 |
| **3. Apply 实现** | `/opsx:apply` | 按 `tasks.md` 写码;spec delta 是验收基线——「完成」= 现实与 delta 的 Specs 段一致 | 代码逼近 spec |
| **4. Archive 归档** | `/opsx:archive` | 把变更归档到 `openspec/changes/archive/`,**把 spec delta 回写进 `openspec/specs/`** | 是——这里才更新 spec |

> 方法论不依赖上游 CLI。四个阶段是纪律:装了上游(`/opsx:*` 命令)自动化记账,不装就手动按四阶段走,逻辑一样。

### 四件套(沉淀在仓库里的东西)

| 产物 | 存什么 | 为什么重要 |
|---|---|---|
| **`proposal.md`** | 为什么改、范围内外、决策与备选 | 「为什么」活得过作者。未来会话或评审读这个,不用猜 |
| **`specs/`(delta)** | 规格的**变更**——落地后什么将为真,写成 spec delta | 可协商的部分。评审后合并;应用后不静默改 |
| **`design.md`**(可选) | 技术设计:数据模型、时序、取舍 | 只给复杂变更;trivial 的别付仪式税 |
| **`tasks.md`** | 有序、可勾选的实现清单 | 执行契约。apply 走它;完成 = 全部勾选且 spec delta 成立 |

### 进入 Apply 前的闸门

动手前确认:proposal 有**可测的**验收标准(不是「弄好点」);代码能答的问题已经**读**出来、没问用户;用户已评审或明确放行。(与 [[grill-me]] 同源——动手前把软肋逼出来。)

---

## Part B:内部框架知识中转

涉及内部框架时,新建微服务、加中间件、数据访问、缓存、消息、权限、定时任务、监控、模板),**别在这里重新推框架怎么用**——路由到对的 `your-framework-*` skill,照它的规范走。本 skill 是总机,框架 skill 是分机。(单一数据源——它们的内容在你的 skill 库里,这里不复制。)

### 框架速查表（占位示例）

公开版只保留路由模式示意;把 `your-framework-*` 换成你自己的框架 skill 即可:

| 路由到 | 管什么 | 典型触发 |
|---|---|---|
| `your-framework-base` | 脚手架/多环境配置 | 新建项目 |
| `your-framework-cache` | 缓存与分布式锁 | cache、lock |
| `your-framework-mq` | 消息队列 | 收发消息 |

## 何时用 / 何时不用

**用**:

- 需求要跨会话存活,或多人/多 agent 必须对契约达成一致。
- 工作涉及内部框架,需要对应模块的规范。
- 触发:对 agent 说 `/openspec`、「启用 openspec」「走 spec-driven」「写规格」「提个 proposal」。

**不用**:

- 轻量、单人、短期、不需要跨会话记忆——方法论层 + [[ponytail]] 够了,**别交用不上的规格税**。
- 正在排查具体 bug——用 [[superpowers]] 的 systematic-debugging 纪律(可以**读** spec 理解预期行为,但别在 bug 中途跑 propose 循环)。
- 任务不碰任何内部框架模块——Part B 无可路由;若你想要契约留痕,Part A 仍可单独用。

---

## 怎么装

### Claude Code(全局)

```bash
mkdir -p ~/.claude/skills/openspec
cp SKILL.md ~/.claude/skills/openspec/
```

### Claude Code(某项目)

```bash
mkdir -p <项目>/.claude/skills/openspec
cp SKILL.md <项目>/.claude/skills/openspec/
```

### Qoder

复制 `SKILL.md` 到 `<项目>/.qoder/skills/openspec/SKILL.md` 即可,与 Claude Code 字节同构。

> 本包不带安装脚本——只有一个 `SKILL.md`,手动复制即可,符合 ponytail「能不写就不写」的精神。

---

## 验证(装完后)

启动会话,给一个还没拍板的需求(比如「给报表模块加导出,要支持多数据源切换」),说 `/openspec`。

✅ **预期**:AI 先 **explore**(读现有 spec/代码,摸清现状);再 **propose** 出四件套(`proposal.md` 明确范围与决策、`specs/` 写 delta、必要时 `design.md`、`tasks.md` 拆成可勾选清单),**等你评审才动手**;实现走 Apply;收尾 Archive 把 delta 回写 `openspec/specs/`。涉及内部框架时,它会**路由到对应 `your-framework-*` skill**(如多数据源 → `your-framework-*`),而不是自己凭空写配置。

❌ **反例**:AI 没等你评审 proposal 就开始写码、或把 `your-framework-*` 的配置内容抄进对话而不是引用 skill、或把 OpenSpec 和 Trellis 混为一谈——都说明没生效。

---

## 和其他包的关系

在现有「四个包 + 分层」坐标系里,OpenSpec 是第五个包:

- **与 [[trellis]] 并列**(都偏工程框架层):Trellis 管 spec/task/memory 的**持久化 + 多 agent 编排**;OpenSpec 管**需求契约的提案 → 归档**。重项目可叠加——OpenSpec 谈契约,Trellis 保契约 + 任务 + 记忆跨 agent 一致。
- **与 superpowers 方法论层正交**:OpenSpec = 做什么/契约;[[superpowers]] 的 brainstorming/writing-plans/test-driven-development/verification-before-completion 纪律 = 怎么做/质量。红线见上文。
- **`your-framework-*` 是「用什么」**(框架知识层,团队已有),本 skill 的 Part B 是**去那里的路由器**——像 superpowers 一带多那样,一个总入口分流。

---

## 致谢与来源

- 上游:[Fission-AI/OpenSpec](https://github.com/Fission-AI/OpenSpec)(**MIT**)
- 本包 Part A 为其 4 阶段工作流(explore/propose/apply/archive)+ 四件套(proposal/specs/design/tasks)的**方法论蒸馏摘录与中文说明**,未整体搬运其 CLI/源码;若 `npm install` 使用上游完整工具,请遵守 MIT 条款。
- Part B 的 `your-framework-*` 随你的 skill 库(本机 `~/.zcode/skills/` 下),本包只做中转索引,不复制内容。
