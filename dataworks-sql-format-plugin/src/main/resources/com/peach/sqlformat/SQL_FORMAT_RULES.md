# DataWorks SQL Format Plugin 格式化规则

## 一、词法级别（Tokenizer 层）

### 1.1 关键词识别

- **Multi-word 关键词**（贪婪匹配，最长优先）：
  `INSERT OVERWRITE TABLE`、`LEFT ANTI JOIN`、`LEFT SEMI JOIN`、`LEFT OUTER JOIN`、`RIGHT OUTER JOIN`、`FULL OUTER JOIN`、`CROSS JOIN`、`INNER JOIN`、`LEFT JOIN`、`RIGHT JOIN`、`FULL JOIN`、`UNION ALL`、`UNION DISTINCT`、`ORDER BY`、`GROUP BY`、`PARTITION BY`、`CLUSTER BY`、`DISTRIBUTE BY`、`SORT BY`
- **单字关键词**：约 60 个，涵盖 DML（SELECT/FROM/WHERE/INSERT 等）、DDL（CREATE/ALTER/DROP/PARTITIONED/STORED 等）、条件（CASE/WHEN/THEN/ELSE/END）、集合（UNION）、Hive 特有（LATERAL VIEW/MAP/REDUCE/TABLESAMPLE 等）
- **函数识别**：如果一个标识符后跟 `(` 且不是关键词，则标记为 FUNCTION

### 1.2 拼接关键词拆分

- `ENDELSE` → `END` + `ELSE`
- `ENDWHEN` → `END` + `WHEN`

### 1.3 Token 类型

`KEYWORD`、`FUNCTION`、`IDENTIFIER`、`STRING`、`NUMBER`、`OPERATOR`、`COMMA`、`DOT`、`LPAREN`、`RPAREN`、`STAR`、`LINE_COMMENT`、`BLOCK_COMMENT`、`VARIABLE`、`SEMICOLON`、`LBRACKET`、`RBRACKET`、`EOF`

### 1.4 字面量支持

- 单引号字符串（`''` 转义）
- 双引号字符串（`""` 转义）
- 反引号标识符
- `${variable}` 变量表达式
- `--` 行注释（到行尾）
- `/* */` 块注释

## 二、大小写规则

| 规则 | 示例 |
|------|-------|
| **关键词大写** | `SELECT`, `FROM`, `WHERE`, `INSERT OVERWRITE TABLE`, `JOIN`, `AND`, `OR` 等 |
| **函数名小写** | `nvl()`, `coalesce()`, `get_json_object()`, `row_number()`, `sum()`, `count()` 等 |
| **别名 AS 小写** | `as`（前后各一空格） |
| **非内置 UDF 也小写** | 只要是 `xxx(` 模式就转小写 |

## 三、缩进规则

- **基础缩进**：4 个空格
- **子查询体**：`FROM (SELECT ...)` 或 `JOIN (SELECT ...)` 内容缩进一级
- **CTE 体**：`WITH xxx AS (SELECT ...)` 内容缩进一级
- 子查询 / CTE 的结束 `)` 返回到当前缩进级别

## 四、子句换行规则

### 4.1 子句启动关键词（独占一行，当前缩进对齐）

以下关键词出现时**强制换行**（除非在 OVER 窗口函数内部）：

`SELECT`、`FROM`、`WHERE`、`GROUP BY`、`ORDER BY`、`HAVING`、`LIMIT`、`WITH`、`CLUSTER BY`、`DISTRIBUTE BY`、`SORT BY`、`INSERT`

### 4.2 JOIN 关键词（换行，与 FROM 对齐）

所有包含 `JOIN` 的复合关键词：

`INNER JOIN`、`LEFT JOIN`、`LEFT OUTER JOIN`、`LEFT SEMI JOIN`、`LEFT ANTI JOIN`、`RIGHT JOIN`、`RIGHT OUTER JOIN`、`FULL JOIN`、`FULL OUTER JOIN`、`CROSS JOIN`

### 4.3 UNION（前后空行）

`UNION ALL` / `UNION DISTINCT` / `UNION` 前后各有一个空行，缩进回到 0。

### 4.4 INSERT 前面空行

在最外层 `INSERT` 之前增加一个空行。

## 五、逗号换行规则

### 5.1 SELECT / GROUP BY / ORDER BY 列表中

- 逗号在行尾，下一列换行到对齐位置：
  - `SELECT` → 7 字符偏移（从 `S` 列对齐）
  - `GROUP BY` / `ORDER BY` → 9 字符偏移
- 首个字段跟在 `SELECT` 同一行

### 5.2 函数参数内部

- **不换行**：所有逗号保持在同一行
- 包括已知函数（如 `nvl(a, b, c)`）和未知 UDF（如 `yt_crm.get_subject_service_info(a, b)`）

### 5.3 OVER 窗口函数内部

- **不换行**：`OVER (PARTITION BY ... ORDER BY ...)` 内所有逗号不触发换行

### 5.4 IN 列表内部

- **不换行**：`IN ('a', 'b', 'c')` 内逗号不触发换行
- 支持 `NOT IN`

### 5.5 CTE 之间

- CTE 结束的 `)` 后的逗号触发两个空行，准备下一个 CTE

## 六、子查询规则

- **FROM 子查询**：`FROM (SELECT ...)` → 内容缩进 4 空格，`)` 独占一行
- **JOIN 子查询**：`JOIN (SELECT ...)` → 同上
- **嵌套子查询**：支持多层嵌套，每层缩进叠加

## 七、CTE（WITH 子句）规则

- `WITH` 独占一行
- CTE 名跟在 `WITH` 同一行
- `AS (` 后内容缩进 4 空格
- CTE 体结束的 `)` **独占一行**，与 `WITH` **同列对齐（不额外缩进）**
- 多个 CTE 之间用空行分隔
- CTE 结束后查询从 `SELECT` 正常开始

## 八、JOIN / ON 规则

- `*JOIN` 独占一行，与 `FROM` 左对齐
- `ON` 跟在 JOIN 同一行
- `ON` 后的多个 `AND`/`OR` 条件**不换行**，保持在 ON 同一行

## 九、WHERE / AND / OR 规则

- `WHERE` 独占一行
- `AND`/`OR` **放在行首**，与 `WHERE` 对齐

**例外（不换行的 AND/OR）：**

- 在 `JOIN ON` 条件中 → 保持同行
- 在 `CASE WHEN` 条件中 → 保持同行
- 在函数调用内部 → 保持同行

## 十、CASE WHEN 规则

| 场景 | 行为 |
|------|------|
| **单个 WHEN** | `CASE WHEN ... THEN ... ELSE ... END` 全部在同一行 |
| **多个 WHEN** | 第一个 WHEN 在 CASE 行首；后续 WHEN 各自换行，与第一个 WHEN **列对齐** |
| **ELSE** | 单个 WHEN → 同行；多个 WHEN → 换行，对齐 WHEN 列 |
| **END** | 紧跟 ELSE（不换行） |
| **嵌套 CASE** | 支持嵌套，内外状态独立保存/恢复 |

## 十一、注释规则

### 11.1 行注释 `--`

- 保留原有注释内容
- 与上下文之间至少一个空格
- **SELECT 列行尾注释**：注释跟在列名后，下一列继续对齐（去掉列对齐缩进，把注释放行尾，再重新对齐）
- 注释后紧跟 `AND` → **不留空行**

### 11.2 块注释 `/* */`

- 保留，前后各一空格

### 11.3 CTE 注释特殊处理

- `WITH xxx as ( --注释` 中的 `(` 放到 `as` 之后、注释之前，避免 `(` 换行

## 十二、特殊上下文规则

### 12.1 OVER（窗口函数）

- `OVER` 后的 `(...)` 内部所有关键词不换行（`PARTITION BY`、`ORDER BY` 都在一行内）
- 内部逗号不触发换行

### 12.2 IN 列表

- `IN (...)` 内所有内容保持同行，逗号不换行
- 支持 `NOT IN`

### 12.3 点号 `.`

- 点号前后无空格（`t.id`、`schema.table`、`get_json_object(...)`）

### 12.4 方括号 `[]`

- 方括号前后无空格（`arr[1]`）

### 12.5 分号

- `;` 后换行

## 十三、语义保留

- 所有 token 的原始**语义顺序**不变
- 去除所有空白后，输出与输入等价（不改变 SQL 逻辑）

## 十四、内置函数字典

### 条件函数

`nvl`, `coalesce`, `if`

### JSON 函数

`get_json_object`, `json_tuple`, `from_json`, `to_json`

### 字符串函数

`split`, `concat`, `concat_ws`, `substr`, `substring`, `trim`, `ltrim`, `rtrim`, `upper`, `lower`, `length`, `replace`, `regexp_replace`, `regexp_extract`, `space`, `repeat`

### 日期函数

`date_format`, `date_add`, `date_sub`, `datediff`, `from_unixtime`, `unix_timestamp`, `to_date`, `year`, `month`, `day`, `hour`, `minute`, `second`, `next_day`, `last_day`, `trunc`, `weekofyear`, `dayofmonth`, `dayofyear`, `months_between`, `add_months`, `current_date`, `current_timestamp`

### 窗口函数

`row_number`, `rank`, `dense_rank`, `ntile`, `lag`, `lead`, `first_value`, `last_value`

### 聚合函数

`sum`, `count`, `max`, `min`, `avg`, `collect_list`, `collect_set`

### 其他函数

`explode`, `posexplode`, `parse_url`, `abs`, `ceil`, `floor`, `round`, `pow`, `sqrt`, `rand`, `greatest`, `least`, `str_to_map`, `map_keys`, `map_values`, `named_struct`, `encode`, `decode`, `assert_true`, `cast`

---

## 附：引擎核心设计

整个格式化引擎是一个 **状态机**（`FormaContext`），追踪以下上下文信息来决策每个 token 的输出格式：

| 状态变量 | 用途 |
|----------|------|
| `indentLevel` | 当前缩进层数 |
| `currentClause` | 当前子句类型（SELECT/FROM/WHERE/GROUP_BY/ORDER_BY/INSERT） |
| `parenDepth` | 括号嵌套深度 |
| `columnAlignment` | SELECT/ORDER BY/GROUP BY 列对齐位置 |
| `functionDepth` | 函数调用嵌套深度（控制逗号不换行） |
| `functionPending` | 下一个 `(` 是否为函数调用 |
| `subqueryDepthIndex` | 子查询嵌套栈指针 |
| `expectingSubquery` | 期待子查询（FROM/JOIN 后第一个 `(`） |
| `inJoinOn` | 是否在 JOIN ON 条件中（控制 AND/OR 同行） |
| `insideCte` / `cteOpenDepth` | CTE 体追踪 |
| `afterCte` / `expectingNextCte` | CTE 间逗号状态 |
| `caseDepth` / `caseWhenPosition` / `caseWhenCount` | CASE WHEN 嵌套与对齐 |
| `inOverClause` / `overOpenDepth` | OVER 窗口函数上下文 |
| `afterInKeyword` / `inClauseDepth` | IN 列表上下文 |
| `inWhenCondition` | CASE WHEN 条件中（控制 AND 同行） |
