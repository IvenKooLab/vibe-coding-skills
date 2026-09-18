# vibe-coding 公开化方案（GitHub 开源准备）

> 2026-09-18 盘点定稿 · 目标：把本仓整理成可公开的中文 AI 编码方法论合集，
> 在 IvenKooLab 名下作为继 loci / nacos2-mcp 之后的第三个公开仓候选。
> **本方案先落仓内，剥离动作经用户确认后执行**（涉及内容取舍的判断权在用户）。

## 一、公开定位（一句话）

**「六个 AI 编码方法论 skill 的中文蒸馏合集：怎么选、怎么串、怎么写你自己的」**
——面向中文 Claude Code / Qoder / 任意 SKILL.md 兼容工具用户。
差异化不是搬运（上游都是英文原版），而是三层原创价值：
① 六包互补分层的**选型体系**（动手前→写码时→跨会话）+ 自研 `/vibe` 路由器；
② 中文 README + 英文 SKILL.md 的**双语体例**（给 agent 英文省 token、给人中文）；
③ `docs/skill编写规范.md` 这套**跨工具同构的编写规范**（沉淀自 agentskills.io 与三个上游实践）。

建议仓库名：`vibe-coding-skills`（比 vibe-coding 搜索指向更明确）。

## 二、必须剥离的公司痕迹（公开前逐项处理）

| 文件 | 位置 | 内容 | 处理 |
|---|---|---|---|
| `README.md` | L3 / L28 / L32 / L52-58 / L90 | "公司 skill 库""公司 lina-*" 及 lina 分层图 | 改为中性："企业内部框架知识层（示例：lina-*）"→ 用 `your-framework-*` 泛化示例 |
| `docs/skill编写规范.md` | L3 / L161-166 / L195-208 | "公司内部""superpowers-sinosafe""公司 skill 库分两层" | sinosafe 标记改占位符 `superpowers-<org>`；分层表去公司字样 |
| `superpowers/.../SKILL.md` | L306 / L311 | lina-* 交叉引用 | 改为泛化示例（`[[your-redis-skill]]` 类）或删除两行 |
| `openspec/README.md` | L3 / L5 | "公司 Lina 框架…路由到 lina-*" | 同上泛化 |
| `ponytail/README.md` | L3 | "公司里那个扎马尾…" | 修辞可保留（泛指职场），保守起见改"团队里" |

## 三、License 核对清单（公开前必查上游）

| 包 | 上游 | License 状态 |
|---|---|---|
| superpowers | obra/superpowers | README 已标 MIT ✅（保留署名+链接） |
| ponytail | DietrichGebert/ponytail | 已标 MIT ✅ |
| openspec | Fission-AI/OpenSpec | 已标 MIT ✅ |
| grill-me | mattpocock/skills | **未标——需查上游仓 LICENSE** |
| Trellis | mindfold-ai/Trellis | **未标——需查** |
| vibe（自研路由） | — | 用户自有 ✅ |
| skill编写规范 | 自研（方法学引用已注明） | ✅ |

仓库自身 license 建议 MIT；每个子包 README 保留"来源+链接+license"三件套（现有格式已好）。

## 四、公开版 README 改写方向（保留骨架，改三处）

1. 首段"补齐公司 skill 库的…" → "把业界优秀的 AI 工程纪律，蒸馏成即装即用的 skill 包"
2. 新增 **Why 中文蒸馏版** 一节（对照上游原版的体例差异与适用人群）
3. 新增 badges（license / skill 数 / 安装一行命令）+ 安装总说明（六个包可单装）

## 五、发布渠道（中文社区为主）

掘金/V2EX（"我把 6 个 AI 编码方法论 skill 蒸馏成了中文合集"）+ awesome-claude-code
类列表投稿；英文侧暂缓（上游就是英文，无增量）。

## 六、执行顺序（决策已定，2026-09-18 用户拍板）

- ✅ **剥离方式：泛化保留**——`lina-*` 改 `your-framework-*` / `myorg-redis` 类占位写法，
  保留"方法论层 × 框架知识层"两层协作的教学价值（本合集相对上游原版的差异化之一）
- ✅ **时机：排后**——优先级队列：loci v0.6 发版 → nacos2-mcp GitHub 建仓 →
  loci 发布帖三连 → **本仓公开化** → 归园 Godot 原型
- 待办（捡起时按序）：① 查 grill-me / Trellis 上游 license → ② 按 §二 清单剥离
  （ponytail README 的"公司"改"团队"、sinosafe 标记改占位符）→ ③ §四 改写 README →
  ④ 推 `public-ready` 分支（本仓保持 Gitee 私有）→ ⑤ 家里 GitHub 建仓 `vibe-coding-skills`
