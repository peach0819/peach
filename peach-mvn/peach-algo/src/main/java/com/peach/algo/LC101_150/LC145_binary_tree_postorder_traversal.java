package com.peach.algo.LC101_150;

import com.peach.algo.base.TreeNode;

import java.util.ArrayList;
import java.util.List;

/**
 * @author feitao.zt
 * @date 2024/8/2
 * 给你一棵二叉树的根节点 root ，返回其节点值的 后序遍历 。
 * 示例 1：
 * 输入：root = [1,null,2,3]
 * 输出：[3,2,1]
 * 示例 2：
 * 输入：root = []
 * 输出：[]
 * 示例 3：
 * 输入：root = [1]
 * 输出：[1]
 * 提示：
 * 树中节点的数目在范围 [0, 100] 内
 * -100 <= Node.val <= 100
 * 进阶：递归算法很简单，你可以通过迭代算法完成吗？
 */
public class LC145_binary_tree_postorder_traversal {

    public List<Integer> postorderTraversal(TreeNode root) {
        List<Integer> resultList = new ArrayList<>();
        parseTree(root, resultList);
        return resultList;
    }

    public void parseTree(TreeNode root, List<Integer> resultList) {
        if (root == null) {
            return;
        }
        if (root.left != null) {
            parseTree(root.left, resultList);
        }
        if (root.right != null) {
            parseTree(root.right, resultList);
        }
        resultList.add(root.val);
    }
}
