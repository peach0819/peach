package com.peach.algo.LC201_250_toVip;

/**
 * @author feitao.zt
 * @date 2024/8/30
 * 你是一个专业的小偷，计划偷窃沿街的房屋，每间房内都藏有一定的现金。这个地方所有的房屋都 围成一圈 ，这意味着第一个房屋和最后一个房屋是紧挨着的。同时，相邻的房屋装有相互连通的防盗系统，如果两间相邻的房屋在同一晚上被小偷闯入，系统会自动报警 。
 * 给定一个代表每个房屋存放金额的非负整数数组，计算你 在不触动警报装置的情况下 ，今晚能够偷窃到的最高金额。
 * 示例 1：
 * 输入：nums = [2,3,2]
 * 输出：3
 * 解释：你不能先偷窃 1 号房屋（金额 = 2），然后偷窃 3 号房屋（金额 = 2）, 因为他们是相邻的。
 * 示例 2：
 * 输入：nums = [1,2,3,1]
 * 输出：4
 * 解释：你可以先偷窃 1 号房屋（金额 = 1），然后偷窃 3 号房屋（金额 = 3）。
 * 偷窃到的最高金额 = 1 + 3 = 4 。
 * 示例 3：
 * 输入：nums = [1,2,3]
 * 输出：3
 * 提示：
 * 1 <= nums.length <= 100
 * 0 <= nums[i] <= 1000
 */
public class LC213_house_robber_ii {

    public static void main(String[] args) {
        new LC213_house_robber_ii().rob(new int[]{ 1, 2, 3, 1 });
    }

    public int rob(int[] nums) {
        if (nums.length == 1) {
            return nums[0];
        }
        if (nums.length == 2) {
            return Math.max(nums[0], nums[1]);
        }
        //分为不偷第一个和不偷最后一个
        return Math.max(handle(nums, 0, nums.length - 2), handle(nums, 1, nums.length - 1));
    }

    public int handle(int[] nums, int begin, int end) {
        //dp[i][j]: i = nums.index,  j = 0这个不偷 1这个偷
        int[][] dp = new int[nums.length][2];
        dp[begin][0] = 0;
        dp[begin][1] = nums[begin];
        for (int i = begin + 1; i <= end; i++) {
            dp[i][0] = Math.max(dp[i - 1][0], dp[i - 1][1]);
            dp[i][1] = dp[i - 1][0] + nums[i];
        }
        return Math.max(dp[end][0], dp[end][1]);
    }
}
