package com.peach.algo.LC451_500_toVip;

import java.util.HashMap;
import java.util.Map;

/**
 * @author feitao.zt
 * @date 2024/12/17
 * 请你为 最不经常使用（LFU）缓存算法设计并实现数据结构。
 * 实现 LFUCache 类：
 * LFUCache(int capacity) - 用数据结构的容量 capacity 初始化对象
 * int get(int key) - 如果键 key 存在于缓存中，则获取键的值，否则返回 -1 。
 * void put(int key, int value) - 如果键 key 已存在，则变更其值；如果键不存在，请插入键值对。当缓存达到其容量 capacity 时，则应该在插入新项之前，移除最不经常使用的项。在此问题中，当存在平局（即两个或更多个键具有相同使用频率）时，应该去除 最久未使用 的键。
 * 为了确定最不常使用的键，可以为缓存中的每个键维护一个 使用计数器 。使用计数最小的键是最久未使用的键。
 * 当一个键首次插入到缓存中时，它的使用计数器被设置为 1 (由于 put 操作)。对缓存中的键执行 get 或 put 操作，使用计数器的值将会递增。
 * 函数 get 和 put 必须以 O(1) 的平均时间复杂度运行。
 * 示例：
 * 输入：
 * ["LFUCache", "put", "put", "get", "put", "get", "get", "put", "get", "get", "get"]
 * [[2], [1, 1], [2, 2], [1], [3, 3], [2], [3], [4, 4], [1], [3], [4]]
 * 输出：
 * [null, null, null, 1, null, -1, 3, null, -1, 3, 4]
 * 解释：
 * // cnt(x) = 键 x 的使用计数
 * // cache=[] 将显示最后一次使用的顺序（最左边的元素是最近的）
 * LFUCache lfu = new LFUCache(2);
 * lfu.put(1, 1);   // cache=[1,_], cnt(1)=1
 * lfu.put(2, 2);   // cache=[2,1], cnt(2)=1, cnt(1)=1
 * lfu.get(1);      // 返回 1
 * // cache=[1,2], cnt(2)=1, cnt(1)=2
 * lfu.put(3, 3);   // 去除键 2 ，因为 cnt(2)=1 ，使用计数最小
 * // cache=[3,1], cnt(3)=1, cnt(1)=2
 * lfu.get(2);      // 返回 -1（未找到）
 * lfu.get(3);      // 返回 3
 * // cache=[3,1], cnt(3)=2, cnt(1)=2
 * lfu.put(4, 4);   // 去除键 1 ，1 和 3 的 cnt 相同，但 1 最久未使用
 * // cache=[4,3], cnt(4)=1, cnt(3)=2
 * lfu.get(1);      // 返回 -1（未找到）
 * lfu.get(3);      // 返回 3
 * // cache=[3,4], cnt(4)=1, cnt(3)=3
 * lfu.get(4);      // 返回 4
 * // cache=[3,4], cnt(4)=2, cnt(3)=3
 * 提示：
 * 1 <= capacity <= 104
 * 0 <= key <= 105
 * 0 <= value <= 109
 * 最多调用 2 * 105 次 get 和 put 方法
 */
public class LC460_lfu_cache {

    public static void main(String[] args) {
        LFUCache cache = new LC460_lfu_cache().new LFUCache(2);
        cache.put(2, 1);
        cache.put(2, 2);
        int i = cache.get(2);
        cache.put(1, 1);
        cache.put(4, 1);
        i = cache.get(2);
        i = 1;
    }

    /**
     * Your LFUCache object will be instantiated and called as such:
     * LFUCache obj = new LFUCache(capacity);
     * int param_1 = obj.get(key);
     * obj.put(key,value);
     */
    class LFUCache {

        class Node {

            int key;
            int value;

            int times;

            Node pre;
            Node next;
        }

        int capacity;
        int cnt = 0;

        Node head = null;

        Map<Integer, Node> cacheMap = new HashMap<>();

        public LFUCache(int capacity) {
            this.capacity = capacity;
        }

        public int get(int key) {
            if (!cacheMap.containsKey(key)) {
                return -1;
            }
            Node node = cacheMap.get(key);
            node.times++;
            moveNode(node);
            return node.value;
        }

        public void put(int key, int value) {
            if (cnt == capacity && !cacheMap.containsKey(key)) {
                cacheMap.remove(head.key);
                if (head.next != null) {
                    head.next.pre = null;
                    head = head.next;
                } else {
                    head = null;
                }
                cnt--;
            }
            if (cacheMap.containsKey(key)) {
                Node oldNode = cacheMap.get(key);
                oldNode.value = value;
                oldNode.times++;
                moveNode(oldNode);
            } else {
                Node newNode = new Node();
                newNode.value = value;
                newNode.key = key;
                newNode.times = 1;
                cacheMap.put(key, newNode);
                addNode(newNode);
                cnt++;
            }
        }

        private void moveNode(Node node) {
            if (node.next == null) {
                return;
            }
            Node beforePre = node.pre;
            Node beforeNext = node.next;

            Node cur = node.next;
            while (true) {
                if (cur.next == null || cur.next.times > node.times) {
                    node.next = cur.next;
                    if (cur.next != null) {
                        cur.next.pre = node;
                    }
                    cur.next = node;
                    node.pre = cur;
                    break;
                }
                cur = cur.next;
            }
            if (head == node) {
                head = beforeNext;
                beforeNext.pre = null;
            } else {
                beforePre.next = beforeNext;
                beforeNext.pre = beforePre;
            }
        }

        private void addNode(Node node) {
            if (head == null) {
                head = node;
                return;
            }
            if (node.times < head.times) {
                node.next = head;
                head.pre = node;
                head = node;
                return;
            }
            Node cur = head;
            while (true) {
                if (cur.next == null || cur.next.times > node.times) {
                    node.next = cur.next;
                    if (cur.next != null) {
                        cur.next.pre = node;
                    }
                    cur.next = node;
                    node.pre = cur;
                    break;
                }
                cur = cur.next;
            }
        }
    }

}