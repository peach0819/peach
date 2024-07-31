package com.peach.algo;

import java.util.HashSet;
import java.util.Set;

/**
 * @author feitao.zt
 * @date 2024/7/30
 * 给定一个未排序的整数数组 nums ，找出数字连续的最长序列（不要求序列元素在原数组中连续）的长度。
 * 请你设计并实现时间复杂度为 O(n) 的算法解决此问题。
 * 示例 1：
 * 输入：nums = [100,4,200,1,3,2]
 * 输出：4
 * 解释：最长数字连续序列是 [1, 2, 3, 4]。它的长度为 4。
 * 示例 2：
 * 输入：nums = [0,3,7,2,5,8,4,6,0,1]
 * 输出：9
 * 提示：
 * 0 <= nums.length <= 105
 * -109 <= nums[i] <= 109
 */
public class LC128_longest_consecutive_sequence {

    /**
     * 实际时间复杂度是O(2n)
     */
    public int longestConsecutive(int[] nums) {
        Set<Integer> set = new HashSet<>();
        for (int x : nums) {
            set.add(x);
        }
        int res = 0;
        for (int x : set) {
            if (!set.contains(x - 1)) {
                int y = x;
                while (set.contains(y + 1)) y++;
                res = Math.max(res, y - x + 1);
            }
        }
        return res;
    }

}
