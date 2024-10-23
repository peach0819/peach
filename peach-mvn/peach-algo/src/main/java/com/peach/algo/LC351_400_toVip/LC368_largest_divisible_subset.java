package com.peach.algo.LC351_400_toVip;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * @author feitao.zt
 * @date 2024/10/10
 * 给你一个由 无重复 正整数组成的集合 nums ，请你找出并返回其中最大的整除子集 answer ，子集中每一元素对 (answer[i], answer[j]) 都应当满足：
 * answer[i] % answer[j] == 0 ，或
 * answer[j] % answer[i] == 0
 * 如果存在多个有效解子集，返回其中任何一个均可。
 * 示例 1：
 * 输入：nums = [1,2,3]
 * 输出：[1,2]
 * 解释：[1,3] 也会被视为正确答案。
 * 示例 2：
 * 输入：nums = [1,2,4,8]
 * 输出：[1,2,4,8]
 * 提示：
 * 1 <= nums.length <= 1000
 * 1 <= nums[i] <= 2 * 109
 * nums 中的所有整数 互不相同
 */
public class LC368_largest_divisible_subset {

    /**
     * dp[i][j] i表示index， j = 0最大整除数 1上一个index
     * LIS变种
     */
    public List<Integer> largestDivisibleSubset(int[] nums) {
        Arrays.sort(nums);
        int[][] dp = new int[nums.length][2];
        dp[0][0] = 1;
        dp[0][1] = -1;
        int max = 1;
        int maxLastIndex = 0;
        for (int i = 1; i < nums.length; i++) {
            int cur = 1;
            int lastIndex = -1;
            for (int j = 0; j < i; j++) {
                if (nums[i] % nums[j] == 0) {
                    if (dp[j][0] + 1 > cur) {
                        cur = dp[j][0] + 1;
                        lastIndex = j;
                    }
                }
            }
            dp[i][0] = cur;
            dp[i][1] = lastIndex;
            if (cur > max) {
                max = cur;
                maxLastIndex = i;
            }
        }
        List<Integer> result = new ArrayList<>();
        while (maxLastIndex >= 0) {
            result.add(0, nums[maxLastIndex]);
            maxLastIndex = dp[maxLastIndex][1];
        }
        return result;
    }

}
