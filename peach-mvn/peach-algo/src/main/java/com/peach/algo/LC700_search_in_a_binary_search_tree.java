package com.peach.algo;

import com.peach.algo.base.TreeNode;

/**
 * @author feitao.zt
 * @date 2026/1/29
 * 给定二叉搜索树（BST）的根节点 root 和一个整数值 val。
 * 你需要在 BST 中找到节点值等于 val 的节点。 返回以该节点为根的子树。 如果节点不存在，则返回 null 。
 * 示例 1:
 * 输入：root = [4,2,7,1,3], val = 2
 * 输出：[2,1,3]
 * 示例 2:
 * 输入：root = [4,2,7,1,3], val = 5
 * 输出：[]
 * 提示：
 * 树中节点数在 [1, 5000] 范围内
 * 1 <= Node.val <= 107
 * root 是二叉搜索树
 * 1 <= val <= 107
 */
public class LC700_search_in_a_binary_search_tree {

    int val;

    public TreeNode searchBST(TreeNode root, int val) {
        this.val = val;
        return handle(root);
    }

    private TreeNode handle(TreeNode node) {
        if (node == null) {
            return null;
        }
        if (node.val == val) {
            return node;
        }
        if (node.val < val) {
            return handle(node.right);
        }
        return handle(node.left);
    }
}
