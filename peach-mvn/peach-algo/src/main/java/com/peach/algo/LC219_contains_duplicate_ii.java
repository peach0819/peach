package com.peach.algo;

import java.util.HashMap;
import java.util.Map;

/**
 * @author feitao.zt
 * @date 2024/9/3
 * 给你一个整数数组 nums 和一个整数 k ，判断数组中是否存在两个 不同的索引 i 和 j ，满足 nums[i] == nums[j] 且 abs(i - j) <= k 。如果存在，返回 true ；否则，返回 false 。
 * 示例 1：
 * 输入：nums = [1,2,3,1], k = 3
 * 输出：true
 * 示例 2：
 * 输入：nums = [1,0,1,1], k = 1
 * 输出：true
 * 示例 3：
 * 输入：nums = [1,2,3,1,2,3], k = 2
 * 输出：false
 * 提示：
 * 1 <= nums.length <= 105
 * -109 <= nums[i] <= 109
 * 0 <= k <= 105
 */
public class LC219_contains_duplicate_ii {

    public static void main(String[] args) {
        new LC219_contains_duplicate_ii().containsNearbyDuplicate(new int[]{ 1, 0, 1, 1 }, 1);
    }

    public boolean containsNearbyDuplicate(int[] nums, int k) {
        if (k == 0) {
            return false;
        }
        Map<Integer, Integer> map = new HashMap<>();
        for (int i = 0; i < nums.length; i++) {
            int num = nums[i];
            Integer index = map.get(num);
            if (index != null && i - index <= k) {
                return true;
            }
            map.put(num, i);
        }
        return false;
    }

}
