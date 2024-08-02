package com.peach.algo.LC101_150;

import com.peach.algo.base.TreeNode;

import java.util.ArrayList;
import java.util.List;

/**
 * @author feitao.zt
 * @date 2024/7/24
 * 给你二叉树的根节点 root ，返回其节点值 自底向上的层序遍历 。 （即按从叶子节点所在层到根节点所在的层，逐层从左向右遍历）
 * 示例 1：
 * 输入：root = [3,9,20,null,null,15,7]
 * 输出：[[15,7],[9,20],[3]]
 * 示例 2：
 * 输入：root = [1]
 * 输出：[[1]]
 * 示例 3：
 * 输入：root = []
 * 输出：[]
 * 提示：
 * 树中节点数目在范围 [0, 2000] 内
 * -1000 <= Node.val <= 1000
 */
public class LC107_binary_tree_level_order_traversal_ii {

    List<List<Integer>> result = new ArrayList<>();

    public List<List<Integer>> levelOrderBottom(TreeNode root) {
        if (root == null) {
            return new ArrayList<>();
        }
        List<TreeNode> list = new ArrayList<>();
        list.add(root);
        handle(list);
        return result;
    }

    private void handle(List<TreeNode> list) {
        if (list.isEmpty()) {
            return;
        }
        List<Integer> cur = new ArrayList<>();
        List<TreeNode> next = new ArrayList<>();
        for (TreeNode treeNode : list) {
            cur.add(treeNode.val);
            if (treeNode.left != null) {
                next.add(treeNode.left);
            }
            if (treeNode.right != null) {
                next.add(treeNode.right);
            }
        }
        result.add(0, cur);
        handle(next);
    }
}
