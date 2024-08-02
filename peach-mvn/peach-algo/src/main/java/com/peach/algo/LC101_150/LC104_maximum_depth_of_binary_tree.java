package com.peach.algo.LC101_150;

import com.peach.algo.base.TreeNode;

/**
 * @author feitao.zt
 * @date 2024/7/24
 * 给定一个二叉树 root ，返回其最大深度。
 * 二叉树的 最大深度 是指从根节点到最远叶子节点的最长路径上的节点数。
 * 示例 1：
 * 输入：root = [3,9,20,null,null,15,7]
 * 输出：3
 * 示例 2：
 * 输入：root = [1,null,2]
 * 输出：2
 * 提示：
 * 树中节点的数量在 [0, 104] 区间内。
 * -100 <= Node.val <= 100
 */
public class LC104_maximum_depth_of_binary_tree {

    int max = 0;

    public int maxDepth(TreeNode root) {
        if (root == null) {
            return 0;
        }
        handle(root, 1);
        return max;
    }

    private void handle(TreeNode root, int depth) {
        max = Math.max(max, depth);
        if (root.left != null) {
            handle(root.left, depth + 1);
        }
        if (root.right != null) {
            handle(root.right, depth + 1);
        }
    }

}
