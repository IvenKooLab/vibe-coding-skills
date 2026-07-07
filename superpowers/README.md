# Superpowers 工作方法论 · 华安增强版

> 把 superpowers 的"AI 怎么干活"工作方法论,沉淀为一套**同时适用于 Claude Code、Qoder(阿里 AI IDE)、Trae(字节 AI IDE)**的 skill,补上公司 skill 库缺位的"方法论层"。

---

## 这是什么

superpowers(obra/superpowers)的本质不是某个框架教程,而是一套工程纪律:**动手前先澄清需求、写码前先拆计划、实现前先写测试、排查走系统化调试、完成前先跑验证**。

摸底公司现有 skill 发现:大多是**框架知识层**(`lina-*`——告诉 AI"用什么"),但"怎么干"这套工作流是缺位的。本套就是来填这个坑的。

**关键事实**:Claude Code、Qoder、Trae 的 skill 文件**字节级同构**——同一份 `SKILL.md` 复制到 `.claude/skills/`、`.qoder/skills/`、`.trae/skills/` 即三处生效,无需维护多套。详见 [`docs/skill编写规范.md`](docs/skill编写规范.md)。

---

## 产物结构

```
superpowers/
├─ README.md                       # 本文件
├─ 分享说明.md                     # 群发用:同事怎么装/用/卸(一页纸)
├─ docs\
│  └─ skill编写规范.md              # ★ 跨工具 skill 编写规范(核心,先读这个)
├─ _template\
│  └─ SKILL.md                     # 可直接套用的标准模板
├─ skills\                         # 6 个 skills(1 开关 + 5 方法论,中文)
│  ├─ superpowers\                 #   总开关(/superpowers 一键启用整套流程)
│  ├─ brainstorming\              #   需求澄清
│  ├─ writing-plans\              #   编写实施计划
│  ├─ test-driven-development\    #   测试驱动开发
│  ├─ systematic-debugging\        #   系统化调试
│  └─ verification-before-completion\  # 完成前验证
├─ commands\
│  └─ superpowers.md               # /superpowers 开关命令(Claude Code slash command)
├─ bootstrap\
│  ├─ CLAUDE.md.snippet           # Claude Code 引导(哨兵包裹)
│  └─ qoder-rule.md               # Qoder 引导(trigger: always_on)
├─ install\
│  ├─ install.sh                  # 安装(bash)
│  ├─ install.bat                 # 安装(Windows 批处理,无需 PowerShell)
│  ├─ install.ps1                 # 安装(PowerShell)
│  ├─ remote-install.sh           # 远程一行安装(需内网 git 托管)
│  ├─ uninstall.sh                # 卸载(bash,自包含)
│  └─ uninstall.ps1               # 卸载(PowerShell,自包含)
└─ migration\
   └─ Trae格式skill迁移示例.md       # Trae JSON → 标准 SKILL.md 示范
```

---

## 一键开关 + 5 个方法论 skills

> 💡 **skill 正文已改为英文**(AI 加载英文比中文省约 30% token);**中文说明就看本节**。

不想逐个记 skill 名字?对 agent 说一句 **`/superpowers`**(Claude Code)或**「启用 superpowers」**(Qoder),本会话后续所有任务自动按下表流程执行。说「停用 superpowers」退出。

### 各 skill 中文说明

| Skill(英文文件名) | 中文名 | 什么时候用 / 做什么 |
|---|---|---|
| `superpowers` | 总开关 | 说 `/superpowers` 或「启用 superpowers」——一次性开启整套流程,后续任务自动走下面 5 步 |
| `brainstorming` | 需求澄清 | 新增功能/重构/修复杂 bug 前——先提问澄清、给 2-3 个方案、分块确认,确认后再动手 |
| `writing-plans` | 编写实施计划 | 需求确认后、动手前——拆成 2-5 分钟可执行任务,每个含文件路径 + 验证步骤 |
| `test-driven-development` | 测试驱动开发 | 写/改业务逻辑、修 bug——先写会失败的测试(RED),再写最小实现(GREEN),再重构 |
| `systematic-debugging` | 系统化调试 | 排查 bug/报错/性能异常——稳定复现 → 找根因(不靠猜)→ 最小修复 → 验证 |
| `verification-before-completion` | 完成前验证 | 声称"完成"前——实跑构建/测试/lint,给可核对证据,禁止"应该没问题" |

**典型流程**:`/superpowers` 开启后,每个任务依次走 brainstorming → writing-plans → test-driven-development →(遇问题)systematic-debugging → verification-before-completion。

> **不重造轮子**:本套是方法论层,与现有 `lina-*` 框架知识层互补——本套管"怎么干",`lina-*` 管"用什么"。

---

## 分层模型:与现有 skill、与 OpenSpec 的关系

```
┌──────────────────────────────────────────────┐
│  方法论层(本套 5 skills)=「怎么干」          │
│  brainstorming → writing-plans → TDD →        │
│  systematic-debugging → verification          │
└──────────────────────────────────────────────┘
                    ↓ 调用 / 交叉引用
┌──────────────────────────────────────────────┐
│  框架知识层(公司已有)=「用什么」             │
│  lina-* · lina-redis · lina-rabbitmq · ...    │
└──────────────────────────────────────────────┘
```

**与 OpenSpec(规格层)**:遵循大厂共识的权责隔离——

> OpenSpec 管「契约与沉淀」(做什么),本套 skill 管「流程与质量」(怎么做),一件事只由一套主导,互不越界。

- 轻量项目(单人、短期、无合规)→ 只用本套 skill,不引 OpenSpec。
- 复杂项目(多团队、支付交易、合规审计)→ OpenSpec 定需求基线,本套 skill 管执行,二者串联。
- **红线**:本套 skill 不越界定义需求基线,只读取 spec。

---

## 怎么装(审阅后)

> 本目录是**暂存区**,审阅满意后再装到 live 环境。安装脚本**只往已装的 IDE 写**,不会替你没装的工具建空目录;删除前还会做指纹校验,绝不误删同名第三方内容。

### 全局(双击即跑,推荐)

三种脚本行为一致,选你顺手的:

| 脚本 | 命令 |
|---|---|
| bash / Git Bash | `bash install/install.sh` |
| PowerShell | `.\install\install.ps1` |
| 批处理(双击) | `.\install\install.bat` |

→ 自动扫描 `~/.claude`、`~/.qoder`、`~/.trae-cn`、`~/.trae`,**装了哪个 IDE 就往哪个里塞 skills**,没装的不碰(不建空目录)。

> 一个 IDE 都没装过(以上目录都不存在)时,脚本会提示并退出,不写任何东西。想预装到某个 IDE 用下面的 `--with-*` 强制。

### 项目级(含 CLAUDE.md 引导)

```bash
bash install/install.sh --project /path/to/project
```
→ 复制到 `<project>/.claude/skills/`,并往 `<project>/CLAUDE.md` 追加引导段(哨兵包裹,可精确卸载)。项目模式下 `.claude` 总是装;Qoder / Trae 需显式 `--with-*`。

### 指定 IDE(Claude Code / Qoder / Trae)

```bash
bash install/install.sh --with-claude            # 全局 ~/.claude(即使目录不存在也建)
bash install/install.sh --with-qoder             # 全局 ~/.qoder
bash install/install.sh --with-trae              # 全局 ~/.trae-cn(回退 ~/.trae)
bash install/install.sh --with-all               # Claude Code + Qoder + Trae 一起
bash install/install.sh --project /path --with-all   # 项目级三端
```

→ Qoder 写 `.qoder/skills/` + `.qoder/rules/superpowers-sinosafe.md`(`trigger: always_on`);Trae 写 `.trae/skills/`(+ `.trae/rules/`)。PowerShell 把 `--with-xxx` 换成 `-WithXxx`(`-WithClaude`、`-WithTrae`、`-WithAll`)。

### 先干跑 / 卸载

```bash
bash install/install.sh --dry-run               # 只看将做什么,不写盘
bash install/install.sh --uninstall             # 卸全局(按哨兵精确移除,不误删用户内容)
bash install/install.sh --uninstall --project /path --with-all
bash install/uninstall.sh --project /path        # 自包含卸载(无需原仓库)
```

> `.bat` 卸载只删 skill + 命令,**不动 CLAUDE.md**(cmd 无法安全删多行哨兵块);要清 CLAUDE.md 引导段用 `install.ps1 -Uninstall` 或手动删 `superpowers-sinosafe:begin/end` 之间的行。`install.ps1` / `install.sh` 能自动清理 CLAUDE.md 哨兵块(含旧 `superpower-sinosafe` 残留)。

> 分享给同事、远程一行安装、卸载,详见 [`分享说明.md`](分享说明.md)。打成压缩包分发的现成包见上级目录 `superpowers-skills.zip`。

---

## 实测验证(装完后)

1. **Claude Code**:启动会话,先输入 `/superpowers` 开启,再说"给用户模块加个批量导出功能"。✅ 预期:AI **先提问**(格式/数据量/权限/是否异步),而非直接写码——说明开关 + `brainstorming` 生效了。
2. **Qoder**:同样 prompt,确认 `.qoder/rules/superpowers-sinosafe.md` 显示为 `always_on`,AI 同样先查 skill。
3. **卸载安全**:跑 `--uninstall`,确认 `CLAUDE.md` 里你自己写的内容原样保留、只有哨兵段被切除。

---

## 想自己写 / 改 skill

1. 读 [`docs/skill编写规范.md`](docs/skill编写规范.md)(核心规范,必读)。
2. 复制 [`_template/SKILL.md`](_template/SKILL.md) 开写。
3. 跑规范末尾的「发布前质量检查清单」自检。
4. 有 Trae JSON 旧 skill 要迁移?看 [`migration/Trae格式skill迁移示例.md`](migration/Trae格式skill迁移示例.md)。

---

## 致谢与来源

- 方法论内核:[obra/superpowers](https://github.com/obra/superpowers)(MIT)
- 中文增强 + Qoder 适配参考:[jnMetaCode/superpowers-zh](https://github.com/jnMetaCode/superpowers-zh)(MIT)
- 跨工具格式规格:[agentskills.io/specification](https://agentskills.io/specification)
- 选型与落地模式参考:公司既有研究《阿里/字节/腾讯大厂 OpenSpec + Superpowers 落地模式》

本套为华安场景的精简增强版:取 superpowers 执行层核心 5 skill,中文化,加公司框架层交叉引用,统一为跨工具标准格式。License:随上游 MIT。
