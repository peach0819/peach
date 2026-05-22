---
trigger: always_on
---
# 代码风格规范

## OOP 规范（阿里规范）

- 所有覆写方法必须加 `@Override`
- 外部正在调用的接口，禁止修改方法签名
- `equals` 用常量或确定有值的对象调用，推荐 `Objects.equals()`
- 浮点数比较用 `BigDecimal.compareTo()`，不用 `==`
- 构造方法禁止加业务逻辑
- 字符串拼接循环中使用 `StringBuilder`

### 包装类型与基本类型

| 场景 | 使用类型 |
|------|----------|
| POJO 属性 | 包装类型（如 Integer, Long） |
| RPC 方法返回值/参数 | 包装类型 |
| 局部变量 | 基本类型（如 int, long） |

## 集合规范（阿里规范）

- `ArrayList.subList()` 返回视图，不能转 ArrayList
- `Arrays.asList()` 返回不可变列表
- 集合转数组用 `toArray(T[] array)`
- foreach 中禁止 remove/add，用 Iterator
- Map 遍历用 `entrySet()`，不用 keySet 再 get
- 集合初始化指定容量

```java
// 指定初始容量
List<User> userList = new ArrayList<>(100);
Map<Long, User> userMap = new HashMap<>(16);
```

## 并发规范（阿里规范）

- 线程池禁止用 `Executors` 创建，使用 `ThreadPoolExecutor`
- `SimpleDateFormat` 线程不安全，禁止作为 static 变量
- `Calendar` 线程不安全，**禁止作为类的静态成员**
- `DateFormat` 线程不安全，**禁止作为类的静态成员**
- 多线程访问 HashMap 不安全，使用 `ConcurrentHashMap`
- 加锁顺序保持一致防死锁
- **禁止在持有锁的时候调用 `Thread.sleep()`**（会导致等待该锁的其它线程被长时间挂起）
- **禁止使用 `parallelStream()`**（并行流会导致线程上下文变量丢失，如 TraceId 丢失等问题）

## 项目工具类使用

### 字符串处理

```java
import org.apache.commons.lang3.StringUtils;

// 判空
StringUtils.isBlank(str);     // null/""/空白 → true
StringUtils.isNotBlank(str);
StringUtils.isEmpty(str);     // null/"" → true

// 默认值
StringUtils.defaultIfBlank(str, "default");
```

### 集合处理

```java
import org.apache.commons.collections.CollectionUtils;

// 判空
CollectionUtils.isEmpty(list);
CollectionUtils.isNotEmpty(list);
```

### 对象比较

```java
import java.util.Objects;

// 空安全比较
Objects.equals(a, b);
Objects.nonNull(obj);
Objects.isNull(obj);
```

### Stream API

```java
// 过滤、映射、收集
List<Long> userIdList = userList.stream()
    .filter(u -> u.getStatus() == 1)
    .map(User::getId)
    .collect(Collectors.toList());

// 分组
Map<Integer, List<User>> statusMap = userList.stream()
    .collect(Collectors.groupingBy(User::getStatus));
```

## Lombok 使用

| 层级 | 规范 |
|------|------|
| Form 对象（web 层） | 使用 `@Data` |
| API 层 Request/Response | **手写 getter/setter** |
| Entity（dal 层） | 使用 `@Data` |

> 说明：API 层 TO/VO 对象手写 getter/setter，是因为 Lombok 使用编译期钩子 hack 代码，对 boolean 类型字段（`isXxx`）会自动去掉 `is` 前缀生成方法，在多版本兼容场景存在不确定性风险。

## 禁用事项

- ❌ **禁止使用 `@Valid` 相关注解**：参数校验逻辑应集中在一处，不应分散在接口定义和实体模型上
- ❌ **禁止使用构造函数调用 Abstract 方法**：父类构造时子类可能尚未初始化完毕，容易引发异常
- ❌ **禁止对 `BigDecimal` 变量调用 `equals` 方法**：`2.0` 和 `2.00` 的 equals 结果为 false，应使用 `compareTo()`

```java
// 错误
new BigDecimal("2.0").equals(new BigDecimal("2.00")); // false！

// 正确
new BigDecimal("2.0").compareTo(new BigDecimal("2.00")) == 0; // true
```

## 不必要的局部变量

中间变量对可读性无增益时，应直接返回，不引入多余变量：

```java
// 反例
User user = findUserByNick(nick);
return user;

// 正例
return findUserByNick(nick);
```

## 集合规范补充

- 使用 `Lists.newArrayList()` 代替 `Collections.emptyList()`，避免 Hessian 序列化后的 `emptyList` 问题
- 对集合判空必须使用 `CollectionUtils.isEmpty()`，**不能用 `!= null` 判断**

## 枚举规范

必须提供 `static get(Integer code)` 方法：

```java
public enum StatusEnum {
    ACTIVE(1, "启用"),
    INACTIVE(0, "禁用");
    
    private final Integer code;
    private final String desc;
    
    // 构造方法、getter...
    
    public static StatusEnum get(Integer code) {
        if (code == null) {
            return null;
        }
        for (StatusEnum e : values()) {
            if (e.code.equals(code)) {
                return e;
            }
        }
        return null;
    }
}
```

## 注释规范

### 类注释

```java
/**
 * 用户服务
 *
 * @author zhangsan
 * @date 2024/01/01
 */
public class UserService {
}
```

### 方法注释

```java
/**
 * 根据ID获取用户
 *
 * @param userId 用户ID
 * @return 用户信息，不存在返回null
 */
public User getById(Long userId) {
}
```
