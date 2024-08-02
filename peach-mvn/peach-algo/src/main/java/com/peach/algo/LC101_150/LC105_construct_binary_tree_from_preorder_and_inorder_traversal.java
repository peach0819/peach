package com.peach.algo.LC101_150;

import com.peach.algo.base.TreeNode;

import java.util.HashMap;
import java.util.Map;

/**
 * @author feitao.zt
 * @date 2023/8/24
 * 给定两个整数数组 preorder 和 inorder ，其中 preorder 是二叉树的先序遍历， inorder 是同一棵树的中序遍历，请构造二叉树并返回其根节点。
 * 示例 1:
 * 输入: preorder = [3,9,20,15,7], inorder = [9,3,15,20,7]
 * 输出: [3,9,20,null,null,15,7]
 * 示例 2:
 * 输入: preorder = [-1], inorder = [-1]
 * 输出: [-1]
 */
public class LC105_construct_binary_tree_from_preorder_and_inorder_traversal {

    Map<Integer, Integer> inMap = new HashMap<>();

    /**
     * 获取根节点位置，然后不停的分别左子树，右子树
     */
    public TreeNode buildTree(int[] preorder, int[] inorder) {
        for (int i = 0; i < preorder.length; i++) {
            inMap.put(inorder[i], i);
        }
        return buildCurTree(preorder, inorder, 0, preorder.length - 1, 0, inorder.length - 1);
    }

    /**
     * 输入: preorder = [3,9,20,15,7], inorder = [9,3,15,20,7]
     * 输出: [3,9,20,null,null,15,7]
     */
    private TreeNode buildCurTree(int[] preorder, int[] inorder, int preBegin, int preEnd, int inBegin, int inEnd) {
        if (inBegin > inEnd) {
            return null;
        }
        int rootVal = preorder[preBegin];

        TreeNode treeNode = new TreeNode();
        treeNode.val = rootVal;

        Integer inIndex = inMap.get(rootVal);

        treeNode.left = buildCurTree(preorder, inorder, preBegin + 1, inIndex - inBegin + preBegin, inBegin,
                inIndex - 1);
        treeNode.right = buildCurTree(preorder, inorder, inIndex - inBegin + preBegin + 1, preEnd, inIndex + 1, inEnd);
        return treeNode;
    }

    public static void main(String[] args) {
        TreeNode treeNode = new LC105_construct_binary_tree_from_preorder_and_inorder_traversal()
                .buildTree(new int[]{ 3, 9, 20, 15, 7 }, new int[]{ 9, 3, 15, 20, 7 });
        int i = 1;
    }
}
