# Vibe · 跨五包路由总开关

> 装了五个包,但记不住什么时候该用哪个?`/vibe` 是**总机**——你说一句话,它把五个兄弟包弹成菜单,每个带一句定位 + 推荐场景,你选一个,它带上下文转交。它是**路由器,不是方法论**——自己不写一行码、不做澄清、不做计划。

vibe-coding 合集的**唯一总入口**。对齐 grill-me 的最简单例(README + 单个 SKILL.md + 一个 slash command)。

---

## 这是什么

`/vibe` 解决一个问题:**五包在手,用哪个?**

- `superpowers` / `grill-me` / `ponytail` / `openspec` / `Trellis` 各管一段,但用户不会每次都记得"这个任务是 grill-me 的活还是 superpowers 的活"。
- `/vibe` 把这个判断变成一个**选择题**:弹菜单 → 用户选 → 转交。不替用户决定,只帮他看清选项。

**关键特征**:

- **纯路由,不干活**。一旦它开始自己编码/澄清/计划,它就越界了——那是被选中那个包的事。
- **菜单为主,推荐为辅**。用户带了任务来,`/vibe` 可以高亮推荐("→ 建议 X"),但永远让用户自己选。
- **带上下文转交**。选完后把"用户要什么 + 为什么选这个 + 已知约束"打包给目标包,不让它从零开始。
- **手动触发,不自动**。永远由用户 `/vibe` 发起,不抢占其他包的流程。

---

## 5 个兄弟包(两段式菜单)

`/vibe` 触发后,**两段式选择**——先选大类(4 张卡片),再选该类下的具体包。5 个包全在,不丢:

### 第一步:4 张大类卡片

```
你要做哪类事?选一个大类:

A. 动手前 · 澄清与计划 —— 需求还没想清楚 / 计划有隐患
   含:superpowers(brainstorming+writing-plans)、grill-me

B. 规格与契约 —— 需求要跨会话 / 团队共识 / 涉及内部框架
   含:openspec

C. 写码时 · 纪律与质量 —— 嫌 AI 写太啰嗦 / 过度设计
   含:ponytail

D. 跨会话与协作 —— 多 agent / 要记忆 / 团队共享
   含:Trellis
```

### 第二步:展开该类

- **选 A** → 展开两个包二选一:`1. (superpowers) 方法论全流程` / `2. (grill-me) 单点深度盘问`
- **选 B** → 直接是 `openspec`,转交
- **选 C** → 直接是 `ponytail`,转交
- **选 D** → 直接是 `Trellis`,转交

> **快捷**:直接回包名(`/vibe openspec` 或只说 `openspec`)跳过两步,立即转交。

---

## 工作流程

1. **两段式选包**(可带推荐)——先选 4 张大类卡片之一,再选该类下的具体包。用户若带任务来,高亮你的推荐,但仍让他选。也可直接回包名跳过两步。
2. **带上下文转交**——用户选定后,加载目标包,转交时带上:用户要什么 / 为什么选它 / 已知约束。然后退场,让目标包接管。
3. **可选:重新评估**——目标包完成一步后,`/vibe` 可重新浮出建议下一步(如 grill-me 收敛后 → 建议 superpowers 的 writing-plans)。这是**可选**的,默认单次转交即结束。

---

## 何时用 / 何时不用

**用**:

- 拿不准某个任务该走哪个包。
- 装了多个包,想要一个总入口分发。
- 触发:对 agent 说 `/vibe`、「用 vibe」「我不确定用哪个包」。

**不用**:

- 已经指名道姓(`/grill-me`、`/ponytail`、`/openspec`、`/superpowers`、`/trellis`)——直接去那个包,不用过菜单。
- 任务单一明确,直接干就行。
- 正在别的包的流程里——别打断它弹菜单。

---

## 怎么装

### Claude Code(全局)

```bash
mkdir -p ~/.claude/skills/vibe
cp SKILL.md ~/.claude/skills/vibe/
# slash command(可选,有了 /vibe 才能直接触发)
mkdir -p ~/.claude/commands
cp commands/vibe.md ~/.claude/commands/
```

### Claude Code(某项目)

```bash
mkdir -p <项目>/.claude/skills/vibe
cp SKILL.md <项目>/.claude/skills/vibe/
mkdir -p <项目>/.claude/commands
cp commands/vibe.md <项目>/.claude/commands/
```

### Qoder

复制 `SKILL.md` 到 `<项目>/.qoder/skills/vibe/SKILL.md`,字节同构。Qoder 的 slash command 在其 rule 层配置。

> 本包不带安装脚本——只有一个 SKILL.md + 一个 command,手动复制即可,符合 ponytail「能不写就不写」的精神。

---

## 验证(装完后)

启动会话,对 agent 说 `/vibe`。

✅ **预期**:AI **弹出 4 张大类卡片**(动手前/规格契约/写码时/跨会话),你选一个大类后展开该类下的具体包(如选"动手前"→ superpowers 或 grill-me 二选一);**等你选完**才继续;选中后**带上下文转交**给目标包,自己不干活。如果你带了任务(如 `/vibe 加个缓存`),它会高亮推荐某个大类/包,但仍让你选。也可以直接回包名跳过两步。

❌ **反例**:AI 自己开始分析需求 / 写码、或只显示 2-3 个选项漏掉其余、或没等你选就跳进某个包——都说明没生效。

---

## 和其他包的关系

- `/vibe` 是**入口层**,五个兄弟包是**执行层**。它不替代任何一个,只做分发。
- `/vibe` 与 `/superpowers` **互补不冲突**:`/superpowers` 是"开锁全流程",`/vibe` 是"一次性选哪个包"。可以 `/vibe` 选完 superpowers,也可以直接 `/superpowers` 跳过菜单。
- 直接 `/grill-me`、`/ponytail` 等会**跳过 `/vibe`**——gateway 只在"不确定用哪个"时才需要。

---

## 致谢与来源

- 本包为**自研**,无外部上游——它是 vibe-coding 合集的调度入口,把五个蒸馏包串成一个可分发的整体。
- 路由器思想借鉴 Nginx 式"入口转发":一个总机,N 个分机,总机不处理业务。
