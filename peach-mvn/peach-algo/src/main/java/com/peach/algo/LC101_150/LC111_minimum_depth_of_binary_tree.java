package com.peach.algo.LC101_150;

import com.peach.algo.base.TreeNode;

import java.util.ArrayList;
import java.util.List;

/**
 * @author feitao.zt
 * @date 2024/7/25
 * 给定一个二叉树，找出其最小深度。
 * 最小深度是从根节点到最近叶子节点的最短路径上的节点数量。
 * 说明：叶子节点是指没有子节点的节点。
 * 示例 1：
 * 输入：root = [3,9,20,null,null,15,7]
 * 输出：2
 * 示例 2：
 * 输入：root = [2,null,3,null,4,null,5,null,6]
 * 输出：5
 * 提示：
 * 树中节点数的范围在 [0, 105] 内
 * -1000 <= Node.val <= 1000
 */
public class LC111_minimum_depth_of_binary_tree {

    public int minDepth(TreeNode root) {
        if (root == null) {
            return 0;
        }
        List<TreeNode> list = new ArrayList<>();
        List<TreeNode> last = new ArrayList<>();
        last.add(root);
        int index = 1;
        while (true) {
            for (TreeNode treeNode : last) {
                if (treeNode.left == null && treeNode.right == null) {
                    return index;
                }
                if (treeNode.left != null) {
                    list.add(treeNode.left);
                }
                if (treeNode.right != null) {
                    list.add(treeNode.right);
                }
            }
            index++;
            last = list;
            list = new ArrayList<>();
        }
    }
}
