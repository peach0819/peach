package com.peach.algo;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * @author feitao.zt
 * @date 2023/7/12
 * 给定一个 N 叉树，返回其节点值的层序遍历。（即从左到右，逐层遍历）。
 * 树的序列化输入是用层序遍历，每组子节点都由 null 值分隔（参见示例）。
 *  
 * 示例 1：
 * 输入：root = [1,null,3,2,4,null,5,6]
 * 输出：[[1],[3,2,4],[5,6]]
 * 示例 2：
 * 输入：root = [1,null,2,3,4,5,null,null,6,7,null,8,null,9,10,null,null,11,null,12,null,13,null,null,14]
 * 输出：[[1],[2,3,4,5],[6,7,8,9,10],[11,12,13],[14]]
 *  
 * 来源：力扣（LeetCode）
 * 链接：https://leetcode.cn/problems/n-ary-tree-level-order-traversal
 * 著作权归领扣网络所有。商业转载请联系官方授权，非商业转载请注明出处。
 */
public class LC429_n_ary_tree_level_order_traversal {

    class Node {

        public int val;
        public List<Node> children;

        public Node() {}

        public Node(int _val) {
            val = _val;
        }

        public Node(int _val, List<Node> _children) {
            val = _val;
            children = _children;
        }
    }

    public List<List<Integer>> levelOrder(Node root) {
        Map<Integer, List<Integer>> deptMap = new LinkedHashMap<>();
        readNode(root, 1, deptMap);
        return new ArrayList<>(deptMap.values());
    }

    private void readNode(Node node, int depth, Map<Integer, List<Integer>> deptMap) {
        if (node == null) {
            return;
        }
        deptMap.putIfAbsent(depth, new ArrayList<>());
        deptMap.get(depth).add(node.val);
        if (node.children != null) {
            for (Node child : node.children) {
                readNode(child, depth + 1, deptMap);
            }
        }
    }
}
