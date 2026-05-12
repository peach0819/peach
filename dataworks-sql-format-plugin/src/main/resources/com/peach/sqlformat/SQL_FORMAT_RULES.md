# DataWorks SQL Format Plugin

## 数仓 SQL 格式化规范（Hive SQL / Spark SQL）

遵循以下规范格式化数仓 SQL。

### 1. 整体风格

| 项目 | 规范 |
|------|------|
| SQL 关键字 | **大写**：`SELECT`, `FROM`, `WHERE`, `INSERT OVERWRITE TABLE`, `JOIN`, `ON`, `AND`, `OR`, `ORDER BY`, `GROUP BY` 等 |
| 函数/表达式 | **小写**：`nvl()`, `coalesce()`, `get_json_object()`, `row_number()`, `sum()`, `count()` 等 |
| 别名 `as` | **小写**，前后各一个空格 |
| 缩进 | 4 空格 |

### 2. CTE（WITH 子句）

- `WITH` 后接 CTE 名，同一行
- CTE 内缩进 **4 空格**
- CTE 结束的 `)` 独占一行
- CTE 之间用空行分隔

### 3. SELECT 子句

- `SELECT` 独占一行
- 首个字段跟在 `SELECT` 同一行
- 后续字段换行，按 `SELECT` 的 `S` 列对齐
- 每列独占一行，逗号在行尾

### 4. FROM / JOIN

- `FROM` 独占一行
- `JOIN` 独占一行，与 `FROM` 左对齐
- `ON` 条件跟在 `JOIN` 同一行

### 5. WHERE / AND / OR

- `WHERE` 独占一行
- `AND` / `OR` 放在行首，与 `WHERE` 对齐

### 6. 子查询（Subquery）

- 子查询内容缩进 **4 空格**
- 子查询结束的 `)` 独占一行

### 7. INSERT OVERWRITE

- `INSERT OVERWRITE TABLE ... partition` 独占一行
- 紧随其后的 `SELECT` 另起一行

### 8. 注释

- 行内注释 `-- text` 保留
- `--` 前至少一个空格
