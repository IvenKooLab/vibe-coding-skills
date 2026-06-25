# 迁移示例:把 Trae JSON 格式 skill 改造成标准 SKILL.md

> 演示如何把一个 **Trae/Qoder 的 JSON prompt 格式** skill,改造成**跨工具通用的标准 SKILL.md**(YAML frontmatter + Markdown),使其同时在 Claude Code 与 Qoder 生效。
>
> 适用于任何用 Trae JSON 格式写的旧 skill。下面以一个常见的「Java 规范代码生成」prompt 为例说明转换规则。

---

## 背景:为什么要改

Trae 的 JSON prompt 格式有以下局限:

- 目录名常用中文,不符合 `name` 必须 kebab-case 英文 slug 的规范。
- 内容是 `{ name, description, prompt, parameters, examples }` 的 JSON,只适配 Trae/Qoder 的"prompt 模板"形态,**Claude Code 无法按标准 skill 发现与自动触发**。
- `prompt` 字段把"何时用"和"怎么做"混在一起,`{user_input}` 占位符是 Trae 专用语法。

按《skill 编写规范》统一后:一份 SKILL.md,Claude Code 与 Qoder 都能发现、自动触发、跨工具一致。

---

## 改造前(Trae JSON 格式)

```json
{
  "name": "Java规范代码生成",
  "description": "严格遵循阿里巴巴Java开发手册,生成符合规范的Java代码(命名、注释、异常处理、集合使用等)",
  "prompt": "请根据以下需求生成符合阿里巴巴Java开发手册的Java代码:\n1. 类名使用UpperCamelCase风格...\n2. 异常捕获后必须处理...\n3. 集合初始化时指定初始容量\n4. 所有方法必须有清晰的Javadoc注释\n5. 避免魔法值,使用常量替代\n需求:{user_input}",
  "parameters": [
    { "name": "user_input", "type": "string", "description": "用户的代码需求描述" }
  ],
  "examples": [ { "input": "...", "output": "..." } ]
}
```

问题:中文目录名、JSON prompt 结构、`{user_input}` 占位、混了何时用与怎么做。

---

## 改造后(标准 SKILL.md)

放到 `skills/java-coding-standard/SKILL.md`(目录名 = `name`,英文 slug):

```markdown
---
name: java-coding-standard
description: 在编写或修改 Java 代码时使用——按阿里巴巴 Java 开发手册生成与审查代码,覆盖命名、注释、异常处理、集合初始化、常量替代魔法值等规范。症状:新建 Java 类/方法、代码评审前自查、或发现命名/魔法值/未处理异常等违规时。
---

# Java 编码规范(阿里巴巴手册)

## Overview
按《阿里巴巴 Java 开发手册》生成与审查 Java 代码,从源头减少评审问题。核心:命名统一、注释完整、异常必处理、集合预分配容量、消灭魔法值。

## 何时使用
- 新建 Java 类 / 接口 / 方法时
- 代码提交/评审前的规范自查
- 发现命名、魔法值、未处理异常、集合未指定容量等违规时

**不适用**:非 Java 代码;纯框架用法问题(去查对应 `lina-*` skill)。

## 核心规范(检查清单)

- [ ] **命名**:类名 UpperCamelCase;方法名/变量名/参数名 lowerCamelCase;常量全大写下划线 `MAX_PAGE_SIZE`
- [ ] **异常**:捕获后必须处理,禁止 `catch (Exception e) {}` 空吞
- [ ] **集合初始化**:已知大小时指定初始容量 `new ArrayList<>(expectedSize)`,避免扩容
- [ ] **注释**:所有 public 方法有清晰 Javadoc(参数、返回、异常);复杂逻辑加行内注释
- [ ] **魔法值**:禁止代码里直接写 `10`、`"Y"` 等,提取为命名常量并注释含义
- [ ] **中英混排**:注释里中文与英文/数字间加空格;技术术语(Redis/MySQL/API)不翻译

## 示例

❌ 坏:
​```java
public List query(Long id) {
    List r = new ArrayList();      // 未指定容量
    if (id == null) {              // 魔法判断散落
        return r;
    }
    try { ... } catch (Exception e) {}  // 空吞异常
    int limit = 10;                // 魔法值
}
​```

✅ 好:
​```java
/** 默认分页大小 */
private static final int DEFAULT_PAGE_SIZE = 10;

/**
 * 根据用户 ID 查询用户角色列表
 * @param userId 用户 ID,非空
 * @return 角色列表,无数据返回空集合
 */
public List<String> queryRolesByUserId(Long userId) {
    if (userId == null) {
        throw new IllegalArgumentException("用户 ID 不能为空");
    }
    List<String> roles = new ArrayList<>(DEFAULT_PAGE_SIZE);
    // ... 业务逻辑
    return roles;
}
​```

## 反模式(Never)
- **Never** `catch` 后空吞异常
- **Never** 代码里裸写魔法值
- **Never** 集合不指定已知容量
- **Never** public 方法缺 Javadoc

## 与现有 skills 协作
- Lina 框架相关结构 → [[lina-framework-base]]
```

---

## 改造规则(可套用到任何 Trae JSON skill)

| Trae JSON 元素 | 标准 SKILL.md 对应 | 转换说明 |
|---|---|---|
| 目录/文件中文名 | 改英文 kebab-case slug,目录名 = `name` | 中文目录名(如「代码规范skill」)→ 英文 slug(如 `java-coding-standard`) |
| `description` | frontmatter `description` | 补"何时用 + 症状",第三人称,≤500 字符 |
| `prompt` 正文 | 拆成「何时用」+「流程/检查清单」+「示例」 | **去掉** `{user_input}` 占位;把指令写成 AI 主动遵循的流程,而非"填空模板" |
| `parameters` | 删除,改为正文里"如何使用"的引导 | 标准 skill 不需要声明式参数 |
| `examples` | 正文「示例」小节(Before/After) | 保留有价值的例子,改成对照 |

核心思路:**从"用户填参数的 prompt 模板"转为"AI 加载后主动遵循的工作流/规范"**——这正是 superpowers skill 与 Trae prompt 的本质区别,也是标准 skill 能被自动触发的原因。

---

## 改造收益

1. **跨工具**:同一份 SKILL.md 在 Claude Code 与 Qoder 都能被发现、自动触发,不再只绑 Trae。
2. **自动触发**:符合规范的 `description` 让 AI 在"写 Java 代码"时主动调用,无需手动填 `{user_input}`。
3. **可组合**:用 `[[wikilink]]` 与 `lina-*` 等已有 skill 串联,形成分层知识网。
4. **可维护**:统一格式,团队任何人都能按《skill 编写规范》读写。
