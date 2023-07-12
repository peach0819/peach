package com.peach.algo;

import java.util.ArrayList;
import java.util.List;

/**
 * @author feitao.zt
 * @date 2023/7/12
 * 二叉树中序遍历
 */
public class LC94_binary_tree_inorder_traversal {

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

    public List<Integer> inorderTraversal(TreeNode root) {
        List<Integer> result = new ArrayList<>();
        readNode(root, result);
        return result;
    }

    private void readNode(TreeNode root, List<Integer> result) {
        if (root == null) {
            return;
        }
        readNode(root.left, result);
        result.add(root.val);
        readNode(root.right, result);
    }
}
