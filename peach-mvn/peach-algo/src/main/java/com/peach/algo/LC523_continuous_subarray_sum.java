package com.peach.algo;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

/**
 * @author feitao.zt
 * @date 2025/3/7
 * 给你一个整数数组 nums 和一个整数 k ，如果 nums 有一个 好的子数组 返回 true ，否则返回 false：
 * 一个 好的子数组 是：
 * 长度 至少为 2 ，且
 * 子数组元素总和为 k 的倍数。
 * 注意：
 * 子数组 是数组中 连续 的部分。
 * 如果存在一个整数 n ，令整数 x 符合 x = n * k ，则称 x 是 k 的一个倍数。0 始终 视为 k 的一个倍数。
 * 示例 1：
 * 输入：nums = [23,2,4,6,7], k = 6
 * 输出：true
 * 解释：[2,4] 是一个大小为 2 的子数组，并且和为 6 。
 * 示例 2：
 * 输入：nums = [23,2,6,4,7], k = 6
 * 输出：true
 * 解释：[23, 2, 6, 4, 7] 是大小为 5 的子数组，并且和为 42 。
 * 42 是 6 的倍数，因为 42 = 7 * 6 且 7 是一个整数。
 * 示例 3：
 * 输入：nums = [23,2,6,4,7], k = 13
 * 输出：false
 * 提示：
 * 1 <= nums.length <= 105
 * 0 <= nums[i] <= 109
 * 0 <= sum(nums[i]) <= 231 - 1
 * 1 <= k <= 231 - 1
 */
public class LC523_continuous_subarray_sum {

    public static void main(String[] args) {
        boolean b = new LC523_continuous_subarray_sum().checkSubarraySum(new int[]{ 0, 1, 0, 3, 0, 4, 0, 4, 0 }, 5);
    }

    /**
     * 我是傻逼
     * 计算从0开始到当前位置合的余数，如果曾经有一个相同的，那这两个余数中间的数加起来一定=0
     */
    public boolean checkSubarraySum(int[] nums, int k) {
        if (nums.length == 1) {
            return false;
        }
        Map<Integer, Integer> has = new HashMap<>();
        has.put(0, -1);
        int sum = 0;
        for (int i = 0; i < nums.length; i++) {
            sum = (sum + nums[i]) % k;
            if (!has.containsKey(sum)) {
                has.put(sum, i);
            } else if (i - has.get(sum) >= 2) {
                return true;
            }
        }
        return false;
    }

    public boolean checkSubarraySum1(int[] nums, int k) {
        if (nums.length == 1) {
            return false;
        }
        Set<Integer> sum = new HashSet<>();
        Set<Integer> cur;
        sum.add(nums[0] % k);
        for (int i = 1; i < nums.length; i++) {
            int num = nums[i] % k;

            cur = new HashSet<>();
            for (Integer last : sum) {
                int newNum = (last + num) % k;
                if (newNum == 0) {
                    return true;
                }
                cur.add(newNum);
            }
            sum.addAll(cur);
            sum.add(num);
        }
        return false;
    }
}
