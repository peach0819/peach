---
name: dataworks-sql-format
description: 数仓 SQL 格式化规范（Hive SQL / Spark SQL）。TRIGGER when: 用户要求格式化 SQL、编写数仓 ETL SQL、或按数仓规范生成 SQL（Hive/Spark）。
license: MIT
metadata:
  author: shared
  version: "2.0"
---

# 数仓 SQL 格式化规范

使用此 Skill 时，严格遵循以下规范格式化或编写数仓 SQL（Hive SQL / Spark SQL）。

---

## 强制要求：不改变原有 SQL 语义

> **核心原则：格式化过程必须等价变换，不得改变原始 SQL 的任何语义、逻辑或行为。**

| 禁止项 | 说明 |
|--------|------|
| 禁止修改表名、列名、别名 | 不得展开 `*`、不得改写列引用、不得修改别名。仅可调整大小写（关键字大写、函数小写） |
| 禁止修改常量 | 字符串、数字、日期常量必须原样保留 |
| 禁止重写表达式 | `a + b + c` 不能改成 `(a + b) + c` |
| 禁止重排/合并 SQL | CTE 顺序、JOIN 顺序、WHERE 条件顺序必须保持原样 |
| 禁止修改注释位置和内容 | 注释必须原样保留，不得删除、合并或移动 |
| 禁止猜测补齐 | 不得添加推测的 `;`、空格外的字符、推测的缺省值、推测的列名 |
| 禁止动 `partition` | partition 字段和值必须原样保留 |

**格式化仅允许以下变更：**
- 关键字大小写（小写→大写）
- 函数/表达式大小写（大写→小写）
- 缩进调整（统一 4 空格）
- 多余空行压缩、行尾多余空格删除
- 对齐调整（列对齐、换行位置）

> 若不确定某项变更是否等价，**保守处理**，保留原样。

---

## 1. 整体风格

| 项目 | 规范 |
|------|------|
| SQL 关键字 | **大写**：`WITH`, `SELECT`, `FROM`, `WHERE`, `INSERT OVERWRITE TABLE`, `INNER JOIN`, `LEFT JOIN`, `RIGHT JOIN`, `FULL JOIN`, `ON`, `AND`, `OR`, `IN`, `NOT IN`, `IS NULL`, `IS NOT NULL`, `LIKE`, `ORDER BY`, `GROUP BY`, `DISTINCT`, `UNION ALL` |
| 函数/表达式 | **小写**：`coalesce()`, `nvl()`, `if()`, `get_json_object()`, `split()`, `concat()`, `cast()`, `date_format()`, `row_number()`, `rank()`, `sum()`, `count()`, `max()`, `min()`, `avg()` 等 |
| 别名 `as` | **小写**，前后各一个空格：`shop.shop_pro_id as province_id` |
| 缩进 | 4 空格 |
| CTE 名称 | **小写 + 下划线**：`feature_group`, `group_shop` |
| 表名 | 保留原始大小写，带数据库前缀：`yt_crm.ads_crm_subject_feature_group_d` |

---

## 2. CTE（WITH 子句）

```
WITH cte_name as (
    select col1,
           col2,
           col3
    from schema.table
    where dayid = '${v_date}'
),

next_cte as (
    select ...
    from ...
)
```

- `WITH` 独占一行，后接 CTE 名
- CTE 体缩进 **4 空格**
- CTE 结束的 `)` **独占一行**，与 `WITH` **同列对齐（缩进 0）**
- CTE 之间用**空行分隔**
- CTE 间逗号后也有空行

---

## 3. SELECT 子句

```
SELECT col1,
       col2,
       func(col3) as alias_name,
       if(condition, expr1, expr2) as result_col
```

- `SELECT` 独占一行
- **首个字段**跟在 `SELECT` 同一行
- **后续字段**换行，按 `SELECT` 的 `S` 列对齐（前面补 7 空格）
- 每列独占一行，逗号在**行尾**
- 别名使用小写 `as`

### 逗号换行规则

以下场景的逗号**触发换行**和对齐：
- `SELECT` 列表中的列分隔
- `GROUP BY` / `ORDER BY` 列表中的列分隔

以下场景的逗号**不换行**（保持同行）：
- **函数参数内部**：`nvl(a, b, c)`、`get_json_object(feature, '$.key')`、`coalesce(a, b, c, d)`
- **未知 UDF 参数**：`yt_crm.get_subject_service_info(a, b)`
- **OVER 窗口函数内部**：`row_number() over (partition by col1 order by col2)`
- **IN 列表内部**：`IN ('a', 'b', 'c')`、`NOT IN (1, 2, 3)`

---

## 4. FROM / JOIN

```
FROM table_name t
LEFT JOIN other_table o ON o.id = t.id AND o.type = t.type
```

- `FROM` 独占一行，与 `SELECT` 左对齐
- `*JOIN` 独占一行，与 `FROM` 左对齐
- `ON` 条件跟在 `JOIN` 同一行
- `ON` 中多个 `AND`/`OR` 条件**不换行**，保持在 ON 同一行

---

## 5. WHERE / AND / OR

```
WHERE dayid = '${v_date}'
AND bu_id = 0
AND status NOT IN (1, 2, 3)
```

- `WHERE` 独占一行，与 `FROM` 左对齐
- `AND`/`OR` 放在**行首**，与 `WHERE` 对齐

**例外（AND/OR 不换行的场景）：**
- 在 `JOIN ON` 条件中 → 保持同行
- 在 `CASE WHEN` 条件中 → 保持同行
- 在函数调用内部 → 保持同行

---

## 6. 子查询（Subquery）

```
SELECT ...
FROM (
    SELECT col1,
           col2,
           row_number() over (partition by col1 order by col2) as rn
    FROM table
    WHERE condition
) t
```

- `FROM (` 后开始子查询
- 子查询内容缩进 **4 空格**
- 子查询结束的 `)` **独占一行**，与 `FROM` 对齐
- 别名跟在 `)` 后：`) t`
- `JOIN (SELECT ...)` 同理，内容缩进 4 空格，`)` 与 `JOIN` 对齐
- 支持**多层嵌套**子查询

---

## 7. INSERT OVERWRITE

```
INSERT OVERWRITE TABLE target_table partition (dayid='${v_date}')
SELECT ...
```

- `INSERT OVERWRITE TABLE ... partition` 独占一行
- 紧随其后的 `SELECT` 另起一行，与 `INSERT` 左对齐
- partition 写法：`partition (dayid='${v_date}')`
- INSERT 前有一个空行

---

## 8. CASE WHEN

```
-- 单个 WHEN：全在一行
SELECT CASE WHEN status = 1 THEN 'active' ELSE 'inactive' END as status_label

-- 多个 WHEN：每个 WHEN 换行对齐
SELECT CASE WHEN a = 1 THEN 'one'
            WHEN a = 2 THEN 'two'
            ELSE 'other' END as val
```

- **单个 WHEN**：`CASE WHEN ... THEN ... ELSE ... END` 全部在同一行
- **多个 WHEN**：第一个 WHEN 在 CASE 行首；后续 WHEN 各自换行，与第一个 WHEN **列对齐**
- **ELSE**：单个 WHEN → 同行；多个 WHEN → 换行，对齐 WHEN 列
- **END**：紧跟 ELSE（不换行）
- **嵌套 CASE**：支持嵌套

---

## 9. UNION / UNION ALL

```
WHERE condition

UNION ALL

SELECT ...
```

- `UNION ALL` / `UNION DISTINCT` / `UNION` 前后各有一个空行
- 缩进回到 0（不额外缩进）

---

## 10. OVER 窗口函数

```
SELECT id,
       lead(create_time, 1, 9999) over (partition by user_id order by create_time) as next_time
```

- `OVER (...)` 内所有内容保持在同一行
- `PARTITION BY`、`ORDER BY` 等关键词在 OVER 内部不换行
- 内部逗号不触发换行

---

## 11. IN 列表

```
WHERE status IN ('a', 'b', 'c')
WHERE status NOT IN (1, 2, 3, 4, 5)
```

- `IN (...)` / `NOT IN (...)` 内所有元素保持在同一行
- 内部逗号不触发换行

---

## 12. 注释

### 行注释 `--`

```
-- 行注释放在语句行尾
AND shop_status != 6 -- 排除未合作门店
```

- 行内注释 `-- text` 放在代码**之后**，`--` 前至少一个空格
- 注释后紧跟 `AND` → **不留空行**
- SELECT 列的行尾注释：注释跟在列名后，下一列继续对齐

### 块注释 `/* */`

- 保留，前后各一空格

---

## 13. 其他格式细节

| 规则 | 行为 |
|------|------|
| 点号 `.` | 前后无空格（`t.id`、`schema.table`） |
| 方括号 `[]` | 前后无空格（`arr[1]`） |
| 分号 `;` | 后换行 |
| 运算符 | 前后空格（`=`, `>`, `<`, `!=`, `<>`, `<=`, `>=`） |
| 反引号标识符 | 保留（`` `select` ``、`` `from` ``） |
| `${variable}` 变量 | 保留在字符串中 |

---

## 14. 完整示例

```sql
WITH feature_group as (
    select feature_type,
           group_type,
           group_type_tag,
           feature_ids,
           1 as join_tag
    from yt_crm.ads_crm_subject_feature_group_d
    where dayid = '${v_date}'
),

shop as (
    SELECT shop_id,
           shop_name,
           shop_pro_id,
           latitude,
           longitude
    FROM ytdw.dw_shop_base_d
    WHERE dayid = '${v_date}'
    AND bu_id = 0
    AND store_type NOT IN (9, 11) -- 排除员工店、伙伴店
),

joined as (
    SELECT feature_group.feature_type,
           feature_group.group_type,
           shop.shop_id,
           shop.shop_name,
           yt_crm.get_subject_service_info(feature_group.feature_ids, shop.service_info) as feature_service_info
    FROM feature_group
    LEFT JOIN shop ON feature_group.join_tag = shop.join_tag
)

INSERT OVERWRITE TABLE ads_crm_subject_shop_user_d partition (dayid='${v_date}')
SELECT joined.feature_type,
       joined.group_type,
       joined.shop_id,
       if(joined.shop_address_id = '其他', 0, joined.shop_address_id) as address_id,
       get_json_object(joined.feature_service_info, '$.service_user_id') as user_id
FROM joined
WHERE joined.feature_service_info is not null
```

---

## 15. 使用方式

在对话中告诉 Claude：

> 按数仓 SQL 格式规范，格式化以下 SQL：
> ```sql
> ...
> ```

或：

> /dataworks-sql-format 格式化下面这段 SQL：...
