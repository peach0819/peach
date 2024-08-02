package com.peach.algo.LC101_150;

import com.peach.algo.base.TreeNode;

/**
 * @author feitao.zt
 * @date 2024/7/25
 * 给你二叉树的根结点 root ，请你将它展开为一个单链表：
 * 展开后的单链表应该同样使用 TreeNode ，其中 right 子指针指向链表中下一个结点，而左子指针始终为 null 。
 * 展开后的单链表应该与二叉树 先序遍历 顺序相同。
 * 示例 1：
 * 输入：root = [1,2,5,3,4,null,6]
 * 输出：[1,null,2,null,3,null,4,null,5,null,6]
 * 示例 2：
 * 输入：root = []
 * 输出：[]
 * 示例 3：
 * 输入：root = [0]
 * 输出：[0]
 * 提示：
 * 树中结点数在范围 [0, 2000] 内
 * -100 <= Node.val <= 100
 * 进阶：你可以使用原地算法（O(1) 额外空间）展开这棵树吗？
 */
public class LC114_flatten_binary_tree_to_linked_list {

    public void flatten(TreeNode root) {
        handle(root);
    }

    private TreeNode handle(TreeNode node) {
        if (node == null) {
            return null;
        }
        if (node.left == null && node.right == null) {
            return node;
        } else if (node.left == null) {
            return handle(node.right);
        } else if (node.right == null) {
            TreeNode leftLast = handle(node.left);
            node.right = node.left;
            node.left = null;
            return leftLast;
        } else {
            TreeNode leftLast = handle(node.left);
            TreeNode rightLast = handle(node.right);
            leftLast.right = node.right;
            node.right = node.left;
            node.left = null;
            return rightLast;
        }
    }
}
