package com.peach.algo;

import com.peach.algo.base.TreeNode;

/**
 * @author feitao.zt
 * @date 2024/10/23
 * 给定二叉树的根节点 root ，返回所有左叶子之和。
 * 示例 1：
 * 输入: root = [3,9,20,null,null,15,7]
 * 输出: 24
 * 解释: 在这个二叉树中，有两个左叶子，分别是 9 和 15，所以返回 24
 * 示例 2:
 * 输入: root = [1]
 * 输出: 0
 * 提示:
 * 节点数在 [1, 1000] 范围内
 * -1000 <= Node.val <= 1000
 */
public class LC404_sum_of_left_leaves {

    int result = 0;

    public int sumOfLeftLeaves(TreeNode root) {
        handle(root, false);
        return result;
    }

    private void handle(TreeNode root, boolean isLeft) {
        if (root == null) {
            return;
        }
        if (root.left == null && root.right == null && isLeft) {
            result += root.val;
        }
        handle(root.left, true);
        handle(root.right, false);
    }
}