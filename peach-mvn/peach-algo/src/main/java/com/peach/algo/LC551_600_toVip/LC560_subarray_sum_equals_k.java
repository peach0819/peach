package com.peach.algo.LC551_600_toVip;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @author feitao.zt
 * @date 2025/6/13
 * 给你一个整数数组 nums 和一个整数 k ，请你统计并返回 该数组中和为 k 的子数组的个数 。
 * 子数组是数组中元素的连续非空序列。
 * 示例 1：
 * 输入：nums = [1,1,1], k = 2
 * 输出：2
 * 示例 2：
 * 输入：nums = [1,2,3], k = 3
 * 输出：2
 * 提示：
 * 1 <= nums.length <= 2 * 104
 * -1000 <= nums[i] <= 1000
 * -107 <= k <= 107
 */
public class LC560_subarray_sum_equals_k {

    public static void main(String[] args) {
        int i = new LC560_subarray_sum_equals_k().subarraySum(new int[]{ 1, 1, 1 }, 2);
    }

    public int subarraySum(int[] nums, int k) {
        //从后往前的值 -> 位置
        Map<Integer, List<Integer>> map = new HashMap<>();
        int sum = 0;
        for (int i = nums.length - 1; i >= 0; i--) {
            int num = nums[i];
            sum += num;
            map.putIfAbsent(sum, new ArrayList<>());
            map.get(sum).add(i);
        }
        if (map.size() == 1 && map.containsKey(0)) {
            return (1 + nums.length) * nums.length / 2;
        }
        int result = map.getOrDefault(k, new ArrayList<>()).size();
        int curSum = 0;
        for (int i = 0; i < nums.length - 1; i++) {
            int num = nums[i];
            curSum += num;
            if (i != nums.length - 1 && curSum == k) {
                result++;
            }
            if (!map.containsKey(sum - k - curSum)) {
                continue;
            }
            List<Integer> list = map.get(sum - k - curSum);
            for (Integer index : list) {
                if (index > i + 1) {
                    result++;
                }
            }
        }
        return result;
    }
}
