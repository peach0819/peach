package com.peach.algo.LC101_150;

import com.peach.algo.base.TreeNode;

/**
 * @author feitao.zt
 * @date 2024/7/25
 * 给你一个整数数组 nums ，其中元素已经按 升序 排列，请你将其转换为一棵平衡二叉搜索树。
 * 示例 1：
 * 输入：nums = [-10,-3,0,5,9]
 * 输出：[0,-3,9,-10,null,5]
 * 解释：[0,-10,5,null,-3,null,9] 也将被视为正确答案：
 * 示例 2：
 * 输入：nums = [1,3]
 * 输出：[3,1]
 * 解释：[1,null,3] 和 [3,1] 都是高度平衡二叉搜索树。
 */
public class LC108_convert_sorted_array_to_binary_search_tree {

    public TreeNode sortedArrayToBST(int[] nums) {
        return handle(nums, 0, nums.length - 1);
    }

    private TreeNode handle(int[] nums, int begin, int end) {
        int mid = (begin + end) / 2;
        TreeNode node = new TreeNode(nums[mid]);
        if (begin < mid) {
            node.left = handle(nums, begin, mid - 1);
        }
        if (end > mid) {
            node.right = handle(nums, mid + 1, end);
        }
        return node;
    }
}
