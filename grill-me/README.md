# Grill-Me · 动手前的「无情盘问」

> 计划看起来「差不多对了」,但你知道里面藏着没说清的决策。`grill-me` 就是把这些软肋一个个逼到台面上——**逐个问题、一次一个**,直到你和 AI 对这个计划达成真正的共识,再动手写码。

---

## 这是什么

`grill-me` 跑一场**无情的盘问**:把计划当成一棵决策树,逐枝走完,每一步都把隐含的假设变成显式的决定。目标不是「快点达成一致」,而是「让每个重要假设都被看见」。

它来自 [mattpocock/skills](https://github.com/mattpocock/skills/tree/main/skills/productivity/grill-me) 的 `grill-me` / `grilling`,本包是其中文说明 + 英文 `SKILL.md` 的蒸馏版。

**关键特征**:

- **一次性只问一个问题**,问完就等。绝不一次性甩一堆问题(那会让人懵)。
- **每个问题都带上 AI 自己的推荐答案**——你是对着一个提案表态,不是对着空白提示词发呆。
- **能读代码回答的,就去读代码**,不问用户。只问代码答不了的产品意图 / 偏好 / 范围 / 风险偏好。
- **达成共识前不动手实现**。

> 💡 **无状态**:`grill-me` 不写任何文件、不留工作区,唯一的产物就是对话里被磨利的共识本身。(上游还有个有状态孪生 `grill-with-docs`,会把同样的盘问沉淀成 ADR + 术语表;本包只取无状态版。)

---

## 何时用

- 你有个计划,「感觉差不多对了」,但你知道里面藏着没拍板的决策——想把软肋在写码前逼出来。
- 触发:对 agent 说 `/grill-me`、「拷问我」「盘问一下这个方案」「stress-test this plan」。

**何时不用**:

- 需求已经清清楚楚、毫无歧义——盘问就是走过场。
- 正在排查一个具体 bug——用 [[systematic-debugging]]。
- 它**不会自动触发**,永远由你主动发起。

---

## 和其他技能的关系

| 技能 | 定位 | 与 grill-me 的关系 |
|---|---|---|
| `grill-me`(本包) | 单点深度盘问 | 把一个计划问透,逐枝走完决策树 |
| `superpower/brainstorming` | 工作流开场澄清 | 偏「完整流程的开场」;grill-me 偏「单点深挖」,可叠加 |
| `superpower/writing-plans` | 共识达成后拆计划 | grill-me 走完的决策树,正好变成计划的骨架 |

一句话:**`grill-me` 是动手前的压力测试,`verification-before-completion` 是收工前的验证**,一头一尾。

---

## 怎么装

### Claude Code(全局)

```bash
mkdir -p ~/.claude/skills/grill-me
cp SKILL.md ~/.claude/skills/grill-me/
```

### Claude Code(某项目)

```bash
mkdir -p <项目>/.claude/skills/grill-me
cp SKILL.md <项目>/.claude/skills/grill-me/
```

### Qoder

复制 `SKILL.md` 到 `<项目>/.qoder/skills/grill-me/SKILL.md` 即可,与 Claude Code 字节同构。

> 安装后对 agent 说 `/grill-me` 或「拷问我这个计划」即可触发。本包不带安装脚本——只有一个 `SKILL.md`,手动复制即可,符合 ponytail「能不写就不写」的精神。

---

## 验证(装完后)

启动会话,贴一个还没完全想清楚的计划(比如「给用户模块加批量导出」),说 `/grill-me`。

✅ **预期**:AI **一次只问一个问题**,每个问题都带它的推荐答案和取舍;**先读你的代码**再决定哪些要问、哪些自己能答;在你确认共识前**不写一行实现代码**。

❌ **反例**:AI 一次甩出 5 个问题、或问你「要不要我搜一下代码」这种流程问题、或没等你拍板就开始写——都说明没生效。

---

## 致谢与来源

- 上游:[mattpocock/skills](https://github.com/mattpocock/skills) · `skills/productivity/grill-me`(含 `grilling` 原语、`grill-with-docs` 有状态孪生)
- 本包为其中文说明 + 英文 `SKILL.md` 的蒸馏摘录,License 随上游。
