package com.peach.algo;

import java.util.Arrays;

/**
 * @author feitao.zt
 * @date 2023/9/8
 * 给定一个非负整数数组 nums 和一个整数 m ，你需要将这个数组分成 m 个非空的连续子数组。
 * 设计一个算法使得这 m 个子数组各自和的最大值最小。
 * 示例 1：
 * 输入：nums = [7,2,5,10,8], m = 2
 * 输出：18
 * 解释：
 * 一共有四种方法将 nums 分割为 2 个子数组。
 * 其中最好的方式是将其分为 [7,2,5] 和 [10,8] 。
 * 因为此时这两个子数组各自的和的最大值为18，在所有情况中最小。
 * 示例 2：
 * 输入：nums = [1,2,3,4,5], m = 2
 * 输出：9
 * 示例 3：
 * 输入：nums = [1,4,4], m = 3
 * 输出：4
 * 提示：
 * 1 <= nums.length <= 1000
 * 0 <= nums[i] <= 106
 * 1 <= m <= min(50, nums.length)
 */
public class LC410_split_array_largest_sum {

    //f(i, k) = max(f(j, k-1), sum(j+1, i))
    //[1,2,3,4,5]
    public int splitArray(int[] nums, int m) {
        int[][] dp = new int[nums.length + 1][m + 1];
        int[] sum = new int[nums.length + 1];

        for (int i = 1; i <= nums.length; i++) {
            Arrays.fill(dp[i], Integer.MAX_VALUE);
        }

        for (int i = 1; i <= nums.length; i++) {
            sum[i] = sum[i - 1] + nums[i - 1];
            int min = Math.min(i, m);
            for (int j = 1; j <= min; j++) {
                if (j == 1) {
                    dp[i][1] = sum[i];
                } else {
                    for (int k = 1; k < i; k++) {
                        dp[i][j] = Math.min(dp[i][j], Math.max(dp[k][j - 1], sum[i] - sum[k]));
                    }
                }
            }
        }
        return dp[nums.length][m];
    }
}
