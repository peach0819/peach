package com.peach.algo.LC201_250_toVip;

import java.util.HashSet;
import java.util.Set;

/**
 * @author feitao.zt
 * @date 2024/9/2
 * 给你一个整数数组 nums 。如果任一值在数组中出现 至少两次 ，返回 true ；如果数组中每个元素互不相同，返回 false 。
 * 示例 1：
 * 输入：nums = [1,2,3,1]
 * 输出：true
 * 示例 2：
 * 输入：nums = [1,2,3,4]
 * 输出：false
 * 示例 3：
 * 输入：nums = [1,1,1,3,3,4,3,2,4,2]
 * 输出：true
 * 提示：
 * 1 <= nums.length <= 105
 * -109 <= nums[i] <= 109
 */
public class LC217_contains_duplicate {

    public boolean containsDuplicate(int[] nums) {
        Set<Integer> set = new HashSet<>();
        for (int num : nums) {
            if (!set.add(num)) {
                return true;
            }
        }
        return false;
    }
}
