package com.peach.algo;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

/**
 * @author feitao.zt
 * @date 2025/11/12
 * 给定一个未排序的整数数组 nums ， 返回最长递增子序列的个数 。
 * 注意 这个数列必须是 严格 递增的。
 * 示例 1:
 * 输入: [1,3,5,4,7]
 * 输出: 2
 * 解释: 有两个最长递增子序列，分别是 [1, 3, 4, 7] 和[1, 3, 5, 7]。
 * 示例 2:
 * 输入: [2,2,2,2,2]
 * 输出: 5
 * 解释: 最长递增子序列的长度是1，并且存在5个子序列的长度为1，因此输出5。
 * 提示:
 * 1 <= nums.length <= 2000
 * -106 <= nums[i] <= 106
 */
public class LC673_number_of_longest_increasing_subsequence {

    public static void main(String[] args) {
        System.out.println(
                new LC673_number_of_longest_increasing_subsequence().findNumberOfLIS(
                        new int[]{ 84, -48, -33, -34, -52, 72, 75, -12, 72, -45 }));
    }

    public int findNumberOfLIS(int[] nums) {
        if (nums.length == 1) {
            return 1;
        }
        int[] dp = new int[nums.length];
        Arrays.fill(dp, 1);
        int max = 1;
        // val[i][j]  i表示index， j表示在index的以当前位置为末尾的最长子序列的长度，值表示子序列数量
        Map<Integer, Integer>[] val = new Map[nums.length];
        for (int i = 0; i < nums.length; i++) {
            Map<Integer, Integer> map = new HashMap<>();
            val[i] = map;
            map.put(1, 1);
            for (int j = 0; j < i; j++) {
                if (nums[i] > nums[j]) {
                    int lastVal = val[j].get(dp[j]);
                    map.putIfAbsent(dp[j] + 1, 0);
                    map.put(dp[j] + 1, map.get(dp[j] + 1) + lastVal);
                    dp[i] = Math.max(dp[i], dp[j] + 1);
                }
            }
            max = Math.max(max, dp[i]);
        }
        int result = 0;
        for (Map<Integer, Integer> map : val) {
            result += map.getOrDefault(max, 0);
        }
        return result;
    }
}
