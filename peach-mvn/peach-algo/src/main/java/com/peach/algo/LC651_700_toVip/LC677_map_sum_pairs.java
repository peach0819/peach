package com.peach.algo.LC651_700_toVip;

/**
 * @author feitao.zt
 * @date 2025/11/6
 * 设计一个 map ，满足以下几点:
 * 字符串表示键，整数表示值
 * 返回具有前缀等于给定字符串的键的值的总和
 * 实现一个 MapSum 类：
 * MapSum() 初始化 MapSum 对象
 * void insert(String key, int val) 插入 key-val 键值对，字符串表示键 key ，整数表示值 val 。如果键 key 已经存在，那么原来的键值对 key-value 将被替代成新的键值对。
 * int sum(string prefix) 返回所有以该前缀 prefix 开头的键 key 的值的总和。
 * 示例 1：
 * 输入：
 * ["MapSum", "insert", "sum", "insert", "sum"]
 * [[], ["apple", 3], ["ap"], ["app", 2], ["ap"]]
 * 输出：
 * [null, null, 3, null, 5]
 * 解释：
 * MapSum mapSum = new MapSum();
 * mapSum.insert("apple", 3);
 * mapSum.sum("ap");           // 返回 3 (apple = 3)
 * mapSum.insert("app", 2);
 * mapSum.sum("ap");           // 返回 5 (apple + app = 3 + 2 = 5)
 * 提示：
 * 1 <= key.length, prefix.length <= 50
 * key 和 prefix 仅由小写英文字母组成
 * 1 <= val <= 1000
 * 最多调用 50 次 insert 和 sum
 */
public class LC677_map_sum_pairs {

    /**
     * Your MapSum object will be instantiated and called as such:
     * MapSum obj = new MapSum();
     * obj.insert(key,val);
     * int param_2 = obj.sum(prefix);
     */
    class MapSum {

        class Node {

            int val;
            Node[] children = new Node[26];
        }

        Node[] nodes = new Node[26];

        public MapSum() {

        }

        public void insert(String key, int val) {
            char[] array = key.toCharArray();
            handleInsert(nodes, array, 0, val);
        }

        private void handleInsert(Node[] nodes, char[] array, int index, int val) {
            if (nodes[array[index] - 'a'] == null) {
                nodes[array[index] - 'a'] = new Node();
            }
            Node node = nodes[array[index] - 'a'];
            if (index == array.length - 1) {
                node.val = val;
                return;
            }
            handleInsert(node.children, array, index + 1, val);
        }

        public int sum(String prefix) {
            char[] array = prefix.toCharArray();
            Node[] nodes = this.nodes;
            int result = 0;
            for (int i = 0; i < array.length; i++) {
                char c = array[i];
                if (nodes[c - 'a'] == null) {
                    return 0;
                }
                if (i == array.length - 1) {
                    result += nodes[c - 'a'].val;
                }
                nodes = nodes[c - 'a'].children;
            }
            return result + handle(nodes);
        }

        private int handle(Node[] nodes) {
            int result = 0;
            for (Node node : nodes) {
                if (node == null) {
                    continue;
                }
                result += node.val;
                result += handle(node.children);
            }
            return result;
        }
    }

}
