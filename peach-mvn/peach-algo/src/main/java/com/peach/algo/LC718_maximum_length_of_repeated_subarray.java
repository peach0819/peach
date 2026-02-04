package com.peach.algo;

/**
 * @author feitao.zt
 * @date 2026/2/4
 * 给两个整数数组 nums1 和 nums2 ，返回 两个数组中 公共的 、长度最长的子数组的长度 。
 * 示例 1：
 * 输入：nums1 = [1,2,3,2,1], nums2 = [3,2,1,4,7]
 * 输出：3
 * 解释：长度最长的公共子数组是 [3,2,1] 。
 * 示例 2：
 * 输入：nums1 = [0,0,0,0,0], nums2 = [0,0,0,0,0]
 * 输出：5
 * 提示：
 * 1 <= nums1.length, nums2.length <= 1000
 * 0 <= nums1[i], nums2[i] <= 100
 */
public class LC718_maximum_length_of_repeated_subarray {

    public int findLength(int[] nums1, int[] nums2) {
        // dp[i][j][2] i: nums1的索引 j: nums2的索引 2: 0表示不取 1表示取当前
        int[][][] dp = new int[nums1.length][nums2.length][2];
        for (int i = 0; i < nums2.length; i++) {
            if (nums1[0] == nums2[i]) {
                dp[0][i][0] = 1;
                dp[0][i][1] = 1;
            }
        }
        for (int i = 0; i < nums1.length; i++) {
            if (nums1[i] == nums2[0]) {
                dp[i][0][0] = 1;
                dp[i][0][1] = 1;
            }
        }
        for (int i = 1; i < nums1.length; i++) {
            for (int j = 1; j < nums2.length; j++) {
                if (nums1[i] == nums2[j]) {
                    dp[i][j][1] = dp[i - 1][j - 1][1] + 1;
                }
                dp[i][j][0] = Math.max(Math.max(dp[i - 1][j][0], dp[i][j - 1][0]), dp[i][j][1]);
            }
        }
        return dp[nums1.length - 1][nums2.length - 1][0];
    }
}
