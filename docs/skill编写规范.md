# Skill 编写规范(Claude Code + Qoder 通用)

> 适用于所有 AI 编程 skill。一套写法,同时吃下 Claude Code 与 Qoder(以及任何兼容 SKILL.md 格式的工具)。
>
> 本规范沉淀自 superpowers(obra/superpowers)官方 `writing-skills` 元规范、agentskills.io 跨工具规格,以及中文社区版(superpowers-zh)对 Qoder 的适配实现。

---

## 0. 一句话核心

**一份 `SKILL.md`,两处生效。** Claude Code 和 Qoder 的 skill 文件**字节级同构**——superpowers-zh 的安装器对两个工具走的是同一段拷贝逻辑,同一份 `SKILL.md` 原样复制到 `.claude/skills/` 与 `.qoder/skills/`,不做任何转换。

因此:**只维护一份源,分发到各工具目录。** 不要为不同工具写不同版本。

---

## 1. 目录布局

| 工具 | skill 落点 | 引导/触发落点 |
|---|---|---|
| Claude Code(全局) | `~/.claude/skills/<name>/SKILL.md` | 追加到项目根 `CLAUDE.md`(见 §6) |
| Claude Code(项目级) | `<项目>/.claude/skills/<name>/SKILL.md` | 同上 |
| Qoder(阿里 AI IDE) | `<项目>/.qoder/skills/<name>/SKILL.md` | `<项目>/.qoder/rules/<name>.md`(配 `trigger`) |

一个 skill 是**一个目录**,目录里至少有一个 `SKILL.md`:

```
creating-skills/
├── SKILL.md          # 必需:metadata + 指令
├── references/       # 可选:重型参考文档(按需加载)
├── assets/           # 可选:模板、示例数据
└── examples.md       # 可选:示例(按需加载)
```

> **目录名必须等于 frontmatter 里的 `name` 字段。** 这是硬约束。

---

## 2. Frontmatter 规范

SKILL.md 顶部 YAML frontmatter,**只有两个字段是必需且关键**:

```yaml
---
name: creating-skills
description: 在任何创造性工作开始之前使用——通过提问澄清真实意图、探索备选方案、分块呈现设计供确认。
---
```

### `name`(必填)

- 仅小写字母 `a-z` / 数字 `0-9` / 连字符 `-`;≤64 字符。
- **kebab-case**,且**必须 = 目录名**。
- 动词优先、动名词(`-ing`)适合流程类:`creating-skills` 优于 `skill-creation`;`systematic-debugging` 优于 `debugging-techniques`。
- 即使正文全中文,**`name` 永远用英文 slug**(便于做目录名、slash command、工具链兼容)。

### `description`(必填,★ 最关键的字段)

`description` 是 AI 判断"现在该不该用这个 skill"的**唯一信号**。七条铁律:

1. **第三人称**(它会进 system prompt,第一人称会导致发现问题)。
2. **以触发措辞开头**:中文"在……时使用 / ……时使用",英文"Use when…"。
3. **只写"何时用"(WHEN TO USE),绝不概括"它怎么做"(WHAT IT DOES)**。这是最高频反模式:一旦 description 概括了流程,AI 会照着描述走捷径、**跳过精读正文**。
4. **含具体关键词**:报错原文、症状词、工具/文件名、同义词(如 timeout/hang/freeze;cleanup/teardown)。
5. **长度 ≤1024 字符**,建议 **<500 字符**。
6. 描述**问题本身**(race condition),而非某个语言的特有症状,除非 skill 本身就是技术特定的。
7. **不要**包含版本号、过期时间等时效信息。

好坏对照:

```yaml
# BAD(概括了流程 → AI 会跳过正文)
description: 执行实施计划时使用——为每个任务派遣子代理,任务间做代码审查

# BAD(第一人称)
description: 我可以帮你澄清需求

# GOOD(只写何时用,含触发场景)
description: 在新增功能、重构、修复杂 bug 等创造性工作开始之前使用——通过提问澄清真实意图、探索备选方案、分块呈现设计供确认。症状:用户给出含糊需求、直接说"开始写"、或需求存在多种合理解读时。
```

> **可选字段**(agentskills.io 规格,日常基本不用):`license`、`compatibility`(≤500 字符,有特殊环境需求时)、`metadata`(键值对,加前缀防冲突)、`allowed-tools`(实验性,各工具支持不一)。**Qoder 的 SKILL.md 不支持 `trigger`/`globs` 字段**——触发控制在 Qoder 的 **rule** 层做(见 §6),不要写在 skill 里。

---

## 3. 正文结构

推荐章节骨架(按需裁剪,不是每节都要):

```markdown
# Skill 标题

## Overview              ← 1-2 句核心原则,点明"这skill管什么"
## 何时使用              ← 触发场景 + 症状(SYMPTOMS)+ 何时【不】适用
## 流程 / 核心原则       ← 编号步骤、检查清单或核心原则(Before/After 对比)
## 示例                  ← 具体、可复用的例子(非抽象描述)
## 反模式(Never)        ← 常见错误 + 纠正
## 与现有 skills 协作    ← 交叉引用(本套方法论的特色)
```

写作要点:

- **流程用编号列表**,不要用流程图节点装代码;决策点可用小型流程图。
- **检查清单用表格或 `- [ ]`**。
- **例子要具体**(真实代码/场景),不要"在某次会话中……"这种不可复用的叙述。
- **反模式用"❌ 坏 / ✅ 好"对照**。

---

## 4. 渐进式披露(Progressive Disclosure)

这是性能与成本的关键。AI 对 skill 是**三层加载**:

| 层级 | 加载时机 | 容量目标 |
|---|---|---|
| Metadata(`name`+`description`) | 启动时**所有** skill 全加载 | ~100 token / skill |
| `SKILL.md` 正文 | 该 skill 被激活时才加载 | **<500 行 / <5000 token** |
| 参考文件 / 脚本 | AI 判断需要时才读取 | 无上限(读之前不耗 token) |

判据:

- **正文 <500 行**。逼近上限时,**把重型参考(100+ 行的 API 文档、综合语法、大表格)拆到同级独立文件**,在正文用相对链接引用。
- **引用只允许一层深**(`SKILL.md → references/foo.md`),禁止 `a.md → b.md → c.md` 多层嵌套——AI 遇到嵌套引用只 `head` 预览,信息会丢。
- **不要用 `@path` 强制加载**引用文件(会瞬间灌爆 context);用 skill 名 + 显式标记:`详见 [[superpowers]]`。
- **路径永远用正斜杠 `/`**,即使 Windows。
- **>100 行的参考文件**在文件头加目录(Table of Contents)。

---

## 5. 触发机制:两种工具的差异

| | Claude Code | Qoder |
|---|---|---|
| skill 发现 | 自动扫描 skills 目录,按 `description` 关键词匹配 + 模型决策 | 同(扫描 `.qoder/skills/`,按 description 匹配) |
| "总先查 skill"行为 | 由 `CLAUDE.md` 引导段承载(见 §6) | 由 `.qoder/rules/*.md` 配 `trigger: always_on` 承载 |
| SKILL.md 支持 `trigger` 字段? | 否 | **否**(只在 rule 层支持) |

**结论**:skill 文件本身不区分工具;让"AI 动手前先查 skill"这个行为生效,靠的是**引导层**(§6),不是 skill 正文。

### 自动触发 vs 手动(参考资料型)skill

这是**软约定,不是 frontmatter 字段**。靠两处区分:

| 维度 | 自动触发型(工作流) | 手动型(参考资料) |
|---|---|---|
| description 措辞 | 强祈使:"在……时使用""每当……""先于……" | 陈述句:"……的规范/清单/模板" |
| 正文结构 | 流程骨架 + 检查清单 + 终止态 | 纯表格 / 模板 / 字典 |
| 调用方式 | AI 主动判断触发 | 用户显式 `/name` 调用 |

> 设计手动型 skill 时,正文写成大量参考资料、不写"流程顺序/终止状态",AI 加载后只当资料引用,不会自动跑流程——这能避免污染其它工作流 skill 的自动调度。

---

## 6. 引导层:让"总先查 skill"生效

superpowers 的灵魂是"**哪怕只有很小的可能性,也要先查有没有匹配的 skill**"。这个行为在两个工具里分别由引导文件承载(本仓库 `bootstrap/` 已备好模板):

**Claude Code** —— 追加到项目根 `CLAUDE.md`(用哨兵注释包裹,便于精确卸载):

```
<!-- superpowers-yourorg:begin -->
… 核心规则 + 可用 skills 索引表 …
<!-- superpowers-yourorg:end -->
```

**Qoder** —— 独立文件 `.qoder/rules/superpowers-yourorg.md`,frontmatter:

```yaml
---
trigger: always_on
alwaysApply: true
---
```

Qoder rule 的三种触发模式:`always_on`(始终生效,引导用此)、`model_decision`(按 description 自主决定)、`manual`(仅 `@rule` 触发)。

> 安装由 `install/install.sh`(或 `.ps1`)自动处理;引导内容详见 `bootstrap/`。

---

## 7. 中英混排与命名约定

- **`name` 永远英文 slug**(§2)。
- **技术术语保留英文**:变量/函数/类名始终英文;`Redis`、`MySQL`、`API`、`SDK`、`RBAC`、`TDD`、`commit message` 的 type(feat/fix/docs)等不翻译。
- **业务逻辑、注释、文档用中文**。
- **盘古之白**:中文与英文/数字之间加一个空格。
  - ✅ `使用 Redis 缓存来减少 MySQL 的查询压力`
  - ❌ `使用Redis缓存来减少MySQL的查询压力`
- **不要机翻味**:技术文档读起来要像中文工程师写的,不是翻译软件产物。

---

## 8. 与现有 skills 协作(分层模型)

skill 库分两层,**互补不重叠**(以企业内部框架为例):

| 层 | 管什么 | 代表 skill |
|---|---|---|
| **方法论层**(本套) | 怎么干(动手前澄清、完成前验证、TDD) | `superpowers`(单 skill,内含 brainstorming / writing-plans / test-driven-development / systematic-debugging / verification-before-completion 5 个纪律) |
| **框架知识层**(已有) | 用什么(内部框架、中间件) | `your-framework-base`、`your-framework-redis`、`your-framework-mq` 等(占位示例) |

**一键开关(总开关 skill)**:方法论层是一个单 skill `superpowers` + Claude Code 的 `/superpowers` 命令。用户说一句 `/superpowers`/「启用 superpowers」,本会话后续所有任务自动按 5 步流程执行,不必逐个触发。开关 skill 本身遵循同样的编写规范(description 只写"何时用")。

**协作方式**:方法论 skill 在"何时用/协作"小节用 `[[skill-name]]` 交叉引用框架 skill。例:`superpowers` 的 brainstorming 纪律涉及框架时指向 `[[your-framework-base]]`;systematic-debugging 纪律涉及中间件异常时指向对应的框架 skill。

### 与 OpenSpec 的红线

若同时引入 OpenSpec(规格层,管"做什么/契约/沉淀")。遵循大厂共识的权责隔离:

> **OpenSpec 管「契约与沉淀」,Superpowers(skill)管「流程与质量」,一件事只由一套主导,互不越界。**

- **需求/设计契约** → OpenSpec 的 `proposal/spec/design`(唯一可信基线)。
- **执行流程/质量** → 本套方法论 skill。
- **禁止**:在 skill 里自行定义需求基线;skill 只读取 spec、不修改基线。轻量项目(无合规/无多人协同)可只用本套 skill,不引入 OpenSpec。

---

## 9. 何时该 / 不该新建 skill(防膨胀)

**该建**:① 这个工作方式对你不直观;② 会跨项目复用;③ 模式通用、非项目特定;④ 别人也受益。

**不该建**:① 一次性方案;② 业界已有成熟文档的标准实践(直接引用即可);③ **项目特定约定**(应放 `CLAUDE.md`,不是 skill);④ 能用 lint/校验自动化的机械约束(自动化,别写文档)。

**skill 的本质**:可复用的**技术、模式、流程**——不是"某次如何解决问题"的叙述。

---

## 10. 发布前质量检查清单

复制此清单逐项核对再发布:

**Frontmatter**
- [ ] `name` = 目录名,kebab-case,仅小写字母/数字/连字符,≤64 字符
- [ ] `description` ≤1024 字符(理想 <500),第三人称,以"……时使用"开头
- [ ] `description` 只写"何时用",**没有**概括流程
- [ ] 含触发关键词/症状/同义词
- [ ] 未声明 Qoder 专用的 `trigger` 字段(那属于 rule 层)

**正文**
- [ ] 正文 <500 行
- [ ] 有 Overview + 何时用(含症状、不适用)
- [ ] 重型参考已拆独立文件,引用 ≤1 层深
- [ ] 路径用正斜杠;例子具体可复用
- [ ] 中英混排加空格,技术术语未机翻

**协作**
- [ ] 该交叉引用的现有 skill 已用 `[[name]]` 链接
- [ ] 未越界定义需求基线(那是 OpenSpec 的事)
