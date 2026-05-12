# DataWorks SQL 格式化 IntelliJ IDEA 插件设计

## 概述

一键格式化 `.sql` 文件的 IntelliJ IDEA 插件，规则基于 dataworks-sql-format 规范。

## 架构

```
┌──────────────────────────────────────┐
│      IntelliJ Plugin 层 (AnAction)    │
│  - 注册右键菜单 "DataWorks SQL 格式化" │
│  - 获取编辑器文本（选中部分或全文）     │
│  - 通过 WriteCommandAction 替换内容    │
│  - 仅对 .sql 文件启用                 │
└──────────────┬───────────────────────┘
               │ SQL 字符串
               ▼
┌──────────────────────────────────────┐
│     SQL 格式化引擎（纯 Java 无依赖）   │
│  - SqlTokenizer  → 分词              │
│  - SqlFormatter → 组装格式化输出      │
│  - 规则来自 dataworks-sql-format skill│
└──────────────────────────────────────┘
```

### 分层说明

- **格式化引擎是纯 Java 类**，不依赖任何 IntelliJ SDK，可单独单元测试
- **Plugin 层很薄**，只做编辑器交互和文本替换

## 项目结构

```
dataworks-sql-format-plugin/
├── build.gradle.kts              # Gradle IntelliJ Plugin 配置
├── settings.gradle.kts
├── src/
│   ├── main/
│   │   ├── java/com/peach/sqlformat/
│   │   │   ├── engine/
│   │   │   │   ├── SqlTokenizer.java      # 分词器
│   │   │   │   ├── SqlFormatter.java      # 格式化器
│   │   │   │   ├── Token.java             # Token 数据结构
│   │   │   │   ├── TokenType.java         # Token 类型枚举
│   │   │   │   └── KeywordDictionary.java # 关键字/函数字典
│   │   │   └── action/
│   │   │       └── DataWorksSqlFormatAction.java  # IDEA 右键菜单
│   │   └── resources/
│   │       └── META-INF/
│   │           └── plugin.xml             # 插件描述文件
│   └── test/
│       └── java/com/peach/sqlformat/engine/
│           ├── SqlTokenizerTest.java
│           ├── SqlFormatterTest.java
│           └── SqlFormatterIntegrationTest.java
```

## Token 设计

### TokenType

| Token 类型 | 示例 | 输出规则 |
|-----------|------|---------|
| KEYWORD | SELECT, FROM, WHERE | **大写** |
| FUNCTION | nvl, get_json_object, split, concat, coalesce | **小写** |
| IDENTIFIER | 表名、列名、别名 | 原样保留 |
| STRING | '${v_date}', '其他' | 原样保留 |
| NUMBER | 0, 1, 100 | 原样保留 |
| OPERATOR | =, !=, <, >, + | 原样保留 |
| COMMA | , | 原样保留 |
| DOT | . | 原样保留 |
| LPAREN / RPAREN | ( ) | 原样保留 |
| LINE_COMMENT | -- 注释内容 | 原样保留，保持位置 |
| VARIABLE | ${v_date} | 原样保留 |

### Token 结构

```java
class Token {
    TokenType type;
    String text;        // 原始文本
    int line;           // 原始行号（用于调试）
}
```

## 分词器（SqlTokenizer）

### 多词关键字优先匹配

优先匹配多词关键字再匹配单词，例如 `LEFT JOIN` 作为一个 KEYWORD token，`INSERT OVERWRITE TABLE` 作为一个 KEYWORD token。

匹配顺序：
```
INSERT OVERWRITE TABLE
LEFT JOIN
RIGHT JOIN
INNER JOIN
FULL JOIN
CROSS JOIN
UNION ALL
ORDER BY
GROUP BY
PARTITION BY
CLUSTER BY
DISTRIBUTE BY
SORT BY
-- 然后才是单词: SELECT, FROM, WHERE, AND, OR, ON, AS, IN, etc.
```

### 函数识别

遇到 `标识符(` 模式时，检查标识符是否在函数列表中（且不在关键字列表中），如果是则标记为 FUNCTION。函数列表（均小写匹配）：

```
nvl, coalesce, if, case, when, get_json_object, split, size, concat,
concat_ws, substr, substring, trim, upper, lower, length, replace,
regexp_replace, cast, date_format, date_add, date_sub, datediff,
from_unixtime, unix_timestamp, to_date, year, month, day, hour,
row_number, rank, dense_rank, sum, count, max, min, avg, distinct,
collect_list, collect_set, explode, posexplode, json_tuple, parse_url
```

### 行内注释处理

- `--` 开始到行尾作为一个 LINE_COMMENT token
- 输出时保持原位置（行尾则跟在同一行，独立一行则单独一行）

## 格式化器（SqlFormatter）

### 状态管理

```java
class FormatContext {
    int indentLevel;        // 当前缩进层
    Clause currentClause;   // 当前子句: SELECT/FROM/WHERE/INSERT/CTE/NONE
    boolean insideCte;      // 是否在 CTE 内部
    int columnAlignment;    // SELECT 列对齐位置
    boolean afterComma;     // 刚输出完逗号
}
```

### 缩进规则

| 上下文 | 缩进 |
|--------|------|
| 顶级（主查询） | 0 |
| CTE 内部 | +4 |
| SELECT 列列表 | 对齐到第一个列 |
| 子查询 `(` 后 | +4 |
| 插入到 `INSERT OVERWRITE ...` | 0（对齐 INSERT） |

### 换行规则

| 场景 | 行为 |
|------|------|
| CTE 定义 | `cte_name as (` 同行，内容折行 |
| CTE 结束 `)` | 独立一行 |
| CTE 之间 | 空行 |
| SELECT 后列 | 首列同行，后续列逗号后换行 |
| FROM/JOIN | 新行，与 SELECT 左对齐 |
| WHERE | 新行，与 SELECT 左对齐 |
| AND/OR | 新行，与 WHERE 左对齐 |
| INSERT OVERWRITE | 新行，独占一行 |
| 子查询 `SELECT` | 新行，缩进 4 空格 |
| `)` 结束子查询 | 独立一行，缩进与对应 `(` 一致 |

### 逻辑不变保障（核心约束）

- 不修改任何 STRING / NUMBER / VARIABLE / LINE_COMMENT token 的内容
- IDENTIFIER 原样保留（不转大小写）
- 只调整 KEYWORD（大写）和 FUNCTION（小写）的大小写
- 输出控制仅涉及：换行位置、缩进空格、关键字前后空格

**验证方式**：格式化前后，按 token 类型逐项比较，跳过 KEYWORD/FUNCTION 的大小写差异和空白差异后，其余 token 的文本内容必须完全一致。验证脚本对比 tokenizer 输出的原始 token 序列和重新分词后的格式化结果的 token 序列。

## IntelliJ Plugin 集成

### plugin.xml

```xml
<idea-plugin>
    <id>com.peach.dataworks-sql-format</id>
    <name>DataWorks SQL Format</name>
    <vendor>peach</vendor>
    <description>DataWorks SQL 格式化工具，遵循 dataworks-sql-format 规范</description>

    <depends>com.intellij.modules.platform</depends>

    <actions>
        <action id="DataWorksSqlFormatAction"
                class="com.peach.sqlformat.action.DataWorksSqlFormatAction"
                text="DataWorks SQL 格式化"
                description="按 DataWorks SQL 规范格式化">
            <add-to-group group-id="EditorPopupMenu"
                          anchor="after"
                          relative-to="Cut"/>
        </action>
    </actions>
</idea-plugin>
```

### AnAction

```java
public class DataWorksSqlFormatAction extends AnAction {
    @Override
    public void actionPerformed(@NotNull AnActionEvent e) {
        Editor editor = e.getRequiredData(CommonDataKeys.EDITOR);
        Project project = e.getRequiredData(CommonDataKeys.PROJECT);
        Document document = editor.getDocument();

        String selectedText = editor.getSelectionModel().getSelectedText();
        String source = selectedText != null ? selectedText : document.getText();

        SqlFormatter formatter = new SqlFormatter(new SqlTokenizer());
        String result = formatter.format(source);

        WriteCommandAction.runWriteCommandAction(project, () -> {
            if (selectedText != null) {
                int start = editor.getSelectionModel().getSelectionStart();
                int end = editor.getSelectionModel().getSelectionEnd();
                document.replaceString(start, end, result);
            } else {
                document.setText(result);
            }
        });
    }

    @Override
    public void update(@NotNull AnActionEvent e) {
        VirtualFile file = e.getData(CommonDataKeys.VIRTUAL_FILE);
        e.getPresentation().setEnabledAndVisible(
            file != null && file.getName().endsWith(".sql")
        );
    }
}
```

## 测试策略

| 测试层级 | 内容 | 方式 |
|---------|------|------|
| 单元测试 | SqlTokenizer 分词正确性 | JUnit，纯字符串输入 |
| 单元测试 | SqlFormatter 格式化输出 | JUnit，输入 → 预期输出 |
| 集成测试 | 完整链路 tokenize → format | JUnit，对比实际 SQL 文件格式化结果 |
| 逻辑不变测试 | 去格式化后 SQL 骨架一致 | 去除所有空白和大小写后对比 |

### 测试用例覆盖

- 简单 SELECT
- CTE WITH 查询
- 子查询嵌套
- JOIN + ON
- WHERE + AND 条件
- INSERT OVERWRITE
- 行内注释保留
- ${v_date} 变量保留
- Hive 函数调用
- 窗口函数（row_number over ...）
- CASE WHEN 表达式
- UNION ALL
- 空输入 / 纯注释 / 空文件

## Skill 封装

dataworks-sql-format 的所有格式化规则已编码到插件代码中：

- `KeywordDictionary.java` — 关键字列表和函数列表（对应 skill 第 1 节"整体风格"）
- `SqlFormatter.java` — 缩进、换行、对齐逻辑（对应 skill 第 2-9 节）
- `SqlTokenizer.java` — 变量 `${}`、注释 `--`、字符串的保留逻辑

同时将完整的 `SKILL.md` 打包进插件资源（`src/main/resources/`），作为插件内置文档。用户可在 IDEA 的插件设置中查看规则说明。

## 非功能性需求

- JDK 11+ 兼容
- IntelliJ IDEA 2021.3+（最低兼容版本）
- 插件大小控制在 100KB 以内（无第三方依赖）

## 使用方式

1. 打开任意 `.sql` 文件
2. 右键 → "DataWorks SQL 格式化"
3. 如需格式化部分内容，选中后右键 → "DataWorks SQL 格式化"
