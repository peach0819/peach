---
name: dataworks-sql-format
description: 数仓 SQL 格式化规范（Hive SQL / Spark SQL）。TRIGGER when: 用户要求格式化 SQL、编写数仓 ETL SQL、或按数仓规范生成 SQL（Hive/Spark）。
license: MIT
metadata:
  author: shared
  version: "1.0"
---

# 数仓 SQL 格式化规范

使用此 Skill 时，严格遵循以下规范格式化或编写数仓 SQL（Hive SQL / Spark SQL）。

---

---

## 强制要求：不改变原有 SQL 语义

> **核心原则：格式化过程必须等价变换，不得改变原始 SQL 的任何语义、逻辑或行为。**

| 禁止项 | 说明 |
|--------|------|
| 禁止修改表名、列名、别名 | 不得展开 `*`、不得改写列引用、不得修改别名。仅可调整大小写（关键字大写、函数小写） |
| 禁止修改常量 | 字符串、数字、日期常量必须原样保留 |
| 禁止重写表达式 | `a + b + c` 不能改成 `(a + b) + c`，`NOT IN` 不能改成 `NOT IN`（大小写除外） |
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
| SQL 关键字 | **大写**：`WITH`, `SELECT`, `FROM`, `WHERE`, `INSERT OVERWRITE TABLE`, `INNER JOIN`, `LEFT JOIN`, `RIGHT JOIN`, `FULL JOIN`, `ON`, `AND`, `OR`, `IN`, `NOT IN`, `IS NULL`, `IS NOT NULL`, `LIKE`, `ORDER BY`, `GROUP BY`, `DISTINCT`, `UNION ALL`, `AS` |
| 函数/表达式 | **小写**：`coalesce()`, `nvl()`, `if()`, `case when`, `get_json_object()`, `split()`, `size()`, `concat()`, `cast()`, `date_format()`, `row_number()`, `rank()`, `sum()`, `count()`, `max()`, `min()`, `avg()` 等 |
| 别名 `as` | **小写**，前后各一个空格：`shop.shop_pro_id as province_id` |
| 缩进 | 4 空格 |
| CTE 名称 | **小写 + 下划线**：`feature_group`, `group_shop`, `dept` |
| 表名 | 保留原始大小写（通常为小写 + 下划线），带数据库前缀：`yt_crm.ads_crm_subject_feature_group_d` |

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

- `WITH` 后接 CTE 名，**同一行**
- CTE 名 `as (` 中间有空格，`(` **不换行**
- CTE 内缩进 **4 空格**
- CTE 结束的 `)` **独占一行**，与 CTE 内容首列对齐
- CTE 之间用**空行分隔**
- 最后一个 CTE 之后**不加逗号**，直接接主查询

---

## 3. SELECT 子句

```
SELECT col1,
       col2,
       func(col3) as alias_name,
       if(condition, expr1, expr2) as result_col
```

- `SELECT` 独占一行
- **首个字段/列**跟在 `SELECT` 同一行（若单列则直接同行）
- **后续字段**换行，按 `SELECT` 的 `S` 列对齐（即前面补 7 空格对齐到 `S` 之后）
- 每列独占一行，逗号在**行尾**
- 别名使用小写 `as`
- 函数调用全部小写
- 复杂表达式尽量保持单行

---

## 4. FROM / JOIN

```
FROM table_name
LEFT JOIN other_table ON condition
```

- `FROM` 独占一行，与 `SELECT` 左对齐
- `JOIN` 独占一行，与 `FROM` 左对齐
- `ON` 条件跟在 `JOIN` 同一行
- 子查询中的 `FROM` 同理

---

## 5. WHERE / AND / OR

```
WHERE dayid = '${v_date}'
AND bu_id = 0
AND status NOT IN (1, 2, 3) -- 排除某些状态
```

- `WHERE` 独占一行，与 `FROM` 左对齐
- `AND` / `OR` 放在**行首**，与 `WHERE` 的 `W` 对齐
- 行内注释 `--` 放在条件语句末尾

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

- 外层 `(` 不换行，跟在 `FROM (` 之后（或 `FROM (` 独占一行后跟 `(`）
- 子查询内容缩进 **4 空格**
- 子查询结束的 `)` 独占一行，与子查询内容对齐
- 别名跟在 `)` 后：`) t` 或 `) alias`

---

## 7. INSERT OVERWRITE

```
INSERT OVERWRITE TABLE target_table partition (dayid='${v_date}')
SELECT ...
```

- `INSERT OVERWRITE TABLE ... partition` 独占一行
- 紧随其后的 `SELECT` 另起一行，与 `INSERT` 左对齐
- partition 写法：`partition (dayid='${v_date}')`

---

## 8. 注释

```
-- 行注释：双短横线 + 空格，放在语句行尾
AND shop_status != 6 -- 排除未合作门店
```

- 行内注释 `-- text` 放在代码**之后**，`--` 前至少一个空格
- 无单独的块注释风格

---

## 9. 完整示例

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

## 10. 使用方式

在对话中告诉 Claude：

> 按数仓 SQL 格式规范，编写以下 SQL：...
>
> 或
>
> /generic-sql-format 格式化下面这段 SQL：...
