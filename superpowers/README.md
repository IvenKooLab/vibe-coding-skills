# Superpowers · 方法论层(5 纪律)

> 把 superpowers 的"AI 怎么干活"工作方法论,沉淀为一个**同时适用于 Claude Code、Qoder、Trae**的标准 skill,补上公司 skill 库缺位的"方法论层"。

本包是 [obra/superpowers](https://github.com/obra/superpowers)(MIT)+ 公司 `lina-*` 的中文说明 + 英文 `SKILL.md` 蒸馏版,与 grill-me / ponytail / openspec / Trellis 结构对齐(一包一 SKILL.md)。

---

## 这是什么

superpowers(obra/superpowers)的本质不是某个框架教程,而是一套工程纪律:**动手前先澄清需求、写码前先拆计划、实现前先写测试、排查走系统化调试、完成前先跑验证**。

摸底公司现有 skill 发现:大多是**框架知识层**(`lina-*`——告诉 AI"用什么"),但"怎么干"这套工作流是缺位的。本包就是来填这个坑的。

> 💡 **5 个纪律已合并进单个 `superpowers` skill**(`skills/superpowers/SKILL.md`,315 行,英文正文,省约 30% token);中文说明看本 README。

---

## 5 个方法论纪律

| 纪律 | 中文名 | 什么时候用 / 做什么 |
|---|---|---|
| `brainstorming` | 需求澄清 | 新增功能/重构/修复杂 bug 前——先提问澄清、给 2-3 个方案、分块确认,确认后再动手 |
| `writing-plans` | 编写实施计划 | 需求确认后、动手前——拆成 2-5 分钟可执行任务,每个含文件路径 + 验证步骤 |
| `test-driven-development` | 测试驱动开发 | 写/改业务逻辑、修 bug——先写会失败的测试(RED),再写最小实现(GREEN),再重构 |
| `systematic-debugging` | 系统化调试 | 排查 bug/报错/性能异常——稳定复现 → 找根因(不靠猜)→ 最小修复 → 验证 |
| `verification-before-completion` | 完成前验证 | 声称"完成"前——实跑构建/测试/lint,给可核对证据,禁止"应该没问题" |

**默认顺序**:`/superpowers` 开启后,每个任务依次走 brainstorming → writing-plans → test-driven-development →(遇问题)systematic-debugging → verification-before-completion。这是默认链,不是强制全跑——按任务挑对应的纪律用即可。

> **不重造轮子**:本套是方法论层,与现有 `lina-*` 框架知识层互补——本套管"怎么干",`lina-*` 管"用什么"。

---

## 何时用 / 何时不用

**用**:

- 新功能 / 重构 / 修复杂 bug / 技术选型——动手前想走标准流程
- 想"一开就锁全流程",本会话后续任务自动按 5 步走
- 触发:对 agent 说 `/superpowers`、「启用 superpowers」

**不用**:

- 任务单一明确,直接干就行
- 排查具体 bug → 单独用 systematic-debugging 纪律,不必开整个开关
- 轻量项目不想付全流程税 → 用 [[grill-me]] 单点盘问 + [[ponytail]] 精简即可

---

## 怎么装

### Claude Code(全局)

```bash
mkdir -p ~/.claude/skills/superpowers
cp skills/superpowers/SKILL.md ~/.claude/skills/superpowers/
```

### Claude Code(某项目)

```bash
mkdir -p <项目>/.claude/skills/superpowers
cp skills/superpowers/SKILL.md <项目>/.claude/skills/superpowers/
```

### Qoder / Trae

复制 `skills/superpowers/SKILL.md` 到 `<项目>/.qoder/skills/superpowers/SKILL.md` 或 `<项目>/.trae/skills/superpowers/SKILL.md`,字节同构。

> 装好后对 agent 说 `/superpowers` 或「启用 superpowers」即激活;说「停用 superpowers」退出。本包按 ponytail 精神**不附安装脚本**——手动 `cp` 即可,和其他兄弟包一致。

---

## 验证(装完后)

让 AI「加一个导出功能」。

✅ **预期**:AI 先走 brainstorming(提问澄清、给 2-3 方案、分块确认),再走 writing-plans(拆成 2-5 分钟可执行任务),实现走 TDD,完成前走 verification 实跑验证给证据。

❌ **反例**:AI 不问需求直接写码、或不跑测试就说"完成"——说明没生效。

---

## 分层模型:与现有 skill、与 OpenSpec 的关系

```
┌──────────────────────────────────────────────┐
│  方法论层(本包 5 纪律)=「怎么干」            │
│  brainstorming → writing-plans → TDD →        │
│  systematic-debugging → verification          │
└──────────────────────────────────────────────┘
                    ↓ 调用 / 交叉引用
┌──────────────────────────────────────────────┐
│  框架知识层(公司已有)=「用什么」             │
│  lina-* · lina-redis · lina-rabbitmq · ...    │
└──────────────────────────────────────────────┘
```

**与 [[openspec]](规格层)**:遵循大厂共识的权责隔离——

> OpenSpec 管「契约与沉淀」(做什么),本包管「流程与质量」(怎么做),一件事只由一套主导,互不越界。

- 轻量项目(单人、短期、无合规)→ 只用本包,不引 OpenSpec。
- 复杂项目(多团队、支付交易、合规审计)→ OpenSpec 定需求基线,本包管执行,二者串联。
- **红线**:本包不越界定义需求基线,只读取 spec。

---

## 致谢与来源

- 上游:[obra/superpowers](https://github.com/obra/superpowers)(MIT)
- 本包为其 5 个核心 skill(brainstorming/writing-plans/test-driven-development/systematic-debugging/verification-before-completion)的**方法论蒸馏摘录与中文说明**,合并为单文件 `SKILL.md`,License 随上游 MIT。
- 跨工具 skill 编写规范见顶层 [`docs/skill编写规范.md`](../docs/skill编写规范.md)。
