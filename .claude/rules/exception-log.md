---
trigger: always_on
alwaysApply: true
---
# 异常处理与日志规范

## 异常处理规范

### 基本原则（阿里规范）

- 异常不用于流程控制
- catch 块不能为空，至少打印日志
- 事务中抛出异常需注意 rollback
- finally 中禁止使用 return
- 禁止 `e.printStackTrace()`，使用日志框架

### NPE 防范

- 使用 `Optional` 处理可能为 null 的返回值
- 工具类判空：`Objects.nonNull()`、`StringUtils.isNotBlank()`
- 远程调用返回值必须判空

### 全局异常处理器

项目应配置全局异常处理器统一处理异常：

| 异常类型 | 日志级别 | 堆栈 |
|----------|----------|------|
| 项目业务异常类 | WARN | 不打印 |
| 其他异常 | ERROR | 完整堆栈 |

### 事务注解

```java
// 必须指定 rollbackFor
@Transactional(rollbackFor = Exception.class)
public void saveUser(User user) {
    // ...
}
```

## 日志规范

### 日志框架

使用 SLF4J 门面：

```java
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class UserService {
    private static final Logger LOGGER = LoggerFactory.getLogger(UserService.class);
    // 也允许小写 logger
}
```

### 日志级别使用

| 级别 | 场景 |
|------|------|
| ERROR | 系统错误、需要告警 |
| WARN | 业务异常、可预期的错误 |
| INFO | 关键业务流程、方法入口 |
| DEBUG | 调试信息、详细数据 |

### 操作类方法日志

操作类方法（新增/修改/删除等写操作）**必须在方法开始和结束各打印一条日志**，便于追踪业务链路和排查问题：

```java
public void updateUser(UserDTO userDTO) {
    LOGGER.info("updateUser begin:[userId={}]", userDTO.getId());
    // ... 业务逻辑
    LOGGER.info("updateUser end:[userId={}]", userDTO.getId());
}

public void deleteUser(Long userId) {
    LOGGER.info("deleteUser begin:[{}]", userId);
    // ... 业务逻辑
    LOGGER.info("deleteUser end:[{}]", userId);
}
```

- 查询类方法（get/list/query）不需要强制打印开始/结束日志
- 日志格式：`方法名 begin/end:[关键参数]`
- 异常路径由 catch 块单独记录，不重复打印结束日志

### 日志格式

```java
// 使用占位符，禁止字符串拼接
LOGGER.info("getUser begin:[userId={},type={}]", userId, type);

// 方法入口记录关键参数
public User getUser(Long userId, Integer type) {
    LOGGER.info("getUser begin:[{},{}]", userId, type);
    // ...
}

// 异常日志
try {
    // ...
} catch (Exception e) {
    LOGGER.error("getUser error:[userId={}]", userId, e);
    throw new BizException("获取用户失败");
}
```

### 禁止事项

- ❌ 日志中打印密码、token、身份证号等敏感信息
- ❌ 使用字符串拼接：`logger.info("user=" + user)`
- ❌ 循环中打印大量日志
- ❌ 滥用 ERROR 级别（业务异常用 WARN）

### error first（错误优先原则）

方法内部首先处理错误和异常分支，确认无误后再执行主逻辑：

```java
// 正例：错误优先，主逻辑在最后
public void processOrder(Order order) {
    if (order == null) {
        throw new BizException("order 不能为空");
    }
    if (!order.isValid()) {
        LOGGER.warn("processOrder invalid order:[{}]", order.getId());
        return;
    }
    // 主逻辑在最后
    doProcess(order);
}
```

### 日志命名规范

- 变量名统一使用 `log` 或 `LOGGER`，全项目保持一致
- 格式：`private static final Logger LOGGER = LoggerFactory.getLogger(当前类.class);`

### try 块规范

- **try 语句不允许嵌套**
- 除 action 层外统一抛出项目定义的业务异常类
- action 层用 try-catch 捕获异常并记录日志，不向外暴露堆栈

### 示例

```java
public UserTO getUser(Long userId) {
    LOGGER.info("getUser begin:[{}]", userId);
    
    ValidateUtil.notNull(userId, "userId不能为空");
    
    User user = userDao.selectById(userId);
    if (user == null) {
        LOGGER.warn("getUser user not found:[{}]", userId);
        throw new BizException("用户不存在");
    }
    
    LOGGER.info("getUser end:[{}]", userId);
    return UserConverter.toTO(user);
}
```
