package com.peach.algo.LC401_450_toVip;

/**
 * @author feitao.zt
 * @date 2024/10/29
 * 给你一个 只包含正整数 的 非空 数组 nums 。请你判断是否可以将这个数组分割成两个子集，使得两个子集的元素和相等。
 * 示例 1：
 * 输入：nums = [1,5,11,5]
 * 输出：true
 * 解释：数组可以分割成 [1, 5, 5] 和 [11] 。
 * 示例 2：
 * 输入：nums = [1,2,3,5]
 * 输出：false
 * 解释：数组不能分割成两个元素和相等的子集。
 * 提示：
 * 1 <= nums.length <= 200
 * 1 <= nums[i] <= 100
 */
public class LC416_partition_equal_subset_sum {

    public boolean canPartition(int[] nums) {
        int total = 0;
        int max = 0;
        for (int num : nums) {
            max = Math.max(max, num);
            total += num;
        }
        if (total % 2 != 0) {
            return false;
        }
        int target = total / 2;
        if (max == target) {
            return true;
        }
        if (max > target) {
            return false;
        }
        //dp[i][target] = dp[i-1][target - nums[i]] || dp[i-1][target]
        boolean[][] dp = new boolean[nums.length][target + 1];
        for (boolean[] booleans : dp) {
            booleans[0] = true;
        }
        dp[0][nums[0]] = true;
        for (int i = 1; i < nums.length; i++) {
            int num = nums[i];
            for (int j = 1; j <= target; j++) {
                dp[i][j] = dp[i - 1][j] || (j - num >= 0 && dp[i - 1][j - num]);
            }
        }
        return dp[nums.length - 1][target];
    }

    /**
     * 动态规划的更高境界，就是把二维数组转成一维数组，历史i不用记录，只记录最近一次i
     */
    // 恰好装满的背包问题
    // 利用一维dp数组判段0...target能否取到
    public boolean canPartition1(int[] nums) {
        int total = 0;
        for (int num : nums) {
            total += num;
        }
        if (total % 2 == 1) {
            return false;
        }
        int target = total / 2;
        boolean[] dp = new boolean[target + 1];
        dp[0] = true;
        for (int num : nums) {
            //这里因为肯定不会到最后一个才相同，如果最后一个才等于target，说明前面肯定有另外一组target
            if (dp[target]) {
                return true;
            }
            for (int i = target; i >= num; i--) {
                if (dp[i - num] && !dp[i]) {
                    dp[i] = true;
                }
            }
        }
        return false;
    }

}
