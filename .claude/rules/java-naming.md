---
trigger: always_on
---
# Java 命名规范

## 通用命名规则（阿里规范）

- **类名**：UpperCamelCase，如 `UserService`、`OrderController`
- **方法名/变量名**：lowerCamelCase，如 `getUserById`、`userName`
- **常量**：全大写下划线分隔，如 `MAX_RETRY_COUNT`
- **包名**：全小写，点分隔，如 `com.company.project.web`
- **抽象类**：以 `Abstract` 或 `Base` 开头，如 `AbstractHandler`
- **异常类**：以 `Exception` 结尾，如 `BizException`
- **枚举类**：以 `Enum` 结尾，成员名全大写，如 `StatusEnum.ACTIVE`
- **布尔变量**：POJO 中禁止以 `is` 开头，避免序列化问题

## 项目特有命名规范

### 类命名与包位置

| 类型 | 后缀 | 包路径 |
|------|------|--------|
| Controller | `Controller` | `com.company.project.web.controller` |
| Service 接口 | `Service` | `com.company.project.biz.service` |
| Service 实现 | `Impl` | `com.company.project.biz.service.impl` |
| DAO 接口 | `Dao` | `com.company.project.dal.dao` |
| 数据库实体 | 无特定后缀 | `com.company.project.dal.entity` |
| 查询条件对象 | `QO` | `com.company.project.dal.query` |
| Form 对象 | `Form` | `com.company.project.web.form` |
| 传输对象 | `TO` | `com.company.project.web.to` |
| 返回结果 | `Result` | `com.company.project.web.result` |
| 枚举 | `Enum` | `com.company.project.enums` |
| 异常 | `Exception` | `com.company.project.core.exception` |
| 常量 | `Constants` | `com.company.project.biz.constants` |

### DAO 方法命名

- **查询**：`selectXxx` / `getXxx` / `queryXxx`
  - 单条：`selectById`、`getByPhone`
  - 列表：`selectList`、`queryByCondition`
- **插入**：`insert` / `insertBatch`
- **更新**：`update` / `updateByXxx`
- **删除**：`delete` / `deleteByXxx`

### 集合变量命名

- 带类型后缀，明确集合元素类型
- List：`userIdList`、`orderList`
- Set：`phoneSet`、`tagSet`
- Map：`userIdMap`、`codeNameMap`
- 数组：以 `s` 结尾，如 `userIds`

### 示例

```java
// 正确
List<Long> userIdList = new ArrayList<>();
Set<String> phoneSet = new HashSet<>();
Map<Long, User> userIdMap = new HashMap<>();

// 错误
List<Long> userIds;  // 缺少 List 后缀
List<Long> users;    // 类型不明确
```

## 各层对象命名约定

| 对象类型 | 说明 | 示例 |
|----------|------|------|
| `Form` | 页面传递给 action 层的入参对象 | `CreateUserForm` |
| `VO` | action 层返回给页面的对象 | `UserVO` |
| `DTO` | 服务层间传递数据的对象 | `UserDTO` |
| `Entity` | 数据库实体对象 | `User` |
| `Query` / `QO` | 构造查询条件的对象 | `UserQO` |
| `TO` | 外部 API 入参和出参对象 | `UserTO` |

## 异构对象转换方法命名

- 格式：`to{目标类型}From{源类型}`
- 示例：`toEntityFromDTO`、`toDTOFromForm`
- 禁止使用 Dozer / BeanMapper 等动态拷贝工具（存在运行时问题）

## 废弃方法注释规范

- 使用 `@Deprecated` 注解标注废弃方法时，**必须**在 Javadoc 中说明废弃原因和推荐的替代方法
- ❌ 禁止只写 `@Deprecated` 而无任何说明

```java
/**
 * @deprecated 已废弃，请使用 {@link #getUserByPhone(String)} 替代
 */
@Deprecated
public User getUser(String phone) { ... }
```
