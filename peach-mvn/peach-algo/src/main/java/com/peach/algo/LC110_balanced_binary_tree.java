package com.peach.algo;

import com.peach.algo.base.TreeNode;

/**
 * @author feitao.zt
 * @date 2024/7/25
 * 给定一个二叉树，判断它是否是
 * 平衡二叉树
 * 示例 1：
 * 输入：root = [3,9,20,null,null,15,7]
 * 输出：true
 * 示例 2：
 * 输入：root = [1,2,2,3,3,null,null,4,4]
 * 输出：false
 * 示例 3：
 * 输入：root = []
 * 输出：true
 */
public class LC110_balanced_binary_tree {

    boolean isBalanced = true;

    public boolean isBalanced(TreeNode root) {
        int[] handle = handle(root);
        return handle[0] == 1;
    }

    /**
     * int[0] = 是否平衡二叉树 1是 0否
     * int[1] = 二叉树深度数
     */
    private int[] handle(TreeNode root) {
        if (!isBalanced) {
            return new int[]{ 0, 0 };
        }
        if (root == null) {
            return new int[]{ 1, 0 };
        }
        int[] left = handle(root.left);
        if (!isBalanced || left[0] == 0) {
            isBalanced = false;
            return new int[]{ 0, 0 };
        }
        int[] right = handle(root.right);
        if (!isBalanced || right[0] == 0) {
            isBalanced = false;
            return new int[]{ 0, 0 };
        }
        if (Math.abs(left[1] - right[1]) > 1) {
            isBalanced = false;
            return new int[]{ 0, 0 };
        }
        return new int[]{ 1, Math.max(left[1], right[1]) + 1 };
    }
}
