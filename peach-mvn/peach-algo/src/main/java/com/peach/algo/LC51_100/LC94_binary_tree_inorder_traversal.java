package com.peach.algo.LC51_100;

import com.peach.algo.base.TreeNode;

import java.util.ArrayList;
import java.util.List;

/**
 * @author feitao.zt
 * @date 2023/7/12
 * 二叉树中序遍历
 */
public class LC94_binary_tree_inorder_traversal {

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
