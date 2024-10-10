package com.peach.algo.LC251_300_toVip;

/**
 * @author feitao.zt
 * @date 2024/9/12
 * 给你一个整数数组 nums ，找到其中最长严格递增子序列的长度。
 * 子序列 是由数组派生而来的序列，删除（或不删除）数组中的元素而不改变其余元素的顺序。例如，[3,6,2,7] 是数组 [0,3,1,6,2,2,7] 的
 * 子序列
 * 。
 * 示例 1：
 * 输入：nums = [10,9,2,5,3,7,101,18]
 * 输出：4
 * 解释：最长递增子序列是 [2,3,7,101]，因此长度为 4 。
 * 示例 2：
 * 输入：nums = [0,1,0,3,2,3]
 * 输出：4
 * 示例 3：
 * 输入：nums = [7,7,7,7,7,7,7]
 * 输出：1
 * 提示：
 * 1 <= nums.length <= 2500
 * -104 <= nums[i] <= 104
 * 进阶：
 * 你能将算法的时间复杂度降低到 O(n log(n)) 吗?
 */
public class LC300_longest_increasing_subsequence {

    /**
     * 我是傻逼
     * dp[i]表示以nums[i]为结尾的最长队列的长度， 所以从dp[0 ~ i-1]比过去，计算dp[i]
     * 官方进阶解法：贪心+二分，维护每个长度的最小末尾队列
     */
    public int lengthOfLIS(int[] nums) {
        int[] dp = new int[nums.length];
        dp[0] = 1;
        int max = 1;
        for (int i = 1; i < nums.length; i++) {
            int cur = 1;
            for (int j = 0; j < i; j++) {
                if (nums[i] > nums[j]) {
                    cur = Math.max(cur, dp[j] + 1);
                }
            }
            dp[i] = cur;
            max = Math.max(cur, max);
        }
        return max;
    }
}
