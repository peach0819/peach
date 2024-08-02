package com.peach.algo;

import java.util.HashMap;
import java.util.Map;

/**
 * @author feitao.zt
 * @date 2024/8/2
 * 请你设计并实现一个满足  LRU (最近最少使用) 缓存 约束的数据结构。
 * 实现 LRUCache 类：
 * LRUCache(int capacity) 以 正整数 作为容量 capacity 初始化 LRU 缓存
 * int get(int key) 如果关键字 key 存在于缓存中，则返回关键字的值，否则返回 -1 。
 * void put(int key, int value) 如果关键字 key 已经存在，则变更其数据值 value ；如果不存在，则向缓存中插入该组 key-value 。如果插入操作导致关键字数量超过 capacity ，则应该 逐出 最久未使用的关键字。
 * 函数 get 和 put 必须以 O(1) 的平均时间复杂度运行。
 * 示例：
 * 输入
 * ["LRUCache", "put", "put", "get", "put", "get", "put", "get", "get", "get"]
 * [[2], [1, 1], [2, 2], [1], [3, 3], [2], [4, 4], [1], [3], [4]]
 * 输出
 * [null, null, null, 1, null, -1, null, -1, 3, 4]
 * 解释
 * LRUCache lRUCache = new LRUCache(2);
 * lRUCache.put(1, 1); // 缓存是 {1=1}
 * lRUCache.put(2, 2); // 缓存是 {1=1, 2=2}
 * lRUCache.get(1);    // 返回 1
 * lRUCache.put(3, 3); // 该操作会使得关键字 2 作废，缓存是 {1=1, 3=3}
 * lRUCache.get(2);    // 返回 -1 (未找到)
 * lRUCache.put(4, 4); // 该操作会使得关键字 1 作废，缓存是 {4=4, 3=3}
 * lRUCache.get(1);    // 返回 -1 (未找到)
 * lRUCache.get(3);    // 返回 3
 * lRUCache.get(4);    // 返回 4
 * 提示：
 * 1 <= capacity <= 3000
 * 0 <= key <= 10000
 * 0 <= value <= 105
 * 最多调用 2 * 105 次 get 和 put
 */
public class LC146_lru_cache {

    public static void main(String[] args) {
        //["LRUCache","put","get","put","get","get"]
        //[[1],[2,1],[2],[3,2],[2],[3]]

        LRUCache lruCache = new LC146_lru_cache().new LRUCache(1);
        lruCache.put(2, 1);
        int i = lruCache.get(2);
        lruCache.put(3, 2);
        i = lruCache.get(2);
        i = lruCache.get(3);
        int j = 1;
    }

    class LRUCache {

        Map<Integer, Node> map;
        Node head;
        Node tail;
        int capacity;

        class Node {

            int key;
            int value;
            Node left;
            Node right;
        }

        public LRUCache(int capacity) {
            map = new HashMap<>();
            head = null;
            tail = null;
            this.capacity = capacity;
        }

        public int get(int key) {
            if (!map.containsKey(key)) {
                return -1;
            }
            Node node = map.get(key);
            moveHead(node);
            return node.value;
        }

        public void put(int key, int value) {
            Node node;
            if (map.containsKey(key)) {
                node = map.get(key);
                node.value = value;
                moveHead(node);
            } else {
                if (map.size() == capacity) {
                    map.remove(tail.key);
                    tail = tail.left;
                    if (tail != null) {
                        tail.right = null;
                    }
                }
                node = new Node();
                node.key = key;
                node.value = value;
                if (capacity > 1) {
                    node.right = head;
                    if (head != null) {
                        head.left = node;
                    }
                }
                head = node;
                if (tail == null) {
                    tail = node;
                }
            }
            map.put(key, node);
        }

        private void moveHead(Node node) {
            if (head == node) {
                return;
            }
            if (node.left != null) {
                node.left.right = node.right;
            }
            if (node.right != null) {
                node.right.left = node.left;
            }
            if (tail == node) {
                tail = node.left;
            }
            node.left = null;
            node.right = head;
            head.left = node;
            head = node;
        }
    }
}
