# AGENTS.md — 项目 AI 协作指南

本文档为 AI Agent 提供按场景分组的规则与技能引用索引。Agent 应根据当前工作场景，加载对应文件作为行为约束。

---

## 目录分层策略

| 目录 | 定位 | 说明 |
|------|------|------|
| `.agents/` | 工程通用配置（团队共享） | rules、skills、openspec 等规范定义，提交到 Git |

---

## 场景一：编写业务代码（新增功能 / 修改逻辑）

无论涉及哪个层级，均需遵守以下全部规范：

| 规范文件 | 核心关注点 |
|----------|-----------|
| [~/.agents/rules/architecture.md](~/.agents/rules/architecture.md) | 分层依赖方向、各层职责与禁止事项、Controller 参数规范、Dubbo API 兼容性、外部服务调用规范 |
| [~/.agents/rules/java-naming.md](~/.agents/rules/java-naming.md) | 类/方法/变量命名、包路径约定、DAO 方法命名、集合变量命名、对象转换方法命名 |
| [~/.agents/rules/method-design.md](~/.agents/rules/method-design.md) | 单一职责、参数规范、返回值规范、异常处理、事务使用、防御性编程、for 循环规范 |
| [~/.agents/rules/code-style.md](~/.agents/rules/code-style.md) | OOP 规范、集合/并发规范、Lombok 使用、枚举规范、注释规范 |
| [~/.agents/rules/exception-log.md](~/.agents/rules/exception-log.md) | 异常体系与使用、日志级别与格式、error first 原则、try 块规范 |

**按子场景额外加载：**

- **涉及数据库 / MyBatis** → 加载 [~/.agents/rules/sql-mybatis.md](~/.agents/rules/sql-mybatis.md)
- **涉及胶水代码生成** → 加载 [~/.agents/skills/glue-coding/SKILL.md](~/.agents/skills/glue-coding/SKILL.md)

---

## 场景二：代码审查（Code Review）

| 文件 | 用途 |
|------|------|
| [~/.agents/skills/code-review/SKILL.md](~/.agents/skills/code-review/SKILL.md) | 审查流程、维度、反馈格式 |
| [~/.agents/rules/architecture.md](~/.agents/rules/architecture.md) | 分层架构合规检查 |
| [~/.agents/rules/sql-mybatis.md](~/.agents/rules/sql-mybatis.md) | SQL 与数据库规范检查 |
| [~/.agents/rules/exception-log.md](~/.agents/rules/exception-log.md) | 异常与日志规范检查 |
| [~/.agents/rules/method-design.md](~/.agents/rules/method-design.md) | 方法设计规范检查 |
| [~/.agents/rules/java-naming.md](~/.agents/rules/java-naming.md) | 命名规范检查 |
| [~/.agents/rules/code-style.md](~/.agents/rules/code-style.md) | 代码风格检查 |
| [~/.agents/rules/unit-test.md](~/.agents/rules/unit-test.md) | 单元测试质量检查 |

---

## 场景三：编写单元测试

| 规范文件 | 核心关注点 |
|----------|-----------|
| [~/.agents/rules/unit-test.md](~/.agents/rules/unit-test.md) | 用例完整度、覆盖率、Mock 使用、断言有效性 |
| [~/.agents/rules/exception-log.md](~/.agents/rules/exception-log.md) | 异常场景断言须同时验证异常类型 + 错误码/消息 |

---

## 场景四：OpenSpec 需求管理与设计文档

本项目使用 **yt-workflow** schema，所有变更必须通过 OpenSpec 流程。

---

## 规范文件速查表

| 文件 | 适用层级 | 核心内容 |
|------|---------|---------|
| `architecture.md` | 全局 | 分层依赖、各层职责、Controller 规范、Dubbo 兼容性 |
| `java-naming.md` | 全局 | 命名规范、包路径、DAO 方法命名、集合变量 |
| `method-design.md` | Service / AO / Biz | 单一职责、参数/返回值、异常处理、事务 |
| `code-style.md` | 全局 | OOP/集合/并发规范、Lombok、枚举、注释 |
| `exception-log.md` | 全局 | 异常体系、日志框架与级别、error first |
| `sql-mybatis.md` | Dal 层 | 表设计、禁止连表、SQL 注意事项、参数绑定 |
| `unit-test.md` | 测试 | 用例完整度、覆盖率、Mock 使用、断言有效性 |
