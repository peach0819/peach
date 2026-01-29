package com.peach.algo.LC651_700_toVip;

import com.peach.algo.base.TreeNode;

/**
 * @author feitao.zt
 * @date 2026/1/20
 * 给定一个二叉树的 root ，返回 最长的路径的长度 ，这个路径中的 每个节点具有相同值 。 这条路径可以经过也可以不经过根节点。
 * 两个节点之间的路径长度 由它们之间的边数表示。
 * 示例 1:
 * 输入：root = [5,4,5,1,1,5]
 * 输出：2
 * 示例 2:
 * 输入：root = [1,4,5,4,4,5]
 * 输出：2
 * 提示:
 * 树的节点数的范围是 [0, 104]
 * -1000 <= Node.val <= 1000
 * 树的深度将不超过 1000
 */
public class LC687_longest_univalue_path {

    int max = 1;

    public int longestUnivaluePath(TreeNode root) {
        handle(root);
        return max - 1;
    }

    private int handle(TreeNode node) {
        if (node == null) {
            return 0;
        }
        int val = node.val;
        int actLeftVal = 0;
        int actRightVal = 0;
        if (node.left != null) {
            int leftVal = handle(node.left);
            if (node.left.val == val) {
                actLeftVal = leftVal;
            }
        }
        if (node.right != null) {
            int rightVal = handle(node.right);
            if (node.right.val == val) {
                actRightVal = rightVal;
            }
        }
        max = Math.max(max, actLeftVal + actRightVal + 1);
        return Math.max(actLeftVal, actRightVal) + 1;
    }
}
