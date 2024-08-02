package com.peach.algo.LC101_150;

import com.peach.algo.base.TreeNode;

/**
 * @author feitao.zt
 * @date 2024/7/24
 * 给定两个整数数组 inorder 和 postorder ，其中 inorder 是二叉树的中序遍历， postorder 是同一棵树的后序遍历，请你构造并返回这颗 二叉树 。
 * 示例 1:
 * 输入：inorder = [9,3,15,20,7], postorder = [9,15,7,20,3]
 * 输出：[3,9,20,null,null,15,7]
 * 示例 2:
 * 输入：inorder = [-1], postorder = [-1]
 * 输出：[-1]
 * 提示:
 * 1 <= inorder.length <= 3000
 * postorder.length == inorder.length
 * -3000 <= inorder[i], postorder[i] <= 3000
 * inorder 和 postorder 都由 不同 的值组成
 * postorder 中每一个值都在 inorder 中
 * inorder 保证是树的中序遍历
 * postorder 保证是树的后序遍历
 */
public class LC106_construct_binary_tree_from_inorder_and_postorder_traversal {

    public static void main(String[] args) {
        new LC106_construct_binary_tree_from_inorder_and_postorder_traversal()
                .buildTree(new int[]{ 9, 3, 15, 20, 7 }, new int[]{ 9, 15, 7, 20, 3 });
        int i = 1;
    }

    public TreeNode buildTree(int[] inorder, int[] postorder) {
        if (inorder.length == 1) {
            return new TreeNode(inorder[0]);
        }
        return build(inorder, 0, inorder.length - 1, postorder, 0, postorder.length - 1);
    }

    private TreeNode build(int[] inorder, int inBegin, int inEnd, int[] postorder, int postBegin, int postEnd) {
        TreeNode node = new TreeNode();
        node.val = postorder[postEnd];

        int inMidIndex = -1;
        for (int i = inEnd; i >= inBegin; i--) {
            if (inorder[i] == postorder[postEnd]) {
                inMidIndex = i;
                break;
            }
        }
        if (inMidIndex > inBegin) {
            node.left = build(inorder, inBegin, inMidIndex - 1, postorder, postBegin,
                    inMidIndex - 1 - inBegin + postBegin);
        }
        if (inMidIndex < inEnd) {
            node.right = build(inorder, inMidIndex + 1, inEnd, postorder, inMidIndex - inBegin + postBegin,
                    postEnd - 1);
        }
        return node;
    }
}
