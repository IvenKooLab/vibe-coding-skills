# Ponytail · 最懒的资深开发

> *He says nothing. He writes one line. It works.* —— 把「公司里那个扎马尾、戴椭圆眼镜、比版本控制还资深的老法师」塞进你的 AI:你给他五十行,他看一眼,不说话,换成一行。

让 AI 像**最懒的资深开发**一样写码:**懒而不疏忽**。最好的代码是从没写出来的代码。

---

## 这是什么

`ponytail` 是一套「写码时的精简纪律」。来自 [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail)(MIT),本包是其中文说明 + 英文 `SKILL.md` 的蒸馏版。

核心是**一把梯子**:动手写码前,从上往下找到第一个「成立」的横档就停——

```
1. 这东西到底需不需要存在?          → 不需要:跳过(YAGNI)
2. 代码库里已经有了?               → 复用,别重写
3. 标准库能干?                    → 用标准库
4. 平台原生功能能干?               → 用原生(`<input type="date">` 而非日期选择器库)
5. 已装的依赖能干?                 → 用它,绝不为新功能引新依赖
6. 能一行写完?                    → 一行
7. 都不行,才:写能跑通的最小代码
```

**关键**:梯子在「理解问题之后」跑,不是代替理解。先读相关代码、端到端捋清真实流程,再爬梯子。**懒的是解法,绝不懒于读代码。**

> 上游实测:同一 agent 带 ponytail vs 不带,代码量均值 **-54%**(过度设计的场景最高 -94%)、成本 **-20%**、速度 **-27%**,且安全护栏 100% 保留(裸 prompt「写一行流」会掉一个安全项)。

---

## 懒,但绝不懒于这些(护栏)

**永远不许省掉**:信任边界的输入校验、防数据丢失的错误处理、安全措施、无障碍基础、用户明确要求的东西。用户坚持要完整版 → 照建,不抬杠。

**非平凡逻辑必须留一个可跑的检查**(一个 `assert` 自检或一个小测试文件;不要框架、不要 fixtures)。一行流无需测试——YAGNI 也适用于测试。

**刻意简化用 `ponytail:` 注释标记**,带已知上限的要写明上限和升级路径:`# ponytail: 全局锁,吞吐不够再换 per-account 锁`。

---

## 三档强度

| 档位 | 触发 | 行为 |
|---|---|---|
| **lite** | `/ponytail lite` | 照要求建,但附一行「更懒的替代方案」,用户选 |
| **full** | `/ponytail` | 梯子强制执行:stdlib/原生优先,最短 diff、最短说明(**默认**) |
| **ultra** | `/ponytail ultra` | YAGNI 极端派:先删后增,丢出一行实现并当场质疑其余需求 |

**例子**——「给这些 API 响应加个缓存」:

- *lite*:「加好了。顺带一提:`functools.lru_cache` 一行就能搞定,省得自己维护缓存类。」
- *full*:「`@lru_cache(maxsize=1000)` 挂在 fetch 函数上。跳过自定义缓存类,lru_cache 实测不够再加。」
- *ultra*:「profiler 说要之前不加缓存。真要加也是 `@lru_cache`;手写 TTL 缓存类是个 hit rate 可怜的 bug 农场。」

---

## 6 个 skills

| Skill | 触发 | 干什么 |
|---|---|---|
| `ponytail` | `/ponytail` | 懒模式本身:能跑通的最简解 |
| `ponytail-review` | `/ponytail-review` | 审当前 diff 的过度设计,一条一行,给「能砍多少行」 |
| `ponytail-audit` | `/ponytail-audit` | 全仓库过度设计审计,按可砍量排序 |
| `ponytail-debt` | `/ponytail-debt` | 把所有 `ponytail:` 简化注释收成一份可追踪的「技术债台账」 |
| `ponytail-gain` | `/ponytail-gain` | 展示实测收益看板(更少代码/更便宜/更快) |
| `ponytail-help` | `/ponytail-help` | 速查卡 |

> 💡 **skill 正文为英文**(省 token),中文说明看本 README。

---

## 何时用 / 何时不用

**用**:任何编码任务(写 / 重构 / 修 bug / review),尤其当 AI 想引新依赖、加投机抽象、写包装组件时。

**不用**:非编码请求(写文章、做研究、解释概念)——ponytail 管「写什么码」,不管「怎么说话」。

---

## 怎么装

### Claude Code(全局)

```bash
# 把 6 个 skill 复制到全局 skills 目录
cp -r skills/* ~/.claude/skills/
```

### Claude Code(某项目)

```bash
cp -r skills/* <项目>/.claude/skills/
```

### Qoder

复制 `skills/*` 到 `<项目>/.qoder/skills/`,字节同构。

> 装好后对 agent 说 `/ponytail` 或「启用 ponytail / lazy 模式」即激活;说「停用 ponytail / normal mode」退出。本包按 ponytail 精神**不附安装脚本**——手动 `cp` 即可。

---

## 验证(装完后)

让 AI「加个日期选择器」。

✅ **预期**:AI 先查有没有原生方案,直接给 `<input type="date">` 一行,而不是装 flatpickr + 写包装组件 + 讨论时区;输出「代码 + 最多三行说明(砍了啥、啥时候加回来)」。

❌ **反例**:AI 引入新依赖、写单实现的接口/工厂、或长篇大论解释一个比代码还长的简化——说明没生效。

---

## 和其他技能的关系

- 与方法论层([[superpowers]] 的 brainstorming / writing-plans / test-driven-development 纪律)正交叠加:ponytail 管**产出的代码长什么样**。
- 「留一个可跑的检查」是 [[superpowers]] verification-before-completion 纪律的懒人版——先留个检查,再让完整验证 skill 跑闸门。

---

## 致谢与来源

- 上游:[DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail)(MIT)
- 本包为其中文说明 + 英文 `SKILL.md` 的蒸馏摘录,License 随上游 MIT。
