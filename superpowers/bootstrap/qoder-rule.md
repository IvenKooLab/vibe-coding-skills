---
trigger: always_on
alwaysApply: true
---

# Superpowers 工作方法论(华安增强版)

> 此文件为 Qoder 引导规则,`trigger: always_on` 表示始终生效(所有智能会话与内联对话)。安装器会将其写入 `<项目>/.qoder/rules/superpowers-sinosafe.md`。Skill 文件位于 `.qoder/skills/<name>/SKILL.md`,与 Claude Code 同构。

> **一键开关**:说一句**"启用 superpowers"**(或输入 `/superpowers`),本会话后续所有任务自动按下文流程执行,无需逐个调用 skill。说"停用 superpowers"即可退出。

## 核心规则(始终生效)

1. **收到任务先查 skill**——哪怕只有很小的可能性匹配,也要先查有没有对应的 skill 并按其流程执行,不要直接动手。
2. **设计先于编码**——收到功能/重构类需求,先用 superpowers 的 `brainstorming` 纪律澄清,确认后再动手。
3. **计划先于实现**——需求确认后,用 `writing-plans` 纪律拆成可执行任务,再逐个实现。
4. **测试先于实现**——写业务逻辑前先写会失败的测试(`test-driven-development` 纪律)。
5. **系统化调试**——排查问题用 `systematic-debugging` 纪律,拒绝"改改试试"。
6. **验证先于宣布完成**——声称"完成"前必须实跑验证并给证据(`verification-before-completion` 纪律)。

## 优先级

**用户显式指令 > 本 skill 集 > 默认行为。** 用户明确说"别用 TDD""直接写别问了",就照用户的。

## 方法论层 skill(superpowers,5 个纪律)

方法论层为一个单 skill `superpowers`,位于 `.qoder/skills/superpowers/SKILL.md`,内含 5 个纪律。

| 纪律 | 何时用 |
|---|---|
| `brainstorming` | 新增功能/重构/修复杂 bug/技术选型前——先澄清需求、探索方案、分块确认 |
| `writing-plans` | 需求确认后、动手前——拆成 2-5 分钟可执行任务,含文件路径+验证步骤 |
| `test-driven-development` | 写/改业务逻辑、修 bug——RED-GREEN-REFACTOR,先写失败的测试 |
| `systematic-debugging` | 排查 bug/报错/性能异常——复现→根因→最小修复→验证 |
| `verification-before-completion` | 声称"完成"前——实跑构建/测试/lint,给可核对证据 |

## 与现有 skills 协作(分层)

- **方法论层**(上表)= 怎么干;**框架知识层**(`lina-*`)= 用什么。两者互补。
- 涉及 Lina 框架 → 查 `lina-framework-base`、`lina-redis`、`lina-rabbitmq` 等;涉及 Java 规范 → 参考阿里巴巴 Java 开发手册。
- 复杂项目:需求/设计契约由 OpenSpec 沉淀,本 skill 集只管执行,不越界定义需求基线。

## 如何使用

当任务匹配某纪律的"何时用"时,读取 `.qoder/skills/superpowers/SKILL.md` 中对应章节并严格遵循其流程。也可输入 `/superpowers` 调用整个方法论层。
