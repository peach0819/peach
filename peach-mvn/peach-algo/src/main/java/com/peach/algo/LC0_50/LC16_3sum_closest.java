package com.peach.algo.LC0_50;

import java.util.Arrays;

/**
 * @author feitao.zt
 * @date 2024/7/2
 * 给你一个长度为 n 的整数数组 nums 和 一个目标值 target。请你从 nums 中选出三个整数，使它们的和与 target 最接近。
 * 返回这三个数的和。
 * 假定每组输入只存在恰好一个解。
 * 示例 1：
 * 输入：nums = [-1,2,1,-4], target = 1
 * 输出：2
 * 解释：与 target 最接近的和是 2 (-1 + 2 + 1 = 2) 。
 * 示例 2：
 * 输入：nums = [0,0,0], target = 1
 * 输出：0
 * 提示：
 * 3 <= nums.length <= 1000
 * -1000 <= nums[i] <= 1000
 * -104 <= target <= 104
 */
public class LC16_3sum_closest {

    public int threeSumClosest(int[] nums, int target) {
        if (nums.length == 3) {
            return nums[0] + nums[1] + nums[2];
        }
        Arrays.sort(nums);
        int min = nums[0] + nums[1] + nums[2];
        if (target <= min) {
            return min;
        }
        int len = nums.length;
        int max = nums[len - 1] + nums[len - 2] + nums[len - 3];
        if (target >= max) {
            return max;
        }

        int num = 0;
        int interval = Integer.MAX_VALUE;
        for (int i = 0; i < nums.length - 2; i++) {
            int j = i + 1;
            int k = nums.length - 1;
            while (k > j) {
                int cur = nums[i] + nums[j] + nums[k];
                int curInterval = cur - target;
                int absInterval = Math.abs(curInterval);
                if (absInterval < interval) {
                    interval = absInterval;
                    num = cur;
                }
                if (curInterval == 0) {
                    return cur;
                }
                if (curInterval < 0) {
                    j++;
                    while (j != k && nums[j] == nums[j - 1]) {
                        j++;
                    }
                } else {
                    k--;
                    while (j != k && nums[k] == nums[k + 1]) {
                        k--;
                    }
                }
            }
        }
        return num;
    }
}
