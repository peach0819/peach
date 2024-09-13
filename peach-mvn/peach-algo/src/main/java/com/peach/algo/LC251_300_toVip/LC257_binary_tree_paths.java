package com.peach.algo.LC251_300_toVip;

import com.peach.algo.base.TreeNode;

import java.util.ArrayList;
import java.util.List;

/**
 * @author feitao.zt
 * @date 2024/9/10
 * 给你一个二叉树的根节点 root ，按 任意顺序 ，返回所有从根节点到叶子节点的路径。
 * 叶子节点 是指没有子节点的节点。
 * 示例 1：
 * 输入：root = [1,2,3,null,5]
 * 输出：["1->2->5","1->3"]
 * 示例 2：
 * 输入：root = [1]
 * 输出：["1"]
 * 提示：
 * 树中节点的数目在范围 [1, 100] 内
 * -100 <= Node.val <= 100
 */
public class LC257_binary_tree_paths {

    List<String> result = new ArrayList<>();

    public List<String> binaryTreePaths(TreeNode root) {
        if (root == null) {
            return result;
        }
        handle(root, new ArrayList<>());
        return result;
    }

    private void handle(TreeNode node, List<String> list) {
        list.add(node.val + "");
        if (node.left != null) {
            handle(node.left, list);
        }
        if (node.right != null) {
            handle(node.right, list);
        }
        if (node.left == null && node.right == null) {
            result.add(build(list));
        }
        list.remove(list.size() - 1);
    }

    private String build(List<String> list) {
        return String.join("->", list);
    }

}
