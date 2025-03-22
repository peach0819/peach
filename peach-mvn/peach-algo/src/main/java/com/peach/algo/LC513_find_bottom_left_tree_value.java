package com.peach.algo;

import com.peach.algo.base.TreeNode;

/**
 * @author feitao.zt
 * @date 2025/2/27
 * 给定一个二叉树的 根节点 root，请找出该二叉树的 最底层 最左边 节点的值。
 * 假设二叉树中至少有一个节点。
 * 示例 1:
 * 输入: root = [2,1,3]
 * 输出: 1
 * 示例 2:
 * 输入: [1,2,3,4,null,5,6,null,null,7]
 * 输出: 7
 * 提示:
 * 二叉树的节点个数的范围是 [1,104]
 * -231 <= Node.val <= 231 - 1
 */
public class LC513_find_bottom_left_tree_value {

    int maxDepth = 0;
    int val;

    public int findBottomLeftValue(TreeNode root) {
        handle(root, 1);
        return val;
    }

    private void handle(TreeNode node, int depth) {
        if (node == null) {
            return;
        }
        if (depth > maxDepth) {
            maxDepth = depth;
            val = node.val;
        }
        handle(node.left, depth + 1);
        handle(node.right, depth + 1);
    }
}
