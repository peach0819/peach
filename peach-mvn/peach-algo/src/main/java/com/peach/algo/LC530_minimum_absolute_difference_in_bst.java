package com.peach.algo;

import com.peach.algo.base.TreeNode;

/**
 * @author feitao.zt
 * @date 2025/4/28
 * 给你一个二叉搜索树的根节点 root ，返回 树中任意两不同节点值之间的最小差值 。
 * 差值是一个正数，其数值等于两值之差的绝对值。
 * 示例 1：
 * 输入：root = [4,2,6,1,3]
 * 输出：1
 * 示例 2：
 * 输入：root = [1,0,48,null,null,12,49]
 * 输出：1
 * 提示：
 * 树中节点的数目范围是 [2, 104]
 * 0 <= Node.val <= 105
 */
public class LC530_minimum_absolute_difference_in_bst {

    int result = Integer.MAX_VALUE;

    public int getMinimumDifference(TreeNode root) {
        handle(root);
        return result;
    }

    private int[] handle(TreeNode node) {
        int min;
        if (node.left != null) {
            int[] handle = handle(node.left);
            min = handle[0];
            result = Math.min(result, node.val - handle[1]);
        } else {
            min = node.val;
        }

        int max;
        if (node.right != null) {
            int[] handle = handle(node.right);
            max = handle[1];
            result = Math.min(result, handle[0] - node.val);
        } else {
            max = node.val;
        }
        return new int[]{ min, max };
    }
}
