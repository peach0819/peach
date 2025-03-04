package com.peach.algo;

import com.peach.algo.base.TreeNode;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @author feitao.zt
 * @date 2025/3/4
 * 给定一棵二叉树的根节点 root ，请找出该二叉树中每一层的最大值。
 * 示例1：
 * 输入: root = [1,3,2,5,3,null,9]
 * 输出: [1,3,9]
 * 示例2：
 * 输入: root = [1,2,3]
 * 输出: [1,3]
 * 提示：
 * 二叉树的节点个数的范围是 [0,104]
 * -231 <= Node.val <= 231 - 1
 */
public class LC515_find_largest_value_in_each_tree_row {

    Map<Integer, Integer> map = new HashMap<>();
    int maxDepth = 0;

    public List<Integer> largestValues(TreeNode root) {
        if (root == null) {
            return new ArrayList<>();
        }
        handle(root, 0);
        List<Integer> result = new ArrayList<>();
        for (int i = 0; i <= maxDepth; i++) {
            result.add(map.get(i));
        }
        return result;
    }

    private void handle(TreeNode node, int depth) {
        if (node == null) {
            return;
        }
        if (depth > maxDepth) {
            maxDepth = depth;
        }
        if (map.containsKey(depth)) {
            map.put(depth, Math.max(map.get(depth), node.val));
        } else {
            map.put(depth, node.val);
        }
        handle(node.left, depth + 1);
        handle(node.right, depth + 1);
    }

}
