package com.peach.algo.LC101_150;

import com.peach.algo.base.TreeNode;

/**
 * @author feitao.zt
 * @date 2024/7/24
 * 给你一个二叉树的根节点 root ， 检查它是否轴对称。
 * 示例 1：
 * 输入：root = [1,2,2,3,4,4,3]
 * 输出：true
 * 示例 2：
 * 输入：root = [1,2,2,null,3,null,3]
 * 输出：false
 * 提示：
 * 树中节点数目在范围 [1, 1000] 内
 * -100 <= Node.val <= 100
 * 进阶：你可以运用递归和迭代两种方法解决这个问题吗？
 */
public class LC101_symmetric_tree {

    public boolean isSymmetric(TreeNode root) {
        return handle(root.left, root.right);
    }

    private boolean handle(TreeNode left, TreeNode right) {
        if (left == null && right == null) {
            return true;
        }
        if (left == null || right == null) {
            return false;
        }
        if (left.val != right.val) {
            return false;
        }
        return handle(left.left, right.right) && handle(left.right, right.left);
    }
}
