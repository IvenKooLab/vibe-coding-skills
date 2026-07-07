# Superpowers 工作方法论 · 华安增强版

> 把 superpowers 的"AI 怎么干活"工作方法论,沉淀为一套**同时适用于 Claude Code 与 Qoder(阿里 AI IDE)**的 skill,补上公司 skill 库缺位的"方法论层"。

---

## 这是什么

superpowers(obra/superpowers)的本质不是某个框架教程,而是一套工程纪律:**动手前先澄清需求、写码前先拆计划、实现前先写测试、排查走系统化调试、完成前先跑验证**。

摸底公司现有 skill 发现:大多是**框架知识层**(`lina-*`——告诉 AI"用什么"),但"怎么干"这套工作流是缺位的。本套就是来填这个坑的。

**关键事实**:Claude Code 和 Qoder 的 skill 文件**字节级同构**——同一份 `SKILL.md` 复制到 `.claude/skills/` 与 `.qoder/skills/` 即两处生效,无需维护两套。详见 [`docs/skill编写规范.md`](docs/skill编写规范.md)。

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

> 本目录是**暂存区**,审阅满意后再装到 live 环境。安装脚本不碰 staging 之外的既有内容(除非你显式指定目标)。

### Claude Code(全局,最简单)

```bash
bash install/install.sh
```
→ 把 5 个 skill 复制到 `~/.claude/skills/`,所有项目可用。

### Claude Code(某项目,含引导)

```bash
bash install/install.sh --project /path/to/project
```
→ 复制到 `<project>/.claude/skills/`,并往 `<project>/CLAUDE.md` 追加引导段(哨兵包裹,可精确卸载)。

### 同时装 Qoder(项目级)

```bash
bash install/install.sh --project /path/to/project --with-qoder
```
→ 额外写入 `.qoder/skills/` + `.qoder/rules/superpowers-sinosafe.md`(`trigger: always_on`)。

### Windows PowerShell

```powershell
.\install\install.ps1                                 # 全局
.\install\install.ps1 -Project 'D:\code\myproj'       # 项目级 + 引导
.\install\install.ps1 -Project 'D:\code\myproj' -WithQoder
```

### Windows 批处理(.bat,无需 PowerShell)

不想装 Git Bash、也不想碰 PowerShell?直接双击 `.bat`(纯 cmd,不依赖任何运行时):

```cmd
.\install\install.bat                                 # 全局(双击即跑)
.\install\install.bat --project D:\code\myproj        # 项目级 + 引导
.\install\install.bat --project D:\code\myproj --with-qoder
.\install\install.bat --dry-run                       # 只看将做什么,不写盘
.\install\install.bat --uninstall --project D:\code\myproj
```

> `.bat` 卸载只删 skill + 命令,**不动 CLAUDE.md**(cmd 无法安全删除多行哨兵块);要清 CLAUDE.md 引导段用 `install.ps1 --uninstall`,或手动删 `superpowers-sinosafe:begin/end` 之间的行。

### 先干跑 / 卸载

```bash
bash install/install.sh --dry-run --project /path      # 只看将做什么,不写盘
bash install/install.sh --uninstall --project /path    # 卸载(也可直接用 uninstall.sh)
bash install/uninstall.sh --project /path              # 自包含卸载(无需原仓库)
```

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
