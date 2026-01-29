package com.peach.algo.LC651_700_toVip;

/**
 * @author feitao.zt
 * @date 2026/1/21
 * 给你一个整数数组 nums 和一个整数 k ，找出三个长度为 k 、互不重叠、且全部数字和最大的子数组，并返回这三个子数组。
 * 以下标的数组形式返回结果，数组中的每一项分别指示每个子数组的起始位置（下标从 0 开始）。如果有多个结果，返回字典序最小的一个。
 * 示例 1：
 * 输入：nums = [1,2,1,2,6,7,5,1], k = 2
 * 输出：[0,3,5]
 * 解释：子数组 [1, 2], [2, 6], [7, 5] 对应的起始下标为 [0, 3, 5]。
 * 也可以取 [2, 1], 但是结果 [1, 3, 5] 在字典序上更大。
 * 示例 2：
 * 输入：nums = [1,2,1,2,1,2,1,2,1], k = 2
 * 输出：[0,2,4]
 * 提示：
 * 1 <= nums.length <= 2 * 104
 * 1 <= nums[i] < 216
 * 1 <= k <= floor(nums.length / 3)
 */
public class LC689_maximum_sum_of_3_non_overlapping_subarrays {

    public static void main(String[] args) {
        LC689_maximum_sum_of_3_non_overlapping_subarrays test = new LC689_maximum_sum_of_3_non_overlapping_subarrays();
        //int[] ints = test.maxSumOfThreeSubarrays(new int[]{ 7, 13, 20, 19, 19, 2, 10, 1, 1, 19 }, 3);
        //int[] ints = test.maxSumOfThreeSubarrays(new int[]{ 1, 2, 1, 2, 6, 7, 5, 1 }, 2);

        int[] ints = test.maxSumOfThreeSubarrays(new int[]{ 4, 5, 10, 6, 11, 17, 4, 11, 1, 3 }, 1);
        int i = 1;
    }

    public int[] maxSumOfThreeSubarrays(int[] nums, int k) {
        long[] sum = new long[nums.length - k + 1];
        for (int j = 0; j < k; j++) {
            sum[0] += nums[j];
        }

        for (int i = 1; i < sum.length; i++) {
            sum[i] = sum[i - 1] - nums[i - 1] + nums[i + k - 1];
        }

        //dp[sum的位置][已累加的数字]
        long[][] dp = new long[sum.length][3 + 1];
        dp[0][1] = sum[0];
        for (int i = 1; i < sum.length; i++) {
            dp[i][1] = Math.max(dp[i - 1][1], sum[i]);
        }

        long max3 = 0;
        int max3Index = 0;
        for (int i = 2; i <= 3; i++) {
            for (int j = (i - 1) * k; j < sum.length; j++) {
                dp[j][i] = Math.max(dp[j - k][i - 1] + sum[j], dp[j - 1][i]);
                if (i == 3 && dp[j][i] > max3) {
                    max3 = dp[j][i];
                    max3Index = j;
                }
            }
        }
        int index3 = max3Index;
        long max2 = max3 - sum[index3];
        int index2 = 0;
        for (int i = 0; i < dp.length; i++) {
            if (dp[i][2] == max2) {
                index2 = i;
                break;
            }
        }
        long max1 = max2 - sum[index2];
        int index1 = 0;
        for (int i = 0; i < dp.length; i++) {
            if (dp[i][1] == max1) {
                index1 = i;
                break;
            }
        }
        return new int[]{ index1, index2, index3 };
    }

    //public int[] maxSumOfThreeSubarrays1(int[] nums, int k) {
    //    int[] sum = new int[nums.length - k + 1];
    //    for (int j = 0; j < k; j++) {
    //        sum[0] += nums[j];
    //    }
    //
    //    for (int i = 1; i < sum.length; i++) {
    //        sum[i] = sum[i - 1] - nums[i - 1] + nums[i + k - 1];
    //    }
    //    int max = 0;
    //    int[] result = new int[3];
    //    for (int i = 0; i < sum.length; i++) {
    //        for (int j = i + k; j < sum.length; j++) {
    //            for (int l = j + k; l < sum.length; l++) {
    //                int cur = sum[i] + sum[j] + sum[l];
    //                if (cur > max) {
    //                    max = cur;
    //                    result[0] = i;
    //                    result[1] = j;
    //                    result[2] = l;
    //                }
    //            }
    //        }
    //    }
    //    return result;
    //}
}
