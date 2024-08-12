package com.peach.algo.LC151_200_toVip;

import com.peach.algo.base.TreeNode;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * @author feitao.zt
 * @date 2024/8/12
 * 给定一个二叉树的 根节点 root，想象自己站在它的右侧，按照从顶部到底部的顺序，返回从右侧所能看到的节点值。
 * 示例 1:
 * 输入: [1,2,3,null,5,null,4]
 * 输出: [1,3,4]
 * 示例 2:
 * 输入: [1,null,3]
 * 输出: [1,3]
 * 示例 3:
 * 输入: []
 * 输出: []
 * 提示:
 * 二叉树的节点个数的范围是 [0,100]
 * -100 <= Node.val <= 100
 */
public class LC199_binary_tree_right_side_view {

    int[] result;
    int maxDepth = 0;

    public List<Integer> rightSideView(TreeNode root) {
        if (root == null) {
            return new ArrayList<>();
        }
        result = new int[100];
        Arrays.fill(result, -101);
        handle(root, 0);
        List<Integer> list = new ArrayList<>();
        for (int i = 0; i <= maxDepth; i++) {
            list.add(result[i]);
        }
        return list;
    }

    private void handle(TreeNode root, int depth) {
        if (result[depth] < -100) {
            result[depth] = root.val;
            maxDepth = Math.max(maxDepth, depth);
        }
        if (root.right != null) {
            handle(root.right, depth + 1);
        }
        if (root.left != null) {
            handle(root.left, depth + 1);
        }
    }
}
