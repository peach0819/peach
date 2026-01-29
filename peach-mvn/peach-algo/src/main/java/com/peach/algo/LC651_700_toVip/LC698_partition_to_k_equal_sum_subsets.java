package com.peach.algo.LC651_700_toVip;

import java.util.Arrays;

/**
 * @author feitao.zt
 * @date 2026/1/28
 * 给定一个整数数组  nums 和一个正整数 k，找出是否有可能把这个数组分成 k 个非空子集，其总和都相等。
 * 示例 1：
 * 输入： nums = [4, 3, 2, 3, 5, 2, 1], k = 4
 * 输出： True
 * 说明： 有可能将其分成 4 个子集（5），（1,4），（2,3），（2,3）等于总和。
 * 示例 2:
 * 输入: nums = [1,2,3,4], k = 3
 * 输出: false
 * 提示：
 * 1 <= k <= len(nums) <= 16
 * 0 < nums[i] < 10000
 * 每个元素的频率在 [1,4] 范围内
 */
public class LC698_partition_to_k_equal_sum_subsets {

    public static void main(String[] args) {
        System.out.println(new LC698_partition_to_k_equal_sum_subsets()
                .canPartitionKSubsets(new int[]{ 4, 5, 9, 3, 10, 2, 10, 7, 10, 8, 5, 9, 4, 6, 4, 9 }, 5));
    }

    boolean[] visit;
    int[] nums;

    public boolean canPartitionKSubsets(int[] nums, int k) {
        int sum = 0;
        for (int num : nums) {
            sum += num;
        }
        if (sum % k != 0) {
            return false;
        }
        int target = sum / k;
        Arrays.sort(nums);
        if (nums[nums.length - 1] > target) {
            return false;
        }
        this.visit = new boolean[nums.length];
        this.nums = nums;

        for (int i = nums.length - 1; i >= 0; i--) {
            if (visit[i]) {
                continue;
            }
            if (!dfs(i, target)) {
                return false;
            }
        }
        return true;
    }

    private boolean dfs(int beginIndex, int target) {
        for (int i = beginIndex; i >= 0; i--) {
            if (visit[i] || nums[i] > target) {
                continue;
            }
            visit[i] = true;
            if (nums[i] == target) {
                return true;
            }
            if (dfs(i - 1, target - nums[i])) {
                return true;
            }
            visit[i] = false;
        }
        return false;
    }
}
