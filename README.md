# vibe-coding · AI 编码技能合集

> 把业界优秀的「AI 怎么干活」技能,蒸馏成一套**同时适用于 Claude Code 与 Qoder**的标准 skill 包,补齐公司 skill 库的方法论 / 纪律 / 工程框架层。

---

## 这是什么

本仓库是 `vibe-coding` 技能合集的**暂存区**。每个子目录是一个独立、可单独安装的 skill 包,均按同一套体例编写:

- **中文 README**——讲清楚「是什么 / 何时用 / 怎么装」,给人看。
- **英文 `SKILL.md`**——AI 加载正文(英文比中文省约 30% token),给 agent 看。
- 跨工具字节同构:同一份 `SKILL.md` 复制到 `.claude/skills/` 与 `.qoder/skills/` 即两处生效。

编写规范见 [`superpower/docs/skill编写规范.md`](superpower/docs/skill编写规范.md)。

---

## 四个包与分层

四个包**互补、可组合**,从「动手前」到「写码时」到「跨会话」各管一段:

| 包 | 层 | 一句话 | 来源 |
|---|---|---|---|
| [`superpower`](superpower/) | 方法论层 | 动手前先澄清需求→拆计划→TDD→系统化调试→完成前验证 | obra/superpowers + 公司 lina-* |
| [`grill-me`](grill-me/) | 需求拷问层 | 动手前对计划做「无情盘问」,逐个走完决策树,直到达成共识 | mattpocock/skills · grill-me |
| [`ponytail`](ponytail/) | 精简纪律层 | 像最懒的资深开发:能不写就不写,能一行就一行,**懒而不疏忽** | DietrichGebert/ponytail |
| [`Trellis`](Trellis/) | 工程框架层 | 把 spec / task / memory 持久化进仓库,让 AI 跨会话有记忆 + 多 agent 协作 | mindfold-ai/Trellis |

### 它们怎么串起来

```
┌──────────────────────────────────────────────────────────────┐
│  需求拷问   grill-me       把计划里每个隐含决策问到底          │
├──────────────────────────────────────────────────────────────┤
│  方法论     superpower     brainstorm→plan→TDD→debug→verify  │
├──────────────────────────────────────────────────────────────┤
│  精简纪律   ponytail       写最少必要的代码;删优于增            │
├──────────────────────────────────────────────────────────────┤
│  工程框架   Trellis        spec/task/memory 持久化 + 多 agent  │
└──────────────────────────────────────────────────────────────┘
                       ↓ 调用 / 交叉引用
┌──────────────────────────────────────────────────────────────┐
│  框架知识层(公司已有 lina-*):「用什么」                       │
│  lina-redis · lina-rabbitmq · lina-mybatis · ...              │
└──────────────────────────────────────────────────────────────┘
```

- **方法论层**管「怎么干」,`lina-*` 管「用什么」,二者互补不互斥。
- `grill-me` 与 `superpower` 的 `brainstorming` 都做需求澄清:`grill-me` 更偏**单点深度盘问**(把一个计划问透),`brainstorming` 更偏**完整工作流开场**。可单独用,也可叠加。
- `ponytail` 是「写码时」的纪律,与任何方法论层都正交,叠加即生效。
- `Trellis` 适合**需要跨会话记忆 / 多 agent 协作 / 团队共享 spec** 的中大型项目;轻量单人项目用前三者即可。

---

## 目录结构

```
.
├─ README.md                       # 本文件(合集索引)
├─ .gitignore
├─ superpower/                     # 方法论层(5 skills + 开关 + 安装脚本)
├─ grill-me/                       # 需求拷问(1 skill)
├─ ponytail/                       # 精简纪律(1 核心 + 5 命令 skills)
└─ Trellis/                        # 工程框架精华(核心工作流 skills)
```

各包的安装 / 使用 / 卸载,见对应目录下的 `README.md`。

---

## 致谢与来源

- [obra/superpowers](https://github.com/obra/superpowers)(MIT)→ superpower 方法论内核
- [mattpocock/skills](https://github.com/mattpocock/skills) · `grill-me` → 需求拷问
- [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail)(MIT)→ 精简纪律
- [mindfold-ai/Trellis](https://github.com/mindfold-ai/Trellis)(AGPL-3.0)→ 工程框架
- 跨工具格式规格:[agentskills.io/specification](https://agentskills.io/specification)

> 各包 License 随上游:superpower / ponytail 为 MIT;grill-me 随 mattpocock/skills;Trellis 上游为 AGPL-3.0,本仓库仅做方法论的**蒸馏摘录与中文说明**,未整体搬运其源码,使用时请遵守上游协议。
