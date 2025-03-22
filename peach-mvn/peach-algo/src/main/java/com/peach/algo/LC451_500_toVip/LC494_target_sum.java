package com.peach.algo.LC451_500_toVip;

import java.util.Arrays;

/**
 * @author feitao.zt
 * @date 2025/2/5
 * 给你一个非负整数数组 nums 和一个整数 target 。
 * 向数组中的每个整数前添加 '+' 或 '-' ，然后串联起所有整数，可以构造一个 表达式 ：
 * 例如，nums = [2, 1] ，可以在 2 之前添加 '+' ，在 1 之前添加 '-' ，然后串联起来得到表达式 "+2-1" 。
 * 返回可以通过上述方法构造的、运算结果等于 target 的不同 表达式 的数目。
 * 示例 1：
 * 输入：nums = [1,1,1,1,1], target = 3
 * 输出：5
 * 解释：一共有 5 种方法让最终目标和为 3 。
 * -1 + 1 + 1 + 1 + 1 = 3
 * +1 - 1 + 1 + 1 + 1 = 3
 * +1 + 1 - 1 + 1 + 1 = 3
 * +1 + 1 + 1 - 1 + 1 = 3
 * +1 + 1 + 1 + 1 - 1 = 3
 * 示例 2：
 * 输入：nums = [1], target = 1
 * 输出：1
 * 提示：
 * 1 <= nums.length <= 20
 * 0 <= nums[i] <= 1000
 * 0 <= sum(nums[i]) <= 1000
 * -1000 <= target <= 1000
 */
public class LC494_target_sum {

    public static void main(String[] args) {
        LC494_target_sum lc494_target_sum = new LC494_target_sum();
        System.out.println(lc494_target_sum.findTargetSumWays(new int[]{ 1, 0 }, 1));
    }

    public int findTargetSumWays(int[] nums, int target) {
        Arrays.sort(nums);
        int sum = 0;
        int zeros = 0;
        for (int num : nums) {
            if (num == 0) {
                zeros++;
            }
            sum += num;
        }
        target = sum - target;
        if (target == 0) {
            return 1 << zeros;
        }
        if (target < 0 || target % 2 != 0) {
            return 0;
        }
        target = target / 2;

        //dp[i][值]
        //这里最巧妙的是，[0][0]设为1
        int[][] dp = new int[nums.length][target + 1];
        if (nums[0] == 0) {
            dp[0][0] = 2;
        } else {
            dp[0][0] = 1;
            dp[0][nums[0]] = 1;
        }
        for (int i = 1; i < nums.length; i++) {
            //只处理上一个位置的
            for (int j = 0; j <= target; j++) {
                dp[i][j] = dp[i - 1][j];
                if (j >= nums[i]) {
                    dp[i][j] += dp[i - 1][j - nums[i]];
                }
            }
        }
        return dp[nums.length - 1][target];
    }

}
