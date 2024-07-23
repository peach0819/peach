package com.peach.algo;

/**
 * @author feitao.zt
 * @date 2024/7/23
 * 给你一个二叉树的根节点 root ，判断其是否是一个有效的二叉搜索树。
 * 有效 二叉搜索树定义如下：
 * 节点的左
 * 子树
 * 只包含 小于 当前节点的数。
 * 节点的右子树只包含 大于 当前节点的数。
 * 所有左子树和右子树自身必须也是二叉搜索树。
 * 示例 1：
 * 输入：root = [2,1,3]
 * 输出：true
 * 示例 2：
 * 输入：root = [5,1,4,null,null,3,6]
 * 输出：false
 * 解释：根节点的值是 5 ，但是右子节点的值是 4 。
 * 提示：
 * 树中节点数目范围在[1, 104] 内
 * -231 <= Node.val <= 231 - 1
 */
public class LC98_validate_binary_search_tree {

    public class TreeNode {

        int val;
        TreeNode left;
        TreeNode right;

        TreeNode() {}

        TreeNode(int val) { this.val = val; }

        TreeNode(int val, TreeNode left, TreeNode right) {
            this.val = val;
            this.left = left;
            this.right = right;
        }
    }

    boolean result = true;

    public boolean isValidBST(TreeNode root) {
        handle(root);
        return result;
    }

    public int[] handle(TreeNode node) {
        if (!result) {
            return null;
        }
        int[] cur = new int[2];
        if (node.left != null) {
            if (node.left.val >= node.val) {
                result = false;
                return null;
            }
            int[] handle = handle(node.left);
            if (!result) {
                return null;
            }
            if (handle[1] >= node.val) {
                result = false;
                return null;
            }
            cur[0] = handle[0];
        } else {
            cur[0] = node.val;
        }

        if (node.right != null) {
            if (node.right.val <= node.val) {
                result = false;
                return null;
            }
            int[] handle = handle(node.right);
            if (!result) {
                return null;
            }
            if (handle[0] <= node.val) {
                result = false;
                return null;
            }
            cur[1] = handle[1];
        } else {
            cur[1] = node.val;
        }
        return cur;
    }
}
