package com.peach.algo.LC401_450_toVip;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

/**
 * @author feitao.zt
 * @date 2024/12/5
 * 请你设计一个用于存储字符串计数的数据结构，并能够返回计数最小和最大的字符串。
 * 实现 AllOne 类：
 * AllOne() 初始化数据结构的对象。
 * inc(String key) 字符串 key 的计数增加 1 。如果数据结构中尚不存在 key ，那么插入计数为 1 的 key 。
 * dec(String key) 字符串 key 的计数减少 1 。如果 key 的计数在减少后为 0 ，那么需要将这个 key 从数据结构中删除。测试用例保证：在减少计数前，key 存在于数据结构中。
 * getMaxKey() 返回任意一个计数最大的字符串。如果没有元素存在，返回一个空字符串 "" 。
 * getMinKey() 返回任意一个计数最小的字符串。如果没有元素存在，返回一个空字符串 "" 。
 * 注意：每个函数都应当满足 O(1) 平均时间复杂度。
 * 示例：
 * 输入
 * ["AllOne", "inc", "inc", "getMaxKey", "getMinKey", "inc", "getMaxKey", "getMinKey"]
 * [[], ["hello"], ["hello"], [], [], ["leet"], [], []]
 * 输出
 * [null, null, null, "hello", "hello", null, "hello", "leet"]
 * 解释
 * AllOne allOne = new AllOne();
 * allOne.inc("hello");
 * allOne.inc("hello");
 * allOne.getMaxKey(); // 返回 "hello"
 * allOne.getMinKey(); // 返回 "hello"
 * allOne.inc("leet");
 * allOne.getMaxKey(); // 返回 "hello"
 * allOne.getMinKey(); // 返回 "leet"
 * 提示：
 * 1 <= key.length <= 10
 * key 由小写英文字母组成
 * 测试用例保证：在每次调用 dec 时，数据结构中总存在 key
 * 最多调用 inc、dec、getMaxKey 和 getMinKey 方法 5 * 104 次
 */
public class LC432_all_oone_data_structure {

    public static void main(String[] args) {
        AllOne allOne = new LC432_all_oone_data_structure().new AllOne();
        allOne.inc("a");
        allOne.inc("b");
        allOne.inc("c");
        allOne.inc("d");
        allOne.inc("e");
        allOne.inc("f");
        allOne.inc("g");
        allOne.inc("h");
        allOne.inc("i");
        allOne.inc("j");
        allOne.inc("k");
        allOne.inc("l");

        allOne.dec("a");
        allOne.dec("b");
        allOne.dec("c");
        allOne.dec("d");
        allOne.dec("e");
        allOne.dec("f");

        allOne.inc("g");
        allOne.inc("h");
        allOne.inc("i");
        allOne.inc("j");

        String maxKey = allOne.getMaxKey();
        String minKey = allOne.getMinKey();

        allOne.inc("k");
        allOne.inc("l");

        maxKey = allOne.getMaxKey();
        minKey = allOne.getMinKey();

        allOne.inc("a");
        allOne.dec("j");

        maxKey = allOne.getMaxKey();
        minKey = allOne.getMinKey();
    }

    /**
     * Your AllOne object will be instantiated and called as such:
     * AllOne obj = new AllOne();
     * obj.inc(key);
     * obj.dec(key);
     * String param_3 = obj.getMaxKey();
     * String param_4 = obj.getMinKey();
     */
    /**
     * 我是傻逼， 双向链表 + hashmap
     */
    class AllOne {

        class Node {

            int val;
            Set<String> set;
            Node pre;
            Node next;
        }

        Node head = null;
        Node tail = null;

        Map<String, Node> map = new HashMap<>();
        Map<Integer, Node> valMap = new HashMap<>();

        public AllOne() {

        }

        public void inc(String key) {
            if (map.containsKey(key)) {
                Node oldNode = map.get(key);

                Node newNode;
                if (oldNode.next != null && oldNode.next.val == oldNode.val + 1) {
                    newNode = oldNode.next;
                } else {
                    newNode = new Node();
                    newNode.val = oldNode.val + 1;
                    newNode.set = new HashSet<>();
                    newNode.pre = oldNode;
                    newNode.next = oldNode.next;
                    valMap.put(newNode.val, newNode);
                    if (tail == oldNode) {
                        tail = newNode;
                    } else {
                        oldNode.next.pre = newNode;
                    }
                    oldNode.next = newNode;
                }

                oldNode.set.remove(key);
                newNode.set.add(key);
                if (oldNode.set.isEmpty()) {
                    if (head == oldNode) {
                        head = newNode;
                        newNode.pre = null;
                    } else {
                        newNode.pre = oldNode.pre;
                        oldNode.pre.next = newNode;
                    }
                    valMap.remove(oldNode.val);
                }
                map.put(key, newNode);
            } else {
                Node newNode;
                if (valMap.containsKey(1)) {
                    newNode = valMap.get(1);
                } else {
                    newNode = new Node();
                    newNode.val = 1;
                    newNode.set = new HashSet<>();
                    newNode.pre = null;
                    valMap.put(newNode.val, newNode);
                    if (head != null) {
                        newNode.next = head;
                        head.pre = newNode;
                    }
                    head = newNode;
                    if (tail == null) {
                        tail = newNode;
                    }
                }

                newNode.set.add(key);
                map.put(key, newNode);
            }
        }

        public void dec(String key) {
            Node oldNode = map.get(key);
            if (oldNode.val == 1) {
                oldNode.set.remove(key);
                map.remove(key);
                if (oldNode.set.isEmpty()) {
                    if (tail == oldNode) {
                        tail = null;
                        head = null;
                    } else {
                        head = oldNode.next;
                        oldNode.next.pre = null;
                    }
                    valMap.remove(oldNode.val);
                }
                return;
            }

            Node newNode;
            if (oldNode.pre != null && oldNode.pre.val == oldNode.val - 1) {
                newNode = oldNode.pre;
            } else {
                newNode = new Node();
                newNode.val = oldNode.val - 1;
                newNode.set = new HashSet<>();
                newNode.next = oldNode;
                newNode.pre = oldNode.pre;
                if (head == oldNode) {
                    head = newNode;
                } else {
                    oldNode.pre.next = newNode;
                }
                oldNode.pre = newNode;
            }

            oldNode.set.remove(key);
            newNode.set.add(key);
            if (oldNode.set.isEmpty()) {
                if (tail == oldNode) {
                    tail = newNode;
                    newNode.next = null;
                } else {
                    newNode.next = oldNode.next;
                    oldNode.next.pre = newNode;
                }
                valMap.remove(oldNode.val);
            }
            map.put(key, newNode);
        }

        public String getMaxKey() {
            if (tail == null) {
                return "";
            }
            return tail.set.iterator().next();
        }

        public String getMinKey() {
            if (head == null) {
                return "";
            }
            return head.set.iterator().next();
        }
    }
}
