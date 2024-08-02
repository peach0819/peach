package com.peach.algo.LC101_150;

import com.peach.algo.base.TreeNode;

import java.util.ArrayList;
import java.util.List;

/**
 * @author feitao.zt
 * @date 2023/7/12
 * 二叉树先序遍历
 */
public class LC144_binary_tree_preorder_traversal {

    public List<Integer> preorderTraversal(TreeNode root) {
        List<Integer> result = new ArrayList<>();
        readNode(root, result);
        return result;
    }

    private void readNode(TreeNode root, List<Integer> result) {
        if (root == null) {
            return;
        }
        result.add(root.val);
        readNode(root.left, result);
        readNode(root.right, result);
    }
}
