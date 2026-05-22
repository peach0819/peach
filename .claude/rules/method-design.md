---
trigger: always_on
---
# 方法编写规范（阿里规范）

## 单一职责

- 一个方法只做一件事，职责单一
- 方法行数建议不超过 **80 行**（含注释），超出需考虑拆分
- 不要在方法内部混杂多层业务逻辑，拆成子方法分层调用

```java
// 正例：职责清晰
public void createUser(CreateUserForm form) {
    validateForm(form);
    User user = buildUser(form);
    saveUser(user);
    sendWelcomeNotification(user);
}

// 反例：一个方法做所有事
public void createUser(CreateUserForm form) {
    if (StringUtils.isBlank(form.getName())) {
        throw new BizException("姓名不能为空"); // 业务异常，使用项目定义的异常类
    }
    // ... 几十行校验
    User user = new User();
    user.setName(form.getName());
    // ... 几十行赋值
    userMapper.insert(user);
    // ... 发通知逻辑
}
```

## 参数规范

- 方法参数个数不超过 **5 个**，超出需封装成对象（BO/Form/Command）
- 禁止使用 `boolean` 参数控制方法内部流程，应拆成两个方法
- 参数校验在方法入口进行，使用 `Preconditions` 或业务异常，不要在方法深处才校验

```java
// 正例：参数封装
public UserTO queryUser(QueryUserParam param) { ... }

// 反例：参数过多
public UserTO queryUser(Long userId, String name, Integer status, 
                        Long deptId, String phone) { ... }

// 正例：拆方法
public void enableUser(Long userId) { ... }
public void disableUser(Long userId) { ... }

// 反例：boolean 控制逻辑分支
public void updateUserStatus(Long userId, boolean enable) { ... }
```

## 返回值规范

- 不允许返回 `null` 的集合，返回空集合 `Collections.emptyList()`
- 可为 null 的返回值必须在 Javadoc 中注明
- 方法内不允许有多个出口（`return`），复杂逻辑应尽早 `return` 减少嵌套

```java
// 正例：返回空集合而非 null
public List<UserTO> listByDept(Long deptId) {
    List<User> users = userMapper.selectByDeptId(deptId);
    if (CollectionUtils.isEmpty(users)) {
        return Collections.emptyList();
    }
    return convert(users);
}

// 正例：尽早 return，减少嵌套
public void processOrder(Order order) {
    if (order == null) {
        return;
    }
    if (!order.isValid()) {
        return;
    }
    doProcess(order);
}
```

## 异常处理

- 捕获异常必须处理，禁止空 `catch` 块
- 不用异常控制正常业务流程（如用 `try-catch` 代替 `if` 判断）
- 业务校验失败抛项目业务异常类，不允许抛 `RuntimeException`、`Exception`
- 事务方法中捕获异常后如需回滚，必须重新抛出或手动标记回滚

```java
// 正例：有意义的异常处理
try {
    userService.createUser(form);
} catch (BizException e) { // 项目业务异常类
    log.warn("创建用户失败, form={}, error={}", form, e.getMessage());
    throw e;
} catch (Exception e) {
    log.error("创建用户异常, form={}", form, e);
    throw new SystemException("创建用户失败", e); // 项目系统异常类
}

// 反例：空 catch，吞掉异常
try {
    userService.createUser(form);
} catch (Exception e) {
    // 什么都不做
}
```

## 方法命名

- 动词开头，见名知意（参见 `java-naming.md` 方法命名规范）
- 查询方法以 `get`/`query`/`list`/`find` 开头
- 修改方法以 `update`/`modify` 开头
- 删除方法以 `delete`/`remove` 开头
- 新增方法以 `add`/`create`/`insert` 开头
- 布尔返回值用 `is`/`has`/`can`/`should` 开头

## 方法可见性

- 仅内部使用的方法声明为 `private`
- 同包或子类使用时才声明为 `protected`
- 不强制 `public`，最小权限原则
- 工具类方法声明为 `public static`

## 幂等性

- 写操作（新增/修改/删除）在可能重复调用的场景下需保证幂等
- 通过唯一索引、状态机检查或去重 Token 实现
- 方法注释中注明是否支持幂等

```java
/**
 * 绑定用户微信，支持重复调用（幂等）
 *
 * @param userId  用户ID
 * @param openId  微信 openId
 */
public void bindWechat(Long userId, String openId) {
    // 已绑定则直接返回，不报错
    if (isAlreadyBound(userId, openId)) {
        return;
    }
    doBindWechat(userId, openId);
}
```

## 事务使用

- `@Transactional` 只标注在 **Service 实现类**的方法上，不标注在接口上
- 只读操作使用 `@Transactional(readOnly = true)`
- 明确指定 `rollbackFor = Exception.class`，否则非 RuntimeException 不会回滚
- 避免事务方法过长，减少事务持有时间

```java
// 正例
@Transactional(rollbackFor = Exception.class)
public void transfer(Long fromId, Long toId, BigDecimal amount) {
    accountService.deduct(fromId, amount);
    accountService.increase(toId, amount);
}
```

## 防御性编程

- 公共方法入口对外部参数做非空校验
- 调用外部接口/RPC 时对返回值做非空判断
- 禁止直接 `.get(0)` 而不判断集合是否为空

```java
// 正例：防御性取第一个元素
if (CollectionUtils.isNotEmpty(list)) {
    User first = list.get(0);
}

// 反例：直接取，可能 IndexOutOfBoundsException
User first = list.get(0);
```

## 方法度量硬限制

| 度量项 | 限制 |
|--------|------|
| 方法参数数量 | ≤ 5 个，超出需封装对象 |
| 方法行数 | ≤ 150 行，超出需重构 |
| 布尔表达式运算符（`&&`/`\|\|`） | 每个表达式 ≤ 3 个 |
| `if` 嵌套层数 | ≤ 3 层 |
| 文件行数 | ≤ 2000 行 |

## 方法入参不可修改

除 build 方法（明确就是对入参进行操作的方法）外，**严禁在方法内部对入参的值进行修改**。如需对数据进行操作，应先做保护性拷贝：

```java
// 反例：直接修改入参
public void process(UserDTO userDTO) {
    userDTO.setName("default"); // 危险！调用方的对象被污染
}

// 正例：拷贝后操作
public void process(UserDTO userDTO) {
    UserDTO copy = new UserDTO();
    BeanUtils.copyProperties(userDTO, copy);
    copy.setName("default");
}
```

## for 循环规范

- **禁止在 for 循环内调用外部 API 或进行数据库操作**，批量操作需调用批量接口
- 循环内数据库操作会产生 N+1 问题，严格禁止

```java
// 反例：循环内查库
for (Long userId : userIdList) {
    User user = userDao.selectById(userId); // 每次循环都查一次库！
}

// 正例：批量查询后在内存中处理
List<User> userList = userDao.selectByIdList(userIdList);
Map<Long, User> userMap = userList.stream()
    .collect(Collectors.toMap(User::getId, u -> u));
```

## 返回类型补充

- 包装类型（`Integer`、`Long` 等）一般不允许返回 `null`；如特殊情况必须返回 `null`，需在注释中说明
- 集合或数组返回 0 尺寸的对象，不允许返回 `null`

## ThreadLocal 使用规范

- 理解 ThreadLocal 的原理，明确其用途：通常用于拦截器或 filter 传递线程上下文（如 session）
- 功能代码里尽量不使用 ThreadLocal
- 如确实需要使用，**必须在线程结束前调用 `remove()`**，否则线程池复用时会导致数据串联到其他用户
