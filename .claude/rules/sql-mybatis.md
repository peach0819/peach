---
trigger: always_on
---
# SQL 与 MyBatis 开发规范

## 表设计规范（阿里规范）

### 命名

- 表名：前缀t+下划线+小写字母 + 下划线，如 `t_user_account`
- 字段名：、`create_time`
- 禁止使用 MySQL 保留字作为表名/字段名

### 必备字段

每张表必须包含以下字段：

```sql
id           BIGINT       -- 主键，使用 int 类型，varchar 效率不高
create_time  DATETIME     -- 创建时间，自动赋值
edit_time    DATETIME     -- 修改时间，自动赋值
creator      VARCHAR(64)  -- 创建人
editor       VARCHAR(64)  -- 修改人
is_deleted   TINYINT      -- 软删除标记，0=未删除，1=已删除
```

### create_time / edit_time 约束

- **禁止通过后端代码传值方式设置** `create_time` 和 `edit_time`
- 新建 SQL 必须将这两个字段设置为**数据库自动赋值**，程序无需关心
- 如果主动在 update 语句中写 `edit_time = NOW()`，即使业务字段无变化也会产生 binlog，可能导致 binlog 挤压；遗留代码可以保留，**新代码禁止**

```sql
-- 正确：数据库自动赋值
CREATE TABLE t_user (
    ...
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    edit_time   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    ...
);

-- 错误：新代码不允许程序主动写 edit_time
UPDATE t_user SET name = #{name}, edit_time = NOW() WHERE id = #{id}
```

### 数据类型

- 小数使用 `DECIMAL`，禁止 `FLOAT`/`DOUBLE`
- `VARCHAR` 按实际需要定义长度，不预留过大
- 单表行数超 500 万或容量超 2GB 建议分表

### 索引命名

- 主键索引：`pk_字段名`
- 唯一索引：`uk_字段名`
- 普通索引：`idx_字段名`

## MyBatis 开发规范

### 严禁连表查询（项目特有）

- **mapper.xml 中仅允许单表查询**
- 禁止 JOIN、子查询关联
- 多表数据在 biz 层用 Java 代码组装

```xml
<!-- 正确 - 单表查询 -->
<select id="selectByUserId" resultType="Account">
    SELECT <include refid="Base_Column_List"/>
    FROM account
    WHERE user_id = #{userId} AND is_deleted = 0
</select>

<!-- 错误 - 禁止连表 -->
<select id="selectWithUser" resultType="Account">
    SELECT a.*, u.name FROM account a 
    JOIN user u ON a.user_id = u.id
</select>
```

### SQL 编写注意事项

1. **所有 SQL 语句必须走索引**，每条查询应针对具体的业务场景，禁止大而全的通用 SQL
2. **禁止无条件查询**，防止全表扫描，严厉禁止
3. 联合索引查询条件须遵循**最左对齐**原则，否则无法命中索引
4. **函数写在 `=` 右边**，写在左边会导致索引失效：`create_time <= DATE_ADD(NOW(), INTERVAL 1 DAY)` ✅
5. 查询条件值的类型必须与表中字段类型一致，类型不一致会导致索引失效（如字符串字段传整型）
6. **禁止 `SELECT *`**，必须显式指定所需字段
7. 带子查询的语句建议改为两表 JOIN 写法

### 参数绑定

- 使用 `#{}` 参数绑定，**禁止 `${}`**（防 SQL 注入）
- 仅动态表名/列名可用 `${}`，且必须白名单校验

### 标准写法

```xml
<!-- 列列表复用 -->
<sql id="Base_Column_List">
    id, user_id, account_name, status, create_time, edit_time, is_deleted
</sql>

<!-- 动态条件 -->
<select id="selectByCondition" resultType="Account">
    SELECT <include refid="Base_Column_List"/>
    FROM account
    WHERE is_deleted = 0
    <if test="userId != null">
        AND user_id = #{userId}
    </if>
    <if test="status != null">
        AND status = #{status}
    </if>
</select>

<!-- 获取自增主键 -->
<insert id="insert" useGeneratedKeys="true" keyProperty="id">
    INSERT INTO account (user_id, account_name, status, create_time)
    VALUES (#{userId}, #{accountName}, #{status}, NOW())
</insert>
```

### DAO 接口规范

- 多参数使用 `@Param` 注解
- 查询条件对象以 `QO` 结尾，定义在 `dal.query` 包

```java
public interface AccountDao {
    Account selectById(@Param("id") Long id);
    
    List<Account> selectByCondition(AccountQO qo);
    
    int insert(Account account);
    
    int updateStatus(@Param("id") Long id, @Param("status") Integer status);
}
```

### 软删除

- 查询默认加 `WHERE is_deleted = 0`
- 删除操作使用 `UPDATE ... SET is_deleted = 1`

```xml
<update id="deleteById">
    UPDATE account SET is_deleted = 1, edit_time = NOW() WHERE id = #{id}
</update>
```
