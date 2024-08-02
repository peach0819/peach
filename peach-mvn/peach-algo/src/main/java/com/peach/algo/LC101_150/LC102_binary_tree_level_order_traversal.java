package com.peach.algo.LC101_150;

import com.peach.algo.base.TreeNode;

import java.util.ArrayList;
import java.util.List;

/**
 * @author feitao.zt
 * @date 2024/7/24
 * 给你二叉树的根节点 root ，返回其节点值的 层序遍历 。 （即逐层地，从左到右访问所有节点）。
 * 示例 1：
 * 输入：root = [3,9,20,null,null,15,7]
 * 输出：[[3],[9,20],[15,7]]
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
public class LC102_binary_tree_level_order_traversal {

    List<List<Integer>> result = new ArrayList<>();

    public List<List<Integer>> levelOrder(TreeNode root) {
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
        result.add(cur);
        handle(next);
    }
}
