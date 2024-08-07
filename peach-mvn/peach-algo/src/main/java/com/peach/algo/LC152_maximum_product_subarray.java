package com.peach.algo;

/**
 * @author feitao.zt
 * @date 2024/8/6
 * 给你一个整数数组 nums ，请你找出数组中乘积最大的非空连续
 * 子数组
 * （该子数组中至少包含一个数字），并返回该子数组所对应的乘积。
 * 测试用例的答案是一个 32-位 整数。
 * 示例 1:
 * 输入: nums = [2,3,-2,4]
 * 输出: 6
 * 解释: 子数组 [2,3] 有最大乘积 6。
 * 示例 2:
 * 输入: nums = [-2,0,-1]
 * 输出: 0
 * 解释: 结果不能为 2, 因为 [-2,-1] 不是子数组。
 * 提示:
 * 1 <= nums.length <= 2 * 104
 * -10 <= nums[i] <= 10
 * nums 的任何前缀或后缀的乘积都 保证 是一个 32-位 整数
 */
public class LC152_maximum_product_subarray {

    public static void main(String[] args) {
        new LC152_maximum_product_subarray().maxProduct(new int[]{ 2, -5, -2, -4, 3 });
    }

    public int maxProduct(int[] nums) {
        if (nums.length == 1) {
            return nums[0];
        }
        //dp[i][0]
        //dp[i][1]
        int max = Integer.MIN_VALUE;
        int positive = 0;
        int negative = 0;
        for (int i = 0; i < nums.length; i++) {
            int num = nums[i];
            if (num == 0) {
                positive = 0;
                negative = 0;
            } else if (num > 0) {
                if (positive == 0) {
                    positive = num;
                } else {
                    positive *= num;
                }
                if (negative != 0) {
                    negative *= num;
                }
                max = Math.max(positive, max);
            } else {
                int tempPos;
                int tempNag;
                if (negative == 0) {
                    tempPos = 0;
                } else {
                    tempPos = negative * num;
                }
                if (positive == 0) {
                    tempNag = num;
                } else {
                    tempNag = positive * num;
                }
                positive = tempPos;
                negative = tempNag;
                max = Math.max(positive, max);
            }
        }

        return max;
    }
}
