package com.peach.algo.LC201_250_toVip;

import com.peach.algo.base.TreeNode;

/**
 * @author feitao.zt
 * @date 2024/9/5
 * 给你一棵二叉树的根节点 root ，翻转这棵二叉树，并返回其根节点。
 * 示例 1：
 * 输入：root = [4,2,7,1,3,6,9]
 * 输出：[4,7,2,9,6,3,1]
 * 示例 2：
 * 输入：root = [2,1,3]
 * 输出：[2,3,1]
 * 示例 3：
 * 输入：root = []
 * 输出：[]
 * 提示：
 * 树中节点数目范围在 [0, 100] 内
 * -100 <= Node.val <= 100
 */
public class LC226_invert_binary_tree {

    public TreeNode invertTree(TreeNode root) {
        handle(root);
        return root;
    }

    private void handle(TreeNode node) {
        if (node == null) {
            return;
        }
        TreeNode temp = node.right;
        node.right = node.left;
        node.left = temp;

        handle(node.left);
        handle(node.right);
    }
}
